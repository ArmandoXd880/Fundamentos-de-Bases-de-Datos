# Tarea 6.2 Implementación de DDL y DML

**Proyecto** Préstamo de material deportivo universitario  
**Alumno** Jesús Armando Zendejo Altamirano

La práctica reutiliza el [esquema SQL Server de la Unidad 4](../../Unidad_4/Tarea_4_2/sql/normalized_schema.sql). Los scripts trabajan en `PrestamosDeportivosU6` y cargan datos ficticios para comprobar las nueve tablas. Se probaron en SQL Server 2022 Developer.

## Clonar

```powershell
git clone https://github.com/ArmandoXd880/Fundamentos-de-Bases-de-Datos.git
cd Fundamentos-de-Bases-de-Datos/Unidad_6/Tarea_6_2
```

## Ejecutar en SQL Server Management Studio

Conéctate a una instancia de SQL Server 2016 o posterior con una cuenta autorizada para crear bases de datos y objetos en la base de práctica. Abre cada archivo en una pestaña y ejecuta **el archivo completo** con **F5**, en este orden.

| Orden | Archivo | Salida esperada |
|---|---|---|
| 1 | [01_schema_ddl.sql](sql/01_schema_ddl.sql) | Base `PrestamosDeportivosU6`, 9 tablas, 9 PK, 9 FK y 20 CHECK. |
| 2 | [02_data_inserts.sql](sql/02_data_inserts.sql) | Conteos de las 9 tablas y 45 filas totales. |
| 3 | [03_queries_dml.sql](sql/03_queries_dml.sql) | Cinco resultados analíticos y cinco operaciones controladas. |

En la primera fase, actualiza **Bases de datos** en el Explorador de objetos y abre **PrestamosDeportivosU6 → Tablas** para verificar el esquema. La fase 2 requiere las tablas vacías. Una vez cargados los datos, puedes repetir la fase 3. Sus operaciones aceptadas se revierten y los conflictos esperados se muestran con el código 547 en la tabla de mantenimiento.

Para ejecutar una consulta por separado selecciona `PrestamosDeportivosU6` en la lista de bases de la pestaña, marca el bloque completo identificado por Q01 a Q05, incluida la CTE cuando la haya, y presiona F5. Para ejecutar las comprobaciones de mantenimiento usa todo el archivo de la fase 3.

## Ejecutar con sqlcmd

Ejemplo con autenticación de Windows. Reemplaza `.` por el nombre de servidor que usas en SSMS, por ejemplo `.\SQLEXPRESS` para una instancia con ese nombre.

```powershell
sqlcmd -S "." -E -b -i ".\sql\01_schema_ddl.sql"
sqlcmd -S "." -E -b -i ".\sql\02_data_inserts.sql"
sqlcmd -S "." -E -b -i ".\sql\03_queries_dml.sql"
```

## Consultas y resultados

| Bloque | Comprobación |
|---|---|
| Q01 | Cinco tipos de material en el catálogo. |
| Q02 | Seis ejemplares con estado apto. |
| Q03 | Ocho renglones del historial con solicitante y pieza. |
| Q04 | Cinco tipos, incluido Cronómetro con cero ejemplares. |
| Q05 | Ana y Luis con al menos dos préstamos y sus cinco agregaciones. |
| M01 a M05 | Dos cambios permitidos y revertidos. Tres operaciones rechazadas por una FK. |

Las [capturas de la consola](evidencias) muestran el esquema, los conteos de carga, cada consulta y las pruebas de mantenimiento. El [informe](Reporte_Tarea_6_2_Practica_SQL_Server.pdf) explica los resultados.
