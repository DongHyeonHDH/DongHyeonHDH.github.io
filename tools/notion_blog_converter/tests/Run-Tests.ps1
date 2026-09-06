Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot '..\Convert-NotionBlog.ps1'
$failures = [Collections.Generic.List[string]]::new()

function Assert-True([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

function New-Fixture([string] $Name) {
    $root = Join-Path ([IO.Path]::GetTempPath()) ('notion-converter-' + $Name + '-' + [guid]::NewGuid().ToString('N'))
    $source = Join-Path $root 'source'
    $blog = Join-Path $root 'blog'
    $stage = Join-Path $root 'stage'
    [IO.Directory]::CreateDirectory($source) | Out-Null
    [IO.Directory]::CreateDirectory((Join-Path $blog '_pages\언어\자바')) | Out-Null
    [IO.Directory]::CreateDirectory((Join-Path $blog '_pages\cs\데이터베이스')) | Out-Null
    return @{ root = $root; source = $source; blog = $blog; stage = $stage }
}

function Invoke-Test([string] $Name, [scriptblock] $Body) {
    try { & $Body; Write-Output "PASS $Name" }
    catch { $failures.Add("FAIL ${Name}: $($_.Exception.Message) at $($_.ScriptStackTrace)"); Write-Output $failures[-1] }
}

Invoke-Test 'success writes UTF-8 post, manifest, and copied image' {
    $f = New-Fixture 'success'
    try {
        $asset = Join-Path $f.source '그림.png'
        [IO.File]::WriteAllBytes($asset, [byte[]](1, 2, 3))
        $md = "# 자바 예외`n`n날짜: 2026/07/31`n`n본문 그대로`n`n![그림](%EA%B7%B8%EB%A6%BC.png)`n"
        [IO.File]::WriteAllText((Join-Path $f.source '자바 예외 0123456789abcdef0123456789abcdef.md'), $md, [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage -Write) -join "`n") | ConvertFrom-Json
        Assert-True ($json.counts.created -eq 1) 'Expected one created post.'
        $post = Join-Path $f.stage '_pages\언어\자바\자바-예외.md'
        Assert-True (Test-Path -LiteralPath $post) 'Post was not created.'
        $text = [IO.File]::ReadAllText($post, [Text.Encoding]::UTF8)
        Assert-True ($text.Contains('본문 그대로')) 'Body content changed or disappeared.'
        Assert-True ($text.Contains('/assets/img/notion/0123456789abcdef0123456789abcdef/그림.png')) 'Image was not rewritten.'
        Assert-True (Test-Path -LiteralPath (Join-Path $f.stage 'conversion-manifest.json')) 'Manifest missing.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'existing destination is never overwritten' {
    $f = New-Fixture 'existing'
    try {
        $sourceFile = Join-Path $f.source '자바 예외 0123456789abcdef0123456789abcdef.md'
        [IO.File]::WriteAllText($sourceFile, "# 자바 예외`n날짜: 2026/01/02`n새 글", [Text.UTF8Encoding]::new($false))
        $existing = Join-Path $f.blog '_pages\언어\자바\자바-예외.md'
        [IO.File]::WriteAllText($existing, "---`ntitle: 기존`n---`n보존", [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n") | ConvertFrom-Json
        Assert-True (@($json.entries | Where-Object reason -eq 'existing_destination').Count -eq 1) 'Existing destination was not rejected.'
        Assert-True (([IO.File]::ReadAllText($existing)).Contains('보존')) 'Existing destination changed.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'path traversal image is rejected' {
    $f = New-Fixture 'traversal'
    try {
        [IO.File]::WriteAllText((Join-Path $f.source '자바 보안 0123456789abcdef0123456789abcdef.md'), "# 자바 보안`n날짜: 2026/01/02`n![x](../outside.png)", [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n") | ConvertFrom-Json
        Assert-True (@($json.entries | Where-Object status -eq 'error').Count -eq 1) 'Traversal was not rejected.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'invalid explicit date is rejected' {
    $f = New-Fixture 'date'
    try {
        [IO.File]::WriteAllText((Join-Path $f.source '자바 날짜 0123456789abcdef0123456789abcdef.md'), "# 자바 날짜`n날짜: 2026/13/40", [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n") | ConvertFrom-Json
        Assert-True (@($json.entries | Where-Object status -eq 'error').Count -eq 1) 'Invalid date was not rejected.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'missing date is skipped by default' {
    $f = New-Fixture 'missing-date'
    try {
        [IO.File]::WriteAllText((Join-Path $f.source 'java-undated 0123456789abcdef0123456789abcdef.md'), "# java undated`nbody", [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n") | ConvertFrom-Json
        Assert-True (@($json.entries | Where-Object { $_.PSObject.Properties['reason'] -and $_.reason -eq 'date_missing' }).Count -eq 1) 'Undated content was not skipped.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'Korean filename date is inferred only with DefaultYear' {
    $f = New-Fixture 'filename-date'
    try {
        [IO.File]::WriteAllText((Join-Path $f.source '6월 23일 java 공부 0123456789abcdef0123456789abcdef.md'), "# java study`nbody", [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage -DefaultYear 2026) -join "`n") | ConvertFrom-Json
        $planned = @($json.entries | Where-Object status -eq 'planned')
        Assert-True ($planned.Count -eq 1) 'Filename-dated content was not planned.'
        Assert-True ($planned[0].date -eq '2026-06-23') 'Filename date was inferred incorrectly.'
        Assert-True ($planned[0].warning -eq 'date_inferred_from_filename') 'Inference warning is missing.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'secret-risk files are excluded without leaking values' {
    $f = New-Fixture 'secret'
    try {
        [IO.File]::WriteAllText((Join-Path $f.source '아이디와 비번 0123456789abcdef0123456789abcdef.md'), "# 자바 설정`npassword: do-not-report-this", [Text.UTF8Encoding]::new($false))
        $raw = (& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n"
        $json = ($raw | ConvertFrom-Json)
        Assert-True (@($json.entries | Where-Object status -eq 'excluded').Count -eq 1) 'Secret-risk file was not excluded.'
        Assert-True (-not $raw.Contains('do-not-report-this')) 'A secret value leaked into the report.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

Invoke-Test 'duplicate content in export is skipped' {
    $f = New-Fixture 'duplicate'
    try {
        $body = "# database April 13`ndate: 2026-04-13`nsame database body"
        [IO.File]::WriteAllText((Join-Path $f.source 'database-first 0123456789abcdef0123456789abcdef.md'), $body, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText((Join-Path $f.source 'database-second fedcba9876543210fedcba9876543210.md'), $body, [Text.UTF8Encoding]::new($false))
        $json = ((& $scriptPath -SourceRoot $f.source -BlogRoot $f.blog -StagingRoot $f.stage) -join "`n") | ConvertFrom-Json
        Assert-True (@($json.entries | Where-Object { $_.PSObject.Properties['reason'] -and $_.reason -eq 'duplicate_content_in_export' }).Count -eq 1) 'Duplicate content was not detected.'
    } finally { if (Test-Path $f.root) { Remove-Item -LiteralPath $f.root -Recurse -Force } }
}

if ($failures.Count -gt 0) { throw ($failures -join "`n") }
Write-Output 'All tests passed.'
