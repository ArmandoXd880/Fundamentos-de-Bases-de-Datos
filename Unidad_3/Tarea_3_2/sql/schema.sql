-- Unidad 3 | DDL para SQL Server 2016 o posterior.
-- Ejecutar completo después de 00_crear_base.sql. Sin DROP ni datos de prueba.
-- Revisión estática realizada; ejecución en SQL Server pendiente de comprobar.
USE [PrestamosDeportivosU3];
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
IF DB_NAME() <> N'PrestamosDeportivosU3'
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
