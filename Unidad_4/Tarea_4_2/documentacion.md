# Tarea 4.2 Normalización aplicada

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 4 Normalización de bases de datos

Tarea 4 2

Proceso de normalización del préstamo deportivo

Proyecto Préstamo de material deportivo universitario

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 4

Maestro: Ruben Riojas

Planteamiento y alcance del análisis

El proyecto administra el préstamo de piezas deportivas a usuarios con perfiles de Alumno o Trabajador. El diseño de la Unidad 3 ya separa las entidades principales. Para documentar la deducción de las formas normales, se analiza una hoja de captura que reúne datos del mismo caso; esta hoja es una representación de estudio y no una afirmación de que la base anterior tuviera esa estructura.

La normalización de la proyección elegida conduce a las separaciones que ya utiliza el proyecto. El resultado mantiene sus nueve tablas, sin dividir relaciones que ya cumplen las dependencias declaradas. El script normalized_schema.sql expresa ese resultado en SQL Server para una base nueva llamada PrestamosDeportivosU4.

Estructura no normalizada

HojaPrestamo contiene idPrestamo, idSolicitante, nombres, fechaSalida, fechaLimite, telefonos {telefono} y piezas {(numeroRenglon, idEjemplar, codigoInventario, idTipo, nombreTipo, deporte, condicionSalida)}. Las llaves { } indican grupos repetitivos, no columnas SQL del resultado.

Ejemplo ficticio: el préstamo 101 corresponde al solicitante 1, Ana, con dos teléfonos y dos piezas. La pieza 501 tiene código BAL01 y la 502, BAL02; ambas pertenecen al tipo 10, Balón, Básquetbol. La hoja repite información de personas, tipos y piezas dentro de los préstamos.

| Riesgo | Manifestación en la hoja |
| --- | --- |
| Inserción | Un tipo o una pieza nueva no dispone de fila propia si todavía no existe un préstamo. |
| Modificación | El mismo tipo puede quedar escrito de forma diferente en dos líneas. |
| Borrado | Al retirar la última hoja se puede perder la única descripción de una pieza o de su tipo. |

Primera forma normal y notación de trabajo

Se extraen los teléfonos a UsuarioTelefono(U, telefono), con clave compuesta. Las piezas se desagrupan en una relación R1 con un valor por celda y una fila por renglón. Los dos grupos independientes no se cruzan entre sí: dos teléfonos y dos piezas no deben generar cuatro detalles del préstamo.

| Símbolo | Atributo | Símbolo | Atributo |
| --- | --- | --- | --- |
| P | idPrestamo | N | numeroRenglon |
| U | idSolicitante | S | nombres del solicitante |
| FS | fechaSalida | FL | fechaLimite |
| E | idEjemplar | C | codigoInventario |
| T | idTipo | NT | nombreTipo |
| D | deporte | CS | condicionSalida |

R1(P, N, U, S, FS, FL, E, C, T, NT, D, CS). S representa el atributo nombres; los apellidos y demás datos comunes se incorporan en el esquema completo. La proyección sirve para analizar cabecera, detalle e inventario sin copiar todos los atributos del proyecto.

| P | N | U | S | E | C | T | NT | D | CS |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 101 | 1 | 1 | Ana | 501 | BAL01 | 10 | Balón | Básquetbol | Bueno |
| 101 | 2 | 1 | Ana | 502 | BAL02 | 10 | Balón | Básquetbol | Bueno |
| 102 | 1 | 1 | Ana | 501 | BAL01 | 10 | Balón | Básquetbol | Usado |

La tabla ilustra parte de las columnas de R1; FS y FL son constantes dentro de cada préstamo y pueden variar entre préstamos. La pieza 501 puede aparecer en otro préstamo histórico después de su devolución. Los datos son ficticios y permiten ilustrar la descomposición.

Dependencias funcionales y claves candidatas

Las siguientes DF se derivan de las reglas del préstamo y de la unicidad del inventario. Se asume un código único por pieza, un tipo por pieza y que una pieza no se repite dentro del mismo préstamo. El número de renglón solo es único dentro de su préstamo.

| DF | Justificación |
| --- | --- |
| P → U, FS, FL | Un préstamo tiene un solicitante y fechas de cabecera. |
| U → S | El identificador de usuario determina sus nombres actuales. |
| E → C, T | La pieza determina su código y su tipo. |
| C → E | El código de inventario es una clave alternativa de la pieza. |
| T → NT, D | El tipo determina su nombre y el deporte. |
| PN → E, CS | Préstamo y renglón determinan la pieza y su condición de salida. |
| PE → N | La misma pieza aparece a lo sumo una vez por préstamo. |

Las claves candidatas de R1 son PN, PE y PC. Desde PN se alcanza E; desde E se obtienen C y T; desde T se obtienen NT y D. P aporta U, FS y FL, y U aporta S. Desde PE se obtiene N. Desde PC se obtiene E y después N. Ninguna de esas parejas puede reducirse a un solo atributo.

Toda clave necesita P porque ninguna DF lo produce. Para obtener N o E debe incluir además N, E o C. Esto agota las candidatas bajo las DF declaradas. Los atributos primos son P, N, E y C. Elegir PN como PK no permite ignorar las otras candidatas.

No se supone que S identifique una persona ni que NT sea único. La disponibilidad de una pieza se controla por sus entregas pendientes; esa unicidad filtrada no vuelve a E una clave del historial completo.

Transición de primera a segunda forma normal

R1 está en 1FN, pero no en 2FN. P determina U, S, FS y FL aunque solo es una parte de PN, PE y PC. E determina T, NT y D y es parte de PE. C también los determina a través de E y es parte de PC. Esas dependencias afectan atributos no primos.

| Relación en 2FN | Claves candidatas | Dependencias que se conservan |
| --- | --- | --- |
| Cabecera2(P, U, S, FS, FL) | P | P → U, FS, FL y U → S. |
| Inventario2(E, C, T, NT, D) | E; C | E → C, T; C → E; T → NT, D. |
| Detalle2(P, N, E, CS) | PN; PE | PN → E, CS y PE → N. |
| UsuarioTelefono(U, telefono) | U y telefono juntos | No se presupone que un teléfono sea exclusivo de una persona. |

Primero se separa Cabecera2 usando P; después se extrae Inventario2 usando E. Cabecera2 e Inventario2 tienen claves candidatas simples, por lo que no conservan dependencias parciales bajo las reglas declaradas. En Detalle2, P, N y E son primos; CS requiere toda PN o toda PE.

Anomalías corregidas y pendientes

La cabecera ya no se repite por cada pieza. Cada pieza y su código se registran una vez en inventario, de modo que una pieza puede existir antes de prestarse. Sin embargo, Cabecera2 aún repite nombres para un usuario en varios préstamos; Inventario2 aún repite nombre y deporte del tipo en varias piezas. Esas dependencias transitivas justifican la siguiente fase.

Transición de segunda a tercera forma normal

En Cabecera2 se tiene P → U → S. U no es superclave de Cabecera2 y S no es primo, por lo que U → S viola 3FN. En Inventario2 se tiene E → T → NT, D y C → E → T → NT, D. T no es superclave y NT y D no son primos.

| Origen | Descomposición a 3FN | Anomalía corregida |
| --- | --- | --- |
| Cabecera2 | Usuario(U, S) y Prestamo(P, U, FS, FL). | Los nombres se actualizan en una sola fila del usuario. |
| Inventario2 | Ejemplar(E, C, T) y TipoMaterial(T, NT, D). | El nombre y deporte del tipo se actualizan una vez y el tipo puede existir sin piezas. |
| Detalle2 | Se conserva Detalle(P, N, E, CS). | La condición pertenece a la entrega concreta y no al tipo o al catálogo. |
| UsuarioTelefono | Se conserva la relación independiente. | Se admiten cero, uno o varios teléfonos sin columnas repetidas. |

Conexión con el modelo completo

Usuario incorpora nombres, apellidos, fechaNacimiento y activo. Alumno y Trabajador conservan la misma identidad con PK compartida y sus claves alternativas. Prestamo añade el registrador habilitado. DetallePrestamo añade devolución y condiciones; Incidencia conserva un identificador propio y la FK compuesta al detalle. Un detalle admite varias incidencias.

Edad se calcula desde fechaNacimiento mediante la vista del proyecto. Suprimir un dato derivado evita desactualización, pero no se usa como sustituto del análisis de las DF. Las nueve tablas finales coinciden estructuralmente con la Unidad 3 porque el mapeo previo ya había separado estos hechos.

Normalización aplicada a la hoja de préstamo

Figura 1. Desglose de la proyección de estudio y sus determinantes. Elaboración propia.

Reunión sin pérdida y conservación de dependencias

| Separación | Intersección | Razón de reunión sin pérdida |
| --- | --- | --- |
| R1 en Cabecera2 y resto del detalle | P | P determina todos los atributos de Cabecera2. |
| Resto del detalle en Inventario2 y Detalle2 | E | E determina todos los atributos de Inventario2. |
| Cabecera2 en Usuario y Prestamo | U | U determina Usuario(U, S). |
| Inventario2 en TipoMaterial y Ejemplar | T | T determina TipoMaterial(T, NT, D). |

Cada división binaria cumple el criterio de intersección determinante; por aplicación sucesiva se puede reconstruir R1 sin tuplas espurias. Los teléfonos se mantienen como conjunto opcional aparte: un INNER JOIN obligatorio con teléfonos eliminaría usuarios que no tienen ninguno. La prueba de reunión sin pérdida se refiere a R1, que no incluye teléfono.

Las DF originales se conservan: P → U, FS, FL en Prestamo; U → S en Usuario; E → C, T y C → E en Ejemplar; T → NT, D en TipoMaterial; PN → E, CS y PE → N en DetallePrestamo. Ninguna exige reunir dos tablas para comprobarse en la proyección normalizada.

Reconstrucción de consulta

Prestamo se une con Usuario mediante idSolicitante; con DetallePrestamo mediante idPrestamo; y con Ejemplar y TipoMaterial mediante sus FK. La consulta reconstruye los datos del préstamo para un reporte, sin almacenarlos repetidos. Las descripciones corresponden al catálogo actual; conservar nombres históricos exigiría otra regla temporal, no una duplicación accidental.

La reunión sin pérdida y la conservación de DF son propiedades analíticas. La comprobación incluida verifica los cierres de atributos, las claves candidatas y la reconstrucción de los datos ilustrativos.

Validación de FNBC del esquema completo

Se consideran las DF de las reglas actuales y las claves alternativas explícitas. Cada determinante no trivial del siguiente resumen es una clave candidata y, por ello, una superclave. El resto de DF se obtiene por inferencia; no se presupone una unicidad adicional por nombres, teléfonos o fecha.

| Relación | Claves candidatas | DF y conclusión |
| --- | --- | --- |
| Usuario | idUsuario | idUsuario → datos comunes. |
| UsuarioTelefono | idUsuario y telefono | Sin DF no trivial adicional. |
| Alumno | idUsuario; matricula | Cada candidata determina carrera y los demás atributos. |
| Trabajador | idUsuario; numeroEmpleado | Cada candidata determina adscripción y habilitación. |
| TipoMaterial | idTipo | idTipo → nombre, deporte. |
| Ejemplar | idEjemplar; codigoInventario | Cada candidata determina idTipo y estadoOperativo. |
| Prestamo | idPrestamo | idPrestamo → solicitante, registrador y fechas. |
| DetallePrestamo | idPrestamo y numeroRenglon; idPrestamo y idEjemplar | Cada candidata determina el resto del detalle. |
| Incidencia | idIncidencia | idIncidencia → detalle, fecha, descripción y estado. |

El resultado cumple FNBC respecto de este conjunto de dependencias. La condición depende de que las reglas sean completas. Por ejemplo, no se declara nombreTipo → deporte sin una regla que asegure nombres de tipo globalmente únicos. La exclusión de dos entregas abiertas de una pieza es una restricción condicionada y no una DF del historial completo.

4FN y 5FN no se afirman como resultado automático: el caso no declara conjuntos independientes ni una dependencia ternaria de reunión que requiera otra descomposición. La validación aplicada solicitada llega a FNBC.

Script normalizado y resultado del diseño

normalized_schema.sql crea las nueve tablas en SQL Server con PK, FK, UNIQUE, NOT NULL, CHECK, índices y una vista. Se ejecuta después de crear la base PrestamosDeportivosU4 mediante 00_crear_base.sql. Los nombres físicos y los tipos se conservan para mantener correspondencia con la Unidad 3 (Microsoft, s. f.).

La PK del detalle es (idPrestamo, numeroRenglon); UNIQUE(idPrestamo, idEjemplar) expresa su otra clave candidata. Alumno.matricula, Trabajador.numeroEmpleado y Ejemplar.codigoInventario son claves alternativas NOT NULL. Incidencia referencia el detalle con ambas columnas de su clave.

Las acciones CASCADE y NO ACTION conservan el criterio de la Unidad 3: se pueden eliminar teléfonos y perfiles de usuarios sin historial; no se elimina en cascada el historial. Cambiar idTipo se propaga al ejemplar. El índice único filtrado controla la entrega abierta por pieza.

Reglas que requieren controles adicionales

La totalidad de los perfiles, el mínimo de un detalle, la actividad del solicitante, la habilitación del registrador y la coherencia de fechas entre tablas no se deducen solo de FNBC. 02_operaciones.sql conserva la interfaz transaccional y su rol de aplicación; una cuenta propietaria con DML directo puede omitir esa interfaz. No se atribuye a la normalización una garantía que depende de permisos y operaciones.

Conclusión

La hoja de estudio pasa de grupos repetitivos a valores atómicos, separa dependencias parciales y elimina dependencias transitivas. La descomposición conserva las DF y permite reconstruir R1 sin pérdida. El esquema completo mantiene nueve relaciones en FNBC según las reglas declaradas y sirve de base para su implementación física en SQL Server.

Referencias

Getta, J. R. (2026). Database normalization. CSCI235 Database Systems. https://documents.uow.edu.au/~jrg/235/slides/03databasenormalization/03databasenormalization.html

Microsoft (s. f.). CREATE TABLE Transact SQL. https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql

Silberschatz, A., Korth, H. F., y Sudarshan, S. (2006). Relational database design. Database system concepts (5.ª ed.), capítulo 7. McGraw-Hill. https://www.db-book.com/Previous-editions/db5/slide-dir/ch7.pdf

## Fuentes y exportaciones de los diagramas

- [Proceso_Normalizacion.drawio](diagramas/Proceso_Normalizacion.drawio)
- [Proceso_Normalizacion.pdf](diagramas/Proceso_Normalizacion.pdf)
- [Proceso_Normalizacion.svg](diagramas/Proceso_Normalizacion.svg)
