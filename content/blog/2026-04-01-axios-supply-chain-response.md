---
title: "Axios Supply Chain Attack: DevRail Is Not Affected"
date: 2026-04-01
description: "The axios npm package was compromised on March 31. DevRail containers do not ship axios and are not affected. Here is our full assessment."
---

On March 31, 2026, attackers compromised a maintainer account for the [axios](https://www.npmjs.com/package/axios) npm package and published malicious versions containing a cross-platform remote access trojan. This post covers our assessment and why DevRail users are not affected.

## What Happened

The attacker published two compromised versions of axios -- `1.14.1` and `0.30.4` -- via the official npm registry. The malicious versions injected a hidden dependency (`plain-crypto-js@4.2.1`) whose postinstall script deployed a platform-specific RAT targeting macOS, Windows, and Linux. The malware performed system fingerprinting, beaconed to a command-and-control server every 60 seconds, and accepted arbitrary commands.

The compromised versions were live for approximately three hours before npm removed them.

Full details are available in [Snyk's advisory](https://snyk.io/blog/axios-npm-package-compromised-supply-chain-attack-delivers-cross-platform/).

## Impact on DevRail

**DevRail is not affected. No action is required for DevRail-managed projects.**

The dev-toolchain container installs JavaScript tooling via `npm install -g`: ESLint, Prettier, TypeScript, and Vitest. None of these packages depend on axios. Axios is an HTTP client library used in application code, not a development tool dependency.

We verified this by inspecting the published container image:

```bash
# Check for axios in global npm packages
docker run --rm ghcr.io/devrail-dev/dev-toolchain:v1 \
  npm list -g --all 2>/dev/null | grep -i axios
# No results

# Check for the malicious package
docker run --rm ghcr.io/devrail-dev/dev-toolchain:v1 \
  npm list -g --all 2>/dev/null | grep -i plain-crypto
# No results
```

Additionally, the current published container image (`v1`) was built on March 16, 2026 -- 15 days before the attack. Even if axios were a transitive dependency, the compromised versions did not exist at build time.

| Check | Result |
|---|---|
| axios in container npm packages | Not present |
| `plain-crypto-js` in container | Not present |
| Container build date | March 16 (15 days before attack) |
| CI runs during attack window | None |

## What About User Projects?

If your project uses axios as an application dependency, DevRail's security scanning will help:

- **`npm audit`** runs as part of `make security` for JavaScript projects. Once the npm advisory propagates, it will flag the compromised versions in your `package-lock.json`.

- **trivy** scans `node_modules/` for known vulnerabilities as part of `make scan`. It will detect compromised packages in your project's filesystem.

To check your project immediately:

```bash
# Check if your project uses affected versions
grep -A 2 '"axios"' package-lock.json | grep '"version"'

# Run DevRail security checks
make security
make scan
```

If you find axios `1.14.1` or `0.30.4` in your lockfile, update immediately and rotate any credentials that may have been exposed on affected machines.

## Lessons

**Dev tools and application dependencies have different risk profiles.** DevRail's container ships linters, formatters, and test runners -- not HTTP clients, ORMs, or other application libraries. This architectural separation means application-level supply chain attacks do not compromise the development toolchain.

**Postinstall scripts remain a significant attack vector.** The axios attack used npm's postinstall mechanism to execute arbitrary code during `npm install`. Consider adding `--ignore-scripts` to CI install commands for application dependencies, and audit any packages that declare postinstall scripts.

**Lock files are your audit trail.** The fastest way to determine exposure is to check `package-lock.json` for the affected version numbers. Projects without lock files cannot be audited reliably -- this is one reason DevRail requires lock files for `npm audit` to run.
