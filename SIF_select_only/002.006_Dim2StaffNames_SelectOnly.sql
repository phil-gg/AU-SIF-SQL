-- This CTE is general cleaning for nhPerson as a whole
WITH nhPerson AS (
SELECT CONVERT(int,[EntityId]) AS EntityId -- numeric eMinerva primary key
      ,CONVERT(bit,[isStudent]) AS isStudent
      ,CONVERT(bit,[isAcStaff]) AS isAcStaff
      ,CONVERT(bit,[InterpreterRequired]) AS InterpreterRequired
      ,case when LEFT([Title],2) <> 'TL' then NULL
            else TRIM([Title])
            end as TitleCode
      ,case when TRIM([FamName]) = '' then NULL
            else TRIM([FamName])
            end as FamName
      ,case when TRIM([FirstName]) = '' then NULL
            else TRIM([FirstName])
            end as FirstName
      ,case when [SecName] = CHAR(96) then NULL
            when TRIM([SecName]) = '' then NULL
            else TRIM([SecName])
            end as SecName
      ,case when TRIM([PrefName]) = '' then NULL
            else TRIM([PrefName])
            end as PrefName
      ,case when TRIM([PrefFamName]) = '' then NULL
            else TRIM([PrefFamName])
            end as PrefFamName
--    ,[PrevNames] -- all null commented out
      ,case when CONVERT(date,[DOB]) = DATEFROMPARTS(1900,1,1) then NULL
            else CONVERT(date,[DOB])
            end as DOB
      ,case when [Gender] = '.' then NULL
            else [Gender]
            end as Gender
      ,case when LEFT([Religion],2) <> 'RC' then NULL
            else TRIM([Religion])
            end as ReligionCode
--    ,[TFN] -- all null commented out
--    ,[Nationality] -- all null commented out
--    ,[Citizenship] -- all null commented out
      ,case when TRIM([CitizenCountry]) = '' then NULL
            else TRIM([CitizenCountry])
            end as CitizenCountry
      ,case when TRIM([CountryOfBirth]) = '' then NULL
            else TRIM([CountryOfBirth])
            end as CountryOfBirth
      ,case when TRIM([PassportCountry]) = '' then NULL
            else TRIM([PassportCountry])
            end as PassportCountry
--    ,[Ethnicity1] -- all null commented out
--    ,[Ethnicity2] -- all null commented out
--    ,[Ethnicity3] -- all null commented out
--    ,[Iwi1] -- all null commented out
--    ,[Iwi2] -- all null commented out
--    ,[Iwi3] -- all null commented out
      ,case when [MotherTongue] is null then '0002'
            when TRY_CONVERT(int,[MotherTongue]) is null then null
            when CONVERT(int,[MotherTongue]) < 0 then null
            when CONVERT(int,[MotherTongue]) > 9999 then null
            else RIGHT(REPLICATE('0', 4) + CONVERT(varchar,CONVERT(int,[MotherTongue])), 4)
            end as MotherTongue
      ,case when [LangAtHome] is null then '0002'
            when TRY_CONVERT(int,[LangAtHome]) is null then null
            when CONVERT(int,[LangAtHome]) < 0 then null
            when CONVERT(int,[LangAtHome]) > 9999 then null
            else RIGHT(REPLICATE('0', 4) + CONVERT(varchar,CONVERT(int,[LangAtHome])), 4)
            end as LangAtHome
      ,case when [OtherLanguage] is null then '0002'
            when TRY_CONVERT(int,[OtherLanguage]) is null then null
            when CONVERT(int,[OtherLanguage]) < 0 then null
            when CONVERT(int,[OtherLanguage]) > 9999 then null
            else RIGHT(REPLICATE('0', 4) + CONVERT(varchar,CONVERT(int,[OtherLanguage])), 4)
            end as OtherLanguage
--    ,[PacificLanguage] -- all null commented out
      ,CONVERT(date,[DeceasedDate]) AS DeceasedDate
      ,case when TRIM([DeathReportedBy]) = '' then NULL
            else TRIM([DeathReportedBy])
            end as DeathReportedBy
      ,CONVERT(date,[DeathReportedDate]) AS DeathReportedDate
      ,CONVERT(int,case when TRIM([EmploymentType]) = '' then null else [EmploymentType] end) AS EmploymentTypeCode
      ,CONVERT(int,case when TRIM([HighestSchoolLevel]) = '' then null else [HighestSchoolLevel] end) AS HighestSchoolLevelCode
      ,CONVERT(int,case when TRIM([HighestQualificationLevel]) = '' then null else [HighestQualificationLevel] end) AS HighestQualificationLevelCode
      ,CONVERT(int,[DebtorNo]) AS DebtorNo
--    ,[LastSuccessfulFinancialExport] -- all null commented out
      ,[Login] AS eMinerva_Login
      ,CONVERT(date,[DateBapCertSigned]) AS DateBapCertSigned
      ,case when LEFT([ParishBaptism],2) <> 'PR' then NULL
            else TRIM([ParishBaptism])
            end as ParishBaptismCode
      ,case when TRIM([Occupation]) = '' then null
            when TRY_CONVERT(int,[Occupation]) is null then null
            when CONVERT(int,[Occupation]) < 0 then null
            when CONVERT(int,[Occupation]) > 999999 then null
            else CONVERT(int,[Occupation])
            end as Occupation
      ,case when TRIM([Workplace]) = '' then null
            else TRIM([Workplace])
            end as Workplace
      ,case when TRIM([Talents]) = '' then null
            else TRIM([Talents])
            end as Talents
      ,case when TRIM([Interests]) = '' then null
            else TRIM([Interests])
            end as Interests
      ,case when TRIM([Comments]) = '' then null
            else TRIM([Comments])
            end as Comments
      ,case when TRIM([TownOfBirth]) = '' then null
            else TRIM([TownOfBirth])
            end as TownOfBirth
      ,CONVERT(int,[ApplicationId]) as ApplicationId
      ,[fwCreatedBy] AS CreatedBy
      ,CONVERT(datetime,[fwCreated],127) AS CreatedAt
      ,[fwUpdatedBy] AS UpdatedBy
      ,CONVERT(datetime,[fwUpdated],127) AS UpdatedAt
      ,CONVERT(datetime,[ChangeStart],127) AS ChangeStart
      ,CONVERT(datetime,[ChangeEnd],127) AS ChangeEnd
      ,CONVERT(bit,[EntityLock]) AS EntityLock
FROM [silver].[nhPerson]
WHERE [IsDisabled] = 0 -- Remove disabled entries
AND [SecName] <> 'Do Not Use' -- Remove soft disabled entries
-- This CTE keeps just fields for Staff
), StaffNhPerson as (
SELECT EntityId AS LocalId
--    ,TitleCode -- only 1 title across thousands of staff; commented out
      ,FamName
      ,FirstName
      ,SecName
      ,PrefName
      ,PrefFamName
--    ,DOB -- only 1 DOB across thousands of staff; commented out
--    ,Gender -- only 1 gender across thousands of staff; commented out
--    ,ReligionCode -- only 2 religion entries across thousands of staff; commented out
--    ,CitizenCountry -- no nationalities across thousands of staff; commented out
--    ,CountryOfBirth -- only 2 country of birth entries across thousands of staff; commented out
--    ,PassportCountry -- only 1 passport country entry across thousands of staff; commented out
--    ,MotherTongue -- No entries; commented out
--    ,LangAtHome -- Only 2 entries; commented out
--    ,OtherLanguage -- Only 2 entries; commented out
--    ,DeceasedDate -- No entries; commented out
--    ,DeathReportedBy -- No entries; commented out
--    ,DeathReportedDate -- No entries; commented out
--    ,EmploymentTypeCode -- Only 2 entries; commented out
--    ,HighestSchoolLevelCode -- Only 2 entries; commented out
--    ,HighestQualificationLevelCode -- Only 2 entries; commented out
      ,DebtorNo
--    ,eMinerva_Login -- No entries; commented out
--    ,DateBapCertSigned -- No entries; commented out
--    ,ParishBaptismCode -- No entries; commented out
--    ,Occupation -- Only 1 entry; commented out
--    ,Workplace -- Only 2 entries; commented out
--    ,Talents -- Only 1 entry; commented out
--    ,Interests -- Only 2 entries; commented out
--    ,Comments -- No entries; commented out
--    ,TownOfBirth -- No entries; commented out
--    ,ApplicationId -- Only 1 entry; commented out
      ,CreatedBy
      ,CreatedAt
      ,UpdatedBy
      ,UpdatedAt
      ,ChangeStart
--    ,ChangeEnd -- All 9999-12-31 23:59:59.997 - commented out
--    ,EntityLock -- All 0 or null; commented out
FROM nhPerson
WHERE isAcStaff = 1
)--, StaffNames as (
SELECT s.RefId as StaffRefId
      ,n.LocalId as StaffLocalId
      ,n.FamName as FamilyName
      ,n.FirstName as GivenName
      ,n.SecName as MiddleName
      ,n.PrefFamName as PreferredFamilyName
      ,n.PrefName as PreferredGivenName
      ,'LGL' as NameUsageTypeKey
      ,n.DebtorNo
      ,n.CreatedBy
      ,n.CreatedAt
      ,n.UpdatedBy
      ,n.UpdatedAt
      ,n.ChangeStart
FROM StaffNhPerson AS n
LEFT JOIN [cdm_demo_gold].[Dim1StaffPersonal] as s
ON n.LocalId = s.LocalId
--)
;
