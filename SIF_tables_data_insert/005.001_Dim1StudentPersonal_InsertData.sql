-- For anything not yet mapped from nhStudent CTE, below, there is a choice:
-- Option 1 = alter Dim1StudentPersonal to have "ee_" fields to hold those fields at this level
-- Option 2 = find somewhere deeper in StudentPersonal SIF tree structure to map the field instead
WITH Time1 AS (
SELECT CURRENT_TIMESTAMP AS "CurrentTimestamp"
), Time2 AS (
SELECT CurrentTimestamp
      ,CONVERT(date, CurrentTimestamp) AS "CurrentDate"
      ,CONVERT(datetime,CONVERT(date, CurrentTimestamp),127) AS "StartTimestamp"
      ,DATEDIFF(day,'1970-01-01',CONVERT(date, CurrentTimestamp)) AS "UnixDays"
FROM Time1
), Time3 AS (
SELECT CurrentTimestamp
      ,CAST(UnixDays AS BIGINT) * CAST(86400000 AS BIGINT) AS "UnixDaysInMillisec"
      ,CAST(DATEDIFF(millisecond,StartTimestamp,CurrentTimestamp) AS BIGINT) AS "UnixMillisecToday"
FROM Time2
), HexTime AS (
SELECT CurrentTimestamp AS "time"
      ,UnixDaysInMillisec + UnixMillisecToday AS "dec"
      ,CONVERT(CHAR(12),CONVERT(BINARY (6), UnixDaysInMillisec + UnixMillisecToday), 2) AS "hex"
FROM Time3
), UuidTime AS (
SELECT "time"
      ,"dec"
      ,"hex"
      ,CONCAT(left(hex, 8),'-',right(hex, 4),'-7000-8') AS UuidV7Start
FROM HexTime
), nhStudent AS (
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
), StudentPersonal AS (
SELECT CONCAT( -- UuidV7Start plus 15 random hexadecimal characters
       (SELECT UuidV7Start from UuidTime), -- timestamp part of Uuidv7
       RIGHT( -- keep last 15 characters plus a hyphen
       CONVERT(uniqueidentifier, -- truncate first 128 bits of SHA hash into UUID string format
       HASHBYTES('SHA2_256', -- hash eMinerva primary key
       CONCAT( -- stick StaffId and EntityId together
       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[StudentNo]), 10), -- StaffId left pad with 0 to CHAR(10)
       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[EntityId]), 10) -- EntityId left pad with 0 to CHAR(10)
       ))), -- close concat hashbytes and convert functions
       16)) -- keep last 15 characters plus a hyphen then close right and original concat
       AS RefId
--      ,CONCAT( -- stick StaffId and EntityId together
--       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[StudentNo]), 10), -- StaffId left pad with 0 to CHAR(10)
--       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[EntityId]), 10) -- EntityId left pad with 0 to CHAR(10)
--       ) AS CombinedPKsToHash
      ,[EntityId] AS LocalId -- eMinerva EntityId mapped to SIF LocalId
      ,[StudentNo] AS StateProvinceId -- eMinerva StudentNo mapped to SIF StateProvinceId
      ,[UniqueStudentIdentifier] AS NationalUniqueStudentIdentifier
--     TO-DO: ProjectedGraduationYear
--     TO-DO: OnTimeGraduationYear
--     TO-DO: GraduationDate
--     TO-DO: AcceptableUsePolicy
--     TO-DO: GiftedTalented
--     TO-DO: EconomicDisadvantage
--     TO-DO: ESL
--     TO-DO: ESLDateAssessed
--     TO-DO: YoungCarersRole
--     TO-DO: Disability
--     TO-DO: CategoryOfDisability
--     TO-DO: IntegrationAide
--     TO-DO: EducationSupport
--     TO-DO: HomeSchooledStudent
--     TO-DO: IndependentStudent
--     TO-DO: Sensitive
--     TO-DO: OfflineDelivery
--     TO-DO: ESLSupport
--     TO-DO: PrePrimaryEducation
--     TO-DO: PrePrimaryEducationHours
--     TO-DO: FirstAUSchoolEnrollment
FROM nhStudent
)
INSERT INTO cdm_demo_gold.Dim1StudentPersonal (
       RefId
      ,LocalId
      ,StateProvinceId
      ,NationalUniqueStudentIdentifier
)
SELECT RefId
      ,LocalId
      ,StateProvinceId
      ,NationalUniqueStudentIdentifier
FROM StudentPersonal
;
