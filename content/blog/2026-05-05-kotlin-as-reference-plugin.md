---
title: "Kotlin Extracted as the Reference Plugin (v1.11)"
date: 2026-05-05
description: "v1.11 ships devrail-plugin-kotlin — the first language ecosystem moved out of dev-toolchain core into a standalone plugin repo. It proves the plugin model end-to-end and gives future contributors a working extraction recipe."
---

A few hours after [v1.10 introduced the plugin architecture](/blog/2026-05-05-plugin-architecture/), v1.11 ships the first proof. **`devrail-plugin-kotlin`** is now a separate repo, a separate release cadence, and -- for consumers who declare it -- the canonical way to use Kotlin tooling under DevRail.

In v1.11, the extraction is **additive**: dev-toolchain still ships Kotlin in core (so existing `languages: [kotlin]` consumers see zero change). v2.0.0 will retire the in-core path and make the plugin the only path. This release is the rehearsal.

## What changed

[`github.com/devrail-dev/devrail-plugin-kotlin`](https://github.com/devrail-dev/devrail-plugin-kotlin) is a new public repository tagged `v1.0.0`. It contains:

- `plugin.devrail.yml` -- the manifest that declares `name: kotlin`, `devrail_min_version: 1.10.0`, and the same five targets (`lint`, `format_check`, `format_fix`, `test`, `security`) the in-core blocks ship.
- `install.sh` -- a self-contained port of dev-toolchain's `scripts/install-kotlin.sh`. Same versions: ktlint 1.5.0, detekt 1.23.7, Gradle 8.12. JDK 21 is COPY'd from `eclipse-temurin:21-jdk` via the manifest's `container.copy_from_builder` block.
- DevRail-standard scaffolding (Makefile, `.devrail.yml`, pre-commit, CI). The plugin repo itself passes `make check`.
- `.github/workflows/ci.yml` -- runs `make check` and validates the manifest with dev-toolchain's `plugin-validator.sh` on every push.

To use it instead of the in-core Kotlin path:

```yaml
# .devrail.yml
plugins:
  - source: github.com/devrail-dev/devrail-plugin-kotlin
    rev: v1.0.0
    languages: [kotlin]
```

Then `make plugins-update && make check`. The build pipeline (Story 13.4) renders the manifest into a project-local `Dockerfile.devrail`, builds `devrail-local:<hash>`, and the dispatcher runs ktlint / detekt / gradle alongside any core-language tools.

> **Loader precedence note.** If a consumer also lists `kotlin` in the top-level `languages:` array, the loader hits the in-core path FIRST and the plugin doesn't run. Until v2.0.0 removes the in-core path, the way to exercise this plugin is to put `kotlin` only inside the plugin's `languages:` block. Document this for any plugin you ship that overlaps with a core language.

## Why Kotlin

We picked Kotlin as the reference extraction because:

1. **It's the freshest core language.** Added in March 2026; the install logic is recent and well-tested. Lower risk of "I forget what this Dockerfile bit does."
2. **Its install script is the heaviest in the matrix.** ktlint, detekt, and gradle each download from a separate upstream. JDK 21 from a builder stage. If extraction works for Kotlin, it works for almost anything.
3. **The `copy_from_builder` pattern is non-trivially exercised.** A whole JDK tree gets COPY'd from `eclipse-temurin:21-jdk`. The plugin manifest reproduces that exactly without dev-toolchain having to know about Kotlin.

## The extraction recipe

The single biggest deliverable in v1.11 is documentation -- a step-by-step recipe for extracting any core language as a plugin. It lives in [`devrail-standards/standards/contributing.md`](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#extracting-a-core-language-as-a-plugin) and covers:

- **Inventory the surface** -- `grep -nE "HAS_<LANG>|<lang>" Makefile Dockerfile scripts/install-<lang>.sh tests/test-<lang>.sh` to find every place dev-toolchain touches the language.
- **Map Makefile blocks to manifest targets** -- the rules for translating an `if [ -n "$(HAS_LANG)" ]; then ...` block into `targets.<name>.cmd` + `gates.<name>`. Notably: multi-tool blocks (Kotlin's `ktlint && detekt`) collapse into one cmd via `&&`. The v1 contract is one cmd per target.
- **Port the install script** -- strip every dependency on `lib/log.sh` and `lib/platform.sh`. Plugin install scripts run during `docker build` of the consumer's `Dockerfile.devrail`, before the dev-toolchain libs are in the layer being built. Replace `log_info` with `printf '[install-<lang>] %s\n' "$msg" >&2`.
- **Write the container fragment** -- `base_image`, `copy_from_builder`, `env`, `install_script`. Reproduces the dev-toolchain runtime layer.
- **Initialize the plugin repo with DevRail standards** -- copy the reference Makefile, `.devrail.yml: { languages: [bash] }`, pre-commit, gitignore. The plugin's own `install.sh` lints cleanly.
- **Validate end-to-end via `file://`** -- in a test consumer workspace, point `plugins:` at your local checkout, run `make plugins-update && make check`, watch the build pipeline build `devrail-local:<hash>` and the dispatcher run your tools.
- **Tag and announce** -- annotated semver tag (`git tag -a v1.0.0`), CHANGELOG entry on dev-toolchain, blog post.

The full text is [here](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#extracting-a-core-language-as-a-plugin). It's written so a contributor with no prior plugin work can follow it from scratch.

## What's regression-tested

Plus the manifest-shape side: dev-toolchain ships a new smoke test in `tests/test-kotlin-plugin-extraction.sh` that:

1. Validates `devrail-plugin-kotlin/plugin.devrail.yml` against schema_version 1.
2. Resolves the plugin via `file://` URL from a vendored fixture (`tests/fixtures/kotlin-via-plugin/`) and confirms `.devrail.lock` records the resolved SHA + content_hash.
3. Loads the plugin into the dispatcher cache and asserts name / version / devrail_min_version match.
4. Walks every target (lint / format_check / format_fix / test / security) and confirms the cmd + gate shape parity with the in-core HAS_KOTLIN behaviour. Specific assertions on `ktlint && detekt-cli` chaining catch regressions where someone changes the manifest but forgets to keep both tools wired up.

The full docker-build of `devrail-local:<hash>` with real ktlint/detekt/gradle downloads (~5 minutes) is NOT in CI — it's a maintainer-run manual check, same trade-off we made for the `minimal-v1` fixture in v1.10. CI gets a fast hermetic regression; humans do the heavy validation.

## What's coming in v2.0.0

The reason this extraction is additive is that we've committed to back-compat through v1.x. Existing consumers with `languages: [kotlin]` should not have to do anything when v1.11 lands. Their `make check` runs unchanged.

v2.0.0 (Story 13.9, no scheduled date yet) flips the model:

- Remove the in-core `HAS_KOTLIN` blocks and Kotlin Dockerfile bits. Same for every other core language as we extract them.
- Ship `devrail-init migrate --to v2` to walk consumer `.devrail.yml` files: any `languages:` entry that's no longer in core gets moved to `plugins:` with the appropriate plugin source pinned.
- Major version bump signals the breaking change.

Between now and then, every other core language gets the same extraction treatment (Swift, Ruby, Go, etc.). Each will follow the recipe documented from this Kotlin pass. We'll likely ship them as separate v1.x minor releases so the migration burden is incremental rather than one big v2 cliff.

## Try it

`ghcr.io/devrail-dev/dev-toolchain:v1.11.0` is up. The floating `:v1` tag now points there. To use the plugin, declare it as shown above and run `make plugins-update`. To author a similar extraction, follow [the recipe](https://github.com/devrail-dev/devrail-standards/blob/main/standards/contributing.md#extracting-a-core-language-as-a-plugin) and use `devrail-plugin-kotlin` as your worked example.

If you extract another core language, open a PR against the (forthcoming) `awesome-devrail` discovery list. Or just publish it on GitHub and link from your team's README -- the plugin model doesn't require any central registry.
