-- There is no LEA data from eMinerva in Bronze or Silver
-- Therefore, there is no equivalent Select Only script, for this file
-- However, all schools need a parent LEA record
-- This is a single LEA entry suitable for all schools in QLD
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
), LEAInfo AS (
SELECT CONCAT( -- UuidV7Start plus 15 random hexadecimal characters
       (SELECT UuidV7Start from UuidTime), -- timestamp part of Uuidv7
       RIGHT( -- keep last 15 characters plus a hyphen
       CONVERT(uniqueidentifier, -- truncate first 128 bits of SHA hash into UUID string format
       HASHBYTES('SHA2_256', -- hash eMinerva primary key
       RIGHT(REPLICATE('0', 10) + 1, 10)--, -- Assigned unique LocalId of 1, left pad with 0 to CHAR(10)
       )), -- close concat hashbytes and convert functions
       16)) -- keep last 15 characters plus a hyphen then close right and original concat
       AS RefId
      ,1 AS LocalId
      ,'Queensland Department of Education' AS LEAName
      ,'https://qed.qld.gov.au' AS LEAURL
      ,'01' AS EducationAgencyType
)
INSERT INTO cdm_demo_gold.Dim1LEAInfo (
       RefId
      ,LocalId
      ,LEAName
      ,LEAURL
      ,EducationAgencyType
)
SELECT RefId
      ,LocalId
      ,LEAName
      ,LEAURL
      ,EducationAgencyType
FROM LEAInfo
;