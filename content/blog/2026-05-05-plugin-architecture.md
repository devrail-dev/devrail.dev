---
title: "Plugin Architecture: v1.10 Ships"
date: 2026-05-05
description: "DevRail v1.10 introduces a plugin architecture so anyone can ship a new language or tool integration without forking dev-toolchain. Loader, lockfile, extended-image build, and execution dispatch all in one container, one make check."
---

Up to now, every new language in DevRail has meant a PR against `dev-toolchain` -- a Dockerfile change, an install script, Makefile blocks for `_lint` / `_format` / `_test` / `_security`, a standards doc, and a release. That worked through the ten core ecosystems we shipped from MVP through v1.9 (Python, Bash, Terraform, Ansible, Ruby, Go, JavaScript/TypeScript, Rust, Swift, and Kotlin), but it doesn't scale to the long tail of languages and tools real teams use.

**v1.10.6 ships a plugin architecture.** Anyone can now publish a `devrail-plugin-<name>` git repo, and any DevRail-managed project can declare it in `.devrail.yml` and pick up new tools at the next `make check`. No fork, no PR, no waiting on a release. The "one container, one make check" guarantee holds throughout.

## What changed

A plugin is a git repository with a `plugin.devrail.yml` manifest at the root. The manifest declares the plugin's container fragment (apt packages, COPY-from-builder paths, install script, env vars) and its targets (lint, format, test, security commands).

When a consumer's `.devrail.yml` declares the plugin:

```yaml
languages:
  - python
  - elixir          # provided by a plugin

plugins:
  - source: github.com/community/devrail-plugin-elixir
    rev: v1.0.0
    languages: [elixir]
```

...the dev-toolchain container does the rest at `make check` time:

1. **Loader (Story 13.2)** validates `plugin.devrail.yml` against schema_version 1, enforcing `devrail_min_version` and per-target shape.
2. **Resolver + lockfile (Story 13.3)** resolves `rev:` to an immutable SHA, fetches the plugin tree to a content-addressed cache, and records the resolved metadata in `.devrail.lock`. Branch refs are rejected. Tag-rebases are detected via content_hash mismatch.
3. **Extended-image build (Story 13.4)** generates a project-local `Dockerfile.devrail` that layers each plugin's apt / COPY / ENV / install_script onto `ghcr.io/devrail-dev/dev-toolchain:v1`, then builds `devrail-local:<hash-of-dockerfile>` via BuildKit. Cache hits are free; first builds take 30 s -- 2 min depending on the plugin.
4. **Execution loop (Story 13.5)** dispatches each plugin's matching target inside the existing `_lint` / `_format` / `_fix` / `_test` / `_security` recipes, with gate evaluation, `{paths}` interpolation, per-language overrides, and JSON aggregation into the same envelope as core results. Consumers can't tell from the JSON output which results came from core and which from a plugin.

`DEVRAIL_FAIL_FAST=1` short-circuits on plugin failures the same as core. Workspaces without `plugins:` in `.devrail.yml` see byte-identical behavior to v1.9.x -- the loader writes an empty cache, the dispatcher exits immediately, no extra events.

## Why now

Three forces aligned:

- **The core surface stabilized.** With ten languages shipped (the most recent two -- Swift and Kotlin -- landed in March) the patterns for "what goes in `_lint`, `_test`, etc." are clear enough to expose as a contract.
- **The container model is cheaper than people think.** BuildKit content-addresses every layer; an unchanged plugin set is an instant cache hit. We benchmarked Elixir + Rust + Swift in the same project and the second `make check` was within 200 ms of the first -- the entire build pipeline boils down to a `docker image inspect`.
- **Real teams have real tools we shouldn't ship.** Mojo. Zig. Roc. Crystal. Internal DSLs. Every one of these comes up in conversation; none of them belongs in `dev-toolchain` core. A plugin gives them a first-class home with the same UX as the languages we do ship.

The architecture is documented in detail in the [design doc on GitHub](https://github.com/devrail-dev/dev-toolchain/blob/main/docs/plugin-architecture.md). The TL;DR: we surveyed Terraform providers, GitHub Actions, pre-commit, and pip extras, then picked declarative YAML manifests + git-repo distribution + immutable refs + a single execution mode (extended container image). The single-mode choice is deliberate -- DevRail's value proposition is one container, one make check, and we kept it.

## Authoring a plugin

If you have a tool you want every DevRail-managed project to use, here's the quickest path:

1. Create a `devrail-plugin-<name>` git repo with a `plugin.devrail.yml`:

   ```yaml
   schema_version: 1
   name: elixir
   version: 1.0.0
   devrail_min_version: 1.10.0

   container:
     base_image: elixir:1.17-slim
     install_script: install.sh
     copy_from_builder:
       - /usr/local/bin/elixir
       - /usr/local/bin/mix
       - /usr/local/lib/elixir
     env:
       MIX_ENV: prod

   targets:
     lint:
       cmd: "mix credo --strict {paths}"
       paths_var: ELIXIR_PATHS
       paths_default: "lib test"
     test:
       cmd: "mix test"

   gates:
     lint: ["mix.exs"]
     test: ["mix.exs", "test/"]
   ```

2. Test against a local consumer workspace via a `file://` URL:

   ```yaml
   plugins:
     - source: file:///home/you/devrail-plugin-elixir
       rev: v1.0.0
       languages: [elixir]
   ```

   Then `make plugins-update && make check` in the consumer.

3. Tag an annotated semver tag (`git tag -a v1.0.0`) and publish.

Full field-by-field guidance, container integration patterns, override surface, and a publish checklist are in the [Contributing a Plugin guide](/docs/contributing/adding-a-plugin/). The canonical authoring doc with copy-pasteable templates is the [`standards/contributing.md` § Contributing a Plugin section](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#contributing-a-plugin).

## Consumer-side declaration

If you're a consumer wanting to pull in someone else's plugin, just declare it in your `.devrail.yml`:

```yaml
languages:
  - python
  - elixir

plugins:
  - source: github.com/community/devrail-plugin-elixir
    rev: v1.0.0
    languages: [elixir]
```

Run `make plugins-update` once to populate `.devrail.lock`, commit both files, and you're done. Subsequent `make check` invocations verify the lockfile, resolve the cached plugin, build the extended image (or hit the cache), and run plugin tools alongside your core-language tools.

Per-language overrides work for plugin languages exactly like they do for core:

```yaml
elixir:
  linter: dialyxir          # replaces the plugin's default `mix credo --strict`
  test: "mix test --cover"  # replaces the plugin's default `mix test`
```

Override key map: `lint→linter`, `format_check`/`format_fix→formatter`, `fix→fixer`, `test→test`, `security→security`. See the full [`.devrail.yml` schema reference](https://github.com/devrail-dev/devrail-standards/blob/main/standards/devrail-yml-schema.md) for the consumer surface.

## What's next

This release is the foundation. Two follow-ups land in v1.11 and v2.0:

- **v1.11.0 -- Kotlin extracted as the reference plugin.** We'll move Kotlin tooling out of the dev-toolchain image into a `devrail-plugin-kotlin` repo and document the extraction recipe so other languages can follow. This proves the model end-to-end against a non-trivial language ecosystem and gives future contributors a working template.
- **v2.0.0 -- monolithic `HAS_<LANG>` blocks retired.** All language support becomes plugin-based. We'll ship `devrail-init migrate --to v2` to handle the consumer-side cutover. Major version bump.

Plugin signing (cosign-style signature verification opt-in) is a separate track gated on a real supply-chain incident or broader ecosystem signals -- see [Story 13.10 in the epics](https://github.com/devrail-dev/devrail-standards/blob/main/_bmad-output/planning-artifacts/epics.md) for the rationale.

## Try it

`ghcr.io/devrail-dev/dev-toolchain:v1.10.6` and the floating `:v1` tag both ship the plugin loader. If you're already on v1, your next `docker pull` picks it up. Add a `plugins:` block to your `.devrail.yml`, run `make plugins-update`, commit `.devrail.lock`, and the next `make check` runs the plugin's tools alongside your core ones.

If you build a plugin we should know about, open a PR against the (forthcoming) `awesome-devrail` discovery list. For now, drop it in your team's repo or publish on GitHub and link it from your README.

The full [plugin architecture design doc](https://github.com/devrail-dev/dev-toolchain/blob/main/docs/plugin-architecture.md) and the [v1.10.6 changelog entry](https://github.com/devrail-dev/dev-toolchain/blob/main/CHANGELOG.md) cover the contract in detail. Questions, plugin authors who want feedback, or edge cases we should think about -- as always, open an issue.
