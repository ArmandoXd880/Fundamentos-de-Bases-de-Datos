
# Fundamentos de Bases de Datos

**Alumno:** Jesús Armando Zendejo Altamirano  
**Materia:** Fundamentos de Bases de Datos  
**Docente:** Ruben Riojas

Repositorio académico que contiene los reportes, documentación y diagramas correspondientes a las unidades de la materia.

---

## Unidad 1: Introducción a las bases de datos

### Tarea 1.1: Fundamentos, objetivos y modelos

- [Documento PDF](Unidad_1/Tarea_1_1/Tarea_1_1_Fundamentos_y_modelos.pdf)
- [Documentación Markdown](Unidad_1/Tarea_1_1/documentacion.md)
- [Mapa conceptual vectorial editable](Unidad_1/Tarea_1_1/diagramas/mapa_conceptual_analitico.svg)
- [Mapa conceptual original](Unidad_1/Tarea_1_1/diagramas/mapa_original.jpg)

### Tarea 1.2: Clasificación y arquitecturas

- [Documento PDF](Unidad_1/Tarea_1_2/Tarea_1_2_Clasificacion_y_arquitecturas.pdf)
- [Documentación Markdown](Unidad_1/Tarea_1_2/documentacion.md)
- [Cuadro sinóptico vectorial](Unidad_1/Tarea_1_2/diagramas/cuadro_sinoptico_clasificacion.svg)
- [Arquitectura ANSI-SPARC](Unidad_1/Tarea_1_2/diagramas/arquitectura_ansi_sparc.svg)
- [Arquitectura funcional del SGBD](Unidad_1/Tarea_1_2/diagramas/arquitectura_funcional_sgbd.svg)

---

## Unidad 2: Diseño conceptual de bases de datos

**Caso de estudio:** Préstamo de material deportivo universitario.

### Tarea 2.1: Modelado Entidad-Relación (E-R y E-RE)

- [Reporte técnico PDF](Unidad_2/Tarea_2_1/Reporte_Tarea_2_1_ER_ERE.pdf)
- [Documentación y reglas de negocio](Unidad_2/Tarea_2_1/documentacion.md)
- [Archivo fuente editable Draw.io](Unidad_2/Tarea_2_1/diagramas/Modelo_ER_ERE_Deportes.drawio)
- [Diagramas E-R y E-RE en PDF](Unidad_2/Tarea_2_1/diagramas/Diagramas_ER_ERE.pdf)

### Tarea 2.2: Transformación del modelo E-R a UML

- [Reporte comparativo PDF](Unidad_2/Tarea_2_2/Reporte_Tarea_2_2_ER_a_UML.pdf)
- [Documentación y correspondencias](Unidad_2/Tarea_2_2/documentacion.md)
- [Archivo fuente editable Draw.io](Unidad_2/Tarea_2_2/diagramas/Modelo_UML_Deportes.drawio)
- [Diagramas UML en PDF](Unidad_2/Tarea_2_2/diagramas/Diagramas_UML.pdf)

---

## Organización de archivos

Cada unidad contiene carpetas individuales para sus actividades, incluyendo reportes técnicos, documentación y diagramas.

Los archivos SVG permiten visualizar los diagramas en formato vectorial.

Los archivos DRAWIO contienen los modelos editables mediante diagrams.net.

Los reportes PDF contienen el desarrollo de las actividades y las referencias bibliográficas correspondientes.

# Unidad 3 Modelo relacional

Alumno: Jesús Armando Zendejo Altamirano. Materia: Fundamentos de Bases de Datos. Docente: Ruben Riojas.

Caso: préstamo de material deportivo de la Unidad 2.

## Tarea 3.1

- [Reporte](Tarea_3_1/Reporte_Tarea_3_1_Modelo_Relacional.pdf)
- [Documentación](Tarea_3_1/documentacion.md)
- [Diagrama editable](Tarea_3_1/diagramas/Esquema_Relacional_Deportes.drawio)
- [Esquema relacional PDF](Tarea_3_1/diagramas/Esquema_Relacional_Deportes.pdf)

## Tarea 3.2

**Estado: revisión estática; pendiente de ejecución y validación real en SQL Server.**

- [DDL schema.sql](Tarea_3_2/sql/schema.sql)
- [Operaciones transaccionales](Tarea_3_2/sql/02_operaciones.sql)
- [Datos ficticios](Tarea_3_2/sql/03_datos_ejemplo.sql)
- [Veinte casos de prueba](Tarea_3_2/sql/04_pruebas_integridad.sql)
- [Verificación del catálogo](Tarea_3_2/sql/05_verificar_esquema.sql)
- [Documentación](Tarea_3_2/documentacion.md)

Orden: 00_crear_base.sql, schema.sql, 02_operaciones.sql, 03_datos_ejemplo.sql, 04_pruebas_integridad.sql y 05_verificar_esquema.sql. Abrir cada archivo en SSMS y ejecutarlo completo antes de continuar. Los scripts no borran bases existentes.

La tarea 3.2 requiere agregar el reporte final y el diagrama generado por SSMS después de ejecutar y validar el esquema. El diagrama de la tarea 3.1 es un diseño lógico y no sustituye esa evidencia.

