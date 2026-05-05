# Software Testing Notes

## Types of Testing

### Test Suite
A **test suite** is a bundle of multiple unit test cases that can be run together.

### Unit Testing
Testing a **single, isolated unit** of the software (e.g., a method or class).

### Integration Testing
Testing a **few units separately**, then combining them and testing them together to make sure they work correctly as a group.

### Regression Testing
When a **new module is added** to the software, regression testing checks that the rest of the software still works correctly with the change.

### System Testing
Testing the **complete software as a whole**, focusing on inputs and outputs, and software compatibility across different operating systems. This falls under **black box testing**.

### Stress Testing
Testing the software under **unfavorable conditions**, pushing it to its maximum limit to check if any failures occur.

---

## Unit Testing

**Unit testing** is a strategy that tests single entities like methods or classes one at a time, to ensure the product meets business requirements.

---

## Mocking and Stubbing

- **Mocking** — Creating an object that mimics a real object.
- **Stubbing** — Code that replaces another component with a simplified version.

Popular mocking frameworks in Java: **Mockito**, **EasyMock**.

---

## JUnit

### What is JUnit?
JUnit is a testing framework used mainly by **developers** for unit testing the functionality they write, although testers also use it.

### Important JUnit Annotations

| Annotation | Description |
|---|---|
| `@Test` | Marks a public void method as a test case. |
| `@Before` | Runs **before each** test case (used for setup/initialization). |
| `@BeforeClass` | Runs **once before all** test cases (e.g., opening a DB connection). |
| `@After` | Runs **after each** test case (e.g., resetting variables). |
| `@AfterClass` | Runs **once after all** test cases (e.g., releasing connections). |
| `@Ignore` | Marks statements to be **skipped** during test execution. |
| `@Test(timeout=x)` | Fails the test if it takes longer than `x` milliseconds. |
| `@Test(expected=NullPointerException.class)` | Asserts that the method throws a specific exception. |

---

## Mockito

### What is Mockito?
**Mockito** is an open-source Java mocking framework that creates objects simulating the behavior of real ones. It supports test-driven and behavior-driven development, and removes the need for *expect-run-verify* patterns.

### Advantages of Mockito
- Mocks are created at runtime, so renaming methods or reordering parameters won't break tests.
- Supports returning values and simulating exceptions.
- Verifies the order of method calls.
- Can create mock objects using annotations.

### Why Do We Need Mocking in Unit Testing?
Mocking is needed to **isolate the module under test** from its external dependencies. Use mocking when:

- A dependency is **not fully implemented yet** (e.g., a REST API still in progress).
- The module **changes system state** (e.g., database create/update/delete operations).
- The module **reads from a database** (to avoid risks related to DB availability).

---

## Mock vs Spy

| | Mock | Spy |
|---|---|---|
| Object type | Completely fake object | Real object with some methods stubbed |
| Unstubbed methods | Do nothing / return defaults | Call the **real** method |
| Use case | Full isolation | Partial mocking |

**Spy** is useful when an object has 2 methods and you want one to be mocked and the other to run its real implementation.

---

## thenReturn vs doReturn

Both are used to **set up stubs** in Mockito:

- `when(...).thenReturn(...)` — Most common, better readability.
- `doReturn(...).when(...)` — Alternative syntax, useful in edge cases (e.g., with spies).

---

## @Mock vs @InjectMocks

| Annotation | Purpose |
|---|---|
| `@Mock` | Creates a **mock object** (fake). |
| `@InjectMocks` | Creates a **real object** and injects mocks into it. Use this when you want the actual method body to execute. |

---

## Why Can't We Mock Static Methods in Mockito?

Static methods **belong to the class**, not to any instance, so all objects share the same static method. This makes them behave like procedural code and harder to mock. They are common in legacy systems.

> **Note:** Newer versions of Mockito (3.4+) added limited support for mocking static methods via `mockStatic()`.