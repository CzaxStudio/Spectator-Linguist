# Spectator — Space Package Manager

> Integrity-verified library distribution for Spectator.
> Works like pip (Python) and cargo (Rust).

---

## Table of Contents

- [Overview](#overview)
- [Commands](#commands)
- [Installing Libraries](#installing-libraries)
- [Integrity Verification](#integrity-verification)
- [Listing & Info](#listing--info)
- [Updating & Removing](#updating--removing)
- [Publishing a Library](#publishing-a-library)
- [Official Libraries](#official-libraries)
- [Registry Format](#registry-format)

---

## Overview

Space manages Spectator libraries with a central public registry and per-install SHA-256 hash verification. Every library downloaded from the registry is verified against its recorded hash before being written to disk.

```
Central Registry (GitHub)          Local Machine
─────────────────────────          ──────────────
registry.json                      ~/.space/installed.json
  coffee → source URL + hash         coffee → version, hash, date
  ghost  → source URL + hash         ghost  → version, hash, date
  ...                                ...

                                   ~/.space/libs/
                                     coffee/index.str
                                     coffee/manifest.json
                                     ghost/index.str
                                     ghost/manifest.json
```

---

## Commands

```
spectator space get <n>              Install from registry (SHA-256 verified)
spectator space get <n> <url>        Install from direct URL
spectator space list                 Show installed libraries
spectator space registry             Browse all published libraries
spectator space search <keyword>     Search registry by keyword
spectator space info <n>             Full details + update check
spectator space update <n>           Re-download and re-verify
spectator space verify <n>           Verify installed file integrity
spectator space hash <file.str>      Compute SHA-256 of a file
spectator space remove <n>           Uninstall
spectator space make lib = file.str  Package + generate registry entry
spectator space publish <n>          Show how to submit to central registry
spectator space help                 Show help
```

---

## Installing Libraries

### From the Central Registry

```powershell
spectator space get coffee
spectator space get ghost
```

Space looks up the library in the central registry, downloads it, verifies its SHA-256 hash, and installs it to `~/.space/libs/`.

**Output:**
```
  [Space] Looking up coffee...
  [✓] Found in registry

  Name:         coffee
  Version:      1.0.0
  Author:       CzaxStudio
  License:      MIT
  Desc:         Premium all-in-one recon library
  SHA-256:      a3f8d2c1b7e4...

  ↓ Downloading: https://raw.githubusercontent.com/...

  ⊕ Verifying integrity...
  [✓] Integrity verified — SHA-256 matches registry

  [✓] Installed: coffee (24.1 KB)
  Location:  C:\Users\Ghost\.space\libs\coffee\index.str
  SHA-256:   a3f8d2c1b7e4...

  Use in script: #Import coffee
```

### From a Direct URL

```powershell
spectator space get mylib https://raw.githubusercontent.com/user/repo/main/mylib.str
```

When installing from a direct URL, no registry hash is available. Space computes and records the hash for future `verify` checks.

### Using in Scripts

```spectator
#Import coffee
#Import ghost
```

---

## Integrity Verification

Spectator uses SHA-256 hashes to protect against supply-chain attacks — tampered files are detected and blocked.

### How it Works

1. `registry.json` stores a SHA-256 hash for each library
2. On `Space get`, the downloaded file is hashed
3. The hash is compared to the registry entry
4. **Mismatch → install aborted**, nothing written to disk
5. Hash is stored locally in `manifest.json` and `installed.json`

### If a Hash Mismatch is Detected

```
  ╔══════════════════════════════════════════════════════╗
  ║  ⚠  INTEGRITY CHECK FAILED                          ║
  ║  The downloaded file does not match the registry.   ║
  ║  This may indicate a supply-chain attack.           ║
  ╚══════════════════════════════════════════════════════╝
  Installation aborted. Contact the library author.
```

### Verify an Installed Library

Re-hash the installed file and compare to the stored hash:

```powershell
spectator space verify coffee
```

**Output (clean):**
```
  [Space] Verifying integrity of: coffee

  Recorded hash:  a3f8d2c1b7e4...
  Current hash:   a3f8d2c1b7e4...

  [✓] VERIFIED — file is intact and unmodified
  [✓] Also matches current registry hash
```

**Output (tampered):**
```
  ╔══════════════════════════════════════════════════════╗
  ║  ⚠  INTEGRITY VIOLATION DETECTED                    ║
  ║  The installed file has been modified since install. ║
  ║  Reinstall immediately: Space update coffee          ║
  ╚══════════════════════════════════════════════════════╝
```

### Compute a File's Hash

```powershell
spectator space hash mylib.str
```

**Output:**
```
  [Space] SHA-256 Hash
  ────────────────────────────────────────────────────────────────────────
  File:        mylib.str
  Size:        12.4 KB
  SHA-256:     a3f8d2c1b7e49f2d8c3a1b5e7f4d2c9a8b3e6f1d4c7a2b5e8f3d6c9a2b5e8f1

  Add this to your registry.json entry:
  "sha256": "a3f8d2c1b7e49f2d8c3a1b5e7f4d2c9a8b3e6f1d4c7a2b5e8f3d6c9a2b5e8f1"
```

---

## Listing & Info

### List Installed Libraries

```powershell
spectator space list
```

```
  Installed Libraries
  ──────────────────────────────────────────────────────────────────────────────
  Name               Version    Author             Hash     Installed
  ──────────────────────────────────────────────────────────────────────────────
  coffee             1.0.0      CzaxStudio         ✓ ok     2026-03-20
  ghost              1.0.0      CzaxStudio         ✓ ok     2026-03-21
  ──────────────────────────────────────────────────────────────────────────────
  2 libraries installed.
  Verify integrity: Space verify <n>
```

### Browse the Registry

```powershell
spectator space registry
```

Shows all published libraries with version, author, description, hash status, and install command.

### Search

```powershell
spectator space search osint
spectator space search recon
spectator space search dns
```

### Full Info + Update Check

```powershell
spectator space info coffee
```

Shows installed version, source URL, install date, hash, and whether an update is available.

---

## Updating & Removing

### Update

Re-downloads from the source URL, verifies the new hash:

```powershell
spectator space update coffee
```

### Remove

```powershell
spectator space remove coffee
spectator space rm ghost
```

---

## Publishing a Library

### Step 1 — Write Your Library

Create a `.str` file. Convention: use `#` comments at the top:

```spectator
## Library  : myrecon
## Version  : 1.0.0
## Author   : YourHandle
## License  : MIT
## Desc     : Custom recon helpers

func myrecon_dns(target) {
  ips = resolve(target)
  each ip : ips { Trace("  A: " --> ip) }
}

func myrecon_ports(target) {
  do --> PortScan(target, 1, 1024)
}
```

### Step 2 — Host on GitHub

Push `myrecon.str` to a public GitHub repo. Get the raw URL:

```
https://raw.githubusercontent.com/YourHandle/myrecon/main/myrecon.str
```

### Step 3 — Package Locally

```powershell
spectator space make lib = myrecon.str
```

Space will ask for:
- Library name
- Version
- Author
- License
- Description
- Keywords
- Raw download URL
- GitHub page (optional)

It packages the file, installs it locally, computes its SHA-256, and generates a ready-to-submit registry entry.

### Step 4 — Get the Hash

```powershell
spectator space hash myrecon.str
```

Copy the SHA-256 output.

### Step 5 — Submit a Pull Request

Fork [https://github.com/CzaxStudio/Spectator](https://github.com/CzaxStudio/Spectator) and add your entry to `registry.json`:

```json
"myrecon": {
  "name":         "myrecon",
  "version":      "1.0.0",
  "author":       "YourHandle",
  "license":      "MIT",
  "description":  "Custom recon helpers for Spectator",
  "source":       "https://raw.githubusercontent.com/YourHandle/myrecon/main/myrecon.str",
  "github":       "https://github.com/YourHandle/myrecon",
  "keywords":     ["recon", "dns"],
  "sha256":       "a3f8d2c1b7e49f2d8c3a1b5e7f4d2c9a8b3e6f1d4c7a2b5e8f3d6c9a2b5e8f1",
  "registered_at":"2026-03-24"
}
```

Once merged, anyone on Earth can install your library with:

```powershell
spectator space get myrecon
```

> **Important:** The `sha256` field must match the SHA-256 of the file at the `source` URL. If you update the file, recompute the hash and update `registry.json` via another PR.

---

## Official Libraries

### Coffee — Recon Library

```powershell
spectator space get coffee
```

```spectator
#Import coffee

## Full recon on a target
coffee_full("target.com")

## Individual functions
coffee_dns("target.com")
coffee_ports("target.com")
coffee_web("https://target.com")
coffee_score("target.com")
```

### Ghost — OSINT Library

```powershell
spectator space get ghost
```

```spectator
#Import ghost

## All-in-one OSINT with mission report
ghost_full("target.com")

## Individual modules
ghost_domain("target.com")
ghost_ip("93.184.216.34")
ghost_email("user@target.com")
ghost_username("target_user")
ghost_person("John Smith")
ghost_company("Acme Corp")
ghost_phone("+1-555-0100")
ghost_breach_check("user@target.com")
ghost_dork("target.com", "passwords")
ghost_timeline("target.com")
```

---

## Registry Format

`registry.json` lives at the root of [https://github.com/CzaxStudio/Spectator](https://github.com/CzaxStudio/Spectator):

```json
{
  "coffee": {
    "name":         "coffee",
    "version":      "1.0.0",
    "author":       "CzaxStudio",
    "license":      "MIT",
    "description":  "Premium all-in-one recon library",
    "source":       "https://raw.githubusercontent.com/CzaxStudio/Spectator/main/Coffee",
    "github":       "https://github.com/CzaxStudio/Spectator",
    "keywords":     ["recon", "dns", "portscan", "web", "osint", "pentest"],
    "sha256":       "abc123...",
    "registered_at":"2026-03-20"
  }
}
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Library name (lowercase, no spaces) |
| `version` | ✅ | Semantic version (`1.0.0`) |
| `author` | ✅ | GitHub handle or name |
| `license` | ✅ | License identifier (`MIT`, `Apache-2.0`) |
| `description` | ✅ | One-line description |
| `source` | ✅ | Raw URL to download the `.str` file |
| `github` | ✓ | Human-readable GitHub page |
| `keywords` | ✓ | Search tags |
| `sha256` | ✅ | SHA-256 of the file at `source` |
| `registered_at` | ✓ | Date added (`YYYY-MM-DD`) |

### File Locations

| Path | Description |
|------|-------------|
| `~/.space/installed.json` | Local install database |
| `~/.space/libs/<n>/index.str` | Installed library code |
| `~/.space/libs/<n>/manifest.json` | Library metadata + hash |
