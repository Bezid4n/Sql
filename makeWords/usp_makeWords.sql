/*
یک 
SP
بنویسید که تعدادی حرف را دریافت کند
exec pRoject_SP 'ش،ک،م،ت'
پس از آن تمام کلمات معنا دار با همان تعداد و کمتر را در قالب یک جدول نمایش دهد


تفکیک حروف
تشکیل تمام کلمات مرتبط
پیدا کردن یک دیکشنری فارسی
تطابق کلمات مرتبط با کلمات دیکشنری فارسی

*/
CREATE OR ALTER PROC usp_makeWords (@letters NVARCHAR(100))
AS 
BEGIN
	/*
		Author: Behzad Danesh
		Date: 1403/02/14
		Subject: This sp make words by letters that user entered.
		Sample Call: Exec usp_makeWords N'ش,ف,ب,ا,ر'
	*/
	SET NOCOUNT ON

	BEGIN TRY
		BEGIN TRAN
			
			DECLARE @countLetters INT
				   ,@i INT=1

			DROP TABLE IF EXISTS #concatTemp

			SELECT @countLetters=COUNT(*)
			FROM STRING_SPLIT(@letters,',');

			SELECT *
				   ,cast(ROW_NUMBER() OVER (ORDER BY VALUE)as nvarchar(20)) AS rowNum
			INTO #concatTemp
			FROM STRING_SPLIT(@letters,',')

			WHILE @i<@countLetters
				BEGIN
					INSERT INTO #concatTemp 
					SELECT CONCAT(C1.[value],C2.[value]) AS concatVal
						  ,CONCAT(c1.rowNum,c2.rowNum) AS concatRow
					FROM #concatTemp c1
					LEFT JOIN #concatTemp c2 ON (SELECT CHARINDEX(c1.rowNum,c2.rowNum))=0
					WHERE C1.rowNum <=@countLetters	
			
					SET @i+=1
				END		
				
			SELECT  T.[value]
				   ,P.[Desc]
			FROM #concatTemp T
			LEFT JOIN PersianDic P ON P.Title=T.[value]
			WHERE P.Title IS NOT NULL
			GROUP BY T.[value]
					,P.[Desc]
			ORDER BY LEN(T.[value])

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR ('خطا رخ داده',16,1)
	END CATCH
END