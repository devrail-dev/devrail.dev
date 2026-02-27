---
title: "Standards"
linkTitle: "Standards"
weight: 20
description: "Per-language tooling standards for Python, Bash, Terraform, Ansible, Ruby, Go, and universal security tools."
---

DevRail defines opinionated tooling standards for each supported language ecosystem. Every tool is pre-installed in the dev-toolchain container and invoked through consistent Makefile targets.

## Language Support Matrix

The following table shows the default tool for each concern per language. These tools are pre-installed in the `dev-toolchain` container.

| Concern | Python | Bash | Terraform | Ansible | Ruby | Go |
|---|---|---|---|---|---|---|
| Linter | ruff | shellcheck | tflint | ansible-lint | rubocop, reek | golangci-lint |
| Formatter | ruff format | shfmt | terraform fmt | -- | rubocop | gofumpt |
| Security | bandit, semgrep | -- | tfsec, checkov | -- | brakeman, bundler-audit | govulncheck |
| Tests | pytest | bats | terratest | molecule | rspec | go test |
| Type Check | mypy | -- | -- | -- | sorbet | -- |
| Docs | -- | -- | terraform-docs | -- | -- | -- |
| Universal | trivy, gitleaks | trivy, gitleaks | trivy, gitleaks | trivy, gitleaks | trivy, gitleaks | trivy, gitleaks |

A `--` entry means the concern does not apply to that language. Universal tools run for all projects regardless of declared languages.

## Makefile Target Mapping

Each Makefile target runs the relevant tools for all languages declared in `.devrail.yml`:

| Target | What It Runs |
|---|---|
| `make lint` | ruff check, shellcheck, tflint, ansible-lint, mypy, rubocop, reek, golangci-lint |
| `make format` | ruff format, shfmt, terraform fmt, rubocop, gofumpt |
| `make test` | pytest, bats, terratest, molecule, rspec, go test |
| `make security` | bandit, semgrep, tfsec, checkov, brakeman, bundler-audit, govulncheck |
| `make scan` | trivy, gitleaks (universal -- all projects) |
| `make docs` | terraform-docs |
| `make check` | All of the above in sequence |

## Per-Language Pages

- [Python Standards](/docs/standards/python/) -- ruff, bandit, semgrep, pytest, mypy
- [Bash Standards](/docs/standards/bash/) -- shellcheck, shfmt, bats
- [Terraform Standards](/docs/standards/terraform/) -- tflint, terraform fmt, tfsec, checkov, terratest, terraform-docs
- [Ansible Standards](/docs/standards/ansible/) -- ansible-lint, molecule
- [Ruby Standards](/docs/standards/ruby/) -- rubocop, brakeman, bundler-audit, rspec, reek, sorbet
- [Go Standards](/docs/standards/go/) -- golangci-lint, gofumpt, govulncheck, go test
- [Universal Security](/docs/standards/universal/) -- trivy, gitleaks

## Consistent Page Structure

Each per-language page follows a consistent structure:

1. **Tools** -- table of tools with category, name, and purpose
2. **Configuration** -- configuration examples with inline comments
3. **Makefile Targets** -- which targets invoke which tools
4. **Pre-Commit Hooks** -- which hooks run locally vs. CI-only
5. **Notes** -- important conventions and gotchas
