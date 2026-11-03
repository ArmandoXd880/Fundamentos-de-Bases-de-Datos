# Tarea 3.2 Diseño físico y validación en SQL Server

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 3 Modelo relacional

Tarea 3 2

Esquema físico en SQL Server y script LDD

Proyecto Préstamo de material deportivo universitario

EJECUCIÓN Y VALIDACIÓN REALIZADAS EN SQL SERVER

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 3

Maestro: Ruben Riojas

Diseño físico y estado de validación

El diseño físico corresponde al esquema relacional de la tarea 3.1 y utiliza SQL Server. schema.sql define nueve tablas, nueve claves primarias, nueve claves foráneas, cuatro restricciones UNIQUE y veinte CHECK, además de índices y una vista para calcular la edad. El uso de objetos y tipos sigue la sintaxis Transact-SQL (Microsoft, s. f.-a).

Estado de ejecución

El esquema se ejecutó en SQL Server Express. Las capturas de la sesión muestran la creación de la base, las nueve tablas, el diagrama físico generado por SSMS y el resultado de veinte pruebas correctas, sin fallas. Las evidencias E1 a E4 están integradas en el reporte técnico final en PDF.

| Dato de la ejecución | Registro |
| --- | --- |
| Motor y versión reales | SQL Server Express 16.0.1000.6 |
| Fecha y hora de ejecución | 2 de noviembre de 2026, 18:43 (validación) |
| Resultado de creación limpia | Base y nueve tablas creadas |
| Resultado de los veinte casos de prueba | 20 correctas, 0 fallidas |
| Diagrama físico generado por SSMS | Realizado y capturado |

Decisiones físicas

Se utiliza int para identificadores y numeroRenglon; date para fechaNacimiento; datetime2(0) para eventos con hora; bit para los indicadores; nvarchar para nombres y descripciones, y varchar para códigos y estados. Los identificadores de entidades fuertes se generan con IDENTITY, excepto idTipo, que es un código de catálogo asignado explícitamente y permite demostrar ON UPDATE CASCADE.

La PK del detalle se conserva compuesta. La edad se obtiene de vwUsuarioEdad y no se almacena como una columna fija. Los teléfonos se mantienen en UsuarioTelefono. Solo segundoApellido y los dos datos de devolución permiten NULL.

Diccionario de datos de usuarios y perfiles

| Tabla y columna | Tipo SQL | NULL | Clave y definición |
| --- | --- | --- | --- |
| Usuario.idUsuario | int | No | PK; IDENTITY |
| Usuario.nombres | nvarchar(80) | No | Valor obligatorio y no vacío si es texto |
| Usuario.primerApellido | nvarchar(60) | No | Valor obligatorio y no vacío si es texto |
| Usuario.segundoApellido | nvarchar(60) | Sí | Opcional |
| Usuario.fechaNacimiento | date | No | No futura |
| Usuario.activo | bit | No | Valor obligatorio y no vacío si es texto |
| UsuarioTelefono.idUsuario | int | No | PK; FK a Usuario |
| UsuarioTelefono.telefono | varchar(20) | No | PK |
| Alumno.idUsuario | int | No | PK; FK a Usuario |
| Alumno.matricula | varchar(20) | No | UNIQUE |
| Alumno.carrera | nvarchar(100) | No | Valor obligatorio y no vacío si es texto |
| Trabajador.idUsuario | int | No | PK; FK a Usuario |
| Trabajador.numeroEmpleado | varchar(20) | No | UNIQUE |
| Trabajador.adscripcion | nvarchar(100) | No | Valor obligatorio y no vacío si es texto |
| Trabajador.habilitadoRegistro | bit | No | Valor obligatorio y no vacío si es texto |

Las claves de cada subtipo también son FK. Los teléfonos se identifican dentro de su usuario.

Diccionario de inventario y cabecera del préstamo

| Tabla y columna | Tipo SQL | NULL | Clave y definición |
| --- | --- | --- | --- |
| TipoMaterial.idTipo | int | No | PK |
| TipoMaterial.nombre | nvarchar(80) | No | Valor obligatorio y no vacío si es texto |
| TipoMaterial.deporte | nvarchar(60) | No | Valor obligatorio y no vacío si es texto |
| Ejemplar.idEjemplar | int | No | PK; IDENTITY |
| Ejemplar.codigoInventario | varchar(30) | No | UNIQUE |
| Ejemplar.idTipo | int | No | FK a TipoMaterial |
| Ejemplar.estadoOperativo | varchar(15) | No | Dominio con CHECK |
| Prestamo.idPrestamo | int | No | PK; IDENTITY |
| Prestamo.idSolicitante | int | No | FK a Usuario |
| Prestamo.idRegistrador | int | No | FK a Trabajador |
| Prestamo.fechaSalida | datetime2(0) | No | Valor obligatorio y no vacío si es texto |
| Prestamo.fechaLimite | datetime2(0) | No | No anterior a fechaSalida |

Dominios de inventario

estadoOperativo admite apto, mantenimiento y baja. Los códigos y los textos obligatorios deben ser no vacíos. fechaLimite debe ser igual o posterior a fechaSalida. Las FK de Prestamo son obligatorias y protegen la identidad del solicitante y del trabajador registrador.

Diccionario del detalle y de las incidencias

| Tabla y columna | Tipo SQL | NULL | Clave y definición |
| --- | --- | --- | --- |
| DetallePrestamo.idPrestamo | int | No | PK; FK a Prestamo |
| DetallePrestamo.numeroRenglon | int | No | PK; Entero positivo |
| DetallePrestamo.idEjemplar | int | No | FK a Ejemplar |
| DetallePrestamo.condicionSalida | nvarchar(150) | No | Valor obligatorio y no vacío si es texto |
| DetallePrestamo.fechaDevolucion | datetime2(0) | Sí | Opcional; Se informan juntos |
| DetallePrestamo.condicionEntrada | nvarchar(150) | Sí | Opcional; Se informan juntos |
| Incidencia.idIncidencia | int | No | PK; IDENTITY |
| Incidencia.idPrestamo | int | No | FK a DetallePrestamo |
| Incidencia.numeroRenglon | int | No | FK a DetallePrestamo; Entero positivo |
| Incidencia.fechaReporte | datetime2(0) | No | Valor obligatorio y no vacío si es texto |
| Incidencia.descripcion | nvarchar(500) | No | Valor obligatorio y no vacío si es texto |
| Incidencia.estado | varchar(10) | No | Dominio con CHECK |

DetallePrestamo declara también UNIQUE(idPrestamo, idEjemplar). Su índice único filtrado permite como máximo un detalle abierto por ejemplar. Incidencia utiliza una FK compuesta sobre idPrestamo y numeroRenglon; su estado admite abierta o resuelta.

Integridad acciones referenciales y operaciones

| Tabla hija | Referencia | DELETE | UPDATE |
| --- | --- | --- | --- |
| UsuarioTelefono | idUsuario → Usuario.idUsuario | CASCADE | NO ACTION |
| Alumno | idUsuario → Usuario.idUsuario | CASCADE | NO ACTION |
| Trabajador | idUsuario → Usuario.idUsuario | CASCADE | NO ACTION |
| Ejemplar | idTipo → TipoMaterial.idTipo | NO ACTION | CASCADE |
| Prestamo | idSolicitante → Usuario.idUsuario | NO ACTION | NO ACTION |
| Prestamo | idRegistrador → Trabajador.idUsuario | NO ACTION | NO ACTION |
| DetallePrestamo | idPrestamo → Prestamo.idPrestamo | NO ACTION | NO ACTION |
| DetallePrestamo | idEjemplar → Ejemplar.idEjemplar | NO ACTION | NO ACTION |
| Incidencia | idPrestamo + numeroRenglon → DetallePrestamo.idPrestamo + numeroRenglon | NO ACTION | NO ACTION |

La cascada de eliminación en teléfonos y perfiles permite retirar a un usuario sin historial. Si tiene préstamos como solicitante o registrador, NO ACTION bloquea la eliminación y la operación se revierte. Los préstamos, detalles e incidencias se conservan; no se usa borrado en cascada en el historial (Microsoft, s. f.-d).

Actualizar idTipo propaga el nuevo código hacia Ejemplar. Las otras claves de entidades se tratan como identidades estables. Las rutas de cascada se limitan para evitar ciclos o múltiples rutas de actualización o eliminación en SQL Server.

Restricciones entre tablas

02_operaciones.sql añade cuatro procedimientos transaccionales. uspCrearUsuario crea la identidad y al menos un perfil; uspRegistrarPrestamo crea una cabecera y uno o más detalles, comprobando actividad, habilitación y disponibilidad; uspDevolverEjemplar y uspRegistrarIncidencia comprueban sus fechas contra la salida.

El rol de aplicación tiene acceso de escritura mediante esos procedimientos y no mediante DML directo sobre las tablas. La totalidad de perfiles y el mínimo de un detalle se garantizan en esa interfaz. Un propietario o administrador conserva la capacidad de ejecutar DML directo y debe respetar las reglas; las PK, FK y CHECK por sí solas no sustituyen esa validación.

Validación prevista del esquema

04_pruebas_integridad.sql contiene veinte casos para comprobar aceptación y rechazo de operaciones, PK, FK, CHECK, NOT NULL, unicidad, FK compuesta, cascadas y reglas de negocio. Cada caso se ejecuta en una transacción que se revierte. La tabla de resultados se calcula en la instancia al ejecutar el archivo; no incluye resultados precargados.

05_verificar_esquema.sql consulta los catálogos sys para obtener la versión real, columnas, claves, CHECK, acciones referenciales y el índice filtrado. DBCC CHECKCONSTRAINTS comprueba las restricciones declarativas sobre los datos presentes; no comprueba por sí solo todas las reglas implementadas en procedimientos.

Unicidad de entregas abiertas

UX_DetallePrestamo_EjemplarAbierto es un índice único sobre idEjemplar con el filtro fechaDevolucion IS NULL. La restricción se aplica a las entregas pendientes y permite múltiples entregas históricas ya cerradas (Microsoft, s. f.-b).

Referencias

Microsoft (s. f.-a). CREATE TABLE Transact SQL. https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql

Microsoft (s. f.-b). Create filtered indexes. https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes

Microsoft (s. f.-c). Create a new database diagram. https://learn.microsoft.com/en-us/ssms/visual-db-tools/create-a-new-database-diagram-visual-database-tools

Microsoft (s. f.-d). Primary and foreign key constraints. https://learn.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints

E1 Creación limpia y entorno real

Evidencia real integrada en el reporte PDF final (captura de SQL Server).

Captura de SSMS con schema.sql ejecutado, mensajes reales y las nueve tablas del proyecto. Motor, versión y fecha deben corresponder a la instancia utilizada.

E2 Diagrama físico generado por el SGBD

[EVIDENCIA REAL PENDIENTE DE INSERTAR]

Captura real del diagrama de SSMS con las nueve tablas, columnas, claves y relaciones. Nombre del diagrama: Diagrama_Prestamos_U3.

E3 Validación del catálogo y de las restricciones

[EVIDENCIA REAL PENDIENTE DE INSERTAR]

Captura real de los resultados de 05_verificar_esquema.sql, con claves, acciones referenciales y restricciones activas.

E4 Resultado real de los casos de prueba

[EVIDENCIA REAL PENDIENTE DE INSERTAR]

Captura real de 04_pruebas_integridad.sql con los casos y el resumen de pruebas correctas y fallidas. El resultado no se declara hasta ejecutar el archivo.

## Fuentes y exportaciones de los diagramas

