---
title: "Terragrunt Support"
date: 2026-03-05
description: "Terragrunt formatting ships as a companion to Terraform -- automatic detection, no configuration required."
---

Terragrunt is now included in the dev-toolchain container as a companion tool to Terraform. Projects that use `terragrunt.hcl` files get automatic format checking with zero configuration.

## How It Works

There is no new language entry. Terragrunt runs within the existing `terraform` language block. If your project already declares `terraform` in `.devrail.yml`, Terragrunt formatting is available immediately.

The Makefile detects `terragrunt.hcl` files at runtime:

- **`make format`** runs `terragrunt hclfmt --terragrunt-check` -- exits non-zero if files need formatting
- **`make fix`** runs `terragrunt hclfmt` -- formats files in place

If no `terragrunt.hcl` files exist, the check is silently skipped. Projects that use Terraform without Terragrunt are unaffected.

```console
$ make format
✓ terraform fmt -check -recursive
✓ terragrunt hclfmt --terragrunt-check
```

## Why a Companion Tool

Terragrunt is a thin wrapper around Terraform for DRY infrastructure code across multiple modules. It uses its own HCL configuration files (`terragrunt.hcl`) that `terraform fmt` does not process. Adding `terragrunt hclfmt` as a companion means teams get consistent formatting for both file types from a single `make check` invocation.

The alternative -- a separate `terragrunt` language entry in `.devrail.yml` -- would require projects to declare two languages for what is fundamentally one infrastructure stack. The companion approach is simpler: declare `terraform`, and Terragrunt support follows automatically.

## Pre-Commit Hooks

The template repositories include a commented hook for local Terragrunt formatting:

```yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.96.3
  hooks:
    - id: terraform_fmt
    - id: terraform_tflint
    # Uncomment if using Terragrunt:
    # - id: terragrunt_fmt
```

## Get Started

- [Terraform standards reference](/docs/standards/terraform/) -- includes Terragrunt configuration and Makefile targets
- [Container tool versions](/docs/container/versions/) -- exact versions shipped in the current image
