
# Guía de Estudio de Spring REST

**¿Qué es REST?**

Significa Representational State Transfer. Es un estilo de arquitectura que realiza una comunicación entre el cliente y el servidor. Esto a través de una comunicación HTTP.

**¿Cuáles son los niveles que maneja REST?**

- **Nivel 1 - Recursos**. Un recurso hace referencia a un concepto importante de nuestro negocio (facturas, cursos, compras, etc). Este estilo permite acceder a cada uno de los recursos de forma independiente, favoreciendo la reutilización y flexibilidad. Cada recurso contiene una URI (Uniform Resource Identifier) Que es la ruta de la URL que contiene el recurso. Un recurso se representa como:
    -   XML
    -   HTML
    -   JSON
        
- **Nivel 2 - Operaciones**. Estas hacen referencia a los métodos más comunes de HTTP (GET, DELETE, POST, PUT).
    
- **Nivel 3 - HATEOAS**. Significa Hypertext As The Engine Of Application State). Supongamos que queremos acceder a un recurso Alumno via REST . Si tenemos una Arquitectura a nivel 2 primero accederemos a ese recurso utilizando GET. En segundo lugar deberemos acceder al recurso de Cursos para añadir al alumno al curso. Esto implica que el cliente que accede a los servicios REST asume un acoplamiento muy alto, debe conocer la url del Alumno y la del Curso. Sin embargo si el recurso del Alumno contiene un link al recurso de Curso esto no hará falta.Podríamos tener una estructura JSON como la siguiente:
```
{nombre:pedro, apellidos:”gomez”, cursos:”http://miurl/cursos”}
```

Podremos acceder directamente al recurso de Curso utilizando las propiedades del Alumno esto es HATEOAS. De esta forma se aumenta la flexibilidad y se reduce el acoplamiento. Construir arquitecturas sobre estilo REST no es sencillo y hay que ir paso a paso.

**¿Cuáles son las dependencias principales que se deben de agregar para hacer un proyecto con REST?**
- Web.
- DevTools
- JPA
- Driver BD

**¿Cuál es la página de Spring INITIALIZR?**

start.spring.io

**¿Cuál es la anotación para publicar un servicio REST?**

@RestController.
@RequestMapping (method = RequestMethod.GET, path = “/hola-mundo”)
@GetMapping(path = “/hola-mundo”)

Si retornas objetos de Java dentro de los métodos, se retornan objetos JSON como respuesta.
Todas las aplicaciones de SpringBoot corren con la anotación @SpringBootApplication.

**¿Qué es el Dispatcher Servlet?**
Es aquel que maneja todas las peticiones HTTP sobre la ruta base de nuestra aplicación web. Y mapea todos los tipos de operaciones (GET, POST, DELETE, PUT) en las rutas o recursos generados.

Ejemplo GET:
```
@GetMapping(path = “/alumnos/{id}”)
public Alumno retornarAlumno(@PathVariable Integer id) {
return alumno;
}
```
Ejemplo POST:
```
@PostMapping(“/usuarios”)
public void crearUsuario(@RequestBody Usuario usuario) {
//guardar usuario
}
```
Para retornar los estados correctos al guardar:
```
@PostMapping(“/url”)
public ResponseEntity<Object> guardar(@Pathvariable Objeto objeto) {
//obtener la URI
return ResponseEntity.created(uri).build();
}
```
**Manejo de excepciones**
La anotación @ControllerAdvice nos permite consolidar nuestros múltiples @ExceptionHandlers dispersos de antes en un solo componente de manejo de errores global.

El mecanismo es extremadamente simple y también muy flexible:

 - Nos da control total sobre el cuerpo de la respuesta, así como el
   código de estado. 
 - Proporciona mapeo de varias excepciones al mismo
   método, para ser manejadas juntas. 
 - Hace un buen uso de la respuesta
   RESTful ResposeEntity más nueva.

```
@ControllerAdvice
public class RestResponseEntityExceptionHandler 
  extends ResponseEntityExceptionHandler {

    @ExceptionHandler(value 
      = { IllegalArgumentException.class, IllegalStateException.class })
    protected ResponseEntity<Object> handleConflict(
      RuntimeException ex, WebRequest request) {
        String bodyOfResponse = "This should be application specific";
        return handleExceptionInternal(ex, bodyOfResponse, 
          new HttpHeaders(), HttpStatus.CONFLICT, request);
    }
}
```
**Validaciones:**

Para las validaciones es necesario utilizar la anotación @Valid.
