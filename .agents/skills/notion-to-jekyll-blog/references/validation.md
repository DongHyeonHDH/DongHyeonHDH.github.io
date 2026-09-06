# Import validation

Run these checks after staging and again after additive copying into the blog.

## Repository integrity

- Capture `git status --short` before and after the import.
- Confirm tracked-file diffs are empty unless the user explicitly requested a non-post change.
- Confirm every destination was absent before copying.
- Do not stage, commit, push, or publish unless explicitly requested.

## Markdown and front matter

- Decode and write files as UTF-8.
- Require exactly one opening and closing front matter delimiter at the start.
- Require non-empty `title` and a valid evidence-backed `date`.
- Follow the real repository's tag, thumbnail, bookmark, and quoting conventions.
- Verify fenced code blocks are balanced and language labels are preserved.
- Reject unresolved Notion IDs in display titles and destination filenames.

## Content fidelity

- Compare each staged post with its source map.
- Verify code blocks, commands, URLs, numbers, product names, and technical claims were not changed during the editorial pass.
- Verify split sources have no silently omitted publishable sections.
- Do not introduce results, causes, lessons, compatibility guarantees, or personal experiences absent from the source.

## Links, images, and safety

- Reject path traversal and references outside the approved source root.
- Copy local images to a unique blog asset path, then verify the rewritten URL resolves.
- Leave remote URLs unchanged unless the user asks to update them.
- Exclude secret-risk content without echoing detected values into logs or reports.

## Converter checks

For batch work, run:

```powershell
& .\tools\notion_blog_converter\tests\Run-Tests.ps1
```

Run the converter from the blog repository with an explicit staging path outside the repository:

```powershell
& .\tools\notion_blog_converter\Convert-NotionBlog.ps1 `
  -SourceRoot '<notion-export-root>' `
  -BlogRoot (Get-Location).Path `
  -StagingRoot '<external-staging-root>' `
  -DefaultYear 2026
```

Omit `-DefaultYear` unless the year is established. Add `-Write` only after reviewing the dry-run JSON. The converter creates staging output; it does not authorize copying, committing, or publishing.

If Ruby/Bundler is available, build Jekyll to a disposable destination and report the result. If it is unavailable, report that limitation instead of claiming a successful site build.
