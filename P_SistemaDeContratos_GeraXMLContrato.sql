USE DB_Teste_01
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vinicius Lima
-- Create date: 2021-05-14
-- Description: Criar uma consulta que retorne para cada contrato um xml com os atributos seguindo o schema abaixo 
-- e insira em uma nova tabela contendo duas colunas: IDContrato, xmlgerado

-- =============================================
CREATE PROCEDURE [dbo].[P_SistemaDeContratos_GeraXMLContrato]
AS
BEGIN TRY
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DROP TABLE IF EXISTS #Processamento
	SELECT DISTINCT tc.IDContrato
	INTO #Processamento
	FROM TB_Contratos tc

	TRUNCATE TABLE TB_Contratos_XML

	WHILE ((SELECT COUNT(1) FROM #Processamento p) > 0)
	BEGIN
		DECLARE @IDContrato INT = 0

		SELECT TOP 1 @IDContrato = IDContrato FROM #Processamento

		DROP TABLE IF EXISTS #Contract
		SELECT TOP 1 
			tc.IDContrato, 
			tc.Emissao, 
			ISNULL(tc1.Calendario,'') AS Calendario, 
			ISNULL(tb1.Basis,'') AS Basis,
			ISNULL(ti.Indexador,'NÃO ESPECIFICADO') AS Indexador, 
			ISNULL(tm.Moeda,'NÃO ESPECIFICADO') Moeda,
			tc.SeriePreco
		INTO #Contract
		FROM TB_Contratos tc
		LEFT JOIN TB_Calendario tc1 ON tc.Calendario_id = tc1.Calendario_id
		LEFT JOIN TB_Basis tb1 ON tc.Basis_id = tb1.Basis_id
		LEFT JOIN TB_Moedas tm ON tc.Moeda_id = tm.Moeda_id
		LEFT JOIN TB_Indexador ti ON tc.Indexador_id = ti.Indexador_id
		WHERE tc.IDContrato = @IDContrato

		DROP TABLE IF EXISTS #TipoInstrumento
		CREATE TABLE #TipoInstrumento (IDContrato INT, Emissao VARCHAR (255), Calendario VARCHAR (255), Basis VARCHAR (255))
		INSERT INTO #TipoInstrumento (IDContrato, Emissao, Calendario, Basis)
		SELECT DISTINCT IDContrato, Emissao, Calendario, Basis FROM #Contract

		DROP TABLE IF EXISTS #currency
		CREATE TABLE #currency (IDContrato INT, Indexador VARCHAR (255), Moeda VARCHAR (255))
		INSERT INTO #currency (IDContrato, Indexador, Moeda)
		SELECT DISTINCT tc.IDContrato, tc.Indexador, tc.Moeda FROM #Contract tc

		DROP TABLE IF EXISTS #series
		CREATE TABLE #series (IDContrato INT, SeriePreco VARCHAR (255))
		INSERT INTO #series (IDContrato, SeriePreco)
		SELECT DISTINCT c.IDContrato, c.SeriePreco FROM #Contract c 

		DECLARE @Arquivo VARCHAR (MAX) = (
		SELECT DISTINCT 
			TipoInstrumento.Emissao AS issuedate, 
			TipoInstrumento.Calendario AS calendar, 
			TipoInstrumento.Basis AS basis, 
			currency.Indexador AS [Index], 
			currency.Moeda AS currency, 
			series.SeriePreco AS priceseries
		FROM #Contract AS Contratc
		INNER JOIN #TipoInstrumento AS tipoinstrumento ON Contratc.IDContrato = TipoInstrumento.IDContrato
		INNER JOIN #currency AS currency ON Contratc.IDContrato = currency.IDContrato
		INNER JOIN #series AS series ON Contratc.IDContrato = series.IDContrato
		FOR XML AUTO, ROOT ('contract'))

		INSERT INTO TB_Contratos_XML (IDContrato, Contrato_XML, DtHrCadastro)
		VALUES (@IDContrato, @Arquivo, DEFAULT);

		DELETE FROM #Processamento WHERE IDContrato = @IDContrato
	END

	SELECT TOP 1 tcx.IDContrato, CAST(tcx.Contrato_XML AS XML) AS Contrato_XML, tcx.DtHrCadastro FROM TB_Contratos_XML tcx

END TRY
BEGIN CATCH
	THROW
END CATCH
GO
