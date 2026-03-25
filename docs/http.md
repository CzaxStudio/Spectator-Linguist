# HTTP Engine

Spectator includes a built-in HTTP client.

## Basic Request

```spectator
resp = http("GET", "https://example.com", {"timeout": 5000})
```

## Response Data

```spectator
httpStatus(resp)
httpHeader(resp, "server")
httpBody(resp)
```

## Extraction

```spectator
extractTitle(body)
extractEmails(body)
```
