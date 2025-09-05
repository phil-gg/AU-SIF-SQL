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
), dbo_Staff AS (
SELECT [StaffId] -- alphanumeric primary key
      ,CONVERT(BIGINT,[EntityId]) AS EntityId -- numeric eMinerva primary key
--    ,[Qualification1] -- all NULL commented out
--    ,[Qualification2] -- all NULL commented out
      ,CONVERT(datetime,CONVERT(date,[StartDate]),127) AS StartDate -- StaffId valid from date
      ,CONVERT(BIT,[Active]) AS Active -- Active Boolean flag
--    ,[Notes] -- all NULL commented out
      ,CONVERT(DECIMAL(4,3),[FTE]) AS FTE -- DATA QUALITY WARNING - all 1.0 which can't be true
--    ,[MainDepartment] -- all NULL commented out
--    ,[StaffType] -- all NULL commented out
--    ,[RegistrationCategory] -- all NULL commented out
--    ,[RegistrationExpiryDate] -- all NULL commented out
--    ,[RegistrationNumber] -- all NULL commented out
      ,[fwCreatedBy] AS CreatedBy
      ,CONVERT(datetime,[fwCreated],127) AS CreatedAt
      ,[fwUpdatedBy] AS UpdatedBy
      ,CONVERT(datetime,[fwUpdated],127) AS UpdatedAt
FROM [silver].[Staff]
)--, StaffPersonal AS (
SELECT CONCAT( -- UuidV7Start plus 15 random hexadecimal characters
       (SELECT UuidV7Start from UuidTime), -- timestamp part of Uuidv7
       RIGHT( -- keep last 15 characters plus a hyphen
       CONVERT(uniqueidentifier, -- truncate first 128 bits of SHA hash into UUID string format
       HASHBYTES('SHA2_256', -- hash eMinerva primary key
       CONCAT( -- stick StaffId and EntityId together
       RIGHT(REPLICATE('0', 10) + [StaffId], 10), -- StaffId left pad with 0 to CHAR(10)
       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[EntityId]), 10) -- EntityId left pad with 0 to CHAR(10)
       ))), -- close concat hashbytes and convert functions
       16)) -- keep last 15 characters plus a hyphen then close right and original concat
       AS RefId
      ,CONCAT( -- stick StaffId and EntityId together
       RIGHT(REPLICATE('0', 10) + [StaffId], 10), -- StaffId left pad with 0 to CHAR(10)
       RIGHT(REPLICATE('0', 10) + CONVERT(VARCHAR(10),[EntityId]), 10) -- EntityId left pad with 0 to CHAR(10)
       ) AS CombinedPKsToHash
      ,[EntityId] AS LocalId -- eMinerva EntityId mapped to SIF LocalId
--     TO-DO: StateProvinceId
--     TO-DO: PersonInfo
--     TO-DO: Title
--     TO-DO: EmploymentStatus
--     TO-DO: MostRecent_SchoolLocalId
--     TO-DO: MostRecent_SchoolACARAId
--     TO-DO: MostRecent_LocalCampusId
--     TO-DO: MostRecent_HomeGroup
      ,StartDate AS ee_StartDate -- StaffId valid from date
      ,Active AS ee_Active -- Active Boolean flag
      ,FTE AS ee_FTE -- DATA QUALITY WARNING - all 1.0 which can't be true
      ,CreatedBy AS ee_CreatedBy
      ,CreatedAt AS ee_CreatedAt
      ,UpdatedBy AS ee_UpdatedBy
      ,UpdatedAt AS ee_UpdatedAt
FROM dbo_Staff