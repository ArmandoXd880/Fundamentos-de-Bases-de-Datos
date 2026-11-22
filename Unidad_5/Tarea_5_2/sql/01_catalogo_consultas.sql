-- Unidad 5 / Tarea 5.2. Álgebra relacional en SQL Server.

-- Para una demostración en SSMS, selecciona un bloque completo (incluye WITH si aparece).

USE [PrestamosDeportivosU4];
SET NOCOUNT ON;

-- C01 · Usuarios activos

SELECT DISTINCT idUsuario, nombres
FROM dbo.Usuario
WHERE activo = 1
ORDER BY idUsuario;

-- C02 · Carreras representadas

SELECT DISTINCT carrera
FROM dbo.Alumno
ORDER BY carrera;

-- C03 · Combinaciones posibles de usuarios y tipos

;WITH UsuariosActivos AS (
    SELECT DISTINCT idUsuario, nombres
    FROM dbo.Usuario
    WHERE activo = 1
)
SELECT u.idUsuario, u.nombres, t.idTipo, t.nombre AS tipo
FROM UsuariosActivos AS u
CROSS JOIN dbo.TipoMaterial AS t
ORDER BY idUsuario, idTipo;

-- C04 · Usuarios con al menos un perfil

SELECT idUsuario FROM dbo.Alumno
UNION
SELECT idUsuario FROM dbo.Trabajador
ORDER BY idUsuario;

-- C05 · Usuarios con ambos perfiles

SELECT idUsuario FROM dbo.Alumno
INTERSECT
SELECT idUsuario FROM dbo.Trabajador
ORDER BY idUsuario;

-- C06 · Usuarios que nunca solicitaron un préstamo

SELECT idUsuario FROM dbo.Usuario
EXCEPT
SELECT idSolicitante AS idUsuario FROM dbo.Prestamo
ORDER BY idUsuario;

-- C07 · Piezas pendientes de basquetbol con plazo vencido

;WITH TiposBasquetbol AS (
    SELECT DISTINCT idTipo
    FROM dbo.TipoMaterial
    WHERE deporte = N'Basquetbol'
),
PiezasBasquetbol AS (
    SELECT DISTINCT e.idEjemplar, e.codigoInventario
    FROM dbo.Ejemplar AS e
    INNER JOIN TiposBasquetbol AS t ON t.idTipo = e.idTipo
),
Pendientes AS (
    SELECT DISTINCT idPrestamo, numeroRenglon, idEjemplar
    FROM dbo.DetallePrestamo
    WHERE fechaDevolucion IS NULL
),
PrestamosVencidos AS (
    SELECT DISTINCT idPrestamo, fechaLimite
    FROM dbo.Prestamo
    WHERE fechaLimite < '2026-11-02T00:00:00'
)
SELECT DISTINCT p.idPrestamo, e.codigoInventario, p.fechaLimite
FROM Pendientes AS d
INNER JOIN PiezasBasquetbol AS e ON e.idEjemplar = d.idEjemplar
INNER JOIN PrestamosVencidos AS p ON p.idPrestamo = d.idPrestamo
ORDER BY idPrestamo, codigoInventario;

-- C08 · Incidencias abiertas y su pieza exacta

;WITH IncidenciasAbiertas AS (
    SELECT DISTINCT idIncidencia, idPrestamo, numeroRenglon
    FROM dbo.Incidencia
    WHERE estado = 'abierta'
),
PiezasPorRenglon AS (
    SELECT DISTINCT idPrestamo, numeroRenglon, idEjemplar
    FROM dbo.DetallePrestamo
)
SELECT DISTINCT i.idIncidencia, e.codigoInventario
FROM IncidenciasAbiertas AS i
INNER JOIN PiezasPorRenglon AS d
    ON d.idPrestamo = i.idPrestamo
    AND d.numeroRenglon = i.numeroRenglon
INNER JOIN dbo.Ejemplar AS e ON e.idEjemplar = d.idEjemplar
ORDER BY idIncidencia;

-- C09 · Usuarios activos que pidieron ambos ejemplares requeridos

;WITH Requeridos AS (
    SELECT v.codigoInventario
    FROM (VALUES ('U3-BAL-01'), ('U3-BAL-03')) AS v(codigoInventario)
),
Pares AS (
    SELECT DISTINCT p.idSolicitante, e.codigoInventario
    FROM dbo.Prestamo AS p
    INNER JOIN dbo.DetallePrestamo AS d ON d.idPrestamo = p.idPrestamo
    INNER JOIN dbo.Ejemplar AS e ON e.idEjemplar = d.idEjemplar
),
Candidatos AS (
    SELECT DISTINCT idSolicitante FROM Pares
),
UsuariosActivos AS (
    SELECT DISTINCT idUsuario, nombres
    FROM dbo.Usuario
    WHERE activo = 1
)
SELECT DISTINCT u.idUsuario, u.nombres
FROM Candidatos AS c
INNER JOIN UsuariosActivos AS u ON u.idUsuario = c.idSolicitante
WHERE NOT EXISTS (
    SELECT 1
    FROM Requeridos AS s
    WHERE NOT EXISTS (
        SELECT 1
        FROM Pares AS r
        WHERE r.idSolicitante = c.idSolicitante
          AND r.codigoInventario = s.codigoInventario
    )
)
ORDER BY idUsuario;

-- C10 · Total de préstamos solicitados por usuario

SELECT u.idUsuario, u.nombres, COUNT(p.idPrestamo) AS totalPrestamos
FROM dbo.Usuario AS u
LEFT JOIN dbo.Prestamo AS p ON p.idSolicitante = u.idUsuario
GROUP BY u.idUsuario, u.nombres
ORDER BY idUsuario;
