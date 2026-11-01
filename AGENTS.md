# AGENTS.md

Bootstrap for coding agents working on **homelab**.

Knowledge is split by scope into two Gitea wikis. Read the relevant pages before
planning or changing anything; the repository carries only `README.md`
(operator-facing) and this file.

- **Instance-wide** — `gitea.x.home.arpa/kb/gitea/wiki`: who you act as on Gitea,
  the task lifecycle and review rules, dependencies. True in every repo here.
- **This project** — `gitea.x.home.arpa/devops/homelab/wiki`: layout, Quadlet
  conventions, host facts, this repo's own workflow.

## Read first — project

| Page | Covers |
| --- | --- |
| `Home` | Wiki entrypoint listing every page and when to read it |

## Read first — instance-wide

| Page | Covers |
| --- | --- |
| `Home` | Wiki entrypoint listing every page and when to read it |

Fetch one page:

```
gitea_wiki_read(method="get", owner="devops", repo="homelab", pageName="Home")
gitea_wiki_read(method="get", owner="kb", repo="gitea", pageName="Home")
```

Or clone the lots:

```
git clone git@gitea.x.home.arpa:devops/homelab.wiki.git /tmp/homelab-wiki
git clone git@gitea.x.home.arpa:kb/gitea.wiki.git /tmp/gitea-wiki
```
