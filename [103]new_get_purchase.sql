DECLARE @CityInfo table(CityID int,CityName nvarchar(50),CityCode nvarchar(10))
DECLARE @ShopInfo table(ShopID int,ShopName nvarchar(50),CityCode nvarchar(10))

INSERT INTO @CityInfo
	select ans_cityCode,ans_Description,ans_NextQ from answer a WHERE a.ans_qus_code like 'NBV-CITY%'

INSERT INTO @ShopInfo
	SELECT a.ans_code1,a.ans_description,b.ans_qus_code from answer a 
	INNER JOIN (select * from answer a INNER JOIN @CityInfo c on c.CityCode collate Chinese_PRC_CI_AS = a.ans_qus_code ) b on b.ans_NextQ = a.ans_qus_code
	WHERE a.ans_isdeleted = 0  or a.ans_code1 in ('3900000','4300000','4000000')

SELECT 
       [Pur_Category]
      ,[pur_Panelistnum]
      ,convert(VARCHAR(10), [Pur_PurchaseDate],20) as Pur_PurchaseDate 
      ,(SELECT TOP 1 '2011P'+ + convert(VARCHAR(3),cal_Period) + 'W' + convert(VARCHAR(3),cal_week) FROM [DataEntry].[dbo].[Calendar] where cal_year = 2011 and [Cal_StartDate] <= Pur_PurchaseDate and [Cal_EndDate] >= Pur_PurchaseDate) as Period
      ,[Pur_Units]
      ,[Pur_Price]
      ,[Pur_OtherAttribute]
      ,[Pur_DE_Id]
      ,[Pur_Item_Code]
      ,[Pur_Barcode]
      ,[Pur_attribute_string]
      ,[Pur_ProductName]
      ,ci.cityname
      ,si.shopname
      ,m.[M_Description]
  FROM [DataEntry].[dbo].[gp_test_purchase]
  LEFT JOIN @CityInfo ci on ci.cityid = [pur_Panelistnum]/100000
  LEFT JOIN @ShopInfo si on si.shopid = pur_shop
  LEFT JOIN [Manufacture] m on m.M_Stem collate Chinese_PRC_CI_AS = case substring(pur_barcode,0,4)
         WHEN '690' THEN substring(pur_barcode,0,8)
         WHEN '691' THEN substring(pur_barcode,0,8)
         WHEN '692' THEN substring(pur_barcode,0,9)
         WHEN '693' THEN substring(pur_barcode,0,9)
         WHEN '694' THEN substring(pur_barcode,0,9)
         WHEN '695' THEN substring(pur_barcode,0,9)
         ELSE pur_barcode end
  WHERE isnull(ustatus,0)= 1
  and pstatus = 5
  and ci.citycode = si.citycode
  and len(pur_Panelistnum) = 8
  ORDER BY Pur_Category