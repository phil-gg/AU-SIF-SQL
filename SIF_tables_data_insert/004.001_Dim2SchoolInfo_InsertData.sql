-- For anything not yet mapped from SourceSchoolinfo CTE, below, there is a choice:
-- Option 1 = alter Dim2SchoolInfo to have "ee_" fields to hold those fields at this level
-- Option 2 = find somewhere deeper in School SIF tree structure to map the field instead
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
), SourceSchoolInfo AS (
SELECT c.Code AS LocalId
      ,c.Name
      ,c.AccreditedName
      ,c.CRICOSName
      ,l.RefId AS LEAInfoRefId
      ,l.LocalId AS LEAInfoLocalId
      ,t.Name AS CampusTypeName
      ,c.Location
      ,c.ABN
      ,c.Currency
      ,c.ProviderCode
      ,c.ProviderName
--      ,c.TrainingAuthorityID -- all null commented out
--      ,c.AVET_TrainOrgID -- all null commented out
--      ,c.AVET_TrainOrgName -- all null commented out
--      ,c.AVET_TrainOrgShName -- all null commented out
--      ,c.AVET_AddFirstLine -- all null commented out
--      ,c.AVET_AddSecondLine -- all null commented out
--      ,c.AVET_SubTownLoc -- all null commented out
--      ,c.AVET_PCode -- all null commented out
--      ,c.AVET_ContName -- all null commented out
--      ,c.AVET_PhNum -- all null commented out
--      ,c.AVET_FaxNum -- all null commented out
--      ,c.AVET_EmailAdd -- all null commented out
--      ,c.AVET_TrainTypeID -- all null commented out
--      ,c.AVET_State -- all null commented out
--      ,c.AVET_TrainAuthorityID -- all null commented out
--      ,c.AVET_TrainAuthorityName -- all null commented out
--      ,c.AVET_AuthAddFirstLine -- all null commented out
--      ,c.AVET_AuthAddSecondLine -- all null commented out
--      ,c.AVET_AuthPCode -- all null commented out
--      ,c.AVET_AuthState -- all null commented out
--      ,c.AVET_AuthContactNAme -- all null commented out
--      ,c.AVET_AuthTelephone -- all null commented out
--      ,c.AVET_AuthFacsimile -- all null commented out
--      ,c.AVET_AuthEmail -- all null commented out
--      ,c.AVET_AuthSubTownLoc -- all null commented out
      ,CASE WHEN LEFT(c.notes,9)='Maze Code'
            THEN RIGHT(c.notes,4)
            ELSE NULL END AS MazeCode
--      ,c.SchoolNum -- duplicate of Code commented out
--      ,c.DateLastIncRan -- all null commented out
--      ,c.DateNextRunOK -- all null commented out
--      ,c.IncYearMonths -- all zero commented out
--      ,c.WSDLLocation -- all null commented out
--      ,c.CertificateName -- all null commented out
--      ,c.CanSubmitElec -- all zero commented out
      ,c.Gender AS GenderCode
      ,c.EstDate
      ,c.ClosedDate
--      ,c.DataCompliant -- all zero commented out
      ,c.ABNBranchNo
      ,c.NSN
      ,c.NCN
      ,c.StateEduID
      ,c.AdminArea as AdminAreaCode
      ,c.ServiceArea as ServiceAreaCode
--      ,c.AccreditedType -- all empty string commented out
      ,c.GeoArea as GeoAreaCode
      ,c.SiteSize
      ,c.RPropDesc
      ,c.MapRef
      ,c.ChurchAffiliation
      ,c.ChurchAuthority
      ,c.SchoolSystem
      ,c.ParishName
--      ,c.ApprovedAuth -- all empty string commented out
      ,c.MissionStatement
      ,c.VisionStatement
      ,c.Motto
      ,c.WebAddress
--      ,c.fwLockUser -- all null commented out
--      ,c.fwLockTime -- all null commented out
      ,c.fwCreatedBy AS CreatedBy
      ,CONVERT(datetime,c.fwCreated,127) AS CreatedAt
      ,c.fwUpdatedBy AS UpdatedBy
      ,CONVERT(datetime,c.fwUpdated,127) AS UpdatedAt
FROM [silver].[Campus] AS c
LEFT JOIN [silver].[CampusType] AS t
ON c.Type = t.Type
-- Only one LEA in BCE systems (with LocalId = 1) parent to all schools
LEFT JOIN [cdm_demo_gold].[Dim1LEAInfo] AS l
ON l.LocalId = 1
), SchoolInfo AS (
SELECT CONCAT( -- UuidV7Start plus 15 random hexadecimal characters
       (SELECT UuidV7Start from UuidTime), -- timestamp part of Uuidv7
       RIGHT( -- keep last 15 characters plus a hyphen
       CONVERT(uniqueidentifier, -- truncate first 128 bits of SHA hash into UUID string format
       HASHBYTES('SHA2_256', -- hash eMinerva primary key
       CONCAT( -- stick School Code and AccreditedName together
       RIGHT(REPLICATE('0', 3) + [LocalId], 3),'-', -- School Code then hyphen
       REPLACE(REPLACE([AccreditedName],'''',''),' ','_') -- AccreditedName with single quote removed and space to underscore
       ))), -- close concat hashbytes and convert functions
       16)) -- keep last 15 characters plus a hyphen then close right and original concat
       AS RefId
--      ,CONCAT( -- stick School Code and AccreditedName together
--       RIGHT(REPLICATE('0', 3) + [LocalId], 3),'-', -- School Code then hyphen
--       REPLACE(REPLACE([AccreditedName],'''',''),' ','_') -- AccreditedName with single quote removed and space to underscore
--       ) AS CombinedPKsToHash
      ,LocalId
--     TO-DO: StateProvinceId
--     TO-DO: CommonwealthId
--     TO-DO: ParentCommonwealthId
--     TO-DO: ACARAId
-- Could use Name rather than AccreditedName here:
      ,AccreditedName AS SchoolName
      ,LEAInfoRefId
      ,LEAInfoLocalId
--     TO-DO: OtherLEARefId
--     TO-DO: OtherLEALocalId
--     TO-DO: SchoolDistrict
--     TO-DO: SchoolDistrictLocalId
--     TO-DO: SchoolType
--     TO-DO: SchoolURL
--     TO-DO: PrincipalName_Title
--     TO-DO: PrincipalName_FamilyName
--     TO-DO: PrincipalName_GivenName
--     TO-DO: PrincipalName_MiddleName
--     TO-DO: PrincipalName_FamilyNameFirst
--     TO-DO: PrincipalName_PreferredFamilyName
--     TO-DO: PrincipalName_PreferredFamilyNameFirst
--     TO-DO: PrincipalName_PreferredGivenName
--     TO-DO: PrincipalName_Suffix
--     TO-DO: PrincipalName_FullName
      ,'LGL' AS PrincipalName_NameUsageTypeKey
--     TO-DO: PrincipalTitle
--     TO-DO: SessionType
--     TO-DO: ARIAScore
--     TO-DO: ARIAClass
--     TO-DO: OperationalStatus
--     TO-DO: FederalElectorate
-- All BCE schools are non-govt & independent = Y
      ,'NG' AS SchoolSector
      ,'Y' AS IndependentSchool
--     TO-DO: NonGovSystemicStatus
-- All BCE schools are 0001 Catholic school system
      ,'0001' AS SchoolSystem
-- All BCE schools are 2515 Catholic
      ,'2515' AS ReligiousAffiliation
--     TO-DO: SchoolGeographicLocation
--     TO-DO: LocalGovernmentArea
--     TO-DO: JurisdictionLowerHouse
--     TO-DO: SLA
--     TO-DO: SchoolCoEdStatus
--     TO-DO: BoardingSchoolStatus
--     TO-DO: TotalEnrolled_AllStudents
--     TO-DO: TotalEnrolled_Girls
--     TO-DO: TotalEnrolled_Boys
      ,EstDate AS Entity_Open
      ,ClosedDate AS Entity_Close
--     TO-DO: SchoolTimeZone
FROM SourceSchoolInfo
)
INSERT INTO cdm_demo_gold.Dim2SchoolInfo (
       RefId
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
)
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
FROM SchoolInfo
;