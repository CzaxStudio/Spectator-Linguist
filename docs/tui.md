# Spectator — TUI (Terminal UI)

> Professional terminal output — colors, tables, banners, progress bars,
> and interactive input. No imports needed.

---

## Table of Contents

- [Output](#output)
- [Colors](#colors)
- [Banner](#banner)
- [Table](#table)
- [Progress Bar](#progress-bar)
- [Interactive Input](#interactive-input)
- [Pipeline Utilities](#pipeline-utilities)
- [Display Formatting](#display-formatting)
- [Full Example](#full-example)

---

## Output

### Trace

Print any value to the terminal with a newline:

```spectator
Trace("Hello, World!")
Trace(42)
Trace(true)
Trace(str(3.14))
Trace("Port " --> str(80) --> " is open")
```

### Print

Print without a newline:

```spectator
print("Loading")
print(".")
print(".")
print(" done")
## Output: Loading... done
```

---

## Colors

Apply ANSI color to any string with `colorize(text, color)`:

```spectator
Trace(colorize("CRITICAL finding",  "red"))
Trace(colorize("Test passed",       "green"))
Trace(colorize("Warning",           "yellow"))
Trace(colorize("Info",              "cyan"))
Trace(colorize("Detail",            "magenta"))
Trace(colorize("Bold heading",      "bold"))
Trace(colorize("Subtle note",       "dim"))
```

### Available Colors

| Name | Effect |
|------|--------|
| `red` | Red text |
| `green` | Green text |
| `yellow` | Yellow text |
| `cyan` | Cyan text |
| `magenta` | Magenta / purple text |
| `bold` | Bold text |
| `dim` | Dimmed / gray text |

### Practical Usage

```spectator
## Severity coloring
func severity_color(sev) {
  match sev {
    "CRITICAL" => { return colorize(sev, "red")     }
    "HIGH"     => { return colorize(sev, "red")     }
    "MEDIUM"   => { return colorize(sev, "yellow")  }
    "LOW"      => { return colorize(sev, "cyan")    }
    "INFO"     => { return colorize(sev, "dim")     }
    _          => { return sev                       }
  }
}

Trace(severity_color("CRITICAL") --> " — SQL Injection found")
Trace(severity_color("MEDIUM")   --> " — Missing HSTS header")
Trace(severity_color("INFO")     --> " — Target runs Nginx 1.24")
```

---

## Banner

Print a professional ASCII banner box:

```spectator
banner("SPECTATOR RECON")
banner("PHASE 1: DISCOVERY")
banner("SCAN COMPLETE")
```

**Output:**
```
  ╔══════════════════════╗
  ║   SPECTATOR RECON    ║
  ╚══════════════════════╝
```

### Custom Section Headers

```spectator
func section(title) {
  Trace("")
  Trace(colorize("  ┌─ " --> title --> " " --> repeat("─", 44 - len(title)) --> "┐", "cyan"))
}

func section_end() {
  Trace(colorize("  └" --> repeat("─", 50) --> "┘", "cyan"))
}

section("DNS Records")
Trace("  A  : 93.184.216.34")
Trace("  MX : mail.target.com")
section_end()
```

---

## Table

Print a formatted ASCII table:

```spectator
table(
  ["Port", "Service", "Status", "Risk"],
  [
    ["22",   "SSH",   "OPEN",   "MEDIUM"],
    ["80",   "HTTP",  "OPEN",   "LOW"],
    ["443",  "HTTPS", "OPEN",   "LOW"],
    ["3306", "MySQL", "OPEN",   "HIGH"],
    ["3389", "RDP",   "OPEN",   "HIGH"]
  ]
)
```

**Output:**
```
  +------+---------+--------+--------+
  | Port | Service | Status | Risk   |
  +------+---------+--------+--------+
  | 22   | SSH     | OPEN   | MEDIUM |
  | 80   | HTTP    | OPEN   | LOW    |
  | 443  | HTTPS   | OPEN   | LOW    |
  | 3306 | MySQL   | OPEN   | HIGH   |
  | 3389 | RDP     | OPEN   | HIGH   |
  +------+---------+--------+--------+
```

### Dynamic Tables

Build the rows list programmatically:

```spectator
target = "target.com"
ports  = [21, 22, 80, 443, 3306, 3389, 8080, 8443]
svcs   = portServices()
rows   = []

each p : ports {
  try {
    if hasPort(target, p) {
      rows = append(rows, [str(p), svcs[str(p)], "OPEN"])
    }
  } catch e {}
}

if len(rows) > 0 {
  table(["Port", "Service", "Status"], rows)
} else {
  Trace("No open ports found.")
}
```

---

## Progress Bar

Show a live updating progress bar in the terminal:

```spectator
progress(current, total, label)
```

```spectator
## Basic usage
loop 10 {
  progress(_i + 1, 10, "Scanning...")
  sleep(100)
}

## With dynamic label
ports = [21, 22, 80, 443, 3306, 3389, 8080, 8443, 8888, 9200]
each p, idx : ports {
  progress(idx + 1, len(ports), "Checking port " --> str(p))
  try { hasPort("target.com", p) } catch e {}
}
```

**Output:**
```
  [████████████████░░░░░░░░░░░░░░]  53%  8/15  Checking port 8080
```

### Subdomain Enumeration with Progress

```spectator
target = "target.com"
subs   = wordlist("common_subdomains")
total  = len(subs)
found  = []

each sub, idx : subs {
  progress(idx + 1, total, "Checking " --> sub --> "." --> target)
  fqdn = sub --> "." --> target
  try {
    ips = resolve(fqdn)
    if len(ips) > 0 {
      found = append(found, fqdn)
    }
  } catch e {}
}

Trace("")
Trace(colorize("  [+] " --> str(len(found)) --> " subdomains found", "green"))
each f : found { Trace("      " --> f) }
```

---

## Interactive Input

Read input from the user at the terminal:

```spectator
## Basic prompt
target = Capture("Target: ")
Trace("Scanning: " --> target)

## With validation
func get_target() {
  loop {
    t = Capture("Enter target (domain or IP): ")
    t = trim(t)
    if t != "" { return t }
    Trace(colorize("  [!] Target cannot be empty.", "red"))
  }
}

target = get_target()
```

### Interactive Menu

```spectator
banner("SPECTATOR")
Trace("")
Trace("  [1]  DNS Recon")
Trace("  [2]  Port Scan")
Trace("  [3]  Web Analysis")
Trace("  [4]  OSINT Lookup")
Trace("  [0]  Exit")
Trace("")

choice = Capture("  Choose: ")

match choice {
  "1" => {
    t = Capture("  Target: ")
    banner("DNS RECON")
    do --> Recon(t)
  }
  "2" => {
    t = Capture("  Target: ")
    banner("PORT SCAN")
    do --> PortScan(t, 1, 1024)
  }
  "3" => {
    t = Capture("  Target URL: ")
    banner("WEB ANALYSIS")
    do --> HeaderAudit(t)
  }
  "4" => {
    t = Capture("  Target: ")
    banner("OSINT")
    do --> WHOIs(t)
    do --> GeoIP(t)
  }
  "0" => {
    Trace(colorize("  Goodbye.", "dim"))
  }
  _ => {
    Trace(colorize("  Invalid choice.", "red"))
  }
}
```

---

## Pipeline Utilities

Process and transform lists of data.

### tally — Count Occurrences

```spectator
severities = ["HIGH", "MEDIUM", "HIGH", "CRITICAL", "LOW", "HIGH", "MEDIUM"]
counts = tally(severities)
Trace(str(counts))
## {"CRITICAL":1,"HIGH":3,"LOW":1,"MEDIUM":2}

each count, sev : counts {
  Trace("  " --> sev --> ": " --> str(count))
}
```

### sortList — Sort a List

```spectator
tools = ["nmap", "burp", "nikto", "gobuster", "sqlmap"]
Trace(str(sortList(tools)))
## [burp, gobuster, nikto, nmap, sqlmap]
```

### diff — Items in One List but Not Another

```spectator
all_ports  = [21, 22, 80, 443, 3306, 3389, 8080]
open_ports = [80, 443, 8080]
closed     = diff(all_ports, open_ports)
Trace(str(closed))   ## [21, 22, 3306, 3389]
```

### intersect — Items in Both Lists

```spectator
scan1 = ["nmap", "burp", "nikto", "sqlmap"]
scan2 = ["burp", "sqlmap", "hydra"]
both  = intersect(scan1, scan2)
Trace(str(both))   ## [burp, sqlmap]
```

### gather — Flatten List of Lists

```spectator
dns_results = [["8.8.8.8", "8.8.4.4"], ["1.1.1.1"], ["9.9.9.9", "149.112.112.112"]]
all_ips     = gather(dns_results)
Trace(str(all_ips))
## [8.8.8.8, 8.8.4.4, 1.1.1.1, 9.9.9.9, 149.112.112.112]
```

---

## Display Formatting

### truncate — Shorten Long Strings

```spectator
long_txt = "This is a very long Content-Security-Policy header value"
Trace(truncate(long_txt, 30))
## "This is a very long Content-S..."
```

### pad — Fixed-Width Columns

```spectator
## Right-pad strings for aligned output
Trace(pad("Port",    8) --> pad("Service", 12) --> "Status")
Trace(pad("80",      8) --> pad("HTTP",    12) --> "OPEN")
Trace(pad("443",     8) --> pad("HTTPS",   12) --> "OPEN")
Trace(pad("3306",    8) --> pad("MySQL",   12) --> "OPEN")
```

**Output:**
```
Port    Service     Status
80      HTTP        OPEN
443     HTTPS       OPEN
3306    MySQL       OPEN
```

### colorize + pad Combined

```spectator
func print_finding(sev, title) {
  sev_col = match sev {
    "CRITICAL" => colorize(pad(sev, 10), "red")
    "HIGH"     => colorize(pad(sev, 10), "red")
    "MEDIUM"   => colorize(pad(sev, 10), "yellow")
    "LOW"      => colorize(pad(sev, 10), "cyan")
    _          => colorize(pad(sev, 10), "dim")
  }
  Trace("  " --> sev_col --> title)
}
```

---

## Full Example

A complete terminal pentest script using all TUI features:

```spectator
## ─────────────────────────────────────────────────
##  Ghost Terminal — TUI Pentest Script
## ─────────────────────────────────────────────────

banner("GHOST TERMINAL")
Trace(colorize("  Spectator v2.0.0  —  See Everything. Miss Nothing.", "dim"))
Trace("")

## Get target
target = Capture("  Target (domain or IP): ")
if target == "" {
  Trace(colorize("  [!] No target provided.", "red"))
}

Trace("")
banner("PHASE 1: DNS RECON")

## DNS
Trace(colorize("  [ A Records ]", "cyan"))
try {
  ips = resolve(target)
  if len(ips) == 0 {
    Trace(colorize("    Could not resolve " --> target, "red"))
  } else {
    each ip : ips { Trace("    " --> ip) }
  }
} catch e {
  Trace(colorize("    Error: " --> e, "red"))
}

Trace("")
Trace(colorize("  [ MX Records ]", "cyan"))
try {
  mxs = lookupMX(target)
  if len(mxs) == 0 { Trace("    (none)") }
  else { each mx : mxs { Trace("    " --> mx) } }
} catch e { Trace("    " --> e) }

Trace("")
banner("PHASE 2: PORT SCAN")

top_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 8080, 8443]
svcs      = portServices()
open_rows = []

each p, idx : top_ports {
  progress(idx + 1, len(top_ports), "Scanning port " --> str(p))
  try {
    if hasPort(target, p) {
      open_rows = append(open_rows, [str(p), svcs[str(p)], colorize("OPEN", "green")])
    }
  } catch e {}
}

Trace("")
if len(open_rows) > 0 {
  table(["Port", "Service", "Status"], open_rows)
} else {
  Trace(colorize("  No common ports open.", "dim"))
}

Trace("")
banner("PHASE 3: WEB ANALYSIS")

try {
  resp  = http("GET", "https://" --> target, {"timeout": 8000, "follow": true})
  code  = httpStatus(resp)
  body  = httpBody(resp)

  Trace("  Status  : " --> colorize(str(code), "green"))
  Trace("  Title   : " --> extractTitle(body))
  Trace("  Server  : " --> httpHeader(resp, "server"))
  Trace("")

  ## Security headers
  Trace(colorize("  [ Security Headers ]", "cyan"))
  sec_headers = [
    ["strict-transport-security", "HSTS"],
    ["content-security-policy",   "CSP"],
    ["x-frame-options",           "X-Frame"],
    ["x-content-type-options",    "XCTO"],
    ["referrer-policy",           "Referer"]
  ]
  score = 0
  each h : sec_headers {
    val = httpHeader(resp, h[0])
    if val != "" {
      Trace("  " --> colorize("[PASS]", "green") --> "  " --> h[1])
      score += 1
    } else {
      Trace("  " --> colorize("[FAIL]", "red") --> "  " --> h[1] --> " missing")
    }
  }
  Trace("")
  pct = score * 100 / len(sec_headers)
  Trace("  Security score: " --> str(score) --> "/" --> str(len(sec_headers)) --> " (" --> str(pct) --> "%%)")

} catch e {
  Trace(colorize("  HTTPS unavailable: " --> e, "yellow"))
}

Trace("")
banner("SCAN COMPLETE")
Trace(colorize("  Target  : " --> target, "cyan"))
Trace(colorize("  Time    : " --> timestamp(), "dim"))
Trace("")
```
