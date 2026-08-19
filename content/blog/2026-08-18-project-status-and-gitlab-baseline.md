---
title: "Project Status and GitLab Baseline"
date: 2026-08-18
description: "DevRail v1 remains active on the v1.12 release line, and GitLab adoption work is being normalized around a v0.1.0 migration baseline."
---

DevRail's public docs have been quiet while the v1 release line kept moving. This update brings the site back in line with the current state of the project: the `dev-toolchain` v1.12 line is active, the latest public v1.12 tag observed is `v1.12.13`, and GitLab adoption work is now being tracked around a practical v0.1.0 migration baseline.

## What changed on the site

- Added a [Project Status](/docs/project-status/) page for the current release line, public repository map, and GitLab migration roadmap.
- Linked the status page from the homepage and docs index so it is visible without digging through release posts.
- Rechecked stale GitHub links in the May plugin posts and kept them pointed at their current public sources.

The generated [Tool Versions](/docs/container/versions/) page is still owned by the scheduled release workflow. It remains the source of truth for exact container contents when the automation publishes a new version snapshot.

## GitLab v0.1.0 baseline

The GitLab work is about making existing repositories converge on the same contract new DevRail template projects already get: a declared `.devrail.yml`, a Makefile that preserves `make check`, review templates that ask for validation evidence, and CI that runs the DevRail check path where the project supports it.

The public roadmap is intentionally high-level. Private repository status and migration MRs stay in the owning GitLab projects, while devrail.dev documents the contract and the migration shape.
