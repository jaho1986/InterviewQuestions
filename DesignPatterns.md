# Design Patterns in Java

Design patterns are **reusable solutions to commonly occurring problems** in software design. They are not finished code, but templates or blueprints that can be adapted to solve a recurring design problem in a given context.

Design patterns are classified into **three main categories**:

| Category | Purpose |
|----------|---------|
| **Creational** | How objects are created |
| **Structural** | How objects are composed and related |
| **Behavioral** | How objects communicate and interact |

---

## 1. Creational Patterns

> Deal with object **creation mechanisms**, aiming to create objects in a manner suitable to the situation.

---

### 1.1 Singleton

Ensures a class has **only one instance** and provides a global access point to it.

**Use when:** You need exactly one shared object (e.g., configuration, logger, connection pool).

```java
public class DatabaseConnection {
    private static DatabaseConnection instance;

    private DatabaseConnection() {
        System.out.println("Connection established.");
    }

    public static DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    public void query(String sql) {
        System.out.println("Executing: " + sql);
    }
}

// Usage
DatabaseConnection conn1 = DatabaseConnection.getInstance();
DatabaseConnection conn2 = DatabaseConnection.getInstance();
System.out.println(conn1 == conn2); // true — same instance
```

---

### 1.2 Factory Method

Defines an interface for creating an object, but lets **subclasses decide which class to instantiate**.

**Use when:** You want to decouple object creation from the code that uses it.

```java
interface Animal {
    void speak();
}

class Dog implements Animal {
    public void speak() { System.out.println("Woof!"); }
}

class Cat implements Animal {
    public void speak() { System.out.println("Meow!"); }
}

class AnimalFactory {
    public static Animal create(String type) {
        return switch (type) {
            case "dog" -> new Dog();
            case "cat" -> new Cat();
            default -> throw new IllegalArgumentException("Unknown animal: " + type);
        };
    }
}

// Usage
Animal a = AnimalFactory.create("dog");
a.speak(); // Woof!
```

---

### 1.3 Abstract Factory

Provides an interface for creating **families of related objects** without specifying their concrete classes.

**Use when:** Your system needs to work with multiple families of products (e.g., UI themes: light/dark).

```java
interface Button { void render(); }
interface Checkbox { void render(); }

class LightButton implements Button {
    public void render() { System.out.println("Light Button"); }
}
class DarkButton implements Button {
    public void render() { System.out.println("Dark Button"); }
}
class LightCheckbox implements Checkbox {
    public void render() { System.out.println("Light Checkbox"); }
}
class DarkCheckbox implements Checkbox {
    public void render() { System.out.println("Dark Checkbox"); }
}

interface UIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

class LightThemeFactory implements UIFactory {
    public Button createButton()     { return new LightButton(); }
    public Checkbox createCheckbox() { return new LightCheckbox(); }
}

class DarkThemeFactory implements UIFactory {
    public Button createButton()     { return new DarkButton(); }
    public Checkbox createCheckbox() { return new DarkCheckbox(); }
}

// Usage
UIFactory factory = new DarkThemeFactory();
factory.createButton().render();   // Dark Button
factory.createCheckbox().render(); // Dark Checkbox
```

---

### 1.4 Builder

Separates the **construction of a complex object** from its representation, allowing the same process to create different representations.

**Use when:** An object has many optional parameters or requires step-by-step construction.

```java
class Pizza {
    private String size;
    private boolean cheese;
    private boolean pepperoni;

    private Pizza(Builder builder) {
        this.size      = builder.size;
        this.cheese    = builder.cheese;
        this.pepperoni = builder.pepperoni;
    }

    @Override
    public String toString() {
        return "Pizza [size=" + size + ", cheese=" + cheese + ", pepperoni=" + pepperoni + "]";
    }

    static class Builder {
        private String size;
        private boolean cheese    = false;
        private boolean pepperoni = false;

        public Builder(String size)    { this.size = size; }
        public Builder cheese()        { this.cheese = true; return this; }
        public Builder pepperoni()     { this.pepperoni = true; return this; }
        public Pizza build()           { return new Pizza(this); }
    }
}

// Usage
Pizza pizza = new Pizza.Builder("Large")
    .cheese()
    .pepperoni()
    .build();
System.out.println(pizza); // Pizza [size=Large, cheese=true, pepperoni=true]
```

---

### 1.5 Prototype

Creates new objects by **cloning** an existing object (the prototype).

**Use when:** Object creation is expensive and a similar object already exists.

```java
class Shape implements Cloneable {
    private String color;

    public Shape(String color) { this.color = color; }

    public Shape clone() {
        try {
            return (Shape) super.clone();
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
    }

    public String toString() { return "Shape [color=" + color + "]"; }
}

// Usage
Shape original = new Shape("Red");
Shape copy     = original.clone();
System.out.println(original); // Shape [color=Red]
System.out.println(copy);     // Shape [color=Red]
System.out.println(original == copy); // false — different objects
```

---

## 2. Structural Patterns

> Deal with object **composition**, creating relationships between objects to form larger structures.

---

### 2.1 Adapter

Allows **incompatible interfaces to work together** by wrapping one class with another that the client expects.

**Use when:** You want to use an existing class but its interface doesn't match what you need.

```java
// Existing class with incompatible interface
class EuropeanSocket {
    public String providePower() { return "220V power"; }
}

// Target interface the client expects
interface USASocket {
    String supplyPower();
}

// Adapter wraps the incompatible class
class SocketAdapter implements USASocket {
    private EuropeanSocket europeanSocket;

    public SocketAdapter(EuropeanSocket socket) {
        this.europeanSocket = socket;
    }

    public String supplyPower() {
        return "Converted: " + europeanSocket.providePower();
    }
}

// Usage
USASocket socket = new SocketAdapter(new EuropeanSocket());
System.out.println(socket.supplyPower()); // Converted: 220V power
```

---

### 2.2 Decorator

Attaches **additional responsibilities to an object dynamically**, without modifying its class.

**Use when:** You want to add behavior to individual objects without affecting others of the same class.

```java
interface Coffee {
    String getDescription();
    double getCost();
}

class SimpleCoffee implements Coffee {
    public String getDescription() { return "Coffee"; }
    public double getCost()        { return 1.0; }
}

class MilkDecorator implements Coffee {
    private Coffee coffee;
    public MilkDecorator(Coffee c) { this.coffee = c; }
    public String getDescription() { return coffee.getDescription() + ", Milk"; }
    public double getCost()        { return coffee.getCost() + 0.25; }
}

class SugarDecorator implements Coffee {
    private Coffee coffee;
    public SugarDecorator(Coffee c) { this.coffee = c; }
    public String getDescription() { return coffee.getDescription() + ", Sugar"; }
    public double getCost()        { return coffee.getCost() + 0.10; }
}

// Usage
Coffee coffee = new SugarDecorator(new MilkDecorator(new SimpleCoffee()));
System.out.println(coffee.getDescription()); // Coffee, Milk, Sugar
System.out.println(coffee.getCost());        // 1.35
```

---

### 2.3 Facade

Provides a **simplified interface** to a complex subsystem.

**Use when:** You want to hide internal complexity and expose a clean, easy-to-use API.

```java
class CPU        { public void start() { System.out.println("CPU started"); } }
class Memory     { public void load()  { System.out.println("Memory loaded"); } }
class HardDrive  { public void read()  { System.out.println("HardDrive reading"); } }

// Facade hides the complexity
class ComputerFacade {
    private CPU cpu           = new CPU();
    private Memory memory     = new Memory();
    private HardDrive hd      = new HardDrive();

    public void startComputer() {
        cpu.start();
        memory.load();
        hd.read();
        System.out.println("Computer is ready.");
    }
}

// Usage — client only interacts with the facade
ComputerFacade computer = new ComputerFacade();
computer.startComputer();
```

---

### 2.4 Composite

Composes objects into **tree structures to represent part-whole hierarchies**. Lets clients treat individual objects and compositions uniformly.

**Use when:** You need to represent hierarchies (e.g., file systems, UI trees, org charts).

```java
import java.util.*;

interface Component {
    void display(String indent);
}

class Leaf implements Component {
    private String name;
    public Leaf(String name) { this.name = name; }
    public void display(String indent) { System.out.println(indent + name); }
}

class Composite implements Component {
    private String name;
    private List<Component> children = new ArrayList<>();

    public Composite(String name) { this.name = name; }
    public void add(Component c)  { children.add(c); }

    public void display(String indent) {
        System.out.println(indent + name);
        for (Component c : children) c.display(indent + "  ");
    }
}

// Usage
Composite root = new Composite("root");
root.add(new Leaf("file1.txt"));

Composite folder = new Composite("documents");
folder.add(new Leaf("resume.pdf"));
folder.add(new Leaf("cover_letter.pdf"));

root.add(folder);
root.display("");
// root
//   file1.txt
//   documents
//     resume.pdf
//     cover_letter.pdf
```

---

### 2.5 Proxy

Provides a **surrogate or placeholder** for another object to control access to it.

**Use when:** You need lazy initialization, access control, logging, or caching before reaching the real object.

```java
interface Image {
    void display();
}

class RealImage implements Image {
    private String filename;
    public RealImage(String filename) {
        this.filename = filename;
        System.out.println("Loading image: " + filename); // Expensive operation
    }
    public void display() { System.out.println("Displaying: " + filename); }
}

class ProxyImage implements Image {
    private String filename;
    private RealImage realImage;

    public ProxyImage(String filename) { this.filename = filename; }

    public void display() {
        if (realImage == null) {
            realImage = new RealImage(filename); // Load only when needed
        }
        realImage.display();
    }
}

// Usage
Image image = new ProxyImage("photo.jpg");
image.display(); // Loads and displays
image.display(); // Only displays (already loaded)
```

---

## 3. Behavioral Patterns

> Deal with **communication and responsibility** between objects.

---

### 3.1 Observer

Defines a **one-to-many dependency** so that when one object changes state, all its dependents are notified automatically.

**Use when:** Changes in one object require updating others, and you don't know how many objects need to change (e.g., event systems, notifications).

```java
import java.util.*;

interface Observer {
    void update(String event);
}

class EventManager {
    private List<Observer> observers = new ArrayList<>();

    public void subscribe(Observer o)   { observers.add(o); }
    public void unsubscribe(Observer o) { observers.remove(o); }

    public void notify(String event) {
        for (Observer o : observers) o.update(event);
    }
}

class EmailListener implements Observer {
    public void update(String event) {
        System.out.println("Email notification: " + event);
    }
}

class LogListener implements Observer {
    public void update(String event) {
        System.out.println("Log entry: " + event);
    }
}

// Usage
EventManager manager = new EventManager();
manager.subscribe(new EmailListener());
manager.subscribe(new LogListener());
manager.notify("User registered"); 
// Email notification: User registered
// Log entry: User registered
```

---

### 3.2 Strategy

Defines a **family of algorithms**, encapsulates each one, and makes them interchangeable at runtime.

**Use when:** You want to switch between different behaviors or algorithms without changing the client code.

```java
interface SortStrategy {
    void sort(int[] data);
}

class BubbleSort implements SortStrategy {
    public void sort(int[] data) { System.out.println("Sorting with Bubble Sort"); }
}

class QuickSort implements SortStrategy {
    public void sort(int[] data) { System.out.println("Sorting with Quick Sort"); }
}

class Sorter {
    private SortStrategy strategy;

    public Sorter(SortStrategy strategy) { this.strategy = strategy; }
    public void setStrategy(SortStrategy strategy) { this.strategy = strategy; }
    public void sort(int[] data) { strategy.sort(data); }
}

// Usage
int[] data = {5, 3, 1, 4};
Sorter sorter = new Sorter(new BubbleSort());
sorter.sort(data); // Sorting with Bubble Sort

sorter.setStrategy(new QuickSort());
sorter.sort(data); // Sorting with Quick Sort
```

---

### 3.3 Command

Encapsulates a **request as an object**, allowing you to parameterize clients with different requests, queue them, or support undoable operations.

**Use when:** You need to queue actions, support undo/redo, or log operations.

```java
interface Command {
    void execute();
    void undo();
}

class Light {
    public void on()  { System.out.println("Light is ON"); }
    public void off() { System.out.println("Light is OFF"); }
}

class TurnOnCommand implements Command {
    private Light light;
    public TurnOnCommand(Light l) { this.light = l; }
    public void execute() { light.on(); }
    public void undo()    { light.off(); }
}

class RemoteControl {
    private Command command;
    public void setCommand(Command c) { this.command = c; }
    public void pressButton()         { command.execute(); }
    public void pressUndo()           { command.undo(); }
}

// Usage
Light light         = new Light();
RemoteControl remote = new RemoteControl();
remote.setCommand(new TurnOnCommand(light));
remote.pressButton(); // Light is ON
remote.pressUndo();   // Light is OFF
```

---

### 3.4 Template Method

Defines the **skeleton of an algorithm** in a base class, deferring some steps to subclasses.

**Use when:** Multiple classes share the same algorithm structure but differ in specific steps.

```java
abstract class DataProcessor {
    // Template method — defines the algorithm skeleton
    public final void process() {
        readData();
        processData();
        writeData();
    }

    protected abstract void readData();
    protected abstract void processData();

    protected void writeData() {
        System.out.println("Writing data to output.");
    }
}

class CSVProcessor extends DataProcessor {
    protected void readData()    { System.out.println("Reading CSV file."); }
    protected void processData() { System.out.println("Processing CSV data."); }
}

class JSONProcessor extends DataProcessor {
    protected void readData()    { System.out.println("Reading JSON file."); }
    protected void processData() { System.out.println("Processing JSON data."); }
}

// Usage
DataProcessor csv = new CSVProcessor();
csv.process();
// Reading CSV file.
// Processing CSV data.
// Writing data to output.
```

---

### 3.5 Iterator

Provides a way to **sequentially access elements** of a collection without exposing its internal structure.

**Use when:** You want a standard way to traverse different types of collections.

```java
import java.util.*;

class NameCollection implements Iterable<String> {
    private List<String> names = new ArrayList<>();

    public void add(String name) { names.add(name); }

    public Iterator<String> iterator() { return names.iterator(); }
}

// Usage
NameCollection collection = new NameCollection();
collection.add("Alice");
collection.add("Bob");
collection.add("Charlie");

for (String name : collection) {
    System.out.println(name);
}
// Alice
// Bob
// Charlie
```

---

### 3.6 Chain of Responsibility

Passes a request along a **chain of handlers**, where each handler decides to process it or pass it forward.

**Use when:** More than one object may handle a request and the handler isn't known a priori (e.g., middleware pipelines, support escalation).

```java
abstract class SupportHandler {
    protected SupportHandler next;

    public void setNext(SupportHandler next) { this.next = next; }

    public abstract void handle(String issue);
}

class Level1Support extends SupportHandler {
    public void handle(String issue) {
        if (issue.equals("basic")) {
            System.out.println("Level 1 resolved: " + issue);
        } else if (next != null) {
            next.handle(issue);
        }
    }
}

class Level2Support extends SupportHandler {
    public void handle(String issue) {
        if (issue.equals("intermediate")) {
            System.out.println("Level 2 resolved: " + issue);
        } else if (next != null) {
            next.handle(issue);
        }
    }
}

class Level3Support extends SupportHandler {
    public void handle(String issue) {
        System.out.println("Level 3 (expert) resolved: " + issue);
    }
}

// Usage
SupportHandler l1 = new Level1Support();
SupportHandler l2 = new Level2Support();
SupportHandler l3 = new Level3Support();
l1.setNext(l2);
l2.setNext(l3);

l1.handle("basic");        // Level 1 resolved: basic
l1.handle("intermediate"); // Level 2 resolved: intermediate
l1.handle("critical");     // Level 3 (expert) resolved: critical
```

---

## Summary

### Creational Patterns

| Pattern | Intent |
|---------|--------|
| **Singleton** | One instance, global access |
| **Factory Method** | Subclass decides which object to create |
| **Abstract Factory** | Create families of related objects |
| **Builder** | Step-by-step construction of complex objects |
| **Prototype** | Clone existing objects |

### Structural Patterns

| Pattern | Intent |
|---------|--------|
| **Adapter** | Make incompatible interfaces compatible |
| **Decorator** | Add behavior dynamically |
| **Facade** | Simplify a complex subsystem |
| **Composite** | Tree structures for part-whole hierarchies |
| **Proxy** | Control access to an object |

### Behavioral Patterns

| Pattern | Intent |
|---------|--------|
| **Observer** | Notify dependents on state change |
| **Strategy** | Swap algorithms at runtime |
| **Command** | Encapsulate requests as objects |
| **Template Method** | Define algorithm skeleton, defer steps |
| **Iterator** | Traverse collections uniformly |
| **Chain of Responsibility** | Pass requests along a handler chain |

---

> Design patterns are a shared vocabulary for developers. Knowing them helps you **communicate solutions clearly**, write **more maintainable code**, and **avoid reinventing the wheel** on problems that have already been solved.