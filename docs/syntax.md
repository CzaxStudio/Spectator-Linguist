# Spectator Syntax Guide

## Variables

```spectator
x = 42
name = "Spectator"
flag = true
```

---

## Strings

```spectator
msg = "Hello " --> name
fmsg = f"Hello {name}"
```

---

## Conditions

```spectator
if score >= 90 {
  Trace("A")
} elseif score >= 75 {
  Trace("B")
} else {
  Trace("F")
}
```

---

## Loops

```spectator
loop 5 {
  Trace(_i)
}

each item : list {
  Trace(item)
}
```

---

## Functions

```spectator
func greet(name) {
  Trace("Hello " --> name)
}
```

---

## Error Handling

```spectator
try {
  resp = http("GET", url, {})
} catch e {
  Trace("Error: " --> e)
}
```

---

## Special Operator

```spectator
do --> Recon("example.com")
```
