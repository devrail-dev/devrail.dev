---
title: "Introducing DevRail"
date: 2026-03-02
description: "One Makefile, one container, every language -- opinionated development standards for teams that ship with AI agents."
---

## The Problem

Every team eventually builds its own tooling stack. Linters, formatters, security scanners, test runners -- installed differently on every developer's machine, pinned to different versions in CI, and completely invisible to the AI agent that just rewrote half your codebase.

The result is predictable. Code that passes locally fails in CI. An agent commits unformatted code because it doesn't know your project uses `shfmt`. A new hire spends a day installing tools that should have been one command. Environment drift compounds over time, and the response is always the same: more documentation that nobody reads, more onboarding steps that go stale, more "works on my machine."

The root cause is not carelessness. It is the absence of a universal contract -- a single interface that produces identical results regardless of who (or what) runs it.

## What DevRail Does

DevRail provides that contract. It consists of three components:

1. **One Makefile.** Public targets (`make lint`, `make format`, `make test`, `make security`, `make scan`, `make check`) delegate to a Docker container. No tools run on the host.
2. **One container.** The [`dev-toolchain`](https://github.com/devrail-dev/dev-toolchain) image packages every linter, formatter, security scanner, and test runner for all supported languages. Pin a version tag and forget about tool management.
3. **One config file.** `.devrail.yml` declares which languages your project uses. The Makefile reads it and runs only the relevant tools.

The outcome: `make check` produces the same results on your laptop, in CI, and inside an AI agent's sandbox. If it passes, the code meets the standard. If it fails, the output tells you exactly what to fix.

## How It Works

1. **Start from a template.** Create a new repository from the [GitHub](https://github.com/devrail-dev/github-repo-template) or [GitLab](https://github.com/devrail-dev/gitlab-repo-template) template. All DevRail files are pre-configured.

2. **Declare your languages.** Edit `.devrail.yml` to list the languages your project uses:

    ```yaml
    languages:
      - python
      - bash
    ```

3. **Run `make check`.** Every tool executes inside the container. Results are identical on every machine.

    ```console
    $ make check
    ✓ lint     (ruff, shellcheck)
    ✓ format   (ruff format, shfmt)
    ✓ test     (pytest, bats)
    ✓ security (bandit, semgrep)
    ✓ scan     (trivy, gitleaks)
    ```

4. **Ship with confidence.** CI pipelines call the same `make` targets. Pre-commit hooks catch issues before push. AI agents follow the same rules.

Already have a project? The [retrofit guide](/docs/getting-started/retrofit/) walks you through adding DevRail files to an existing repository without disrupting your code.

## What's in the Container

The `dev-toolchain` container includes tools for seven language ecosystems. Each language has opinionated defaults documented in the [standards reference](/docs/standards/).

| Concern | Python | Bash | Terraform | Ansible | Ruby | Go | JS/TS |
|---|---|---|---|---|---|---|---|
| Linter | ruff | shellcheck | tflint | ansible-lint | rubocop | golangci-lint | eslint |
| Formatter | ruff | shfmt | terraform fmt | -- | rubocop | gofumpt | prettier |
| Security | bandit | -- | tfsec | -- | brakeman | govulncheck | npm audit |
| Tests | pytest | bats | terratest | molecule | rspec | go test | vitest |

Universal tools -- trivy, gitleaks, and git-cliff -- run for every project regardless of language.

## Agent-Ready by Default

DevRail was built with AI coding agents in mind. The template repositories ship with instruction files for Claude Code (`CLAUDE.md`), Cursor (`.cursorrules`), OpenCode (`.opencode/agents.yaml`), and a generic `AGENTS.md`. Each file inlines six critical rules so agents follow the standard even if they don't read cross-file references.

The shortest path to agent compliance:

> This project follows DevRail development standards. Read DEVELOPMENT.md before making changes. Run `make check` before marking any task complete.

Agents that follow file references get the full picture. Agents that don't still get the minimum viable rules. Either way, `make check` is the gate.

See the [agent setup guide](/docs/getting-started/agents/) for detailed configuration, example prompts, and verification steps.

## Current Status

DevRail is in **beta**. The core contract -- Makefile, container, `.devrail.yml` -- is stable and used in production projects. Language support for all seven ecosystems ships in the `v1` container image. Standards, tool versions, and defaults may still change based on real-world usage.

What works today: new projects from templates, retrofitting existing repos, CI integration, agent instruction files. What's still evolving: the `make fix` auto-remediation workflow, additional language ecosystems, and edge cases we haven't hit yet.

If you run into problems or have opinions about how things should work, [open an issue](https://github.com/devrail-dev/devrail.dev/issues). Bug reports, feature requests, and "this default is wrong" complaints are all welcome.

## Get Started

- [Quick start guide](/docs/getting-started/) -- set up a new project in minutes
- [Retrofit guide](/docs/getting-started/retrofit/) -- add DevRail to an existing repository
- [Standards reference](/docs/standards/) -- per-language tooling and configuration
- [Container documentation](/docs/container/) -- how the dev-toolchain image works
- [Contributing](/docs/contributing/) -- help improve DevRail
