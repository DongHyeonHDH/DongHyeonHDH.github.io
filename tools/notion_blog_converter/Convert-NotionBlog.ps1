[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SourceRoot,

    [Parameter(Mandatory = $true)]
    [string] $BlogRoot,

    [string] $StagingRoot = (Join-Path $PSScriptRoot '..\..\output\notion-blog-staging'),

    [ValidateRange(1900, 9999)]
    [Nullable[int]] $DefaultYear,

    [switch] $Write
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Get-FullPath([string] $Path) {
    return [IO.Path]::GetFullPath($Path)
}

function Get-RelativePath([string] $Root, [string] $Path) {
    $rootFull = (Get-FullPath $Root).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $rootUri = [Uri]::new($rootFull)
    $pathUri = [Uri]::new((Get-FullPath $Path))
    return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace('/', [IO.Path]::DirectorySeparatorChar)
}

function Assert-ContainedPath([string] $Path, [string] $Root, [string] $Label) {
    $full = Get-FullPath $Path
    $rootFull = (Get-FullPath $Root).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label escapes its allowed root: $Path"
    }
    return $full
}

function Get-Title([string] $Text, [string] $FileName) {
    $heading = [regex]::Match($Text, '(?m)^#\s+(.+?)\s*$')
    if ($heading.Success) { return $heading.Groups[1].Value.Trim() }
    return ([regex]::Replace([IO.Path]::GetFileNameWithoutExtension($FileName), '\s+[0-9a-fA-F]{32}$', '')).Trim()
}

function Convert-ToSlug([string] $Title) {
    $value = $Title.Normalize([Text.NormalizationForm]::FormKC).ToLowerInvariant()
    $value = [regex]::Replace($value, '[\\/:*?"<>|#%{}\[\]]', ' ')
    $value = [regex]::Replace($value, '[^\p{L}\p{Nd}._-]+', '-')
    $value = [regex]::Replace($value, '-+', '-').Trim('-', '.', ' ')
    if ([string]::IsNullOrWhiteSpace($value)) { throw 'Title does not produce a safe slug.' }
    if ($value -eq '.' -or $value -eq '..') { throw 'Unsafe slug.' }
    return $value
}

function Get-SourceId([string] $FileName) {
    $match = [regex]::Match([IO.Path]::GetFileNameWithoutExtension($FileName), '([0-9a-fA-F]{32})$')
    if ($match.Success) { return $match.Groups[1].Value.ToLowerInvariant() }
    $bytes = [Text.Encoding]::UTF8.GetBytes($FileName)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').Substring(0, 32).ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Get-PostDate([string] $Text, [string] $FileName, [Nullable[int]] $FallbackYear) {
    $property = [regex]::Match($Text, '(?m)^(?:날짜|Date|date)\s*:\s*(.+?)\s*$')
    if ($property.Success) {
        $raw = $property.Groups[1].Value.Trim()
        $match = [regex]::Match($raw, '(?<y>\d{4})\s*(?:년|[-/.])\s*(?<m>\d{1,2})\s*(?:월|[-/.])\s*(?<d>\d{1,2})')
        if (-not $match.Success) { throw 'An explicit date property exists but is not supported.' }
        try {
            $date = [DateTime]::new([int]$match.Groups['y'].Value, [int]$match.Groups['m'].Value, [int]$match.Groups['d'].Value)
            return @{ date = $date.ToString('yyyy-MM-dd'); warning = $null }
        } catch {
            throw 'An explicit date property is invalid.'
        }
    }
    if ($null -ne $FallbackYear) {
        $nameMatch = [regex]::Match($FileName, '(?<m>\d{1,2})\s*월\s*(?<d>\d{1,2})\s*일')
        if ($nameMatch.Success) {
            try {
                $date = [DateTime]::new([int]$FallbackYear, [int]$nameMatch.Groups['m'].Value, [int]$nameMatch.Groups['d'].Value)
                return @{ date = $date.ToString('yyyy-MM-dd'); warning = 'date_inferred_from_filename' }
            } catch {
                throw 'A filename date is invalid for DefaultYear.'
            }
        }
    }
    return @{ date = $null; warning = 'date_missing' }
}

function Get-Tags([string] $Text, [string] $Category) {
    $tags = [Collections.Generic.List[string]]::new()
    $property = [regex]::Match($Text, '(?m)^(?:태그|Tags|tags)\s*:\s*(.+?)\s*$')
    if ($property.Success) {
        foreach ($tag in ($property.Groups[1].Value -split ',')) {
            $clean = $tag.Trim()
            if ($clean -and -not $tags.Contains($clean)) { $tags.Add($clean) }
        }
    }
    $leaf = ($Category -split '[\\/]')[-1]
    if (-not $tags.Contains($leaf)) { $tags.Add($leaf) }
    return $tags.ToArray()
}

function Get-Category([string] $RelativePath, [string] $Title) {
    $probe = ($RelativePath + ' ' + $Title).ToLowerInvariant()
    if ($probe -match '바로그림') { return '프로젝트\바로그림' }
    if ($probe -match '프로젝트|공모전') { return '프로젝트' }
    if ($probe -match 'java|자바') { return '언어\자바' }
    if ($probe -match 'kafka|카프카') { return '백엔드\kafka 공부' }
    if ($probe -match 'docker|도커|kubernetes|쿠버네티스|배포|aws|github action') { return '백엔드\배포' }
    if ($probe -match 'database|dbms|데이터베이스|sql|jpa|redis|mysql|lock') { return 'cs\데이터베이스' }
    if ($probe -match 'network|네트워크|http|tcp|udp|dns') { return 'cs\네트워크' }
    if ($probe -match '운영체제|\bos\b|프로세스|스레드|교착') { return 'cs\os' }
    if ($probe -match 'web programming|javascript|html|css|웹') { return 'cs\웹' }
    if ($probe -match 'spring|backend|백엔드|elasticsearch|elastic') { return '백엔드' }
    if ($probe -match 'til|학습 일지|교육 학습') { return 'Today I Learned' }
    return $null
}

function Test-SecretRisk([string] $RelativePath, [string] $Text) {
    if ($RelativePath -match '(?i)(아이디와\s*비번|비밀번호|passwords?|credentials?|secrets?|\.env(?:\.|$))') {
        return 'sensitive_path_name'
    }
    $patterns = @(
        '(?im)^\s*(?:password|passwd|pwd|비밀번호|비번|api[_ -]?key|client[_ -]?secret|access[_ -]?token)\s*[:=]\s*\S+',
        '(?m)-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
        '(?i)\bAKIA[0-9A-Z]{16}\b'
    )
    foreach ($pattern in $patterns) {
        if ([regex]::IsMatch($Text, $pattern)) { return 'credential_pattern_detected' }
    }
    return $null
}

function Remove-FrontMatter([string] $Text) {
    return [regex]::Replace($Text, '\A---\r?\n.*?\r?\n---\r?\n', '', [Text.RegularExpressions.RegexOptions]::Singleline)
}

function Get-NormalizedHash([string] $Text) {
    $normalized = (Remove-FrontMatter $Text) -replace '\r\n?', "`n"
    $normalized = [regex]::Replace($normalized, '[ \t]+(?=\n)', '').Trim()
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($normalized)))).Replace('-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
}

function Get-ExistingBlogIndex([string] $Root) {
    $titles = @{}
    $hashes = @{}
    Get-ChildItem -LiteralPath (Join-Path $Root '_pages') -File -Recurse -Filter '*.md' | ForEach-Object {
        $text = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)
        $titleMatch = [regex]::Match($text, '(?m)^title:\s*["'']?(.*?)["'']?\s*$')
        if ($titleMatch.Success) { $titles[$titleMatch.Groups[1].Value.Trim().ToLowerInvariant()] = $_.FullName }
        $hashes[(Get-NormalizedHash $text)] = $_.FullName
    }
    return @{ titles = $titles; hashes = $hashes }
}

function Format-FrontMatter([string] $Title, [string[]] $Tags, [string] $Date, [string] $SourceId) {
    $titleJson = ConvertTo-Json $Title -Compress
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('---')
    $lines.Add("title: $titleJson")
    $lines.Add('tags:')
    foreach ($tag in $Tags) { $lines.Add('  - ' + (ConvertTo-Json $tag -Compress)) }
    $lines.Add("date: `"$Date`"")
    $lines.Add('thumbnail: "/assets/img/thumbnail/empty.jpg"')
    $lines.Add('bookmark: false')
    $lines.Add("notion_id: `"$SourceId`"")
    $lines.Add('---')
    return ($lines -join "`n") + "`n`n"
}

$source = Get-FullPath $SourceRoot
$blog = Get-FullPath $BlogRoot
$stage = Get-FullPath $StagingRoot
if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Source root not found: $source" }
if (-not (Test-Path -LiteralPath (Join-Path $blog '_pages') -PathType Container)) { throw "Blog _pages directory not found: $blog" }
if ($stage.StartsWith(($blog.TrimEnd('\') + '\'), [StringComparison]::OrdinalIgnoreCase)) { throw 'StagingRoot must not be inside BlogRoot.' }

$blogIndex = Get-ExistingBlogIndex $blog
$seenHashes = @{}
$seenTitles = @{}
$entries = [Collections.Generic.List[object]]::new()
$assetPlans = [Collections.Generic.List[object]]::new()
$csvFiles = @(Get-ChildItem -LiteralPath $source -File -Recurse -Filter '*.csv' | Sort-Object FullName)
$mdFiles = @(Get-ChildItem -LiteralPath $source -File -Recurse -Filter '*.md' | Sort-Object FullName)

foreach ($file in $mdFiles) {
    $relative = Get-RelativePath $source $file.FullName
    try {
        [void](Assert-ContainedPath $file.FullName $source 'Source file')
        $text = [IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8)
        if ($text.StartsWith('---') -and -not [regex]::IsMatch($text, '\A---\r?\n.*?\r?\n---\r?\n', [Text.RegularExpressions.RegexOptions]::Singleline)) {
            throw 'Malformed source front matter.'
        }
        $secretReason = Test-SecretRisk $relative $text
        if ($secretReason) {
            $entries.Add([ordered]@{ source = $relative; status = 'excluded'; reason = $secretReason })
            continue
        }
        $title = Get-Title $text $file.Name
        if ([string]::IsNullOrWhiteSpace($title)) { throw 'Title is missing.' }
        $category = Get-Category $relative $title
        if (-not $category) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'no_matching_existing_blog_category' })
            continue
        }
        $blogCategory = Assert-ContainedPath (Join-Path (Join-Path $blog '_pages') $category) (Join-Path $blog '_pages') 'Blog category'
        if (-not (Test-Path -LiteralPath $blogCategory -PathType Container)) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'mapped_blog_category_missing'; category = $category })
            continue
        }
        $sourceId = Get-SourceId $file.Name
        $slug = Convert-ToSlug $title
        $dateInfo = Get-PostDate $text $file.Name $DefaultYear
        if (-not $dateInfo.date) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'date_missing'; category = $category })
            continue
        }
        $targetRelative = Join-Path (Join-Path '_pages' $category) ($slug + '.md')
        $blogTarget = Assert-ContainedPath (Join-Path $blog $targetRelative) $blog 'Blog target'
        $stageTarget = Assert-ContainedPath (Join-Path $stage $targetRelative) $stage 'Staging target'
        if (Test-Path -LiteralPath $blogTarget) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'existing_destination'; target = $targetRelative })
            continue
        }
        if (Test-Path -LiteralPath $stageTarget) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'existing_staging_destination'; target = $targetRelative })
            continue
        }
        $contentHash = Get-NormalizedHash $text
        if ($blogIndex.hashes.ContainsKey($contentHash)) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'duplicate_content_in_blog'; existing = Get-RelativePath $blog $blogIndex.hashes[$contentHash] })
            continue
        }
        if ($seenHashes.ContainsKey($contentHash)) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'duplicate_content_in_export'; existing = $seenHashes[$contentHash] })
            continue
        }
        $titleKey = $title.Trim().ToLowerInvariant()
        if ($blogIndex.titles.ContainsKey($titleKey)) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'duplicate_title_in_blog'; existing = Get-RelativePath $blog $blogIndex.titles[$titleKey] })
            continue
        }
        if ($seenTitles.ContainsKey($titleKey)) {
            $entries.Add([ordered]@{ source = $relative; status = 'skipped'; reason = 'duplicate_title_in_export'; existing = $seenTitles[$titleKey] })
            continue
        }
        $pageAssetTargets = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $rewritten = [regex]::Replace($text, '!\[(?<alt>[^\]]*)\]\((?<url>(?:[^()\r\n]|\([^()\r\n]*\))+?)(?<tail>\s+"[^"]*")?\)', {
            param($match)
            $url = $match.Groups['url'].Value
            if ($url -match '^(?i)(https?:|data:|/)') { return $match.Value }
            $decoded = [Uri]::UnescapeDataString($url.Replace('/', [IO.Path]::DirectorySeparatorChar))
            $assetSource = Assert-ContainedPath (Join-Path $file.DirectoryName $decoded) $source 'Image link'
            if (-not (Test-Path -LiteralPath $assetSource -PathType Leaf)) { throw "Referenced image is missing: $url" }
            $assetName = [IO.Path]::GetFileName($assetSource)
            $safeName = [regex]::Replace($assetName, '[^\p{L}\p{Nd}._-]+', '-')
            if (-not $pageAssetTargets.Add($safeName)) {
                $shortHash = (Get-FileHash -LiteralPath $assetSource -Algorithm SHA256).Hash.Substring(0, 8).ToLowerInvariant()
                $safeName = [IO.Path]::GetFileNameWithoutExtension($safeName) + '-' + $shortHash + [IO.Path]::GetExtension($safeName)
            }
            $assetRelative = Join-Path (Join-Path 'assets\img\notion' $sourceId) $safeName
            $assetStage = Assert-ContainedPath (Join-Path $stage $assetRelative) $stage 'Staging asset'
            $assetPlans.Add([ordered]@{ source = $assetSource; target = $assetStage; target_relative = $assetRelative })
            $webPath = '/' + ($assetRelative -replace '\\', '/')
            return '![' + $match.Groups['alt'].Value + '](' + $webPath + $match.Groups['tail'].Value + ')'
        })

        foreach ($link in [regex]::Matches($text, '(?<!!)\[[^\]]+\]\((?<url>[^)\s]+)')) {
            $url = $link.Groups['url'].Value
            if ($url -match '^(?i)(https?:|mailto:|#|/)') { continue }
            $decoded = [Uri]::UnescapeDataString($url.Replace('/', [IO.Path]::DirectorySeparatorChar))
            [void](Assert-ContainedPath (Join-Path $file.DirectoryName $decoded) $source 'Local link')
        }

        $tags = Get-Tags $text $category
        $frontMatter = Format-FrontMatter $title $tags $dateInfo.date $sourceId
        $output = $frontMatter + $rewritten
        $seenTitles[$titleKey] = $relative
        $seenHashes[$contentHash] = $relative
        $entry = [ordered]@{
            source = $relative
            status = $(if ($Write) { 'created' } else { 'planned' })
            category = $category
            target = $targetRelative
            title = $title
            date = $dateInfo.date
            warning = $dateInfo.warning
            content_sha256 = $contentHash
        }
        $entries.Add($entry)
        if ($Write) {
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($stageTarget)) | Out-Null
            [IO.File]::WriteAllText($stageTarget, $output, $utf8NoBom)
        }
    } catch {
        $entries.Add([ordered]@{ source = $relative; status = 'error'; reason = $_.Exception.Message })
    }
}

if ($Write) {
    foreach ($asset in $assetPlans) {
        if (Test-Path -LiteralPath $asset.target) { throw "Refusing to overwrite staged asset: $($asset.target_relative)" }
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($asset.target)) | Out-Null
        [IO.File]::Copy($asset.source, $asset.target, $false)
    }
}

$counts = @{}
foreach ($entry in $entries) {
    $status = [string]$entry['status']
    if ($counts.ContainsKey($status)) { $counts[$status]++ } else { $counts[$status] = 1 }
}
$manifest = [ordered]@{
    schema_version = 1
    mode = $(if ($Write) { 'write-to-staging' } else { 'dry-run' })
    source_root = $source
    blog_root_read_only = $blog
    staging_root = $stage
    markdown_files = $mdFiles.Count
    csv_inventory = @($csvFiles | ForEach-Object { Get-RelativePath $source $_.FullName })
    csv_policy = 'inventory_only_not_converted'
    counts = $counts
    entries = $entries
}
$manifestJson = $manifest | ConvertTo-Json -Depth 8
if ($Write) {
    [IO.Directory]::CreateDirectory($stage) | Out-Null
    $manifestPath = Join-Path $stage 'conversion-manifest.json'
    if (Test-Path -LiteralPath $manifestPath) { throw "Refusing to overwrite manifest: $manifestPath" }
    [IO.File]::WriteAllText($manifestPath, $manifestJson, $utf8NoBom)
}
$manifestJson
