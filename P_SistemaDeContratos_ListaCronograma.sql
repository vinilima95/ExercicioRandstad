USE DB_Teste_01
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		VINICIUS LIMA
-- Create date: 2021-05-04
-- Description:	Construção de uma stored procedure que receberá como parâmetro @IDContrato e @DataFoto, 
-- e deve retornar o cronograma do contrato na data foto. Formato de saída abaixo:

/*

CREATE NONCLUSTERED INDEX [IX_TB_Cronograma_IDContrato_DataFoto_Includes]
ON [dbo].[TB_Cronograma] ([IDContrato],[DataFoto])
INCLUDE ([IDFluxo],[Tipo],[DataBase],[DataBaixa],[DataEvento],[Projetado],[Realizado],[TaxaCambio],[TaxaVariante],[Taxa],[FoiRealizado])
GO

*/

-- =============================================
CREATE PROCEDURE [dbo].[P_SistemaDeContratos_ListaCronograma]
	@IDContrato INT,
	@DataFoto DATE
AS
BEGIN TRY
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT DISTINCT
		tc.IDContrato, 
		tc1.IDFluxo, 
		tc1.Tipo, 
		tc1.[DataBase], 
		tc1.DataBaixa,
		tc1.DataEvento,
		tc1.FoiRealizado,
		tc1.Projetado,
		tc1.Realizado,
		tc1.TaxaCambio,
		tc1.TaxaVariante,
		tc1.Taxa
	FROM TB_Contratos tc
	INNER JOIN TB_Cronograma tc1 ON tc.IDContrato = tc1.IDContrato
	WHERE tc.IDContrato = @IDContrato
	AND tc1.DataFoto = @DataFoto

END TRY
BEGIN CATCH
	THROW;
END CATCH
GO
