# Blog category map

Use the repository's current `_pages` tree as the source of truth. This map records the known routing rules for `DongHyeonHDH.github.io`; if the tree changes, inspect it again instead of creating a category from this file alone.

## Known destinations

| Subject | Existing destination |
| --- | --- |
| Database concepts, SQL, transactions, JOIN, indexes, locks | `_pages/cs/데이터베이스/` |
| Operating systems, processes, threads, deadlocks | `_pages/cs/os/` |
| Networks, HTTP, TCP/UDP, DNS | `_pages/cs/네트워크/` and its existing subdirectories |
| General web concepts, HTML, CSS, JavaScript | `_pages/cs/웹/` |
| Java language, OOP, exceptions, collections, lambdas, streams | `_pages/언어/자바/` |
| Kafka | `_pages/백엔드/kafka 공부/` |
| Docker, AWS, CI/CD, GitHub Actions, deployment, Prometheus, Grafana | `_pages/백엔드/배포/` |
| Other backend topics with no narrower existing category | `_pages/백엔드/` |
| Material tied to a named project | the matching existing directory under `_pages/프로젝트/` |
| Mixed daily records that cannot be split honestly | the matching existing directory under `_pages/Today I Learned/` |

## Routing rules

1. Prefer the narrowest existing category supported by the source content.
2. Use project directories only when the source names or clearly identifies that project. Do not infer that a generic integration project belongs to an existing named project.
3. Split a source only when its own headings define distinct, self-contained topics. Preserve the text and code under those headings.
4. Keep context required to understand a split section with that section. Record shared or excluded material in the source map.
5. If two categories are equally plausible, stage the file as unresolved and request the author's choice. Do not create a new category automatically.
6. Each new directory requires an `index.md` that follows the repository convention. Create a new directory only when the user explicitly approves it.
