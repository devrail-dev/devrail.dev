---
title: "make fix and Mirror Automation"
date: 2026-03-03
description: "Auto-remediation lands for all seven language ecosystems, and CI-based mirroring eliminates manual git push between GitLab and GitHub."
---

Two features shipped today: `make fix` for auto-remediation and CI-based mirror automation between GitLab and GitHub.

## make fix

`make check` tells you what's wrong. `make fix` fixes what it can.

```console
$ make fix
✓ python   (ruff format, ruff check --fix)
✓ bash     (shfmt -w)
✓ go       (gofumpt -w)
✓ js/ts    (prettier --write, eslint --fix)
```

The target runs formatters and auto-fixable linter rules in-place for all seven supported language ecosystems. It follows the same contract as every other Makefile target: runs inside the dev-toolchain container, reads `.devrail.yml` for language detection, and produces identical results everywhere.

The intended workflow: run `make fix` to auto-remediate, then run `make check` to verify. Anything `make check` still flags after `make fix` requires manual attention -- issues that tools cannot safely resolve on their own.

`make fix` is available in all [DevRail templates](https://github.com/devrail-dev) and existing projects after pulling the latest Makefile.

## Mirror Automation

DevRail maintains repositories on both GitHub and GitLab. Until now, mirroring between the two required a manual `git push <remote> main` after every merge. That step is now automated.

Each repository has a CI job that pushes to its mirror after a successful merge to `main`:

- **GitLab CI** pushes to GitHub using a deploy key stored as a CI variable
- **GitHub Actions** pushes to GitLab using a deploy key stored as a repository secret

The mirror jobs skip gracefully if the secret is not configured, so the CI files work in any fork or clone without modification. If you are hosting DevRail templates on your own infrastructure, see the CI files for the pattern -- it is straightforward to adapt.
