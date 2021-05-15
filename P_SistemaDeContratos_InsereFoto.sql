USE DB_Teste_01
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Vinicius Lima
-- Create date: 2021-05-14
-- Description:	Construção de uma stored procedure que apartir dos dados do arquivo 3 irá inserir novas fotos no modelo.
-- =============================================
CREATE PROCEDURE [dbo].[P_SistemaDeContratos_InsereFoto]
	 @IDContrato BIGINT	
	 , @DataFoto DATE
	 , @IDTranche INT
	 , @Tipo SMALLINT
	 , @DataBase DATE
	 , @DataBaixa DATE
	 , @DataEvento	DATE
	 , @Projetado NUMERIC (18,2)
	 , @Realizado NUMERIC (18,2)
	 , @TaxaCambio	NUMERIC (18,2)
	 , @TaxaVariante NUMERIC (18,2)
	 , @Taxa NUMERIC (18,2)
	 , @FoiRealizado BIT
AS
BEGIN TRY
	SET NOCOUNT ON;

	-- o que determina o fluxo são os campos IDContrato, IDTranche, Tipo e dataBase (pelo que entendi não podem haver duas linhas com esses mesmos campos)
	-- validação para nao inserir o mesmo cronograma duas vezes
	DECLARE @Retorno INT = 0

	IF ((SELECT COUNT(1) FROM TB_Cronograma tc WHERE tc.IDContrato = @IDContrato AND tc.IDTranche = @IDTranche AND tc.Tipo = @Tipo AND tc.[DataBase] = @DataBase) > 1)
	BEGIN
		-- Quando fluxos forem alterados uma coluna DataUltimoFluxo na tbContrato deve ser atualizada 
		-- contendo a DataBase do fluxo de maior DataBase deste contrato.

		INSERT INTO TB_Cronograma (IDContrato, DataFoto, IDTranche, Tipo, [DataBase], DataBaixa, DataEvento, Projetado, Realizado, TaxaCambio, TaxaVariante, Taxa, FoiRealizado, Status_cod, DtHrCadastro, DtHrInicio, DtHrFinal)
		VALUES (@IDContrato, @DataFoto, @IDTranche, @Tipo, @DataBase, @DataBaixa, @DataEvento, @Projetado, @Realizado, @TaxaCambio, @TaxaVariante, @Taxa, @FoiRealizado, DEFAULT, SYSDATETIME(), DEFAULT, DEFAULT);

		SET @Retorno = (SELECT SCOPE_IDENTITY())

		DECLARE @MaiorDataBase DATE
		SELECT TOP 1 @MaiorDataBase = MAX(tc.[DataBase]) FROM TB_Cronograma tc WHERE tc.IDContrato = @IDContrato

		UPDATE TB_Contratos SET DataUltimoFluxo = @MaiorDataBase WHERE IDContrato = @IDContrato

	END

	-- Não foi especificado a necessidade de um retorno em caso de sucesso, 
	-- mas por garantia deixei retornando 0 (em caso de falha / duplicidade) e o Id da tabela TB_Cronograma = IDFluxo em caso de sucesso
	SELECT @Retorno


END TRY
BEGIN CATCH
	THROW;
END CATCH
GO
