---
title: "CLI Reference"
linkTitle: "CLI Reference"
weight: 25
description: "Complete reference for the devrail init command."
---

## Installation

`devrail init` is a single shell script. No package manager is required — run it directly with `curl`:

```bash
curl -fsSL https://devrail.dev/init.sh | bash
```

Or download it for repeated use:

```bash
curl -fsSL https://devrail.dev/init.sh -o devrail-init.sh
chmod +x devrail-init.sh
./devrail-init.sh [options]
```

## Synopsis

```
devrail init [options]
```

When run without options, the script launches an interactive wizard that prompts for languages, CI platform, and which adoption layers to install.

## Options

| Option | Description |
|---|---|
| `--languages <list>` | Comma-separated list of languages (e.g., `python,bash,go`) |
| `--ci <platform>` | CI platform: `github`, `gitlab`, or `none` |
| `--all` | Install all 4 layers (agent files, pre-commit, Makefile, CI) |
| `--agents-only` | Install only Layer 1 (agent instruction files) |
| `--yes` | Non-interactive mode; skip existing files without prompting |
| `--force` | Overwrite existing files without prompting |
| `--dry-run` | Show what would be generated without writing any files |
| `--version` | Print the DevRail version and exit |
| `--help` | Print usage information and exit |

## Supported Languages

The `--languages` flag accepts any combination of the following:

| Language | Pre-commit Hooks | Makefile Targets |
|---|---|---|
| `python` | ruff (lint + format) | ruff check, ruff format, pytest |
| `bash` | shellcheck, shfmt | shellcheck, shfmt |
| `terraform` | terraform_fmt, terraform_validate, terraform_tflint, terragrunt_fmt | tflint, terraform fmt |
| `ansible` | ansible-lint | ansible-lint |
| `ruby` | rubocop | rubocop, brakeman, bundler-audit |
| `go` | golangci-lint | golangci-lint, gofumpt, govulncheck |
| `javascript` | eslint, prettier | eslint, prettier, tsc, npm audit |
| `rust` | cargo-fmt, cargo-clippy | cargo fmt, cargo clippy, cargo audit |

## Adoption Layers

`devrail init` uses a 4-layer progressive adoption model. In interactive mode, you choose which layers to install. In non-interactive mode, use `--all` for everything or `--agents-only` for just Layer 1.

### Layer 1: Agent Instruction Files

Files that tell AI coding agents (Claude Code, Cursor, OpenCode) how to work in your project.

| File | Purpose |
|---|---|
| `CLAUDE.md` | Claude Code agent instructions |
| `AGENTS.md` | Generic agent instructions |
| `.cursorrules` | Cursor agent instructions |
| `.opencode/agents.yaml` | OpenCode agent instructions |

### Layer 2: Pre-commit Hooks

Language-aware `.pre-commit-config.yaml` with hooks for your declared languages, plus conventional commits and gitleaks secret detection.

### Layer 3: Makefile + Container

| File | Purpose |
|---|---|
| `Makefile` | Two-layer delegation pattern (host → Docker → container) |
| `DEVELOPMENT.md` | Canonical development standards reference |
| `.editorconfig` | Editor formatting rules |
| `.gitignore` | Standard ignore patterns (appended if exists) |
| `.gitleaksignore` | Gitleaks allowlist |
| `.devrail.yml` | Language declaration and project settings |

### Layer 4: CI Pipelines

**GitHub Actions** generates 6 workflow files:

- `.github/workflows/lint.yml`
- `.github/workflows/format.yml`
- `.github/workflows/test.yml`
- `.github/workflows/security.yml`
- `.github/workflows/scan.yml`
- `.github/workflows/docs.yml`

Plus `.github/PULL_REQUEST_TEMPLATE.md` and `.github/CODEOWNERS`.

**GitLab CI** generates:

- `.gitlab-ci.yml` (single file with parallel check-stage jobs)
- `.gitlab/merge_request_templates/default.md`
- `.gitlab/CODEOWNERS`

## Conflict Resolution

When `devrail init` encounters an existing file:

| Mode | Behavior |
|---|---|
| Interactive (default) | Prompts: **[s]kip**, **[o]verwrite**, or **[b]ackup + overwrite** |
| `--yes` | Skips existing files (safe, preserves your files) |
| `--force` | Overwrites existing files without prompting |

### Makefile Merge Strategy

| Scenario | Behavior |
|---|---|
| No existing Makefile | DevRail Makefile written normally |
| Existing Makefile with DevRail markers | Updated in-place between markers |
| Existing non-DevRail Makefile | Backed up to `Makefile.pre-devrail`, DevRail Makefile written, include guidance printed |

### .gitignore Handling

DevRail patterns are appended below a `# --- DevRail ---` marker. If the marker already exists, the append is skipped (idempotent).

## `.devrail.yml` Configuration

The script reads `.devrail.yml` if it exists, or creates one based on the `--languages` flag or interactive prompts.

```yaml
# .devrail.yml
languages:
  - python
  - bash

fail_fast: false
log_format: json
```

## Examples

```bash
# Interactive mode — walks through all choices
curl -fsSL https://devrail.dev/init.sh | bash

# Greenfield Python project with GitHub Actions
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages python --ci github --yes

# Add agent files only to any project
curl -fsSL https://devrail.dev/init.sh | bash -s -- --agents-only --yes

# Preview what would be generated (dry run)
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages go,rust --ci gitlab --dry-run

# Multi-language project with GitLab CI
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages python,bash,terraform --ci gitlab --yes

# Force overwrite all existing files
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages javascript --ci github --force
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DEVRAIL_VERSION` | `v1` | Container image tag used in generated files |
