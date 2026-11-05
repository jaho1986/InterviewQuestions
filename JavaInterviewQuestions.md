## Object Oriented Programming 
Is a methodology or paradigm to design a program using Classes and Objects

#### Object: 
Is a real world entity that has its own properties an behaviours.

#### Class:
It's a blueprint where the properties and behavior of objects are decided.

#### Polymorphism:
Concept in wich a single action can be done in different ways.

#### Static Polymorphism:
Is the one that is resolved in compile time. Method overloading is an example of compile time polymorphism.

#### Dynamic Polymorphism:
Dynamic porlymorphism is a process in wich a call to an overridden method is resolved at runtime. That's why it is called runtime polymorphism.

#### Advantages:
- Support method overriding
- Common method specification.

#### Example:
Cass A has a method move()
Cass B has a method move()
You create instances of the to classes and you call the method move of each class.

#### Characteristics of Polymorphism:
- Operator overloading. (Operator + sum, or concatenate).
- Polimorphic parameters. (When you have local variables with the same name as the instance variables).
 
#### Super Keyword:
Super is a keyword. It is used inside a sub-class mehotd definition to call a method or variable in the superclass.
 
#### What is inheritance?
Is a procedure, in wich a sub class inherits all the properties and behaviours of a super class.

#### Why do we need inheritance?
- To reduce code redundancy.
- To improve the readability.

#### Which types of inheritance are supported in Java:
- Single inheritance.
- Multi-level inheritance.
- Hierarchical inheritance.
- Hybrid inheritance.
 
#### Single inheritance
Is a process where a subclass inherits all properties and behaviour of a single super class.

#### Multi-level inheritance
Is a process where a subclass inherits all the properties and behaviours of more than one super class at multiple levels.

#### Hierarchical inheritance
Is a process where one or more subclasses inherits all the properties and beaviours of one super class.

#### Hybrid inheritance
Is a combination of one or more inheritances.

#### Overloading
Is a feature that allows a class to have more than one method with the same name, if their argument list are different.

#### Three types of method overloading:
- Number of parameters.
- Data types of the parameters.
- Sequence of the data type of the parameters.

#### Overriding
Is a feature that allows the parent class and the subclass to have a same method.

#### Rules of method overriding:
- The argument list of the child should match the parent class.
- Access modifier of the child class should be less restrictive than the parent class.
- Local parameters cannot be overridden.
 
## Generics in Java
Is a term that denotes a set of language features related to the definition and use of Generic types and methods.

#### Types of generics:
- Generic Type Class.
- Generic Type Interface.
- Generic Type Method.
- Generic Type Constructor.
 
#### Generic functions
We can also write generic functions that can be called with different types of arguments based of the type of aguments passed to the generic method and further the compiles handles this method.

#### Advantages of Generics in Java:
- Code reusability.
- Type safety.
- Individual type casting not required.
- Implementing non generic algorithms.
 
## Collections in Java

#### ArrayList
- Is an implementation of the `List` interface.
- An array has a fixed size, but an `ArrayList` can grow dynamically.
- `ArrayList` is used to store objects and perform operations on them.
- `ArrayList` is not synchronized. 
- If your application does not require dynamic resizing, an array can be more efficient.

#### How to Iterate Over an ArrayList?
- Enhanced `for` loop.
- `Iterator`.
- `ListIterator`.
- `forEach()`.

#### CopyOnWriteArrayList
`CopyOnWriteArrayList` is a thread-safe implementation of the `List` interface. It creates a new copy of its underlying array whenever the list is modified, making it suitable for frequent reads and infrequent modifications.

#### Queue
- Is an interface.
- `Deque` stands for double-ended queue. A `Deque` can be operated at both ends, allowing insertion and deletion at either end.
- A typical queue operates on the principle of "First In, First Out" (FIFO).

#### PriorityQueue
It is a class that orders elements according to their natural ordering or a provided `Comparator`. By default, the head is the least element. Iteration does not guarantee sorted order.

#### Set
- `Set` is an interface. `HashSet` and `TreeSet` are implementations of `Set`.
- `Set` does not allow duplicate elements.
- `HashSet` prevents duplicates and generally offers better performance than `TreeSet`. It does not guarantee insertion order.
- `TreeSet` sorts the added elements and does not allow duplicates.

#### LinkedList
A linked list is a linear data structure consisting of a chain of nodes, where each node contains a value and references to the previous and next nodes.

- Implements the `List` and `Deque` interfaces.
- Maintains insertion order when used as a list.
- It is not synchronized.

#### Similarities Between LinkedList and ArrayList
- They are implementations of the `List` interface.
- They maintain the insertion order of the elements.
- Their classes are not synchronized by default.

#### LinkedList VS ArrayList
- Insertion and deletion can be faster in `LinkedList` when the position is already known. Finding the position still takes time. `ArrayList` may need to shift elements when inserting or removing elements in the middle.
- `LinkedList` is based on a doubly linked list, whereas `ArrayList` is based on a dynamically resizable array.
- The `LinkedList` class can be used as a list and a queue because it implements the `List` and `Deque` interfaces, whereas `ArrayList` implements `List`.
- `LinkedList` consumes more memory than `ArrayList` because every node stores references to the previous and next nodes.

#### Hashtable (Legacy Class)
- It is a legacy implementation of the `Map` interface.
- Its methods are synchronized.
- It does not allow `null` keys or values.
- It introduces synchronization overhead.
- **Modern alternative: `ConcurrentHashMap`** — a thread-safe map designed for concurrent access by multiple threads.

#### HashMap
- It is a `Map` implementation that satisfies most basic use cases.
- It is not thread-safe.
- Iteration order is not guaranteed.
- When a map is manipulated by multiple threads, concurrent modifications require synchronization or a suitable concurrent implementation.
- Most applications can use `HashMap` when a map is populated once and then safely shared for read-only access among multiple threads, provided it is safely published and not subsequently modified.

#### LinkedHashMap
It is very similar to `HashMap`. It combines two structures over the same data:

1. **Hash table** (similar to `HashMap`): allows searching, inserting, and deleting by key in average O(1) time.
2. **Doubly linked list:** each entry stores references to the previous and next entries, maintaining insertion order by default.

#### TreeMap
- It implements the `SortedMap` and `NavigableMap` interfaces.
- Iteration is guaranteed in sorted key order.
- The keys must be mutually comparable when using natural ordering. Otherwise, a `ClassCastException` may be thrown. Alternatively, a `Comparator` can be provided in the constructor.
- It is based on a red-black tree. The `NavigableMap` interface provides methods that return entries matching or closest to a key, such as `floorEntry()`.

#### IdentityHashMap
- Uses object identity to store and retrieve keys.
- It uses reference equality (`r1 == r2`) rather than logical equality (`r1.equals(r2)`). For hashing, `System.identityHashCode(key)` is used instead of `key.hashCode()`.
- It is used in specialized cases such as serialization and deep-copying object graphs.

#### EnumMap
- `EnumMap<K extends Enum<K>, V>`.
- It is used for enum-type keys. All keys in an enum map must come from a single enum type specified when the map is created.
- `null` keys are not permitted, but `null` values are allowed.
- It is not synchronized by default.

#### WeakHashMap
- Elements in a `WeakHashMap` can be reclaimed by the garbage collector if their keys are no longer strongly referenced elsewhere. This makes it useful for certain lookup tables and caches.
- Keys are stored using weak references.
- It is useful when the desired lifetime of cache entries depends on external references to the keys. However, values that reference their own keys can prevent those keys from being collected.

#### Collections.synchronizedMap(aMap)
- A convenient wrapper to create a synchronized map.
- It wraps the passed map and synchronizes individual method calls. Iteration requires manually synchronizing on the returned map.

#### ConcurrentHashMap
- Supports concurrent retrieval and updates. Retrieval operations generally do not block, even when updates are running concurrently.
- It uses fine-grained synchronization and other concurrency techniques rather than locking the entire table for every update.
- Iterators do not throw `ConcurrentModificationException` due to concurrent modifications; they are weakly consistent.
- It can be used when multiple threads perform concurrent additions, updates, and reads.
- `null` keys and values are not allowed. This avoids ambiguity when `get()` returns `null`, since it means that no mapping exists for the key.
- Individual operations are thread-safe, but multiple operations are not automatically atomic as a group. Methods such as `putIfAbsent()`, `compute()`, and `merge()` support atomic operations.

#### ConcurrentSkipListMap
- It is similar to `TreeMap`, but supports concurrent access.
- It is a scalable, concurrent implementation of `ConcurrentNavigableMap` and `SortedMap`.
- It guarantees average O(log N) performance for basic operations.
- Unlike `ConcurrentHashMap`, it maintains keys in sorted order.

#### Graphs
A graph is a non-linear data structure consisting of nodes and edges. The nodes are also referred to as vertices, and the edges connect vertices. Graphs are used to represent networks, such as roads, telephone networks, circuit networks, and social networks like LinkedIn and Facebook.

#### shuffle()
The `Collections.shuffle()` method is used to randomly rearrange the elements in a list. It changes their order without sorting them.

#### Methods for Data Manipulation in Java
- `Collections.reverse()` — reverses the order of the elements in a list.
- `Collections.fill()` — replaces every element in a list with the specified value.
- `Collections.copy()` — copies elements from a source list to a destination list. The destination list must be at least as large as the source list.
- `Collections.swap()` — swaps the positions of two elements in a list.
- `addAll()` — adds all elements of a collection to another collection.

#### Composition
Composition is an object-oriented programming concept, not part of the Java Collections Framework.

- `Collections.frequency()` — returns the number of times an element appears in a collection.
- `Collections.disjoint()` — checks whether two collections have no elements in common.


## Threading

#### Thread
 - Thread is a lightweight sub process. Every Java program contains at least one thread.
 - A thread is created and controlled by the java.lang.Thread class

#### Thread Lifecycle:
 - New
 - Runnable \
 -           Waiting
 - Running  /
 - Terminated

Java defines six states in the `Thread.State` enum: 
 - **NEW:** A thread is in this state when you create the object with `new Thread()`, but you have not called `start()` yet. Nothing is running at this point.
 - **RUNNABLE:** When you call `start()`, the thread becomes runnable. This means it is either running right now or ready to run and waiting for the CPU to give it time.
 - **BLOCKED:** A thread enters this state when it tries to enter a `synchronized` block or method, but another thread already holds the lock. It stays blocked until the lock is released.
 - **WAITING:** A thread goes here when it waits without any time limit, for example by calling `object.wait()`, `thread.join()`, or `LockSupport.park()`. It only continues when another thread wakes it up, for example with `notify()`, or when the joined thread finishes.
 - **TIMED_WAITING:** This is similar to waiting, but with a time limit. It happens when you call methods like `Thread.sleep(1000)`, `wait(1000)`, or `join(1000)`. The thread goes back to runnable when the time ends or when it is woken up earlier.
 - **TERMINATED:** A thread reaches this state when its `run()` method finishes normally or stops because of an uncaught exception. A terminated thread cannot be started again.

#### Ways to create a thread in Java

1. Extend the `Thread` class:

```java
class MyThread extends Thread {
    @Override
    public void run() {
        System.out.println("Hello from the thread");
    }
}

new MyThread().start();
```

2. Implement the `Runnable` interface:

```java
class MyTask implements Runnable {
    @Override
    public void run() {
        System.out.println("Hello from Runnable");
    }
}

new Thread(new MyTask()).start();
```

3. Use a lambda expression:

```java
new Thread(() -> System.out.println("Hello from lambda")).start();
```

4. Use `ExecutorService`:

```java
ExecutorService executor = Executors.newFixedThreadPool(2);
executor.submit(() -> System.out.println("Hello from the executor"));
executor.shutdown();
```

With `Callable`, you can also return a result through a `Future`.

5. Use `CompletableFuture`:

```java
CompletableFuture.runAsync(() -> System.out.println("Hello async"));
```

6. Use virtual threads (Java 21+):

```java
Thread.startVirtualThread(() -> System.out.println("Hello virtual"));
```

**Important note**:
Always call `start()`, not `run()`. If you call `run()` directly, the code runs in the current thread and no new thread is created.
   
#### Multi Threading:
Multi Threading is the ability of a program to run two or more threads concurrently, where each thread can handle a different task at the same time making optimal use of the available resources.

#### Synchronized methods are used to guarantee that a method can only be accessed by one thread at a time. 
We use sincronized when multiples threads work on the same object.

#### Thread Pool:
Java Thread Pool manages the pool of worker threads and contains a queue that keep the tasks waiting to be executed.
 
## Comparable VS Comparator Java
- Comparable is an interface used to compare objects by the comapreTo(Object o) method.
    Example: class nameClass implements Comparable<Object> {...
    ObjectClass > ObjectToCompare = +
    ObjectClass < ObjectToCompare = -
    ObjectClass = ObjectToCompare = 0
- Comparator. We use comparator in 2 situations:
    - When the classes to compare don't implement the Comparable interface.
    - When you want to compare objects with a different logic that the one implemented with the comparable Interface.

Example:
```
     Comparator<Object> comparator = new Comparator<Laptop>() {
       public int compare (Object o1, Object o2) {
         //logic here...
       }
     };
```
