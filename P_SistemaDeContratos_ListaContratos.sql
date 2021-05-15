USE DB_Teste_01
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vinicius Lima
-- Create date: 2021-05-14
-- Description: Construção de uma stored procedure que retorne na primeira coluna o Nome do contrato, 
-- na segunda coluna o indexador em ordem crescente e na terceira coluna o indexador em ordem decrescente.

-- =============================================
CREATE PROCEDURE [dbo].[P_SistemaDeContratos_ListaContratos]
AS
BEGIN TRY
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	SELECT DISTINCT tc.NomeContrato, ISNULL(ti.Indexador,'NÃO ESPECIFICADO') AS IndexadorASC, ISNULL(ti.Indexador,'NÃO ESPECIFICADO') IndexadorDESC
	FROM TB_Contratos tc
	INNER JOIN TB_Cronograma tc1 ON tc.IDContrato = tc1.IDContrato
	LEFT JOIN TB_Indexador ti ON tc.Indexador_id = ti.Indexador_id
	ORDER BY 2 ASC, 3 DESC
	
END TRY
BEGIN CATCH
	THROW
END CATCH
GO
