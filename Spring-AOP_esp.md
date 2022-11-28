# Guía de estudio de Spring AOP

**¿Qué son las tareas Transversales?**
Una tarea transversal es una tarea que puede afectar a toda la aplicación y debe centralizarse en un lugar en el código como sea posible, como el registro de bitácoras, autenticación, registro, seguridad, etc.

**¿Para qué se utiliza Spring AOP?**
Para proporcionar una forma de agregar dinámicamente tareas transversales antes, después o alrededor de la lógica real usando configuraciones simples. También hace que sea fácil mantener el código en el presente y en el futuro.

**¿Cuáles son las 2 maneras de implementar aspectos?**
 - Por medio de la anotación ApspectJ
 - Por medio de la configuración XML de Spring.

**¿Cuál es la diferencia entre una tarea normal y una transversal?**
La tarea es el comportamiento que queremos tener en un módulo de una aplicación. La tarea se puede definir como una funcionalidad que queremos implementar para resolver un problema comercial específico.

La tarea transversal es aquella que se aplica a lo largo de una aplicación y en más de un módulo, como por ejemplo, la seguridad.

**¿Cuáles son las implementaciones de AOP disponibles?**
 - AspectJ
 - Spring AOP
 - JBoss AOP

**¿Qué es un advice?**
Un advice es la implementación de una tarea transversal que le interese aplicar en otros módulos de su aplicación.

**¿Cuáles son los 5 diferentes tipos de advices?**
 - **Before advice**: Se ejecuta antes de un punto de unión, pero que no tiene la capacidad de evitar que el flujo de ejecución avance hasta el punto de unión (a menos que arroje una excepción). Utiliza la anotación @Before.
 - **After returning advice**: Se ejecuta después de que un punto de unión se ejecuta normalmente. Por ejemplo, si un método retorna sin lanzar una excepción. Utiliza la anotación @AfterReturning.
 - **After throwing advice**: Se ejecuta si un método sale arrojando una excepción. Utiliza la anotación @AfterThrowing.
 - **After advice**: Es el que ejecuta un advice independientemente de que el JoinPoint se ejecute normalmente o arroje una excepción. Utiliza la anotación @After.
 - **Around advice**: Este advice rodea un JoinPoint, como una invocación a un método. Este es el tipo de advice más poderoso. Para usar este consejo, usa la anotación @Around.
    

**¿Qué es un Spring AOP-Proxy?**
Un proxy, es un patrón de diseño muy usado. Un proxy es como cualquier otro objeto, pero contiene funcionalidad especial detrás.

Spring AOP está basada en proxy. Un proxy AOP es un objeto creado por el framework AOP para implementar contratos de aspectos en tiempo de ejecución.

Por defecto Spring AOP usa proxies dinámicos de JDK para proxies AOP. Esto habilita que cualquier interfaz (o conjunto de inerfaces) sea un proxy.

**¿Qué es Introduction en Spring AOP?**
Introductions dan capacidad a los aspectos de implementar la funcionalidad de interfaces y elegir la clase de implentación, al declarar aquellos objetos que dispararán la ejecución de un aspecto. Utiliza la anotación @DeclareParents.
```
@Aspect
public class UsageTracking {
@DeclareParents(value="com.xzy.myapp.service.*+", defaultImpl=DefaultUsageTracked.class)
public static UsageTracked mixin;

@Before("com.xyz.myapp.SystemArchitecture.businessService() && this(usageTracked)")
public void recordUsage(UsageTracked usageTracked) {
    usageTracked.incrementUseCount();
}
}
```
**¿Qué son los Joint point y Point cut?**
El punto de unión es un punto de ejecución del programa, como la ejecución de un método o el manejo de una excepción. En Spring AOP, un punto de unión siempre representa una ejecución de método .

**Pointcut** es la expresión que coincide con los puntos de unión.
El advice está asociado a una expresión de JoinPoint y se ejecuta en cualquier punto de unión que coincida con el PointCut

(*por ejemplo, la expresión* `execution(* EmployeeManager.getEmployeeById(..))` *se utiliza para hacer coincidir getEmployeeById() el método en la interfaz EmployeeManager ).*

El concepto de como los puntos de unión coinciden con las expresiones de Point Cut es primordial para AOP, y Spring usa el lenguaje de expresión pointcut de AspectJ por defecto.

**¿Qué es Weaving?**
Spring AOP solo admite el uso de PointCuts de AspectJ y permite que los aspectos utilicen solo beans declarados en el contexto de Spring. Si se desea utilizar PointCuts que se encuentran fuera del contenedor de IoC, debe usar el Framework AspectJ en la aplicación de Spring y usar Weaving.

**¿Cómo habilitar el uso de @AspectJ?**
```
<aop:aspectj-autoproxy/>Guía de estudio de Spring AOP:
```
