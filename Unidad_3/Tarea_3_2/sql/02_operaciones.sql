-- Ejecutar después de schema.sql. Complementa las restricciones entre tablas.
-- Los procedimientos son la interfaz de escritura del rol de aplicación.
USE [PrestamosDeportivosU3];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
CREATE TYPE dbo.TelefonosTipo AS TABLE(telefono varchar(20) NOT NULL PRIMARY KEY);
GO
CREATE TYPE dbo.DetallesPrestamoTipo AS TABLE(
 numeroRenglon int NOT NULL PRIMARY KEY,
 idEjemplar int NOT NULL UNIQUE,
 condicionSalida nvarchar(150) NOT NULL
);
GO
CREATE PROCEDURE dbo.uspCrearUsuario
 @nombres nvarchar(80),@primerApellido nvarchar(60),@fechaNacimiento date,
 @esAlumno bit,@esTrabajador bit,@telefonos dbo.TelefonosTipo READONLY,
 @idUsuario int OUTPUT,@segundoApellido nvarchar(60)=NULL,
 @matricula varchar(20)=NULL,@carrera nvarchar(100)=NULL,
 @numeroEmpleado varchar(20)=NULL,@adscripcion nvarchar(100)=NULL,
 @habilitadoRegistro bit=0
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF ISNULL(@esAlumno,0)=0 AND ISNULL(@esTrabajador,0)=0
    THROW 51001,N'El usuario debe tener al menos un perfil.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  INSERT dbo.Usuario(nombres,primerApellido,segundoApellido,fechaNacimiento)
    VALUES(@nombres,@primerApellido,@segundoApellido,@fechaNacimiento);
  SET @idUsuario=CONVERT(int,SCOPE_IDENTITY());
  IF @esAlumno=1 INSERT dbo.Alumno VALUES(@idUsuario,@matricula,@carrera);
  IF @esTrabajador=1 INSERT dbo.Trabajador VALUES(@idUsuario,@numeroEmpleado,@adscripcion,@habilitadoRegistro);
  INSERT dbo.UsuarioTelefono SELECT @idUsuario,telefono FROM @telefonos;
  COMMIT TRANSACTION;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
END;
GO
CREATE PROCEDURE dbo.uspRegistrarPrestamo
 @idSolicitante int,@idRegistrador int,@fechaSalida datetime2(0),@fechaLimite datetime2(0),
 @detalles dbo.DetallesPrestamoTipo READONLY,@idPrestamo int OUTPUT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF NOT EXISTS(SELECT 1 FROM @detalles) THROW 51002,N'El prestamo debe contener al menos una pieza.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.Usuario WITH(UPDLOCK,HOLDLOCK) WHERE idUsuario=@idSolicitante AND activo=1)
    THROW 51003,N'El solicitante no existe o esta inactivo.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.Trabajador WITH(UPDLOCK,HOLDLOCK) WHERE idUsuario=@idRegistrador AND habilitadoRegistro=1)
    THROW 51004,N'El registrador no es un trabajador habilitado.',1;
  IF EXISTS(SELECT 1 FROM @detalles d LEFT JOIN dbo.Ejemplar e WITH(UPDLOCK,HOLDLOCK)
     ON e.idEjemplar=d.idEjemplar WHERE e.idEjemplar IS NULL OR e.estadoOperativo<>'apto')
    THROW 51005,N'Hay una pieza inexistente o no apta.',1;
  IF EXISTS(SELECT 1 FROM dbo.DetallePrestamo p JOIN @detalles d ON d.idEjemplar=p.idEjemplar
     WHERE p.fechaDevolucion IS NULL)
    THROW 51006,N'Hay una pieza pendiente de devolucion.',1;
  INSERT dbo.Prestamo(idSolicitante,idRegistrador,fechaSalida,fechaLimite)
    VALUES(@idSolicitante,@idRegistrador,@fechaSalida,@fechaLimite);
  SET @idPrestamo=CONVERT(int,SCOPE_IDENTITY());
  INSERT dbo.DetallePrestamo(idPrestamo,numeroRenglon,idEjemplar,condicionSalida)
    SELECT @idPrestamo,numeroRenglon,idEjemplar,condicionSalida FROM @detalles;
  COMMIT TRANSACTION;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
END;
GO
CREATE PROCEDURE dbo.uspDevolverEjemplar
 @idPrestamo int,@numeroRenglon int,@fechaDevolucion datetime2(0),@condicionEntrada nvarchar(150)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.DetallePrestamo WITH(UPDLOCK,HOLDLOCK)
     WHERE idPrestamo=@idPrestamo AND numeroRenglon=@numeroRenglon AND fechaDevolucion IS NULL)
    THROW 51007,N'El detalle no existe o ya esta devuelto.',1;
  IF @fechaDevolucion IS NULL OR EXISTS(SELECT 1 FROM dbo.Prestamo WHERE idPrestamo=@idPrestamo AND @fechaDevolucion<fechaSalida)
    THROW 51008,N'La fecha de devolucion es invalida.',1;
  UPDATE dbo.DetallePrestamo SET fechaDevolucion=@fechaDevolucion,condicionEntrada=@condicionEntrada
    WHERE idPrestamo=@idPrestamo AND numeroRenglon=@numeroRenglon;
  COMMIT TRANSACTION;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
END;
GO
CREATE PROCEDURE dbo.uspRegistrarIncidencia
 @idPrestamo int,@numeroRenglon int,@fechaReporte datetime2(0),@descripcion nvarchar(500),
 @idIncidencia int OUTPUT,@estado varchar(10)='abierta'
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM dbo.DetallePrestamo WITH(UPDLOCK,HOLDLOCK)
     WHERE idPrestamo=@idPrestamo AND numeroRenglon=@numeroRenglon)
    THROW 51009,N'El detalle de la incidencia no existe.',1;
  IF @fechaReporte IS NULL OR EXISTS(SELECT 1 FROM dbo.Prestamo WHERE idPrestamo=@idPrestamo AND @fechaReporte<fechaSalida)
    THROW 51010,N'La incidencia no puede preceder al prestamo.',1;
  INSERT dbo.Incidencia(idPrestamo,numeroRenglon,fechaReporte,descripcion,estado)
    VALUES(@idPrestamo,@numeroRenglon,@fechaReporte,@descripcion,@estado);
  SET @idIncidencia=CONVERT(int,SCOPE_IDENTITY());
  COMMIT TRANSACTION;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK TRANSACTION; THROW; END CATCH;
END;
GO
CREATE ROLE rolPrestamosAplicacion AUTHORIZATION dbo;
GRANT SELECT ON SCHEMA::dbo TO rolPrestamosAplicacion;
DENY INSERT,UPDATE,DELETE ON SCHEMA::dbo TO rolPrestamosAplicacion;
GRANT EXECUTE ON OBJECT::dbo.uspCrearUsuario TO rolPrestamosAplicacion;
GRANT EXECUTE ON OBJECT::dbo.uspRegistrarPrestamo TO rolPrestamosAplicacion;
GRANT EXECUTE ON OBJECT::dbo.uspDevolverEjemplar TO rolPrestamosAplicacion;
GRANT EXECUTE ON OBJECT::dbo.uspRegistrarIncidencia TO rolPrestamosAplicacion;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.TelefonosTipo TO rolPrestamosAplicacion;
GRANT EXECUTE,REFERENCES ON TYPE::dbo.DetallesPrestamoTipo TO rolPrestamosAplicacion;
-- No se crean logins ni se agregan usuarios de tu computadora al rol.
SELECT name,type_desc FROM sys.objects
WHERE schema_id=SCHEMA_ID(N'dbo') AND type='P' ORDER BY name;
