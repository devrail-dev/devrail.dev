---
title: "New Project"
linkTitle: "New Project"
weight: 10
description: "Create a new DevRail-compliant project using devrail init or a template."
---

## Recommended: `devrail init`

The fastest way to start a new DevRail project is `devrail init`. Run it in an empty directory (or a freshly initialized git repo) and it generates all configuration files:

```bash
mkdir my-new-project && cd my-new-project
git init

# Interactive mode — prompts for languages and CI platform
curl -fsSL https://devrail.dev/init.sh | bash

# Or non-interactive — specify everything up front
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages python,bash --ci github --yes
```

This generates all DevRail files including the Makefile, `.devrail.yml`, pre-commit config, agent instruction files, CI workflows, and documentation. See the [CLI Reference](/docs/getting-started/cli-reference/) for all options.

After running `devrail init`:

```bash
# Install git hooks for local enforcement
make install-hooks

# Run all DevRail checks
make check

# Make your first commit
git add .
git commit -m "feat: initialize project with DevRail standards"
```

## Alternative: From a Template

You can also create a repository directly from one of the official templates. All DevRail configuration files are included and pre-configured.

### From GitHub Template

Navigate to the [DevRail GitHub template](https://github.com/devrail-dev/github-repo-template) and click **"Use this template"** to create a new repository in your organization or personal account.

Alternatively, use the GitHub CLI:

```bash
# Create a new repository from the DevRail GitHub template
gh repo create my-new-project --template devrail-dev/github-repo-template --public
cd my-new-project
```

### From GitLab Template

In GitLab, navigate to **New Project > Create from template > Custom** and select the DevRail GitLab template. Enter your project name and create the project.

Alternatively, clone the template manually:

```bash
# Clone the DevRail GitLab template
git clone https://gitlab.com/devrail-dev/gitlab-repo-template.git my-new-project
cd my-new-project

# Reset git history for a clean start
rm -rf .git
git init
git add .
git commit -m "feat: initialize project with DevRail standards"
```

### After Creating from Template

```bash
# Edit .devrail.yml to declare your project's languages
# Configure your languages (see below)

# Install git hooks
make install-hooks

# Run all DevRail checks
make check
```

## Configure Your Languages

Edit `.devrail.yml` to declare which languages your project uses. The Makefile reads this file to determine which tools to run.

```yaml
# .devrail.yml -- declare your project's languages
languages:
  - python
  - bash

fail_fast: false
log_format: json
```

Supported languages: `python`, `bash`, `terraform`, `ansible`, `ruby`, `go`, `javascript`, `rust`. List only the languages your project actually uses.

## What Is Included

Whether you use `devrail init` or a template, you get the following files:

| File | Purpose |
|---|---|
| `Makefile` | Universal execution interface with two-layer delegation |
| `.devrail.yml` | Language declaration and project settings |
| `.editorconfig` | Editor formatting rules (indent, line endings, whitespace) |
| `.gitignore` | Standard ignore patterns |
| `.pre-commit-config.yaml` | Pre-commit hook configuration |
| `DEVELOPMENT.md` | Canonical development standards |
| `CLAUDE.md` | Claude Code agent instructions |
| `AGENTS.md` | Generic agent instructions |
| `.cursorrules` | Cursor agent instructions |
| `.opencode/agents.yaml` | OpenCode agent instructions |
| `CHANGELOG.md` | Changelog (Keep a Changelog format) |
| `LICENSE` | MIT license |
| `README.md` | Project README template |
| CI configuration | GitHub Actions workflows or `.gitlab-ci.yml` |

## Next Steps

- [View Standards Reference](/docs/standards/) to understand which tools run for your declared languages
- [Learn About the Container](/docs/container/) to understand how the dev-toolchain image works
- [Customize Templates](/docs/templates/) for advanced configuration
