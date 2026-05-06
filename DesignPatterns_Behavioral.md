# Behavioral Design Patterns in Java

Behavioral design patterns deal with **how objects communicate and interact with each other**. They define clear responsibilities and communication channels between objects, making complex flows easier to manage and understand.

They help you:
- Define clear communication between objects without tight coupling.
- Encapsulate actions, rules, and algorithms so they can be swapped or extended.
- Make your code easier to maintain when behavior needs to change.

There are 10 behavioral patterns covered here:

| Pattern | One-line summary |
|---------|-----------------|
| **Chain of Responsibility** | Pass a request along a chain until someone handles it |
| **Command** | Wrap a request as an object so it can be stored or undone |
| **Iterator** | Traverse a collection without knowing its internal structure |
| **Mediator** | Objects communicate through a central coordinator |
| **Memento** | Save and restore an object's previous state |
| **Observer** | Notify many objects when one object changes |
| **State** | Change an object's behavior when its internal state changes |
| **Strategy** | Swap algorithms at runtime without changing the client |
| **Template Method** | Define the skeleton of an algorithm, let subclasses fill in the steps |
| **Visitor** | Add new operations to objects without changing their classes |

---

## 1. Chain of Responsibility

### What is it?
The Chain of Responsibility pattern passes a request along a **chain of handlers**. Each handler decides either to process the request or to pass it on to the next handler in the chain.

### What problem does it solve?
When more than one object might handle a request, and you don't want the sender to know which specific object will handle it. Without this pattern, you end up with large `if/else` or `switch` blocks deciding who should handle what.

### When to use it?
- When multiple objects can handle a request and the handler is not known in advance.
- When you want to issue a request to one of several objects without specifying the receiver explicitly.
- When the set of handlers should be defined dynamically (e.g. based on configuration).

### Java Example

```java
// Step 1: Define the abstract handler
abstract class SupportHandler {
    protected SupportHandler next;

    public void setNext(SupportHandler next) {
        this.next = next;
    }

    public abstract void handle(String issueLevel);
}

// Step 2: Concrete handlers
class BasicSupport extends SupportHandler {
    public void handle(String issueLevel) {
        if (issueLevel.equals("basic")) {
            System.out.println("BasicSupport: Handling basic issue.");
        } else if (next != null) {
            next.handle(issueLevel);
        }
    }
}

class TechnicalSupport extends SupportHandler {
    public void handle(String issueLevel) {
        if (issueLevel.equals("technical")) {
            System.out.println("TechnicalSupport: Handling technical issue.");
        } else if (next != null) {
            next.handle(issueLevel);
        }
    }
}

class ManagementSupport extends SupportHandler {
    public void handle(String issueLevel) {
        System.out.println("ManagementSupport: Handling escalated issue: " + issueLevel);
    }
}

// Step 3: Build and use the chain
public class Main {
    public static void main(String[] args) {
        SupportHandler basic   = new BasicSupport();
        SupportHandler tech    = new TechnicalSupport();
        SupportHandler manager = new ManagementSupport();

        // Build the chain: basic -> technical -> management
        basic.setNext(tech);
        tech.setNext(manager);

        basic.handle("basic");      // BasicSupport: Handling basic issue.
        basic.handle("technical");  // TechnicalSupport: Handling technical issue.
        basic.handle("billing");    // ManagementSupport: Handling escalated issue: billing
    }
}
```

**Key benefit:** You can add, remove, or reorder handlers without changing the sender or the other handlers. The chain is flexible and easy to extend.

---

## 2. Command

### What is it?
The Command pattern **wraps a request into an object**. This object contains everything needed to execute the action — including who does it and how to undo it.

### What problem does it solve?
When you want to parameterize actions, queue them, log them, or support undo/redo. Without this pattern, calling a method directly makes it impossible to store, delay, or reverse the action.

### When to use it?
- When you need undo/redo functionality.
- When you want to queue operations and execute them later.
- When you want to log every action that is performed.
- When operations need to be executed at a specific time or in a specific order.

### Java Example

```java
import java.util.Stack;

// Step 1: Define the Command interface
interface Command {
    void execute();
    void undo();
}

// Step 2: The receiver — the object that actually does the work
class TextEditor {
    private StringBuilder text = new StringBuilder();

    public void write(String word) {
        text.append(word);
        System.out.println("Text: " + text);
    }

    public void erase(int characters) {
        int start = text.length() - characters;
        if (start >= 0) text.delete(start, text.length());
        System.out.println("Text: " + text);
    }
}

// Step 3: Concrete command
class WriteCommand implements Command {
    private TextEditor editor;
    private String word;

    public WriteCommand(TextEditor editor, String word) {
        this.editor = editor;
        this.word   = word;
    }

    public void execute() { editor.write(word); }
    public void undo()    { editor.erase(word.length()); }
}

// Step 4: The invoker — stores and runs commands
class CommandManager {
    private Stack<Command> history = new Stack<>();

    public void executeCommand(Command command) {
        command.execute();
        history.push(command);
    }

    public void undoLast() {
        if (!history.isEmpty()) {
            history.pop().undo();
        }
    }
}

// Step 5: Use it
public class Main {
    public static void main(String[] args) {
        TextEditor editor   = new TextEditor();
        CommandManager mgr  = new CommandManager();

        mgr.executeCommand(new WriteCommand(editor, "Hello "));  // Text: Hello
        mgr.executeCommand(new WriteCommand(editor, "World"));   // Text: Hello World
        mgr.undoLast();                                          // Text: Hello
        mgr.undoLast();                                          // Text:
    }
}
```

**Key benefit:** Every action is an object. You can store a history of commands and undo them one by one — perfect for text editors, games, or any app that needs undo/redo.

---

## 3. Iterator

### What is it?
The Iterator pattern provides a way to **sequentially access elements of a collection without exposing its internal structure**. You get a standard way to loop through any kind of collection.

### What problem does it solve?
When you have different types of collections (arrays, lists, trees) and you want client code to loop through them the same way, without needing to know if it's an array, a linked list, or something else.

### When to use it?
- When you want a standard way to traverse different types of collections.
- When you want to hide the internal structure of a collection from the client.
- When you need multiple traversal strategies for the same collection (forward, backward, filtered).

### Java Example

```java
import java.util.Iterator;

// Step 1: A custom collection of names
class NameCollection implements Iterable<String> {
    private String[] names;
    private int size = 0;

    public NameCollection(int capacity) {
        names = new String[capacity];
    }

    public void add(String name) {
        names[size++] = name;
    }

    // Step 2: Return an iterator
    @Override
    public Iterator<String> iterator() {
        return new Iterator<String>() {
            private int index = 0;

            public boolean hasNext() { return index < size; }
            public String next()     { return names[index++]; }
        };
    }
}

// Step 3: Use it — the client doesn't need to know it's an array internally
public class Main {
    public static void main(String[] args) {
        NameCollection names = new NameCollection(10);
        names.add("Alice");
        names.add("Bob");
        names.add("Charlie");

        for (String name : names) {
            System.out.println(name);
        }
        // Alice
        // Bob
        // Charlie
    }
}
```

**Key benefit:** The client uses a simple `for-each` loop. If you later change the internal storage from an array to a linked list, the client code does not change at all.

---

## 4. Mediator

### What is it?
The Mediator pattern introduces a **central object (the mediator) that handles all communication** between other objects. Instead of objects talking directly to each other, they talk to the mediator, and the mediator coordinates everything.

### What problem does it solve?
When many objects communicate directly with each other, the code becomes a tangled web of dependencies — changing one object forces you to update many others. The mediator centralizes communication and removes those direct dependencies.

### When to use it?
- When many objects communicate with each other and the dependencies become hard to manage.
- When you want to reuse objects more easily by reducing their dependencies.
- Common use cases: chat rooms, air traffic control, UI component coordination.

### Java Example

```java
import java.util.ArrayList;
import java.util.List;

// Step 1: Define the Mediator interface
interface ChatMediator {
    void sendMessage(String message, User sender);
    void addUser(User user);
}

// Step 2: The concrete mediator — coordinates communication
class ChatRoom implements ChatMediator {
    private List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
    }

    public void sendMessage(String message, User sender) {
        for (User user : users) {
            // Don't send the message back to the sender
            if (user != sender) {
                user.receive(message, sender.getName());
            }
        }
    }
}

// Step 3: The User class — communicates through the mediator only
class User {
    private String name;
    private ChatMediator mediator;

    public User(String name, ChatMediator mediator) {
        this.name     = name;
        this.mediator = mediator;
    }

    public String getName() { return name; }

    public void send(String message) {
        System.out.println(name + " sends: " + message);
        mediator.sendMessage(message, this);
    }

    public void receive(String message, String from) {
        System.out.println(name + " received from " + from + ": " + message);
    }
}

// Step 4: Use the mediator
public class Main {
    public static void main(String[] args) {
        ChatMediator chatRoom = new ChatRoom();

        User alice = new User("Alice", chatRoom);
        User bob   = new User("Bob",   chatRoom);
        User carol = new User("Carol", chatRoom);

        chatRoom.addUser(alice);
        chatRoom.addUser(bob);
        chatRoom.addUser(carol);

        alice.send("Hello everyone!");
        // Alice sends: Hello everyone!
        // Bob   received from Alice: Hello everyone!
        // Carol received from Alice: Hello everyone!
    }
}
```

**Key benefit:** Users don't know about each other — they only talk to the chat room. Adding a new user or removing one does not affect the others at all.

---

## 5. Memento

### What is it?
The Memento pattern lets you **save a snapshot of an object's state** and restore it later — without exposing the internal details of the object.

### What problem does it solve?
When you need to implement undo functionality or save/restore states (like checkpoints in a game or versioning in a document). Doing this without Memento means exposing private fields, which breaks encapsulation.

### When to use it?
- When you need undo/redo or rollback functionality.
- When you want to save checkpoints and restore them later.
- When you want to keep the object's internal state private while still being able to save and restore it.

### Java Example

```java
import java.util.Stack;

// Step 1: The Memento — stores a snapshot of state
class Memento {
    private final String state;

    public Memento(String state) { this.state = state; }
    public String getState()     { return state; }
}

// Step 2: The Originator — the object whose state we want to save
class TextDocument {
    private String content = "";

    public void write(String text) {
        content += text;
        System.out.println("Document: " + content);
    }

    // Save current state
    public Memento save() {
        return new Memento(content);
    }

    // Restore a previous state
    public void restore(Memento memento) {
        content = memento.getState();
        System.out.println("Restored to: " + content);
    }
}

// Step 3: The Caretaker — manages saved states
class History {
    private Stack<Memento> snapshots = new Stack<>();

    public void save(Memento memento) {
        snapshots.push(memento);
    }

    public Memento undo() {
        if (!snapshots.isEmpty()) return snapshots.pop();
        return null;
    }
}

// Step 4: Use it
public class Main {
    public static void main(String[] args) {
        TextDocument doc     = new TextDocument();
        History history      = new History();

        history.save(doc.save());   // Save empty state
        doc.write("Hello ");        // Document: Hello

        history.save(doc.save());   // Save "Hello " state
        doc.write("World");         // Document: Hello World

        doc.restore(history.undo()); // Restored to: Hello
        doc.restore(history.undo()); // Restored to:
    }
}
```

**Key benefit:** The `TextDocument` class never exposes its internal `content` field directly. The Memento stores the snapshot, and the History manages them — clean separation of concerns.

---

## 6. Observer

### What is it?
The Observer pattern defines a **one-to-many relationship**: when one object (the subject) changes its state, **all objects that depend on it (observers) are notified automatically**.

### What problem does it solve?
When a change in one object requires updating others, and you don't know in advance how many objects need to be updated. Without this pattern, you have to hardcode every notification, making your code rigid and hard to extend.

### When to use it?
- When changes in one object need to trigger updates in others.
- When the number of dependent objects is not known in advance.
- Common use cases: event systems, notifications, real-time data feeds, UI data binding (like in MVC frameworks).

### Java Example

```java
import java.util.ArrayList;
import java.util.List;

// Step 1: Observer interface — all observers must implement this
interface Observer {
    void update(float temperature);
}

// Step 2: Subject interface — manages observers and notifies them
interface Subject {
    void addObserver(Observer o);
    void removeObserver(Observer o);
    void notifyObservers();
}

// Step 3: The concrete subject — holds the state
class WeatherStation implements Subject {
    private List<Observer> observers = new ArrayList<>();
    private float temperature;

    public void setTemperature(float temperature) {
        this.temperature = temperature;
        System.out.println("\nWeather Station: Temperature changed to " + temperature + "°C");
        notifyObservers();
    }

    public void addObserver(Observer o)    { observers.add(o); }
    public void removeObserver(Observer o) { observers.remove(o); }

    public void notifyObservers() {
        for (Observer o : observers) {
            o.update(temperature);
        }
    }
}

// Step 4: Concrete observers
class PhoneDisplay implements Observer {
    public void update(float temperature) {
        System.out.println("PhoneDisplay: Showing temperature " + temperature + "°C");
    }
}

class ThermostatDisplay implements Observer {
    public void update(float temperature) {
        if (temperature > 30) {
            System.out.println("Thermostat: It's hot! Turning on AC.");
        } else {
            System.out.println("Thermostat: Temperature is comfortable.");
        }
    }
}

// Step 5: Use it
public class Main {
    public static void main(String[] args) {
        WeatherStation station = new WeatherStation();

        station.addObserver(new PhoneDisplay());
        station.addObserver(new ThermostatDisplay());

        station.setTemperature(22.5f);
        // PhoneDisplay: Showing temperature 22.5°C
        // Thermostat: Temperature is comfortable.

        station.setTemperature(35.0f);
        // PhoneDisplay: Showing temperature 35.0°C
        // Thermostat: It's hot! Turning on AC.
    }
}
```

**Key benefit:** The `WeatherStation` doesn't know anything about `PhoneDisplay` or `ThermostatDisplay`. You can add or remove observers at any time without changing the station's code.

---

## 7. State

### What is it?
The State pattern allows an object to **change its behavior when its internal state changes**. The object appears to change its class — but what actually changes is which state object it delegates behavior to.

### What problem does it solve?
When an object's behavior depends on its current state and there are many states with different rules. Without this pattern, you end up with large `if/else` or `switch` blocks checking the current state everywhere.

### When to use it?
- When an object must behave differently depending on its current state.
- When you have many conditional statements that depend on the object's state.
- Common use cases: vending machines, traffic lights, order processing, media players.

### Java Example

```java
// Step 1: Define a State interface
interface TrafficLightState {
    void handle(TrafficLight light);
}

// Step 2: Concrete states — each one knows what to do and what comes next
class RedLight implements TrafficLightState {
    public void handle(TrafficLight light) {
        System.out.println("RED — Stop!");
        light.setState(new GreenLight()); // Transition to next state
    }
}

class GreenLight implements TrafficLightState {
    public void handle(TrafficLight light) {
        System.out.println("GREEN — Go!");
        light.setState(new YellowLight());
    }
}

class YellowLight implements TrafficLightState {
    public void handle(TrafficLight light) {
        System.out.println("YELLOW — Slow down!");
        light.setState(new RedLight());
    }
}

// Step 3: The context — holds the current state and delegates behavior to it
class TrafficLight {
    private TrafficLightState currentState;

    public TrafficLight() {
        this.currentState = new RedLight(); // Initial state
    }

    public void setState(TrafficLightState state) {
        this.currentState = state;
    }

    public void change() {
        currentState.handle(this);
    }
}

// Step 4: Use it
public class Main {
    public static void main(String[] args) {
        TrafficLight light = new TrafficLight();

        light.change(); // RED   — Stop!
        light.change(); // GREEN — Go!
        light.change(); // YELLOW — Slow down!
        light.change(); // RED   — Stop!
    }
}
```

**Key benefit:** Adding a new state (e.g. `BlinkingYellow`) only requires creating a new class. No `if/else` blocks need to be updated.

---

## 8. Strategy

### What is it?
The Strategy pattern defines a **family of algorithms**, puts each one in a separate class, and makes them **interchangeable at runtime**. The client chooses which algorithm to use without changing the code that uses it.

### What problem does it solve?
When you have multiple ways to do the same thing (sort, validate, compress, pay) and you want to switch between them easily. Without this pattern, all the algorithms live inside one big class with many `if/else` blocks.

### When to use it?
- When you want to switch between different algorithms or behaviors at runtime.
- When you have multiple versions of an algorithm and you want to avoid code duplication.
- Common use cases: sorting algorithms, payment methods, compression formats, validation rules.

### Java Example

```java
// Step 1: Define the Strategy interface
interface SortStrategy {
    void sort(int[] data);
}

// Step 2: Concrete strategies — each is a different algorithm
class BubbleSort implements SortStrategy {
    public void sort(int[] data) {
        System.out.println("Sorting using Bubble Sort...");
        // (actual sorting logic would go here)
    }
}

class QuickSort implements SortStrategy {
    public void sort(int[] data) {
        System.out.println("Sorting using Quick Sort...");
        // (actual sorting logic would go here)
    }
}

class MergeSort implements SortStrategy {
    public void sort(int[] data) {
        System.out.println("Sorting using Merge Sort...");
        // (actual sorting logic would go here)
    }
}

// Step 3: The context — uses a strategy
class Sorter {
    private SortStrategy strategy;

    public Sorter(SortStrategy strategy) {
        this.strategy = strategy;
    }

    // Allow switching strategy at runtime
    public void setStrategy(SortStrategy strategy) {
        this.strategy = strategy;
    }

    public void sort(int[] data) {
        strategy.sort(data);
    }
}

// Step 4: Use it
public class Main {
    public static void main(String[] args) {
        int[] data = {5, 3, 8, 1, 9};

        Sorter sorter = new Sorter(new BubbleSort());
        sorter.sort(data); // Sorting using Bubble Sort...

        sorter.setStrategy(new QuickSort());
        sorter.sort(data); // Sorting using Quick Sort...

        sorter.setStrategy(new MergeSort());
        sorter.sort(data); // Sorting using Merge Sort...
    }
}
```

**Key benefit:** You can swap sorting algorithms at runtime with one line of code. Adding a new algorithm only requires a new class — the `Sorter` class never changes.

---

## 9. Template Method

### What is it?
The Template Method pattern defines the **skeleton of an algorithm in a base class**, leaving some steps for subclasses to fill in. The overall structure stays the same, but specific steps can be customized.

### What problem does it solve?
When you have multiple classes that follow the same sequence of steps, but each step may be implemented differently. Without this pattern, you repeat the overall structure in every class, which leads to code duplication.

### When to use it?
- When several classes share the same algorithm structure but differ in specific steps.
- When you want to avoid code duplication in the overall workflow.
- Common use cases: data parsers, report generators, game loops, build systems.

### Java Example

```java
// Step 1: The abstract class defines the template
abstract class DataExporter {

    // The template method — defines the fixed sequence
    public final void export() {
        readData();
        processData();
        writeOutput();
        System.out.println("--- Export complete ---\n");
    }

    // Steps that must be implemented by subclasses
    protected abstract void readData();
    protected abstract void processData();
    protected abstract void writeOutput();
}

// Step 2: Concrete subclasses — fill in the specific steps
class CsvExporter extends DataExporter {
    protected void readData()     { System.out.println("Reading data from database..."); }
    protected void processData()  { System.out.println("Converting data to CSV format..."); }
    protected void writeOutput()  { System.out.println("Writing CSV file to disk..."); }
}

class PdfExporter extends DataExporter {
    protected void readData()     { System.out.println("Reading data from database..."); }
    protected void processData()  { System.out.println("Formatting data for PDF layout..."); }
    protected void writeOutput()  { System.out.println("Generating PDF file..."); }
}

// Step 3: Use it
public class Main {
    public static void main(String[] args) {
        DataExporter csv = new CsvExporter();
        csv.export();
        // Reading data from database...
        // Converting data to CSV format...
        // Writing CSV file to disk...
        // --- Export complete ---

        DataExporter pdf = new PdfExporter();
        pdf.export();
        // Reading data from database...
        // Formatting data for PDF layout...
        // Generating PDF file...
        // --- Export complete ---
    }
}
```

**Key benefit:** The order of the steps (`readData → processData → writeOutput`) is defined once in the base class and cannot be changed. Subclasses only customize the parts that are different.

---

## 10. Visitor

### What is it?
The Visitor pattern lets you **add new operations to a group of objects without changing their classes**. You create a separate "visitor" object that knows how to perform the operation on each type of object.

### What problem does it solve?
When you have a group of different object types and you need to perform multiple different operations on them. Adding each operation directly to every class would keep modifying those classes. The Visitor keeps new operations separate.

### When to use it?
- When you need to perform many different and unrelated operations on an object structure without changing the structure.
- When the object structure rarely changes but you frequently need to add new operations.
- Common use cases: compilers (AST traversal), report generation, tax calculation, export systems.

### Java Example

```java
// Step 1: Define the Visitor interface — one method per object type
interface TaxVisitor {
    void visit(Food food);
    void visit(Electronics electronics);
    void visit(Clothing clothing);
}

// Step 2: Define the Element interface — objects that accept a visitor
interface Product {
    void accept(TaxVisitor visitor);
}

// Step 3: Concrete elements — each delegates to the visitor
class Food implements Product {
    public double price;
    public Food(double price) { this.price = price; }

    public void accept(TaxVisitor visitor) { visitor.visit(this); }
}

class Electronics implements Product {
    public double price;
    public Electronics(double price) { this.price = price; }

    public void accept(TaxVisitor visitor) { visitor.visit(this); }
}

class Clothing implements Product {
    public double price;
    public Clothing(double price) { this.price = price; }

    public void accept(TaxVisitor visitor) { visitor.visit(this); }
}

// Step 4: Concrete visitor — contains the logic for each type
class TaxCalculator implements TaxVisitor {
    public void visit(Food food) {
        System.out.println("Food tax (0%):        $" + (food.price * 0.00));
    }
    public void visit(Electronics electronics) {
        System.out.println("Electronics tax (15%): $" + (electronics.price * 0.15));
    }
    public void visit(Clothing clothing) {
        System.out.println("Clothing tax (8%):     $" + (clothing.price * 0.08));
    }
}

// Step 5: Use it
public class Main {
    public static void main(String[] args) {
        Product[] cart = {
            new Food(10.00),
            new Electronics(200.00),
            new Clothing(50.00)
        };

        TaxVisitor taxCalc = new TaxCalculator();
        for (Product product : cart) {
            product.accept(taxCalc);
        }
        // Food tax (0%):         $0.0
        // Electronics tax (15%): $30.0
        // Clothing tax (8%):     $4.0
    }
}
```

**Key benefit:** To add a new operation (e.g. `DiscountCalculator`), you only create a new visitor class. None of the product classes (`Food`, `Electronics`, `Clothing`) need to be touched.

---



> Behavioral patterns are about **who does what, when, and how objects talk to each other**. The right pattern helps you add new behaviors, reduce dependencies, and keep your business logic clean and organized.