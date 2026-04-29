# SOLID Principles in Java

SOLID is an acronym for five object-oriented design principles that help developers write clean, maintainable, and scalable code. Each letter represents one principle.

---

## S — Single Responsibility Principle (SRP)

> *"A class should have only one reason to change."*

A class or method should do **one thing** and do it well. If a class or method handles multiple responsibilities, changes to one may break the other.

### ❌ Wrong
```java
class UserService {
    public void createUser(String name) { /* ... */ }
    public void sendWelcomeEmail(String email) { /* ... */ } // Not UserService's job
    public void saveToDatabase(User user) { /* ... */ }       // Not UserService's job
}
```

### ✅ Correct
```java
class UserService {
    public void createUser(String name) { /* ... */ }
}

class EmailService {
    public void sendWelcomeEmail(String email) { /* ... */ }
}

class UserRepository {
    public void save(User user) { /* ... */ }
}
```

---

## O — Open/Closed Principle (OCP)

> *"Software entities should be open for extension, but closed for modification."*

You should be able to **add new behavior** without changing existing code. Use abstraction (interfaces/abstract classes) to achieve this.

### ❌ Wrong
```java
class DiscountCalculator {
    public double calculate(String customerType, double price) {
        if (customerType.equals("VIP")) return price * 0.8;
        if (customerType.equals("Member")) return price * 0.9;
        return price; // Adding a new type requires modifying this class
    }
}
```

### ✅ Correct
```java
interface DiscountStrategy {
    double apply(double price);
}

class VipDiscount implements DiscountStrategy {
    public double apply(double price) { return price * 0.8; }
}

class MemberDiscount implements DiscountStrategy {
    public double apply(double price) { return price * 0.9; }
}

class DiscountCalculator {
    public double calculate(DiscountStrategy strategy, double price) {
        return strategy.apply(price); // No modification needed to add new types
    }
}
```

---

## L — Liskov Substitution Principle (LSP)

> *"Objects of a subclass should be replaceable with objects of the superclass without breaking the application."*

In other words: if class `B` extends class `A`, you should be able to use `B` anywhere `A` is expected and the program must still behave correctly. A subclass must **honor the contract** of its parent — same expected inputs, same expected behavior.

### Classic example: Rectangle and Square

At first glance, it seems logical that a `Square` extends `Rectangle` (a square *is* a rectangle mathematically). But in code, this breaks LSP:

### ❌ Wrong
```java
class Rectangle {
    protected int width;
    protected int height;

    public void setWidth(int width)   { this.width = width; }
    public void setHeight(int height) { this.height = height; }

    public int getArea() { return width * height; }
}

class Square extends Rectangle {
    // A square must keep width == height at all times
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width; // Forces height to match
    }

    @Override
    public void setHeight(int height) {
        this.height = height;
        this.width = height; // Forces width to match
    }
}

// This method works fine with Rectangle...
public void resize(Rectangle r) {
    r.setWidth(5);
    r.setHeight(10);
    System.out.println(r.getArea()); // Expected: 50
}

// ...but breaks when a Square is passed
resize(new Rectangle()); // prints 50 ✅
resize(new Square());    // prints 100 ❌ — setHeight changed the width too!
```

The `Square` silently changed the behavior of `setWidth` and `setHeight`, so substituting it for a `Rectangle` produces unexpected results. **LSP is violated.**

### ✅ Correct
```java
// Remove the inheritance. Use a shared abstraction instead.
interface Shape {
    int getArea();
}

class Rectangle implements Shape {
    private int width;
    private int height;

    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }

    public int getArea() { return width * height; }
}

class Square implements Shape {
    private int side;

    public Square(int side) {
        this.side = side;
    }

    public int getArea() { return side * side; }
}

// Both can be used through the Shape interface safely
public void printArea(Shape shape) {
    System.out.println("Area: " + shape.getArea());
}

printArea(new Rectangle(5, 10)); // Area: 50 ✅
printArea(new Square(5));        // Area: 25 ✅
```

Now each class is independent, has its own consistent behavior, and neither breaks the other's contract.


### ✅ Correct
```java
interface Bird {
    void eat();
}

interface FlyingBird extends Bird {
    void fly();
}

class Eagle implements FlyingBird {
    public void eat() { /* ... */ }
    public void fly() { System.out.println("Eagle flying!"); }
}

class Penguin implements Bird {
    public void eat() { /* ... */ } // No fly() — no broken contract
}
```

---

## I — Interface Segregation Principle (ISP)

> *"Clients should not be forced to depend on interfaces they do not use."*

It's better to have **small, specific interfaces** over large, general-purpose ones. No class should be forced to implement methods it doesn't need.

### ❌ Wrong
```java
interface Worker {
    void work();
    void eat();  // Robots don't eat — forced to implement this anyway
}

class Robot implements Worker {
    public void work() { System.out.println("Working..."); }
    public void eat() { /* Robots don't eat — empty or throws exception */ }
}
```

### ✅ Correct
```java
interface Workable {
    void work();
}

interface Eatable {
    void eat();
}

class Human implements Workable, Eatable {
    public void work() { System.out.println("Working..."); }
    public void eat()  { System.out.println("Eating..."); }
}

class Robot implements Workable {
    public void work() { System.out.println("Working..."); }
    // No need to implement eat()
}
```

---

## D — Dependency Inversion Principle (DIP)

> *"High-level modules should not depend on low-level modules. Both should depend on abstractions."*

Classes should depend on **interfaces or abstract classes**, not on concrete implementations. This makes your code flexible and easy to test.

### ❌ Wrong
```java
class MySQLDatabase {
    public void save(String data) { System.out.println("Saving to MySQL..."); }
}

class UserService {
    private MySQLDatabase db = new MySQLDatabase(); // Tightly coupled to MySQL

    public void saveUser(String data) { db.save(data); }
}
```

### ✅ Correct
```java
interface Database {
    void save(String data);
}

class MySQLDatabase implements Database {
    public void save(String data) { System.out.println("Saving to MySQL..."); }
}

class MongoDatabase implements Database {
    public void save(String data) { System.out.println("Saving to MongoDB..."); }
}

class UserService {
    private final Database db;

    // Dependency is injected — not hardcoded
    public UserService(Database db) { this.db = db; }

    public void saveUser(String data) { db.save(data); }
}

// Usage
Database db = new MySQLDatabase(); // or new MongoDatabase()
UserService service = new UserService(db);
```

---

## Summary Table

| Letter | Principle | Core Idea |
|--------|-----------|-----------|
| **S** | Single Responsibility | One class, one job |
| **O** | Open/Closed | Extend without modifying |
| **L** | Liskov Substitution | Subclasses must honor parent contracts |
| **I** | Interface Segregation | Small, focused interfaces |
| **D** | Dependency Inversion | Depend on abstractions, not concretions |

---

> Applying SOLID principles leads to code that is easier to **test**, **maintain**, **extend**, and **understand** — the hallmarks of professional software design.
