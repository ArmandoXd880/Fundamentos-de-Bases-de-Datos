# Tarea 2.1 Modelado conceptual E R y E R extendido

Alumno: Jesús Armando Zendejo Altamirano  
Materia: Fundamentos de Bases de Datos  
Docente: Ruben Riojas

Unidad 2 Diseño de bases de datos con el modelo E R

Tarea 2 1

Modelado conceptual E R y E R extendido

Caso de estudio Préstamo de material deportivo universitario

Nombre: Jesús Armando Zendejo Altamirano

Materia: FUNDAMENTOS DE BASES DE DATOS

Unidad: 2

Maestro: Ruben Riojas

Planteamiento del problema y contexto

El préstamo de balones, raquetas y otros materiales deportivos en una universidad requiere relacionar a las personas con cada pieza entregada. Registrar únicamente cantidades por tipo no permite distinguir qué ejemplar recibió un usuario, cuál regresó ni qué daño corresponde a una entrega específica. El problema de diseño consiste en conservar esas relaciones y su historial sin confundir el catálogo de materiales con las unidades físicas.

Este caso se sitúa en el entorno universitario del Campus Monclova. El alcance y las reglas siguientes son una propuesta de funcionamiento para delimitar el modelo; no se presentan como resultados de entrevistas ni como una política institucional ya verificada.

Objetivo del diseño

Diseñar un modelo conceptual que identifique solicitantes, personal registrador, tipos de material, ejemplares, préstamos, devoluciones por pieza e incidencias. El sistema debe permitir conocer quién tiene una pieza y reconstruir sus entregas anteriores.

Actores y alcance

El solicitante es un usuario activo con perfil de alumno, trabajador o ambos. El registrador es un trabajador habilitado. La coordinación mantiene el catálogo y el estado operativo de las piezas. Una misma persona puede ser estudiante y trabajadora, sin duplicar su identidad.

Se incluyen préstamos ya formalizados, con al menos una pieza, y devoluciones parciales. Se excluyen reservas futuras, multas monetarias, compras, bajas contables y autenticación técnica. Esas funciones podrían ampliarse sin alterar la distinción entre tipo de material y ejemplar.

Recorrido de un préstamo

1. El trabajador verifica al solicitante y selecciona ejemplares aptos y disponibles.

2. Registra la cabecera del préstamo, las fechas y un detalle por pieza, con su condición de salida.

3. Al devolver una pieza, completa fechaDevolucion y condicionEntrada de ese detalle; los demás pueden seguir abiertos.

4. Si detecta un daño o faltante, registra una incidencia vinculada a la entrega concreta y conserva su resolución.

Reglas de negocio

Las reglas delimitan las decisiones del caso y permiten comprobar el modelo. Las restricciones temporales y de autorización requieren validación adicional a las cardinalidades.

| Regla | Descripción |
| --- | --- |
| RN01 | Todo usuario se identifica por idUsuario. Pertenece a Alumno, a Trabajador o a ambos; se conserva una sola identidad. |
| RN02 | La matrícula identifica de forma alternativa a cada alumno y el número de empleado a cada trabajador. Ambos subtipos heredan idUsuario. |
| RN03 | Solo un usuario activo puede solicitar un préstamo. Cada préstamo formalizado tiene un solicitante y un trabajador con habilitadoRegistro verdadero. |
| RN04 | Un usuario puede no tener préstamos o solicitar varios a lo largo del tiempo. Un trabajador puede registrar cero o varios préstamos. |
| RN05 | Cada préstamo formalizado contiene uno o más detalles. Cada detalle pertenece a un solo préstamo y se numera de forma única dentro de él. |
| RN06 | Cada detalle corresponde a un ejemplar. Un ejemplar puede aparecer en muchos detalles históricos, pero solo en uno pendiente de devolución. |
| RN07 | Un mismo ejemplar no puede repetirse dentro de un préstamo. Para volver a prestarlo debe cerrarse su detalle anterior y abrir otro préstamo. |
| RN08 | Cada ejemplar pertenece exactamente a un tipo de material. Un tipo puede existir sin ejemplares o agrupar varios. |
| RN09 | fechaLimite no puede preceder a fechaSalida. Una fechaDevolucion registrada no puede ser anterior a fechaSalida. |
| RN10 | Solo se presta un ejemplar con estadoOperativo apto y sin detalle abierto. Los otros estados admitidos son mantenimiento y baja. |
| RN11 | Se registra condicionSalida al entregar cada pieza. fechaDevolucion y condicionEntrada deben estar ambas vacías o ambas informadas. |
| RN12 | Cada incidencia se vincula a una asignación concreta de ejemplar a detalle. Una asignación puede tener cero o varias incidencias; su estado es abierta o resuelta. |
| RN13 | fechaReporte de una incidencia no puede preceder a fechaSalida del préstamo al que pertenece su detalle. |
| RN14 | Los registros históricos no se eliminan al devolver material. La edad se calcula desde fechaNacimiento; los teléfonos son un conjunto opcional sin duplicados. |

Entidades atributos e identificación

Se emplea notación Chen con extensiones ERE. Las entidades se distinguen por sus claves; las relaciones describen asociaciones del entorno (Chen, 1976). UK identifica una clave alternativa, no una segunda clave primaria.

| Entidad | Tipo | Identificación | Otros atributos y función |
| --- | --- | --- | --- |
| Usuario | Fuerte | idUsuario | nombre compuesto, fechaNacimiento, edad derivada, telefonos multivalorado y activo. |
| Alumno | Subtipo | idUsuario heredada; matrícula UK | carrera. Comparte los datos y relaciones de Usuario. |
| Trabajador | Subtipo | idUsuario heredada; número de empleado UK | adscripcion y habilitadoRegistro. Puede solicitar y registrar préstamos. |
| Prestamo | Fuerte | idPrestamo | fechaSalida y fechaLimite. Se vincula a solicitante y registrador. |
| DetallePrestamo | Débil | idPrestamo del dueño + numeroRenglon | condicionSalida; fechaDevolucion y condicionEntrada opcionales. |
| TipoMaterial | Fuerte | idTipo | nombre y deporte. Clasifica piezas físicas semejantes. |
| Ejemplar | Fuerte | idEjemplar; código de inventario UK | estadoOperativo. Representa una pieza física identificable. |
| Incidencia | Fuerte | idIncidencia | fechaReporte, descripcion y estado. Conserva el contexto de una entrega. |

Tipos especiales de atributos

Clave: idUsuario distingue al usuario. Compuesto: nombre se divide en nombres, primerApellido y segundoApellido, este último opcional. Derivado: edad se obtiene de fechaNacimiento contando años cumplidos a la fecha de consulta. Multivalorado: telefonos admite de cero a varios valores distintos. La fecha de nacimiento no puede ser futura.

DetallePrestamo es débil: numeroRenglon es solo una clave parcial. El mismo número puede repetirse en préstamos distintos; su identificación completa combina al propietario con ese número. Los subtipos heredan la clave de Usuario y no crean una identidad independiente.

Relaciones cardinalidades y participación

En el diagrama E-R, el par escrito junto a una entidad indica cuántas veces participa una instancia de esa entidad en la relación. El mínimo cero señala participación parcial; el mínimo uno, participación total. N significa varios.

| Relación | Primer extremo | Segundo extremo | Participación y regla |
| --- | --- | --- | --- |
| solicita | Usuario (0,N) | Prestamo (1,1) | Usuario parcial; Prestamo total. RN03 y RN04. |
| registra | Trabajador (0,N) | Prestamo (1,1) | Trabajador parcial; Prestamo total. Se exige habilitación. |
| contiene | Prestamo (1,N) | DetallePrestamo (1,1) | Total en ambos extremos; relación identificadora. RN05. |
| corresponde | DetallePrestamo (1,1) | Ejemplar (0,N) | Detalle total; Ejemplar parcial. RN06 y RN07. |
| clasifica | TipoMaterial (0,N) | Ejemplar (1,1) | Tipo parcial; Ejemplar total. RN08. |
| documenta | Asignación agregada (0,N) | Incidencia (1,1) | Agregado parcial; Incidencia total. RN12. |

Restricciones que no expresa una cardinalidad aislada

La relación histórica entre Ejemplar y DetallePrestamo es de uno a muchos. La disponibilidad actual exige, además, que el número de detalles sin fechaDevolucion para cada ejemplar sea como máximo uno. Dentro de un mismo préstamo, la pareja formada por préstamo y ejemplar debe ser única.

También se valida que el registrador esté habilitado, que el solicitante esté activo y que las fechas y las condiciones de entrada cumplan las reglas RN09 a RN13. Estas condiciones son restricciones del modelo aunque no se representen con un rombo adicional.

Modelo E R extendido del préstamo deportivo

Figura 1. Estructura E-R extendida con cardinalidades, entidad débil, especialización y agregación. Elaboración propia.

Atributos y jerarquía de Usuario

Figura 2. Atributos de Usuario y jerarquía total y superpuesta. Los subtipos conservan la misma identidad. Elaboración propia.

Atributos de préstamos inventario e incidencias

Figura 3. Atributos de los demás conjuntos de entidades. La clave parcial del detalle se combina con la del préstamo. Elaboración propia.

Justificación del modelo extendido

Especialización generalización y jerarquía

Usuario es el supertipo común de Alumno y Trabajador. La especialización es total porque todo usuario del alcance pertenece al menos a un subtipo, y superpuesta porque una persona puede pertenecer a ambos. Los atributos comunes se definen una sola vez. Vista de abajo hacia arriba, la misma jerarquía generaliza ambos perfiles en Usuario.

Agregación de una relación

El rectángulo discontinuo agrupa DetallePrestamo, corresponde y Ejemplar como una asignación concreta. documenta vincula Incidencia con esa asignación, de modo que un daño queda asociado a una entrega y no solo al ejemplar. La agregación abstrae una relación para participar en otra relación; no expresa por sí misma un vínculo de propiedad o borrado (Silberschatz et al., 2019).

Decisiones principales

TipoMaterial separa el catálogo de las piezas físicas. DetallePrestamo permite que una misma operación incluya varias piezas y que cada una regrese en un momento distinto. La identificación débil preserva su dependencia de la cabecera. La condición de salida se conserva como dato histórico y no se sustituye por el estado operativo actual del ejemplar.

Comprobación con escenarios

| Escenario | Resultado del modelo |
| --- | --- |
| Un alumno también trabaja en la universidad. | Un Usuario pertenece a los dos subtipos con el mismo idUsuario. |
| Un préstamo entrega dos balones y solo regresa uno. | Dos detalles; únicamente uno tiene fechaDevolucion y condicionEntrada. |
| Se intenta prestar una pieza ya entregada y no devuelta. | Se rechaza por RN06 y RN10, aunque la relación histórica admita varios detalles. |
| El mismo ejemplar vuelve a prestarse después de su devolución. | Se permite en un nuevo préstamo, conservando los detalles anteriores. |
| Aparece un daño en una devolución concreta. | Incidencia apunta al contexto de esa asignación mediante el detalle correspondiente. |

Herramienta de modelado y archivos del diseño

La herramienta CASE seleccionada es diagrams.net draw.io. La fuente nativa Modelo_ER_ERE_Deportes.drawio contiene tres hojas con formas, textos y conectores editables. Se acompaña de PDF vectorial, SVG y PNG a 300 ppp. La distribución en hojas separa la estructura global y los atributos para conservar su legibilidad; todas las hojas pertenecen al mismo modelo.

El formato drawio almacena el modelo gráfico en XML y puede abrirse de nuevo en el editor. El PDF permite consultar el resultado y el SVG mantiene líneas y texto vectoriales. La fuente editable se conserva junto con las exportaciones (JGraph Ltd., s. f.).

Conclusión

El diseño organiza el préstamo de material deportivo a partir de identidades, piezas físicas y entregas rastreables. Las cardinalidades establecen la estructura; las reglas temporales impiden préstamos simultáneos de una misma pieza. La especialización reconoce perfiles compartidos y la agregación conserva el contexto de cada incidencia.

Referencias

Chen, P. P. (1976). The entity relationship model toward a unified view of data. ACM Transactions on Database Systems, 1(1), 9–36. https://doi.org/10.1145/320434.320440

JGraph Ltd. (s. f.). Save a diagram in various formats. https://www.drawio.com/docs/manual/editor/save-file-formats/

Silberschatz, A., Korth, H. F., y Sudarshan, S. (2019). Database system concepts (7.ª ed.). McGraw-Hill. https://www.db-book.com/

## Fuentes y exportaciones de los diagramas

- [Diagramas_ER_ERE.pdf](diagramas/Diagramas_ER_ERE.pdf)
- [ER_ERE_01_Estructura.pdf](diagramas/ER_ERE_01_Estructura.pdf)
- [ER_ERE_01_Estructura.svg](diagramas/ER_ERE_01_Estructura.svg)
- [ER_ERE_02_Usuario.pdf](diagramas/ER_ERE_02_Usuario.pdf)
- [ER_ERE_02_Usuario.svg](diagramas/ER_ERE_02_Usuario.svg)
- [ER_ERE_03_Atributos.pdf](diagramas/ER_ERE_03_Atributos.pdf)
- [ER_ERE_03_Atributos.svg](diagramas/ER_ERE_03_Atributos.svg)
- [Modelo_ER_ERE_Deportes.drawio](diagramas/Modelo_ER_ERE_Deportes.drawio)
