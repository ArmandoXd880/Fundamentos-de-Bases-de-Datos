-- Ejecutar una sola vez en SSMS. No elimina ni reemplaza bases existentes.
USE master;
IF DB_ID(N'PrestamosDeportivosU3_Grabacion') IS NOT NULL
    THROW 51000, N'La base de grabacion ya existe. Usa el paso donde te quedaste; no se ha borrado nada.', 1;
EXEC(N'CREATE DATABASE [PrestamosDeportivosU3_Grabacion]');
SELECT name, create_date FROM sys.databases WHERE name = N'PrestamosDeportivosU3_Grabacion';
