# Unidad 4 Normalización de bases de datos

Proyecto: préstamo de material deportivo universitario. Alumno: Jesús Armando Zendejo Altamirano.

## Tarea 4.1

- [Reporte PDF](Tarea_4_1/Reporte_Tarea_4_1_Normalizacion.pdf)
- [Documento editable](Tarea_4_1/Reporte_Tarea_4_1_Normalizacion.docx)
- [Desarrollo teórico](Tarea_4_1/documentacion.md)
- [Mapa conceptual editable](Tarea_4_1/diagramas/Mapa_Conceptual_Normalizacion.drawio)
- [Mapa vectorial PDF](Tarea_4_1/diagramas/Mapa_Conceptual_Normalizacion.pdf)

## Tarea 4.2

- [Reporte PDF](Tarea_4_2/Reporte_Tarea_4_2_Normalizacion_Aplicada.pdf)
- [Documento editable](Tarea_4_2/Reporte_Tarea_4_2_Normalizacion_Aplicada.docx)
- [Proceso analítico](Tarea_4_2/documentacion.md)
- [Proceso editable](Tarea_4_2/diagramas/Proceso_Normalizacion.drawio)
- [SQL normalizado](Tarea_4_2/sql/normalized_schema.sql)
- [Comprobación analítica](Tarea_4_2/comprobacion/README.md)

El esquema final conserva las nueve tablas de U3 porque el diseño previo ya había separado correctamente estos hechos. El análisis parte de una hoja agrupada del mismo caso; no modifica la historia de ejecución de U3.

## SQL Server

Base nueva: PrestamosDeportivosU4. Orden: 00_crear_base.sql, normalized_schema.sql, 02_operaciones.sql, 03_datos_ejemplo.sql, 04_pruebas_integridad.sql y 05_verificar_esquema.sql. Abrir en SSMS y ejecutar cada archivo completo con F5; detenerse ante cualquier error. No se borran bases existentes y no es una migración.

Estado del SQL: revisado estáticamente; ejecución y validación real en SQL Server pendientes. Las comprobaciones analíticas son cálculos del modelo y ejemplos, no resultados del SGBD. Los datos de ejemplo son ficticios.
