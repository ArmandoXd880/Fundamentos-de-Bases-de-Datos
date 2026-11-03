-- Datos ficticios de demostracion. Ejecutar una sola vez en el proyecto vacio.
USE [PrestamosDeportivosU3];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON; SET XACT_ABORT ON;
IF EXISTS(SELECT 1 FROM dbo.Usuario) OR EXISTS(SELECT 1 FROM dbo.TipoMaterial)
 THROW 51000,N'Hay datos existentes. No se han borrado ni reemplazado.',1;
DECLARE @ana int,@carlos int,@luis int,@p1 int,@p2 int,@inc int;
DECLARE @telefonos dbo.TelefonosTipo; DECLARE @detalles dbo.DetallesPrestamoTipo;
BEGIN TRY
 BEGIN TRANSACTION;
 INSERT dbo.TipoMaterial VALUES(9301,N'Balon',N'Basquetbol');
 INSERT dbo.Ejemplar(codigoInventario,idTipo,estadoOperativo) VALUES
 ('U3-BAL-01',9301,'apto'),('U3-BAL-02',9301,'apto'),('U3-BAL-03',9301,'apto');
 INSERT @telefonos VALUES('8661000001'),('8661000002');
 EXEC dbo.uspCrearUsuario @nombres=N'Ana',@primerApellido=N'Ejemplo',@fechaNacimiento='2002-04-12',
 @esAlumno=1,@esTrabajador=1,@telefonos=@telefonos,@idUsuario=@ana OUTPUT,
 @matricula='U3-A001',@carrera=N'Informatica',@numeroEmpleado='U3-E001',@adscripcion=N'Apoyo deportivo';
 DELETE @telefonos;
 EXEC dbo.uspCrearUsuario @nombres=N'Carlos',@primerApellido=N'Registro',@fechaNacimiento='1990-05-20',
 @esAlumno=0,@esTrabajador=1,@telefonos=@telefonos,@idUsuario=@carlos OUTPUT,
 @numeroEmpleado='U3-E002',@adscripcion=N'Deportes',@habilitadoRegistro=1;
 INSERT @telefonos VALUES('8661000003');
 EXEC dbo.uspCrearUsuario @nombres=N'Luis',@primerApellido=N'SinUso',@fechaNacimiento='2001-06-15',
 @esAlumno=1,@esTrabajador=1,@telefonos=@telefonos,@idUsuario=@luis OUTPUT,
 @matricula='U3-A003',@carrera=N'Informatica',@numeroEmpleado='U3-E003',@adscripcion=N'Apoyo';
 UPDATE dbo.Usuario SET activo=0 WHERE idUsuario=@luis;
 INSERT @detalles SELECT 1,idEjemplar,N'Buen estado' FROM dbo.Ejemplar WHERE codigoInventario='U3-BAL-01';
 INSERT @detalles SELECT 2,idEjemplar,N'Buen estado' FROM dbo.Ejemplar WHERE codigoInventario='U3-BAL-02';
 EXEC dbo.uspRegistrarPrestamo @ana,@carlos,'2026-10-30T10:00:00','2026-11-01T18:00:00',@detalles,@p1 OUTPUT;
 DELETE @detalles;
 INSERT @detalles SELECT 1,idEjemplar,N'Buen estado' FROM dbo.Ejemplar WHERE codigoInventario='U3-BAL-03';
 EXEC dbo.uspRegistrarPrestamo @ana,@carlos,'2026-10-30T11:00:00','2026-11-01T18:00:00',@detalles,@p2 OUTPUT;
 EXEC dbo.uspRegistrarIncidencia @p1,1,'2026-10-30T12:00:00',N'Observacion ficticia para demostrar el historial.',@inc OUTPUT;
 COMMIT TRANSACTION;
END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
SELECT @ana AS SolicitanteConDosPerfiles,@carlos AS Registrador,@p1 AS PrestamoConDosPiezas,@p2 AS SegundoPrestamo;
SELECT * FROM dbo.vwUsuarioEdad;
SELECT * FROM dbo.DetallePrestamo ORDER BY idPrestamo,numeroRenglon;
