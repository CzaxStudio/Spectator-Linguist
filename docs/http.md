# Spectator — HTTP Engine

> Full HTTP client built into Spectator. No imports needed.

---

## Table of Contents

- [Basic Requests](#basic-requests)
- [Request Options](#request-options)
- [Reading Responses](#reading-responses)
- [Sessions](#sessions)
- [Content Extraction](#content-extraction)
- [URL Utilities](#url-utilities)
- [Downloading Files](#downloading-files)
- [Fuzzing](#fuzzing)
- [Multi-Request](#multi-request)

---

## Basic Requests

```spectator
## GET
resp = http("GET", "https://target.com", {})

## POST
resp = http("POST", "https://target.com/login", {
  "body": "username=admin&password=test"
})

## POST JSON
resp = http("POST", "https://api.target.com/v1/users", {
  "body":    "{\"username\":\"admin\"}",
  "headers": {"Content-Type": "application/json"}
})

## PUT / PATCH / DELETE
resp = http("PUT",    "https://target.com/api/item/1", {"body": "data"})
resp = http("PATCH",  "https://target.com/api/item/1", {"body": "data"})
resp = http("DELETE", "https://target.com/api/item/1", {})

## HEAD — headers only, no body
resp = http("HEAD", "https://target.com", {})

## OPTIONS — CORS preflight
resp = http("OPTIONS", "https://target.com/api", {})
```

---

## Request Options

All options are passed as a map in the third argument:

```spectator
resp = http("GET", "https://target.com", {
  "timeout":  10000,                        ## ms (default: 10000)
  "follow":   true,                         ## follow redirects (default: false)
  "agent":    "Mozilla/5.0 (Windows NT)",   ## User-Agent string
  "headers":  {                             ## custom headers
    "Authorization": "Bearer token123",
    "X-Custom":      "value"
  },
  "body":     "raw body string",            ## request body
  "proxy":    "http://127.0.0.1:8080",      ## proxy (e.g. Burp Suite)
  "insecure": true                          ## skip TLS verification
})
```

### Using Burp Suite as Proxy

```spectator
resp = http("GET", "https://target.com", {
  "proxy":    "http://127.0.0.1:8080",
  "insecure": true
})
```

---

## Reading Responses

```spectator
resp = http("GET", "https://target.com", {"follow": true})

## Status code
code = httpStatus(resp)        ## 200
Trace(str(code))

## Body
body = httpBody(resp)
Trace(body)

## Single header (lowercase key)
server = httpHeader(resp, "server")
ct     = httpHeader(resp, "content-type")
hsts   = httpHeader(resp, "strict-transport-security")

## Check redirect
if isRedirect(code) {
  Trace("Redirected!")
}
```

---

## Sessions

Sessions maintain cookies and state across multiple requests — essential for authenticated testing.

```spectator
## Create a session
sess = httpSession()

## Configure session defaults
httpSessionSet(sess, "agent",   "Mozilla/5.0")
httpSessionSet(sess, "timeout", 15000)
httpSessionSet(sess, "proxy",   "http://127.0.0.1:8080")

## Login — cookies are stored automatically
login = httpSessionPost(sess, "https://target.com/login", {
  "body": "username=admin&password=hunter2"
})
Trace("Login: " --> str(httpStatus(login)))

## Subsequent requests use the session cookies
dashboard = httpSessionGet(sess, "https://target.com/dashboard", {})
Trace("Dashboard: " --> str(httpStatus(dashboard)))

profile = httpSessionGet(sess, "https://target.com/profile", {})
body    = httpBody(profile)

## Custom request on session
resp = httpSessionDo(sess, "PUT", "https://target.com/api/user", {
  "body":    "{\"role\":\"admin\"}",
  "headers": {"Content-Type": "application/json"}
})

## Close when done
httpSessionClose(sess)
```

---

## Content Extraction

Extract structured data from HTML responses:

```spectator
resp = http("GET", "https://target.com", {"follow": true, "agent": "Mozilla/5.0"})
body = httpBody(resp)

## Page title
title = extractTitle(body)
Trace(title)

## All links on the page
links = extractLinks(body, "https://target.com")
each link : links {
  Trace(link)
}

## All forms
forms = extractForms(body)
each form : forms {
  Trace(str(form))
}

## All email addresses
emails = extractEmails(body)
each email : emails {
  Trace(email)
}

## Meta tags
meta = extractMeta(body)
Trace(str(meta))

## Strip HTML tags
plain = stripHTML(body)
Trace(truncate(plain, 200))
```

---

## URL Utilities

```spectator
## Build a query string
q = buildQuery({"user": "admin", "page": "1", "limit": "50"})
Trace(q)   ## "limit=50&page=1&user=admin"

## Parse a query string
params = parseQuery("user=admin&page=1&limit=50")
Trace(params["user"])   ## "admin"

## Build a full URL
url = buildURL("https://api.target.com", {
  "path":  "/v2/users",
  "query": {"role": "admin", "active": "true"}
})
Trace(url)   ## "https://api.target.com/v2/users?active=true&role=admin"
```

---

## Downloading Files

```spectator
## Download a file to disk
err = httpDownload("https://target.com/file.zip", "/tmp/file.zip")
if err == "" {
  Trace("Downloaded successfully")
} else {
  Trace("Error: " --> err)
}
```

---

## Fuzzing

```spectator
## Fuzz URL parameters
results = httpFuzz("https://target.com/page?id=FUZZ", {
  "wordlist": ["1", "2", "admin", "../etc/passwd", "' OR 1=1--"],
  "timeout":  5000,
  "filter":   "status:200"   ## only show 200 responses
})
each r : results {
  Trace(str(r))
}

## Brute force login
results = httpBrute("https://target.com/login", {
  "method":   "POST",
  "body":     "username=admin&password=FUZZ",
  "wordlist": ["password", "admin", "123456", "hunter2"],
  "stop_on":  "Welcome"   ## stop when response contains this
})
each r : results {
  Trace(str(r))
}
```

---

## Multi-Request

Send multiple requests concurrently:

```spectator
targets = [
  "https://target1.com",
  "https://target2.com",
  "https://target3.com"
]

results = httpMulti(targets, {
  "method":  "GET",
  "timeout": 5000,
  "threads": 10
})

each r : results {
  Trace(r["url"] --> " → " --> str(r["status"]))
}
```

---

## Real-World Examples

### Security Header Audit

```spectator
url  = "https://target.com"
resp = http("GET", url, {"follow": true, "timeout": 10000})
code = httpStatus(resp)

Trace("URL    : " --> url)
Trace("Status : " --> str(code))
Trace("")

security_headers = [
  "strict-transport-security",
  "content-security-policy",
  "x-frame-options",
  "x-content-type-options",
  "referrer-policy",
  "permissions-policy"
]

score = 0
each h : security_headers {
  val = httpHeader(resp, h)
  if val != "" {
    Trace("[PASS] " --> h)
    score += 1
  } else {
    Trace("[FAIL] " --> h --> " — missing")
  }
}

Trace("")
Trace("Score: " --> str(score) --> "/" --> str(len(security_headers)))
```

### Technology Fingerprinting

```spectator
resp = http("GET", "https://target.com", {
  "follow": true,
  "agent":  "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
})
body     = httpBody(resp)
body_low = lower(body)

Trace("Server: " --> httpHeader(resp, "server"))
Trace("Title : " --> extractTitle(body))
Trace("")
Trace("[ Detected Technologies ]")

techs = [
  ["WordPress",  "wp-content"],
  ["Joomla",     "joomla"],
  ["Laravel",    "laravel"],
  ["Django",     "csrfmiddlewaretoken"],
  ["React",      "react"],
  ["Angular",    "ng-version"],
  ["jQuery",     "jquery"],
  ["Bootstrap",  "bootstrap"],
  ["Cloudflare", "cloudflare"],
  ["Nginx",      "nginx"],
  ["Apache",     "apache"]
]

each t : techs {
  if contains(body_low, lower(t[1])) {
    Trace("  [+] " --> t[0])
  }
}
```

### Authenticated API Testing

```spectator
base = "https://api.target.com"
sess = httpSession()
httpSessionSet(sess, "headers", {
  "Authorization": "Bearer eyJhbGc...",
  "Content-Type":  "application/json"
})

## Enumerate users
resp = httpSessionGet(sess, base --> "/v1/users", {})
Trace(str(httpStatus(resp)) --> " — /v1/users")

## Try IDOR
loop 10 {
  id   = _i + 1
  resp = httpSessionGet(sess, base --> "/v1/users/" --> str(id), {})
  code = httpStatus(resp)
  if code == 200 {
    Trace("[IDOR] User " --> str(id) --> " accessible")
  }
}

httpSessionClose(sess)
```
