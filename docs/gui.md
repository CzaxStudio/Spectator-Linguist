# Spectator — GUI Framework

> Build real desktop security tools with a native window and HTML/CSS UI.
> Works on Windows, Linux, and macOS.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Window Options](#window-options)
- [Widgets](#widgets)
- [Layout](#layout)
- [Events](#events)
- [Runtime Control](#runtime-control)
- [Dialogs & Notifications](#dialogs--notifications)
- [Theming](#theming)
- [Platform Notes](#platform-notes)
- [Full Example](#full-example)

---

## Quick Start

The absolute minimum to open a window:

```spectator
#Import Spec.GUI

open.window()
end()
```

Opens a dark window titled `MyApp`. That's it.

---

## Window Options

Customise the window with `open.window(opts)`:

```spectator
#Import Spec.GUI

open.window({
  "title":     "Ghost Recon",    ## window title      (default: "MyApp")
  "width":     1200,             ## width in pixels   (default: 900)
  "height":    800,              ## height in pixels  (default: 600)
  "bg":        "#070b14",        ## background color  (default: "#0a0f1a")
  "accent":    "#00d4aa",        ## accent color      (default: "#38bdf8")
  "text":      "#e2e8f0",        ## text color        (default: "#cbd5e1")
  "font":      "Segoe UI",       ## font family       (default: "Segoe UI")
  "radius":    "6",              ## border radius px  (default: "8")
  "padding":   "24",             ## page padding px   (default: "24")
  "resizable": true,             ## allow resize      (default: true)
  "scrollbar": true,             ## show scrollbar    (default: true)
  "css":       ".g-btn { text-transform: uppercase; }"  ## custom CSS
})
```

---

## Widgets

All widgets are added between `open.window()` and `end()`.

### Label

```spectator
GUI.label("Hello World")

## With options
GUI.label("Bold Title", {
  "size":   24,
  "color":  "#38bdf8",
  "bold":   true,
  "italic": false,
  "align":  "center",      ## "left" / "center" / "right"
  "margin": "8px 0",
  "id":     "my_label"     ## optional — for GUI.set() later
})
```

### Input

```spectator
GUI.input("my_input", "Placeholder text...")

## With options
GUI.input("my_input", "Enter target...", {
  "width":     "60%%",
  "value":     "default value",
  "multiline": false,
  "rows":      4,           ## only when multiline: true
  "disabled":  false
})

## Multiline
GUI.input("notes", "Enter notes...", {"multiline": true, "rows": 6})
```

### Password

```spectator
GUI.password("my_pass", "Enter password...")
```

### Number

```spectator
GUI.number("port_num", "Port", {
  "min":   "1",
  "max":   "65535",
  "step":  "1",
  "value": "80"
})
```

### Button

```spectator
GUI.button("Run Scan", "run_event", {
  "color":     "#00d4aa",     ## background color
  "textColor": "#070b14",     ## text color
  "width":     "200px",
  "size":      "sm",          ## "sm" / "" (normal) / "lg"
  "icon":      "▶",           ## optional icon before text
  "outline":   false,         ## outlined style
  "disabled":  false
})
```

### Icon Button

```spectator
GUI.iconButton("🔍", "search_event", {
  "color": "#38bdf8",
  "size":  "22px"
})
```

### Link Button

```spectator
GUI.link("Click here", "link_event", {"color": "#38bdf8"})
```

### Checkbox

```spectator
GUI.checkbox("verbose_mode", "Enable verbose output", {
  "checked": false,
  "color":   "#e2e8f0"
})
```

### Toggle

```spectator
GUI.toggle("dark_mode", "Dark Mode", {
  "checked": true,
  "color":   "#e2e8f0"
})
```

### Radio

```spectator
GUI.radio("scan_type_fast",   "scan_type", "Fast scan",   "fast",   {"checked": true})
GUI.radio("scan_type_full",   "scan_type", "Full scan",   "full",   {})
GUI.radio("scan_type_stealth","scan_type", "Stealth scan","stealth",{})
```

### Dropdown

```spectator
GUI.dropdown("protocol", ["HTTP", "HTTPS", "FTP", "SSH"], {
  "width":       "200px",
  "placeholder": "Select protocol..."
})
```

### Slider

```spectator
GUI.slider("timeout", 1, 30, {
  "showValue": true,
  "step":      "1",
  "color":     "#00d4aa",
  "width":     "80%%"
})
```

### Output Box

```spectator
GUI.output("scan_results", {
  "height": 400,
  "bg":     "#020610",
  "color":  "#94a3b8"
})
```

### Progress Bar

```spectator
GUI.progress("scan_bar", {
  "color":  "#00d4aa",
  "bg":     "#0f172a",
  "height": 8,
  "label":  "Scanning..."
})
```

### Spinner

```spectator
GUI.spinner("loading_spin")
```

### Table

```spectator
GUI.table("results_table",
  ["Port", "Service", "Status", "Risk"],
  [
    ["80",  "HTTP",  "OPEN", "LOW"],
    ["443", "HTTPS", "OPEN", "LOW"],
    ["22",  "SSH",   "OPEN", "MEDIUM"]
  ],
  {
    "striped": true,
    "height":  300
  }
)
```

### Image

```spectator
GUI.image("logo.png", {
  "width":  "120px",
  "height": "auto",
  "radius": "8"
})
```

### Badge

```spectator
GUI.badge("CRITICAL", {"bg": "#ef4444", "color": "#fff"})
GUI.badge("HIGH",     {"bg": "#f97316"})
GUI.badge("MEDIUM",   {"bg": "#f59e0b", "color": "#000"})
GUI.badge("LOW",      {"bg": "#3b82f6"})
GUI.badge("INFO",     {"bg": "#22c55e"})
```

### Alert Box

```spectator
GUI.alert_box("Scan complete — 3 findings",  {"type": "success"})
GUI.alert_box("HSTS header missing",          {"type": "warning"})
GUI.alert_box("Connection refused",           {"type": "error"})
GUI.alert_box("Target is running Nginx 1.24", {"type": "info"})
```

### Code Block

```spectator
GUI.code("SELECT * FROM users WHERE id='1' OR '1'='1'", {
  "height": 120,
  "bg":     "#020610"
})
```

### Divider

```spectator
GUI.divider()

## With options
GUI.divider({
  "color":  "#1e293b",
  "margin": "16px 0"
})

## With label
GUI.divider({"text": "Results", "color": "#475569"})
```

### Space

```spectator
GUI.space(16)   ## 16px vertical gap
```

### Raw HTML

```spectator
GUI.html("<div style='color:#ef4444;font-size:20px'>⚠ Warning</div>")
```

---

## Layout

### Row (Horizontal)

```spectator
GUI.rowStart()
GUI.input("host", "Host...", {"width": "60%%"})
GUI.number("port", "Port",   {"width": "15%%", "value": "80"})
GUI.button("Go", "scan", {})
GUI.rowEnd()

## With options
GUI.rowStart({"gap": "12px", "align": "flex-start", "justify": "space-between"})
```

### Column (Vertical)

```spectator
GUI.rowStart()

GUI.colStart({"width": "49%%"})
GUI.label("Left Column")
GUI.input("input_a", "Field A")
GUI.colEnd()

GUI.colStart({"width": "49%%"})
GUI.label("Right Column")
GUI.input("input_b", "Field B")
GUI.colEnd()

GUI.rowEnd()
```

### Card

```spectator
GUI.card("Section Title", {
  "bg":      "#0f172a",
  "border":  "#1e293b",
  "radius":  "10",
  "padding": "20",
  "accent":  true,      ## adds left accent border
  "id":      "my_card"
})
GUI.label("Content inside the card")
GUI.input("card_input", "Enter value...")
GUI.cardEnd()
```

### Tabs

```spectator
GUI.tabs(["Scanner", "Payloads", "Report"])

GUI.tabPanel("Scanner", {"active": true})
GUI.label("Scanner content here")
GUI.tabPanelEnd()

GUI.tabPanel("Payloads", {})
GUI.label("Payloads content here")
GUI.tabPanelEnd()

GUI.tabPanel("Report", {})
GUI.label("Report content here")
GUI.tabPanelEnd()

## Switch tab programmatically
GUI.openTab("Payloads")
```

### Sidebar

```spectator
GUI.sidebar([
  {"id": "scan",   "label": "Scanner",  "icon": "⌖"},
  {"id": "recon",  "label": "Recon",    "icon": "◎"},
  {"id": "report", "label": "Report",   "icon": "✦"}
])

## Content for each sidebar section goes here
## (use tabPanels inside the sidebar main area)

GUI.sidebarEnd()
```

### Header / Footer

```spectator
GUI.header("Ghost Recon", {
  "subtitle": "Professional Pentest Suite",
  "logo":     "logo.png",
  "bg":       "#0a0f1a",
  "color":    "#e2e8f0"
})

## ... page content ...

GUI.footer("Spectator v2.0.0  ·  Authorized use only")
```

---

## Events

Bind a function to a button or sidebar item with `GUI.on`:

```spectator
GUI.on("run_scan", func() {
  target = GUI.get("target_input")
  GUI.clear("output_box")
  GUI.print("output_box", "Scanning " --> target --> "...")

  ## Do actual work
  ips = resolve(target)
  each ip : ips {
    GUI.print("output_box", "  IP: " --> ip)
  }

  GUI.setProgress("scan_bar", 1.0)
  GUI.print("output_box", "Done.")
})
```

### Sidebar Navigation Events

```spectator
GUI.on("sidebar:scan",   func() { GUI.eval("_sOpenTab('scan','default')")   })
GUI.on("sidebar:recon",  func() { GUI.eval("_sOpenTab('recon','default')")  })
GUI.on("sidebar:report", func() { GUI.eval("_sOpenTab('report','default')") })
```

---

## Runtime Control

### Reading & Writing Values

```spectator
## Read any widget value
target   = GUI.get("target_input")    ## text input → string
checked  = GUI.get("verbose_chk")     ## checkbox → "true"/"false"
selected = GUI.get("protocol_drop")   ## dropdown → selected option
sliderv  = GUI.get("timeout_slider")  ## slider → number as string

## Write a value
GUI.set("target_input", "scanme.nmap.org")
GUI.set("status_label", "Scanning...")
```

### Output Box

```spectator
GUI.print("out", "Line of output")    ## append a line
GUI.clear("out")                       ## clear all content
```

### Progress Bar

```spectator
GUI.setProgress("bar", 0.0)    ## empty
GUI.setProgress("bar", 0.5)    ## 50%
GUI.setProgress("bar", 1.0)    ## full
```

### Spinner

```spectator
GUI.showSpinner("loading")
## ... do work ...
GUI.hideSpinner("loading")
```

### Show / Hide / Enable / Disable

```spectator
GUI.hide("advanced_section")
GUI.show("advanced_section")
GUI.disable("run_button")
GUI.enable("run_button")
GUI.focus("target_input")
```

### Table at Runtime

```spectator
## Add a row
GUI.appendRow("results_table", ["22", "SSH", "OPEN", "MEDIUM"])

## Clear all rows
GUI.clearTable("results_table")
```

### Window Title

```spectator
GUI.setTitle("Scanning: target.com")
GUI.setTitle("Ghost Recon")   ## reset
```

### CSS at Runtime

```spectator
GUI.css(".g-output", "fontSize", "11px")
GUI.addClass("my_card", "g-card-accent")
GUI.removeClass("my_card", "hidden")
```

### Raw JavaScript

```spectator
GUI.eval("document.title = 'Custom Title'")
GUI.eval("document.body.style.cursor = 'wait'")
```

---

## Dialogs & Notifications

### Alert Dialog

```spectator
GUI.alert("Scan complete — 5 findings.")
```

### Confirm Dialog

Returns `true` or `false`:

```spectator
ok = GUI.confirm("Clear all findings?")
if ok {
  GUI.clearTable("findings_table")
}
```

### Desktop Notification

```spectator
GUI.notify("Ghost Recon", "Scan finished for target.com")
```

---

## Theming

### Change at Build Time (open.window)

```spectator
open.window({
  "bg":     "#0d0a1a",   ## deep purple-black
  "accent": "#a855f7"    ## purple accent
})
```

### Change at Runtime

```spectator
## Background themes
GUI.on("theme_dark",   func() { GUI.setBg("#070b14") })
GUI.on("theme_blue",   func() { GUI.setBg("#0c1a2e") })
GUI.on("theme_purple", func() { GUI.setBg("#0d0a1a") })
GUI.on("theme_black",  func() { GUI.setBg("#000000") })

## Accent colors
GUI.on("accent_teal",   func() { GUI.setAccent("#00d4aa") })
GUI.on("accent_cyan",   func() { GUI.setAccent("#38bdf8") })
GUI.on("accent_purple", func() { GUI.setAccent("#a855f7") })
GUI.on("accent_green",  func() { GUI.setAccent("#22c55e") })
GUI.on("accent_orange", func() { GUI.setAccent("#f97316") })
```

### Custom CSS

Inject any CSS at build time:

```spectator
open.window({
  "css": "
    .g-btn { text-transform: uppercase; letter-spacing: .1em; }
    .g-output { font-size: 11px; }
    .g-sidebar { width: 180px; }
  "
})
```

---

## Platform Notes

| Platform | Engine | Requirement |
|----------|--------|-------------|
| Windows 10/11 | WebView2 | Pre-installed — nothing needed |
| Linux | WebKitGTK | `libgtk-3-dev libwebkit2gtk-4.0-dev` |
| macOS | WKWebView | Pre-installed — nothing needed |

**Building with GUI:**

```bash
# Windows
go build -tags gui -ldflags="-s -w" -o Spectator.exe .

# Linux (native, CGO required)
go build -tags gui -ldflags="-s -w" -o spectator .

# macOS (native, CGO required)
go build -tags gui -ldflags="-s -w" -o spectator .
```

> **Note:** GUI builds for Linux and macOS must be compiled natively on those platforms (CGO does not cross-compile). Use GitHub Actions for automated cross-platform builds.

---

## Full Example

```spectator
#Import Spec.GUI

open.window({
  "title":   "Port Scanner",
  "width":   900,
  "height":  600,
  "bg":      "#070b14",
  "accent":  "#00d4aa",
  "padding": "0"
})

GUI.header("Port Scanner", {"subtitle": "Check open ports on any host"})

GUI.rowStart()
GUI.input("target", "Enter target host...", {"width": "70%%"})
GUI.button("Scan", "run_scan", {"color": "#00d4aa", "textColor": "#070b14"})
GUI.button("Clear", "clear", {"color": "#1e293b"})
GUI.rowEnd()

GUI.space(10)
GUI.progress("bar", {"color": "#00d4aa", "height": 6})
GUI.space(8)
GUI.output("out", {"height": 380, "bg": "#020610"})
GUI.footer("Spectator v2.0.0  ·  For authorized use only")

GUI.on("clear", func() {
  GUI.clear("out")
  GUI.setProgress("bar", 0)
  GUI.setTitle("Port Scanner")
})

GUI.on("run_scan", func() {
  target = GUI.get("target")
  if target == "" {
    GUI.alert("Please enter a target.")
    return
  }

  GUI.clear("out")
  GUI.setTitle("Scanning: " --> target)
  GUI.print("out", "Scanning " --> target --> "...")
  GUI.print("out", "")

  top20 = [21,22,23,25,53,80,110,143,443,445,3306,3389,5432,6379,8080,8443,8888,9200,27017,11211]
  svcs  = portServices()
  found = 0

  each port, idx : top20 {
    GUI.setProgress("bar", (idx + 1) / len(top20))
    try {
      if hasPort(target, port) {
        GUI.print("out", "  OPEN  " --> str(port) --> "  " --> svcs[str(port)])
        found += 1
      }
    } catch e {}
  }

  GUI.print("out", "")
  GUI.print("out", str(found) --> " open port(s) found.")
  GUI.setProgress("bar", 1.0)
  GUI.setTitle("Port Scanner")
  GUI.notify("Scan Complete", str(found) --> " open ports on " --> target)
})

end()
```
