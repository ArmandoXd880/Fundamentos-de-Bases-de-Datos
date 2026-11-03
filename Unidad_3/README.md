# Unidad 3 · Modelo relacional

**Alumno:** Jesús Armando Zendejo Altamirano  
**Materia:** Fundamentos de Bases de Datos  
**Docente:** Ruben Riojas  
**Proyecto:** Préstamo de material deportivo universitario.

## Tarea 3.1 · Modelo relacional y reglas de integridad

- [Reporte técnico PDF](Tarea_3_1/Reporte_Tarea_3_1_Modelo_Relacional.pdf)
- [Documento editable](Tarea_3_1/Reporte_Tarea_3_1_Modelo_Relacional.docx)
- [Documentación Markdown](Tarea_3_1/documentacion.md)
- [Diagrama del esquema relacional PDF](Tarea_3_1/diagramas/Esquema_Relacional_Deportes.pdf)
- [Fuente editable del diagrama](Tarea_3_1/diagramas/Esquema_Relacional_Deportes.drawio)

El reporte presenta componentes formales del modelo relacional, transformación del modelo E-R, claves primarias y foráneas, claves compuestas, jerarquía de usuarios y restricciones de integridad.

## Tarea 3.2 · Esquema físico en SQL Server

- [Reporte técnico con evidencias PDF](Tarea_3_2/Reporte_Tarea_3_2.pdf)
- [Documentación técnica](Tarea_3_2/documentacion.md)
- [Guía de ejecución](Tarea_3_2/README.md)
- [Script formal schema.sql](Tarea_3_2/sql/schema.sql)
- [01 · Creación de base de datos](Tarea_3_2/sql/01_crear_base.sql)
- [03 · Datos de ejemplo](Tarea_3_2/sql/03_datos_ejemplo.sql)
- [04 · Pruebas y verificación](Tarea_3_2/sql/04_pruebas_y_verificacion.sql)
- [Consulta complementaria del catálogo](Tarea_3_2/sql/Apoyo/Verificar_Catalogo_Completo.sql)
- [Diagrama físico generado en SSMS PNG](Tarea_3_2/diagramas/Diagrama_Fisico_SQL_Server.png)
- [Diagrama físico PDF](Tarea_3_2/diagramas/Diagrama_Fisico_SQL_Server.pdf)

### Capturas de la ejecución

- [E1 · Creación de base de datos](Tarea_3_2/evidencias/E1_Creacion_Base.png)
- [E1 · Creación de tablas](Tarea_3_2/evidencias/E1_Creacion_Tablas.png)
- [E3 · Datos de ejemplo](Tarea_3_2/evidencias/E3_Datos_Ejemplo.png)
- [E4 · Pruebas y verificación](Tarea_3_2/evidencias/E4_Pruebas_y_Verificacion.png)

### Video

- [Video de la tarea 3.2 en YouTube](https://youtu.be/TIleC__uPwQ)

La ejecución está documentada en SQL Server 2022, versión 16.0.1000.6. Las evidencias muestran nueve tablas, nueve PK, nueve FK, veinte CHECK y un resultado de veinte pruebas correctas y cero fallidas. Las FK y CHECK del resumen aparecen activas y validadas.

La base `PrestamosDeportivosU3_Grabacion` permite demostrar la creación limpia del mismo esquema del proyecto, conservando la base original `PrestamosDeportivosU3`.
