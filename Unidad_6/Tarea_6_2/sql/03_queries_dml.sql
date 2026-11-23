-- Tarea 6.2 | Fase 3 de 3. Consultas y comprobaciones de integridad.
-- Las modificaciones de mantenimiento se ejecutan en transacciones que se revierten.
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

-- Q01 | Catálogo de tipos
PRINT 'Q01 | Catalogo de tipos';
SELECT idTipo, nombre AS tipo, deporte
FROM dbo.TipoMaterial
ORDER BY idTipo;

-- Q02 | Ejemplares aptos
PRINT 'Q02 | Ejemplares aptos (WHERE y ORDER BY)';
SELECT codigoInventario, idTipo,
       estadoOperativo
FROM dbo.Ejemplar
WHERE estadoOperativo = 'apto'
ORDER BY idTipo, codigoInventario;

-- Q03 | Historial por pieza
PRINT 'Q03 | Historial por pieza (INNER JOIN)';
SELECT p.idPrestamo, d.numeroRenglon, u.nombres AS solicitante,
       e.codigoInventario
FROM dbo.Prestamo AS p
INNER JOIN dbo.Usuario AS u ON u.idUsuario = p.idSolicitante
INNER JOIN dbo.DetallePrestamo AS d ON d.idPrestamo = p.idPrestamo
INNER JOIN dbo.Ejemplar AS e ON e.idEjemplar = d.idEjemplar
ORDER BY p.fechaSalida, d.numeroRenglon;

-- Q04 | Existencias por tipo, incluidas las de cero piezas
PRINT 'Q04 | Existencias por tipo (LEFT JOIN)';
SELECT t.idTipo, t.nombre AS tipo, COUNT(e.idEjemplar) AS ejemplares
FROM dbo.TipoMaterial AS t
LEFT JOIN dbo.Ejemplar AS e ON e.idTipo = t.idTipo
GROUP BY t.idTipo, t.nombre
ORDER BY t.idTipo;

-- Q05 | Actividad de quien solicitó al menos dos préstamos
PRINT 'Q05 | Actividad por solicitante (GROUP BY y HAVING)';
WITH PiezasPorPrestamo AS (
    SELECT p.idPrestamo, p.idSolicitante, COUNT(d.idEjemplar) AS piezas
    FROM dbo.Prestamo AS p
    INNER JOIN dbo.DetallePrestamo AS d ON d.idPrestamo = p.idPrestamo
    GROUP BY p.idPrestamo, p.idSolicitante
)
SELECT u.nombres AS solicitante, COUNT(*) AS prestamos,
       SUM(p.piezas) AS totalPiezas,
       CAST(AVG(CAST(p.piezas AS decimal(9,2))) AS decimal(9,2)) AS promedio,
       MAX(p.piezas) AS maximo, MIN(p.piezas) AS minimo
FROM PiezasPorPrestamo AS p
INNER JOIN dbo.Usuario AS u ON u.idUsuario = p.idSolicitante
GROUP BY u.idUsuario, u.nombres
HAVING COUNT(*) >= 2
ORDER BY totalPiezas DESC, u.idUsuario;

-- M01 a M05 | Integridad. Ejecutar este bloque completo.
PRINT 'M01 a M05 | Operaciones de mantenimiento';
DECLARE @resultados TABLE (
    orden int PRIMARY KEY, prueba varchar(24), resultado varchar(24), detalle varchar(30)
);

-- M01: una FK puede pasar a apuntar a otro padre existente.
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.Ejemplar SET idTipo = 9305 WHERE codigoInventario = 'U6-CON-01';
    IF @@ROWCOUNT <> 1 OR NOT EXISTS (
        SELECT 1 FROM dbo.Ejemplar WHERE codigoInventario = 'U6-CON-01' AND idTipo = 9305
    )
        THROW 51001, N'M01: se esperaba una pieza actualizada al tipo existente.', 1;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
IF NOT EXISTS (SELECT 1 FROM dbo.Ejemplar WHERE codigoInventario = 'U6-CON-01' AND idTipo = 9304)
    THROW 51001, N'M01: la reversión no dejó el tipo original.', 1;
INSERT @resultados VALUES (1, 'UPDATE tipo existente', 'Aceptado y revertido', '9304 > 9305 > 9304');

-- M02: una FK no puede apuntar a un padre inexistente.
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.Ejemplar SET idTipo = 999999 WHERE codigoInventario = 'U6-CON-01';
    THROW 51002, N'M02: se esperaba que la FK rechazara el UPDATE.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 547 OR ERROR_MESSAGE() NOT LIKE N'%FK_Ejemplar_Tipo%'
        THROW;
    INSERT @resultados VALUES (2, 'UPDATE tipo inexistente', 'Bloqueado (547)', 'FK_Ejemplar_Tipo');
END CATCH;

-- M03: se puede eliminar un tipo sin ejemplares dependientes.
BEGIN TRY
    BEGIN TRANSACTION;
    DELETE dbo.TipoMaterial WHERE idTipo = 9305;
    IF @@ROWCOUNT <> 1 OR EXISTS (SELECT 1 FROM dbo.TipoMaterial WHERE idTipo = 9305)
        THROW 51003, N'M03: se esperaba eliminar el tipo sin ejemplares.', 1;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
IF NOT EXISTS (SELECT 1 FROM dbo.TipoMaterial WHERE idTipo = 9305)
    THROW 51003, N'M03: no se encontró la fila restaurada.', 1;
INSERT @resultados VALUES (3, 'DELETE tipo sin hijos', 'Aceptado y revertido', '9305 sigue en el catalogo');

-- M04: ON DELETE NO ACTION protege a las piezas de un tipo con referencias.
BEGIN TRY
    BEGIN TRANSACTION;
    DELETE dbo.TipoMaterial WHERE idTipo = 9301;
    THROW 51004, N'M04: se esperaba que la FK rechazara el DELETE.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 547 OR ERROR_MESSAGE() NOT LIKE N'%FK_Ejemplar_Tipo%'
        THROW;
    INSERT @resultados VALUES (4, 'DELETE tipo con hijos', 'Bloqueado (547)', 'FK_Ejemplar_Tipo');
END CATCH;

-- M05: tampoco se puede dar de alta un teléfono sin usuario.
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT dbo.UsuarioTelefono (idUsuario, telefono) VALUES (-1, '8661000099');
    THROW 51005, N'M05: se esperaba que la FK rechazara el INSERT.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 547 OR ERROR_MESSAGE() NOT LIKE N'%FK_UsuarioTelefono_Usuario%'
        THROW;
    INSERT @resultados VALUES (5, 'INSERT telefono huerfano', 'Bloqueado (547)', 'FK_UsuarioTelefono_Usuario');
END CATCH;

SELECT CAST('M0' + CONVERT(varchar(1), orden) AS char(3)) AS caso, prueba, resultado, detalle
FROM @resultados
ORDER BY orden;
