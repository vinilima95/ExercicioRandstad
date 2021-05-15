/*

Criação do DB Script gerado pela interface gráfica da ferramenta 

CREATE DATABASE [DB_Teste_01]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DB_Teste_01', FILENAME = N'S:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\DB_Teste_01.mdf' , SIZE = 3072KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DB_Teste_01_log', FILENAME = N'S:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\DATA\DB_Teste_01_log.ldf' , SIZE = 66560KB , FILEGROWTH = 131072KB )
GO
ALTER DATABASE [DB_Teste_01] SET COMPATIBILITY_LEVEL = 130
GO
ALTER DATABASE [DB_Teste_01] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DB_Teste_01] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DB_Teste_01] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DB_Teste_01] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DB_Teste_01] SET ARITHABORT OFF 
GO
ALTER DATABASE [DB_Teste_01] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DB_Teste_01] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DB_Teste_01] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [DB_Teste_01] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DB_Teste_01] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DB_Teste_01] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DB_Teste_01] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DB_Teste_01] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DB_Teste_01] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DB_Teste_01] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DB_Teste_01] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DB_Teste_01] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DB_Teste_01] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DB_Teste_01] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DB_Teste_01] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DB_Teste_01] SET  READ_WRITE 
GO
ALTER DATABASE [DB_Teste_01] SET RECOVERY FULL 
GO
ALTER DATABASE [DB_Teste_01] SET  MULTI_USER 
GO
ALTER DATABASE [DB_Teste_01] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DB_Teste_01] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DB_Teste_01] SET DELAYED_DURABILITY = DISABLED 
GO
USE [DB_Teste_01]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = On;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary;
GO
USE [DB_Teste_01]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [DB_Teste_01] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO

*/

/* ############## FIM DA CRIAÇÃO DA BASE */

-- dependendo da regra de importação
-- creio que seria melhor usar um ID em alguns campos para garantir a integridade da informação, por exemplo os campos
-- TipoInstrumento, moeda, Indexador Calendarios, Basis e País ao invés da descrição por texto
-- pode facilitar futuramente caso seja necessário realizar algum tipo de filtragem na base

-- criação das tabelas auxiliares

-- Tabelas de carga para receber os dados dos arquivos CSV

-- tabelas de carga para importação do csv
DROP TABLE IF EXISTS Carga_Contratos
CREATE TABLE Carga_Contratos (
	IDContrato VARCHAR (255),
	ContratoCodigo VARCHAR (255),
	NomeContrato VARCHAR (255),
	TipoInstrumento	VARCHAR (255),
	Vencimento VARCHAR (255),
	Emissao	VARCHAR (255),
	Moeda VARCHAR (255),
	Indexador VARCHAR (255),
	Calendario VARCHAR (255),
	Basis VARCHAR (255),
	Pais VARCHAR (255),
	SeriePreco VARCHAR (255))

DROP TABLE IF EXISTS Carga_Cronograma
CREATE TABLE Carga_Cronograma (
	IDContrato VARCHAR (255),
	DataFoto VARCHAR (255),	
	IDTranche VARCHAR (255),	
	Tipo VARCHAR (255),	
	[DataBase] VARCHAR (255),	
	DataBaixa VARCHAR (255),
	DataEvento VARCHAR (255),	
	Projetado VARCHAR (255),	
	Realizado VARCHAR (255),	
	TaxaCambio VARCHAR (255),	
	TaxaVariante VARCHAR (255),	
	Taxa VARCHAR (255),	
	FoiRealizado VARCHAR (255))

DROP TABLE IF EXISTS Carga_Delta_Cronograma
CREATE TABLE Carga_Delta_Cronograma (
	IDContrato VARCHAR (255),	
	DataFoto VARCHAR (255),	
	IDTranche VARCHAR (255),	
	Tipo VARCHAR (255),	
	[DataBase] VARCHAR (255),	
	DataBaixa VARCHAR (255),	
	DataEvento VARCHAR (255),	
	Projetado VARCHAR (255),	
	Realizado VARCHAR (255),	
	TaxaCambio VARCHAR (255),	
	TaxaVariante VARCHAR (255),	
	Taxa VARCHAR (255),	
	FoiRealizado VARCHAR (255))

-- necessário validar a importação para o caminho do seu arquivo e para o  seu banco
Declare @bcpCommand as varchar(8000) = 'bcp Carga_Contratos in S:\ArquivosTeste\Arquivo1_Contratos.csv -d DB_Teste_01 -t; -T -c -S' + @@servername
Exec master..xp_cmdshell @bcpCommand
GO

Declare @bcpCommand as varchar(8000) = 'bcp Carga_Cronograma in S:\ArquivosTeste\Arquivo2_Cronograma.csv -d DB_Teste_01 -t; -T -c -S' + @@servername
Exec master..xp_cmdshell @bcpCommand
GO

Declare @bcpCommand as varchar(8000) = 'bcp Carga_Delta_Cronograma in S:\ArquivosTeste\Arquivo3_Delta_Cronograma.csv -d DB_Teste_01 -t; -T -c -S' + @@servername
Exec master..xp_cmdshell @bcpCommand
GO

DELETE FROM Carga_Contratos WHERE IDContrato = 'IDContrato'
DELETE FROM Carga_Cronograma WHERE IDContrato = 'IDContrato'
DELETE FROM Carga_Delta_Cronograma WHERE IDContrato = 'IDContrato'

-- criação das tabelas principais

DROP TABLE IF EXISTS TB_Contratos
CREATE TABLE TB_Contratos (
	IDContrato BIGINT CONSTRAINT IDContrato PRIMARY KEY,
	Contrato_Codigo VARCHAR (255),
	NomeContrato VARCHAR (255),
	TipoInstrumento_id SMALLINT,
	Vencimento DATE,
	Emissao DATE,
	Moeda_id SMALLINT,
	Indexador_id SMALLINT,
	Calendario_id SMALLINT,
	Basis_id SMALLINT,
	Pais_id SMALLINT,
	SeriePreco VARCHAR (255),
	DataUltimoFluxo DATETIME2,
	Status_Cod INT,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

ALTER TABLE dbo.TB_Contratos
	 ADD DtHrInicio DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN 
         CONSTRAINT DF_TB_Contratos_DtHrInicio DEFAULT DATEADD(second, -1, SYSUTCDATETIME()),
	 DtHrFinal DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN 
         CONSTRAINT DF_TB_Contratos_DtHrFinal DEFAULT CONVERT(datetime2 (0), '9999-12-31 23:59:59'),
	 PERIOD FOR SYSTEM_TIME (DtHrInicio, DtHrFinal);
GO

ALTER TABLE dbo.TB_Contratos SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.TB_Contratos_Historico));

DROP TABLE IF EXISTS TB_Cronograma
CREATE TABLE TB_Cronograma (
	Cronograma_id INT IDENTITY PRIMARY KEY,
	IDFluxo INT,
	IDContrato INT,
	DataFoto DATE,
	IDTranche INT,
	Tipo SMALLINT,
	[DataBase] DATE,
	DataBaixa DATE,
	DataEvento DATE,
	Projetado NUMERIC (18,2),
	Realizado NUMERIC (18,2),
	TaxaCambio NUMERIC (18,2),
	TaxaVariante NUMERIC (18,2),
	Taxa NUMERIC (18,2),
	FoiRealizado BIT,
	Status_cod INT DEFAULT 1,
	DtHrCadastro DATETIME2)
	
ALTER TABLE dbo.TB_Cronograma
	 ADD DtHrInicio DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN 
         CONSTRAINT DF_TB_Cronograma_DtHrInicio DEFAULT DATEADD(second, -1, SYSUTCDATETIME()),
	 DtHrFinal DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN 
         CONSTRAINT DF_TB_Cronograma_DtHrFinal DEFAULT CONVERT(datetime2 (0), '9999-12-31 23:59:59'),
	 PERIOD FOR SYSTEM_TIME (DtHrInicio, DtHrFinal);
	
ALTER TABLE dbo.TB_Cronograma SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.TB_Cronograma_Historico));

-- teste para ver se o versionamento funcionou corretamente

INSERT INTO TB_Contratos (IDContrato, Contrato_Codigo, TipoInstrumento_id, Vencimento, Emissao, Moeda_id, Indexador_id, Calendario_id, Basis_id, Pais_id, SeriePreco, Status_Cod, DtHrCadastro)
VALUES (1, 'ContratoTeste', 1, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE), 1, 1, 1, 1, 1, 'Teste', 1, DEFAULT);

-- tabela de versionamento vazia
SELECT * FROM TB_Contratos_Historico

-- atualiza um campo da tabela principal
UPDATE TB_Contratos SET Status_Cod = 2 WHERE IDContrato = 1

-- guarda o estado anterior da linha e o periodo que esteve sem modificação
SELECT * FROM TB_Contratos_Historico tc

-- limpa o teste da tabela, não é possível truncar a tabela com versionamento
DELETE FROM TB_Contratos 

DROP TABLE IF EXISTS TB_TipoInstrumento
CREATE TABLE TB_TipoInstrumento (
	TipoInstrumento_id INT IDENTITY PRIMARY KEY,
	TipoInstrumento VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Moedas
CREATE TABLE TB_Moedas (
	Moeda_id INT IDENTITY PRIMARY KEY,
	Moeda VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Indexador
CREATE TABLE TB_Indexador (
	Indexador_id INT IDENTITY PRIMARY KEY,
	Indexador VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Calendario
CREATE TABLE TB_Calendario (
	Calendario_id INT IDENTITY PRIMARY KEY,
	Calendario VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Basis
CREATE TABLE TB_Basis (
	Basis_id INT IDENTITY PRIMARY KEY,
	Basis VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Pais
CREATE TABLE TB_Pais (
	Pais_id INT IDENTITY PRIMARY KEY,
	Pais VARCHAR (255),
	Status_cod BIT DEFAULT 1,
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

DROP TABLE IF EXISTS TB_Contratos_XML
CREATE TABLE TB_Contratos_XML (
	IDContrato INT,
	Contrato_XML VARCHAR (MAX),
	DtHrCadastro DATETIME2 DEFAULT GETDATE())

INSERT INTO TB_TipoInstrumento (TipoInstrumento)
SELECT DISTINCT RTRIM(LTRIM(UPPER(cc.TipoInstrumento)))
FROM Carga_Contratos cc
LEFT JOIN TB_TipoInstrumento tti ON cc.TipoInstrumento = tti.TipoInstrumento
WHERE tti.TipoInstrumento_id IS NULL

INSERT INTO TB_Moedas (Moeda)
SELECT DISTINCT  RTRIM(LTRIM(UPPER(cc.Moeda)))
FROM Carga_Contratos cc	
LEFT JOIN TB_Moedas tm ON cc.Moeda = tm.Moeda
WHERE tm.Moeda_id IS NULL
AND cc.Moeda COLLATE SQL_Latin1_General_CP1_CI_AI NOT LIKE '%NULL%' --> Coloquei isso aqui pois no excel tinha alguns valores que estavam com a string "null"
AND ISNULL(cc.Moeda,'') <> ''

INSERT INTO TB_Indexador (Indexador)
SELECT DISTINCT RTRIM(LTRIM(UPPER(cc.Indexador)))
FROM Carga_Contratos cc
LEFT JOIN TB_Indexador ti ON cc.Indexador = ti.Indexador
WHERE ti.Indexador_id IS NULL
AND cc.Indexador COLLATE SQL_Latin1_General_CP1_CI_AI NOT LIKE '%NULL%' --> Coloquei isso aqui pois no excel tinha alguns valores que estavam com a string "null"
AND ISNULL(cc.Indexador,'') <> ''

INSERT INTO TB_Calendario (Calendario)
SELECT DISTINCT RTRIM(LTRIM(UPPER(cc.Calendario)))
FROM Carga_Contratos cc
LEFT JOIN TB_Calendario ti ON cc.Calendario = ti.Calendario
WHERE ti.Calendario_id IS NULL
AND cc.Calendario COLLATE SQL_Latin1_General_CP1_CI_AI NOT LIKE '%NULL%' --> Coloquei isso aqui pois no excel tinha alguns valores que estavam com a string "null"
AND ISNULL(cc.Calendario,'') <> ''

INSERT INTO TB_Basis (Basis)
SELECT DISTINCT RTRIM(LTRIM(UPPER(cc.Basis)))
FROM Carga_Contratos cc
LEFT JOIN TB_Basis ti ON cc.Basis = ti.Basis
WHERE ti.Basis IS NULL
AND cc.Basis COLLATE SQL_Latin1_General_CP1_CI_AI NOT LIKE '%NULL%' --> Coloquei isso aqui pois no excel tinha alguns valores que estavam com a string "null"
AND ISNULL(cc.Basis,'') <> ''

INSERT INTO TB_Pais (Pais)
SELECT DISTINCT RTRIM(LTRIM(UPPER(cc.Pais)))
FROM Carga_Contratos cc
LEFT JOIN TB_Pais ti ON cc.Calendario = ti.Pais
WHERE ti.Pais IS NULL
AND cc.Pais COLLATE SQL_Latin1_General_CP1_CI_AI NOT LIKE '%NULL%' --> Coloquei isso aqui pois no excel tinha alguns valors que estavam com a string "null"
AND ISNULL(cc.Pais,'') <> ''


INSERT INTO TB_Contratos (IDContrato, Contrato_Codigo, NomeContrato, TipoInstrumento_id, Vencimento, Emissao, Moeda_id, Indexador_id, Calendario_id, Basis_id, Pais_id, SeriePreco, Status_Cod, DtHrCadastro)
SELECT DISTINCT 
	cc.IDContrato AS IDContrato, 
	UPPER(RTRIM(LTRIM(cc.ContratoCodigo))) AS Contrato_Codigo, 
	UPPER(RTRIM(LTRIM(cc.NomeContrato))) AS NomeContrato,
	tti.TipoInstrumento_id, 
	TRY_CAST(SUBSTRING(cc.Vencimento,7,4) + '-' + SUBSTRING(cc.Vencimento,4,2) + '-' + SUBSTRING(cc.Vencimento,1,2) AS DATE) AS Vencimento, 
	TRY_CAST(SUBSTRING(cc.Emissao,7,4) + '-' + SUBSTRING(cc.Emissao,4,2) + '-' + SUBSTRING(cc.Emissao,1,2) AS DATE) AS Emissao, 
	tm.Moeda_id, 
	ti.Indexador_id, 
	tc.Calendario_id, 
	tb.Basis_id, 
	tp.Pais_id, 
	cc.SeriePreco, 
	CASE 
		WHEN TRY_CAST(SUBSTRING(cc.Vencimento,7,4) + '-' + SUBSTRING(cc.Vencimento,4,2) + '-' + SUBSTRING(cc.Vencimento,1,2) AS DATE) > CAST(GETDATE() AS DATE) THEN 2 --> Nesse caso deixei como status cod 2 "vencido"
		WHEN TRY_CAST(SUBSTRING(cc.Vencimento,7,4) + '-' + SUBSTRING(cc.Vencimento,4,2) + '-' + SUBSTRING(cc.Vencimento,1,2) AS DATE) <= CAST(GETDATE() AS DATE) THEN 1 
	END Status_Cod, 
	GETDATE() DtHrCadastro 
FROM Carga_Contratos cc
LEFT JOIN TB_TipoInstrumento tti ON cc.TipoInstrumento =tti.TipoInstrumento
LEFT JOIN TB_Moedas tm ON cc.Moeda = tm.Moeda
LEFT JOIN TB_Indexador ti ON cc.Indexador = ti.Indexador
LEFT JOIN TB_Calendario tc ON cc.Calendario = tc.Calendario
LEFT JOIN TB_Basis tb ON cc.Basis = tb.Basis
LEFT JOIN TB_Pais tp ON cc.Pais = tp.Pais
LEFT JOIN TB_Contratos tc1 ON cc.IDContrato = tc1.IDContrato
WHERE tc1.IDContrato IS NULL

INSERT INTO TB_Cronograma (IDContrato, DataFoto, IDTranche, Tipo, [DataBase], DataBaixa, DataEvento, Projetado, Realizado, TaxaCambio, TaxaVariante, Taxa, FoiRealizado, Status_cod, DtHrCadastro)
SELECT DISTINCT
	cc.IDContrato AS IDContrato, 
	CASE 
		WHEN TRY_CAST(SUBSTRING(cc.DataFoto,7,4) + '-' + SUBSTRING(cc.DataFoto,4,2) + '-' + SUBSTRING(cc.DataFoto,1,2) AS DATE) = '1900-01-01' THEN NULL 
		ELSE TRY_CAST(SUBSTRING(cc.DataFoto,7,4) + '-' + SUBSTRING(cc.DataFoto,4,2) + '-' + SUBSTRING(cc.DataFoto,1,2) AS DATE) END DataFoto, 
	ISNULL(TRY_CAST(IDTranche AS INT),0) as IDTranche, 
	ISNULL(TRY_CAST(cc.Tipo AS INT),0) as Tipo, 
	TRY_CAST(SUBSTRING(cc.[DataBase],7,4) + '-' + SUBSTRING(cc.[DataBase],4,2) + '-' + SUBSTRING(cc.[DataBase],1,2) AS DATE) [DataBase], 
	TRY_CAST(SUBSTRING(cc.DataBaixa,7,4) + '-' + SUBSTRING(cc.DataBaixa,4,2) + '-' + SUBSTRING(cc.DataBaixa,1,2) AS DATE)DataBaixa, 
	TRY_CAST(SUBSTRING(cc.DataEvento,7,4) + '-' + SUBSTRING(cc.DataEvento,4,2) + '-' + SUBSTRING(cc.DataEvento,1,2) AS DATE) DataEvento,
	TRY_CAST(REPLACE(cc.Projetado,',','.') AS NUMERIC(18,2)) AS Projetado, 
	TRY_CAST(REPLACE(cc.Realizado,',','.') AS NUMERIC(18,2)) AS Realizado, 
	TRY_CAST(REPLACE(cc.TaxaCambio,',','.') AS NUMERIC(18,2)) AS TaxaCambio,
	TRY_CAST(REPLACE(cc.TaxaVariante,',','.') AS NUMERIC(18,2)) AS TaxaVariante, 
	TRY_CAST(REPLACE(cc.Taxa,',','.') AS NUMERIC(18,2)) AS Taxa,
	ISNULL(TRY_CAST(cc.FoiRealizado AS INT),0), 
	1 Status_cod, 
 	GETDATE() DtHrCadastro
FROM Carga_Cronograma cc
ORDER BY 7 ASC

UPDATE TB_Cronograma SET IDFluxo = Cronograma_id

-- indices:
CREATE NONCLUSTERED INDEX [IX_TB_Cronograma_IDContrato_DataFoto_Includes]
ON [dbo].[TB_Cronograma] ([IDContrato],[DataFoto])
INCLUDE ([IDFluxo],[Tipo],[DataBase],[DataBaixa],[DataEvento],[Projetado],[Realizado],[TaxaCambio],[TaxaVariante],[Taxa],[FoiRealizado])
GO
