# Creational Design Patterns in Java

Creational design patterns deal with **how objects are created**. Instead of creating objects directly (using `new`), these patterns give you smarter, more flexible ways to do it.

They help you:
- Control how and when objects are created.
- Make your code easier to change and maintain.
- Avoid repeating object creation logic all over your code.

There are 5 main creational patterns:

| Pattern | One-line summary |
|---------|-----------------|
| **Factory Method** | Let subclasses decide which object to create |
| **Abstract Factory** | Create families of related objects |
| **Builder** | Build complex objects step by step |
| **Prototype** | Create new objects by copying existing ones |
| **Singleton** | Ensure only one instance of a class exists |

---

## 1. Factory Method

### What is it?
The Factory Method pattern defines an interface for creating an object, but lets **subclasses decide which class to instantiate**. Instead of calling `new Dog()` or `new Cat()` directly, you call a method that returns the right object for you.

### What problem does it solve?
When you have code that needs to create objects, but you don't know in advance **which exact type** you'll need. If you hardcode `new Dog()` everywhere, adding a new animal means changing many places in your code.

### When to use it?
- When the type of object to create depends on some condition or input.
- When you want to delegate the responsibility of object creation to subclasses.
- When you want to avoid `if/else` or `switch` blocks scattered across your code.

### Java Example

```java
// Step 1: Define a common interface
interface Animal {
    void speak();
}

// Step 2: Create concrete implementations
class Dog implements Animal {
    public void speak() {
        System.out.println("Woof!");
    }
}

class Cat implements Animal {
    public void speak() {
        System.out.println("Meow!");
    }
}

// Step 3: Create the Factory
class AnimalFactory {
    public static Animal createAnimal(String type) {
        if (type.equals("dog")) return new Dog();
        if (type.equals("cat")) return new Cat();
        throw new IllegalArgumentException("Unknown animal: " + type);
    }
}

// Step 4: Use the factory
public class Main {
    public static void main(String[] args) {
        Animal a = AnimalFactory.createAnimal("dog");
        a.speak(); // Woof!

        Animal b = AnimalFactory.createAnimal("cat");
        b.speak(); // Meow!
    }
}
```

**Key benefit:** To add a new animal (e.g. `Bird`), you only change the factory — not every place in your code that creates animals.

---

## 2. Abstract Factory

### What is it?
The Abstract Factory pattern provides an interface for creating **families of related objects** — without specifying their exact classes. Think of it as a "factory of factories".

### What problem does it solve?
When your application needs to work with **groups of related objects** that must be used together. For example, a UI library that supports both Windows and Mac styles: buttons, checkboxes, and menus should all match the same style.

### When to use it?
- When your system needs to be independent of how its objects are created.
- When you need to ensure that related objects are always used together.
- When you want to switch between "families" of objects easily (e.g. switching themes, platforms, or environments).

### Java Example

```java
// Step 1: Define abstract products
interface Button {
    void render();
}

interface Checkbox {
    void render();
}

// Step 2: Create concrete products for each "family"

// Windows family
class WindowsButton implements Button {
    public void render() { System.out.println("Rendering Windows Button"); }
}

class WindowsCheckbox implements Checkbox {
    public void render() { System.out.println("Rendering Windows Checkbox"); }
}

// Mac family
class MacButton implements Button {
    public void render() { System.out.println("Rendering Mac Button"); }
}

class MacCheckbox implements Checkbox {
    public void render() { System.out.println("Rendering Mac Checkbox"); }
}

// Step 3: Define the Abstract Factory interface
interface UIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

// Step 4: Implement a factory for each family
class WindowsFactory implements UIFactory {
    public Button createButton()     { return new WindowsButton(); }
    public Checkbox createCheckbox() { return new WindowsCheckbox(); }
}

class MacFactory implements UIFactory {
    public Button createButton()     { return new MacButton(); }
    public Checkbox createCheckbox() { return new MacCheckbox(); }
}

// Step 5: Use the abstract factory
public class Main {
    public static void main(String[] args) {
        UIFactory factory = new WindowsFactory(); // Swap to MacFactory anytime
        Button button = factory.createButton();
        Checkbox checkbox = factory.createCheckbox();

        button.render();   // Rendering Windows Button
        checkbox.render(); // Rendering Windows Checkbox
    }
}
```

**Key benefit:** To switch from Windows UI to Mac UI, you only change one line (`new WindowsFactory()` to `new MacFactory()`). All objects created will automatically match.

---

## 3. Builder

### What is it?
The Builder pattern lets you **construct complex objects step by step**. Instead of a constructor with many parameters, you use a builder object that lets you set only the parts you need.

### What problem does it solve?
When an object has many optional fields or requires a complex setup. A constructor like `new Pizza(size, crust, cheese, pepperoni, mushrooms, olives, ...)` is hard to read and easy to mess up — especially when many parameters are optional.

### When to use it?
- When an object has many optional parameters.
- When you want to create different versions of the same object.
- When construction involves multiple steps that need to be done in a specific order.

### Java Example

```java
// The complex object
class Pizza {
    private String size;
    private String crust;
    private boolean cheese;
    private boolean pepperoni;
    private boolean mushrooms;

    // Private constructor — only the Builder can call it
    private Pizza(Builder builder) {
        this.size       = builder.size;
        this.crust      = builder.crust;
        this.cheese     = builder.cheese;
        this.pepperoni  = builder.pepperoni;
        this.mushrooms  = builder.mushrooms;
    }

    public String toString() {
        return size + " pizza | Crust: " + crust +
               " | Cheese: " + cheese +
               " | Pepperoni: " + pepperoni +
               " | Mushrooms: " + mushrooms;
    }

    // The Builder (static inner class)
    public static class Builder {
        private String size;
        private String crust;
        private boolean cheese    = false;
        private boolean pepperoni = false;
        private boolean mushrooms = false;

        public Builder(String size, String crust) {
            this.size  = size;
            this.crust = crust;
        }

        public Builder cheese()    { this.cheese    = true; return this; }
        public Builder pepperoni() { this.pepperoni = true; return this; }
        public Builder mushrooms() { this.mushrooms = true; return this; }

        public Pizza build() { return new Pizza(this); }
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        Pizza pizza = new Pizza.Builder("Large", "Thin")
                            .cheese()
                            .pepperoni()
                            .build();

        System.out.println(pizza);
        // Large pizza | Crust: Thin | Cheese: true | Pepperoni: true | Mushrooms: false
    }
}
```

**Key benefit:** You can create many variations of a `Pizza` without needing dozens of different constructors. The code reads almost like a sentence.

---

## 4. Prototype

### What is it?
The Prototype pattern lets you **create new objects by copying (cloning) an existing object**, instead of building one from scratch.

### What problem does it solve?
When creating an object is expensive or complicated (e.g. it requires a database call, heavy computation, or complex setup), and you already have a similar object ready. Instead of rebuilding from zero, you just copy it and adjust what's different.

### When to use it?
- When object creation is costly and a similar object already exists.
- When you want to avoid subclasses just to vary how an object is initialized.
- When you need many similar objects with minor differences.

### Java Example

```java
// Step 1: Implement Cloneable
class Character implements Cloneable {
    private String name;
    private String weapon;
    private int health;

    public Character(String name, String weapon, int health) {
        this.name   = name;
        this.weapon = weapon;
        this.health = health;
    }

    // Setter so we can customize the clone
    public void setName(String name) { this.name = name; }

    // Clone method
    @Override
    public Character clone() {
        try {
            return (Character) super.clone();
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
    }

    public String toString() {
        return name + " | Weapon: " + weapon + " | Health: " + health;
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        // Original object (expensive to create)
        Character original = new Character("Warrior", "Sword", 100);

        // Clone it instead of creating from scratch
        Character clone1 = original.clone();
        clone1.setName("Warrior II");

        Character clone2 = original.clone();
        clone2.setName("Warrior III");

        System.out.println(original); // Warrior    | Weapon: Sword | Health: 100
        System.out.println(clone1);   // Warrior II  | Weapon: Sword | Health: 100
        System.out.println(clone2);   // Warrior III | Weapon: Sword | Health: 100
    }
}
```

**Key benefit:** All three characters share the same weapon and health setup. You didn't have to repeat the complex initialization — you just cloned and renamed.

---

## 5. Singleton

### What is it?
The Singleton pattern ensures that a class has **only one instance** throughout the entire application, and provides a global point of access to it.

### What problem does it solve?
Some objects should exist only once — like a database connection, a configuration manager, or a logging system. Without Singleton, different parts of your code could accidentally create multiple instances, leading to inconsistent state, wasted resources, or conflicts.

### When to use it?
- When exactly one object is needed to coordinate actions across the system.
- For shared resources: database connections, thread pools, caches, loggers.
- When global state needs to be controlled and consistent.

### Java Example

```java
class DatabaseConnection {
    // Step 1: Store the single instance (starts as null)
    private static DatabaseConnection instance = null;

    // Step 2: Private constructor — nobody outside can call new DatabaseConnection()
    private DatabaseConnection() {
        System.out.println("Connecting to database...");
    }

    // Step 3: Public method to get the instance (creates it only once)
    public static DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    public void query(String sql) {
        System.out.println("Running query: " + sql);
    }
}

// Usage
public class Main {
    public static void main(String[] args) {
        DatabaseConnection db1 = DatabaseConnection.getInstance();
        DatabaseConnection db2 = DatabaseConnection.getInstance();

        db1.query("SELECT * FROM users");

        // Both variables point to the SAME object
        System.out.println(db1 == db2); // true
    }
}
```

> Warning — Thread safety note: The example above is simple but not thread-safe. In multi-threaded applications, use the `synchronized` keyword to avoid creating two instances at the same time.

```java
// Thread-safe version
public static synchronized DatabaseConnection getInstance() {
    if (instance == null) {
        instance = new DatabaseConnection();
    }
    return instance;
}
```

**Key benefit:** No matter how many times you call `getInstance()`, you always get the same object — one connection, one config, one logger.
