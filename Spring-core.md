# Guía de estudio de Spring Core

**¿Qué es Spring?**
Es un Framework que se utiliza para hacer aplicaciones Java con el fin de tener bajo acoplamiento entre los componentes implementando la inyección de dependencias.

**Características de Spring**

 - Ligero.
 - Utiliza inyección de dependencias.
 - Administra el ciclo de vida de los beans.
 - Soporta transacciones.

**Ventajas de usar Spring**
 - Reduce las dependencias entre los componentes de la aplicación.
 - Facilita las pruebas unitarias debido a la inyección de dependencias.
 - Es modular, por lo que no es necesario cargar dependencias que no se utilizan dentro del proyecto.
 - Es compatible con la mayoría de las características de Java EE.

**¿Qué es la inyección de dependencias?**
Es la manera en la que inyectamos propiedades a los objetos y es responsable de inicializar todos los objetos dentro del sistema. Incluso, cuando los objetos dependen de otros objetos, (esto es: le asigna la referencia a cada uno de ellos).

*Ejemplo:*
Si una clase “A” depende de “B”, la inyección de dependencias inicializa “A”, inicializa “B” y asigna una referencia de “B” a “A” (así podemos decir que B ha sido inyectado a “A”).

**¿Cómo se implementa la inyección de dependencias en Spring?**
Podemos utilizar Spring XML o las anotaciones.

**Tipos de inyección de dependencias:**
 - Inyección por constructor.
 - Inyección por getter y setter.
 - Inyección por interfaz.
    
**Nombra algunos módulos importantes de Spring:**
 - Spring JDBC
 - Spring ORM
 - Spring JMS
 - Spring Transactions
 - Spring Web
 - Spring AOP
 - Spring Beans
 - Spring Core
 - Spring Context
 - Spring Test
    
**¿Qué es la programación orientada a aspectos?**
Es un paradigma de programación cuya intención es la de quitar la dependencia de tareas que son comunes entre distintas clases (transversales) y facilitar el desacoplamiento. Por ejemplo: verificar que constantemente un usuario esté registrado, que tenga permisos de sistema, etc.

**¿Qué es IoC?**
Es un mecanismo que se encarga de administrar las instancias de los objetos en vez de crearlas dentro de las clases con el operador new.

**¿Qué es un Spring bean?**
Es cualquier clase normal de Java que se inicializa con el contenedor Spring IoC el cual gestiona el ciclo de vida del mismo.

**¿Cuáles son las diferentes formas de configurar una clase como Spring Bean?**
*Configuración basada en XML:*

    <bean name="myBean"class="com.journaldev.spring.beans.MyBean" />
*Configuración basada en Java:*
```
@Configuration
@ComponentScan(value="com.journaldev.spring.main")
public class MyConfiguration {
  @Bean
  public MyService getService(){
    return new MyService();
  }
}
```
**¿Cuáles son los diferentes Scopes de un bean de Spring?**
-   **Singleton**: Solo se creará una instancia del bean para cada contenedor.
-   **Prototype**: se creará una nueva instancia cada vez que se solicite el bean.
-   **Request**: Esto es lo mismo que el alcance prototype, sin embargo, está destinado a ser utilizado para aplicaciones web.
-   **Session**: el contenedor creará un nuevo bean para cada sesión HTTP.
-   **Global-session**: esto se usa para crear beans de sesión global para aplicaciones de portlet.

**¿Cuál es el ciclo de vida de Spring Bean?**
Spring Beans inicializa Spring Beans y todas las dependencias también se inyectan. Cuando se destruye el contexto, también destruye todos los beans inicializados.

¿Cómo obtener el objeto ServletContext y ServletConfig en un Spring Bean?
```
@Autowired
ServletContext servletContext;
```
**¿Qué es el cableado de un bean?**
Es el proceso de inyección de dependencias de los beans cuando se inicializa el contexto de Spring.

**¿Cuales son los tipos de cableados de Spring?**
 - autowire by name
 - autowire by type
 - autowire by constructor

**¿Cómo proporcioa Spring seguridad en lo hilos?**
Al cambiar el scope de un bean a prototype o session para lograr la seguridad de hilos a costa del rendimiento. En caso contrario al utilizar Singleton, todas las variables de instancia de una clase pueden ser modificadas por cualquier hilo y esto conduce a datos inconsistentes.

**¿Qué es un @Controller en Spring MVC?**
Es la clase que se encarga de atender todas las solicitudes de los clientes y les envía los recursos configurados.

**¿Cuál es la diferencia entre las anotaciones de @Component, @Controller, @Repository y @Service en Spring?**
 - **@Component** se utiliza para indicar que una clase es un componente. Estas clases se usan para detección automática y se configuran como bean, cuando se utilizan configuraciones basadas en anotaciones.
 - **@Repository** se usa para indicar que un componente se usa como repositorio y un mecanismo para almacenar / recuperar / buscar datos.
 - **@Service** se usa para indicar que una clase es un Servicio. Por lo general, las clases de facade de negocios que brindan algunos servicios se anotan con esto.
    
**¿Qué es el DispatcherServlet?**
Es el controlador en una aplicación Spring MVC, carga el archivo de configuración de los bean e inicializa todos los beans configurados.

**¿Qué es el ContextLoaderListener?**
Es el oyente que inicia y cierra el WebApplicationContext. Se encarga de vincular el ciclo de vida de ApplicationContext con el ciclo de vida de ServletContext y automatizar la creación de ApplicationContext.

**¿Qué es ViewResolver en Spring?**
Se usan para resolver las páginas de vista por su nombre.
```
<beans:bean class = "org.springframework.web.servlet.view.InternalResourceViewResolver">
    <beans: property name = "prefix" value = "/WEB-INF/views/" />
    <beans: property name = "suffix" value = ".jsp" />
</beans:bean>
```
**¿Qué es un MultipartResolver?**
Es una interfaz que se usa para cargar archivos.

**¿Cómo manejar excepciones en Spring MVC?**
 - Basado en controlador: podemos definir métodos de controlador de excepción en nuestras clases de controlador. Todo lo que necesitamos es anotar estos métodos con la anotación @ExceptionHandler.
 - Global Exception Handler: el manejo de excepciones es una preocupación transversal y Spring proporciona la anotación @ControllerAdvice que podemos usar con cualquier clase para definir nuestro manejador global de excepciones.
 - HandlerExceptionResolver implementation: para excepciones genéricas.

**¿Cómo crear ApplicationContext en un programa Java?**
 - AnnotationConfigApplicationContext: si estamos utilizando Spring en aplicaciones java independientes y usando anotaciones para Configuration.
 - ClassPathXmlApplicationContext: si tenemos un archivo xml de configuración.
 - FileSystemXmlApplicationContext: Es similar a ClassPathXmlApplicationContext, excepto que el archivo de configuración xml se puede cargar desde cualquier lugar del sistema de archivos.

**¿Podemos tener múltiples archivos de configuración en Spring?**
Para las aplicaciones Spring MVC, podemos definir múltiples archivos de configuración de contexto de primavera a través de contextConfigLocation.
```
<context-param>
<param-name> contextConfigLocation </ param-name>
<param-value> /WEB-INF/spring/root-context.xml /WEB-INF/spring/root-security.xml </ param-value>
</ context-param>
```
**¿Podemos tener múltiples archivos de configuración en Spring?**
Para las aplicaciones Spring MVC, podemos definir múltiples archivos de configuración de contexto de primavera a través de contextConfigLocation
```
<beans: import resource = "spring-jdbc.xml" />
```
**¿Qué es ContextLoaderListener?**
ContextLoaderListener es la clase de escucha utilizada para cargar el contexto raíz y definir configuraciones de los bean de Spring. Se configura dentro del web.xml

**¿Cuáles son las configuraciones mínimas necesarias para crear la aplicación Spring MVC?**
 - Agregar spring-context
 - Configurar DispatcherServlet
 - Agregar el archivo de configuración.
 - Agregar un controller para atender las solicitudes.
    
**¿Cómo podemos usar Spring para crear Restful Web Service devolviendo la respuesta JSON?**
Utilizando la dependencia de jackson.

**¿Cuáles son algunas de las anotaciones importantes de Spring que ha utilizado?**

 - **@Controller** - para las clases de controlador en el proyecto Spring MVC.
 - **@RequestMapping** - para configurar la asignación de URI en los métodos del controlador. Esta es una anotación muy importante, por lo que debe ir a Spring MVC RequestMapping Annotation Examples
 - **@ResponseBody** - para enviar Object como respuesta, generalmente para enviar datos XML o JSON como respuesta.
 - **@PathVariable** - para asignar valores dinámicos desde el URI a los argumentos del método del manejador.
 - **@Autowired** - para autocablear dependencias en beans de Spring.
 - **@Qualifier** - con anotación @Autowired para evitar confusiones cuando hay varias instancias de tipo de bean.
 - **@Service** - para clases de servicio.
 - **@Scope** - para configurar el alcance del bean de Spring.
 - **@Configuration**, **@ComponentScan** y **@Bean** - para configuraciones basadas en Java.

Anotaciones AspectJ para configurar aspectos y consejos, @Aspect , @Before , @After , @Around , @Pointcut , etc.

**¿Qué es Spring Security?**
El marco de seguridad de Spring se centra en proporcionar autenticación y autorización en aplicaciones Java.
