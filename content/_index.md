---
title: "DevRail"
linkTitle: "DevRail"
---

{{% blocks/cover title="DevRail" image_anchor="top" height="full" color="primary" %}}
One Makefile. One Container. Every Language.

Opinionated development standards for teams that ship with AI agents.

{{% blocks/link-down color="info" %}}
{{% /blocks/cover %}}

{{% blocks/section color="white" %}}

## Give This to Your Agent

Paste this into your agent's context, system prompt, or project instructions. That's all it takes.

```text
This project follows DevRail development standards (https://devrail.dev).

Key rules:
1. Run `make check` before completing any task. This runs all linters,
   formatters, security scanners, and tests inside a Docker container.
2. Use conventional commits: type(scope): description.
3. Never install tools on the host. All tools run inside the
   ghcr.io/devrail-dev/dev-toolchain:v1 container via `make` targets.
4. Respect `.editorconfig` formatting rules.

Available make targets: lint, format, test, security, scan, check (all).
Languages are declared in `.devrail.yml`. See https://devrail.dev/docs/standards/
for per-language tool details.
```

Want it baked into your repo instead? [Add agent instruction files](/docs/getting-started/agents/) so every agent reads the rules automatically.

{{% /blocks/section %}}

{{% blocks/section color="light" %}}

## Why DevRail?

DevRail provides a universal development contract that works the same way for every developer, every CI pipeline, and every AI agent. No more environment drift. No more "works on my machine."

{{% /blocks/section %}}

{{% blocks/section color="white" type="row" %}}

{{% blocks/feature icon="fa-terminal" title="One Command" %}}
Run `make check` and get consistent results everywhere -- your laptop, CI, or an AI agent. The Makefile delegates to a Docker container that has every tool pre-installed.

[Get Started](/docs/getting-started/)
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-cube" title="One Container" %}}
The `dev-toolchain` container includes linters, formatters, security scanners, and test runners for Python, Bash, Terraform, Ansible, and Ruby. Pin a version and forget about tool management.

[Learn About the Container](/docs/container/)
{{% /blocks/feature %}}

{{% blocks/feature icon="fa-file-code" title="Every Language" %}}
Per-language standards define which tools run, how they are configured, and what Makefile targets invoke them. Consistent patterns across all supported ecosystems.

[View Standards](/docs/standards/)
{{% /blocks/feature %}}

{{% /blocks/section %}}

{{% blocks/section color="white" %}}

## How It Works

1. **Start from a template.** Create a new repository from the GitHub or GitLab template. All DevRail files are pre-configured.

2. **Declare your languages.** Edit `.devrail.yml` to list the languages your project uses. The Makefile reads this file to determine which tools to run.

3. **Run `make check`.** Every linter, formatter, security scanner, and test runner executes inside the dev-toolchain container. Results are identical on every machine.

4. **Ship with confidence.** CI pipelines call the same `make` targets. Pre-commit hooks catch issues before push. AI agents follow the same standards.

{{% /blocks/section %}}

{{% blocks/section color="light" %}}

## Ready to Start?

- [Agent Setup Guide](/docs/getting-started/agents/) -- Get your AI agent following DevRail in one paste
- [Quick Start Guide](/docs/getting-started/) -- Set up a new or existing project
- [Standards Reference](/docs/standards/) -- Per-language tooling conventions
- [Container Documentation](/docs/container/) -- How the dev-toolchain works
- [Contributing](/docs/contributing/) -- Help improve DevRail

{{% /blocks/section %}}
