-- ==========================================================================
-- BDD_PoliMusic - Script de creacin de tablas y datos de prueba
-- --------------------------------------------------------------------------
-- Ejecutar este script en SQL Server (Docker, puerto 14333) despus de
-- crear la base de datos BDD_PoliMusic.
--
-- Cmo ejecutar:
--   1. Conectarse con sqlcmd o Azure Data Studio a localhost,14333
--   2. Ejecutar este script
-- ==========================================================================

USE [BDD_PoliMusic];
GO

-- === TBL_USER ===========================================================
-- Tabla de usuarios. USER_TYPE: 0 = normal, 1 = admin.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TBL_USER')
BEGIN
    CREATE TABLE TBL_USER (
        ID_USER    INT IDENTITY(1,1) PRIMARY KEY,
        USERNAME   VARCHAR(50)  NOT NULL UNIQUE,
        PASSWORD   VARCHAR(50)  NOT NULL,
        EMAIL      VARCHAR(50)  NULL,
        BIRTHDAY   DATETIME     NULL,
        USER_PHOTO VARCHAR(255) NULL,
        USER_TYPE  INT          NOT NULL DEFAULT 0
    );
    PRINT 'TBL_USER creada.';
END
GO

-- === TBL_SONG ===========================================================
-- Tabla de canciones.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TBL_SONG')
BEGIN
    CREATE TABLE TBL_SONG (
        ID_SONG   INT IDENTITY(1,1) PRIMARY KEY,
        SONG_NAME VARCHAR(50)  NOT NULL,
        SONG_PATH VARCHAR(255) NOT NULL,
        PLAYS     INT          NOT NULL DEFAULT 0
    );
    PRINT 'TBL_SONG creada.';
END
GO

-- === Datos de prueba ====================================================

-- Insertar usuarios si no existen
IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'userAdmin')
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_TYPE)
    VALUES ('userAdmin', '12345678', 'admin@polimusic.edu', '1995-01-15', 1);
GO

IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'userNormal')
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_TYPE)
    VALUES ('userNormal', '12345678', 'normal@polimusic.edu', '2000-06-20', 0);
GO

-- Insertar canciones si no existen
IF NOT EXISTS (SELECT 1 FROM TBL_SONG WHERE SONG_NAME = 'Adventure')
    INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS)
    VALUES ('Adventure', '~/songFiles/bensound-adventure.mp3', 0);
GO

IF NOT EXISTS (SELECT 1 FROM TBL_SONG WHERE SONG_NAME = 'Creative Minds')
    INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS)
    VALUES ('Creative Minds', '~/songFiles/bensound-creativeminds.mp3', 0);
GO

IF NOT EXISTS (SELECT 1 FROM TBL_SONG WHERE SONG_NAME = 'Epic')
    INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS)
    VALUES ('Epic', '~/songFiles/bensound-epic.mp3', 0);
GO

IF NOT EXISTS (SELECT 1 FROM TBL_SONG WHERE SONG_NAME = 'Jazz Comedy')
    INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS)
    VALUES ('Jazz Comedy', '~/songFiles/bensound-jazzcomedy.mp3', 0);
GO

IF NOT EXISTS (SELECT 1 FROM TBL_SONG WHERE SONG_NAME = 'Little Idea')
    INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS)
    VALUES ('Little Idea', '~/songFiles/bensound-littleidea.mp3', 0);
GO

PRINT 'Datos de prueba insertados.';
GO

-- Verificar
SELECT * FROM TBL_USER;
SELECT * FROM TBL_SONG;
GO
