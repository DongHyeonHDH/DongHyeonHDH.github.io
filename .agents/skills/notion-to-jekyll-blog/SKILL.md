---
name: notion-to-jekyll-blog
description: Migrate exported Notion Markdown into new posts for this Jekyll blog while preserving source content, routing by the existing _pages taxonomy, and validating front matter, images, duplicates, dates, and secret risk. Use for additive Notion-to-blog imports; do not use to rewrite existing posts or for ordinary post drafting.
---

# Notion to Jekyll Blog

Move publishable material from a Notion export into this repository as reviewable, additive Jekyll posts. Preserve the author's content and keep existing posts immutable.

## Establish the boundary

1. Resolve the repository root, Notion export root, and a staging directory outside the blog repository.
2. Read applicable `AGENTS.md`, inspect `git status`, `_pages`, representative posts, `index.md` files, and actual front matter before planning destinations.
3. Treat all existing blog files as read-only. Never overwrite, rename, reformat, or delete them during an import.
4. Read [references/category-map.md](references/category-map.md) when selecting destinations or splitting a mixed-topic source.
5. Read [references/validation.md](references/validation.md) before creating final files or reporting completion.

If the source root, blog root, or intended publication scope cannot be determined safely, stop before writing and ask one concise question.

## Coordinate the specialist agents

For batch imports, use the following roles in order. Give each agent exact source, staging, and repository paths, and wait for its result before starting the next write-capable role.

1. `documentation-engineer`: inspect the blog read-only; report front matter conventions, available category directories, required `index.md` files, image conventions, duplicates, and a source-to-destination plan.
2. `technical-writer`: create new files in staging only. Split mixed sources at existing heading boundaries and arrange the selected source material for the chosen topic. Do not edit the live blog.
3. `content-quality-editor`: perform a mechanical final pass on staged files only. It may fix encoding, spacing, broken Markdown, and obvious grammar without changing claims, code, links, front matter values, section meaning, or the author's voice.
4. `backend-developer`: maintain or run `tools/notion_blog_converter/Convert-NotionBlog.ps1`, fix reproducible converter defects, and run its tests. It must not broaden into editorial rewriting.

Do not run multiple agents that write the same staging paths in parallel. Skip a role only when it has no applicable work, and state that in the final report. If a named custom agent is unavailable, use a bounded subagent with the same responsibility rather than silently dropping the check.

## Preserve source fidelity

- Every factual statement, experience, result, command, and code example in a new post must be supported by the selected Notion source.
- Do not force a `problem -> cause -> solution -> result -> lesson` narrative when those facts are absent. Keep ordinary learning notes as topic-oriented notes.
- Allowed mechanical changes are: removing Notion page IDs from display titles and filenames, adding evidence-backed front matter, normalizing heading levels, fixing encoding or Markdown syntax, and rewriting local image URLs after copying the referenced file.
- Do not paraphrase, shorten, expand, or "improve" source prose unless the user explicitly requests editorial rewriting.
- When splitting one source, maintain a source map showing which original headings went to each post. Do not duplicate or silently drop sections. Record intentionally excluded private, irrelevant, duplicate, or unsafe sections and the reason.
- Treat credentials, private URLs, tokens, keys, personal identifiers, and files whose names indicate passwords or secrets as non-publishable. Report only the path and risk category, never the value.

## Stage before adding

Run the converter in dry-run mode first for batch work. Use an explicit staging directory outside the blog repository. Supply `-DefaultYear` only when the user has established the year and the filename contains a Korean month/day date. Never invent a date.

Review the manifest and staged files before adding anything to the blog. A destination is eligible only when:

- the target category exists and its `index.md` convention is satisfied;
- the destination path does not exist;
- no existing post has equivalent content or title;
- the front matter title and date are evidence-backed;
- all local images exist and their target paths are unique;
- the file passed the checks in `references/validation.md`.

Copy only approved new files. Adding files to the local repository is allowed only when requested by the user. Committing, pushing, publishing, or changing remote state always requires a separate explicit request.

## Return

Report:

- new files and their source mappings;
- skipped files grouped by duplicate, unmapped, missing date, sensitive, or invalid;
- agent roles used and validations performed;
- unresolved category, date, thumbnail, link, or runtime decisions;
- whether any commit or push occurred.
