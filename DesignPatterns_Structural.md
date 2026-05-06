# Structural Design Patterns in Java

Structural design patterns deal with **how classes and objects are composed** to form larger structures. They help you organize relationships between objects in a way that is flexible and efficient.

They help you:
- Combine objects and classes into bigger structures without losing flexibility.
- Make incompatible interfaces work together.
- Add new behavior to objects without changing their original code.
- Simplify complex systems behind a clean interface.

There are 6 structural patterns covered here:

| Pattern | One-line summary |
|---------|-----------------|
| **Adapter** | Make two incompatible interfaces work together |
| **Bridge** | Separate an abstraction from its implementation |
| **Composite** | Treat individual objects and groups the same way |
| **Decorator** | Add new behavior to an object without changing its class |
| **Facade** | Provide a simple interface to a complex system |
| **Proxy** | Control access to another object |

---

## 1. Adapter

### What is it?
The Adapter pattern acts as a **translator between two incompatible interfaces**. It wraps an existing class so that it can work with another class that expects a different interface — just like a power adapter that lets you plug a US device into a European outlet.

### What problem does it solve?
When you want to use an existing class, but its interface does not match what your code expects. Rewriting the existing class is risky or impossible (e.g. it comes from a third-party library).

### When to use it?
- When you need to use a class whose interface is not compatible with the rest of your code.
- When integrating third-party libraries or legacy code that you cannot modify.
- When you want to reuse existing code without rewriting it.

### Java Example

```java
// Step 1: The interface your code expects
interface MediaPlayer {
    void play(String fileName);
}

// Step 2: An existing class with a different interface (e.g. from a library)
class AdvancedPlayer {
    public void playMp4(String fileName) {
        System.out.println("Playing MP4 file: " + fileName);
    }
}

// Step 3: The Adapter — wraps AdvancedPlayer and implements MediaPlayer
class MediaAdapter implements MediaPlayer {
    private AdvancedPlayer advancedPlayer;

    public MediaAdapter() {
        this.advancedPlayer = new AdvancedPlayer();
    }

    @Override
    public void play(String fileName) {
        // Translates the call to the format AdvancedPlayer understands
        advancedPlayer.playMp4(fileName);
    }
}

// Step 4: Use the adapter
public class Main {
    public static void main(String[] args) {
        MediaPlayer player = new MediaAdapter();
        player.play("movie.mp4"); // Playing MP4 file: movie.mp4
    }
}
```

**Key benefit:** Your code only knows about `MediaPlayer`. The adapter handles the translation internally — no changes needed in either the existing class or your main code.

---

## 2. Bridge

### What is it?
The Bridge pattern **separates an abstraction from its implementation** so that both can change independently. Instead of building a big hierarchy of subclasses, you split the idea into two separate hierarchies connected by a "bridge".

### What problem does it solve?
When you have a class that can vary in two independent dimensions, and you try to cover every combination with subclasses, the number of classes explodes. For example: `RedCircle`, `BlueCircle`, `RedSquare`, `BlueSquare` — adding a new color or shape doubles the number of classes.

### When to use it?
- When you want to avoid a large number of subclasses caused by combining two varying dimensions.
- When both the abstraction and the implementation should be extensible independently.
- When you want to switch implementations at runtime.

### Java Example

```java
// Step 1: Define the implementation interface (one dimension)
interface Color {
    String apply();
}

// Step 2: Concrete implementations
class Red implements Color {
    public String apply() { return "Red"; }
}

class Blue implements Color {
    public String apply() { return "Blue"; }
}

// Step 3: Define the abstraction (other dimension) — holds a reference to Color
abstract class Shape {
    protected Color color; // The "bridge"

    public Shape(Color color) {
        this.color = color;
    }

    public abstract void draw();
}

// Step 4: Concrete abstractions
class Circle extends Shape {
    public Circle(Color color) { super(color); }

    public void draw() {
        System.out.println("Drawing a " + color.apply() + " Circle");
    }
}

class Square extends Shape {
    public Square(Color color) { super(color); }

    public void draw() {
        System.out.println("Drawing a " + color.apply() + " Square");
    }
}

// Step 5: Use the bridge
public class Main {
    public static void main(String[] args) {
        Shape redCircle  = new Circle(new Red());
        Shape blueSquare = new Square(new Blue());

        redCircle.draw();  // Drawing a Red Circle
        blueSquare.draw(); // Drawing a Blue Square
    }
}
```

**Key benefit:** To add a new color (e.g. `Green`), you only create one new class. To add a new shape (e.g. `Triangle`), you only create one new class. No combinations needed.

---

## 3. Composite

### What is it?
The Composite pattern lets you **treat individual objects and groups of objects the same way**. You build a tree structure where both single items and containers of items share the same interface.

### What problem does it solve?
When you have a hierarchy of objects where some are simple (leaves) and some contain others (branches), and you want to treat both uniformly. For example, a file system where files and folders are treated the same way when you call `getSize()` or `print()`.

### When to use it?
- When you need to work with tree-like structures (file systems, menus, organization charts).
- When you want client code to treat individual items and collections of items the same way.
- When the structure can be nested to any depth.

### Java Example

```java
import java.util.ArrayList;
import java.util.List;

// Step 1: Common interface for both files and folders
interface FileSystemItem {
    void print(String indent);
}

// Step 2: Leaf — a single file
class File implements FileSystemItem {
    private String name;

    public File(String name) { this.name = name; }

    public void print(String indent) {
        System.out.println(indent + "File: " + name);
    }
}

// Step 3: Composite — a folder that can contain files or other folders
class Folder implements FileSystemItem {
    private String name;
    private List<FileSystemItem> children = new ArrayList<>();

    public Folder(String name) { this.name = name; }

    public void add(FileSystemItem item) { children.add(item); }

    public void print(String indent) {
        System.out.println(indent + "Folder: " + name);
        for (FileSystemItem item : children) {
            item.print(indent + "  "); // Indent to show nesting
        }
    }
}

// Step 4: Use the composite
public class Main {
    public static void main(String[] args) {
        File file1 = new File("resume.pdf");
        File file2 = new File("photo.png");
        File file3 = new File("notes.txt");

        Folder documents = new Folder("Documents");
        documents.add(file1);
        documents.add(file2);

        Folder root = new Folder("Root");
        root.add(documents);
        root.add(file3);

        root.print("");
        // Folder: Root
        //   Folder: Documents
        //     File: resume.pdf
        //     File: photo.png
        //   File: notes.txt
    }
}
```

**Key benefit:** The code that calls `print()` does not need to know if it's dealing with a file or a folder. It just calls the same method on both.

---

## 4. Decorator

### What is it?
The Decorator pattern lets you **add new behavior to an object at runtime by wrapping it** inside another object. You stack decorators like layers — each one adds something new without changing the original class.

### What problem does it solve?
When you want to add responsibilities to objects without using inheritance. Inheritance is static (fixed at compile time) and leads to an explosion of subclasses. Decorators are dynamic — you can combine them freely at runtime.

### When to use it?
- When you want to add behavior to individual objects, not to the whole class.
- When using subclasses to add features would create too many combinations.
- When you want to add or remove features from objects at runtime.

### Java Example

```java
// Step 1: Define the base interface
interface Coffee {
    String getDescription();
    double getCost();
}

// Step 2: A basic implementation
class SimpleCoffee implements Coffee {
    public String getDescription() { return "Simple coffee"; }
    public double getCost()        { return 1.00; }
}

// Step 3: Base decorator — implements the same interface and wraps a Coffee object
abstract class CoffeeDecorator implements Coffee {
    protected Coffee coffee;

    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }
}

// Step 4: Concrete decorators — each adds something new
class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) { super(coffee); }

    public String getDescription() { return coffee.getDescription() + ", Milk"; }
    public double getCost()        { return coffee.getCost() + 0.25; }
}

class SugarDecorator extends CoffeeDecorator {
    public SugarDecorator(Coffee coffee) { super(coffee); }

    public String getDescription() { return coffee.getDescription() + ", Sugar"; }
    public double getCost()        { return coffee.getCost() + 0.10; }
}

class VanillaDecorator extends CoffeeDecorator {
    public VanillaDecorator(Coffee coffee) { super(coffee); }

    public String getDescription() { return coffee.getDescription() + ", Vanilla"; }
    public double getCost()        { return coffee.getCost() + 0.50; }
}

// Step 5: Use the decorators
public class Main {
    public static void main(String[] args) {
        Coffee coffee = new SimpleCoffee();
        System.out.println(coffee.getDescription() + " -> $" + coffee.getCost());
        // Simple coffee -> $1.0

        coffee = new MilkDecorator(coffee);
        coffee = new SugarDecorator(coffee);
        coffee = new VanillaDecorator(coffee);
        System.out.println(coffee.getDescription() + " -> $" + coffee.getCost());
        // Simple coffee, Milk, Sugar, Vanilla -> $1.85
    }
}
```

**Key benefit:** You can mix and match decorators freely. No need for classes like `CoffeeWithMilkAndSugarAndVanilla`. Just wrap and stack.

---

## 5. Facade

### What is it?
The Facade pattern provides a **simple, unified interface to a complex system** of classes. It hides all the complexity behind a single easy-to-use class.

### What problem does it solve?
When a system has many classes that must interact in a specific order or way, and making client code deal with all of them makes the code messy and hard to understand. The facade takes care of all that complexity so clients only need to call one simple method.

### When to use it?
- When you want to provide a simple interface to a complex subsystem.
- When there are many dependencies between client code and internal classes.
- When you want to layer your system — the facade becomes the entry point.

### Java Example

```java
// Step 1: Complex subsystem classes
class CPU {
    public void freeze() { System.out.println("CPU: Freezing..."); }
    public void execute() { System.out.println("CPU: Executing..."); }
}

class Memory {
    public void load(String data) { System.out.println("Memory: Loading data -> " + data); }
}

class HardDrive {
    public String read() {
        System.out.println("HardDrive: Reading boot sector...");
        return "boot data";
    }
}

// Step 2: The Facade — hides all the complexity
class ComputerFacade {
    private CPU cpu;
    private Memory memory;
    private HardDrive hardDrive;

    public ComputerFacade() {
        this.cpu       = new CPU();
        this.memory    = new Memory();
        this.hardDrive = new HardDrive();
    }

    // One simple method replaces the complex sequence of calls
    public void start() {
        System.out.println("-- Starting computer --");
        cpu.freeze();
        String data = hardDrive.read();
        memory.load(data);
        cpu.execute();
        System.out.println("-- Computer started --");
    }
}

// Step 3: Use the facade
public class Main {
    public static void main(String[] args) {
        ComputerFacade computer = new ComputerFacade();
        computer.start();
        // -- Starting computer --
        // CPU: Freezing...
        // HardDrive: Reading boot sector...
        // Memory: Loading data -> boot data
        // CPU: Executing...
        // -- Computer started --
    }
}
```

**Key benefit:** The client only calls `computer.start()`. It doesn't need to know about `CPU`, `Memory`, or `HardDrive` at all. The complexity is hidden behind the facade.

---

## 6. Proxy

### What is it?
The Proxy pattern provides a **substitute or placeholder for another object**. The proxy controls access to the original object — it can add extra logic before or after forwarding the call.

### What problem does it solve?
When you need to control access to an object — for example, to delay its creation until it's really needed (lazy loading), to add security checks, to log calls, or to cache results.

### When to use it?
- **Virtual Proxy:** Delay the creation of a heavy object until it is actually needed.
- **Protection Proxy:** Control access based on permissions.
- **Logging Proxy:** Log every call to the real object.
- **Caching Proxy:** Store results and avoid repeated expensive calls.

### Java Example

```java
// Step 1: Define a common interface
interface Image {
    void display();
}

// Step 2: The real object — expensive to create
class RealImage implements Image {
    private String fileName;

    public RealImage(String fileName) {
        this.fileName = fileName;
        loadFromDisk(); // Expensive operation
    }

    private void loadFromDisk() {
        System.out.println("Loading image from disk: " + fileName);
    }

    public void display() {
        System.out.println("Displaying image: " + fileName);
    }
}

// Step 3: The Proxy — controls access to RealImage
class ProxyImage implements Image {
    private String fileName;
    private RealImage realImage; // Starts as null

    public ProxyImage(String fileName) {
        this.fileName  = fileName;
        this.realImage = null; // Not loaded yet
    }

    public void display() {
        // Only create the real object when it's actually needed
        if (realImage == null) {
            realImage = new RealImage(fileName); // Lazy loading
        }
        realImage.display();
    }
}

// Step 4: Use the proxy
public class Main {
    public static void main(String[] args) {
        Image image = new ProxyImage("photo.jpg");

        // Image is NOT loaded from disk yet
        System.out.println("Image object created, not loaded yet.");

        // Now it loads and displays
        image.display();
        // Loading image from disk: photo.jpg
        // Displaying image: photo.jpg

        // Second call — no loading needed, already cached
        image.display();
        // Displaying image: photo.jpg
    }
}
```

**Key benefit:** The heavy loading operation only happens once, and only when truly needed. The client code doesn't change — it just calls `display()` on the proxy as if it were the real object.

> Structural patterns are about **how you connect and organize the pieces** of your system. The right pattern can save you from messy dependencies, duplicate code, and rigid class hierarchies.