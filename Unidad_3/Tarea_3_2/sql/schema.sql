-- Tarea 3.2 | Creacion limpia para el video. Ejecutar una sola vez, completo con F5.
-- Mismo modelo y reglas que el paquete original, en una base de grabacion separada.
-- Unidad 3 | DDL para SQL Server 2016 o posterior.
-- Ejecutar completo después de 01_crear_base.sql. Sin DROP ni datos de prueba.
-- Ejecucion documentada en el reporte: base de grabacion y pruebas de integridad.
USE [PrestamosDeportivosU3_Grabacion];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
IF DB_NAME() <> N'PrestamosDeportivosU3_Grabacion'
    THROW 51000, N'Contexto de base incorrecto.', 1;
IF EXISTS (SELECT 1 FROM sys.tables WHERE schema_id=SCHEMA_ID(N'dbo')
    AND name IN (N'Usuario',N'UsuarioTelefono',N'Alumno',N'Trabajador',N'TipoMaterial',
                 N'Ejemplar',N'Prestamo',N'DetallePrestamo',N'Incidencia'))
    THROW 51000, N'Ya existen tablas del proyecto. El script no modifica ni borra esas tablas.', 1;
BEGIN TRY
BEGIN TRANSACTION;
CREATE TABLE dbo.Usuario (
    idUsuario int IDENTITY(1,1) NOT NULL,
    nombres nvarchar(80) NOT NULL,
    primerApellido nvarchar(60) NOT NULL,
    segundoApellido nvarchar(60) NULL,
    fechaNacimiento date NOT NULL,
    activo bit NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT(1),
    CONSTRAINT PK_Usuario PRIMARY KEY (idUsuario),
    CONSTRAINT CK_Usuario_Nombres CHECK(LEN(LTRIM(RTRIM(nombres)))>0),
    CONSTRAINT CK_Usuario_Apellido CHECK(LEN(LTRIM(RTRIM(primerApellido)))>0),
    CONSTRAINT CK_Usuario_Apellido2 CHECK(segundoApellido IS NULL OR LEN(LTRIM(RTRIM(segundoApellido)))>0),
    CONSTRAINT CK_Usuario_Nacimiento CHECK(fechaNacimiento<=CONVERT(date,GETDATE()))
);
CREATE TABLE dbo.UsuarioTelefono (
    idUsuario int NOT NULL,
    telefono varchar(20) NOT NULL,
    CONSTRAINT PK_UsuarioTelefono PRIMARY KEY(idUsuario,telefono),
    CONSTRAINT CK_UsuarioTelefono_Valor CHECK(LEN(LTRIM(RTRIM(telefono)))>0),
    CONSTRAINT FK_UsuarioTelefono_Usuario FOREIGN KEY(idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE TABLE dbo.Alumno (
    idUsuario int NOT NULL,
    matricula varchar(20) NOT NULL,
    carrera nvarchar(100) NOT NULL,
    CONSTRAINT PK_Alumno PRIMARY KEY(idUsuario),
    CONSTRAINT UQ_Alumno_Matricula UNIQUE(matricula),
    CONSTRAINT CK_Alumno_Matricula CHECK(LEN(LTRIM(RTRIM(matricula)))>0),
    CONSTRAINT CK_Alumno_Carrera CHECK(LEN(LTRIM(RTRIM(carrera)))>0),
    CONSTRAINT FK_Alumno_Usuario FOREIGN KEY(idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE TABLE dbo.Trabajador (
    idUsuario int NOT NULL,
    numeroEmpleado varchar(20) NOT NULL,
    adscripcion nvarchar(100) NOT NULL,
    habilitadoRegistro bit NOT NULL CONSTRAINT DF_Trabajador_Habilitado DEFAULT(0),
    CONSTRAINT PK_Trabajador PRIMARY KEY(idUsuario),
    CONSTRAINT UQ_Trabajador_Numero UNIQUE(numeroEmpleado),
    CONSTRAINT CK_Trabajador_Numero CHECK(LEN(LTRIM(RTRIM(numeroEmpleado)))>0),
    CONSTRAINT CK_Trabajador_Adscripcion CHECK(LEN(LTRIM(RTRIM(adscripcion)))>0),
    CONSTRAINT FK_Trabajador_Usuario FOREIGN KEY(idUsuario) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE CASCADE ON UPDATE NO ACTION
);
CREATE TABLE dbo.TipoMaterial (
    idTipo int NOT NULL,
    nombre nvarchar(80) NOT NULL,
    deporte nvarchar(60) NOT NULL,
    CONSTRAINT PK_TipoMaterial PRIMARY KEY(idTipo),
    CONSTRAINT CK_TipoMaterial_Id CHECK(idTipo>0),
    CONSTRAINT CK_TipoMaterial_Nombre CHECK(LEN(LTRIM(RTRIM(nombre)))>0),
    CONSTRAINT CK_TipoMaterial_Deporte CHECK(LEN(LTRIM(RTRIM(deporte)))>0)
);
CREATE TABLE dbo.Ejemplar (
    idEjemplar int IDENTITY(1,1) NOT NULL,
    codigoInventario varchar(30) NOT NULL,
    idTipo int NOT NULL,
    estadoOperativo varchar(15) NOT NULL CONSTRAINT DF_Ejemplar_Estado DEFAULT('apto'),
    CONSTRAINT PK_Ejemplar PRIMARY KEY(idEjemplar),
    CONSTRAINT UQ_Ejemplar_Codigo UNIQUE(codigoInventario),
    CONSTRAINT CK_Ejemplar_Codigo CHECK(LEN(LTRIM(RTRIM(codigoInventario)))>0),
    CONSTRAINT CK_Ejemplar_Estado CHECK(estadoOperativo IN('apto','mantenimiento','baja')),
    CONSTRAINT FK_Ejemplar_TipoMaterial FOREIGN KEY(idTipo) REFERENCES dbo.TipoMaterial(idTipo)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE TABLE dbo.Prestamo (
    idPrestamo int IDENTITY(1,1) NOT NULL,
    idSolicitante int NOT NULL,
    idRegistrador int NOT NULL,
    fechaSalida datetime2(0) NOT NULL,
    fechaLimite datetime2(0) NOT NULL,
    CONSTRAINT PK_Prestamo PRIMARY KEY(idPrestamo),
    CONSTRAINT CK_Prestamo_Fechas CHECK(fechaLimite>=fechaSalida),
    CONSTRAINT FK_Prestamo_Solicitante FOREIGN KEY(idSolicitante) REFERENCES dbo.Usuario(idUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Prestamo_Registrador FOREIGN KEY(idRegistrador) REFERENCES dbo.Trabajador(idUsuario)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE dbo.DetallePrestamo (
    idPrestamo int NOT NULL,
    numeroRenglon int NOT NULL,
    idEjemplar int NOT NULL,
    condicionSalida nvarchar(150) NOT NULL,
    fechaDevolucion datetime2(0) NULL,
    condicionEntrada nvarchar(150) NULL,
    CONSTRAINT PK_DetallePrestamo PRIMARY KEY(idPrestamo,numeroRenglon),
    CONSTRAINT UQ_DetallePrestamo_Pieza UNIQUE(idPrestamo,idEjemplar),
    CONSTRAINT CK_DetallePrestamo_Renglon CHECK(numeroRenglon>0),
    CONSTRAINT CK_DetallePrestamo_Salida CHECK(LEN(LTRIM(RTRIM(condicionSalida)))>0),
    CONSTRAINT CK_DetallePrestamo_Devolucion CHECK(
        (fechaDevolucion IS NULL AND condicionEntrada IS NULL) OR
        (fechaDevolucion IS NOT NULL AND condicionEntrada IS NOT NULL
         AND LEN(LTRIM(RTRIM(condicionEntrada)))>0)),
    CONSTRAINT FK_DetallePrestamo_Prestamo FOREIGN KEY(idPrestamo) REFERENCES dbo.Prestamo(idPrestamo)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_DetallePrestamo_Ejemplar FOREIGN KEY(idEjemplar) REFERENCES dbo.Ejemplar(idEjemplar)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE dbo.Incidencia (
    idIncidencia int IDENTITY(1,1) NOT NULL,
    idPrestamo int NOT NULL,
    numeroRenglon int NOT NULL,
    fechaReporte datetime2(0) NOT NULL,
    descripcion nvarchar(500) NOT NULL,
    estado varchar(10) NOT NULL CONSTRAINT DF_Incidencia_Estado DEFAULT('abierta'),
    CONSTRAINT PK_Incidencia PRIMARY KEY(idIncidencia),
    CONSTRAINT CK_Incidencia_Descripcion CHECK(LEN(LTRIM(RTRIM(descripcion)))>0),
    CONSTRAINT CK_Incidencia_Estado CHECK(estado IN('abierta','resuelta')),
    CONSTRAINT FK_Incidencia_Detalle FOREIGN KEY(idPrestamo,numeroRenglon)
        REFERENCES dbo.DetallePrestamo(idPrestamo,numeroRenglon)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
-- La regla de una sola entrega pendiente también se protege frente a concurrencia.
CREATE UNIQUE INDEX UX_DetallePrestamo_EjemplarAbierto ON dbo.DetallePrestamo(idEjemplar)
    WHERE fechaDevolucion IS NULL;
CREATE INDEX IX_Ejemplar_Tipo ON dbo.Ejemplar(idTipo);
CREATE INDEX IX_Prestamo_Solicitante ON dbo.Prestamo(idSolicitante);
CREATE INDEX IX_Prestamo_Registrador ON dbo.Prestamo(idRegistrador);
CREATE INDEX IX_DetallePrestamo_Ejemplar ON dbo.DetallePrestamo(idEjemplar);
CREATE INDEX IX_Incidencia_Detalle ON dbo.Incidencia(idPrestamo,numeroRenglon);
EXEC(N'CREATE VIEW dbo.vwUsuarioEdad AS
 SELECT idUsuario,nombres,primerApellido,segundoApellido,fechaNacimiento,activo,
 DATEDIFF(YEAR,fechaNacimiento,CONVERT(date,GETDATE()))-
 CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,fechaNacimiento,CONVERT(date,GETDATE())),fechaNacimiento)
 >CONVERT(date,GETDATE()) THEN 1 ELSE 0 END AS edad FROM dbo.Usuario;');
COMMIT TRANSACTION;
SELECT DB_NAME() AS BaseCreada,COUNT(*) AS TablasDelProyecto
FROM sys.tables WHERE schema_id=SCHEMA_ID(N'dbo') AND is_ms_shipped=0;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;

GO
-- Segunda parte del mismo archivo: operaciones del proyecto.
-- Los procedimientos son la interfaz de escritura del rol de aplicación.
USE [PrestamosDeportivosU3_Grabacion];
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

PRINT N'PASO 2 COMPLETO: tablas y operaciones creadas.';
