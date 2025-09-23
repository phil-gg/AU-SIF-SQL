WITH silver_visa AS (
SELECT a.[Code] AS [LocalId]
      ,COALESCE(a.[Name],'') AS [VisaSubClassCode]
      ,a.[Notes] AS [VisaSubClassName]
      ,a.[VisaType] AS [VisaTypeCode]
      ,b.[Name] AS [VisaTypeName]
      ,a.[InActive]
      ,ROW_NUMBER() OVER (ORDER BY a.[Seq] ASC, a.[Code] ASC, a.[Name] ASC) AS [DisplayOrder]
--    ,a.[fwCreated] -- Not needed for reference data; commented out
--    ,a.[fwCreatedBy] -- Not needed for reference data; commented out
--    ,a.[fwUpdated] -- Not needed for reference data; commented out
--    ,a.[fwUpdatedBy] -- Not needed for reference data; commented out
--    ,a.[SysType] -- All 'MTongue' going into a language-only target table; not needed and commented out
--    ,a.[Seq] -- Only useful as part of a formula for DisplayOrder; commented out
FROM [silver].[VisaSubClassNumber] AS a
LEFT JOIN [silver].[VisaType] AS b
ON a.[VisaType] = b.[Code]
WHERE LEFT(a.[Code],2) = 'VN'
)
INSERT INTO cdm_demo_gold.Dim1VisaSubClass (
       LocalId
      ,VisaSubClassCode
      ,VisaSubClassName
      ,VisaTypeCode
      ,VisaTypeName
      ,InActive
      ,DisplayOrder
)
SELECT LocalId
      ,VisaSubClassCode
      ,VisaSubClassName
      ,VisaTypeCode
      ,VisaTypeName
      ,InActive
      ,DisplayOrder
FROM silver_visa
;
