-- Ejecutar una sola vez en SSMS. No elimina ni reemplaza bases existentes.
USE master;
IF DB_ID(N'PrestamosDeportivosU3') IS NOT NULL
    THROW 51000, N'La base ya existe. No se ha borrado nada. Revisa su contenido antes de continuar.', 1;
EXEC(N'CREATE DATABASE [PrestamosDeportivosU3]');
SELECT name, create_date FROM sys.databases WHERE name = N'PrestamosDeportivosU3';
