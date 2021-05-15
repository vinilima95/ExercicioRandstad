USE DB_Teste_01
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vinicius Lima
-- Create date: 2021-05-15
-- Description: Crie um script que remova dos xmls a nova tag criada.

-- =============================================
CREATE PROCEDURE [dbo].[P_SistemaDeContratos_AlteraXMLContrato_RemoveTAG]
AS
BEGIN TRY
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DROP TABLE IF EXISTS #Processamento
	SELECT DISTINCT tc.IDContrato
	INTO #Processamento
	FROM TB_Contratos_XML tc

	WHILE ((SELECT COUNT(1) FROM #Processamento p) > 0)
	BEGIN
		DECLARE @IDContrato INT = 0
		DECLARE @CalendarName VARCHAR (255) = ''

		SELECT TOP 1 @IDContrato = p.IDContrato FROM #Processamento p

		DECLARE @XML XML = (SELECT TOP 1 tcx.Contrato_XML FROM TB_Contratos_XML tcx WHERE tcx.IDContrato = @IDContrato)

		SET @XML.modify(
			'delete 
			(
				(/contract/tipoinstrumento/@calendarname)[1]
			)')

		UPDATE TB_Contratos_XML SET Contrato_XML = CAST(@XML AS VARCHAR(MAX)), DtHrCadastro = GETDATE() WHERE IDContrato = @IDContrato

		DELETE FROM #Processamento WHERE IDContrato = @IDContrato

	END

	SELECT TOP 1 tcx.IDContrato, CAST(tcx.Contrato_XML AS XML) AS Contrato_XML, tcx.DtHrCadastro FROM TB_Contratos_XML tcx
	
END TRY
BEGIN CATCH
	THROW
END CATCH
GO
