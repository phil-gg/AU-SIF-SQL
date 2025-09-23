SELECT [Code] as [LocalId]
      ,[NatCode]
      ,[InActive]
      ,[Name] AS [LanguageName]
      ,COALESCE([Notes],'') AS [LanguageRecordComment]
      ,ROW_NUMBER() OVER (ORDER BY [Seq] ASC, [Code] ASC) AS [DisplayOrder]
--    ,[fwCreated] -- Not needed for reference data; commented out
--    ,[fwCreatedBy] -- Not needed for reference data; commented out
--    ,[fwUpdated] -- Not needed for reference data; commented out
--    ,[fwUpdatedBy] -- Not needed for reference data; commented out
--    ,[SysType] -- All 'MTongue' going into a language-only target table; not needed and commented out
--    ,[Seq] -- Only useful as part of a formula for DisplayOrder; commented out
FROM [silver].[MTongue]
;
