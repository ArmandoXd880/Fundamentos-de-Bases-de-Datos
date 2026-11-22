-- Comprueba cada conjunto de resultados en las dos direcciones y revisa el número de filas.

-- Los identificadores esperados son los generados al cargar la base vacía por primera vez.

USE [PrestamosDeportivosU4];
SET NOCOUNT ON;

-- C01 · Usuarios activos

;WITH Obtenido AS (
    SELECT DISTINCT idUsuario, nombres
    FROM dbo.Usuario
    WHERE activo = 1
),
Esperado AS (
    SELECT idUsuario, nombres
    FROM (VALUES
        (1, N'Ana'),
        (2, N'Carlos')
    ) AS v(idUsuario, nombres)
)
SELECT 'C01' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario, nombres FROM Obtenido
           EXCEPT
           SELECT idUsuario, nombres FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario, nombres FROM Esperado
           EXCEPT
           SELECT idUsuario, nombres FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C02 · Carreras representadas

;WITH Obtenido AS (
    SELECT DISTINCT carrera
    FROM dbo.Alumno
),
Esperado AS (
    SELECT carrera
    FROM (VALUES
        (N'Informatica')
    ) AS v(carrera)
)
SELECT 'C02' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT carrera FROM Obtenido
           EXCEPT
           SELECT carrera FROM Esperado
       ) OR EXISTS (
           SELECT carrera FROM Esperado
           EXCEPT
           SELECT carrera FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C03 · Combinaciones posibles de usuarios y tipos

;WITH UsuariosActivos AS (
    SELECT DISTINCT idUsuario, nombres
    FROM dbo.Usuario
    WHERE activo = 1
),
Obtenido AS (
    SELECT u.idUsuario, u.nombres, t.idTipo, t.nombre AS tipo
    FROM UsuariosActivos AS u
    CROSS JOIN dbo.TipoMaterial AS t
),
Esperado AS (
    SELECT idUsuario, nombres, idTipo, tipo
    FROM (VALUES
        (1, N'Ana', 9301, N'Balon'),
        (2, N'Carlos', 9301, N'Balon')
    ) AS v(idUsuario, nombres, idTipo, tipo)
)
SELECT 'C03' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario, nombres, idTipo, tipo FROM Obtenido
           EXCEPT
           SELECT idUsuario, nombres, idTipo, tipo FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario, nombres, idTipo, tipo FROM Esperado
           EXCEPT
           SELECT idUsuario, nombres, idTipo, tipo FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C04 · Usuarios con al menos un perfil

;WITH Obtenido AS (
    SELECT idUsuario FROM dbo.Alumno
    UNION
    SELECT idUsuario FROM dbo.Trabajador
),
Esperado AS (
    SELECT idUsuario
    FROM (VALUES
        (1),
        (2),
        (3)
    ) AS v(idUsuario)
)
SELECT 'C04' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario FROM Obtenido
           EXCEPT
           SELECT idUsuario FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario FROM Esperado
           EXCEPT
           SELECT idUsuario FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C05 · Usuarios con ambos perfiles

;WITH Obtenido AS (
    SELECT idUsuario FROM dbo.Alumno
    INTERSECT
    SELECT idUsuario FROM dbo.Trabajador
),
Esperado AS (
    SELECT idUsuario
    FROM (VALUES
        (1),
        (3)
    ) AS v(idUsuario)
)
SELECT 'C05' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario FROM Obtenido
           EXCEPT
           SELECT idUsuario FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario FROM Esperado
           EXCEPT
           SELECT idUsuario FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C06 · Usuarios que nunca solicitaron un préstamo

;WITH Obtenido AS (
    SELECT idUsuario FROM dbo.Usuario
    EXCEPT
    SELECT idSolicitante AS idUsuario FROM dbo.Prestamo
),
Esperado AS (
    SELECT idUsuario
    FROM (VALUES
        (2),
        (3)
    ) AS v(idUsuario)
)
SELECT 'C06' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario FROM Obtenido
           EXCEPT
           SELECT idUsuario FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario FROM Esperado
           EXCEPT
           SELECT idUsuario FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

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
),
Obtenido AS (
    SELECT DISTINCT p.idPrestamo, e.codigoInventario, p.fechaLimite
    FROM Pendientes AS d
    INNER JOIN PiezasBasquetbol AS e ON e.idEjemplar = d.idEjemplar
    INNER JOIN PrestamosVencidos AS p ON p.idPrestamo = d.idPrestamo
),
Esperado AS (
    SELECT idPrestamo, codigoInventario, fechaLimite
    FROM (VALUES
        (1, 'U3-BAL-01', CAST('2026-11-01T18:00:00' AS datetime2(0))),
        (1, 'U3-BAL-02', CAST('2026-11-01T18:00:00' AS datetime2(0))),
        (2, 'U3-BAL-03', CAST('2026-11-01T18:00:00' AS datetime2(0)))
    ) AS v(idPrestamo, codigoInventario, fechaLimite)
)
SELECT 'C07' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idPrestamo, codigoInventario, fechaLimite FROM Obtenido
           EXCEPT
           SELECT idPrestamo, codigoInventario, fechaLimite FROM Esperado
       ) OR EXISTS (
           SELECT idPrestamo, codigoInventario, fechaLimite FROM Esperado
           EXCEPT
           SELECT idPrestamo, codigoInventario, fechaLimite FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C08 · Incidencias abiertas y su pieza exacta

;WITH IncidenciasAbiertas AS (
    SELECT DISTINCT idIncidencia, idPrestamo, numeroRenglon
    FROM dbo.Incidencia
    WHERE estado = 'abierta'
),
PiezasPorRenglon AS (
    SELECT DISTINCT idPrestamo, numeroRenglon, idEjemplar
    FROM dbo.DetallePrestamo
),
Obtenido AS (
    SELECT DISTINCT i.idIncidencia, e.codigoInventario
    FROM IncidenciasAbiertas AS i
    INNER JOIN PiezasPorRenglon AS d
        ON d.idPrestamo = i.idPrestamo
        AND d.numeroRenglon = i.numeroRenglon
    INNER JOIN dbo.Ejemplar AS e ON e.idEjemplar = d.idEjemplar
),
Esperado AS (
    SELECT idIncidencia, codigoInventario
    FROM (VALUES
        (1, 'U3-BAL-01')
    ) AS v(idIncidencia, codigoInventario)
)
SELECT 'C08' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idIncidencia, codigoInventario FROM Obtenido
           EXCEPT
           SELECT idIncidencia, codigoInventario FROM Esperado
       ) OR EXISTS (
           SELECT idIncidencia, codigoInventario FROM Esperado
           EXCEPT
           SELECT idIncidencia, codigoInventario FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

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
),
Obtenido AS (
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
),
Esperado AS (
    SELECT idUsuario, nombres
    FROM (VALUES
        (1, N'Ana')
    ) AS v(idUsuario, nombres)
)
SELECT 'C09' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario, nombres FROM Obtenido
           EXCEPT
           SELECT idUsuario, nombres FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario, nombres FROM Esperado
           EXCEPT
           SELECT idUsuario, nombres FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;

-- C10 · Total de préstamos solicitados por usuario

;WITH Obtenido AS (
    SELECT u.idUsuario, u.nombres, COUNT(p.idPrestamo) AS totalPrestamos
    FROM dbo.Usuario AS u
    LEFT JOIN dbo.Prestamo AS p ON p.idSolicitante = u.idUsuario
    GROUP BY u.idUsuario, u.nombres
),
Esperado AS (
    SELECT idUsuario, nombres, totalPrestamos
    FROM (VALUES
        (1, N'Ana', 2),
        (2, N'Carlos', 0),
        (3, N'Luis', 0)
    ) AS v(idUsuario, nombres, totalPrestamos)
)
SELECT 'C10' AS consulta,
       (SELECT COUNT(*) FROM Obtenido) AS obtenidas,
       (SELECT COUNT(*) FROM Esperado) AS esperadas,
       CASE WHEN EXISTS (
           SELECT idUsuario, nombres, totalPrestamos FROM Obtenido
           EXCEPT
           SELECT idUsuario, nombres, totalPrestamos FROM Esperado
       ) OR EXISTS (
           SELECT idUsuario, nombres, totalPrestamos FROM Esperado
           EXCEPT
           SELECT idUsuario, nombres, totalPrestamos FROM Obtenido
       ) OR (SELECT COUNT(*) FROM Obtenido) <> (SELECT COUNT(*) FROM Esperado)
       THEN 'DIFERENCIA' ELSE 'OK' END AS validacion;
