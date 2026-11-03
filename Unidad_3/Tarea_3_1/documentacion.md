# Tarea 3.1 Modelo relacional

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 3 Modelo relacional

Tarea 3 1

Transformación del modelo E R y reglas de integridad

Proyecto Préstamo de material deportivo universitario

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 3

Maestro: Ruben Riojas

Componentes formales del modelo relacional

El modelo relacional organiza la información en relaciones. Cada relación tiene atributos con dominios definidos y contiene tuplas. En la formulación clásica, una relación es un conjunto de tuplas: no admite duplicados ni un orden intrínseco de filas o atributos. SQL incorpora convenciones adicionales que deben controlarse mediante restricciones (Codd, 1970; Silberschatz et al., 2019).

| Componente | Definición y ejemplo del proyecto |
| --- | --- |
| Relación | Conjunto de tuplas con un mismo esquema. UsuarioTelefono describe los teléfonos asociados a cada usuario. |
| Atributo | Propiedad identificada por un nombre. Ejemplos: idUsuario y telefono. |
| Dominio | Valores permitidos para un atributo. idUsuario usa enteros positivos; telefono, texto no vacío de hasta 20 caracteres. |
| Tupla | Una ocurrencia válida de la relación. Ejemplo ilustrativo: (1, 8661000001) en UsuarioTelefono. |
| Esquema e instancia | El esquema fija la estructura; la instancia es el conjunto de tuplas existente en un momento dado. |
| Grado y cardinalidad | UsuarioTelefono tiene grado 2. Su cardinalidad es la cantidad de teléfonos registrados, que cambia con los datos. |

Formulación

Si R = (A1, A2, ..., An), una instancia r de R es un subconjunto de dom(A1) × dom(A2) × ... × dom(An). Cada tupla t asigna a cada atributo Ai un valor de su dominio. Para UsuarioTelefono: r ⊆ DIdUsuario × DTelefono.

La clave candidata es una superclave mínima. La clave primaria se selecciona entre las candidatas; las demás pueden declararse UNIQUE. Una clave foránea exige que los valores referenciados existan en una clave primaria o alternativa de la relación padre.

Valores opcionales en SQL

NULL es un marcador de ausencia o desconocimiento de SQL; no equivale a cero ni a texto vacío. segundoApellido y los dos campos de devolución son opcionales. Las claves primarias y las FK obligatorias del proyecto se declaran NOT NULL. Los teléfonos se separan en otra tabla para mantener valores atómicos.

Método de conversión desde la Unidad 2

Se conserva el caso de préstamo deportivo, sus ocho conjuntos de entidades y las reglas RN01 a RN14. La transformación produce nueve tablas: se añade UsuarioTelefono para el atributo multivalorado y no se almacena edad como dato fijo.

| Elemento conceptual | Conversión aplicada |
| --- | --- |
| Entidad fuerte | Una tabla para Usuario, TipoMaterial, Ejemplar, Prestamo e Incidencia, conservando su identificador. |
| Atributo compuesto | nombre se descompone en nombres, primerApellido y segundoApellido dentro de Usuario. |
| Atributo multivalorado | telefonos produce UsuarioTelefono. Su PK compuesta evita repetir el mismo valor para un usuario. |
| Atributo derivado | edad se calcula desde fechaNacimiento en una vista; no se agrega una columna almacenada. |
| Jerarquía total y superpuesta | Usuario más Alumno y Trabajador. Cada subtipo utiliza idUsuario como PK y FK y admite la misma identidad en ambos. |
| Relación 1 a 1 | Entre Usuario y cada subtipo, la PK compartida limita a un registro de ese subtipo por usuario. La unión de subtipos debe cubrir a Usuario. |
| Relación 1 a N | La PK del lado uno se propaga como FK al lado varios: TipoMaterial a Ejemplar; Usuario y Trabajador a Prestamo. |
| Relación N a M | La asociación histórica entre Prestamo y Ejemplar se resuelve mediante DetallePrestamo con dos FK. Se conserva la numeración del detalle. |
| Entidad débil | DetallePrestamo usa la PK del propietario más numeroRenglon. No se cambia por una identidad independiente. |
| Agregación ERE | La asignación queda representada por el detalle y su ejemplar; Incidencia referencia la PK compuesta del detalle. No se duplica una tabla Asignacion. |

No se añaden relaciones ficticias para ilustrar reglas generales. El caso contiene las relaciones uno a varios, los vínculos uno a uno de la jerarquía y la asociación muchos a muchos resuelta por su detalle.

Formulación del esquema y claves primarias

Usuario

Usuario(idUsuario, nombres, primerApellido, segundoApellido, fechaNacimiento, activo).

PK: idUsuario.

UsuarioTelefono

UsuarioTelefono(idUsuario, telefono).

PK: idUsuario + telefono.

Alumno

Alumno(idUsuario, matricula, carrera).

PK: idUsuario.

Trabajador

Trabajador(idUsuario, numeroEmpleado, adscripcion, habilitadoRegistro).

PK: idUsuario.

TipoMaterial

TipoMaterial(idTipo, nombre, deporte).

PK: idTipo.

Ejemplar

Ejemplar(idEjemplar, codigoInventario, idTipo, estadoOperativo).

PK: idEjemplar.

Prestamo

Prestamo(idPrestamo, idSolicitante, idRegistrador, fechaSalida, fechaLimite).

PK: idPrestamo.

DetallePrestamo

DetallePrestamo(idPrestamo, numeroRenglon, idEjemplar, condicionSalida, fechaDevolucion, condicionEntrada).

PK: idPrestamo + numeroRenglon.

Incidencia

Incidencia(idIncidencia, idPrestamo, numeroRenglon, fechaReporte, descripcion, estado).

PK: idIncidencia.

El símbolo + expresa una clave compuesta, no una suma aritmética.

Llaves foráneas y claves alternativas

| Tabla hija | FK | Clave referenciada |
| --- | --- | --- |
| UsuarioTelefono | idUsuario | Usuario.idUsuario |
| Alumno | idUsuario | Usuario.idUsuario |
| Trabajador | idUsuario | Usuario.idUsuario |
| Ejemplar | idTipo | TipoMaterial.idTipo |
| Prestamo | idSolicitante | Usuario.idUsuario |
| Prestamo | idRegistrador | Trabajador.idUsuario |
| DetallePrestamo | idPrestamo | Prestamo.idPrestamo |
| DetallePrestamo | idEjemplar | Ejemplar.idEjemplar |
| Incidencia | idPrestamo + numeroRenglon | DetallePrestamo.idPrestamo + numeroRenglon |

Claves alternativas y unicidad

Alumno.matricula, Trabajador.numeroEmpleado y Ejemplar.codigoInventario se declaran UNIQUE. DetallePrestamo también declara UNIQUE(idPrestamo, idEjemplar), porque la misma pieza no puede repetirse dentro de un préstamo. UsuarioTelefono no requiere otra clave: su PK ya evita teléfonos duplicados por usuario.

Cardinalidad mínima y obligatoriedad

Las FK NOT NULL hacen obligatoria la referencia desde la tabla hija. Una FK por sí sola no exige que un padre tenga hijos: no garantiza que Usuario tenga un perfil ni que Prestamo contenga al menos un detalle. Esas dos condiciones se conservan como restricciones globales y se implementan mediante operaciones transaccionales en la tarea 3.2.

Esquema relacional de usuarios y préstamos

Figura 1. Esquema relacional y propagación de claves de los usuarios y los préstamos. Diseño lógico, no captura de un SGBD.

Esquema relacional del inventario y del historial

Figura 2. Inventario, detalle e incidencia con referencia compuesta. Diseño lógico, no captura de un SGBD.

Restricciones de integridad del proyecto

| Tipo | Aplicación |
| --- | --- |
| Entidad | Cada PK es única y no nula. La PK del detalle combina idPrestamo y numeroRenglon. |
| Referencial | Cada FK debe identificar una fila existente. Incidencia debe señalar un detalle completo, no solo una cabecera. |
| Dominio | Tipos, longitudes, NOT NULL, valores no vacíos, estados permitidos y coherencia de fechas por fila. |
| Unicidad condicional | Cada ejemplar puede figurar como máximo en un detalle cuya fechaDevolucion sea NULL. |
| Restricciones globales | Todo Usuario pertenece a Alumno o Trabajador o ambos; cada préstamo formalizado contiene uno o más detalles. |

Expresión de las reglas globales

Los identificadores de Usuario son exactamente la unión de los identificadores de Alumno y Trabajador. La intersección de los subtipos puede contener identificadores, porque la especialización es superpuesta. Para cada préstamo p debe existir al menos un detalle d con d.idPrestamo = p.idPrestamo.

Para cada ejemplar e, la cantidad de detalles con d.idEjemplar = e.idEjemplar y d.fechaDevolucion ausente es como máximo uno. El número de renglón es positivo y la pareja formada por préstamo y ejemplar no se repite.

Coherencia temporal y conservación del historial

fechaLimite no precede a fechaSalida. Las fechas de devolución e incidencia tampoco pueden preceder a la salida correspondiente. Los dos datos de devolución se completan juntos. Devolver una pieza actualiza su detalle; no elimina los registros históricos.

Justificación y resultado del mapeo

El esquema distingue categorías de material y piezas físicas, conserva la identidad común de cada persona y permite consultar el historial de las entregas. La PK compuesta del detalle mantiene la identificación débil del modelo original; su FK compuesta en Incidencia conserva el contexto exacto del daño reportado.

La separación de teléfonos evita columnas repetidas. La descomposición del nombre conserva sus componentes sin convertirlos en entidades artificiales. Calcular la edad evita guardar un valor que se vuelve obsoleto con el tiempo.

Ejemplos de integridad

| Operación | Condición que debe cumplirse |
| --- | --- |
| Registrar un teléfono | Debe existir el usuario y no debe repetirse el mismo teléfono para él. |
| Registrar una incidencia | Debe existir el detalle indicado por las dos columnas de la FK. |
| Prestar de nuevo un ejemplar | El detalle anterior debe estar devuelto y la pieza debe estar apta. |
| Registrar una persona con dos perfiles | Se conserva un Usuario y un registro en cada subtipo con el mismo identificador. |

Conclusión

La transformación genera nueve relaciones con PK, FK y dominios explícitos. Las reglas de conversión preservan las cardinalidades y la jerarquía del caso. Las restricciones que requieren consultar varias tablas se distinguen de las que pueden expresarse directamente con claves y CHECK.

Referencias

Codd, E. F. (1970). A relational model of data for large shared data banks. Communications of the ACM, 13(6), 377–387. https://doi.org/10.1145/362384.362685

Microsoft (s. f.-a). CREATE TABLE Transact SQL. https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql

Microsoft (s. f.-d). Primary and foreign key constraints. https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints

Silberschatz, A., Korth, H. F., y Sudarshan, S. (2019). Database system concepts (7.ª ed.). McGraw-Hill. https://www.db-book.com/

## Fuentes y exportaciones de los diagramas

- [Esquema_Relacional_01.pdf](diagramas/Esquema_Relacional_01.pdf)
- [Esquema_Relacional_01.svg](diagramas/Esquema_Relacional_01.svg)
- [Esquema_Relacional_02.pdf](diagramas/Esquema_Relacional_02.pdf)
- [Esquema_Relacional_02.svg](diagramas/Esquema_Relacional_02.svg)
- [Esquema_Relacional_Deportes.drawio](diagramas/Esquema_Relacional_Deportes.drawio)
- [Esquema_Relacional_Deportes.pdf](diagramas/Esquema_Relacional_Deportes.pdf)
