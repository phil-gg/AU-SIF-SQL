-- This initial Student Enrolment fact is mapped from nhStudent rather than Enrolment tables in silver
-- BCE analysis will be required to determine whether this is an appropriate mapping
-- Note that circa 55000 nhStudent table rows have no associated school recorded
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
SELECT [EntityID]
      ,[School]
FROM [silver].[nhStudent]
), StudentPersonal AS (
SELECT RefId
      ,LocalId
      ,StateProvinceId
      ,NationalUniqueStudentIdentifier
FROM cdm_demo_gold.Dim1StudentPersonal
), SchoolInfo AS (
SELECT RefId
      ,LocalId
      ,SchoolName
      ,LEAInfoRefId	
      ,LEAInfoLocalId
      ,PrincipalName_NameUsageTypeKey
      ,SchoolSector
      ,IndependentSchool
      ,SchoolSystem
      ,ReligiousAffiliation
      ,Entity_Open
      ,Entity_Close
FROM cdm_demo_gold.Dim2SchoolInfo
), JoinSchoolInfoStudentPersonal AS (
SELECT p.RefId AS StudentRefId
      ,p.LocalId AS StudentLocalId
      ,p.StateProvinceId
      ,p.NationalUniqueStudentIdentifier
      ,i.RefId AS SchoolInfoRefId
      ,i.LocalId AS SchoolInfoLocalId
      ,i.SchoolName
      ,i.LEAInfoRefId	
      ,i.LEAInfoLocalId
      ,i.PrincipalName_NameUsageTypeKey
      ,i.SchoolSector
      ,i.IndependentSchool
      ,i.SchoolSystem
      ,i.ReligiousAffiliation
      ,i.Entity_Open
      ,i.Entity_Close
FROM nhStudent AS n
INNER JOIN StudentPersonal AS p
ON n.EntityID = p.LocalId
-- Circa 55000 extra nhStudent records with no associated school recorded added by switching this to left join
INNER JOIN SchoolInfo AS i
ON n.School = i.LocalId
), StudentSchoolEnrollment AS (
SELECT CONCAT( -- UuidV7Start plus 15 random hexadecimal characters
       (SELECT UuidV7Start from UuidTime), -- timestamp part of Uuidv7
       RIGHT( -- keep last 15 characters plus a hyphen
       CONVERT(uniqueidentifier, -- truncate first 128 bits of SHA hash into UUID string format
       HASHBYTES('SHA2_256', -- hash eMinerva primary key
       CONCAT( -- stick StaffId and EntityId together
       RIGHT(REPLICATE('0', 3) + [SchoolInfoLocalId], 3),'-', -- School Code then hyphen
       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[StudentLocalId]), 10) -- StudentId left pad with 0 to CHAR(10)
       ))), -- close concat hashbytes and convert functions
       16)) -- keep last 15 characters plus a hyphen then close right and original concat
       AS RefId
--      ,CONCAT( -- stick StaffId and EntityId together
--       RIGHT(REPLICATE('0', 3) + [SchoolInfoLocalId], 3),'-', -- School Code then hyphen
--       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[StudentLocalId]), 10) -- StudentId left pad with 0 to CHAR(10)
--       ) AS CombinedPKsToHash
      ,[StudentLocalId] AS LocalId -- placeholder for now (replace with an enrolment primary key value)
      ,StudentRefId
      ,StudentLocalId
      ,SchoolInfoRefId
      ,SchoolInfoLocalId
-- Set membership type for all records to 01 / home school for now (as only have one home entry per student from nhStudent table)
      ,'01' AS MembershipType
-- Set membership type for all records to C / current for now (as only have one (presumably) current entry per student from nhStudent table)
      ,'C' AS TimeFrame
-- Set SchoolYear to current year (as only have one (presumably) current entry per student from nhStudent table)
      ,CONVERT(SMALLINT,YEAR(GETDATE())) AS SchoolYear
--     TO-DO: IntendedEntryDate
-- Set EntryDate to current load timestamp for now (placeholder value)
      ,(SELECT [time] from UuidTime) AS EntryDate
--     TO-DO: EntryCode
--     TO-DO: YearLevel
--     TO-DO: HomeroomRefId
--     TO-DO: HomeroomLocalId
--     TO-DO: AdvisorRefId
--     TO-DO: AdvisorLocalId
--     TO-DO: CounselorRefId
--     TO-DO: CounselorLocalId
--     TO-DO: Homegroup
--     TO-DO: ACARASchoolId
--     TO-DO: ClassCode
--     TO-DO: TestLevel
--     TO-DO: ReportingSchool
--     TO-DO: House
--     TO-DO: CalendarRefId
--     TO-DO: CalendarLocalId
--     TO-DO: IndividualLearningPlan
--     TO-DO: ExitDate
--     TO-DO: ExitCode
--     TO-DO: ExitStatus
--     TO-DO: FTE
--     TO-DO: FTPTStatus
--     TO-DO: FFPOS
--     TO-DO: CatchmentStatusCode
--     TO-DO: RecordClosureReason
--     TO-DO: PromotionInfo
--     TO-DO: PreviousSchool
--     TO-DO: PreviousSchoolName
--     TO-DO: DestinationSchool
--     TO-DO: DestinationSchoolName
--     TO-DO: StartedAtSchoolDate
--     TO-DO: DisabilityLevelOfAdjustment
--     TO-DO: DisabilityCategory
--     TO-DO: CensusAge
--     TO-DO: DistanceEducationStudent
--     TO-DO: BoardingStatus
--     TO-DO: InternationalStudent
--     TO-DO: ToSchool_TravelMode
--     TO-DO: ToSchool_TravelDetails
--     TO-DO: ToSchool_TravelAccompaniment
--     TO-DO: FromSchool_TravelMode
--     TO-DO: FromSchool_TravelDetails
--     TO-DO: FromSchool_TravelAccompaniment
FROM JoinSchoolInfoStudentPersonal
)
INSERT INTO cdm_demo_gold.Fact3StudentSchoolEnrollment (
       RefId
      ,LocalId
      ,StudentRefId
      ,StudentLocalId
      ,SchoolInfoRefId
      ,SchoolInfoLocalId
      ,MembershipType
      ,TimeFrame
      ,SchoolYear
      ,EntryDate
)
SELECT RefId
      ,LocalId
      ,StudentRefId
      ,StudentLocalId
      ,SchoolInfoRefId
      ,SchoolInfoLocalId
      ,MembershipType
      ,TimeFrame
      ,SchoolYear
      ,EntryDate
FROM StudentSchoolEnrollment
;
