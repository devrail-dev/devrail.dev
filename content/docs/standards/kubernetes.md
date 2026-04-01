---
title: "Kubernetes"
linkTitle: "Kubernetes"
weight: 55
description: "Kubernetes tooling standards: kustomize and kubeconform for manifest validation."
---

Kubernetes projects use kustomize for rendering overlays and kubeconform for schema validation. Detection is automatic based on `kustomization.yaml` file presence -- no `.devrail.yml` language entry is needed.

## Tools

| Category | Tool | Purpose |
|---|---|---|
| Manifest Validation | kustomize build | Render overlays, catch structural errors |
| Schema Validation | kubeconform | Validate against Kubernetes API schemas |

All tools are pre-installed in the dev-toolchain container. Do not install them on the host.

## Configuration

### kustomize

No config file required. Reads `kustomization.yaml` in each overlay directory.

### kubeconform

No config file required. Validates against built-in Kubernetes schemas. Override the target version if needed:

```bash
kustomize build overlays/production | kubeconform -strict -kubernetes-version 1.29.0
```

For CRDs, add additional schema sources:

```bash
kubeconform -strict \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
```

## Makefile Targets

| Target | Command | Description |
|---|---|---|
| `make lint` | `kustomize build <dir> \| kubeconform -strict -summary` | Validate each Kustomize overlay |

Detection is automatic. Every directory containing `kustomization.yaml` is validated independently.

## Pre-Commit Hooks

### CI-Only (too slow for local hooks)

Kustomize validation runs via `make lint` in CI. It is not configured as a local pre-commit hook because `kustomize build` may need to fetch remote bases.

## Notes

- **Kustomize is a companion tool, not a language.** No `.devrail.yml` entry needed. Auto-detected by `kustomization.yaml` presence.
- **kubeconform replaces kubeval.** kubeval is deprecated. kubeconform is the maintained successor with better CRD support.
- **Each overlay is validated independently.** The Makefile finds all `kustomization.yaml` files and validates each directory.
- **CRD validation requires schema sources.** Core Kubernetes resources are validated by default. CRDs need additional schema locations configured.
- **All tools are pre-installed in the dev-toolchain container.** Do not install them on the host.
- For cross-cutting coding practices and git workflow standards, see [Coding Practices](/docs/standards/practices/).
