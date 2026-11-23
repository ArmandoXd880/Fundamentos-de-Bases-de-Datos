-- Tarea 6.2 | Fase 2 de 3. Carga ficticia en las nueve tablas.
-- Se ejecuta una vez sobre el esquema vacío. No sustituye registros existentes.
IF @@TRANCOUNT <> 0
    THROW 51000, N'El script requiere una sesión sin transacciones abiertas.', 1;
USE [PrestamosDeportivosU6];
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

DECLARE @usuarios TABLE (idUsuario int NOT NULL, nombres nvarchar(80) PRIMARY KEY);
DECLARE @prestamos TABLE (idPrestamo int NOT NULL, fechaSalida datetime2(0) PRIMARY KEY);
DECLARE @bloqueo int;

BEGIN TRY
    BEGIN TRANSACTION;
    EXEC @bloqueo = sys.sp_getapplock
        @Resource = N'Tarea6.2_CargaDemo', @LockMode = 'Exclusive',
        @LockOwner = 'Transaction', @LockTimeout = 10000;
    IF @bloqueo < 0
        THROW 51000, N'No se pudo obtener el bloqueo de la carga de ejemplo.', 1;
    IF EXISTS (
        SELECT 1 FROM dbo.Usuario UNION ALL
        SELECT 1 FROM dbo.UsuarioTelefono UNION ALL
        SELECT 1 FROM dbo.Alumno UNION ALL
        SELECT 1 FROM dbo.Trabajador UNION ALL
        SELECT 1 FROM dbo.TipoMaterial UNION ALL
        SELECT 1 FROM dbo.Ejemplar UNION ALL
        SELECT 1 FROM dbo.Prestamo UNION ALL
        SELECT 1 FROM dbo.DetallePrestamo UNION ALL
        SELECT 1 FROM dbo.Incidencia
    )
        THROW 51000, N'La carga requiere las nueve tablas vacías. No se cambió ningún dato.', 1;

    INSERT dbo.Usuario (nombres, primerApellido, fechaNacimiento, activo)
        OUTPUT inserted.idUsuario, inserted.nombres INTO @usuarios (idUsuario, nombres)
    VALUES (N'Ana', N'Ejemplo', '20020412', 1),
           (N'Carlos', N'Registro', '19900520', 1),
           (N'Luis', N'Muestra', '20010615', 1),
           (N'Elena', N'Práctica', '20030708', 1),
           (N'Mateo', N'Archivo', '19880914', 0);

    INSERT dbo.UsuarioTelefono (idUsuario, telefono)
    SELECT u.idUsuario, v.telefono
    FROM (VALUES (N'Ana', '8661000001'), (N'Ana', '8661000002'),
                 (N'Carlos', '8661000003'), (N'Luis', '8661000004'),
                 (N'Elena', '8661000005')) AS v(nombres, telefono)
    INNER JOIN @usuarios AS u ON u.nombres = v.nombres;

    INSERT dbo.Alumno (idUsuario, matricula, carrera)
    SELECT u.idUsuario, v.matricula, v.carrera
    FROM (VALUES (N'Ana', 'U6-A001', N'Informática'),
                 (N'Luis', 'U6-A002', N'Informática'),
                 (N'Elena', 'U6-A003', N'Industrial')) AS v(nombres, matricula, carrera)
    INNER JOIN @usuarios AS u ON u.nombres = v.nombres;

    INSERT dbo.Trabajador (idUsuario, numeroEmpleado, adscripcion, habilitadoRegistro)
    SELECT u.idUsuario, v.numeroEmpleado, v.adscripcion, v.habilitado
    FROM (VALUES (N'Ana', 'U6-E001', N'Apoyo deportivo', 0),
                 (N'Carlos', 'U6-E002', N'Deportes', 1),
                 (N'Mateo', 'U6-E003', N'Almacén', 0)) AS v(nombres, numeroEmpleado, adscripcion, habilitado)
    INNER JOIN @usuarios AS u ON u.nombres = v.nombres;

    INSERT dbo.TipoMaterial (idTipo, nombre, deporte)
    VALUES (9301, N'Balón', N'Basquetbol'),
           (9302, N'Red', N'Voleibol'),
           (9303, N'Raqueta', N'Tenis'),
           (9304, N'Cono', N'Entrenamiento'),
           (9305, N'Cronómetro', N'Atletismo');

    INSERT dbo.Ejemplar (codigoInventario, idTipo, estadoOperativo)
    VALUES ('U6-BAL-01', 9301, 'apto'),
           ('U6-BAL-02', 9301, 'apto'),
           ('U6-BAL-03', 9301, 'apto'),
           ('U6-RED-01', 9302, 'apto'),
           ('U6-RED-02', 9302, 'mantenimiento'),
           ('U6-RAQ-01', 9303, 'apto'),
           ('U6-RAQ-02', 9303, 'baja'),
           ('U6-CON-01', 9304, 'apto');

    INSERT dbo.Prestamo (idSolicitante, idRegistrador, fechaSalida, fechaLimite)
        OUTPUT inserted.idPrestamo, inserted.fechaSalida INTO @prestamos (idPrestamo, fechaSalida)
    SELECT solicitante.idUsuario, registrador.idUsuario, v.salida, v.limite
    FROM (VALUES (N'Ana', '2026-10-28T09:00:00', '2026-10-30T18:00:00'),
                 (N'Luis', '2026-10-29T10:00:00', '2026-11-01T18:00:00'),
                 (N'Ana', '2026-11-01T09:00:00', '2026-11-03T18:00:00'),
                 (N'Carlos', '2026-11-02T09:00:00', '2026-11-04T18:00:00'),
                 (N'Luis', '2026-11-05T11:00:00', '2026-11-06T18:00:00')) AS v(nombres, salida, limite)
    INNER JOIN @usuarios AS solicitante ON solicitante.nombres = v.nombres
    INNER JOIN @usuarios AS registrador ON registrador.nombres = N'Carlos';

    INSERT dbo.DetallePrestamo
        (idPrestamo, numeroRenglon, idEjemplar, condicionSalida, fechaDevolucion, condicionEntrada)
    SELECT p.idPrestamo, v.renglon, e.idEjemplar, N'Buen estado', v.devolucion, v.entrada
    FROM (VALUES
        ('2026-10-28T09:00:00', 1, 'U6-BAL-01', '2026-10-30T11:00:00', N'Buen estado'),
        ('2026-10-28T09:00:00', 2, 'U6-BAL-02', '2026-10-31T10:00:00', N'Requiere revisión'),
        ('2026-10-29T10:00:00', 1, 'U6-RED-01', '2026-11-01T12:00:00', N'Buen estado'),
        ('2026-10-29T10:00:00', 2, 'U6-RAQ-01', '2026-11-02T10:00:00', N'Requiere revisión'),
        ('2026-11-01T09:00:00', 1, 'U6-BAL-01', NULL, NULL),
        ('2026-11-01T09:00:00', 2, 'U6-BAL-03', NULL, NULL),
        ('2026-11-02T09:00:00', 1, 'U6-CON-01', NULL, NULL),
        ('2026-11-05T11:00:00', 1, 'U6-RED-01', NULL, NULL)
    ) AS v(salida, renglon, codigo, devolucion, entrada)
    INNER JOIN @prestamos AS p ON p.fechaSalida = v.salida
    INNER JOIN dbo.Ejemplar AS e ON e.codigoInventario = v.codigo;

    INSERT dbo.Incidencia (idPrestamo, numeroRenglon, fechaReporte, descripcion, estado)
    SELECT p.idPrestamo, v.renglon, v.reporte, v.descripcion, v.estado
    FROM (VALUES
        ('2026-10-28T09:00:00', 2, '2026-10-31T10:05:00', N'Revisión del balón recibido.', 'resuelta'),
        ('2026-10-29T10:00:00', 2, '2026-11-02T10:05:00', N'Desgaste en el mango.', 'abierta'),
        ('2026-11-01T09:00:00', 2, '2026-11-01T09:30:00', N'Reporte de válvula floja.', 'abierta')
    ) AS v(salida, renglon, reporte, descripcion, estado)
    INNER JOIN @prestamos AS p ON p.fechaSalida = v.salida;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

PRINT 'Carga de datos de ejemplo';
SELECT CAST(tabla AS varchar(22)) AS tabla, filas
FROM (
    SELECT 'Usuario' AS tabla, COUNT(*) AS filas FROM dbo.Usuario
    UNION ALL SELECT 'UsuarioTelefono', COUNT(*) FROM dbo.UsuarioTelefono
    UNION ALL SELECT 'Alumno', COUNT(*) FROM dbo.Alumno
    UNION ALL SELECT 'Trabajador', COUNT(*) FROM dbo.Trabajador
    UNION ALL SELECT 'TipoMaterial', COUNT(*) FROM dbo.TipoMaterial
    UNION ALL SELECT 'Ejemplar', COUNT(*) FROM dbo.Ejemplar
    UNION ALL SELECT 'Prestamo', COUNT(*) FROM dbo.Prestamo
    UNION ALL SELECT 'DetallePrestamo', COUNT(*) FROM dbo.DetallePrestamo
    UNION ALL SELECT 'Incidencia', COUNT(*) FROM dbo.Incidencia
) AS recuentos
ORDER BY tabla;
