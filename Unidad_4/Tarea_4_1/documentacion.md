# Tarea 4.1 Dependencias y formas normales

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 4 Normalización de bases de datos

Tarea 4 1

Dependencias anomalías y formas normales

Proyecto Préstamo de material deportivo universitario

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 4

Maestro: Ruben Riojas

Fundamentos de la normalización

La normalización analiza las dependencias que representan las reglas del negocio y descompone relaciones para reducir redundancia y anomalías. El propósito es guardar cada hecho en el lugar adecuado, conservar la información al reconstruirla y poder comprobar sus dependencias. Tener una clave primaria o muchas tablas no demuestra por sí solo que un esquema esté normalizado.

En el préstamo deportivo, el nombre del tipo de material describe al tipo, no a cada préstamo que lo utiliza. Si ese nombre se copia en cada línea, se multiplica el mismo hecho. La separación entre TipoMaterial, Ejemplar, Prestamo y DetallePrestamo evita esa repetición.

Dependencias y claves

| Concepto | Definición y ejemplo breve |
| --- | --- |
| DF X → Y | En toda instancia válida, dos tuplas con el mismo X tienen el mismo Y. Ejemplo: idTipo → nombreTipo, deporte. No significa que Y sea único. |
| DF completa | X → A es completa si ningún subconjunto propio de X determina A. En el detalle: (idPrestamo, numeroRenglon) → condicionSalida. |
| DF parcial | Un subconjunto propio de una clave candidata determina un atributo no primo. En una hoja aplanada, idPrestamo → fechaSalida es parcial respecto a (idPrestamo, numeroRenglon). |
| Dependencia transitiva | Una clave determina un atributo por un determinante intermedio no superclave. Ejemplo: idEjemplar → idTipo → nombreTipo. |
| Claves y atributos primos | Una superclave determina todos los atributos; una clave candidata es mínima. Un atributo primo pertenece al menos a una clave candidata. Deben examinarse todas las candidatas. |
| Cierre de atributos X+ | Conjunto de atributos que se deducen desde X aplicando las DF repetidamente. X es superclave si su cierre cubre el esquema. |

Las dependencias se justifican con las reglas del entorno, no con coincidencias en pocas filas. Dos alumnos pueden llamarse igual: nombres no determina idUsuario. La definición de dependencia completa y el uso de todas las claves candidatas siguen el análisis de Getta (2026).

Anomalías y calidad de la descomposición

| Anomalía | Problema en una hoja única | Corrección |
| --- | --- | --- |
| Inserción | No se puede registrar un tipo de material si la única tabla exige también una clave de préstamo y un renglón. | Registrar el catálogo en TipoMaterial sin crear un préstamo ficticio. |
| Modificación | Cambiar el nombre de un tipo obliga a editar muchas filas; alguna puede conservar el valor anterior. | Modificar una sola fila del catálogo. |
| Borrado | Eliminar la última línea que usa un tipo puede borrar también la única información del tipo. | Separar el ciclo de vida del catálogo y del préstamo. |

Reunión sin pérdida

La descomposición debe permitir recuperar exactamente la relación original mediante la reunión de sus proyecciones, sin perder tuplas ni crear combinaciones falsas. Para una división binaria R en R1 y R2 basada en DF, basta que la intersección determine por completo R1 o R2. Por ejemplo, al separar Ejemplar(E, C, T) y TipoMaterial(T, NT, D), el atributo común T identifica la fila del tipo.

Conservación de dependencias

Una dependencia se conserva si puede comprobarse a partir de las dependencias de las relaciones resultantes sin reconstruir la tabla original. Esta propiedad es diferente de la reunión sin pérdida. La descomposición a FNBC puede perder la conservación directa de alguna DF; por ello debe justificarse la elección entre FNBC y 3FN (Silberschatz et al., 2006).

Límite de la normalización

Normalizar no reemplaza claves foráneas, tipos de datos, controles de concurrencia ni reglas como exigir al menos una pieza por préstamo. Tampoco supone que toda repetición de un valor sea incorrecta: repetir una FK es necesario para representar una relación. El análisis depende del conjunto explícito de reglas del negocio.

Normalización dependencias y anomalías

Figura 1. Mapa conceptual de dependencias, anomalías y descomposición. Elaboración propia.

Condiciones de las formas normales

Figura 2. Mapa conceptual de las condiciones de 1FN a 5FN. Elaboración propia.

Primera y segunda forma normal

Primera forma normal

Una relación está en 1FN si cada atributo contiene un valor atómico de su dominio y no hay grupos repetitivos como listas de piezas o columnas pieza1, pieza2 y pieza3. Atomicidad se define según el uso del dominio: una fecha es un valor; no se divide en tres columnas para cumplir 1FN. La eliminación de listas no elimina todavía las dependencias parciales o transitivas.

| Antes | Después |
| --- | --- |
| Usuario 1 con telefonos = {8661000001, 8661000002}. | UsuarioTelefono contiene (1, 8661000001) y (1, 8661000002). Su clave es (idUsuario, telefono). |
| Un préstamo con piezas = {(1, 501), (2, 502)}. | Dos filas de detalle, cada una identificada por préstamo y renglón. |

Segunda forma normal

Una relación está en 2FN si está en 1FN y cada atributo no primo depende completamente de cada clave candidata. Una DF parcial es relevante cuando una parte propia de alguna clave determina un atributo no primo. No basta revisar únicamente la PK elegida.

Ejemplo: R(idPrestamo, numeroRenglon, fechaSalida, idEjemplar). La clave es (idPrestamo, numeroRenglon), pero fechaSalida depende solo de idPrestamo. Se separa Prestamo(idPrestamo, fechaSalida) de Detalle(idPrestamo, numeroRenglon, idEjemplar). La información de cada pieza permanece asociada al préstamo.

Si todas las claves candidatas son de un solo atributo y no hay dependencias desde el conjunto vacío, no hay una parte propia de clave que produzca una dependencia parcial. Una relación así puede estar en 2FN y conservar dependencias transitivas que incumplen 3FN.

Tercera forma normal y FNBC

Tercera forma normal

La condición formal de 3FN exige que, para cada DF no trivial X → A implicada por las reglas, X sea superclave o A sea primo. Una DF es trivial si su lado derecho está incluido en el izquierdo. La frase eliminar dependencias transitivas es una guía práctica; la condición formal también contempla claves candidatas superpuestas.

Ejemplo: EjemplarAmpliado(idEjemplar, codigoInventario, idTipo, nombreTipo, deporte). Tanto idEjemplar como codigoInventario son claves candidatas. idTipo determina nombreTipo y deporte, pero no identifica una pieza. Se obtiene Ejemplar(idEjemplar, codigoInventario, idTipo) y TipoMaterial(idTipo, nombreTipo, deporte).

Forma normal de Boyce Codd

FNBC exige que el determinante de toda DF no trivial sea una superclave. A diferencia de 3FN, no admite una excepción porque el atributo determinado sea primo. FNBC implica 3FN; la implicación inversa no siempre se cumple.

Ejemplo de 3FN que no cumple FNBC

Sea Asignacion(sesion, instructor, sala), con las reglas (sesion, instructor) → sala y sala → instructor. Las claves candidatas son (sesion, instructor) y (sesion, sala). Todos los atributos son primos: se cumple 3FN. Sin embargo, sala no determina sesion y no es superclave; sala → instructor viola FNBC.

Se descompone en SalaInstructor(sala, instructor) y SesionSala(sesion, sala). La intersección sala determina la primera relación, por lo que la reunión es sin pérdida. La DF (sesion, instructor) → sala no se comprueba directamente en una sola tabla resultante; requeriría un control adicional. Este ejemplo es ilustrativo y no añade entidades al préstamo deportivo.

Cuarta y quinta forma normal

Cuarta forma normal

Una dependencia multivaluada X →→ Y expresa que, dado X, los valores posibles de Y son independientes de los atributos restantes. Es no trivial si Y no está incluido en X y X unido con Y no cubre todo el esquema. 4FN exige que todo determinante de una DMV no trivial sea superclave. Las DF son un caso particular de DMV; por ello 4FN también exige FNBC (Fagin, 1977).

Ejemplo ilustrativo: Preferencia(usuario, telefono, deporte). Se supone que cada teléfono es independiente de cada deporte preferido. Si un usuario tiene dos teléfonos y dos deportes, se necesitan cuatro combinaciones. usuario →→ telefono y usuario →→ deporte. usuario no identifica una combinación, por lo que se separan UsuarioTelefono y UsuarioDeporte. No debe suponerse independencia cuando el teléfono pertenece a un contacto específico por deporte.

Quinta forma normal

5FN, o forma normal de proyección y reunión, requiere que toda dependencia de reunión no trivial esté implicada por las claves candidatas. Una dependencia de reunión afirma que una relación equivale a la reunión de determinadas proyecciones. El problema puede requerir tres o más proyecciones y no se reduce siempre a divisiones binarias de 4FN (Fagin, 1979).

Ejemplo ilustrativo: Suministro(proveedor, tipoMaterial, sede). Supóngase que un triple es válido exactamente cuando son válidos sus tres pares: proveedor con tipo, proveedor con sede y tipo con sede. Con esa regla se separan ProveedorTipo, ProveedorSede y TipoSede. Si existe una autorización específica para cada triple, la regla no se cumple y la separación podría inventar suministros.

Aplicación en el proyecto

El préstamo deportivo se valida hasta FNBC respecto de las DF declaradas. Las formas 4FN y 5FN se investigan como fundamentos, pero no se atribuyen automáticamente al esquema ni se crean nuevas tablas sin reglas multivaluadas o de reunión que lo justifiquen. La tarea 4.2 muestra el proceso aplicado y sus límites.

Referencias

Fagin, R. (1977). Multivalued dependencies and a new normal form for relational databases. ACM Transactions on Database Systems, 2(3), 262–278. https://doi.org/10.1145/320557.320571

Fagin, R. (1979). Normal forms and relational database operators. Proceedings of the 1979 ACM SIGMOD International Conference on Management of Data, 153–160. https://research.ibm.com/publications/normal-forms-and-relational-database-operators

Getta, J. R. (2026). Database normalization. CSCI235 Database Systems. https://documents.uow.edu.au/~jrg/235/slides/03databasenormalization/03databasenormalization.html

Silberschatz, A., Korth, H. F., y Sudarshan, S. (2006). Relational database design. Database system concepts (5.ª ed.), capítulo 7. McGraw-Hill. https://www.db-book.com/Previous-editions/db5/slide-dir/ch7.pdf

## Fuentes y exportaciones de los diagramas

- [Mapa_01_Dependencias.pdf](diagramas/Mapa_01_Dependencias.pdf)
- [Mapa_01_Dependencias.svg](diagramas/Mapa_01_Dependencias.svg)
- [Mapa_02_Formas_Normales.pdf](diagramas/Mapa_02_Formas_Normales.pdf)
- [Mapa_02_Formas_Normales.svg](diagramas/Mapa_02_Formas_Normales.svg)
- [Mapa_Conceptual_Normalizacion.drawio](diagramas/Mapa_Conceptual_Normalizacion.drawio)
- [Mapa_Conceptual_Normalizacion.pdf](diagramas/Mapa_Conceptual_Normalizacion.pdf)
