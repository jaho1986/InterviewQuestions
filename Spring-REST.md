# Spring REST Study Guide

## What is REST?

**REST** (Representational State Transfer) is an architectural style for building web services that communicate over HTTP. A RESTful API exposes resources (data or functionality) through URLs and uses standard HTTP methods to interact with them.

---

## Core Principles of REST

| Principle              | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| **Stateless**          | Each request contains all the information needed; the server stores no client state |
| **Client-Server**      | The client and server are independent; they communicate through a defined interface |
| **Uniform Interface**  | Resources are identified by URLs and manipulated using standard HTTP methods |
| **Cacheable**          | Responses can be cached to improve performance                              |
| **Layered System**     | The client doesn't need to know if it's talking directly to the server or through intermediaries |

---

## HTTP Methods in REST

| Method   | Action           | Example URL             |
|----------|------------------|-------------------------|
| `GET`    | Retrieve data    | `GET /users/1`          |
| `POST`   | Create a resource | `POST /users`          |
| `PUT`    | Update a resource (full) | `PUT /users/1`  |
| `PATCH`  | Update a resource (partial) | `PATCH /users/1` |
| `DELETE` | Delete a resource | `DELETE /users/1`      |

---

## HTTP Status Codes

| Code  | Meaning                  |
|-------|--------------------------|
| `200` | OK — Request succeeded   |
| `201` | Created — Resource created successfully |
| `204` | No Content — Success, no body returned |
| `400` | Bad Request — Invalid input |
| `401` | Unauthorized — Authentication required |
| `403` | Forbidden — No permission |
| `404` | Not Found — Resource doesn't exist |
| `500` | Internal Server Error    |

---

## Key Annotations

### `@RestController`
Marks a class as a REST controller. It combines `@Controller` and `@ResponseBody`, so every method automatically returns data (JSON/XML) instead of a view.

```java
@RestController
@RequestMapping("/users")
public class UserController { }
```

---

### `@RequestMapping`
Maps HTTP requests to a class or method. You can specify the path and HTTP method.

```java
@RequestMapping(value = "/users", method = RequestMethod.GET)
```

> Shorthand alternatives: `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping`

---

### `@PathVariable`
Extracts a value from the URL path.

```java
@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) { }
```

---

### `@RequestParam`
Extracts a value from the query string.

```java
// GET /users?role=admin
@GetMapping("/users")
public List<User> getUsers(@RequestParam String role) { }
```

---

### `@RequestBody`
Maps the HTTP request body (usually JSON) to a Java object.

```java
@PostMapping("/users")
public User createUser(@RequestBody User user) { }
```

---

### `@ResponseBody`
Tells Spring to serialize the return value directly into the HTTP response body. Already included in `@RestController`.

---

### `@ResponseStatus`
Sets the HTTP status code returned by a method.

```java
@ResponseStatus(HttpStatus.CREATED)
@PostMapping("/users")
public User createUser(@RequestBody User user) { }
```

---

## ResponseEntity

`ResponseEntity` gives you full control over the HTTP response: status code, headers, and body.

```java
@GetMapping("/users/{id}")
public ResponseEntity<User> getUser(@PathVariable Long id) {
    User user = userService.findById(id);
    if (user == null) {
        return ResponseEntity.notFound().build();
    }
    return ResponseEntity.ok(user);
}
```

---

## JSON Serialization with Jackson

Spring uses **Jackson** by default to convert Java objects to JSON and vice versa. No extra configuration is needed — just add the dependency and it works automatically.

Useful Jackson annotations:

| Annotation              | Purpose                                      |
|-------------------------|----------------------------------------------|
| `@JsonProperty("name")` | Renames a field in the JSON output           |
| `@JsonIgnore`           | Excludes a field from serialization          |
| `@JsonFormat`           | Formats dates and numbers in the JSON output |

---

## Exception Handling

### `@ExceptionHandler`
Handles exceptions within a specific controller.

```java
@ExceptionHandler(UserNotFoundException.class)
public ResponseEntity<String> handleNotFound(UserNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
}
```

### `@ControllerAdvice`
Handles exceptions **globally** across all controllers.

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<String> handleNotFound(UserNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
    }
}
```

---

## Content Negotiation

Spring REST can return different formats (JSON, XML) based on the client's request headers.

- The client sends `Accept: application/json` to request JSON.
- The client sends `Accept: application/xml` to request XML.

Spring handles this automatically when the appropriate dependencies are on the classpath.

---

## Validation

Use Bean Validation annotations to validate incoming request bodies.

```java
public class User {
    @NotNull
    @Size(min = 2, max = 50)
    private String name;

    @Email
    private String email;
}
```

Enable validation in the controller with `@Valid`:

```java
@PostMapping("/users")
public User createUser(@Valid @RequestBody User user) { }
```

---

## REST vs SOAP

| Feature       | REST                        | SOAP                        |
|---------------|-----------------------------|-----------------------------|
| Protocol      | HTTP                        | HTTP, SMTP, TCP             |
| Format        | JSON, XML                   | XML only                    |
| Complexity    | Simple                      | Complex                     |
| Performance   | Faster, lightweight         | Heavier                     |
| Standards     | Flexible                    | Strict (WS-* standards)     |

---

## Best Practices

- Use **nouns** in URLs, not verbs → `/users` not `/getUsers`
- Use **plural nouns** for collections → `/users`, `/products`
- Return appropriate **HTTP status codes**
- Version your API → `/api/v1/users`
- Always **validate** incoming data
- Use **HTTPS** to secure your API