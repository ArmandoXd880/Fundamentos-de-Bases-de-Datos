# Esquema físico del préstamo deportivo

El esquema conserva el proyecto de las unidades 2 y 3.1. El reporte PDF reúne el diccionario completo, las decisiones físicas y las capturas de SQL Server. `schema.sql` contiene la definición formal y las operaciones transaccionales.

## Tablas y claves

| Tabla | PK | FK y claves alternativas |
| --- | --- | --- |
| Usuario | idUsuario | Datos comunes de las personas. |
| UsuarioTelefono | idUsuario, telefono | idUsuario referencia Usuario. |
| Alumno | idUsuario | PK compartida y FK a Usuario; matricula UNIQUE. |
| Trabajador | idUsuario | PK compartida y FK a Usuario; numeroEmpleado UNIQUE. |
| TipoMaterial | idTipo | Nombre y deporte de la categoría. |
| Ejemplar | idEjemplar | idTipo referencia TipoMaterial; codigoInventario UNIQUE. |
| Prestamo | idPrestamo | idSolicitante referencia Usuario; idRegistrador referencia Trabajador. |
| DetallePrestamo | idPrestamo, numeroRenglon | FK a Prestamo y Ejemplar; UNIQUE(idPrestamo, idEjemplar). |
| Incidencia | idIncidencia | FK compuesta (idPrestamo, numeroRenglon) a DetallePrestamo. |

## Integridad

- Cada PK identifica una fila y es no nula; las FK obligatorias son NOT NULL.
- CHECK valida textos obligatorios, estados, número de renglón, nacimiento no futuro, orden de fechas en la cabecera y devolución con ambos datos.
- `UX_DetallePrestamo_EjemplarAbierto` evita dos detalles abiertos de la misma pieza.
- Las eliminaciones de teléfonos y perfiles de un usuario sin historial usan CASCADE. Las referencias al historial usan NO ACTION.
- Cambiar idTipo se propaga a Ejemplar mediante ON UPDATE CASCADE.
- Los procedimientos transaccionales comprueban totalidad de perfiles, mínimo de un detalle, usuario activo, registrador habilitado, disponibilidad y fechas entre tablas.
- El rol de aplicación escribe mediante esos procedimientos. Una cuenta propietaria con DML directo conserva la responsabilidad de respetar las reglas globales.

## Evidencias del reporte

| Evidencia | Archivo |
| --- | --- |
| Creación de la base | [E1_Creacion_Base.png](evidencias/E1_Creacion_Base.png) |
| Creación de tablas y procedimientos | [E1_Creacion_Tablas.png](evidencias/E1_Creacion_Tablas.png) |
| Diagrama generado por el SGBD | [Diagrama_Fisico_SQL_Server.png](diagramas/Diagrama_Fisico_SQL_Server.png) |
| Datos ficticios cargados | [E3_Datos_Ejemplo.png](evidencias/E3_Datos_Ejemplo.png) |
| Pruebas y resumen de restricciones | [E4_Pruebas_y_Verificacion.png](evidencias/E4_Pruebas_y_Verificacion.png) |

La ejecución muestra veinte casos correctos, cero fallidos y un esquema de nueve tablas, nueve PK, nueve FK y veinte CHECK. Los valores son los resultados observados en las capturas entregadas por el alumno. El diagrama corresponde al mismo modelo del proyecto; la base de grabación permite repetir su creación en un espacio separado de la base original.
