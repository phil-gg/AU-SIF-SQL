--WITH nhStudent AS (
-- Five (5) different IDs in source for students as follows
SELECT [EntityID]
      ,[StudentNo]
--      ,RIGHT([AltStudentNo],LEN([StudentNo])) AS TruncatedAltStudentNo -- AltStudentNo is always StudentNo prefixed with 's00' commented out
      ,[Login]
      ,CASE WHEN LEN([StudentIdentifier1]) = 0 THEN NULL
	        ELSE [StudentIdentifier1] END AS [StudentIdentifier1]
      ,CASE WHEN LEN([UniqueStudentIdentifier]) = 0 THEN NULL
	        ELSE [UniqueStudentIdentifier] END AS [UniqueStudentIdentifier]
      ,CASE WHEN LEN([USIType]) = 0 THEN NULL
	        ELSE [USIType] END AS [USIType]
      ,CASE WHEN LEN([USIStatus]) = 0 THEN NULL
	        ELSE [USIStatus] END AS [USIStatus]
--      ,[PotentialStudentNo] -- all null commented out
--      ,[NSN] -- all null commented out
--      ,[StudStatus] -- all null commented out
--      ,[School] -- needed for the enrolment fact not StudentPersonal commented out
--      ,[FamilyRep] -- all zero or null commented out
--      ,[MarketingSource] -- all null commented out
      ,[International]
      ,CASE WHEN LEN([HCNo]) = 0 THEN NULL
	        ELSE [HCNo] END AS [HCNo]
      ,CASE WHEN LEN([HCExDate]) = 0 THEN NULL
	        ELSE [HCExDate] END AS [HCExDate]
      ,[IndigStatusId] AS IndigenousStatusCode
--      ,[PacificLLI] -- all null commented out
--      ,[MaoriLLI] -- all null commented out
--      ,[StartSchoolDate] -- all null commented out
--      ,[Alumni] -- all zero or null commented out
      ,[HomeRoom] -- all null commented out
      ,[House] AS HouseCode
      ,[YearLevel]
--      ,[FundType] -- all null commented out
--      ,[ZoneStatus] -- all null commented out
--      ,[ORRS] -- all null commented out
--      ,[LeavingDate] -- all null commented out
--      ,[LeavingReason] -- all null commented out
--      ,[ScholasticYear] -- all null commented out
--      ,[Year12] -- all null commented out
--      ,[Year12StudentNo] -- all null commented out
--      ,[Year12Year] -- all zero or null commented out
--      ,[Year12School] -- all null commented out
--      ,[Year12State] -- all null commented out
--      ,[TEScore] -- all zero or null commented out
--      ,[ECE] -- all null commented out
--      ,[SecQual] -- all null commented out
--      ,[NonNQFQual] -- all null commented out
--      ,[UE] -- all zero or null commented out
--      ,[NewSchoolNum] -- all null commented out
--      ,[StudentSpare1] -- all null commented out
--      ,[StudentSpare2] -- all null commented out
--      ,[StudentSpare3] -- all null commented out
--      ,[StudentSpare4] -- all null commented out
--      ,[StudentSpare5] -- all null commented out
--      ,[GCCStatus] -- all null commented out
--      ,[GCCExpiryDate] -- all null commented out
      ,[IsIndependent]
      ,[IndependentStatusDate]
--      ,[IndependentStatus] -- all empty string or null commented out
--      ,[SightingEvidenceDate] -- all null commented out
      ,CASE WHEN LEN([PreviousSchool]) = 0 THEN NULL
	        ELSE [PreviousSchool] END AS [PreviousSchool]
      ,CASE WHEN LEN([RegionalStudentNumber]) = 0 THEN NULL
	        ELSE [RegionalStudentNumber] END AS [RegionalStudentNumber]
--      ,[MainSchool] -- only one student with MainSchool 312 everyone else null commented out
--      ,[FeeAssisted] -- all zero or null commented out
      ,[InternationalStudentType] -- all empty string or null commented out
      ,[FinancialAssistance] -- all zero commented out
--      ,[LibraryCardNo] -- all empty string or null commented out
      ,[LocalResident]
      ,[ApplicantClassification] AS ApplicantClassificationCode
--      ,[ESLSupport] -- all zero commented out
      ,[LastVerified]
      ,[ChangeStart]
--      ,[ChangeEnd] -- all 9999-12-31 commented out
      ,[fwCreatedBy] AS CreatedBy
      ,CONVERT(datetime,[fwCreated],127) AS CreatedAt
      ,[fwUpdatedBy] AS UpdatedBy
      ,CONVERT(datetime,[fwUpdated],127) AS UpdatedAt
FROM [silver].[nhStudent]
;