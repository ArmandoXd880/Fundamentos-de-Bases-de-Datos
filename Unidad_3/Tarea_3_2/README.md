# Tarea 3.2 · Esquema físico y script LDD

## Archivos de la entrega

| Archivo | Contenido |
| --- | --- |
| [Reporte_Tarea_3_2.pdf](Reporte_Tarea_3_2.pdf) | Diccionario de datos, decisiones físicas, cascadas y evidencias reales de ejecución. |
| [sql/schema.sql](sql/schema.sql) | CREATE TABLE, PK, FK, UNIQUE, CHECK, NOT NULL, índices, vista y operaciones transaccionales. |
| [Diagrama PNG](diagramas/Diagrama_Fisico_SQL_Server.png) | Captura del diagrama físico de SSMS incluida en el reporte. |
| [Diagrama PDF](diagramas/Diagrama_Fisico_SQL_Server.pdf) | Página del reporte que contiene el diagrama generado por el SGBD. |
| [Evidencias](evidencias) | Capturas originales incorporadas al reporte. |
| [Documentación técnica](documentacion.md) | Esquema, claves, reglas e interpretación de los resultados. |

## Ejecución desde una base nueva

Usar SQL Server y abrir los archivos completos en SSMS. Ejecutar con F5, uno por uno:

1. [01_crear_base.sql](sql/01_crear_base.sql): crea `PrestamosDeportivosU3_Grabacion`.
2. [schema.sql](sql/schema.sql): crea nueve tablas, restricciones y operaciones del proyecto.
3. [03_datos_ejemplo.sql](sql/03_datos_ejemplo.sql): carga los datos ficticios una sola vez.
4. [04_pruebas_y_verificacion.sql](sql/04_pruebas_y_verificacion.sql): ejecuta veinte casos de integridad y consulta el resumen técnico real.

La creación y la carga se ejecutan una sola vez en una base nueva. Los archivos se detienen si detectan una base, tablas o datos que ya existen; no borran ni reinician el trabajo previo. Si un paso falla, revisar sus Mensajes antes de continuar. El script de tablas y operaciones contiene separadores GO compatibles con SSMS; no necesita SQLCMD Mode.

[Apoyo/Verificar_Catalogo_Completo.sql](sql/Apoyo/Verificar_Catalogo_Completo.sql) permite consultar columnas, claves, cascadas, CHECK, índice filtrado y DBCC CHECKCONSTRAINTS. El resumen de restricciones cuenta solo las tablas del proyecto y excluye objetos de soporte del diseñador.

## Resultados documentados

- Motor: SQL Server 2022, versión 16.0.1000.6.
- Base de la demostración: `PrestamosDeportivosU3_Grabacion`.
- Evidencia de pruebas: 2 de noviembre de 2026, 18:43:14 según el reloj mostrado por la instancia.
- Tablas del proyecto: 9.
- Restricciones: 9 PK, 9 FK y 20 CHECK.
- Pruebas: 20 correctas y 0 fallidas.
- FK no validadas: 0. CHECK no validados: 0.

Un error previsto dentro de una prueba —por ejemplo, intentar repetir una PK— es un rechazo correcto. El campo `errorReal` registra ese rechazo; no equivale a una prueba fallida cuando el resultado es CORRECTO. Las transacciones de prueba se revierten para conservar los datos de ejemplo; los identificadores IDENTITY pueden presentar saltos.

## Video

[Video en YouTube](https://youtu.be/TIleC__uPwQ)
