# Tarea 2.2 Transición del modelo E R a UML

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 2 Diseño de bases de datos con el modelo E R

Tarea 2 2

Transición de diagrama E R a notación UML

Caso de estudio Préstamo de material deportivo universitario

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 2

Maestro: Ruben Riojas

Objetivo y criterio de conversión

El modelo UML conserva el mismo caso de préstamo deportivo y las reglas RN01 a RN14 de la tarea 2.1. La conversión representa los conjuntos de entidades como clases, los atributos como propiedades y las relaciones como asociaciones. No modifica el alcance ni añade préstamos, reservas o pagos distintos a los del modelo original.

Correspondencia entre entidades y clases

| E-R y ERE | UML | Identidad y significado |
| --- | --- | --- |
| Usuario | Clase abstracta Usuario | idUsuario es la identidad común. La abstracción conserva la especialización total. |
| Alumno y Trabajador | Subclases Alumno y Trabajador | Herencia de identidad y propiedades. Conjunto de generalización complete y overlapping. |
| Prestamo | Clase Prestamo | Conserva idPrestamo, fechaSalida y fechaLimite. |
| DetallePrestamo débil | Clase DetallePrestamo | Su identidad combina prestamo.idPrestamo y numeroRenglon; la composición expresa su dependencia. |
| TipoMaterial y Ejemplar | Clases TipoMaterial y Ejemplar | Se mantiene la diferencia entre categoría y pieza física. |
| Incidencia | Clase Incidencia | Conserva idIncidencia y su vínculo con una asignación concreta. |

Nombre se representa como un tipo de dato compuesto, no como una entidad con identidad propia. EstadoOperativo y EstadoIncidencia son dominios enumerados. Estos tipos describen valores y no introducen actores ni operaciones nuevas.

Alcance del diagrama de clases

Se presenta un modelo de clases del dominio. No incorpora pantallas, controladores, métodos de persistencia ni claves foráneas como sustituto de las asociaciones. La implementación orientada a objetos requerirá operaciones y validaciones que respeten este contrato conceptual.

Diagrama UML de usuarios y préstamos

Figura 1. Clases de usuarios y préstamos, tipo Nombre y jerarquía con especialización completa y superpuesta. Elaboración propia.

Diagrama UML del inventario y los detalles de préstamo

Figura 2. Clases del inventario, composición de detalles, agregación compartida y asociación de incidencias. Prestamo es la misma clase de la figura 1.

Correspondencia de atributos y propiedades

| Elemento E-R | Propiedad UML | Correspondencia |
| --- | --- | --- |
| Clave idUsuario | idUsuario: Integer {id} | Identidad de la clase y de sus instancias en ambos perfiles. |
| nombre compuesto | nombre: Nombre [1] | Nombre agrupa nombres, primerApellido y segundoApellido [0..1]. |
| telefonos multivalorado | telefonos: String [0..*] {unique} | Colección opcional de valores distintos; no se limita artificialmente a telefono1 y telefono2. |
| edad derivada | /edad: Integer {readOnly} | La barra señala derivación. Se obtiene de fechaNacimiento al consultar. |
| matricula y numeroEmpleado | Propiedades con {unique} | Claves alternativas. No reemplazan la identidad heredada. |
| numeroRenglon parcial | numeroRenglon: Integer {id parcial} | Se combina con el préstamo propietario para identificar el detalle. |
| Datos opcionales de devolución | fechaDevolucion y condicionEntrada [0..1] | Ausencia antes de la devolución; presencia conjunta cuando se registra. |
| Estados del ejemplar y de la incidencia | EstadoOperativo y EstadoIncidencia | Dominios cerrados que conservan los valores del E-R. |

Lectura de la multiplicidad UML

En UML, la multiplicidad junto a una clase indica cuántos objetos de esa clase puede tener un objeto de la clase opuesta. Por ejemplo, 1 junto a Usuario y 0..* junto a Prestamo significa que cada préstamo tiene un solicitante y cada usuario puede tener varios préstamos. No se copian las etiquetas E-R al mismo lugar visual sin revisar su significado (Object Management Group, 2017).

Relaciones asociaciones y restricciones

| Relación del E-R | Notación UML y multiplicidades | Justificación |
| --- | --- | --- |
| Usuario solicita Prestamo | Asociación. Usuario 1; Prestamo 0..*. | Cada préstamo conserva un solicitante; el usuario puede no tener préstamos. |
| Trabajador registra Prestamo | Asociación. Trabajador 1; Prestamo 0..*. | El registrador es único y debe estar habilitado. |
| Prestamo contiene DetallePrestamo | Composición con rombo negro en Prestamo. Prestamo 1; DetallePrestamo 1..*. | El detalle tiene un solo propietario y depende de su identidad. |
| DetallePrestamo corresponde a Ejemplar | Asociación. DetallePrestamo 0..*; Ejemplar 1. | Cada detalle trata una pieza; una pieza conserva varios detalles históricos. |
| TipoMaterial clasifica Ejemplar | Agregación compartida con rombo blanco en TipoMaterial. TipoMaterial 1; Ejemplar 0..*. | El catálogo agrupa piezas; no se transmite una orden automática de eliminación. |
| Asignación documenta Incidencia | Asociación DetallePrestamo Incidencia. DetallePrestamo 1; Incidencia 0..*. | El detalle ya identifica un ejemplar de un préstamo, por lo que conserva el contexto del agregado. |

Herencia y especialización

La flecha triangular vacía apunta desde Alumno y Trabajador hacia Usuario. El conjunto complete conserva la totalidad; overlapping permite que una misma identidad tenga ambos perfiles. Esas restricciones se aplican al conjunto de generalizaciones, no solo a una flecha aislada (Object Management Group, 2017).

Agregación ERE composición y agregación UML

La agregación ERE conserva el contexto

En el modelo original, el agregado reúne DetallePrestamo, corresponde y Ejemplar. En UML no se crea una clase Asignacion redundante: cada DetallePrestamo ya determina exactamente un préstamo propietario y un ejemplar. Asociar la incidencia al detalle conserva la misma entrega y permite reconstruir toda su información.

La composición expresa propiedad exclusiva

El rombo negro se coloca en Prestamo. Un detalle no puede pertenecer a dos préstamos ni cambiar de propietario conservando su identidad. La devolución cierra la entrega, pero no destruye el detalle. La política del caso prohíbe borrar el historial; un mecanismo técnico de borrado en cascada no se deduce de este dibujo.

La agregación compartida agrupa el catálogo

El rombo blanco se utiliza entre TipoMaterial y Ejemplar. En este diseño indica agrupación de inventario y no impone dependencia del ciclo de vida. La pieza tiene identidad propia y su historial no desaparece al reorganizar el catálogo. Para eliminar un tipo debe dejar de tener ejemplares asociados; la multiplicidad uno del tipo sigue siendo obligatoria.

UML deja sin fijar una semántica universal de ciclo de vida para la agregación compartida. Por eso se explicita la interpretación del caso. Su rombo blanco no sustituye la agregación ERE ni determina por sí solo reglas de persistencia (Object Management Group, 2017).

Restricciones conservadas fuera de las multiplicidades

Cada ejemplar tiene como máximo un detalle abierto y no se repite dentro de un mismo préstamo.

El solicitante debe estar activo; el registrador debe ser un trabajador habilitado.

Las fechas respetan el orden temporal y los datos de devolución se completan juntos.

La incidencia conserva una fecha válida, una descripción y uno de sus estados permitidos.

Coincidencias y aportes al desarrollo orientado a objetos

Ambos modelos describen las mismas identidades y asociaciones del problema. El modelo E-R destaca la estructura conceptual de los datos, las claves y la participación. UML facilita representar propiedades tipadas, colecciones, herencia y relaciones entre objetos del dominio. Ninguno de los dos reemplaza la validación de las reglas de negocio.

Aplicación al desarrollo

La propiedad nombre puede implementarse como un objeto de valor; telefonos, como una colección sin duplicados; edad, como una propiedad calculada. Un Prestamo administra su colección de detalles y cada detalle referencia a un Ejemplar. Una Incidencia referencia al detalle afectado, de modo que se consulta la pieza, el préstamo y el solicitante sin duplicar esos datos.

La especialización superpuesta exige atención en C#, donde una clase tiene una sola clase base directa (Microsoft, 2022). No se deben crear dos identidades independientes para la misma persona. Una implementación puede conservar Usuario y representar sus perfiles mediante roles o interfaces. Esa decisión de código debe mantener la identidad única y las reglas de ambos modelos.

Comprobación de equivalencia

| Caso | E-R extendido | UML |
| --- | --- | --- |
| Persona con dos perfiles | Pertenece a Alumno y Trabajador con el mismo idUsuario. | Clasificación superpuesta y atributos heredados de Usuario. |
| Préstamo con devolución parcial | Un préstamo contiene varios detalles; solo algunos están devueltos. | Composición con 1..* detalles y propiedades opcionales por detalle. |
| Daño en un balón de una entrega | Incidencia se asocia con la asignación agregada. | Incidencia referencia al detalle de ese balón en ese préstamo. |
| Nueva entrega de una pieza ya devuelta | Se crea otro detalle histórico y se comprueba disponibilidad. | Se crea otro objeto detalle conservando la restricción de un único detalle abierto. |

Herramienta y archivos editables

Modelo_UML_Deportes.drawio conserva dos hojas editables de diagrams.net. Ambas forman un solo diagrama de dominio distribuido para facilitar su lectura. La repetición de Prestamo es una referencia a la misma clase, no una clase adicional. Se incluyen exportaciones en PDF vectorial, SVG y PNG a 300 ppp.

Conclusión

La transición mantiene las entidades, los atributos, la identidad y las reglas del caso. Las asociaciones conservan las cardinalidades; la composición representa la dependencia del detalle y la herencia preserva los perfiles. La comparación también evita confundir la abstracción de una relación en ERE con la agrupación compartida de UML.

Referencias

Chen, P. P. (1976). The entity relationship model toward a unified view of data. ACM Transactions on Database Systems, 1(1), 9–36. https://doi.org/10.1145/320434.320440

JGraph Ltd. (s. f.). Save a diagram in various formats. https://www.drawio.com/docs/manual/editor/save-file-formats/

Microsoft (2022, 16 de febrero). Inheritance derive types to create more specialized behavior. https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/object-oriented/inheritance

Object Management Group (2017). OMG Unified Modeling Language Version 2.5.1. https://www.omg.org/spec/UML/2.5.1

Silberschatz, A., Korth, H. F., y Sudarshan, S. (2019). Database system concepts (7.ª ed.). McGraw-Hill. https://www.db-book.com/

## Fuentes y exportaciones de los diagramas

- [Diagramas_UML.pdf](diagramas/Diagramas_UML.pdf)
- [Modelo_UML_Deportes.drawio](diagramas/Modelo_UML_Deportes.drawio)
- [UML_01_Usuarios_y_prestamos.pdf](diagramas/UML_01_Usuarios_y_prestamos.pdf)
- [UML_01_Usuarios_y_prestamos.svg](diagramas/UML_01_Usuarios_y_prestamos.svg)
- [UML_02_Inventario_y_detalles.pdf](diagramas/UML_02_Inventario_y_detalles.pdf)
- [UML_02_Inventario_y_detalles.svg](diagramas/UML_02_Inventario_y_detalles.svg)
