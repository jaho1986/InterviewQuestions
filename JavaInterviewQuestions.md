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

#### Arraylist
- Is the implementation of List Interface.
- Array is size fixed, but Arraylist size can grow dynamically.
- ArrayList is used to store objects and perform operations on it.
- ArrayList is not Syncronized. Vector is similar to ArrayList wich is synchronized.
- If your application does not require insertion or deletion of elements, the most efficient data structure is the array.
 
#### How to create elements of arraylist?
- For each loop.
- Iterator.
- List Iterator.
- Enumeration.
  
#### Vector
Vector is same as ArrayList. The only difference is that, Vector is syncronized but ArrayList is not. That means Vector is threadsafe.
 
#### Queue
- Is an interface.
- PriorityQueue is a class wich implements Queue iterface and sorts the data stored. DeQue satands for double ended queue.
- The Queue can be operated at both ends. Same holds for insertion and deletion too.
- Queue operates on the principle "First In First Out". 
 
#### PriorityQueue
 Is the one that sorts the data.
 
#### Set
- Set is a collection interface. HashSet and TreeSet are implementations of set.
- Set cannot have duplicates.
- Class HashSet removes the duplicates and gives better performance over TreeSet. It doesn't guarantee to store the data in the same order it is inserted.
- Class TreeSet sorts the added data apart from removing the duplicates.
  
#### LinkedList
A linked list is a linear data structure wich is constituted by a chain of nodes in wich each node contains a value an a pointer to the next node in the chain.

- Implements Queue and Deque interfaces.
- Contain insertion Order.
- It's not synchronized.

#### ArrayList
Arraylist is the implementation of the List interface where the elements can be dynamically added or removed from the list. We use arraylist when we want to have a dynamic collection of elements.

#### Similairities between LinkkedList and ArrayList:
- They are implementations of the List interface.
- They maintain the insertion order of the elements.
- Their classes are not synchronized.

#### LinkedList VS ArrayList:
- Insertion, deletion, and removal are faster in LinkedList because thre is no need for resize like in an Arraylist.
- LinkedList is based on doubly linked list implementation whereas Arraylist is based on the concept of a dynamically resizable array.
- A LinkedList class can be used as a list and a queue because it implements List and Deque interfaces whereas Arraylist can only implement Lists.
- LinkedList consumes more memory than an ArrayList because every node in a LinkedList stores two references, whereas ArrayList holds only data and its index.
 
#### HashTable
- It's an implementation of the Map Interface.
- All methods are thread-safe.
- There is a "synchronized" keyword on each public method (put, get, remove, etc).
- Overhead in an environment where Map is initialized once and read by multiple threads.

#### HashMap
- It's a Map implementation that satisfies most of the basic use cases.
- Is not "thread-safe".
- Iteration is not guaranteed in insertion order.
- We need to use the "synchronized" operation when is manipulated by multiple threads (concurrent adds, removes, iterations).
- Most of the enterprise applications populate the map once and then read it many times from many threads. Given this Hashmap suffices for all such scenarios, without any worries of performace overheads.

#### LinkedHashMap
It's very similar to HashMap. It combines two strucures over the same data:
1. **Hash Table** (same as `HashMap`): allows searching, inserting and deleting by key in `O(1)` on average.
2. **Double Liked List** each entry also stores 2 references: `before` () and `after` (next node) which form a chain in the order in which the entries were inserted.


#### TreeMap
- Is the implementation of SortedMap and NavigableMap interfaces.
- Iteration is guranteed in "natural sorted" order of keys.
- The keys should implement "Comparable Interface" (ClassCastException is thrown if it's not implemented); in other case, we need to provide an explicit Comparator in the constructor.
- It's a Red-black tree based implementation. NavigableMap interface provides methods that can return closest match to the key (floorEntry()).

#### IdentityHashMap
- Uses identity to store and retrieve key values.
- It uses reference equality; meaning r1==r2 rather than r1.equals(r2). For hashing, System.identityHashCode(givenKey) is invoked rather than givenKey.hashCode().
- It's used in serialization/deep copying

#### EnumMap
- EnumMap<K extends Enum<K>,V>
- It's used for enum type keys. All of the keys in an enum map must come from a single enum type that is specified, explicitly or implicitly when the map is created.
- Null Keys are not permited.
- It's not synchronnized.

#### WeakHashMap
- Elements in a WeakHasMap can be reclaimed by the garbage collector if there are no other strong references to the object, this makes them useful for caches/lookup storage.
- Keys inserted gets wrapped in java.lang.ref.WeakReference.
- Useful only if the desired lifetime of cache entries is determined by external references to the key, not the value.

#### Collections.synchronizedMap(aMap):
- A convenient "decorator" to create fully synchronized map.
- Return type is collections.SynchronizedMap Instance. It wraps around passsed map instance and marks all APIs as Synchronized, effectively making it similar to HashTable.

#### ConcurrentHashMap
- Supports full concurrency during retrieval. Means, retrieval operations do not block even if adds are running concurrently(mostly).
- Reads can happen fast, while writes require a lock. Write lock is acquired at granular level, the whole table is not locked only segments are locked. So, there is a rare chance of read waiting on write to complete.
- Iterations do not throw concurrent modification exception (within the same thread).
- It can be used in cases where a lot of concurrent addition happens followed no or concurrent reads later on.
- Null keys are not allowed. If map.get(null) returns null, it's not sure if null is not mapped or if null is mapped to a null value. In a non-concurrent map, we clould use contains() call, but in a concurrent map, values can change between API calls.
- Operations are not atomic.

#### ConcurrentSkipListMap
- It's equivalent to TreeMap.
- A scalable concurrent ConcurrentNavigableMap/SortedMap implementation.
- Guarantees average O(log(N)) performance on a wide variety of operations. ConcurrentHasMap does not guareantee operation time as a part of its contract.

#### Graphs
A Graph is a non-linear data structure consisting of nodes and edges. The nodes are sometimes also referred to as vertices and the edges are lines or arcs that connect any two nodes in the graph. Graphs are used to represent networks. The networks may include paths in a city or telephone network or circuit network. Graphs are also used in social networks like linkedIn, Facebook. 

#### Suffle()
The suffle() method of the java collections framework is used to destroy any kinkd of order present in the data structure. it does just the opposite of sorting.

#### Methods for Data Manipulation in Java:
- Reverse() - reverses the order of the elements.
- fill() - replace every element in a collection with the specified value.
- copy() - creates a copy of elements from the specified source.
- swap() - swaps the position of two elements in a collection.
- addAll() - adds all the elements of a collection to other collection.
 
#### Composition
Is part if the collections in java.
- frequency() - returns the count of the number of times an element is present.
- disjoint() - Checks if two collections contain some common element.
 
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
