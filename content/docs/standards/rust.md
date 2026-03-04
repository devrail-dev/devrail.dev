---
title: "Rust"
linkTitle: "Rust"
weight: 35
description: "Rust tooling standards: clippy, rustfmt, cargo-audit, cargo-deny, and cargo test."
---

Rust projects use clippy for linting, rustfmt for formatting, cargo-audit and cargo-deny for security scanning, and cargo test for testing.

## Tools

| Category | Tool | Purpose |
|---|---|---|
| Linter | clippy | Official Rust linter (rustup component) |
| Formatter | rustfmt | Official Rust formatter (rustup component) |
| Security (vulns) | cargo-audit | Scans Cargo.lock for known vulnerabilities |
| Security (policy) | cargo-deny | Enforces dependency policies (licenses, bans, sources) |
| Tests | cargo test | Built-in Rust test runner |

All tools are pre-installed in the dev-toolchain container. Do not install them on the host.

## Configuration

### clippy

Config file: `clippy.toml` at repository root.

```toml
# clippy.toml -- DevRail Rust clippy configuration
# See: https://doc.rust-lang.org/clippy/lint_configuration.html
too-many-arguments-threshold = 7
```

Clippy is invoked with `-D warnings` to treat all warnings as errors. Additional lint groups can be enabled via `#![warn(clippy::pedantic)]` in `lib.rs` or `main.rs`.

### rustfmt

Config file: `rustfmt.toml` at repository root.

```toml
# rustfmt.toml -- DevRail Rust formatter configuration
edition = "2021"
max_width = 100
use_field_init_shorthand = true
use_try_shorthand = true
```

### cargo-audit

No config file required. Scans `Cargo.lock` for known vulnerabilities in crate dependencies using the RustSec Advisory Database.

### cargo-deny

Config file: `deny.toml` at repository root.

```toml
# deny.toml -- DevRail cargo-deny configuration
# See: https://embarkstudios.github.io/cargo-deny/

[advisories]
vulnerability = "deny"
unmaintained = "warn"
yanked = "warn"

[licenses]
unlicensed = "deny"
allow = [
  "MIT",
  "Apache-2.0",
  "BSD-2-Clause",
  "BSD-3-Clause",
  "ISC",
  "Unicode-3.0",
  "Unicode-DFS-2016",
]

[bans]
multiple-versions = "warn"

[sources]
unknown-registry = "deny"
unknown-git = "warn"
```

## Makefile Targets

| Target | Command | Description |
|---|---|---|
| `make lint` | `cargo clippy --all-targets --all-features -- -D warnings` | Lint all Rust files |
| `make format` | `cargo fmt --all -- --check` | Check formatting |
| `make fix` | `cargo fmt --all` | Apply formatting fixes |
| `make security` | `cargo audit` | Dependency vulnerability scanning (if `Cargo.lock` exists) |
| `make security` | `cargo deny check` | Dependency policy checking (if `deny.toml` exists) |
| `make test` | `cargo test --all-targets` | Run test suite (if `*.rs` files and `Cargo.toml` exist) |

## Pre-Commit Hooks

### Local Hooks (run on every commit, under 30 seconds)

Formatting and linting with cargo via pre-commit-cargo:

```yaml
# .pre-commit-config.yaml -- Rust hooks
repos:
  - repo: https://github.com/AndrejOrsula/pre-commit-cargo
    rev: v0.4.0
    hooks:
      - id: cargo-fmt
        args: ["--all", "--", "--check"]
      - id: cargo-clippy
        args: ["--all-targets", "--all-features", "--workspace", "--", "-D", "warnings"]
```

### CI-Only (too slow for local hooks)

- `cargo audit` -- dependency vulnerability scanning
- `cargo deny check` -- dependency policy enforcement
- `cargo test --all-targets` -- full test suite

## Notes

- **Clippy is the single linting tool.** It is the official Rust linter, bundled as a rustup component. It subsumes many standalone lint tools.
- **rustfmt is the single formatting tool.** It is the official Rust formatter, also bundled as a rustup component. There is no "strict superset" -- rustfmt is the standard.
- **The entire Rust toolchain is included in the container.** Clippy and rustfmt are tightly coupled to the compiler version. The full toolchain (rustup + cargo + rustc + stdlib) is COPY'd from the builder stage.
- **`Cargo.lock` presence gates vulnerability scanning.** If no `Cargo.lock` file exists, `cargo audit` is skipped because there are no pinned dependencies to scan.
- **`deny.toml` presence gates policy checking.** If no `deny.toml` file exists, `cargo deny` is skipped.
- **`cargo test --all-targets` runs all test types.** This includes unit tests, integration tests, doc tests, and examples. It gates on the presence of `*.rs` files and `Cargo.toml`.
- **All tools are pre-installed in the dev-toolchain container.** Do not install them on the host.
- For cross-cutting coding practices and git workflow standards that apply to all languages, see [Coding Practices](/docs/standards/practices/).
