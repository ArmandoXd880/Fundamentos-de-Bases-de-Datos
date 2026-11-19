# Comprobación analítica de la normalización

Estas comprobaciones se ejecutaron en Python sobre las dependencias declaradas y los datos ficticios del reporte. No se conectan ni ejecutan SQL Server y no acreditan el funcionamiento del DDL en ese motor.

- [Código reproducible](comprobar_normalizacion.py)
- [Resultados analíticos](resultados_analiticos.json)
- [Ejemplo completo R1 con sus doce atributos](R1_ejemplo.csv)

Ejecutar desde esta carpeta: `python comprobar_normalizacion.py`. Requiere Python 3.9 o posterior; solo usa la biblioteca estándar y lee `../sql/normalized_schema.sql`.

Las 14 comprobaciones incluyen las tres claves candidatas de R1, cierres de atributos, una dependencia parcial, los cuatro pasos de descomposición sin pérdida, conservación de DF, FNBC de la proyección, reconstrucción exacta del ejemplo, correspondencia de claves con las nueve tablas SQL y los ejemplos teóricos de 3FN/FNBC, 4FN y 5FN. La validación depende de las reglas explícitas; no descubre dependencias ocultas del negocio ni demuestra 4FN o 5FN del proyecto aplicado.
