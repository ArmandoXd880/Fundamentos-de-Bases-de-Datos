# Unidad 5 Álgebra relacional

**Proyecto** Préstamo de material deportivo universitario  
**Alumno** Jesús Armando Zendejo Altamirano  
**Materia** Fundamentos de Bases de Datos

## Tarea 5.1 Operadores fundamentales y extendidos

- [Informe en PDF](Tarea_5_1/Reporte_Tarea_5_1_Algebra_Relacional.pdf)
- [Archivo fuente editable en Word](Tarea_5_1/Reporte_Tarea_5_1_Algebra_Relacional.docx)
- [Mapa conceptual vectorial](Tarea_5_1/diagramas/Mapa_Conceptual_Algebra_Relacional.svg)

## Tarea 5.2 Catálogo de consultas

- [Informe en PDF](Tarea_5_2/Reporte_Tarea_5_2_Consultas_Algebra_Relacional.pdf)
- [Archivo fuente editable en Word](Tarea_5_2/Reporte_Tarea_5_2_Consultas_Algebra_Relacional.docx)
- [Catálogo de diez consultas T-SQL](Tarea_5_2/sql/01_catalogo_consultas.sql)
- [Comprobaciones con los datos de ejemplo](Tarea_5_2/sql/02_validar_datos_ejemplo.sql)

### Ejecución en SQL Server Management Studio

Las consultas reutilizan `PrestamosDeportivosU4`, la base de la [Unidad 4](../Unidad_4/Tarea_4_2/sql). Si ya tienes instalada esa base, abre `01_catalogo_consultas.sql` en SSMS y ejecútalo. Puedes ejecutar un bloque C01 a C10 por separado seleccionándolo completo, incluida su cláusula `WITH` cuando la tenga.

Si necesitas preparar una instancia de pruebas vacía, ejecuta los scripts originales de la Unidad 4 en este orden.

1. [00_crear_base.sql](../Unidad_4/Tarea_4_2/sql/00_crear_base.sql)
2. [normalized_schema.sql](../Unidad_4/Tarea_4_2/sql/normalized_schema.sql)
3. [02_operaciones.sql](../Unidad_4/Tarea_4_2/sql/02_operaciones.sql)
4. [03_datos_ejemplo.sql](../Unidad_4/Tarea_4_2/sql/03_datos_ejemplo.sql)

Después ejecuta los dos scripts de la Unidad 5. El catálogo funciona con el esquema de la Unidad 4 y los resultados reflejan sus datos actuales. La comprobación exacta del informe presupone la primera carga del conjunto ficticio en una base vacía. Con esa carga se esperan diez revisiones con estado `OK`. Ambos scripts de la Unidad 5 son de lectura.

### Entrega en Teams

Sube la carpeta `Unidad_5` a la raíz de este repositorio. Para cada tarea entrega el informe PDF, el enlace público de su carpeta de GitHub y el enlace público de su video en YouTube. Graba con la webcam visible en la esquina inferior derecha.
