---
title: "Our Response to the Trivy Supply Chain Attack"
date: 2026-03-23
description: "How the Trivy GitHub Actions compromise affected DevRail, what we found, and what we changed."
---

On March 19, 2026, attackers compromised credentials for the Aqua Security GitHub organization and force-pushed 75 of 76 version tags in the [trivy-action](https://github.com/aquasecurity/trivy-action) repository to point at malicious commits containing an infostealer. A malicious Trivy binary (v0.69.4) was also briefly published. This post covers our assessment and response.

## What Happened

The attackers exploited credentials that were not fully rotated after a prior incident on March 1. During a window of approximately 12 hours (March 19 ~17:43 UTC to March 20 ~05:40 UTC), every `trivy-action` tag from `0.0.1` through `0.34.0` pointed to a commit that ran a Python-based credential stealer. The payload harvested environment variables, SSH keys, cloud credentials, Kubernetes tokens, and other secrets from CI runners, then exfiltrated them to a command-and-control server.

Full details are available in [Aqua Security's advisory](https://github.com/aquasecurity/trivy/discussions/10425) and [aquasecurity/trivy-action#541](https://github.com/aquasecurity/trivy-action/issues/541).

## Impact on DevRail

**No DevRail secrets were compromised.**

Our CI workflow (`ci.yml`) referenced `aquasecurity/trivy-action@0.28.0`, which was among the hijacked tags. However, all CI runs on March 19 completed by 04:58 UTC -- approximately 13 hours before the attack window opened at ~17:43 UTC. No CI jobs ran during the compromise period.

The Trivy binary inside the dev-toolchain container (v0.69.3, installed via the APT repository at `get.trivy.dev/deb`) was not affected. The malicious binary was v0.69.4, which was published only via GitHub releases and Docker Hub, not the APT channel.

| Component | Our version | Status |
|---|---|---|
| Trivy binary in container | 0.69.3 (APT) | Not affected |
| `trivy-action` in CI | `@0.28.0` (tag) | Tag was hijacked, but no runs during the window |
| `setup-trivy` | Not used | N/A |

## What We Changed

We pinned `trivy-action` to a full commit SHA instead of a version tag:

```yaml
# Before (vulnerable to tag poisoning)
uses: aquasecurity/trivy-action@0.28.0

# After (immune to tag poisoning)
uses: aquasecurity/trivy-action@57a97c7e7821a5776cebc9bb87c984fa69cba8f1 # v0.35.0
```

Version 0.35.0 was created after the first incident and was confirmed safe by Aqua Security.

This change is in [dev-toolchain PR #18](https://github.com/devrail-dev/dev-toolchain/pull/18).

## Lessons

**Pin GitHub Actions to commit SHAs, not version tags.** Git tags are mutable -- anyone with write access can force-push a tag to point at any commit. A compromised maintainer credential is enough to silently replace every version of an action with malicious code. SHA references are immutable and cannot be changed after the fact.

This applies to all third-party GitHub Actions, not just Trivy. The [GitHub documentation on security hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions) recommends the same practice.

**Install tools from package managers when possible.** The Trivy binary inside our container was installed via APT, not from GitHub releases. The APT channel was not compromised. Package manager distribution adds a layer of indirection that makes supply chain attacks harder to execute -- the attacker would need to compromise the package repository infrastructure, not just a single GitHub credential.

**Monitor your CI execution windows.** Knowing exactly when your CI jobs ran relative to a compromise window is the difference between "rotate everything" and "no action needed." We were able to confirm no exposure because our run timestamps were well outside the attack period.
