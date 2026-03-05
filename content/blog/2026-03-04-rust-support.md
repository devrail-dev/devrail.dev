---
title: "Rust Support"
date: 2026-03-04
description: "DevRail now supports Rust -- clippy, rustfmt, cargo-audit, cargo-deny, and cargo test ship in the dev-toolchain container."
---

Rust is the eighth language ecosystem in DevRail. Add `rust` to your `.devrail.yml` and the full toolchain is available immediately.

## What Ships

The dev-toolchain container includes the complete Rust toolchain and five tools:

| Concern | Tool | What It Does |
|---|---|---|
| Linter | clippy | Official Rust linter, treats warnings as errors |
| Formatter | rustfmt | Official Rust formatter |
| Security | cargo-audit | Scans `Cargo.lock` against the RustSec Advisory Database |
| Security | cargo-deny | Enforces license, ban, and source policies on dependencies |
| Tests | cargo test | Built-in test runner, all targets |

The entire Rust toolchain -- rustup, cargo, rustc, clippy, and rustfmt -- is COPY'd from the `rust:1-slim-bookworm` builder stage. Clippy and rustfmt are rustup components, tightly coupled to the compiler version. Shipping them together eliminates version drift between the linter, formatter, and compiler.

cargo-audit and cargo-deny are installed via [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) in the builder stage, avoiding long compilation times for these tools.

## How It Works

```yaml
# .devrail.yml
languages:
  - rust
```

```console
$ make check
✓ lint       (cargo clippy --all-targets --all-features -- -D warnings)
✓ format     (cargo fmt --all -- --check)
✓ security   (cargo audit, cargo deny check)
✓ test       (cargo test --all-targets)
✓ scan       (trivy, gitleaks)
```

`make fix` runs `cargo fmt --all` to auto-format in place.

## Gating

Each tool gates on the presence of the files it needs:

- **clippy and rustfmt** gate on `*.rs` files
- **cargo audit** gates on `Cargo.lock` -- skipped if no lock file exists
- **cargo deny** gates on `deny.toml` -- skipped if no policy file exists
- **cargo test** gates on `*.rs` files + `Cargo.toml`

This means Rust tools run only when there is Rust code to check. A multi-language project that declares `rust` but has not yet added any `.rs` files will not fail.

## Pre-Commit Hooks

The template repositories include commented hooks using [pre-commit-cargo](https://github.com/AndrejOrsula/pre-commit-cargo):

```yaml
- repo: https://github.com/AndrejOrsula/pre-commit-cargo
  rev: v0.4.0
  hooks:
    - id: cargo-fmt
      args: ["--all", "--", "--check"]
    - id: cargo-clippy
      args: ["--all-targets", "--all-features", "--workspace", "--", "-D", "warnings"]
```

Security scanning and tests remain CI-only due to execution time.

## Get Started

- [Rust standards reference](/docs/standards/rust/) -- configuration, Makefile targets, and notes
- [Container tool versions](/docs/container/versions/) -- exact versions shipped in the current image
