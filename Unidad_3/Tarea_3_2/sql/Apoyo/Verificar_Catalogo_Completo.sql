-- Resultados reales para las capturas: ejecutar despues de schema.sql y 02_operaciones.sql.
USE [PrestamosDeportivosU3_Grabacion];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
SELECT @@VERSION AS VersionReal,DB_NAME() AS BaseActual,SYSDATETIME() AS MomentoEjecucion;
SELECT COUNT(*) AS TablasProyecto FROM sys.tables
WHERE schema_id=SCHEMA_ID(N'dbo') AND name IN
('Usuario','UsuarioTelefono','Alumno','Trabajador','TipoMaterial','Ejemplar','Prestamo','DetallePrestamo','Incidencia');
SELECT t.name AS Tabla,c.column_id,c.name AS Columna,ty.name AS Tipo,
 CASE WHEN c.max_length=-1 THEN 'MAX' WHEN ty.name IN('nvarchar','nchar') THEN CONVERT(varchar(10),c.max_length/2)
 ELSE CONVERT(varchar(10),c.max_length) END AS Longitud,c.is_nullable AS PermiteNull,c.is_identity AS EsIdentity
FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id JOIN sys.types ty ON ty.user_type_id=c.user_type_id
WHERE t.schema_id=SCHEMA_ID(N'dbo') AND t.name NOT LIKE 'sys%' ORDER BY t.name,c.column_id;
SELECT OBJECT_NAME(parent_object_id) AS Tabla,name AS Restriccion,type_desc
FROM sys.key_constraints WHERE OBJECT_NAME(parent_object_id) IN ('Usuario','UsuarioTelefono','Alumno','Trabajador','TipoMaterial','Ejemplar','Prestamo','DetallePrestamo','Incidencia') AND schema_id=SCHEMA_ID(N'dbo') ORDER BY Tabla,type_desc;
SELECT fk.name AS FK,OBJECT_NAME(fk.parent_object_id) AS TablaHija,
 COL_NAME(fkc.parent_object_id,fkc.parent_column_id) AS ColumnaHija,
 OBJECT_NAME(fk.referenced_object_id) AS TablaPadre,
 COL_NAME(fkc.referenced_object_id,fkc.referenced_column_id) AS ColumnaPadre,
 fk.delete_referential_action_desc AS AlEliminar,fk.update_referential_action_desc AS AlActualizar,
 fk.is_disabled,fk.is_not_trusted
FROM sys.foreign_keys fk JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
WHERE fk.schema_id=SCHEMA_ID(N'dbo') ORDER BY fk.name,fkc.constraint_column_id;
SELECT OBJECT_NAME(parent_object_id) AS Tabla,name,definition,is_disabled,is_not_trusted
FROM sys.check_constraints WHERE schema_id=SCHEMA_ID(N'dbo') ORDER BY Tabla,name;
SELECT OBJECT_NAME(object_id) AS Tabla,name,is_unique,filter_definition
FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.DetallePrestamo') AND name IS NOT NULL;
-- Debe devolver cero filas si los datos cumplen las restricciones activas.
DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS;
-- Resumen estructural: los numeros se obtienen de la instancia, no son resultados precargados.
SELECT (SELECT COUNT(*) FROM sys.key_constraints WHERE type='PK' AND schema_id=SCHEMA_ID('dbo') AND OBJECT_NAME(parent_object_id) IN ('Usuario','UsuarioTelefono','Alumno','Trabajador','TipoMaterial','Ejemplar','Prestamo','DetallePrestamo','Incidencia')) AS ClavesPrimarias,
 (SELECT COUNT(*) FROM sys.foreign_keys WHERE schema_id=SCHEMA_ID('dbo') AND OBJECT_NAME(parent_object_id) IN ('Usuario','UsuarioTelefono','Alumno','Trabajador','TipoMaterial','Ejemplar','Prestamo','DetallePrestamo','Incidencia')) AS ClavesForaneas,
 (SELECT COUNT(*) FROM sys.check_constraints WHERE schema_id=SCHEMA_ID('dbo') AND OBJECT_NAME(parent_object_id) IN ('Usuario','UsuarioTelefono','Alumno','Trabajador','TipoMaterial','Ejemplar','Prestamo','DetallePrestamo','Incidencia')) AS Checks;
