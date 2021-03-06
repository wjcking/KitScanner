USE [CNE1133]
GO
/****** Object:  Trigger [dbo].[tr_verify_giftorderpoint]    Script Date: 08/21/2012 14:07:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[tr_verify_giftorderpoint]
   ON [dbo].[GiftOrder]
   Instead of insert
AS 
BEGIN
	 DECLARE @UserPoint INT 
	 DECLARE @OrderedPoint INT  
	 DECLARE @currentOrderPoint INT 
	 DECLARE @UserID nvarchar(20) 
	 SET @UserID = (SELECT UserID FROM inserted)
	 
	 SELECT TOP 1 @UserPoint = Point FROM CNE1133.users	  WHERE UserID = @UserID
	 SELECT @OrderedPoint = 
	 (SELECT Isnull(SUM(POINT),0) FROM dbo.GiftOrder WHERE UserID = @UserID AND [Status] <> 3)
	   +
	 (SELECT Isnull(SUM(g.POINT),0) FROM dbo.GiftScannerOrder gso 
	 LEFT JOIN dbo.Gift g ON g.Number = gso.Number 
	  WHERE gso.UserID = @UserID AND gso.[Status] = 1 )
	 
	 SELECT @currentOrderPoint = POINT FROM inserted
	 
	 --PRINT @UserID 
	 --print @UserPoint
	 --PRINT @OrderedPoint
	 --PRINT @currentOrderPoint
	 -- 大于或等于，小于则不insert
	 IF (@UserPoint >= (@OrderedPoint + @currentOrderPoint))
	 BEGIN
	 
		INSERT INTO [CNE1133].[dbo].[GiftOrder]
			   ([UserID]
			   ,[GiftID]
			   ,[CategoryID]
			   ,[Cellphone]
			   ,[OrderCount]
			   ,[Point]
			   ,[OrderTime]
			   ,[Status]
			   ,[UpdateTime]
			   ,[PayStatus])
		SELECT  [UserID]
			   ,[GiftID]
			   ,[CategoryID]
			   ,[Cellphone]
			   ,[OrderCount]
			   ,[Point]
			   ,[OrderTime]
			   ,[Status]
			   ,[UpdateTime]
			   ,[PayStatus]
		FROM INSERTED
	END

END
