# GUI Framework

Spectator supports native GUI apps.

## Create Window

```spectator
open.window({"title": "My Tool"})
```

## Widgets

```spectator
GUI.input("target", "Enter target...")
GUI.button("Run", "run")
GUI.output("out")
```

## Events

```spectator
GUI.on("run", func() {
  Trace("Clicked")
})
```

## End GUI

```spectator
end()
```
