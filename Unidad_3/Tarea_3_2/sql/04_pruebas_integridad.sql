-- Casos de prueba pendientes de ejecutar. La tabla de resultados se calcula en tu instancia.
USE [PrestamosDeportivosU3];
GO
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON; SET XACT_ABORT OFF;
IF @@TRANCOUNT<>0 THROW 51000,N'Ejecuta las pruebas en una ventana sin transaccion abierta.',1;
DECLARE @ana int=(SELECT idUsuario FROM dbo.Alumno WHERE matricula='U3-A001');
DECLARE @carlos int=(SELECT idUsuario FROM dbo.Trabajador WHERE numeroEmpleado='U3-E002');
DECLARE @luis int=(SELECT idUsuario FROM dbo.Alumno WHERE matricula='U3-A003');
DECLARE @e1 int=(SELECT idEjemplar FROM dbo.Ejemplar WHERE codigoInventario='U3-BAL-01');
DECLARE @e3 int=(SELECT idEjemplar FROM dbo.Ejemplar WHERE codigoInventario='U3-BAL-03');
DECLARE @p1 int=(SELECT idPrestamo FROM dbo.DetallePrestamo WHERE idEjemplar=@e1 AND fechaDevolucion IS NULL);
DECLARE @p2 int=(SELECT idPrestamo FROM dbo.DetallePrestamo WHERE idEjemplar=@e3 AND fechaDevolucion IS NULL);
IF @ana IS NULL OR @carlos IS NULL OR @luis IS NULL OR @p1 IS NULL OR @p2 IS NULL
 THROW 51000,N'Faltan los datos de 03_datos_ejemplo.sql o fueron modificados.',1;
DECLARE @casos TABLE(id int IDENTITY PRIMARY KEY,nombre nvarchar(120),sentencia nvarchar(max),errores varchar(50));
INSERT @casos(nombre,sentencia,errores) VALUES
(N'PK repetida',N'INSERT dbo.TipoMaterial VALUES(9301,N''Duplicado'',N''Prueba'');','2627'),
(N'FK sin padre',N'INSERT dbo.Ejemplar(codigoInventario,idTipo) VALUES(''U3-HUERFANO'',999999);','547'),
(N'Dominio de estado',N'UPDATE dbo.Ejemplar SET estadoOperativo=''invalido'' WHERE idEjemplar=@e1;','547'),
(N'NOT NULL',N'INSERT dbo.Usuario(nombres,primerApellido,fechaNacimiento) VALUES(NULL,N''Prueba'',''2000-01-01'');','515'),
(N'Codigo de inventario unico',N'INSERT dbo.Ejemplar(codigoInventario,idTipo) VALUES(''U3-BAL-01'',9301);','2627'),
(N'Una pieza abierta una sola vez',N'INSERT dbo.DetallePrestamo(idPrestamo,numeroRenglon,idEjemplar,condicionSalida) VALUES(@p2,99,@e1,N''Prueba'');','2601,2627'),
(N'Devolucion con ambos datos',N'UPDATE dbo.DetallePrestamo SET fechaDevolucion=''2026-10-31T12:00:00'' WHERE idPrestamo=@p1 AND numeroRenglon=1;','547'),
(N'Orden de fechas',N'INSERT dbo.Prestamo(idSolicitante,idRegistrador,fechaSalida,fechaLimite) VALUES(@ana,@carlos,''2026-10-31'',''2026-10-30'');','547'),
(N'Cascada al eliminar usuario sin historial',N'DELETE dbo.Usuario WHERE idUsuario=@luis; IF EXISTS(SELECT 1 FROM dbo.UsuarioTelefono WHERE idUsuario=@luis) OR EXISTS(SELECT 1 FROM dbo.Alumno WHERE idUsuario=@luis) OR EXISTS(SELECT 1 FROM dbo.Trabajador WHERE idUsuario=@luis) THROW 51999,N''Cascada incompleta.'',1;','0'),
(N'Cascada al actualizar el tipo',N'UPDATE dbo.TipoMaterial SET idTipo=9401 WHERE idTipo=9301; IF (SELECT COUNT(*) FROM dbo.Ejemplar WHERE idTipo=9401)<>3 THROW 51999,N''La clave no se propago.'',1;','0'),
(N'Proteccion de usuario con historial',N'DELETE dbo.Usuario WHERE idUsuario=@ana;','547'),
(N'FK compuesta de incidencia',N'INSERT dbo.Incidencia(idPrestamo,numeroRenglon,fechaReporte,descripcion) VALUES(@p1,999,''2026-10-31'',N''Prueba'');','547'),
(N'Totalidad de perfiles',N'DECLARE @tel dbo.TelefonosTipo; DECLARE @id int; EXEC dbo.uspCrearUsuario @nombres=N''Prueba'',@primerApellido=N''SinPerfil'',@fechaNacimiento=''2000-01-01'',@esAlumno=0,@esTrabajador=0,@telefonos=@tel,@idUsuario=@id OUTPUT;','51001'),
(N'Prestamo sin piezas',N'DECLARE @d dbo.DetallesPrestamoTipo; DECLARE @id int; EXEC dbo.uspRegistrarPrestamo @ana,@carlos,''2026-10-31'',''2026-11-01'',@d,@id OUTPUT;','51002'),
(N'Solicitante inactivo',N'DECLARE @d dbo.DetallesPrestamoTipo; DECLARE @id int; INSERT @d VALUES(1,@e1,N''Prueba''); EXEC dbo.uspRegistrarPrestamo @luis,@carlos,''2026-10-31'',''2026-11-01'',@d,@id OUTPUT;','51003'),
(N'Registrador no habilitado',N'DECLARE @d dbo.DetallesPrestamoTipo; DECLARE @id int; INSERT @d VALUES(1,@e1,N''Prueba''); EXEC dbo.uspRegistrarPrestamo @ana,@ana,''2026-10-31'',''2026-11-01'',@d,@id OUTPUT;','51004'),
(N'Devolucion anterior a salida',N'EXEC dbo.uspDevolverEjemplar @p1,1,''2026-10-29T12:00:00'',N''Prueba'';','51008'),
(N'Incidencia anterior a salida',N'DECLARE @id int; EXEC dbo.uspRegistrarIncidencia @p1,1,''2026-10-29T12:00:00'',N''Prueba'',@id OUTPUT;','51010'),
(N'Devolver y volver a prestar conservando historial',N'EXEC dbo.uspDevolverEjemplar @p1,1,''2026-10-31T12:00:00'',N''Buen estado''; DECLARE @d dbo.DetallesPrestamoTipo; DECLARE @nuevo int; INSERT @d VALUES(1,@e1,N''Buen estado''); EXEC dbo.uspRegistrarPrestamo @ana,@carlos,''2026-10-31T13:00:00'',''2026-11-02'',@d,@nuevo OUTPUT; IF (SELECT COUNT(*) FROM dbo.DetallePrestamo WHERE idEjemplar=@e1)<>2 THROW 51999,N''Historial incorrecto.'',1;','0'),
(N'Identidad compartida en la jerarquia',N'IF NOT EXISTS(SELECT 1 FROM dbo.Usuario u JOIN dbo.Alumno a ON a.idUsuario=u.idUsuario JOIN dbo.Trabajador t ON t.idUsuario=u.idUsuario WHERE u.idUsuario=@ana) THROW 51999,N''No conserva ambos perfiles.'',1;','0');

DECLARE @resultados TABLE(id int,nombre nvarchar(120),resultado varchar(10),errorReal int,detalle nvarchar(2048));
DECLARE @i int,@nombre nvarchar(120),@sql nvarchar(max),@errores varchar(50),@err int,@msg nvarchar(2048);
DECLARE pruebas CURSOR LOCAL FAST_FORWARD FOR SELECT id,nombre,sentencia,errores FROM @casos ORDER BY id;
OPEN pruebas; FETCH NEXT FROM pruebas INTO @i,@nombre,@sql,@errores;
WHILE @@FETCH_STATUS=0
BEGIN
 SET @err=0; SET @msg=N'Operacion aceptada.';
 BEGIN TRY
  BEGIN TRANSACTION;
  EXEC sys.sp_executesql @sql,N'@ana int,@carlos int,@luis int,@e1 int,@p1 int,@p2 int',
      @ana,@carlos,@luis,@e1,@p1,@p2;
  IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 END TRY BEGIN CATCH
  SET @err=ERROR_NUMBER(); SET @msg=ERROR_MESSAGE();
  IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 END CATCH;
 INSERT @resultados VALUES(@i,@nombre,
   CASE WHEN CHARINDEX(','+CONVERT(varchar(12),@err)+',',','+@errores+',')>0 THEN 'CORRECTO' ELSE 'FALLO' END,@err,@msg);
 FETCH NEXT FROM pruebas INTO @i,@nombre,@sql,@errores;
END;
CLOSE pruebas; DEALLOCATE pruebas;
SELECT * FROM @resultados ORDER BY id;
SELECT COUNT(*) AS Total,SUM(CASE WHEN resultado='CORRECTO' THEN 1 ELSE 0 END) AS Correctas,
 SUM(CASE WHEN resultado='FALLO' THEN 1 ELSE 0 END) AS Fallidas FROM @resultados;
IF EXISTS(SELECT 1 FROM @resultados WHERE resultado='FALLO')
 THROW 51099,N'Hay pruebas fallidas. Guarda el resultado real y revisa antes de declarar validado el esquema.',1;
-- Las transacciones de prueba se revierten; los valores IDENTITY pueden presentar saltos.
