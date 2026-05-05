---
title: "Contributing a Plugin"
linkTitle: "Contributing a Plugin"
weight: 15
description: "Step-by-step guide for authoring a DevRail plugin that ships a new language ecosystem or tool integration without forking the core repos."
---

DevRail plugins extend the dev-toolchain image with new languages or tool integrations *without* a fork or PR against the core repos. The plugin loader (shipped in v1.10.0+) reads `plugins:` from a consumer's `.devrail.yml`, resolves each entry to an immutable git ref, builds a project-local extended image (`devrail-local:<hash>`), and dispatches plugin-defined targets inside the existing `make check` recipes.

If you have a tool you want every DevRail-managed project to use, you can ship it as a plugin instead of opening a PR against `dev-toolchain`. This page is the high-level overview; the canonical authoring guide with full templates is in the `devrail-standards` repo.

{{% alert title="Canonical Reference" color="info" %}}
The authoritative, detailed plugin authoring guide lives at [`standards/contributing.md` § Contributing a Plugin](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#contributing-a-plugin). This page provides the overview; the canonical guide provides field-by-field schema, container integration patterns, and a publishing checklist.
{{% /alert %}}

## What is a plugin?

A plugin is a git repository containing a `plugin.devrail.yml` manifest at the repo root. The manifest declares:

- **Identity** — `name`, `version`, `schema_version`, `devrail_min_version`
- **Container fragment** — `apt_packages`, `copy_from_builder`, `env`, `install_script` (layered onto the core dev-toolchain image)
- **Targets** — `lint`, `format_check`, `format_fix`, `fix`, `test`, `security` commands
- **Gates** — per-target paths that must exist for the target to run

When a consumer declares your plugin in their `.devrail.yml`, `make check` automatically:

1. Fetches the plugin's manifest at the pinned `rev:` and validates it against the schema
2. Generates a `Dockerfile.devrail` extending the core image with your container fragment
3. Builds `devrail-local:<hash>` (cached by content hash — unchanged plugin sets reuse the image)
4. Runs your targets alongside core-language targets, aggregating results into the same JSON envelope

## Quick start

1. **Create the repo.** Convention is `devrail-plugin-<name>` (the trailing path component is not enforced — the manifest's `name` field is authoritative — but encouraged for discoverability).

2. **Add `plugin.devrail.yml`:**

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

3. **Test locally** against a consumer workspace using a `file://` URL:

   ```yaml
   # In the consumer's .devrail.yml
   languages:
     - elixir

   plugins:
     - source: file:///home/you/devrail-plugin-elixir
       rev: v1.0.0
       languages: [elixir]
   ```

   ```bash
   make plugins-update     # resolver fetches the file:// fixture
   make check              # full pipeline runs your plugin
   ```

4. **Tag and publish** an annotated semver tag (`git tag -a v1.0.0`). Consumers pin via `rev: v1.0.0` (or a full SHA) — branch refs are rejected.

## Versioning

- **`schema_version`** is the manifest format. Pinned at `1` for the v1.10.x line. The loader rejects unknown majors.
- **`version`** is your plugin's own semver. Bump on each release.
- **`devrail_min_version`** is the oldest dev-toolchain version your plugin supports. Set to `1.10.0` for plugins targeting the first stable plugin-loader release.
- The consumer's `.devrail.lock` records the resolved SHA + content hash. Re-tagging an existing tag onto different code is detected via content_hash mismatch.

## Override surface

Consumers can override your manifest defaults from their `.devrail.yml`:

```yaml
elixir:
  linter: dialyxir          # replaces targets.lint.cmd
  test: "mix test --cover"  # replaces targets.test.cmd
```

Override key map: `lint→linter`, `format_check`/`format_fix→formatter`, `fix→fixer`, `test→test`, `security→security`.

## What's NOT in scope for v1.10

These are deferred to later phases:

- **Plugin signing** — content_hash detects tampering, but not authenticity. Coming in a later release.
- **Sidecar / volume-mounted plugins** — extended image (Option A) is the only execution mode in v1.
- **Parallel plugin execution** — sequential per design; needs shared-state semantics first.

## Next steps

- Read the [canonical plugin authoring guide](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#contributing-a-plugin) for field-by-field details, container integration patterns, and the pre-publish checklist.
- Read the [plugin architecture design doc](https://github.com/devrail-dev/dev-toolchain/blob/main/docs/plugin-architecture.md) for the full rationale and lifecycle.
- See the [`plugins:` schema documentation](https://github.com/devrail-dev/devrail-standards/blob/main/standards/devrail-yml-schema.md) for the consumer-side declaration shape.
