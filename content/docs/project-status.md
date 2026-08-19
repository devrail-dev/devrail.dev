---
title: "Project Status"
linkTitle: "Project Status"
weight: 5
description: "Current DevRail release status, repository activity, and GitLab migration roadmap."
---

DevRail v1 is stable for current adopters. The public site, templates, standards, and container documentation are maintained from the GitHub organization, while active GitLab deployments are being normalized around the same baseline files and check contract.

## Current Release Line

- Public container release line: `ghcr.io/devrail-dev/dev-toolchain:v1`
- Latest public v1.12 tag observed: `v1.12.13`
- Current generated tool-version page: [Tool Versions](/docs/container/versions/)
- Compatibility posture: v1 remains backward-compatible; breaking language/plugin changes are reserved for v2.

## Public Repository Status

The public repositories remain the canonical open-source surfaces:

| Repository | Status |
|---|---|
| [dev-toolchain](https://github.com/devrail-dev/dev-toolchain) | Active v1 container release line |
| [devrail-standards](https://github.com/devrail-dev/devrail-standards) | Canonical standards and schema source |
| [devrail.dev](https://github.com/devrail-dev/devrail.dev) | Public documentation site |
| [github-repo-template](https://github.com/devrail-dev/github-repo-template) | Public GitHub bootstrap template |
| [gitlab-repo-template](https://gitlab.com/devrail-dev/gitlab-repo-template) | Public GitLab bootstrap template |

## GitLab v0.1.0 Migration Baseline

The GitLab migration work is focused on making existing repositories match the same operational contract as new template-based projects. The v0.1.0 baseline means a repository has, at minimum:

- `DEVRAIL.md` or equivalent project-facing adoption notes
- `.devrail.yml` with declared languages and project settings
- Makefile targets that preserve the `make check` contract
- Merge request templates that ask for validation evidence
- GitLab CI that runs the DevRail check path where the project can support it

### Roadmap

1. Complete baseline-ready repositories that already have the docs, Makefile, `.devrail.yml`, and merge request template pieces.
2. Fill Makefile and CI gaps in repositories that already have partial DevRail adoption.
3. Classify repositories with no clear DevRail signal as adopt, defer, or exempt.
4. Keep public docs aligned with the internal migration pattern without publishing private repository names or infrastructure details.

This page is the public status note for that work. Detailed per-repository migration status stays with the owning GitLab projects.
