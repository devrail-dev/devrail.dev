---
title: "Retrofit Existing Project"
linkTitle: "Retrofit"
weight: 20
description: "Add DevRail standards to an existing repository using devrail init."
---

If you already have a repository and want to adopt DevRail standards, `devrail init` handles everything — generating configuration files, backing up conflicting files, and merging `.gitignore` patterns.

## Recommended: `devrail init`

Run `devrail init` in your existing project directory:

```bash
cd my-existing-project

# Interactive mode — choose languages, CI platform, and adoption layers
curl -fsSL https://devrail.dev/init.sh | bash

# Or non-interactive — specify everything up front
curl -fsSL https://devrail.dev/init.sh | bash -s -- --all --languages python,bash --ci github --yes
```

### What Happens to Existing Files

`devrail init` handles conflicts safely:

| Scenario | Behavior |
|---|---|
| File does not exist | Created normally |
| File already exists (interactive) | Prompts: **[s]kip**, **[o]verwrite**, or **[b]ackup + overwrite** |
| File already exists (`--yes`) | Skipped (preserves your files) |
| File already exists (`--force`) | Overwritten without prompting |
| Existing Makefile (non-DevRail) | Backed up to `Makefile.pre-devrail`, DevRail Makefile written with include guidance |
| Existing Makefile (DevRail markers) | Updated in-place between markers |
| Existing `.gitignore` | DevRail patterns appended below a `# --- DevRail ---` marker (idempotent) |

### Progressive Adoption

You do not have to adopt everything at once. `devrail init` supports 4 layers that you can install incrementally:

1. **Agent files only** (`--agents-only`) — CLAUDE.md, AGENTS.md, .cursorrules, .opencode/agents.yaml
2. **Pre-commit hooks** — .pre-commit-config.yaml with language-aware hooks
3. **Makefile + container** — Makefile, DEVELOPMENT.md, .editorconfig, .gitignore, .devrail.yml
4. **CI pipelines** — GitHub Actions workflows or GitLab CI configuration

In interactive mode, you are prompted for each layer. In non-interactive mode, use `--all` for everything or `--agents-only` for just agent files.

### After Running `devrail init`

```bash
# Configure your languages in .devrail.yml (if not already set via --languages)
# Edit .devrail.yml to list only the languages your project uses

# Install git hooks
make install-hooks

# Run all DevRail checks against your existing code
make check
```

Expect some findings on the first run — your existing code may not match DevRail formatting or linting standards. This is normal.

### Fixing Findings

Use `make fix` to auto-fix formatting issues in-place:

```bash
# Auto-fix formatting (runs inside the container)
make fix
```

For linting issues that cannot be auto-fixed, address them manually following the guidance in the [Standards Reference](/docs/standards/).

### Commit DevRail Files

```bash
# Stage all DevRail configuration files
git add Makefile .devrail.yml .editorconfig .pre-commit-config.yaml DEVELOPMENT.md

# Optionally stage agent instruction files
git add CLAUDE.md AGENTS.md .cursorrules .opencode/agents.yaml

# Commit using conventional commit format
git commit -m "chore: add DevRail development standards"
```

## Alternative: Manual Setup

If you prefer to copy files manually instead of using `devrail init`, download them from the template repository:

### Required Files

```bash
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/Makefile
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.devrail.yml
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.editorconfig
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.pre-commit-config.yaml
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/DEVELOPMENT.md
```

| File | Purpose | Can You Skip It? |
|---|---|---|
| `Makefile` | Universal execution interface | No -- required |
| `.devrail.yml` | Language declaration | No -- required |
| `.editorconfig` | Editor formatting rules | No -- required |
| `.pre-commit-config.yaml` | Pre-commit hook config | Recommended |
| `DEVELOPMENT.md` | Canonical standards doc | Recommended |

### Optional Agent Files

```bash
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/CLAUDE.md
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/AGENTS.md
curl -O https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.cursorrules
mkdir -p .opencode
curl -o .opencode/agents.yaml https://raw.githubusercontent.com/devrail-dev/github-repo-template/main/.opencode/agents.yaml
```

## Handling Conflicts with Existing Configuration

### Existing Makefile

If your project already has a Makefile, you have two options:

1. **Merge targets.** Add DevRail's public targets (`lint`, `format`, `test`, `security`, `scan`, `docs`, `changelog`, `check`, `install-hooks`) to your existing Makefile. Keep your existing targets alongside them.

2. **Replace.** If your existing Makefile only has basic targets, replace it entirely with the DevRail Makefile.

In either case, ensure the DevRail `DEVRAIL_IMAGE` variable and `DOCKER_RUN` delegation pattern are present.

### Existing `.editorconfig`

If you already have an `.editorconfig`, compare it with the DevRail default. DevRail's `.editorconfig` enforces:

- UTF-8 charset
- LF line endings
- Final newline inserted
- Trailing whitespace trimmed
- 2-space indentation (except Makefile: tabs, Python: 4 spaces, Shell: 2 spaces)

Merge any project-specific overrides you need, but do not weaken the baseline rules.

### Existing Linter Configurations

DevRail does not require you to delete existing linter configurations (`ruff.toml`, `.shellcheckrc`, `.tflint.hcl`, etc.). The dev-toolchain container tools will use your project-level configuration files if they exist.

## Next Steps

- Run `make check` regularly as you work on existing code
- Review the [Standards Reference](/docs/standards/) to understand what each tool checks
- Set up [CI pipelines](/docs/contributing/pull-requests/) to enforce standards on every pull request
