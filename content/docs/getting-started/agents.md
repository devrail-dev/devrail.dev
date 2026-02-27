---
title: "Working with AI Agents"
linkTitle: "AI Agents"
weight: 30
description: "How to get AI coding agents to follow DevRail standards in your projects."
---

DevRail is designed so that AI coding agents (Claude Code, Cursor, OpenCode, Copilot, etc.) follow the same standards as human developers and CI pipelines. This page explains how to set it up and what to expect.

## The Short Version

If your project already has DevRail files (Makefile, `.devrail.yml`, DEVELOPMENT.md), just tell your agent:

> This project follows DevRail development standards. Read DEVELOPMENT.md before making changes. Run `make check` before marking any task complete.

That's it. The agent instruction files (CLAUDE.md, AGENTS.md, etc.) already contain this directive, so agents that read them will follow DevRail automatically.

## How It Works

DevRail communicates standards to agents through a **hybrid shim** pattern:

```
CLAUDE.md / AGENTS.md / .cursorrules / .opencode/agents.yaml
    │
    ├── Points to DEVELOPMENT.md (full standards reference)
    │
    └── Inlines 6 critical rules (minimum viable compliance)
```

**Agents that follow cross-file references** (like Claude Code) will read DEVELOPMENT.md and get the complete picture -- language-specific tooling, Makefile contract, shell conventions, everything.

**Agents that ignore cross-file references** still get the six critical rules inlined directly in their instruction file. This ensures minimum compliance regardless of agent capability.

## Setting Up a Project for Agent Use

### Option A: Start from a Template

If you create a project from a [DevRail template](/docs/getting-started/new-project/), all agent instruction files are already included. No additional setup needed.

### Option B: Retrofit an Existing Project

If you have an existing project, follow the [Retrofit Guide](/docs/getting-started/retrofit/) to add DevRail files. The agent instruction files are listed as optional, but **they are required if you want agents to follow DevRail standards**.

Copy all four shim files:

```bash
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/CLAUDE.md
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/AGENTS.md
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.cursorrules
mkdir -p .opencode
curl -o .opencode/agents.yaml https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.opencode/agents.yaml
```

### Option C: Point an Agent at DevRail Without Files

If you do not want to commit DevRail files yet, you can paste instructions directly into your agent's context. Here is a prompt you can use:

> You are working on a project that follows DevRail development standards (https://devrail.dev).
>
> **Key rules:**
> 1. Run `make check` before completing any task. This runs all linters, formatters, security scanners, and tests inside a Docker container.
> 2. Use conventional commits: `type(scope): description`.
> 3. Never install tools on the host. All tools run inside the `ghcr.io/devrail-dev/dev-toolchain:v1` container via `make` targets.
> 4. Respect `.editorconfig` formatting rules.
>
> **Available `make` targets:**
> - `make lint` -- run linters
> - `make format` -- check formatting
> - `make test` -- run tests
> - `make security` -- run security scanners
> - `make check` -- run everything
>
> Languages are declared in `.devrail.yml`. The Makefile reads this file to determine which tools to run. See https://devrail.dev/docs/standards/ for per-language tool details.

## Example Prompts

### Retrofitting an existing project

> I want to adopt DevRail standards in this project. Read https://devrail.dev/docs/getting-started/retrofit/ and follow the steps. This is a Ruby on Rails project, so set `languages: [ruby]` in `.devrail.yml`. After adding the DevRail files, run `make check` and fix any findings.

### Ongoing development

> Before you finish, run `make check` and fix any failures. Use conventional commit messages.

### Explaining what DevRail does

> Read https://devrail.dev/docs/standards/ and tell me which tools will run for my project based on the languages in `.devrail.yml`.

## What Agents See

When an agent reads the project's CLAUDE.md (or equivalent), it learns:

1. **DEVELOPMENT.md is the canonical reference.** It contains the full Makefile contract, per-language tooling, shell conventions, and logging standards.
2. **Six critical rules must always be followed.** These are inlined so the agent cannot miss them.
3. **`make check` is the single gate.** No task is complete until it passes.
4. **Everything runs in Docker.** The agent should never try to install tools on the host.

## Verifying Agent Compliance

After an agent completes a task, check that it followed DevRail:

| Check | What to look for |
|---|---|
| Commit messages | Follow `type(scope): description` format |
| `make check` | Agent ran it and it passes |
| No host tool installs | Agent did not run `pip install`, `gem install`, `npm install -g`, etc. for linting/formatting tools |
| `.editorconfig` respected | Indentation, line endings, and trailing whitespace match project rules |

If an agent consistently ignores standards, add the critical rules directly to its system prompt or context window rather than relying on file references.

## Which File Does My Agent Read?

| Agent | Instruction File |
|---|---|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` |
| OpenCode | `.opencode/agents.yaml` |
| Other / generic | `AGENTS.md` |

All four files contain identical content in different formats. You only need the file(s) for the agent(s) you use, but shipping all four costs nothing and covers future tool changes.
