-- This relational data structure implements AU SIF v3.6.3 as per link below:
-- http://specification.sifassociation.org/Implementation/AU/3.6.3/index.html#contents:~:text=Highlighted%20Additions/Changes-,3%20Data%20Model,-3.1%20Introduction

-- Elements are built in this numbered order:
--  (1) 3.10 SIF AU Student Baseline Profile (SBP) and supporting objects
--  (2) 3.8.1 LearningResource + 3.8.2 LearningResourcePackage
--  (3) 3.11 Timetabling and Resource Scheduling

/* ************************************************************************** */
/* SECTION: Dynamically drop all constraints & user tables before (re-)build  */
/* ************************************************************************** */

-- Need Azure SQL Database or Azure SQL Managed Instance for this demo.
-- Enforcement of Primary Keys, Foreign Keys, and unique constraints test our mapping is correct.
-- Such instance types can switch database with 'USE' command:
USE [demo_integration_gold];
PRINT N'Using database [demo_integration_gold]';
GO

-- Set schema within which to build the SIF relational data structure
DECLARE @schemaName SYSNAME = 'cdm_demo_gold';
-- Variable for dynamic SQL to execute
DECLARE @sql NVARCHAR(MAX) = N'';

-- Drop all Foreign Key Constraints
SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys fk
INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @schemaName;

-- Drop all Primary Key and Unique Constraints (including any clustered index created by a PK)
SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(kc.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(kc.parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(kc.name) + ';' + CHAR(13) + CHAR(10)
FROM sys.key_constraints kc
INNER JOIN sys.tables t ON kc.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @schemaName
  AND kc.type IN ('PK', 'UQ'); -- 'PK' for Primary Key, 'UQ' for Unique Constraint

-- Drop all Check Constraints
SELECT @sql += N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(cc.parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(cc.parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(cc.name) + ';' + CHAR(13) + CHAR(10)
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @schemaName;

-- Print the generated SQL for review
-- PRINT N'Dropping contraints as shown below...';
-- PRINT @sql;

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
PRINT N'All constraints (Foreign Key, Primary Key, Unique, Check) for user tables in schema [' + @schemaName + '] have been deleted';
GO

-- Now constraints dropped, tables can be dropped without errors
DECLARE @schemaName SYSNAME = 'cdm_demo_gold';
DECLARE @sql NVARCHAR(MAX) = N'';

-- Drop all user tables within the specified schema
SELECT @sql += N'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13) + CHAR(10)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @schemaName
  AND TABLE_TYPE = 'BASE TABLE'; -- Ensures only user-defined tables are targeted

-- Print the generated SQL for review
-- PRINT N'Dropping tables as shown below...';
-- PRINT @sql;

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
PRINT N'All user tables in schema [' + @schemaName + '] have been deleted';
GO

/* ************************************************************************** */
/* SECTION: Create target SIF data structure                                  */
/* ************************************************************************** */

-- Each instance of "VARCHAR (111)" that is a placeholder datatype only.
-- Such placeholder datatypes will need to be replaced during mapping.

-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 0 in name implement SIF codes (1&2 then have FKs)  --
-- -------------------------------------------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim0StaffEmploymentStatus (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_StaffEmploymentStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StaffEmploymentStatus';
INSERT INTO cdm_demo_gold.Dim0StaffEmploymentStatus ([TypeKey], [TypeValue]) VALUES
    ('A', 'Active'),
    ('I', 'Inactive'),
    ('N', 'No Longer Employed'),
    ('O', 'On Leave'),
    ('S', 'Suspended'),
    ('X', 'Other - Details Not Available');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StaffEmploymentStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0ElectronicIdType (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_ElectronicIdType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ElectronicIdType';
INSERT INTO cdm_demo_gold.Dim0ElectronicIdType ([TypeKey], [TypeValue]) VALUES
    ('01', 'Barcode'),
    ('02', 'Magstripe'),
    ('03', 'PIN'),
    ('04', 'RFID');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ElectronicIdType';
GO

CREATE TABLE cdm_demo_gold.Dim0NameUsageType (
     [TypeKey] CHAR (3) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_NameUsageType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0NameUsageType';
INSERT INTO cdm_demo_gold.Dim0NameUsageType ([TypeKey], [TypeValue]) VALUES
    ('AKA', 'Also known as or alias'),
    ('BTH', 'Name at Birth'),
    ('LGL', 'Legal Name of the client as defined by the organisation which collects it (legal not defined by SIF standard)'),
    ('MDN', 'Maiden Name'),
    ('NEW', 'New born identification name'),
    ('OTH', 'Non specific name usage type'),
    ('PBN', 'Professional or buisness name'),
    ('PRF', 'Preferred name'),
    ('PRV', 'Previous name'),
    ('STG', 'Stage name'),
    ('TRB', 'Tribal Name');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0NameUsageType';
GO

CREATE TABLE cdm_demo_gold.Dim0YesNoType (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_YesNoType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0YesNoType';
INSERT INTO cdm_demo_gold.Dim0YesNoType ([TypeKey], [TypeValue]) VALUES
    ('N', 'No'),
    ('U', 'Unknown'),
    ('X', 'Not Provided'),
    ('Y', 'Yes');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0YesNoType';
GO

CREATE TABLE cdm_demo_gold.Dim0IndigenousStatus (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_IndigenousStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0IndigenousStatus';
INSERT INTO cdm_demo_gold.Dim0IndigenousStatus ([TypeKey], [TypeValue]) VALUES
    (1, 'Aboriginal but not Torres Strait Islander origin'),
    (2, 'Torres Strait Islander but not Aboriginal origin'),
    (3, 'Both Aboriginal and Torres Strait Islander origin'),
    (4, 'Neither Aboriginal nor Torres Strait Islander origin'),
    (9, 'Not Stated/Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0IndigenousStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0SexCode (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SexCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SexCode';
INSERT INTO cdm_demo_gold.Dim0SexCode ([TypeKey], [TypeValue]) VALUES
    (1, 'Male'),
    (2, 'Female'),
    (3, 'Intersex or indeterminate'),
    (4, 'Self-described'),
    (9, 'Not Stated/Inadequately Described');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SexCode';
GO

CREATE TABLE cdm_demo_gold.Dim0BirthdateVerification (
     [TypeKey] VARCHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_BirthdateVerification] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0BirthdateVerification';
INSERT INTO cdm_demo_gold.Dim0BirthdateVerification ([TypeKey], [TypeValue]) VALUES
    ('1004', 'Birth certificate'),
    ('1006', 'Hospital certificate'),
    ('1008', 'Passport'),
    ('1009', 'Physician''s certificate'),
    ('1010', 'Previously verified school records'),
    ('1011', 'State-issued ID'),
    ('1012', 'Driver''s license'),
    ('1013', 'Immigration document/visa'),
    ('3423', 'Other official document'),
    ('3424', 'Other non-official document'),
    ('9999', 'Other'),
    ('N', 'Birthdate NOT Verified'),
    ('Y', 'Documentation Sighted, type not recorded');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0BirthdateVerification';
GO

CREATE TABLE cdm_demo_gold.Dim0StateTerritoryCode (
     [TypeKey] VARCHAR (3) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_StateTerritoryCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StateTerritoryCode';
INSERT INTO cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey], [TypeValue]) VALUES
    ('ACT', 'Australian Capital Territory'),
    ('NSW', 'New South Wales'),
    ('NT', 'Northern Territory'),
    ('OTH', 'Other Territories'),
    ('QLD', 'Queensland'),
    ('SA', 'South Australia'),
    ('TAS', 'Tasmania'),
    ('VIC', 'Victoria'),
    ('WA', 'Western Australia'),
    ('XXX', 'Not Provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StateTerritoryCode';
GO

CREATE TABLE cdm_demo_gold.Dim0AustralianCitizenshipStatus (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_AusCitizenshipCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AustralianCitizenshipStatus';
INSERT INTO cdm_demo_gold.Dim0AustralianCitizenshipStatus ([TypeKey], [TypeValue]) VALUES
    ('1', 'Australian Citizen'),
    ('2', 'New Zealand Citizen'),
    ('3', 'Permanent Resident'),
    ('4', 'Temporary Entry Permit'),
    ('5', 'Other Overseas'),
    ('8', 'Permanent Humanitarian Visa'),
    ('X', 'Not Provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AustralianCitizenshipStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0EnglishProficiency (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EnglishProficiency] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EnglishProficiency';
INSERT INTO cdm_demo_gold.Dim0EnglishProficiency ([TypeKey], [TypeValue]) VALUES
    (0, 'Not Stated/Inadequately described'),
    (1, 'Very well'),
    (2, 'Well'),
    (3, 'Not well'),
    (4, 'Not at all'),
    (9, 'Not Applicable - English is first language spoken and do not speak a language other than English at home');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EnglishProficiency';
GO

CREATE TABLE cdm_demo_gold.Dim0DwellingArrangement (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_DwellingArrangement] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0DwellingArrangement';
INSERT INTO cdm_demo_gold.Dim0DwellingArrangement ([TypeKey], [TypeValue]) VALUES
    ('1669', 'Boarding house'),
    ('1670', 'Cooperative house'),
    ('1671', 'Crisis shelter'),
    ('1672', 'Disaster shelter'),
    ('1673', 'Residential school/dormitory'),
    ('1674', 'Family residence - Both Parents/Guardians'),
    ('1675', 'Foster home'),
    ('1676', 'Institution'),
    ('1677', 'Prison or juvenile detention center'),
    ('1678', 'Rooming house'),
    ('1679', 'Transient shelter'),
    ('167I', 'Independent'),
    ('167o', 'Family residence - One Parent/Guardian'),
    ('1680', 'No home (Homeless Youth)'),
    ('1681', 'Other dormitory'),
    ('168A', 'Arranged by State - Out of Home Care'),
    ('3425', 'Group home/halfway house'),
    ('4000', 'Boarder'),
    ('9999', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0DwellingArrangement';
GO

CREATE TABLE cdm_demo_gold.Dim0ReligionType (
     [TypeKey] VARCHAR (6) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_ReligionType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ReligionType';
INSERT INTO cdm_demo_gold.Dim0ReligionType ([TypeKey], [TypeValue]) VALUES
    ('000000', 'Inadequately described'),
    ('000001', 'Not Stated'),
    ('1511', 'Buddhism'),
    ('2511', 'Anglican'),
    ('2512', 'Assyrian Apostolic'),
    ('2513', 'Baptist'),
    ('2515', 'Catholic'),
    ('2516', 'Churches of Christ'),
    ('2517', 'Eastern Orthodox'),
    ('2518', 'Jehovah''s Witnesses'),
    ('2521', 'Latter Day Saints'),
    ('2522', 'Lutheran'),
    ('2523', 'Oriental Orthodox'),
    ('2524', 'Pentecostal'),
    ('2525', 'Presbyterian and Reformed'),
    ('2526', 'Salvation Army'),
    ('2527', 'Seventh-day Adventist'),
    ('2528', 'Uniting Church'),
    ('2531', 'Other Protestant'),
    ('2532', 'Other Christian'),
    ('3511', 'Hinduism'),
    ('4511', 'Shia Islam'),
    ('4512', 'Sunni Islam'),
    ('4513', 'Other Islam'),
    ('5511', 'Judaism'),
    ('6511', 'Sikhism'),
    ('8511', 'Australian Aboriginal Traditional Religions'),
    ('8512', 'Baha''i'),
    ('8513', 'Chinese Religions'),
    ('8514', 'Druse'),
    ('8515', 'Japanese Religions'),
    ('8516', 'Nature Religions'),
    ('8517', 'Spiritualism'),
    ('8518', 'Miscellaneous Religions'),
    ('9511', 'No Religion, so described'),
    ('9512', 'Secular Beliefs'),
    ('9513', 'Other Spiritual Beliefs'),
    ('25143', 'Brethren'),
    ('151100', 'Buddhism, nfd'),
    ('250000', 'Christian, nfd'),
    ('251200', 'Assyrian Apostolic, nfd'),
    ('251500', 'Catholic, nfd'),
    ('251600', 'Churches of Christ, nfd'),
    ('252100', 'Latter Day Saints, nfd'),
    ('252300', 'Oriental Orthodox, nfd'),
    ('252400', 'Pentecostal, nfd'),
    ('252500', 'Presbyterian and Reformed, nfd'),
    ('253100', 'Other Protestant, nfd'),
    ('253200', 'Other Christian, nfd'),
    ('450000', 'Islam, nfd'),
    ('851300', 'Chinese Religions, nfd'),
    ('851500', 'Japanese Religions, nfd'),
    ('851600', 'Nature Religions, nfd'),
    ('950000', 'Secular Beliefs and Other Spiritual Beliefs and No Religious Affiliation, nfd'),
    ('951200', 'Secular Beliefs, nfd'),
    ('951300', 'Other Spiritual Beliefs, nfd');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ReligionType';
GO

CREATE TABLE cdm_demo_gold.Dim0PermanentResidentStatus (
     [TypeKey] VARCHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_PermanentResidentStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PermanentResidentStatus';
INSERT INTO cdm_demo_gold.Dim0PermanentResidentStatus ([TypeKey], [TypeValue]) VALUES
    ('99', 'Unknown'),
    ('N', 'Not a Resident'),
    ('P', 'Permanent Resident'),
    ('T', 'Temporary Resident');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PermanentResidentStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0VisaStudyEntitlement (
     [TypeKey] VARCHAR (9) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_VisaStudyEntitlement] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0VisaStudyEntitlement';
INSERT INTO cdm_demo_gold.Dim0VisaStudyEntitlement ([TypeKey], [TypeValue]) VALUES
    ('Nil', 'No entitlement to study'),
    ('Limited', 'Limited entitlement to study'),
    ('Unlimited', 'Unlimited entitlement to study');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0VisaStudyEntitlement';
GO


CREATE TABLE cdm_demo_gold.Dim0ImmunisationCertificateStatus (
     [TypeKey] VARCHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_ImmunisationCertificateStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ImmunisationCertificateStatus';
INSERT INTO cdm_demo_gold.Dim0ImmunisationCertificateStatus ([TypeKey], [TypeValue]) VALUES
    ('C', 'Complete'),
    ('I', 'Incomplete no reason given'),
    ('IM', 'Incomplete - Medical Reason'),
    ('IN', 'Incomplete and Not up to date'),
    ('IO', 'Incomplete - Objection'),
    ('IU', 'Incomplete but Up to date'),
    ('N', 'Not Sighted or Not Provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ImmunisationCertificateStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0CulturalEthnicGroups (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_CulturalEthnicGroups] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0CulturalEthnicGroups';
INSERT INTO cdm_demo_gold.Dim0CulturalEthnicGroups ([TypeKey], [TypeValue]) VALUES
    ('0000', 'Inadequately described'),
    ('0001', 'Not stated'),
    ('0901', 'Eurasian, so described'),
    ('0902', 'Asian, so described'),
    ('0903', 'African, so described'),
    ('0904', 'European, so described'),
    ('0905', 'Caucasian, so described'),
    ('0906', 'Creole, so described'),
    ('1000', 'Oceanian, nfd'),
    ('1100', 'Australian Peoples, nfd'),
    ('1101', 'Australian'),
    ('1102', 'Australian Aboriginal'),
    ('1103', 'Australian South Sea Islander'),
    ('1104', 'Torres Strait Islander'),
    ('1105', 'Norfolk Islander'),
    ('1200', 'New Zealand Peoples, nfd'),
    ('1201', 'Maori'),
    ('1202', 'New Zealander'),
    ('1300', 'Melanesian and Papuan, nfd'),
    ('1301', 'New Caledonian'),
    ('1302', 'Ni-Vanuatu'),
    ('1303', 'Papua New Guinean'),
    ('1304', 'Solomon Islander'),
    ('1399', 'Melanesian and Papuan, nec'),
    ('1400', 'Micronesian, nfd'),
    ('1401', 'I-Kiribati'),
    ('1402', 'Nauruan'),
    ('1499', 'Micronesian, nec'),
    ('1500', 'Polynesian, nfd'),
    ('1501', 'Cook Islander'),
    ('1502', 'Fijian'),
    ('1503', 'Niuean'),
    ('1504', 'Samoan'),
    ('1505', 'Tongan'),
    ('1506', 'Hawaiian'),
    ('1507', 'Tahitian'),
    ('1508', 'Tokelauan'),
    ('1511', 'Tuvaluan'),
    ('1512', 'Pitcairn'),
    ('1599', 'Polynesian, nec'),
    ('2000', 'North-West European, nfd'),
    ('2100', 'British, nfd'),
    ('2101', 'English'),
    ('2102', 'Scottish'),
    ('2103', 'Welsh'),
    ('2104', 'Channel Islander'),
    ('2105', 'Manx'),
    ('2199', 'British, nec'),
    ('2201', 'Irish'),
    ('2300', 'Western European, nfd'),
    ('2301', 'Austrian'),
    ('2303', 'Dutch'),
    ('2304', 'Flemish'),
    ('2305', 'French'),
    ('2306', 'German'),
    ('2307', 'Swiss'),
    ('2311', 'Belgian'),
    ('2312', 'Frisian'),
    ('2313', 'Luxembourg'),
    ('2399', 'Western European, nec'),
    ('2400', 'Northern European, nfd'),
    ('2401', 'Danish'),
    ('2402', 'Finnish'),
    ('2403', 'Icelandic'),
    ('2404', 'Norwegian'),
    ('2405', 'Swedish'),
    ('2499', 'Northern European, nec'),
    ('3000', 'Southern and Eastern European, nfd'),
    ('3100', 'Southern European, nfd'),
    ('3101', 'Basque'),
    ('3102', 'Catalan'),
    ('3103', 'Italian'),
    ('3104', 'Maltese'),
    ('3105', 'Portuguese'),
    ('3106', 'Spanish'),
    ('3107', 'Gibraltarian'),
    ('3199', 'Southern European, nec'),
    ('3200', 'South Eastern European, nfd'),
    ('3201', 'Albanian'),
    ('3202', 'Bosnian'),
    ('3203', 'Bulgarian'),
    ('3204', 'Croatian'),
    ('3205', 'Greek'),
    ('3206', 'Macedonian'),
    ('3207', 'Moldovan'),
    ('3208', 'Montenegrin'),
    ('3211', 'Romanian'),
    ('3212', 'Roma Gypsy'),
    ('3213', 'Serbian'),
    ('3214', 'Slovene'),
    ('3215', 'Cypriot'),
    ('3216', 'Vlach'),
    ('3299', 'South Eastern European, nec'),
    ('3300', 'Eastern European, nfd'),
    ('3301', 'Belarusan'),
    ('3302', 'Czech'),
    ('3303', 'Estonian'),
    ('3304', 'Hungarian'),
    ('3305', 'Latvian'),
    ('3306', 'Lithuanian'),
    ('3307', 'Polish'),
    ('3308', 'Russian'),
    ('3311', 'Slovak'),
    ('3312', 'Ukrainian'),
    ('3313', 'Sorb/Wend'),
    ('3399', 'Eastern European, nec'),
    ('4000', 'North African and Middle Eastern, nfd'),
    ('4100', 'Arab, nfd'),
    ('4101', 'Algerian'),
    ('4102', 'Egyptian'),
    ('4103', 'Iraqi'),
    ('4104', 'Jordanian'),
    ('4105', 'Kuwaiti'),
    ('4106', 'Lebanese'),
    ('4107', 'Libyan'),
    ('4108', 'Moroccan'),
    ('4111', 'Palestinian'),
    ('4112', 'Saudi Arabian'),
    ('4113', 'Syrian'),
    ('4114', 'Tunisian'),
    ('4115', 'Yemeni'),
    ('4116', 'Bahraini'),
    ('4117', 'Emirati'),
    ('4118', 'Omani'),
    ('4121', 'Qatari'),
    ('4199', 'Arab, nec'),
    ('4201', 'Jewish'),
    ('4300', 'Peoples of the Sudan, nfd'),
    ('4301', 'Bari'),
    ('4302', 'Darfur'),
    ('4303', 'Dinka'),
    ('4304', 'Nuer'),
    ('4305', 'South Sudanese'),
    ('4306', 'Sudanese'),
    ('4399', 'Peoples of the Sudan, nec'),
    ('4900', 'Other North African and Middle Eastern, nfd'),
    ('4902', 'Berber'),
    ('4903', 'Coptic'),
    ('4904', 'Iranian'),
    ('4905', 'Kurdish'),
    ('4907', 'Turkish'),
    ('4908', 'Assyrian'),
    ('4911', 'Chaldean'),
    ('4912', 'Mandaean'),
    ('4913', 'Nubian'),
    ('4914', 'Yezidi'),
    ('4999', 'Other North African and Middle Eastern, nec'),
    ('5000', 'South-East Asian, nfd'),
    ('5100', 'Mainland South-East Asian, nfd'),
    ('5101', 'Anglo-Burmese'),
    ('5102', 'Burmese'),
    ('5103', 'Hmong'),
    ('5104', 'Khmer (Cambodian)'),
    ('5105', 'Lao'),
    ('5106', 'Thai'),
    ('5107', 'Vietnamese'),
    ('5108', 'Karen'),
    ('5111', 'Mon'),
    ('5112', 'Chin'),
    ('5113', 'Rohingya'),
    ('5199', 'Mainland South-East Asian, nec'),
    ('5200', 'Maritime South-East Asian, nfd'),
    ('5201', 'Filipino'),
    ('5202', 'Indonesian'),
    ('5203', 'Javanese'),
    ('5204', 'Madurese'),
    ('5205', 'Malay'),
    ('5206', 'Sundanese'),
    ('5207', 'Timorese'),
    ('5208', 'Acehnese'),
    ('5211', 'Balinese'),
    ('5212', 'Bruneian'),
    ('5213', 'Kadazan'),
    ('5214', 'Singaporean'),
    ('5215', 'Temoq'),
    ('5299', 'Maritime South-East Asian, nec'),
    ('6000', 'North-East Asian, nfd'),
    ('6100', 'Chinese Asian, nfd'),
    ('6101', 'Chinese'),
    ('6102', 'Taiwanese'),
    ('6199', 'Chinese Asian, nec'),
    ('6900', 'Other North-East Asian, nfd'),
    ('6901', 'Japanese'),
    ('6902', 'Korean'),
    ('6903', 'Mongolian'),
    ('6904', 'Tibetan'),
    ('6999', 'Other North-East Asian, nec'),
    ('7000', 'Southern and Central Asian, nfd'),
    ('7100', 'Southern Asian, nfd'),
    ('7101', 'Anglo-Indian'),
    ('7102', 'Bengali'),
    ('7103', 'Burgher'),
    ('7104', 'Gujarati'),
    ('7106', 'Indian'),
    ('7107', 'Malayali'),
    ('7111', 'Nepalese'),
    ('7112', 'Pakistani'),
    ('7113', 'Punjabi'),
    ('7114', 'Sikh'),
    ('7115', 'Sinhalese'),
    ('7117', 'Maldivian'),
    ('7118', 'Bangladeshi'),
    ('7121', 'Bhutanese'),
    ('7122', 'Fijian Indian'),
    ('7123', 'Kashmiri'),
    ('7124', 'Parsi'),
    ('7125', 'Sindhi'),
    ('7126', 'Sri Lankan'),
    ('7127', 'Sri Lankan Tamil'),
    ('7128', 'Indian Tamil'),
    ('7131', 'Tamil, nfd'),
    ('7132', 'Telugu'),
    ('7199', 'Southern Asian, nec'),
    ('7200', 'Central Asian, nfd'),
    ('7201', 'Afghan'),
    ('7202', 'Armenian'),
    ('7203', 'Georgian'),
    ('7204', 'Kazakh'),
    ('7205', 'Pathan'),
    ('7206', 'Uzbek'),
    ('7207', 'Azeri'),
    ('7208', 'Hazara'),
    ('7211', 'Tajik'),
    ('7212', 'Tatar'),
    ('7213', 'Turkmen'),
    ('7214', 'Uighur'),
    ('7215', 'Kyrgyz'),
    ('7299', 'Central Asian, nec'),
    ('8000', 'Peoples of the Americas, nfd'),
    ('8100', 'North American, nfd'),
    ('8101', 'African American'),
    ('8102', 'American'),
    ('8103', 'Canadian'),
    ('8104', 'French Canadian'),
    ('8105', 'Hispanic North American'),
    ('8106', 'Native North American Indian'),
    ('8107', 'Bermudan'),
    ('8199', 'North American, nec'),
    ('8200', 'South American, nfd'),
    ('8201', 'Argentinian'),
    ('8202', 'Bolivian'),
    ('8203', 'Brazilian'),
    ('8204', 'Chilean'),
    ('8205', 'Colombian'),
    ('8206', 'Ecuadorian'),
    ('8207', 'Guyanese'),
    ('8208', 'Peruvian'),
    ('8211', 'Uruguayan'),
    ('8212', 'Venezuelan'),
    ('8213', 'Paraguayan'),
    ('8299', 'South American, nec'),
    ('8300', 'Central American, nfd'),
    ('8301', 'Mexican'),
    ('8302', 'Nicaraguan'),
    ('8303', 'Salvadoran'),
    ('8304', 'Costa Rican'),
    ('8305', 'Guatemalan'),
    ('8306', 'Mayan'),
    ('8399', 'Central American, nec'),
    ('8400', 'Caribbean Islander, nfd'),
    ('8401', 'Cuban'),
    ('8402', 'Jamaican'),
    ('8403', 'Trinidadian Tobagonian'),
    ('8404', 'Barbadian'),
    ('8405', 'Puerto Rican'),
    ('8499', 'Caribbean Islander, nec'),
    ('9000', 'Sub-Saharan African, nfd'),
    ('9100', 'Central and West African, nfd'),
    ('9101', 'Akan'),
    ('9102', 'Fulani'),
    ('9103', 'Ghanaian'),
    ('9104', 'Nigerian'),
    ('9105', 'Yoruba'),
    ('9106', 'Ivorean'),
    ('9107', 'Liberian'),
    ('9108', 'Sierra Leonean'),
    ('9111', 'Acholi'),
    ('9112', 'Cameroonian'),
    ('9113', 'Congolese'),
    ('9114', 'Gio'),
    ('9115', 'Igbo'),
    ('9116', 'Krahn'),
    ('9117', 'Mandinka'),
    ('9118', 'Senegalese'),
    ('9121', 'Themne'),
    ('9122', 'Togolese'),
    ('9199', 'Central and West African, nec'),
    ('9200', 'Southern and East African, nfd'),
    ('9201', 'Afrikaner'),
    ('9202', 'Angolan'),
    ('9203', 'Eritrean'),
    ('9204', 'Ethiopian'),
    ('9205', 'Kenyan'),
    ('9206', 'Malawian'),
    ('9207', 'Mauritian'),
    ('9208', 'Mozambican'),
    ('9211', 'Namibian'),
    ('9212', 'Oromo'),
    ('9213', 'Seychellois'),
    ('9214', 'Somali'),
    ('9215', 'South African'),
    ('9216', 'Tanzanian'),
    ('9217', 'Ugandan'),
    ('9218', 'Zambian'),
    ('9221', 'Zimbabwean'),
    ('9222', 'Amhara'),
    ('9223', 'Batswana'),
    ('9225', 'Hutu'),
    ('9226', 'Masai'),
    ('9228', 'Tigrayan'),
    ('9231', 'Tigre'),
    ('9232', 'Zulu'),
    ('9233', 'Burundian'),
    ('9234', 'Kunama'),
    ('9235', 'Madi'),
    ('9236', 'Ogaden'),
    ('9237', 'Rwandan'),
    ('9238', 'Shona'),
    ('9241', 'Swahili'),
    ('9242', 'Swazilander'),
    ('9299', 'Southern and East African, nec');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0CulturalEthnicGroups';
GO

CREATE TABLE cdm_demo_gold.Dim0MaritalStatus (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_MaritalStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0MaritalStatus';
INSERT INTO cdm_demo_gold.Dim0MaritalStatus ([TypeKey], [TypeValue]) VALUES
    (1, 'Never Married'),
    (2, 'Widowed'),
    (3, 'Divorced'),
    (4, 'Separated'),
    (5, 'Married (registered and de facto)'),
    (6, 'Not stated/inadequately described');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0MaritalStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0AddressType (
     [TypeKey] VARCHAR (5) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_AddressType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AddressType';
INSERT INTO cdm_demo_gold.Dim0AddressType ([TypeKey], [TypeValue]) VALUES
    ('0123', 'Mailing address'),
    ('0123A', 'Alternate Mailing address'),
    ('0124', 'Shipping address'),
    ('0124A', 'Alternate Shipping address'),
    ('0125', 'Billing address'),
    ('0765', 'Physical location address'),
    ('0765A', 'Alternate Physical location address'),
    ('9999', 'Other'),
    ('9999A', 'Alternate Other address');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AddressType';
GO

CREATE TABLE cdm_demo_gold.Dim0AddressRole (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_AddressRole] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AddressRole';
INSERT INTO cdm_demo_gold.Dim0AddressRole ([TypeKey], [TypeValue]) VALUES
    ('012A', 'Term Address'),
    ('012B', 'Home Address'),
    ('012C', 'Home Stay Address'),
    ('013A', 'Overseas Address'),
    ('1073', 'Other home address'),
    ('1074', 'Employer''s address'),
    ('1075', 'Employment address'),
    ('2382', 'Other organisation address'),
    ('9999', 'Other Address');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AddressRole';
GO

CREATE TABLE cdm_demo_gold.Dim0SpatialUnitType (
     [TypeKey] VARCHAR (5) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SpatialUnitType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SpatialUnitType';
INSERT INTO cdm_demo_gold.Dim0SpatialUnitType ([TypeKey], [TypeValue]) VALUES
    ('MB', 'Mesh Block'),
    ('SA1', 'Statistical Area Level 1'),
    ('SA2', 'Statistical Area Level 2'),
    ('SA3', 'Statistical Area Level 3'),
    ('SA4', 'Statistical Area Level 4'),
    ('GCCSA', 'Greater Capital City Statistical Areas'),
    ('S/T', 'State and Territory'),
    ('LG', 'Local Government Area'),
    ('TR', 'TourismRegion'),
    ('ILOC', 'Indigenous Location'),
    ('IARE', 'Indigenous Area'),
    ('IREG', 'Indigenous Region');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SpatialUnitType';
GO

CREATE TABLE cdm_demo_gold.Dim0PhoneNumberType (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_PhoneNumberType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PhoneNumberType';
INSERT INTO cdm_demo_gold.Dim0PhoneNumberType ([TypeKey], [TypeValue]) VALUES
    ('0096', 'Main telephone number'),
    ('0350', 'Alternate telephone number'),
    ('0359', 'Answering service'),
    ('0370', 'Beeper number'),
    ('0400', 'Appointment telephone number'),
    ('0426', 'Telex number'),
    ('0437', 'Telemail'),
    ('0448', 'Voice mail'),
    ('0478', 'Instant messaging number'),
    ('0486', 'Media conferencing number'),
    ('0777', 'Home Telephone Number'),
    ('0779', 'Home Mobile'),
    ('0887', 'Work Telephone Number'),
    ('0888', 'Mobile'),
    ('0889', 'Work Mobile'),
    ('2364', 'Facsimile number');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PhoneNumberType';
GO

CREATE TABLE cdm_demo_gold.Dim0EmailType (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EmailType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EmailType';
INSERT INTO cdm_demo_gold.Dim0EmailType ([TypeKey], [TypeValue]) VALUES
    ('01', 'Primary'),
    ('02', 'Alternate 1'),
    ('03', 'Alternate 2'),
    ('04', 'Alternate 3'),
    ('05', 'Alternate 4'),
    ('06', 'Work'),
    ('07', 'Personal');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EmailType';
GO

-- Student but not Staff Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0AlertMessageType (
     [TypeKey] VARCHAR (11) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_AlertMessageType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AlertMessageType';
INSERT INTO cdm_demo_gold.Dim0AlertMessageType ([TypeKey], [TypeValue]) VALUES
    ('Legal', 'Custody, guardian, court orders (e.g. must attend school), lawsuits, etc.'),
    ('Discipline', 'Student is suspended, expelled, on probation, etc.'),
    ('Educational', 'Academic probation, etc.'),
    ('Other', '');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AlertMessageType';
GO

CREATE TABLE cdm_demo_gold.Dim0MedicalSeverity (
     [TypeKey] VARCHAR (8) NOT NULL,
     CONSTRAINT [PK_MedicalSeverity] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0MedicalSeverity';
INSERT INTO cdm_demo_gold.Dim0MedicalSeverity ([TypeKey]) VALUES
    ('Low'),
    ('Moderate'),
    ('High'),
    ('Severe'),
    ('Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0MedicalSeverity';
GO

CREATE TABLE cdm_demo_gold.Dim0DisabilityNCCDCategory (
     [TypeKey] VARCHAR (16) NOT NULL,
     CONSTRAINT [PK_DisabilityNCCDCategory] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0DisabilityNCCDCategory';
INSERT INTO cdm_demo_gold.Dim0DisabilityNCCDCategory ([TypeKey]) VALUES
    ('None'),
    ('Cognitive'),
    ('Physical'),
    ('Sensory'),
    ('Social-Emotional');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0DisabilityNCCDCategory';
GO

CREATE TABLE cdm_demo_gold.Dim0PrePrimaryEducationHours (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_PrePrimaryEducationHours] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PrePrimaryEducationHours';
INSERT INTO cdm_demo_gold.Dim0PrePrimaryEducationHours ([TypeKey], [TypeValue]) VALUES
    ('F', 'Full Time'),
    ('P', 'Part Time'),
    ('O', 'Other - not elsewhere classified'),
    ('U', 'Unknown or Not Provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PrePrimaryEducationHours';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolEnrollmentType (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolEnrollmentType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolEnrollmentType';
INSERT INTO cdm_demo_gold.Dim0SchoolEnrollmentType ([TypeKey], [TypeValue]) VALUES
    ('01', 'Home School'),
    ('02', 'Other School'),
    ('03', 'Concurrent Enrolment');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolEnrollmentType';
GO

CREATE TABLE cdm_demo_gold.Dim0FFPOSStatusCode (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_FFPOSStatusCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0FFPOSStatusCode';
INSERT INTO cdm_demo_gold.Dim0FFPOSStatusCode ([TypeKey], [TypeValue]) VALUES
    (1, 'FFPOS'),
    (2, 'Non-FFPOS'),
    (9, 'Not stated/Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0FFPOSStatusCode';
GO

CREATE TABLE cdm_demo_gold.Dim0DisabilityLevelOfAdjustment (
     [TypeKey] VARCHAR (71) NOT NULL
     CONSTRAINT [PK_DisabilityLevelOfAdjustment] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0DisabilityLevelOfAdjustment';
INSERT INTO cdm_demo_gold.Dim0DisabilityLevelOfAdjustment ([TypeKey]) VALUES
    ('None'),
    ('QDTP (support provided within Quality Differentiated Teaching Practice)'),
    ('Supplementary'),
    ('Substantial'),
    ('Extensive');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0DisabilityLevelOfAdjustment';
GO

CREATE TABLE cdm_demo_gold.Dim0BoardingStatus (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_BoardingStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0BoardingStatus';
INSERT INTO cdm_demo_gold.Dim0BoardingStatus ([TypeKey], [TypeValue]) VALUES
    ('B', 'Boarding Student'),
    ('D', 'Day Student');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0BoardingStatus';
GO

-- StudentContact (aka parents & guardians) Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0EmploymentType (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EmploymentType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EmploymentType';
INSERT INTO cdm_demo_gold.Dim0EmploymentType ([TypeKey], [TypeValue]) VALUES
    (1, 'Qualified professionals, senior management in large business organisation, government administration and defence'),
    (2, 'Other business managers, arts/media/sportspersons and associate professionals'),
    (3, 'Tradesmen/women, clerks and skilled office, sales and service staff'),
    (4, 'Machine operators, hospitality staff, assistants, labourers and related workers'),
    (8, 'Out of employed work for 12 months or more (if less use previous occupational group)'),
    (9, 'Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EmploymentType';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolEducationLevelType (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolEducationLevelType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolEducationLevelType';
INSERT INTO cdm_demo_gold.Dim0SchoolEducationLevelType ([TypeKey], [TypeValue]) VALUES
    (0, 'Not stated/Unknown'),
    (1, 'Year 9 or equivalent or below'),
    (2, 'Year 10 or equivalent'),
    (3, 'Year 11 or equivalent'),
    (4, 'Year 12 or equivalent');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolEducationLevelType';
GO

CREATE TABLE cdm_demo_gold.Dim0NonSchoolEducationType (
     [TypeKey] INT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_NonSchoolEducationType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0NonSchoolEducationType';
INSERT INTO cdm_demo_gold.Dim0NonSchoolEducationType ([TypeKey], [TypeValue]) VALUES
    (0, 'Not stated/Unknown'),
    (5, 'Certificate I to IV (including trade certificate)'),
    (6, 'Advanced diploma/Diploma'),
    (7, 'Bachelor degree or above'),
    (8, 'No non-school qualification');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0NonSchoolEducationType';
GO

-- LEAInfo Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0EducationAgencyType (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EducationAgencyType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EducationAgencyType';
INSERT INTO cdm_demo_gold.Dim0EducationAgencyType ([TypeKey], [TypeValue]) VALUES
    ('01', 'Jurisdictional agency'),
    ('02', 'Cross-jurisdictional agency'),
    ('03', 'Intra-jurisdictional agency'),
    ('99', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EducationAgencyType';
GO

CREATE TABLE cdm_demo_gold.Dim0OperationalStatus (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_OperationalStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0OperationalStatus';
INSERT INTO cdm_demo_gold.Dim0OperationalStatus ([TypeKey], [TypeValue]) VALUES
    ('B', 'Building or Construction Started'),
    ('C', 'Closed'),
    ('O', 'Open'),
    ('P', 'Proposed'),
    ('S', 'Site'),
    ('U', 'Unstaffed');

PRINT N'Inserted SIF values into cdm_demo_gold.Dim0OperationalStatus';
GO

-- SchoolInfo Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0SchoolLevelType (
     [TypeKey] VARCHAR (17) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolLevelType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolLevelType';
INSERT INTO cdm_demo_gold.Dim0SchoolLevelType ([TypeKey], [TypeValue]) VALUES
    ('Camp', 'Camp'),
    ('Commty', 'Community College'),
    ('EarlyCh', 'Early Childhood'),
    ('JunPri', 'Junior Primary'),
    ('Kgarten', 'Kindergarten only'),
    ('Kind', 'Preschool/Kindergarten'),
    ('Lang', 'Language'),
    ('MCH', 'Maternal Child Health Centre'),
    ('Middle', 'Middle School'),
    ('Other', 'Other'),
    ('PreSch', 'PreSchool only'),
    ('Pri/Sec', 'Primary/Secondary Combined'),
    ('Prim', 'Primary'),
    ('Sec', 'Secondary'),
    ('Senior', 'Senior Secondary School'),
    ('Spec/P-12', 'Special/Primary/Secondary Combined'),
    ('Spec/Pri', 'Special/Primary Combined'),
    ('Spec/Sec', 'Special/Secondary Combined'),
    ('Special', 'Special'),
    ('SpecialAssistance', 'Special Assistance'),
    ('Specif', 'Specific Purpose'),
    ('Supp', 'SupportCentre'),
    ('Unknown', 'Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolLevelType';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolFocusCode (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolFocusCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolFocusCode';
INSERT INTO cdm_demo_gold.Dim0SchoolFocusCode ([TypeKey], [TypeValue]) VALUES
    ('01', 'Regular'),
    ('02', 'Special Ed'),
    ('03', 'Alternate'),
    ('04', 'Vocational'),
    ('98', 'Other'),
    ('99', 'Not Provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolFocusCode';
GO

CREATE TABLE cdm_demo_gold.Dim0ARIAClass (
     [TypeKey] SMALLINT NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_ARIAClass] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ARIAClass';
INSERT INTO cdm_demo_gold.Dim0ARIAClass ([TypeKey], [TypeValue]) VALUES
    (1, 'Major Cities (ARIA score 0 <= 0.20) — relatively unrestricted accessibility to a wide range of goods, services and opportunities for social interaction'),
    (2, 'Inner Regional (ARIA score greater than 0.20 to <=2.40) — some restrictions to accessibility to some goods, services and opportunities for social interaction'),
    (3, 'Outer Regional (ARIA score greater than 2.40 to <=5.92) — significantly restricted accessibility to goods, services and opportunities for social interaction'),
    (4, 'Remote (ARIA score greater than 5.92 to <=10.53) — very restricted accessibility to goods, services and opportunities for social interaction'),
    (5, 'Very Remote (ARIA score greater than 10.53 to <=15) — very little accessibility to goods, services and opportunities for social interaction');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ARIAClass';
GO

CREATE TABLE cdm_demo_gold.Dim0SessionType (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SessionType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SessionType';
INSERT INTO cdm_demo_gold.Dim0SessionType ([TypeKey], [TypeValue]) VALUES
    ('0827', 'Full school year'),
    ('0828', 'Semester'),
    ('0829', 'Trimester'),
    ('0830', 'Quarter'),
    ('0832', 'Mini-term'),
    ('0833', 'Summer term'),
    ('0837', 'Twelve month'),
    ('9999', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SessionType';
GO

CREATE TABLE cdm_demo_gold.Dim0YearLevelCode (
     [TypeKey] VARCHAR (8) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_YearLevelCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0YearLevelCode';
INSERT INTO cdm_demo_gold.Dim0YearLevelCode ([TypeKey], [TypeValue]) VALUES
    ('0', 'Year 1 minus 1 — For use for AG Collection Reporting. Full time Education Pre Year 1, equivalent to Year Level 1 minus 1, also known as Foundation'),
    ('1', 'Year 1'),
    ('11MINUS', '11 Years and Younger'),
    ('12PLUS', '12 years and Older'),
    ('2', 'Year 2'),
    ('3', 'Year 3'),
    ('4', 'Year 4'),
    ('5', 'Year 5'),
    ('6', 'Year 6'),
    ('7', 'Year 7'),
    ('8', 'Year 8'),
    ('9', 'Year 9'),
    ('10', 'Year 10'),
    ('11', 'Year 11'),
    ('12', 'Year 12'),
    ('13', 'Year 13'),
    ('CC', 'Childcare'),
    ('K', 'Kindergarten'),
    ('K3', '3yo Kindergarten'),
    ('K4', '4yo Kindergarten'),
    ('P', 'Prep'),
    ('PS', 'Pre-School'),
    ('UG', 'Ungraded'),
    ('UGJunSec', 'Ungraded Junior Secondary'),
    ('UGPri', 'Ungraded Primary'),
    ('UGSec', 'Ungraded Secondary'),
    ('UGSnrSec', 'Ungraded Senior Secondary');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0YearLevelCode';
GO

CREATE TABLE cdm_demo_gold.Dim0FederalElectorateList (
     [FederalDivisionAlphabeticalId] SMALLINT NOT NULL,
     [FederalDivisionName] VARCHAR (63) NOT NULL,
     [StateTerritoryCode] VARCHAR (3) NOT NULL,
     [ExtractedFromAPHDateTime] DATETIME NOT NULL,
     [Classification] VARCHAR (63) NULL,
     [MP_Title] VARCHAR (63) NULL,
     [MP_GivenName] VARCHAR (63) NULL,
     [MP_FamilyName] VARCHAR (63) NULL,
     [MP_Party] VARCHAR (63) NULL,
     [MP_Positions] VARCHAR (255) NULL,
     CONSTRAINT [PK_FederalElectorateList] PRIMARY KEY ([FederalDivisionAlphabeticalId]),
     CONSTRAINT [FK_FederalElectorateList_StateTerritoryCode] FOREIGN KEY ([StateTerritoryCode]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0FederalElectorateList';
INSERT INTO cdm_demo_gold.Dim0FederalElectorateList ([FederalDivisionAlphabeticalId],[FederalDivisionName],[StateTerritoryCode],[ExtractedFromAPHDateTime],[Classification],[MP_Title],[MP_GivenName],[MP_FamilyName],[MP_Party],[MP_Positions]) VALUES
    (1,'Adelaide','SA','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Steve','Georganas','Australian Labor Party','Chair of Joint Standing Committee on Migration'),
    (2,'Aston','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Mary','Doyle','Australian Labor Party', NULL ),
    (3,'Ballarat','VIC','2025-08-07T00:00:00Z','Provincial','Hon','Catherine','King','Australian Labor Party','Minister for Infrastructure, Transport; Regional Development and Local Government'),
    (4,'Banks','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Zhi','Soon','Australian Labor Party', NULL ),
    (5,'Barker','SA','2025-08-07T00:00:00Z','Rural','Mr','Tony','Pasin','Liberal Party of Australia', NULL ),
    (6,'Barton','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Ash','Ambihaipahar','Australian Labor Party', NULL ),
    (7,'Bass','TAS','2025-08-07T00:00:00Z','Provincial','Ms','Jess','Teesdale','Australian Labor Party', NULL ),
    (8,'Bean','ACT','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','David','Smith','Australian Labor Party','Government Whip'),
    (9,'Bendigo','VIC','2025-08-07T00:00:00Z','Provincial','Ms','Lisa','Chesters','Australian Labor Party','Chair of Joint Standing Committee on Treaties'),
    (10,'Bennelong','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Jerome','Laxale','Australian Labor Party','Chair of Joint Standing Committee on Electoral Matters'),
    (11,'Berowra','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Julian','Leeser','Liberal Party of Australia', NULL ),
    (12,'Blair','QLD','2025-08-07T00:00:00Z','Provincial','Hon','Shayne','Neumann','Australian Labor Party','Chair of Joint Standing Committee on Foreign Affairs, Defence and Trade'),
    (13,'Blaxland','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Jason','Clare','Australian Labor Party','Minister for Education'),
    (14,'Bonner','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Kara','Cook','Australian Labor Party', NULL ),
    (15,'Boothby','SA','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Louise','Miller-Frost','Australian Labor Party','Chair of Standing Committee on Social Policy and Legal Affairs'),
    (16,'Bowman','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Henry','Pike','Liberal National Party of Queensland','Opposition Whip'),
    (17,'Braddon','TAS','2025-08-07T00:00:00Z','Rural','Ms','Anne','Urquhart','Australian Labor Party', NULL ),
    (18,'Bradfield','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Nicolette','Boele','Independent', NULL ),
    (19,'Brand','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Madeleine','King','Australian Labor Party','Minister for Resources; Minister for Northern Australia'),
    (20,'Brisbane','QLD','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Madonna','Jarrett','Australian Labor Party', NULL ),
    (21,'Bruce','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Julian','Hill','Australian Labor Party','Assistant Minister for Citizenship; Customs and Multicultural Affairs; Assistant Minister for International Education'),
    (22,'Bullwinkel','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Trish','Cook','Australian Labor Party', NULL ),
    (23,'Burt','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Matt','Keogh','Australian Labor Party','Minister for Defence Personnel; Minister for Veterans'' Affairs'),
    (24,'Calare','NSW','2025-08-07T00:00:00Z','Rural','Hon','Andrew','Gee','Independent', NULL ),
    (25,'Calwell','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Basem','Abdo','Australian Labor Party', NULL ),
    (26,'Canberra','ACT','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Alicia','Payne','Australian Labor Party', NULL ),
    (27,'Canning','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Andrew','Hastie','Liberal Party of Australia', NULL ),
    (28,'Capricornia','QLD','2025-08-07T00:00:00Z','Provincial','Hon','Michelle','Landry','Liberal National Party of Queensland','Chief Nationals Whip'),
    (29,'Casey','VIC','2025-08-07T00:00:00Z','Rural','Mr','Aaron','Violi','Liberal Party of Australia','Opposition Chief Whip'),
    (30,'Chifley','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Ed','Husic','Australian Labor Party','Chair of Standing Committee on Economics'),
    (31,'Chisholm','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Dr','Carina','Garland','Australian Labor Party','Chair of Standing Committee on Employment, Workplace Relations, Skills and Training'),
    (32,'Clark','TAS','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Andrew','Wilkie','Independent', NULL ),
    (33,'Cook','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Simon','Kennedy','Liberal Party of Australia','Deputy Chair of Standing Committee on Economics'),
    (34,'Cooper','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Ged','Kearney','Australian Labor Party','Assistant Minister for Social Services; Assistant Minister for the Prevention of Family Violence'),
    (35,'Corangamite','VIC','2025-08-07T00:00:00Z','Provincial','Ms','Libby','Coker','Australian Labor Party','Chair of Joint Standing Committee on the National Disability Insurance Scheme'),
    (36,'Corio','VIC','2025-08-07T00:00:00Z','Provincial','Hon','Richard','Marles','Australian Labor Party','Deputy Prime Minister; Minister for Defence'),
    (37,'Cowan','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Hon Dr','Anne','Aly','Australian Labor Party','Minister for Small Business; Minister for International Development; Minister for Multicultural Affairs'),
    (38,'Cowper','NSW','2025-08-07T00:00:00Z','Provincial','Mr','Pat','Conaghan','The Nationals', NULL ),
    (39,'Cunningham','NSW','2025-08-07T00:00:00Z','Provincial','Ms','Alison','Byrnes','Australian Labor Party', NULL ),
    (40,'Curtin','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Kate','Chaney','Independent', NULL ),
    (41,'Dawson','QLD','2025-08-07T00:00:00Z','Rural','Mr','Andrew','Willcox','Liberal National Party of Queensland','Deputy Chair of Parliamentary Standing Committee on Public Works'),
    (42,'Deakin','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Matt','Gregg','Australian Labor Party', NULL ),
    (43,'Dickson','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Ali','France','Australian Labor Party', NULL ),
    (44,'Dobell','NSW','2025-08-07T00:00:00Z','Provincial','Hon','Emma','McBride','Australian Labor Party','Assistant Minister for Mental Health and Suicide Prevention; Assistant Minister for Rural and Regional Health'),
    (45,'Dunkley','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Jodie','Belyea','Australian Labor Party', NULL ),
    (46,'Durack','WA','2025-08-07T00:00:00Z','Rural','Hon','Melissa','Price','Liberal Party of Australia', NULL ),
    (47,'Eden-Monaro','NSW','2025-08-07T00:00:00Z','Rural','Hon','Kristy','McBain','Australian Labor Party','Minister for Emergency Management; Minister for Regional Development; Local Government and Territories'),
    (48,'Fadden','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Cameron','Caldwell','Liberal National Party of Queensland','Opposition Whip; Deputy Chair of Joint Standing Committee on Migration'),
    (49,'Fairfax','QLD','2025-08-07T00:00:00Z','Rural','Mr','Ted','O''Brien','Liberal National Party of Queensland','Deputy Leader of the Opposition'),
    (50,'Farrer','NSW','2025-08-07T00:00:00Z','Rural','Hon','Sussan','Ley','Liberal Party of Australia','Leader of the Opposition'),
    (51,'Fenner','ACT','2025-08-07T00:00:00Z','Inner-metropolitan','Hon Dr','Andrew','Leigh','Australian Labor Party','Assistant Minister for Productivity; Competition; Charities and Treasury'),
    (52,'Fisher','QLD','2025-08-07T00:00:00Z','Rural','Mr','Andrew','Wallace','Liberal National Party of Queensland', NULL ),
    (53,'Flinders','VIC','2025-08-07T00:00:00Z','Rural','Ms','Zoe','McKenzie','Liberal Party of Australia','Deputy Chair of Joint Standing Committee on Treaties'),
    (54,'Flynn','QLD','2025-08-07T00:00:00Z','Rural','Mr','Colin','Boyce','Liberal National Party of Queensland', NULL ),
    (55,'Forde','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Rowan','Holzberger','Australian Labor Party', NULL ),
    (56,'Forrest','WA','2025-08-07T00:00:00Z','Rural','Mr','Ben','Small','Liberal Party of Australia', NULL ),
    (57,'Fowler','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Dai','Le','Independent', NULL ),
    (58,'Franklin','TAS','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Julie','Collins','Australian Labor Party','Minister for Agriculture; Fisheries and Forestry'),
    (59,'Fraser','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon Dr','Daniel','Mulino','Australian Labor Party','Assistant Treasurer; Minister for Financial Services'),
    (60,'Fremantle','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Josh','Wilson','Australian Labor Party','Assistant Minister for Climate Change and Energy; Assistant Minister for Emergency Management'),
    (61,'Gellibrand','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Tim','Watts','Australian Labor Party','Chair of Standing Committee on Education'),
    (62,'Gilmore','NSW','2025-08-07T00:00:00Z','Rural','Mrs','Fiona','Phillips','Australian Labor Party', NULL ),
    (63,'Gippsland','VIC','2025-08-07T00:00:00Z','Rural','Hon','Darren','Chester','The Nationals', NULL ),
    (64,'Goldstein','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Tim','Wilson','Liberal Party of Australia', NULL ),
    (65,'Gorton','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Alice','Jordan-Baird','Australian Labor Party', NULL ),
    (66,'Grayndler','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Anthony','Albanese','Australian Labor Party','Prime Minister'),
    (67,'Greenway','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Michelle','Rowland','Australian Labor Party','Attorney-General'),
    (68,'Grey','SA','2025-08-07T00:00:00Z','Rural','Mr','Tom','Venning','Liberal Party of Australia','Deputy Chair of Joint Standing Committee on Aboriginal and Torres Strait Islander Affairs'),
    (69,'Griffith','QLD','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Renee','Coffey','Australian Labor Party', NULL ),
    (70,'Groom','QLD','2025-08-07T00:00:00Z','Provincial','Mr','Garth','Hamilton','Liberal National Party of Queensland','Deputy Chair of Parliamentary Joint Committee on Corporations and Financial Services'),
    (71,'Hasluck','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Tania','Lawrence','Australian Labor Party', NULL ),
    (72,'Hawke','VIC','2025-08-07T00:00:00Z','Provincial','Hon','Sam','Rae','Australian Labor Party','Minister for Aged Care and Seniors'),
    (73,'Herbert','QLD','2025-08-07T00:00:00Z','Provincial','Mr','Phillip','Thompson','Liberal National Party of Queensland','OAM, Deputy Chair of Joint Standing Committee on Northern Australia'),
    (74,'Hindmarsh','SA','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Mark','Butler','Australian Labor Party','Minister for Disability and the National Disability Insurance Scheme; Minister for Health and Ageing; Deputy Leader of the House'),
    (75,'Hinkler','QLD','2025-08-07T00:00:00Z','Provincial','Mr','David','Batt','Liberal National Party of Queensland','Deputy Nationals Whip'),
    (76,'Holt','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Cassandra','Fernando','Australian Labor Party', NULL ),
    (77,'Hotham','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Clare','O''Neil','Australian Labor Party','Minister for Housing; Minister for Homelessness; Minister for Cities'),
    (78,'Hughes','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','David','Moncrieff','Australian Labor Party', NULL ),
    (79,'Hume','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Angus','Taylor','Liberal Party of Australia', NULL ),
    (80,'Hunter','NSW','2025-08-07T00:00:00Z','Rural','Mr','Dan','Repacholi','Australian Labor Party', NULL ),
    (81,'Indi','VIC','2025-08-07T00:00:00Z','Rural','Dr','Helen','Haines','Independent', NULL ),
    (82,'Isaacs','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Mark','Dreyfus','Australian Labor Party','KC'),
    (83,'Jagajaga','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Kate','Thwaites','Australian Labor Party', NULL ),
    (84,'Kennedy','QLD','2025-08-07T00:00:00Z','Rural','Hon','Bob','Katter','Katter''s Australian Party', NULL ),
    (85,'Kingsford Smith','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Matt','Thistlethwaite','Australian Labor Party','Assistant Minister for Immigration; Assistant Minister for Foreign Affairs and Trade'),
    (86,'Kingston','SA','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Amanda','Rishworth','Australian Labor Party','Minister for Employment and Workplace Relations'),
    (87,'Kooyong','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Dr','Monique','Ryan','Independent', NULL ),
    (88,'La Trobe','VIC','2025-08-07T00:00:00Z','Provincial','Hon','Jason','Wood','Liberal Party of Australia', NULL ),
    (89,'Lalor','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Joanne','Ryan','Australian Labor Party','Chief Government Whip'),
    (90,'Leichhardt','QLD','2025-08-07T00:00:00Z','Rural','Mr','Matt','Smith','Australian Labor Party', NULL ),
    (91,'Lilley','QLD','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Anika','Wells','Australian Labor Party','Minister for Communications; Minister for Sport'),
    (92,'Lindsay','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Mrs','Melissa','McIntosh','Liberal Party of Australia', NULL ),
    (93,'Lingiari','NT','2025-08-07T00:00:00Z','Rural','Ms','Marion','Scrymgour','Australian Labor Party','Chair of Joint Standing Committee on Northern Australia'),
    (94,'Longman','QLD','2025-08-07T00:00:00Z','Provincial','Mr','Terry','Young','Liberal National Party of Queensland','Second Deputy Speaker'),
    (95,'Lyne','NSW','2025-08-07T00:00:00Z','Rural','Ms','Alison','Penfold','The Nationals', NULL ),
    (96,'Lyons','TAS','2025-08-07T00:00:00Z','Rural','Hon','Rebecca','White','Australian Labor Party','Assistant Minister for Women; Assistant Minister for Indigenous Health; Assistant Minister for Health and Aged Care'),
    (97,'Macarthur','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Dr','Mike','Freelander','Australian Labor Party','Chair of Standing Committee on Health, Aged Care and Disability'),
    (98,'Mackellar','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Dr','Sophie','Scamps','Independent', NULL ),
    (99,'Macnamara','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Josh','Burns','Australian Labor Party','Chair of Joint Committee of Public Accounts and Audit'),
    (100,'Macquarie','NSW','2025-08-07T00:00:00Z','Provincial','Ms','Susan','Templeman','Australian Labor Party','Chair of House of Representatives Standing Committee on Communications, the Arts and Sport'),
    (101,'Makin','SA','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Tony','Zappia','Australian Labor Party','Chair of Parliamentary Standing Committee on Public Works'),
    (102,'Mallee','VIC','2025-08-07T00:00:00Z','Rural','Dr','Anne','Webster','The Nationals', NULL ),
    (103,'Maranoa','QLD','2025-08-07T00:00:00Z','Rural','Hon','David','Littleproud','Liberal National Party of Queensland','Leader of the Nationals'),
    (104,'Maribyrnong','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Jo','Briskey','Australian Labor Party', NULL ),
    (105,'Mayo','SA','2025-08-07T00:00:00Z','Rural','Ms','Rebekha','Sharkie','Centre Alliance', NULL ),
    (106,'McEwen','VIC','2025-08-07T00:00:00Z','Rural','Mr','Rob','Mitchell','Australian Labor Party','Chair of Standing Committee on Industry, Innovation and Science'),
    (107,'McMahon','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Chris','Bowen','Australian Labor Party','Minister for Climate Change and Energy'),
    (108,'McPherson','QLD','2025-08-07T00:00:00Z','Provincial','Mr','Leon','Rebello','Liberal National Party of Queensland','Deputy Chair of Parliamentary Joint Committee on Human Rights'),
    (109,'Melbourne','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Sarah','Witty','Australian Labor Party', NULL ),
    (110,'Menzies','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Gabriel','Ng','Australian Labor Party', NULL ),
    (111,'Mitchell','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Alex','Hawke','Liberal Party of Australia','Manager of Opposition Business'),
    (112,'Monash','VIC','2025-08-07T00:00:00Z','Rural','Ms','Mary','Aldred','Liberal Party of Australia','Deputy Chair of House of Representatives Standing Committee on Communications, the Arts and Sport'),
    (113,'Moncrieff','QLD','2025-08-07T00:00:00Z','Provincial','Ms','Angie','Bell','Liberal National Party of Queensland', NULL ),
    (114,'Moore','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Tom','French','Australian Labor Party', NULL ),
    (115,'Moreton','QLD','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Julie-Ann','Campbell','Australian Labor Party', NULL ),
    (116,'New England','NSW','2025-08-07T00:00:00Z','Rural','Hon','Barnaby','Joyce','The Nationals', NULL ),
    (117,'Newcastle','NSW','2025-08-07T00:00:00Z','Provincial','Ms','Sharon','Claydon','Australian Labor Party','Deputy Speaker'),
    (118,'Nicholls','VIC','2025-08-07T00:00:00Z','Rural','Mr','Sam','Birrell','The Nationals','Deputy Chair of Standing Committee on Education'),
    (119,'O''Connor','WA','2025-08-07T00:00:00Z','Rural','Mr','Rick','Wilson','Liberal Party of Australia', NULL ),
    (120,'Oxley','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Milton','Dick','Australian Labor Party','Speaker; Chair of Joint Committee on the Broadcasting of Parliamentary Proceedings; Chair of Selection Committee; Chair of Standing Committee on Appropriations and Administration'),
    (121,'Page','NSW','2025-08-07T00:00:00Z','Rural','Hon','Kevin','Hogan','The Nationals','Deputy Manager of Opposition Business; Deputy Leader of the National Party'),
    (122,'Parkes','NSW','2025-08-07T00:00:00Z','Rural','Mr','Jamie','Chaffey','The Nationals','Deputy Chair of Standing Committee on Primary Industries'),
    (123,'Parramatta','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon Dr','Andrew','Charlton','Australian Labor Party','Cabinet Secretary; Assistant Minister for Science, Technology and the Digital Economy'),
    (124,'Paterson','NSW','2025-08-07T00:00:00Z','Provincial','Ms','Meryl','Swanson','Australian Labor Party','Chair of Standing Committee on Primary Industries'),
    (125,'Pearce','WA','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Tracey','Roberts','Australian Labor Party', NULL ),
    (126,'Perth','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Patrick','Gorman','Australian Labor Party','Assistant Minister to the Prime Minister; Assistant Minister for the Public Service; Assistant Minister for Employment and Workplace Relations'),
    (127,'Petrie','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Emma','Comer','Australian Labor Party', NULL ),
    (128,'Rankin','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Hon Dr','Jim','Chalmers','Australian Labor Party', NULL ),
    (129,'Reid','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Sally','Sitou','Australian Labor Party', NULL ),
    (130,'Richmond','NSW','2025-08-07T00:00:00Z','Rural','Hon','Justine','Elliot','Australian Labor Party', NULL ),
    (131,'Riverina','NSW','2025-08-07T00:00:00Z','Rural','Hon','Michael','McCormack','The Nationals','Deputy Chair of Standing Committee on Industry, Innovation and Science'),
    (132,'Robertson','NSW','2025-08-07T00:00:00Z','Provincial','Dr','Gordon','Reid','Australian Labor Party', NULL ),
    (133,'Ryan','QLD','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Elizabeth','Watson-Brown','Australian Greens', NULL ),
    (134,'Scullin','VIC','2025-08-07T00:00:00Z','Outer-metropolitan','Hon','Andrew','Giles','Australian Labor Party','Minister for Skills and Training'),
    (135,'Shortland','NSW','2025-08-07T00:00:00Z','Provincial','Hon','Pat','Conroy','Australian Labor Party','Minister for Defence Industry; Minister for Pacific Island Affairs'),
    (136,'Solomon','NT','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Luke','Gosling','Australian Labor Party','OAM'),
    (137,'Spence','SA','2025-08-07T00:00:00Z','Outer-metropolitan','Mr','Matt','Burnell','Australian Labor Party', NULL ),
    (138,'Sturt','SA','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Claire','Clutterham','Australian Labor Party', NULL ),
    (139,'Swan','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Zaneta','Mascarenhas','Australian Labor Party','Chair of Parliamentary Joint Committee on Human Rights'),
    (140,'Sydney','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Tanya','Plibersek','Australian Labor Party','Minister for Social Services'),
    (141,'Tangney','WA','2025-08-07T00:00:00Z','Inner-metropolitan','Mr','Sam','Lim','Australian Labor Party', NULL ),
    (142,'Wannon','VIC','2025-08-07T00:00:00Z','Rural','Hon','Dan','Tehan','Liberal Party of Australia', NULL ),
    (143,'Warringah','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Zali','Steggall','Independent','OAM'),
    (144,'Watson','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Tony','Burke','Australian Labor Party','Minister for Home Affairs; Minister for the Arts; Minister for Cyber Security; Minister for Immigration and Citizenship; Leader of the House'),
    (145,'Wentworth','NSW','2025-08-07T00:00:00Z','Inner-metropolitan','Ms','Allegra','Spender','Independent', NULL ),
    (146,'Werriwa','NSW','2025-08-07T00:00:00Z','Outer-metropolitan','Ms','Anne','Stanley','Australian Labor Party','Government Whip; Chair of Joint Standing Committee on the Parliamentary Library'),
    (147,'Whitlam','NSW','2025-08-07T00:00:00Z','Provincial','Ms','Carol','Berry','Australian Labor Party', NULL ),
    (148,'Wide Bay','QLD','2025-08-07T00:00:00Z','Rural','Mr','Llew','O''Brien','Liberal National Party of Queensland','Deputy Chair of Parliamentary Joint Committee on Law Enforcement'),
    (149,'Wills','VIC','2025-08-07T00:00:00Z','Inner-metropolitan','Hon','Peter','Khalil','Australian Labor Party','Assistant Minister for Defence'),
    (150,'Wright','QLD','2025-08-07T00:00:00Z','Rural','Hon','Scott','Buchholz','Liberal National Party of Queensland', NULL ),
    (998,'Not Supplied / Unknown','XXX','2025-08-07T00:00:00Z', NULL
    ,NULL, NULL, NULL, NULL, NULL),
    (999,'Not Applicable','XXX','2025-08-07T00:00:00Z', NULL
    ,NULL, NULL, NULL, NULL, NULL);
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0FederalElectorateList';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolSectorCode (
     [TypeKey] VARCHAR (3) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolSectorCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolSectorCode';
INSERT INTO cdm_demo_gold.Dim0SchoolSectorCode ([TypeKey], [TypeValue]) VALUES
    ('Gov', 'Government School'),
    ('NG', 'Non-Government School');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolSectorCode';
GO

CREATE TABLE cdm_demo_gold.Dim0SystemicStatus (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SystemicStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SystemicStatus';
INSERT INTO cdm_demo_gold.Dim0SystemicStatus ([TypeKey], [TypeValue]) VALUES
    ('N', 'Non-systemic'),
    ('S', 'Systemic');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SystemicStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolSystemType (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolSystemType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolSystemType';
INSERT INTO cdm_demo_gold.Dim0SchoolSystemType ([TypeKey], [TypeValue]) VALUES
    ('0001', 'Catholic'),
    ('0002', 'Anglican'),
    ('0003', 'Lutheran'),
    ('0004', 'Seventh Day Adventist'),
    ('9999', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolSystemType';
GO

CREATE TABLE cdm_demo_gold.Dim0SchoolGeographicLocationType (
     [TypeKey] VARCHAR (5) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolGeographicLocationType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolGeographicLocationType';
INSERT INTO cdm_demo_gold.Dim0SchoolGeographicLocationType ([TypeKey], [TypeValue]) VALUES
    ('1', 'Metropolitan Zone'),
    ('1.1', 'State Capital regions - State Capitals (except Hobart, Darwin)'),
    ('1.2', 'Major urban Statistical Districts (Pop >=100 000)'),
    ('2', 'Provincial Zone'),
    ('3', 'Remote Zone'),
    ('10', 'Major Cities of Australia - New South Wales'),
    ('11', 'Inner Regional Australia - New South Wales'),
    ('12', 'Outer Regional Australia - New South Wales'),
    ('13', 'Remote Australia - New South Wales'),
    ('14', 'Very Remote Australia - New South Wales'),
    ('15', 'Migratory - Offshore - Shipping (NSW)'),
    ('19', 'No usual address (NSW)'),
    ('2.1.1', 'Provincial City Statistical Districts (Pop 50 000 - 99 999)'),
    ('2.1.2', 'Provincial City Statistical Districts (Pop 25 000 - 49 999)'),
    ('2.2.1', 'Inner Provincial areas (CD ARIA Plus score <= 2.4)'),
    ('2.2.2', 'Outer Provincial areas (CD ARIA Plus score > 2.4 and <= 5.92)'),
    ('20', 'Major Cities of Australia - Victoria'),
    ('21', 'Inner Regional Australia - Victoria'),
    ('22', 'Outer Regional Australia - Victoria'),
    ('23', 'Remote Australia - Victoria'),
    ('25', 'Migratory - Offshore - Shipping (Vic.)'),
    ('29', 'No usual address (Vic.)'),
    ('3.1', 'Remote areas (CD ARIA Plus score > 5.92 and <= 10.53)'),
    ('3.2', 'Very Remote areas (CD ARIA Plus score > 10.53)'),
    ('30', 'Major Cities of Australia - Queensland'),
    ('31', 'Inner Regional Australia - Queensland'),
    ('32', 'Outer Regional Australia - Queensland'),
    ('33', 'Remote Australia - Queensland'),
    ('34', 'Very Remote Australia - Queensland'),
    ('35', 'Migratory - Offshore - Shipping (Qld)'),
    ('39', 'No usual address (Qld)'),
    ('40', 'Major Cities of Australia - South Australia'),
    ('41', 'Inner Regional Australia - South Australia'),
    ('42', 'Outer Regional Australia - South Australia'),
    ('43', 'Remote Australia - South Australia'),
    ('44', 'Very Remote Australia - South Australia'),
    ('45', 'Migratory - Offshore - Shipping (SA)'),
    ('49', 'No usual address (SA)'),
    ('50', 'Major Cities of Australia - Western Australia'),
    ('51', 'Inner Regional Australia - Western Australia'),
    ('52', 'Outer Regional Australia - Western Australia'),
    ('53', 'Remote Australia - Western Australia'),
    ('54', 'Very Remote Australia - Western Australia'),
    ('55', 'Migratory - Offshore - Shipping (WA)'),
    ('59', 'No usual address (WA)'),
    ('61', 'Inner Regional Australia - Tasmania'),
    ('62', 'Outer Regional Australia - Tasmania'),
    ('63', 'Remote Australia - Tasmania'),
    ('64', 'Very Remote Australia - Tasmania'),
    ('65', 'Migratory - Offshore - Shipping (Tas.)'),
    ('69', 'No usual address (Tas.)'),
    ('72', 'Outer Regional Australia - Northern Territory'),
    ('73', 'Remote Australia - Northern Territory'),
    ('74', 'Very Remote Australia - Northern Territory'),
    ('75', 'Migratory - Offshore - Shipping (NT)'),
    ('79', 'No usual address (NT)'),
    ('80', 'Major Cities of Australia - Australian Capital Territory'),
    ('81', 'Inner Regional Australia - Australian Capital Territory'),
    ('85', 'Migratory - Offshore - Shipping (ACT)'),
    ('89', 'No usual address (ACT)'),
    ('91', 'Inner Regional Australia'),
    ('94', 'Very Remote Australia'),
    ('95', 'Migratory - Offshore - Shipping (OT) Other Territories'),
    ('99', 'No usual address (OT) Other Territories');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolGeographicLocationType';

CREATE TABLE cdm_demo_gold.Dim0SchoolCoEdStatus (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_SchoolCoEdStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0SchoolCoEdStatus';
INSERT INTO cdm_demo_gold.Dim0SchoolCoEdStatus ([TypeKey], [TypeValue]) VALUES
    ('C', 'Co-Educational'),
    ('F', 'Female'),
    ('M', 'Male');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0SchoolCoEdStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0AusTimeZoneList (
     [TimeZoneCode] VARCHAR (5) NOT NULL,
     [TimeZoneName] VARCHAR (63) NOT NULL,
     [TimeOffset] VARCHAR (63) NULL,
     [DisplayOrder] SMALLINT NULL,
     CONSTRAINT [PK_AusTimeZoneList] PRIMARY KEY ([TimeZoneCode]),
);
PRINT N'Created cdm_demo_gold.Dim0AusTimeZoneList';
INSERT INTO cdm_demo_gold.Dim0AusTimeZoneList ([TimeZoneCode],[TimeZoneName],[TimeOffset],[DisplayOrder]) VALUES
    ('AEST','Australian Eastern Standard Time','UTC +10:00',1),
    ('AET','Australian Eastern Time','UTC +10:00 / +11:00',2),
    ('AEDT','Australian Eastern Daylight Time','UTC +11:)0',3),
    ('ACST','Australian Central Standard Time','UTC +9:30',4),
    ('ACDT','Australian Central Daylight Time','UTC +10:30',5),
    ('ACT','Australian Central Time','UTC +9:30 / +10:30',6),
    ('AWST','Australian Western Standard Time','UTC +8:00',7),
    ('ACWST','Australian Central Western Standard Time','UTC +8:45',8),
    ('AWDT','Australian Western Daylight Time','UTC +9:00',9),
    ('LHDT','Lord Howe Daylight Time','UTC +11:00',10),
    ('LHST','Lord Howe Standard Time','UTC +10:30',11),
    ('NFT','Norfolk Time','UTC +11:00 / +12:00',12),
    ('CXT','Christmas Island Time','UTC +7:00',13),
    ('Other','Other Time Zone not defined', NULL ,14);
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AusTimeZoneList';
GO

-- Identity Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0PartyType (
     [TypeKey] VARCHAR (14) NOT NULL
     CONSTRAINT [PK_PartyType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PartyType';
INSERT INTO cdm_demo_gold.Dim0PartyType ([TypeKey]) VALUES
    ('Staff'),
    ('Student'),
    ('StudentContact');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PartyType';
GO

CREATE TABLE cdm_demo_gold.Dim0AuthenticationSource (
     [TypeKey] VARCHAR (63) NOT NULL
     CONSTRAINT [PK_AuthenticationSource] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AuthenticationSource';
INSERT INTO cdm_demo_gold.Dim0AuthenticationSource ([TypeKey]) VALUES
    ('AUAccessShibboleth'),
    ('MSActiveDirectory'),
    ('NovellNDS'),
    ('OpenDirectory'),
    ('OpenID'),
    ('Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AuthenticationSource';
GO

CREATE TABLE cdm_demo_gold.Dim0EncryptionAlgorithm (
     [TypeKey] VARCHAR (16) NOT NULL
     CONSTRAINT [PK_EncryptionAlgorithm] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EncryptionAlgorithm';
INSERT INTO cdm_demo_gold.Dim0EncryptionAlgorithm ([TypeKey]) VALUES
    ('MD5'),
    ('SHA1'),
    ('DES'),
    ('TripleDES'),
    ('RC2'),
    ('AES'),
    ('RSA');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EncryptionAlgorithm';
GO

-- PersonPicture Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0PermissionCategoryCode (
     [TypeKey] VARCHAR (32) NOT NULL
     CONSTRAINT [PK_PermissionCategoryCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PermissionCategoryCode';
INSERT INTO cdm_demo_gold.Dim0PermissionCategoryCode ([TypeKey]) VALUES
    ('Jurisdiction Educational'),
    ('Jurisdiction Promotional'),
    ('OKMediaRelease'),
    ('OKOnlineMaterial'),
    ('OKOnLineServices'),
    ('OKPrintedMaterial'),
    ('OKPublishInfo'),
    ('School/College Newsletter'),
    ('School/College Yearbook');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PermissionCategoryCode';
GO

-- PersonPrivacy Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0PermissionYesNoType (
     [TypeKey] CHAR (1) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_PermissionYesNoType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PermissionYesNoType';
INSERT INTO cdm_demo_gold.Dim0PermissionYesNoType ([TypeKey], [TypeValue]) VALUES
    ('N', 'No'),
    ('U', 'Unknown'),
    ('Y', 'Yes');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PermissionYesNoType';
GO

-- StaffAssignment Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0StaffActivity (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_StaffActivity] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StaffActivity';
INSERT INTO cdm_demo_gold.Dim0StaffActivity ([TypeKey], [TypeValue]) VALUES
    ('1100', 'Teacher in school n.f.d.'),
    ('1101', 'Primary Teacher'),
    ('1102', 'Secondary teacher'),
    ('1103', 'Principal'),
    ('1104', 'Special School Teacher'),
    ('1105', 'Assistant Principal'),
    ('1106', 'Teacher Librarian'),
    ('1107', 'Primary/Secondary Combined Teacher'),
    ('1199', 'Other Teacher In School'),
    ('1200', 'Specialist support in school n.f.d.'),
    ('1201', 'Nurse'),
    ('1202', 'Physiotherapist'),
    ('1203', 'Speech Therapist'),
    ('1204', 'Guidance Officer'),
    ('1205', 'Psychologist'),
    ('1206', 'Social worker'),
    ('1207', 'Student welfare worker'),
    ('1208', 'Indigenous Education Worker'),
    ('1299', 'Other Specialist support in school'),
    ('1300', 'Administration and clerical in school n.f.d.'),
    ('1301', 'Teacher Aide'),
    ('1302', 'Librarian - in school Administration'),
    ('1303', 'Office Manager'),
    ('1304', 'Clerical/Administrative officer'),
    ('1305', 'Clerical/Administrative assistant'),
    ('1306', 'Laboratory assistant'),
    ('1307', 'ICT Officer'),
    ('1399', 'Other Administration and clerical in school'),
    ('1400', 'Building Operations in school n.f.d.'),
    ('1401', 'Building maintenance worker - in school'),
    ('1402', 'Gardener - in school'),
    ('1403', 'Canteen assistant - in school'),
    ('1404', 'Farm Worker - in school'),
    ('1405', 'Bus Driver - in school'),
    ('1406', 'Caretaker - in school'),
    ('1499', 'Other Building Operations and general maintenance - In school'),
    ('1999', 'In School Staff out of scope'),
    ('2100', 'Executive n.f.d.'),
    ('2101', 'Chief Executive'),
    ('2102', 'Deputy Chief Executive'),
    ('2103', 'General Manager'),
    ('2198', 'Principal and other School Executive out of school'),
    ('2199', 'Other Executive'),
    ('2200', 'Specialist support out of scope n.f.d.'),
    ('2201', 'Community Participation Officer'),
    ('2202', 'Computer Support Officer'),
    ('2203', 'Coordinator - out of school Specialist Support'),
    ('2204', 'Curriculum Officer'),
    ('2205', 'Curriculum Program Manager'),
    ('2206', 'Education Officer - out of school Specialist Support'),
    ('2207', 'Education Program Manager'),
    ('2208', 'Home Liaison Officer'),
    ('2209', 'Learning Support Leader'),
    ('2210', 'Librarian - out of school Specialist Support'),
    ('2211', 'Moderator'),
    ('2212', 'Occupational Therapist'),
    ('2213', 'On-line Education Officer'),
    ('2214', 'Policy Officer - out of school Specialist Support'),
    ('2215', 'Principal Education Officer'),
    ('2216', 'Professional Services Officer'),
    ('2217', 'Project Coordinator'),
    ('2218', 'Registered Nurse'),
    ('2219', 'Senior Education Officer'),
    ('2220', 'Social Welfare Officer'),
    ('2221', 'Speech Language Pathologist'),
    ('2222', 'Sports Coordinator'),
    ('2223', 'Staff Development Officer'),
    ('2224', 'Training Officer - out of school Specialist Support'),
    ('2298', 'Teachers - out of school Specialist Support'),
    ('2299', 'Other specialist support out of school'),
    ('2300', 'Administration and clerical out of school n.f.d.'),
    ('2301', 'Accounts Certifying Officer'),
    ('2302', 'Administrative and Clerical officer'),
    ('2303', 'Administrative Assistant'),
    ('2304', 'Administrative Officer'),
    ('2305', 'Budget Officer'),
    ('2306', 'Clerk'),
    ('2307', 'Finance and Administration Officer'),
    ('2308', 'Finance Officer'),
    ('2309', 'General Ledger Officer'),
    ('2310', 'Receptionist'),
    ('2311', 'Senior Auditor'),
    ('2312', 'Services Clerk'),
    ('2313', 'Aboriginal Education Coordinator'),
    ('2314', 'Aboriginal Education Worker'),
    ('2315', 'Assistant Manager'),
    ('2316', 'Client Services Officer'),
    ('2317', 'Coordinator - out of school Administration'),
    ('2318', 'District Officer'),
    ('2319', 'Education Officer - out of school Administration'),
    ('2320', 'Enrolment Officer'),
    ('2321', 'Examiner'),
    ('2322', 'Liaison Officer'),
    ('2323', 'Librarian - out of school Administration'),
    ('2324', 'Library Technician'),
    ('2325', 'Manager'),
    ('2326', 'Operational Services Officer'),
    ('2327', 'Professional Officers'),
    ('2328', 'Program Coordinator'),
    ('2329', 'Project Manager'),
    ('2330', 'Project Officer'),
    ('2331', 'Project Support Officer'),
    ('2332', 'Public Servant'),
    ('2333', 'School Services Officer'),
    ('2334', 'School Support Officer'),
    ('2335', 'Senior Investigator'),
    ('2336', 'Senior Professional Officers'),
    ('2337', 'Senior Project Officer/Project Officer'),
    ('2338', 'Student Services co ordinator'),
    ('2339', 'Student Support Officer'),
    ('2340', 'Assistant Editor'),
    ('2341', 'Communications Officer'),
    ('2342', 'Corporate Services Officer'),
    ('2343', 'Designer'),
    ('2344', 'Desktop Publisher'),
    ('2345', 'Editor'),
    ('2346', 'Graphic Designer'),
    ('2347', 'Journalist/Media and Marketing'),
    ('2348', 'Photographer'),
    ('2349', 'Printer'),
    ('2350', 'Production Officer/Coordinator'),
    ('2351', 'Public Relations Officer'),
    ('2352', 'Advisor'),
    ('2353', 'Executive Assistant'),
    ('2354', 'Executive Officer'),
    ('2355', 'Executive Secretary'),
    ('2356', 'Personal Assistant'),
    ('2357', 'Secretary'),
    ('2358', 'Human Resources Services Officer'),
    ('2359', 'Personnel (and Payroll) Officer'),
    ('2360', 'Personnel Officer'),
    ('2361', 'Recruitment Officer'),
    ('2362', 'Training Officer - out of school Administration'),
    ('2363', 'Workers Compensation Officer'),
    ('2364', 'Workforce Management Officer'),
    ('2365', 'Audio Visual Communications Program Officer'),
    ('2366', 'Business Systems Analyst'),
    ('2367', 'Computer Systems Officer'),
    ('2368', 'Computer Technician'),
    ('2369', 'Data Management Officer'),
    ('2370', 'Information Analyst'),
    ('2371', 'Information Manager'),
    ('2372', 'Information Officer'),
    ('2373', 'Information Technology Officers'),
    ('2374', 'Network Administrator'),
    ('2375', 'Policy Officer n.f.d.'),
    ('2376', 'Performance Measurement Officer'),
    ('2377', 'Policy Officer - out of school Administration'),
    ('2378', 'Research Officer'),
    ('2379', 'Review Officer'),
    ('2380', 'Senior Research Officer/Research Officer'),
    ('2381', 'Other policy officer'),
    ('2382', 'Despatch Officer'),
    ('2383', 'Driver'),
    ('2384', 'Facilities Services Officer'),
    ('2385', 'Housing and Transport Officer'),
    ('2386', 'Indexer'),
    ('2387', 'Legal Officer'),
    ('2388', 'Store Person'),
    ('2389', 'Store Supervisor'),
    ('2390', 'Supply Officer'),
    ('2391', 'Team Leader'),
    ('2392', 'Technical Officer - out of school Administration'),
    ('2393', 'Technician'),
    ('2394', 'Transport Officer'),
    ('2397', 'Public service officers n.f.d.'),
    ('2398', 'Teachers - Out of School Administration'),
    ('2399', 'Other Administration and clerical out of school'),
    ('2400', 'Building Operations out of school n.f.d.'),
    ('2401', 'Building maintenance worker - out of school'),
    ('2402', 'Bus Driver - out of school'),
    ('2403', 'Canteen assistant - out of school'),
    ('2404', 'Caretaker - out of school'),
    ('2405', 'Cook'),
    ('2406', 'Courier'),
    ('2407', 'Farm Worker - out of school'),
    ('2408', 'Gardener - out of school'),
    ('2409', 'Greenkeeper'),
    ('2410', 'Groundsman'),
    ('2411', 'Handyman'),
    ('2412', 'House Officer'),
    ('2413', 'Janitor'),
    ('2414', 'Kitchen Hand'),
    ('2415', 'Maintenance Officer'),
    ('2416', 'School Attendant'),
    ('2417', 'Security Officer'),
    ('2418', 'Technical Officer - out of school Building Operations'),
    ('2499', 'Other Building Operations and general maintenance out of school'),
    ('2999', 'Out of School Staff out of scope');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StaffActivity';
GO

-- StudentContactRelationship Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0RelationshipToStudentType (
     [TypeKey] CHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_RelationshipToStudentType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0RelationshipToStudentType';
INSERT INTO cdm_demo_gold.Dim0RelationshipToStudentType ([TypeKey], [TypeValue]) VALUES
    ('00', 'Spouse/Partner (expected to be rare)'),
    ('01', 'Parent'),
    ('02', 'Step-Parent'),
    ('03', 'Adoptive Parent (DEPRECATED: 01 Parent is preferred)'),
    ('04', 'Foster Parent'),
    ('05', 'Host Family'),
    ('06', 'Relative'),
    ('07', 'Friend'),
    ('08', 'Self'),
    ('09', 'Other'),
    ('10', 'Sibling'),
    ('11', 'Grandparent'),
    ('12', 'Aunt/Uncle'),
    ('13', 'Nephew/Niece'),
    ('14', 'Step-Sibling'),
    ('20', 'Guardian'),
    ('30', 'Case Worker'),
    ('31', 'Supervisor'),
    ('32', 'Duty Manager'),
    ('40', 'Medical Contact'),
    ('99', 'Not provided');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0RelationshipToStudentType';
GO

CREATE TABLE cdm_demo_gold.Dim0ParentRelationshipStatus (
     [TypeKey] VARCHAR (15) NOT NULL
     CONSTRAINT [PK_ParentRelationshipStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ParentRelationshipStatus';
INSERT INTO cdm_demo_gold.Dim0ParentRelationshipStatus ([TypeKey]) VALUES
    ('Parent1'),
    ('Parent2'),
    ('NotForReporting');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ParentRelationshipStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0ContactSourceType (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_ContactSourceType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ContactSourceType';
INSERT INTO cdm_demo_gold.Dim0ContactSourceType ([TypeKey], [TypeValue]) VALUES
    ('C', 'Provided by the child (ie pupil)'),
    ('O', 'Other'),
    ('P', 'Provided by the parent'),
    ('S', 'Ascribed by the current school'),
    ('T', 'Ascribed by a previous school');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ContactSourceType';
GO

CREATE TABLE cdm_demo_gold.Dim0ContactMethod (
     [TypeKey] VARCHAR (12) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_ContactMethod] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ContactMethod';
INSERT INTO cdm_demo_gold.Dim0ContactMethod ([TypeKey], [TypeValue]) VALUES
    ('AltMailing', 'Postal, using alternate mailing address on file'),
    ('Email', 'Email'),
    ('Mailing', 'Postal, using main mailing address on file'),
    ('ParentPortal', 'Contact via Parent Portal'),
    ('Phone', 'Phone');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ContactMethod';
GO

CREATE TABLE cdm_demo_gold.Dim0CodesetForOtherCodeListType (
     [TypeKey] VARCHAR (13) NOT NULL
     CONSTRAINT [PK_CodesetForOtherCodeListType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0CodesetForOtherCodeListType';
INSERT INTO cdm_demo_gold.Dim0CodesetForOtherCodeListType ([TypeKey]) VALUES
    ('StateProvince'),
    ('Local'),
    ('Other'),
    ('Text');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0CodesetForOtherCodeListType';
GO

-- StudentSchoolEnrollment Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0EnrollmentTimeFrame (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_EnrollmentTimeFrame] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EnrollmentTimeFrame';
INSERT INTO cdm_demo_gold.Dim0EnrollmentTimeFrame ([TypeKey], [TypeValue]) VALUES
    ('C', 'Current'),
    ('F', 'Future'),
    ('H', 'Historic');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EnrollmentTimeFrame';
GO

CREATE TABLE cdm_demo_gold.Dim0EnrollmentEntryType (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EnrollmentEntryType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EnrollmentEntryType';
INSERT INTO cdm_demo_gold.Dim0EnrollmentEntryType ([TypeKey], [TypeValue]) VALUES
    ('0997', 'Transfer from a different campus of the same school'),
    ('0998', 'Temporary enrolment'),
    ('1821', 'Transfer from a public school in the same district'),
    ('1822', 'Transfer from a public school in a different district in the same jurisdiction'),
    ('1823', 'Transfer from a public school in a different jurisdiction'),
    ('1824', 'Transfer from a private, non-religiously-affiliated school in the same district'),
    ('1825', 'Transfer from a private, non-religiously-affiliated school in a different district'),
    ('1826', 'Transfer from a private, non-religiously-affiliated school in a different jurisdiction'),
    ('1827', 'Transfer from a private, religiously-affiliated school in the same district'),
    ('1828', 'Transfer from a private, religiously-affiliated school in a different district in the same jurisdiction'),
    ('1829', 'Transfer from a private, religiously-affiliated school in a different jurisdiction'),
    ('1830', 'Transfer from a school outside of the country'),
    ('1831', 'Transfer from an institution'),
    ('1833', 'Transfer from home schooling'),
    ('1835', 'Re-entry from the same school with no interruption of schooling'),
    ('1836', 'Re-entry after a voluntary withdrawal'),
    ('1837', 'Re-entry after an involuntary withdrawal'),
    ('1838', 'Original entry into an Australian school'),
    ('1839', 'Original entry into an Australian school from a foreign country with no interruption in schooling'),
    ('1840', 'Original entry into an Australian school from a foreign country with an interruption in schooling'),
    ('1841', 'Entry into Intensive English Centre'),
    ('9999', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EnrollmentEntryType';
GO

CREATE TABLE cdm_demo_gold.Dim0EnrollmentExitWithdrawalType (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EnrollmentExitWithdrawalType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EnrollmentExitWithdrawalType';
INSERT INTO cdm_demo_gold.Dim0EnrollmentExitWithdrawalType ([TypeKey], [TypeValue]) VALUES
    ('1907', 'Student is in a different public school in the same district'),
    ('1908', 'Transferred to a public school in a different local education agency in the same jurisdiction'),
    ('1909', 'Transferred to a public school in a different jurisdiction'),
    ('1910', 'Transferred to a private, non-religiously-affiliated school in the district'),
    ('1911', 'Transferred to a private, non-religiously-affiliated school in a different district in the same jurisdiction'),
    ('1912', 'Transferred to a private, non-religiously-affiliated school in a different jurisdiction'),
    ('1913', 'Transferred to a private, religiously-affiliated school in the same district'),
    ('1914', 'Transferred to a private, religiously-affiliated school in a different district in the same jurisdiction'),
    ('1915', 'Transferred to a private, religiously-affiliated school in a different jurisdiction'),
    ('1916', 'Transferred to a school outside of the country'),
    ('1917', 'Transferred to an institution'),
    ('1918', 'Transferred to home schooling'),
    ('1919', 'Transferred to a charter school'),
    ('1921', 'Graduated with regular, advanced, International Baccalaureate, or other type of diploma'),
    ('1922', 'Completed school with other credentials'),
    ('1923', 'Died or is permanently incapacitated'),
    ('1924', 'Withdrawn due to illness'),
    ('1925', 'Expelled, Excluded or involuntarily withdrawn'),
    ('1926', 'Reached maximum age for services'),
    ('1927', 'Discontinued schooling'),
    ('1928', 'Completed grade 12, but did not meet all graduation requirements'),
    ('1930', 'Enrolled in a postsecondary early admission program, eligible to return'),
    ('1931', 'Not enrolled, unknown status'),
    ('1940', 'Deceased'),
    ('1941', 'Permanently incapacitated'),
    ('3499', 'Student is in the same local education agency and receiving education services, but is not assigned'),
    ('3500', 'Enrolled in an adult education or training program'),
    ('3501', 'Completed a state-recognized vocational education program'),
    ('3502', 'Not enrolled, eligible to return'),
    ('3503', 'Enrolled in a foreign exchange program, eligible to return'),
    ('3504', 'Withdrawn from school, under the age for compulsory attendance; eligible to return'),
    ('3505', 'Exited'),
    ('3509', 'Completed with a state-recognized equivalency certificate'),
    ('9998', 'Transferred to a different campus of the same school'),
    ('9999', 'Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EnrollmentExitWithdrawalType';
GO

CREATE TABLE cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_EnrollmentExitWithdrawalStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus';
INSERT INTO cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus ([TypeKey], [TypeValue]) VALUES
    ('1905', 'Permanent exit/withdrawal'),
    ('1906', 'Temporary exit/withdrawal'),
    ('9999', 'Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField (
     [TypeKey] VARCHAR (16) NOT NULL
    ,CONSTRAINT [PK_StudentSchoolEnrollmentOtherCodeField] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField';
INSERT INTO cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField ([TypeKey]) VALUES
    ('EntryCode'),
    ('ExitCode'),
    ('ExitStatus'),
    ('CatchmentStatus');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField';
GO

CREATE TABLE cdm_demo_gold.Dim0FullTimePartTimeStatusCode (
     [TypeKey] VARCHAR (2) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_FullTimePartTimeStatusCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0FullTimePartTimeStatusCode';
INSERT INTO cdm_demo_gold.Dim0FullTimePartTimeStatusCode ([TypeKey], [TypeValue]) VALUES
    ('01', 'Full Time'),
    ('02', 'Part Time'),
    ('9', 'Not stated/inadequately described');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0FullTimePartTimeStatusCode';
GO

CREATE TABLE cdm_demo_gold.Dim0PublicSchoolCatchmentStatus (
     [TypeKey] CHAR (4) NOT NULL,
     [TypeValue] VARCHAR (255) NULL,
     CONSTRAINT [PK_PublicSchoolCatchmentStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0PublicSchoolCatchmentStatus';
INSERT INTO cdm_demo_gold.Dim0PublicSchoolCatchmentStatus ([TypeKey], [TypeValue]) VALUES
    ('1652', 'Resident of usual school catchment area'),
    ('1653', 'Resident of another school catchment area'),
    ('9999', 'Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0PublicSchoolCatchmentStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason (
     [TypeKey] VARCHAR (23) NOT NULL
    ,CONSTRAINT [PK_StudentSchoolEnrollmentRecordClosureReason] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason';
INSERT INTO cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason ([TypeKey]) VALUES
    ('SchoolExit'),
    ('TimeDependentDataChange'),
    ('EndOfYear'),
    ('CampusExit');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason';
GO

CREATE TABLE cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus (
     [TypeKey] VARCHAR (8) NOT NULL
    ,CONSTRAINT [PK_StudentSchoolEnrollmentPromotionStatus] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus';
INSERT INTO cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus ([TypeKey]) VALUES
    ('Promoted'),
    ('Demoted'),
    ('Retained'),
    ('NA');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus';
GO

CREATE TABLE cdm_demo_gold.Dim0TravelMode (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_TravelMode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0TravelMode';
INSERT INTO cdm_demo_gold.Dim0TravelMode ([TypeKey], [TypeValue]) VALUES
    ('A', 'Walks between home or a carers'' residence and school'),
    ('B', 'Rides a bicycle or scooter between home or carer''s place and school'),
    ('C', 'Driven by car/motor vehicle between home or a carers'' residence and school'),
    ('D', 'Bus to/from school gates (mostly by bus, remainder on foot)'),
    ('E', 'Tram to/from near school (mostly by tram, remainder on foot)'),
    ('F', 'Train to/from near the school (mostly by train, remainder on foot)'),
    ('G', 'Combination of car and public transport'),
    ('H', 'Combinations of public transport such as train and bus, or train and tram'),
    ('I', 'Taxi or other modes');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0TravelMode';
GO

CREATE TABLE cdm_demo_gold.Dim0TravelAccompaniment (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_TravelAccompaniment] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0TravelAccompaniment';
INSERT INTO cdm_demo_gold.Dim0TravelAccompaniment ([TypeKey], [TypeValue]) VALUES
    ('A', 'Adult Accompaniment'),
    ('I', 'Independent'),
    ('U', 'Unknown');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0TravelAccompaniment';
GO

CREATE TABLE cdm_demo_gold.Dim0StudentGroupCategoryCode (
     [TypeKey] VARCHAR (16) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_StudentGroupCategoryCode] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0StudentGroupCategoryCode';
INSERT INTO cdm_demo_gold.Dim0StudentGroupCategoryCode ([TypeKey], [TypeValue]) VALUES
    ('RollGroup', 'Roll Group'),
    ('MentorGroup', 'Mentor Group'),
    ('PastoralGroup', 'Pastoral Group'),
    ('AfterSchoolGroup', 'After School Group'),
    ('OtherGroup', 'Other Group');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0StudentGroupCategoryCode';
GO

-- LearningResourcePackage Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0AbstractContentType (
     [TypeKey] VARCHAR (6) NOT NULL
    ,CONSTRAINT [PK_AbstractContentType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AbstractContentType';
INSERT INTO cdm_demo_gold.Dim0AbstractContentType ([TypeKey]) VALUES
    ('XML'),
    ('Text'),
    ('Binary'),
    ('URL');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AbstractContentType';
GO

CREATE TABLE cdm_demo_gold.Dim0AustralianCurriculumStrand (
     [TypeKey] CHAR (1) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_AustralianCurriculumStrand] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0AustralianCurriculumStrand';
INSERT INTO cdm_demo_gold.Dim0AustralianCurriculumStrand ([TypeKey], [TypeValue]) VALUES
    ('A', 'The arts'),
    ('B', 'Economics and business'),
    ('C', 'Civics and citizenship'),
    ('D', 'Design and technologies'),
    ('E', 'English'),
    ('G', 'Geography'),
    ('H', 'History'),
    ('I', 'Digital technologies'),
    ('L', 'Languages'),
    ('M', 'Mathematics'),
    ('P', 'Health and physical education'),
    ('S', 'Science'),
    ('T', 'Technologies'),
    ('U', 'Humanities and social sciences'),
    ('W', 'Work Studies'),
    ('R', 'Religious Studies'), -- Added value not part of http://vocabulary.esa.edu.au/framework/
    ('O', 'Other'); -- Added value not part of http://vocabulary.esa.edu.au/framework/
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0AustralianCurriculumStrand';
GO

-- EquipmentInfo Dim0 items from here

CREATE TABLE cdm_demo_gold.Dim0EquipmentType (
     [TypeKey] VARCHAR (17) NOT NULL
    ,[TypeValue] VARCHAR (255) NULL
    ,CONSTRAINT [PK_EquipmentType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0EquipmentType';
INSERT INTO cdm_demo_gold.Dim0EquipmentType ([TypeKey], [TypeValue]) VALUES
    ('DesktopComputer', 'Desktop Computer'),
    ('LaptopComputer', 'Laptop Computer'),
    ('Other', 'Other'),
    ('OverheadProjector', 'Overhead Projector'),
    ('SlideProjector', 'Slide Projector'),
    ('Tablet', 'Tablet'),
    ('Vehicle', 'Vehicle');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0EquipmentType';
GO

CREATE TABLE cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject (
     [TypeKey] VARCHAR (16) NOT NULL
    ,CONSTRAINT [PK_OwnerOrLocationSIF_RefObject] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject';
INSERT INTO cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject ([TypeKey]) VALUES
    ('SchoolInfo'),
    ('RoomInfo'),
    ('LEAInfo'),
    ('StaffPersonal'),
    ('Other');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject';
GO

CREATE TABLE cdm_demo_gold.Dim0ResourceType (
     [TypeKey] VARCHAR (16) NOT NULL
     CONSTRAINT [PK_ResourceType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0ResourceType';
INSERT INTO cdm_demo_gold.Dim0ResourceType ([TypeKey]) VALUES
    ('EquipmentInfo'),
    ('LearningResource'),
    ('RoomInfo');
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0ResourceType';
GO





-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 1 in name may have FKs to tables with 0            --
-- -------------------------------------------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim1Country (
     [LocalId] VARCHAR (5) NOT NULL
    ,[NatCode] CHAR (4) NULL
    ,[InActive] BIT NULL
    ,[CountryName] VARCHAR (255) NULL
    ,[CountryRecordComment] VARCHAR (255) NULL
    ,[DisplayOrder] INT NOT NULL
    ,CONSTRAINT [PK_Country] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [Unique_CountryNatCode] UNIQUE ([NatCode])
);
PRINT N'Created cdm_demo_gold.Dim1Country';
GO

CREATE TABLE cdm_demo_gold.Dim1Languages (
     [LocalId] CHAR (4) NOT NULL
    ,[NatCode] CHAR (4) NULL
    ,[InActive] BIT NULL
    ,[LanguageName] VARCHAR (255) NULL
    ,[LanguageRecordComment] VARCHAR (255) NULL
    ,[DisplayOrder] INT NOT NULL
    ,CONSTRAINT [PK_Language] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [Unique_LanguageNatCode] UNIQUE ([NatCode])
);
PRINT N'Created cdm_demo_gold.Dim1Languages';
GO

CREATE TABLE cdm_demo_gold.Dim1VisaSubClass (
     [LocalId] CHAR (5) NOT NULL
    ,[VisaSubClassCode] VARCHAR (40) NOT NULL
    ,[VisaSubClassName] VARCHAR (255) NULL
    ,[VisaType] VARCHAR (255) NULL
    ,[InActive] BIT NULL
    ,[DisplayOrder] INT NOT NULL
    ,CONSTRAINT [PK_VisaSubClass] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [Unique_VisaSubClassCode] UNIQUE ([VisaSubClassCode])
);
PRINT N'Created cdm_demo_gold.Dim1VisaSubClass';
GO





-- -------------------------------- --
-- SUBSECTION: 3.10.7 StaffPersonal --
-- -------------------------------- --

-- TO-DO: May want SchoolLocalId and SchoolACARAId and LocalCampusId to be FKs.
CREATE TABLE cdm_demo_gold.Dim1StaffPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[Title] VARCHAR (111) NULL
    ,[EmploymentStatus] CHAR (1) NULL
    ,[MostRecent_SchoolLocalId] VARCHAR (111) NULL
    ,[MostRecent_SchoolACARAId] VARCHAR (111) NULL
    ,[MostRecent_LocalCampusId] VARCHAR (111) NULL
    ,[MostRecent_HomeGroup] VARCHAR (111) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StaffPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StaffPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StaffPersonal] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_StaffPersonal_EmploymentStatus] FOREIGN KEY ([EmploymentStatus]) REFERENCES cdm_demo_gold.Dim0StaffEmploymentStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1StaffPersonal';
GO

-- Don't think BCE will ever send Staff household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim1StaffHouseholdContactInfo (
     [HouseholdContactId] VARCHAR (111) NOT NULL
    ,[PreferenceNumber] INT NULL
    ,[HouseholdSalutation] VARCHAR (111) NULL
    ,CONSTRAINT [PK_StaffHouseholdContactInfo] PRIMARY KEY ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Dim1StaffHouseholdContactInfo';
GO

-- ----------------------------------- --
-- SUBSECTION: 3.10.10 StudentPersonal --
-- ----------------------------------- --

-- TO-DO: May want SchoolLocalId and SchoolACARAId and LocalCampusId to be FKs.
CREATE TABLE cdm_demo_gold.Dim1StudentPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[NationalUniqueStudentIdentifier] CHAR (10) NULL
    ,[ProjectedGraduationYear] SMALLINT NULL
    ,[OnTimeGraduationYear] SMALLINT NULL
    ,[GraduationDate] DATETIME NULL
    ,[MostRecent_SchoolLocalId] VARCHAR (111) NULL
    ,[MostRecent_HomeroomRefId] CHAR (36) NULL
    ,[MostRecent_HomeroomLocalId] VARCHAR (111) NULL
    ,[MostRecent_YearLevel] VARCHAR (8) NULL
    ,[MostRecent_FTE] DECIMAL (3,2) NULL
    ,[MostRecent_Parent1Language] CHAR (4) NULL
    ,[MostRecent_Parent2Language] CHAR (4) NULL
    ,[MostRecent_Parent1EmploymentType] INT NULL
    ,[MostRecent_Parent2EmploymentType] INT NULL
    ,[MostRecent_Parent1SchoolEducationLevel] INT NULL
    ,[MostRecent_Parent2SchoolEducationLevel] INT NULL
    ,[MostRecent_Parent1NonSchoolEducation] INT NULL
    ,[MostRecent_Parent2NonSchoolEducation] INT NULL
    ,[MostRecent_LocalCampusId] VARCHAR (111) NULL
    ,[MostRecent_SchoolACARAId] VARCHAR (111) NULL
    ,[MostRecent_TestLevel] VARCHAR (8) NULL
    ,[MostRecent_Homegroup] VARCHAR (111) NULL
    ,[MostRecent_ClassCode] VARCHAR (111) NULL
    ,[MostRecent_MembershipType] CHAR (2) NULL
    ,[MostRecent_FFPOS] INT NULL
    ,[MostRecent_ReportingSchoolId] VARCHAR (111) NULL
    ,[MostRecent_OtherEnrollmentSchoolACARAId] VARCHAR (111) NULL
    ,[MostRecent_OtherSchoolName] VARCHAR (111) NULL
    ,[MostRecent_DisabilityLevelOfAdjustment] VARCHAR (71) NULL
    ,[MostRecent_DisabilityCategory] VARCHAR (16) NULL
    ,[MostRecent_CensusAge] INT NULL
    ,[MostRecent_DistanceEducationStudent] CHAR (1) NULL
    ,[MostRecent_BoardingStatus] CHAR (1) NULL
    ,[AcceptableUsePolicy] CHAR (1) NULL
    ,[GiftedTalented] CHAR (1) NULL
    ,[EconomicDisadvantage] CHAR (1) NULL
    ,[ESL] CHAR (1) NULL
    ,[ESLDateAssessed] DATETIME NULL
    ,[YoungCarersRole] CHAR (1) NULL
    ,[Disability] CHAR (1) NULL
    ,[CategoryOfDisability] VARCHAR (16) NULL
    ,[IntegrationAide] CHAR (1) NULL
    ,[EducationSupport] CHAR (1) NULL
    ,[HomeSchooledStudent] CHAR (1) NULL
    ,[IndependentStudent] CHAR (1) NULL
    ,[Sensitive] CHAR (1) NULL
    ,[OfflineDelivery] CHAR (1) NULL
    ,[ESLSupport] CHAR (1) NULL
    ,[PrePrimaryEducation] VARCHAR (111) NULL
    ,[PrePrimaryEducationHours] CHAR (1) NULL
    ,[FirstAUSchoolEnrollment] DATETIME NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StudentPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentPersonal] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_YearLevel] FOREIGN KEY ([MostRecent_YearLevel]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [Check_StudentPersonal_MostRecent_FTE_Range] CHECK (MostRecent_FTE >= 0 AND MostRecent_FTE <= 1)
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent1Language] FOREIGN KEY ([MostRecent_Parent1Language]) REFERENCES cdm_demo_gold.Dim1Languages ([LocalId])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent2Language] FOREIGN KEY ([MostRecent_Parent2Language]) REFERENCES cdm_demo_gold.Dim1Languages ([LocalId])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent1EmploymentType] FOREIGN KEY ([MostRecent_Parent1EmploymentType]) REFERENCES cdm_demo_gold.Dim0EmploymentType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent2EmploymentType] FOREIGN KEY ([MostRecent_Parent2EmploymentType]) REFERENCES cdm_demo_gold.Dim0EmploymentType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent1SchoolEducationLevel] FOREIGN KEY ([MostRecent_Parent1SchoolEducationLevel]) REFERENCES cdm_demo_gold.Dim0SchoolEducationLevelType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent2SchoolEducationLevel] FOREIGN KEY ([MostRecent_Parent2SchoolEducationLevel]) REFERENCES cdm_demo_gold.Dim0SchoolEducationLevelType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent1NonSchoolEducation] FOREIGN KEY ([MostRecent_Parent1NonSchoolEducation]) REFERENCES cdm_demo_gold.Dim0NonSchoolEducationType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_Parent2NonSchoolEducation] FOREIGN KEY ([MostRecent_Parent2NonSchoolEducation]) REFERENCES cdm_demo_gold.Dim0NonSchoolEducationType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_TestLevel] FOREIGN KEY ([MostRecent_TestLevel]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_MembershipType] FOREIGN KEY ([MostRecent_MembershipType]) REFERENCES cdm_demo_gold.Dim0SchoolEnrollmentType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_FFPOS] FOREIGN KEY ([MostRecent_FFPOS]) REFERENCES cdm_demo_gold.Dim0FFPOSStatusCode ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_DisabilityLevelOfAdjustment] FOREIGN KEY ([MostRecent_DisabilityLevelOfAdjustment]) REFERENCES cdm_demo_gold.Dim0DisabilityLevelOfAdjustment ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_DisabilityCategory] FOREIGN KEY ([MostRecent_DisabilityCategory]) REFERENCES cdm_demo_gold.Dim0DisabilityNCCDCategory ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_DistanceEducationStudent] FOREIGN KEY ([MostRecent_DistanceEducationStudent]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_MostRecent_BoardingStatus] FOREIGN KEY ([MostRecent_BoardingStatus]) REFERENCES cdm_demo_gold.Dim0BoardingStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_AcceptableUsePolicy] FOREIGN KEY ([AcceptableUsePolicy]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_GiftedTalented] FOREIGN KEY ([GiftedTalented]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_EconomicDisadvantage] FOREIGN KEY ([EconomicDisadvantage]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_ESL] FOREIGN KEY ([ESL]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_YoungCarersRole] FOREIGN KEY ([YoungCarersRole]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_Disability] FOREIGN KEY ([Disability]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_CategoryOfDisability] FOREIGN KEY ([CategoryOfDisability]) REFERENCES cdm_demo_gold.Dim0DisabilityNCCDCategory ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_IntegrationAide] FOREIGN KEY ([IntegrationAide]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_EducationSupport] FOREIGN KEY ([EducationSupport]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_HomeSchooledStudent] FOREIGN KEY ([HomeSchooledStudent]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_IndependentStudent] FOREIGN KEY ([IndependentStudent]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_Sensitive] FOREIGN KEY ([Sensitive]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_OfflineDelivery] FOREIGN KEY ([OfflineDelivery]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_ESLSupport] FOREIGN KEY ([ESLSupport]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentPersonal_PrePrimaryEducationHours] FOREIGN KEY ([PrePrimaryEducationHours]) REFERENCES cdm_demo_gold.Dim0PrePrimaryEducationHours ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1StudentPersonal';
GO

-- Don't think BCE will ever send Student household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim1StudentHouseholdContactInfo (
     [HouseholdContactId] VARCHAR (111) NOT NULL
    ,[PreferenceNumber] INT NULL
    ,[HouseholdSalutation] VARCHAR (111) NULL
    ,CONSTRAINT [PK_StudentHouseholdContactInfo] PRIMARY KEY ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Dim1StudentHouseholdContactInfo';
GO

-- ----------------------------------------- --
-- SUBSECTION: 3.10.8 StudentContactPersonal --
-- ----------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim1StudentContactPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[EmploymentType] INT NULL
    ,[SchoolEducationalLevel] INT NULL
    ,[NonSchoolEducation] INT NULL
    ,[Employment] VARCHAR (111) NULL
    ,[Workplace] VARCHAR (111) NULL
    ,[WorkingWithChildrenCheckStateTerritory] VARCHAR (3) NOT NULL
    ,[WorkingWithChildrenCheckNumber] VARCHAR (111) NOT NULL
    ,[WorkingWithChildrenCheckHolderName] VARCHAR (111) NULL
    ,[WorkingWithChildrenCheckType] VARCHAR (111) NULL
    ,[WorkingWithChildrenCheckReasons] VARCHAR (111) NULL
    ,[WorkingWithChildrenCheckDetermination] VARCHAR (111) NULL
    ,[WorkingWithChildrenCheckCheckDate] DATETIME NULL
    ,[WorkingWithChildrenCheckDeterminationDate] DATETIME NULL
    ,[WorkingWithChildrenCheckExpiryDate] DATETIME NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StudentContactPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentContactPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentContactPersonal] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_StudentContact_EmploymentType] FOREIGN KEY ([EmploymentType]) REFERENCES cdm_demo_gold.Dim0EmploymentType ([TypeKey])
    ,CONSTRAINT [FK_StudentContact_SchoolEducationalLevel] FOREIGN KEY ([SchoolEducationalLevel]) REFERENCES cdm_demo_gold.Dim0SchoolEducationLevelType ([TypeKey])
    ,CONSTRAINT [FK_StudentContact_NonSchoolEducation] FOREIGN KEY ([NonSchoolEducation]) REFERENCES cdm_demo_gold.Dim0NonSchoolEducationType ([TypeKey])
    ,CONSTRAINT [FK_StudentContact_WorkingWithChildrenCheckStateTerritory] FOREIGN KEY ([WorkingWithChildrenCheckStateTerritory]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1StudentContactPersonal';
GO

-- Don't think BCE will ever send StudentContact household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim1StudentContactHouseholdContactInfo (
     [HouseholdContactId] VARCHAR (111) NOT NULL
    ,[PreferenceNumber] INT NULL
    ,[HouseholdSalutation] VARCHAR (111) NULL
    ,CONSTRAINT [PK_StudentContactHouseholdContactInfo] PRIMARY KEY ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Dim1StudentContactHouseholdContactInfo';
GO

-- -------------- --
-- 3.10.2 LEAInfo --
-- -------------- --

CREATE TABLE cdm_demo_gold.Dim1LEAInfo (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[CommonwealthId] VARCHAR (111) NULL
    ,[LEAName] VARCHAR (255) NOT NULL
    ,[LEAURL] VARCHAR (255) NULL
    ,[EducationAgencyType] CHAR (2) NULL
    ,[OperationalStatus] CHAR (1) NULL
    ,[JurisdictionLowerHouse] VARCHAR (111) NULL
    ,[SLA] VARCHAR (111) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_LEAInfo] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_LEAInfo] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LEAInfo] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_LEAInfo_EducationAgencyType] FOREIGN KEY ([EducationAgencyType]) REFERENCES cdm_demo_gold.Dim0EducationAgencyType ([TypeKey])
    ,CONSTRAINT [FK_LEAInfo_OperationalStatus] FOREIGN KEY ([OperationalStatus]) REFERENCES cdm_demo_gold.Dim0OperationalStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1LEAInfo';
GO

-- ----------------------------------------- --
-- SUBSECTION: 3.8.2 LearningResourcePackage --
-- ----------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim1LearningResourcePackage (
     [RefId] CHAR (36) NOT NULL
    ,[AbstractContentType] VARCHAR (6) NOT NULL
    ,[XMLData] VARCHAR (MAX) NULL
    ,[TextData] VARCHAR (MAX) NULL
    ,[Base64BinaryData] VARCHAR (MAX) NULL
    ,[ReferenceURL] VARCHAR (255) NOT NULL
    ,[MIMEType] VARCHAR (255) NOT NULL
    ,[FileName] VARCHAR (255) NOT NULL
    ,[Description] VARCHAR (255) NOT NULL
    ,CONSTRAINT [RefUnique_LearningResourcePackage] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_LearningResourcePackage] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LearningResourcePackage] PRIMARY KEY ([RefId])
    ,CONSTRAINT [FK_LearningResourcePackage_AbstractContentType] FOREIGN KEY ([AbstractContentType]) REFERENCES cdm_demo_gold.Dim0AbstractContentType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1LearningResourcePackage';
GO

-- TO-DO: Dim1LearningStandardItem = a hierarchy of individual curriculum standards or benchmarks

-- -------------------------------- --
-- SUBSECTION: 3.11.1 EquipmentInfo --
-- -------------------------------- --

CREATE TABLE cdm_demo_gold.Dim1EquipmentInfo (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[Name] VARCHAR (111) NOT NULL
    ,[Description] VARCHAR (111) NULL
    ,[AssetNumber] VARCHAR (111) NULL
-- TO-DO: Add FK constraint once a table for Invoice is added to the data model:
    ,[InvoiceRefId] CHAR (36) NULL
-- TO-DO: Add FK constraint once a table for Purchase Order is added to the data model:
    ,[PurchaseOrderRefId] CHAR (36) NULL
-- Field doubled up to split enumerated equipment type from free-text equipment type:
    ,[EquipmentType] VARCHAR (17) NULL
    ,[OtherEquipmentType] VARCHAR (111) NULL
-- Not currently restricted with a FK constraint (no union of all these different RefIds built - for now):
    ,[OwnerOrLocationRefId] CHAR (36) NULL
    ,[OwnerOrLocationLocalId] INT NULL
    ,[OwnerOrLocationSIF_RefObject] VARCHAR (16) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_EquipmentInfo] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_EquipmentInfo] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_EquipmentInfo] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [Unique_EquipmentInfo_AssetNumber] UNIQUE ([AssetNumber])
    ,CONSTRAINT [FK_LEquipmentInfo_EquipmentType] FOREIGN KEY ([EquipmentType]) REFERENCES cdm_demo_gold.Dim0EquipmentType ([TypeKey])
    ,CONSTRAINT [FK_LEquipmentInfo_OwnerOrLocationSIF_RefObject] FOREIGN KEY ([OwnerOrLocationSIF_RefObject]) REFERENCES cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1EquipmentInfo';
GO





-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 2 in name have FK to table(s) with 1 (& maybe 0)   --
-- -------------------------------------------------------------------------- --

-- -------------------------------- --
-- SUBSECTION: 3.10.7 StaffPersonal --
-- -------------------------------- --

-- Not needed, duplicate of Dim1StaffPersonal, and Dim2PartyList
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StaffList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,CONSTRAINT [FKRef_StaffList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffList] PRIMARY KEY ([StaffLocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StaffList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffElectronicIdList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[ElectronicIdValue] VARCHAR (111) NULL
    ,[ElectronicIdTypeKey] CHAR (2) NOT NULL
    ,CONSTRAINT [FKRef_StaffElectronicIdList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffElectronicIdList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffElectronicIdList] PRIMARY KEY ([StaffLocalId],[ElectronicIdTypeKey])
    ,CONSTRAINT [FK_StaffElectronicIdList_ElectronicIdListType] FOREIGN KEY ([ElectronicIdTypeKey]) REFERENCES cdm_demo_gold.Dim0ElectronicIdType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffElectronicIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffOtherIdList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[OtherIdValue] VARCHAR (111) NULL
    ,[OtherIdType] VARCHAR (111) NOT NULL -- Not a key, and no FK relationship this time, unlike electronic, above
    ,CONSTRAINT [FKRef_StaffOtherIdList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffOtherIdList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffOtherIdList] PRIMARY KEY ([StaffLocalId],[OtherIdType])
);
PRINT N'Created cdm_demo_gold.Dim2StaffOtherIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffNames (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[Title] VARCHAR (111) NULL
    ,[FamilyName] VARCHAR (111) NULL
    ,[GivenName] VARCHAR (111) NULL
    ,[MiddleName] VARCHAR (111) NULL
    ,[FamilyNameFirst] CHAR (1) NULL
    ,[PreferredFamilyName] VARCHAR (111) NULL
    ,[PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PreferredGivenName] VARCHAR (111) NULL
    ,[Suffix] VARCHAR (111) NULL
    ,[FullName] VARCHAR (111) NULL
    ,[NameUsageTypeKey] CHAR (3) NOT NULL
    ,CONSTRAINT [FKRef_StaffNames_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffNames_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffNames] PRIMARY KEY ([StaffLocalId],[NameUsageTypeKey])
    ,CONSTRAINT [FK_StaffNames_FamilyNameFirst] FOREIGN KEY ([FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffNames_PreferredFamilyNameFirst] FOREIGN KEY ([PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffNames_NameUsageType] FOREIGN KEY ([NameUsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffNames';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffDemographics (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[IndigenousStatus] INT NULL
    ,[Gender] INT NULL
    ,[BirthDate] DATETIME NULL
    ,[DateOfDeath] DATETIME NULL
    ,[Deceased] CHAR (1) NULL
    ,[BirthDateVerification] VARCHAR (4) NULL
    ,[PlaceOfBirth] VARCHAR (111) NULL
    ,[StateOfBirth] VARCHAR (3) NULL
    ,[CountryOfBirth] VARCHAR (5) NULL
    ,[CountryArrivalDate] DATETIME NULL
    ,[AustralianCitizenshipStatus] CHAR (1) NULL
    ,[EnglishProficiency] INT NULL
    ,[DwellingArrangement] CHAR (4) NULL
    ,[Religion] VARCHAR (6) NULL
    ,[ReligiousRegion] VARCHAR (111) NULL
    ,[PermanentResident] VARCHAR (2) NULL
    ,[VisaSubClass] CHAR (5) NULL
    ,[VisaStatisticalCode] VARCHAR (111) NULL
    ,[VisaNumber] VARCHAR (111) NULL
    ,[VisaGrantDate] DATETIME NULL
    ,[VisaExpiryDate] DATETIME NULL
    ,[VisaConditions] VARCHAR (111) NULL
    ,[VisaStudyEntitlement] VARCHAR (9) NULL
    ,[LBOTE] CHAR (1) NULL
    ,[InterpreterRequired] CHAR (1) NULL
    ,[ImmunisationCertificateStatus] VARCHAR (2) NULL
    ,[CulturalBackground] CHAR (4) NULL
    ,[MaritalStatus] INT NULL
    ,[MedicareNumber] VARCHAR (111) NULL
    ,[MedicarePositionNumber] VARCHAR (111) NULL
    ,[MedicareCardHolder] VARCHAR (111) NULL
    ,[PrivateHealthInsurer] VARCHAR (111) NULL
    ,[PrivateHealthPolicyId] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StaffDemographics_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffDemographics_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffDemographics] PRIMARY KEY ([StaffLocalId])
    ,CONSTRAINT [FK_StaffDemographics_IndigenousStatus] FOREIGN KEY ([IndigenousStatus]) REFERENCES cdm_demo_gold.Dim0IndigenousStatus ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_GenderAkaSexCode] FOREIGN KEY ([Gender]) REFERENCES cdm_demo_gold.Dim0SexCode ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_Deceased] FOREIGN KEY ([Deceased]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_BirthdateVerification] FOREIGN KEY ([BirthdateVerification]) REFERENCES cdm_demo_gold.Dim0BirthdateVerification ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_StateOfBirth] FOREIGN KEY ([StateOfBirth]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_CountryOfBirth] FOREIGN KEY ([CountryOfBirth]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
    ,CONSTRAINT [FK_StaffDemographics_AustralianCitizenshipStatus] FOREIGN KEY ([AustralianCitizenshipStatus]) REFERENCES cdm_demo_gold.Dim0AustralianCitizenshipStatus ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_EnglishProficiency] FOREIGN KEY ([EnglishProficiency]) REFERENCES cdm_demo_gold.Dim0EnglishProficiency ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_DwellingArrangement] FOREIGN KEY ([DwellingArrangement]) REFERENCES cdm_demo_gold.Dim0DwellingArrangement ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_Religion] FOREIGN KEY ([Religion]) REFERENCES cdm_demo_gold.Dim0ReligionType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_PermanentResident] FOREIGN KEY ([PermanentResident]) REFERENCES cdm_demo_gold.Dim0PermanentResidentStatus ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_VisaSubClass] FOREIGN KEY ([VisaSubClass]) REFERENCES cdm_demo_gold.Dim1VisaSubClass ([LocalId])
    ,CONSTRAINT [FK_StaffDemographics_VisaStudyEntitlement] FOREIGN KEY ([VisaStudyEntitlement]) REFERENCES cdm_demo_gold.Dim0VisaStudyEntitlement ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_LBOTE] FOREIGN KEY ([LBOTE]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_InterpreterRequired] FOREIGN KEY ([InterpreterRequired]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_ImmunisationCertificateStatus] FOREIGN KEY ([ImmunisationCertificateStatus]) REFERENCES cdm_demo_gold.Dim0ImmunisationCertificateStatus ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_CulturalBackground] FOREIGN KEY ([CulturalBackground]) REFERENCES cdm_demo_gold.Dim0CulturalEthnicGroups ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_MaritalStatus] FOREIGN KEY ([MaritalStatus]) REFERENCES cdm_demo_gold.Dim0MaritalStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffDemographics';
GO

CREATE TABLE cdm_demo_gold.Bridge2StaffCountriesOfCitizenship (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StaffCountriesOfCitizenship_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffCountriesOfCitizenship_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffCountriesOfCitizenship] PRIMARY KEY ([StaffLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StaffCountriesOfCitizenship_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StaffCountriesOfCitizenship';
GO

CREATE TABLE cdm_demo_gold.Bridge2StaffCountriesOfResidency (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StaffCountriesOfResidency_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffCountriesOfResidency_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffCountriesOfResidency] PRIMARY KEY ([StaffLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StaffCountriesOfResidency_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StaffCountriesOfResidency';
GO

CREATE TABLE cdm_demo_gold.Bridge2StaffLanguages (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[LanguageLocalId] CHAR (4) NOT NULL
    ,CONSTRAINT [FKRef_StaffLanguages_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffLanguages_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffLanguages] PRIMARY KEY ([StaffLocalId], [LanguageLocalId])
    ,CONSTRAINT [FK_StaffLanguages_LanguageLocalId] FOREIGN KEY ([LanguageLocalId]) REFERENCES cdm_demo_gold.Dim1Languages ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StaffLanguages';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffReligiousEvent (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[ReligiousEventDescription] VARCHAR (111)  NOT NULL
    ,[ReligiousEventDate] DATETIME  NOT NULL
    ,CONSTRAINT [FKRef_StaffReligiousEvent_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffReligiousEvent_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffReligiousEvent] PRIMARY KEY ([StaffLocalId],[ReligiousEventDate])
);
PRINT N'Created cdm_demo_gold.Dim2StaffReligiousEvent';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffPassport (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[ExpiryDate] DATETIME  NULL
    ,[Country] VARCHAR (5)  NOT NULL
    ,CONSTRAINT [FKRef_StaffPassport_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffPassport_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffPassport] PRIMARY KEY ([StaffLocalId],[Number],[Country])
    ,CONSTRAINT [FK_StaffPassport_Country] FOREIGN KEY ([Country]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StaffPassport';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffAddressList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StaffAddressList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAddressList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffAddressList] PRIMARY KEY ([StaffLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StaffAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StaffAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StaffAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffPhoneNumberList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_StaffPhoneNumberList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffPhoneNumberList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffPhoneNumberList] PRIMARY KEY ([StaffLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StaffPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffEmailList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_StaffEmailList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffEmailList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffEmailList] PRIMARY KEY ([StaffLocalId],[EmailType])
    ,CONSTRAINT [FK_StaffEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffEmailList';
GO

-- Don't think BCE will ever send Staff household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Bridge2StaffHouseholdContactInfo (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[StaffHouseholdContactId] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StaffHouseholdContactInfo_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffHouseholdContactInfo_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_BridgeStaffHouseholdContactInfo] PRIMARY KEY ([StaffLocalId], [StaffHouseholdContactId])
    ,CONSTRAINT [FK_BridgeStaffHouseholdContactInfo_HouseholdContactId] FOREIGN KEY ([StaffHouseholdContactId]) REFERENCES cdm_demo_gold.Dim1StaffHouseholdContactInfo ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Bridge2StaffHouseholdContactInfo';
GO

-- Don't think BCE will ever send Staff household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StaffHouseholdContactAddressList (
     [StaffHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKLocal_StaffHouseholdContactAddressList_StaffHouseholdContact] FOREIGN KEY ([StaffHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StaffHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StaffHouseholdContactAddressList] PRIMARY KEY ([StaffHouseholdContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StaffHouseholdContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StaffHouseholdContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StaffHouseholdContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffHouseholdContactAddressList';
GO

-- Don't think BCE will ever send Staff household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StaffHouseholdContactPhoneNumberList (
     [StaffHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKLocal_StaffHouseholdContactPhoneNumberList_StaffPersonal] FOREIGN KEY ([StaffHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StaffHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StaffHouseholdContactPhoneNumberList] PRIMARY KEY ([StaffHouseholdContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StaffHouseholdContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffHouseholdContactPhoneNumberList';
GO

-- Don't think BCE will ever send Staff household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StaffHouseholdContactEmailList (
     [StaffHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKLocal_StaffHouseholdContactEmailList_StaffPersonal] FOREIGN KEY ([StaffHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StaffHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StaffHouseholdContactEmailList] PRIMARY KEY ([StaffHouseholdContactLocalId],[EmailType])
    ,CONSTRAINT [FK_StaffHouseholdContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StaffHouseholdContactEmailList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffMostRecentNAPLANClassList (
     [StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[ClassCode] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StaffMostRecentNAPLANClassList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffMostRecentNAPLANClassList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffMostRecentNAPLANClassList] PRIMARY KEY ([StaffLocalId],[ClassCode])
);
PRINT N'Created cdm_demo_gold.Dim2StaffMostRecentNAPLANClassList';
GO

-- ----------------------------------- --
-- SUBSECTION: 3.10.10 StudentPersonal --
-- ----------------------------------- --

-- Not needed, duplicate of Dim1StudentPersonal, and Dim2PartyList
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,CONSTRAINT [FKRef_StudentList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentList] PRIMARY KEY ([StudentLocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StudentList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentAlertMessages (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[AlertMessageContent] VARCHAR (896) NOT NULL
    ,[AlertMessageType] VARCHAR (11) NOT NULL
    ,CONSTRAINT [FKRef_StudentAlertMessages_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentAlertMessages_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentAlertMessages] PRIMARY KEY ([StudentLocalId],[AlertMessageContent])
    ,CONSTRAINT [FK_StudentAlertMessages_AlertMessageType] FOREIGN KEY ([AlertMessageType]) REFERENCES cdm_demo_gold.Dim0AlertMessageType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentAlertMessages';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentMedicalAlertMessages (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[MedicalAlertContent] VARCHAR (896) NOT NULL
    ,[MedicalSeverity] VARCHAR (8) NOT NULL
    ,CONSTRAINT [FKRef_StudentMedicalAlertMessages_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentMedicalAlertMessages_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentMedicalAlertMessages] PRIMARY KEY ([StudentLocalId],[MedicalAlertContent])
    ,CONSTRAINT [FK_StudentMedicalAlertMessages_MedicalSeverity] FOREIGN KEY ([MedicalSeverity]) REFERENCES cdm_demo_gold.Dim0MedicalSeverity ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentMedicalAlertMessages';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentElectronicIdList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[ElectronicIdValue] VARCHAR (111) NULL
    ,[ElectronicIdTypeKey] CHAR (2) NOT NULL
    ,CONSTRAINT [FKRef_StudentElectronicIdList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentElectronicIdList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentElectronicIdList] PRIMARY KEY ([StudentLocalId],[ElectronicIdTypeKey])
    ,CONSTRAINT [FK_StudentElectronicIdList_ElectronicIdListType] FOREIGN KEY ([ElectronicIdTypeKey]) REFERENCES cdm_demo_gold.Dim0ElectronicIdType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentElectronicIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentOtherIdList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[OtherIdValue] VARCHAR (111) NULL
    ,[OtherIdType] VARCHAR (111) NOT NULL -- Not a key, and no FK relationship this time, unlike electronic, above
    ,CONSTRAINT [FKRef_StudentOtherIdList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentOtherIdList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentOtherIdList] PRIMARY KEY ([StudentLocalId],[OtherIdType])
);
PRINT N'Created cdm_demo_gold.Dim2StudentOtherIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentNames (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[Title] VARCHAR (111) NULL
    ,[FamilyName] VARCHAR (111) NULL
    ,[GivenName] VARCHAR (111) NULL
    ,[MiddleName] VARCHAR (111) NULL
    ,[FamilyNameFirst] CHAR (1) NULL
    ,[PreferredFamilyName] VARCHAR (111) NULL
    ,[PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PreferredGivenName] VARCHAR (111) NULL
    ,[Suffix] VARCHAR (111) NULL
    ,[FullName] VARCHAR (111) NULL
    ,[NameUsageTypeKey] CHAR (3) NOT NULL
    ,CONSTRAINT [FKRef_StudentNames_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentNames_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentNames] PRIMARY KEY ([StudentLocalId],[NameUsageTypeKey])
    ,CONSTRAINT [FK_StudentNames_FamilyNameFirst] FOREIGN KEY ([FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentNames_PreferredFamilyNameFirst] FOREIGN KEY ([PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentNames_NameUsageType] FOREIGN KEY ([NameUsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentNames';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentDemographics (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[IndigenousStatus] INT NULL
    ,[Gender] INT NULL
    ,[BirthDate] DATETIME NULL
    ,[DateOfDeath] DATETIME NULL
    ,[Deceased] CHAR (1) NULL
    ,[BirthDateVerification] VARCHAR (4) NULL
    ,[PlaceOfBirth] VARCHAR (111) NULL
    ,[StateOfBirth] VARCHAR (3) NULL
    ,[CountryOfBirth] VARCHAR (5) NULL
    ,[CountryArrivalDate] DATETIME NULL
    ,[AustralianCitizenshipStatus] CHAR (1) NULL
    ,[EnglishProficiency] INT NULL
    ,[DwellingArrangement] CHAR (4) NULL
    ,[Religion] VARCHAR (6) NULL
    ,[ReligiousRegion] VARCHAR (111) NULL
    ,[PermanentResident] VARCHAR (2) NULL
    ,[VisaSubClass] CHAR (5) NULL
    ,[VisaStatisticalCode] VARCHAR (111) NULL
    ,[VisaNumber] VARCHAR (111) NULL
    ,[VisaGrantDate] DATETIME NULL
    ,[VisaExpiryDate] DATETIME NULL
    ,[VisaConditions] VARCHAR (111) NULL
    ,[VisaStudyEntitlement] VARCHAR (9) NULL
    ,[LBOTE] CHAR (1) NULL
    ,[InterpreterRequired] CHAR (1) NULL
    ,[ImmunisationCertificateStatus] VARCHAR (2) NULL
    ,[CulturalBackground] CHAR (4) NULL
    ,[MaritalStatus] INT NULL
    ,[MedicareNumber] VARCHAR (111) NULL
    ,[MedicarePositionNumber] VARCHAR (111) NULL
    ,[MedicareCardHolder] VARCHAR (111) NULL
    ,[PrivateHealthInsurer] VARCHAR (111) NULL
    ,[PrivateHealthPolicyId] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StudentDemographics_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentDemographics_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentDemographics] PRIMARY KEY ([StudentLocalId])
    ,CONSTRAINT [FK_StudentDemographics_IndigenousStatus] FOREIGN KEY ([IndigenousStatus]) REFERENCES cdm_demo_gold.Dim0IndigenousStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_GenderAkaSexCode] FOREIGN KEY ([Gender]) REFERENCES cdm_demo_gold.Dim0SexCode ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_Deceased] FOREIGN KEY ([Deceased]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_BirthdateVerification] FOREIGN KEY ([BirthdateVerification]) REFERENCES cdm_demo_gold.Dim0BirthdateVerification ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_StateOfBirth] FOREIGN KEY ([StateOfBirth]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_CountryOfBirth] FOREIGN KEY ([CountryOfBirth]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
    ,CONSTRAINT [FK_StudentDemographics_AustralianCitizenshipStatus] FOREIGN KEY ([AustralianCitizenshipStatus]) REFERENCES cdm_demo_gold.Dim0AustralianCitizenshipStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_EnglishProficiency] FOREIGN KEY ([EnglishProficiency]) REFERENCES cdm_demo_gold.Dim0EnglishProficiency ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_DwellingArrangement] FOREIGN KEY ([DwellingArrangement]) REFERENCES cdm_demo_gold.Dim0DwellingArrangement ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_Religion] FOREIGN KEY ([Religion]) REFERENCES cdm_demo_gold.Dim0ReligionType ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_PermanentResident] FOREIGN KEY ([PermanentResident]) REFERENCES cdm_demo_gold.Dim0PermanentResidentStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_VisaSubClass] FOREIGN KEY ([VisaSubClass]) REFERENCES cdm_demo_gold.Dim1VisaSubClass ([LocalId])
    ,CONSTRAINT [FK_StudentDemographics_VisaStudyEntitlement] FOREIGN KEY ([VisaStudyEntitlement]) REFERENCES cdm_demo_gold.Dim0VisaStudyEntitlement ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_LBOTE] FOREIGN KEY ([LBOTE]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_InterpreterRequired] FOREIGN KEY ([InterpreterRequired]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_ImmunisationCertificateStatus] FOREIGN KEY ([ImmunisationCertificateStatus]) REFERENCES cdm_demo_gold.Dim0ImmunisationCertificateStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_CulturalBackground] FOREIGN KEY ([CulturalBackground]) REFERENCES cdm_demo_gold.Dim0CulturalEthnicGroups ([TypeKey])
    ,CONSTRAINT [FK_StudentDemographics_MaritalStatus] FOREIGN KEY ([MaritalStatus]) REFERENCES cdm_demo_gold.Dim0MaritalStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentDemographics';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentCountriesOfCitizenship (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StudentCountriesOfCitizenship_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentCountriesOfCitizenship_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentCountriesOfCitizenship] PRIMARY KEY ([StudentLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StudentCountriesOfCitizenship_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentCountriesOfCitizenship';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentCountriesOfResidency (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StudentCountriesOfResidency_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentCountriesOfResidency_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentCountriesOfResidency] PRIMARY KEY ([StudentLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StudentCountriesOfResidency_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentCountriesOfResidency';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentLanguages (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[LanguageLocalId] CHAR (4) NOT NULL
    ,CONSTRAINT [FKRef_StudentLanguages_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentLanguages_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentLanguages] PRIMARY KEY ([StudentLocalId], [LanguageLocalId])
    ,CONSTRAINT [FK_StudentLanguages_LanguageLocalId] FOREIGN KEY ([LanguageLocalId]) REFERENCES cdm_demo_gold.Dim1Languages ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentLanguages';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentReligiousEvent (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[ReligiousEventDescription] VARCHAR (111)  NOT NULL
    ,[ReligiousEventDate] DATETIME  NOT NULL
    ,CONSTRAINT [FKRef_StudentReligiousEvent_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentReligiousEvent_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentReligiousEvent] PRIMARY KEY ([StudentLocalId],[ReligiousEventDate])
);
PRINT N'Created cdm_demo_gold.Dim2StudentReligiousEvent';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentPassport (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[ExpiryDate] DATETIME  NULL
    ,[Country] VARCHAR (5)  NOT NULL
    ,CONSTRAINT [FKRef_StudentPassport_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentPassport_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentPassport] PRIMARY KEY ([StudentLocalId],[Number],[Country])
    ,CONSTRAINT [FK_StudentPassport_Country] FOREIGN KEY ([Country]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StudentPassport';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentAddressList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StudentAddressList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentAddressList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentAddressList] PRIMARY KEY ([StudentLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StudentAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StudentAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StudentAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentPhoneNumberList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_StudentPhoneNumberList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentPhoneNumberList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentPhoneNumberList] PRIMARY KEY ([StudentLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StudentPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentEmailList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_StudentEmailList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentEmailList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentEmailList] PRIMARY KEY ([StudentLocalId],[EmailType])
    ,CONSTRAINT [FK_StudentEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentEmailList';
GO

-- Don't think BCE will ever send Student household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Bridge2StudentHouseholdContactInfo (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[StudentHouseholdContactId] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StudentHouseholdContactInfo_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentHouseholdContactInfo_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_BridgeStudentHouseholdContactInfo] PRIMARY KEY ([StudentLocalId], [StudentHouseholdContactId])
    ,CONSTRAINT [FK_BridgeStudentHouseholdContactInfo_HouseholdContactId] FOREIGN KEY ([StudentHouseholdContactId]) REFERENCES cdm_demo_gold.Dim1StudentHouseholdContactInfo ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentHouseholdContactInfo';
GO

-- Don't think BCE will ever send Student household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentHouseholdContactAddressList (
     [StudentHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKLocal_StudentHouseholdContactAddressList_StudentHouseholdContact] FOREIGN KEY ([StudentHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentHouseholdContactAddressList] PRIMARY KEY ([StudentHouseholdContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StudentHouseholdContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StudentHouseholdContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StudentHouseholdContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentHouseholdContactAddressList';
GO

-- Don't think BCE will ever send Student household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentHouseholdContactPhoneNumberList (
     [StudentHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKLocal_StudentHouseholdContactPhoneNumberList_StudentPersonal] FOREIGN KEY ([StudentHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentHouseholdContactPhoneNumberList] PRIMARY KEY ([StudentHouseholdContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StudentHouseholdContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentHouseholdContactPhoneNumberList';
GO

-- Don't think BCE will ever send Student household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentHouseholdContactEmailList (
     [StudentHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKLocal_StudentHouseholdContactEmailList_StudentPersonal] FOREIGN KEY ([StudentHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentHouseholdContactEmailList] PRIMARY KEY ([StudentHouseholdContactLocalId],[EmailType])
    ,CONSTRAINT [FK_StudentHouseholdContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentHouseholdContactEmailList';
GO

-- ----------------------------------------- --
-- SUBSECTION: 3.10.8 StudentContactPersonal --
-- ----------------------------------------- --

-- Not needed, duplicate of Dim1StudentContactPersonal, and Dim2PartyList
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentContactPersonList (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,CONSTRAINT [FKRef_StudentContactPersonList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactPersonList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactPersonList] PRIMARY KEY ([StudentContactLocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactPersonList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactOtherIdList (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[OtherIdValue] VARCHAR (111) NULL
    ,[OtherIdType] VARCHAR (111) NOT NULL -- Not a key, and no FK relationship this time, unlike electronic, above
    ,CONSTRAINT [FKRef_StudentContactOtherIdList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactOtherIdList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactOtherIdList] PRIMARY KEY ([StudentContactLocalId],[OtherIdType])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactOtherIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactNames (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[Title] VARCHAR (111) NULL
    ,[FamilyName] VARCHAR (111) NULL
    ,[GivenName] VARCHAR (111) NULL
    ,[MiddleName] VARCHAR (111) NULL
    ,[FamilyNameFirst] CHAR (1) NULL
    ,[PreferredFamilyName] VARCHAR (111) NULL
    ,[PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PreferredGivenName] VARCHAR (111) NULL
    ,[Suffix] VARCHAR (111) NULL
    ,[FullName] VARCHAR (111) NULL
    ,[NameUsageTypeKey] CHAR (3) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactNames_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactNames_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactNames] PRIMARY KEY ([StudentContactLocalId],[NameUsageTypeKey])
    ,CONSTRAINT [FK_StudentContactNames_FamilyNameFirst] FOREIGN KEY ([FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactNames_PreferredFamilyNameFirst] FOREIGN KEY ([PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactNames_NameUsageType] FOREIGN KEY ([NameUsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactNames';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactDemographics (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[IndigenousStatus] INT NULL
    ,[Gender] INT NULL
    ,[BirthDate] DATETIME NULL
    ,[DateOfDeath] DATETIME NULL
    ,[Deceased] CHAR (1) NULL
    ,[BirthDateVerification] VARCHAR (4) NULL
    ,[PlaceOfBirth] VARCHAR (111) NULL
    ,[StateOfBirth] VARCHAR (3) NULL
    ,[CountryOfBirth] VARCHAR (5) NULL
    ,[CountryArrivalDate] DATETIME NULL
    ,[AustralianCitizenshipStatus] CHAR (1) NULL
    ,[EnglishProficiency] INT NULL
    ,[DwellingArrangement] CHAR (4) NULL
    ,[Religion] VARCHAR (6) NULL
    ,[ReligiousRegion] VARCHAR (111) NULL
    ,[PermanentResident] VARCHAR (2) NULL
    ,[VisaSubClass] CHAR (5) NULL
    ,[VisaStatisticalCode] VARCHAR (111) NULL
    ,[VisaNumber] VARCHAR (111) NULL
    ,[VisaGrantDate] DATETIME NULL
    ,[VisaExpiryDate] DATETIME NULL
    ,[VisaConditions] VARCHAR (111) NULL
    ,[VisaStudyEntitlement] VARCHAR (9) NULL
    ,[LBOTE] CHAR (1) NULL
    ,[InterpreterRequired] CHAR (1) NULL
    ,[ImmunisationCertificateStatus] VARCHAR (2) NULL
    ,[CulturalBackground] CHAR (4) NULL
    ,[MaritalStatus] INT NULL
    ,[MedicareNumber] VARCHAR (111) NULL
    ,[MedicarePositionNumber] VARCHAR (111) NULL
    ,[MedicareCardHolder] VARCHAR (111) NULL
    ,[PrivateHealthInsurer] VARCHAR (111) NULL
    ,[PrivateHealthPolicyId] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StudentContactDemographics_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactDemographics_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactDemographics] PRIMARY KEY ([StudentContactLocalId])
    ,CONSTRAINT [FK_StudentContactDemographics_IndigenousStatus] FOREIGN KEY ([IndigenousStatus]) REFERENCES cdm_demo_gold.Dim0IndigenousStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_GenderAkaSexCode] FOREIGN KEY ([Gender]) REFERENCES cdm_demo_gold.Dim0SexCode ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_Deceased] FOREIGN KEY ([Deceased]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_BirthdateVerification] FOREIGN KEY ([BirthdateVerification]) REFERENCES cdm_demo_gold.Dim0BirthdateVerification ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_StateOfBirth] FOREIGN KEY ([StateOfBirth]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_CountryOfBirth] FOREIGN KEY ([CountryOfBirth]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
    ,CONSTRAINT [FK_StudentContactDemographics_AustralianCitizenshipStatus] FOREIGN KEY ([AustralianCitizenshipStatus]) REFERENCES cdm_demo_gold.Dim0AustralianCitizenshipStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_EnglishProficiency] FOREIGN KEY ([EnglishProficiency]) REFERENCES cdm_demo_gold.Dim0EnglishProficiency ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_DwellingArrangement] FOREIGN KEY ([DwellingArrangement]) REFERENCES cdm_demo_gold.Dim0DwellingArrangement ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_Religion] FOREIGN KEY ([Religion]) REFERENCES cdm_demo_gold.Dim0ReligionType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_PermanentResident] FOREIGN KEY ([PermanentResident]) REFERENCES cdm_demo_gold.Dim0PermanentResidentStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_VisaSubClass] FOREIGN KEY ([VisaSubClass]) REFERENCES cdm_demo_gold.Dim1VisaSubClass ([LocalId])
    ,CONSTRAINT [FK_StudentContactDemographics_VisaStudyEntitlement] FOREIGN KEY ([VisaStudyEntitlement]) REFERENCES cdm_demo_gold.Dim0VisaStudyEntitlement ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_LBOTE] FOREIGN KEY ([LBOTE]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_InterpreterRequired] FOREIGN KEY ([InterpreterRequired]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_ImmunisationCertificateStatus] FOREIGN KEY ([ImmunisationCertificateStatus]) REFERENCES cdm_demo_gold.Dim0ImmunisationCertificateStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_CulturalBackground] FOREIGN KEY ([CulturalBackground]) REFERENCES cdm_demo_gold.Dim0CulturalEthnicGroups ([TypeKey])
    ,CONSTRAINT [FK_StudentContactDemographics_MaritalStatus] FOREIGN KEY ([MaritalStatus]) REFERENCES cdm_demo_gold.Dim0MaritalStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactDemographics';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentContactCountriesOfCitizenship (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactCountriesOfCitizenship_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactCountriesOfCitizenship_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactCountriesOfCitizenship] PRIMARY KEY ([StudentContactLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StudentContactCountriesOfCitizenship_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentContactCountriesOfCitizenship';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentContactCountriesOfResidency (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[CountryLocalId] VARCHAR (5) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactCountriesOfResidency_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactCountriesOfResidency_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactCountriesOfResidency] PRIMARY KEY ([StudentContactLocalId], [CountryLocalId])
    ,CONSTRAINT [FK_StudentContactCountriesOfResidency_CountryLocalId] FOREIGN KEY ([CountryLocalId]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentContactCountriesOfResidency';
GO

CREATE TABLE cdm_demo_gold.Bridge2StudentContactLanguages (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[LanguageLocalId] CHAR (4) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactLanguages_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactLanguages_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactLanguages] PRIMARY KEY ([StudentContactLocalId], [LanguageLocalId])
    ,CONSTRAINT [FK_StudentContactLanguages_LanguageLocalId] FOREIGN KEY ([LanguageLocalId]) REFERENCES cdm_demo_gold.Dim1Languages ([LocalId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentContactLanguages';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactReligiousEvent (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[ReligiousEventDescription] VARCHAR (111)  NOT NULL
    ,[ReligiousEventDate] DATETIME  NOT NULL
    ,CONSTRAINT [FKRef_StudentContactReligiousEvent_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactReligiousEvent_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactReligiousEvent] PRIMARY KEY ([StudentContactLocalId],[ReligiousEventDate])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactReligiousEvent';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactPassport (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[ExpiryDate] DATETIME  NULL
    ,[Country] VARCHAR (5)  NOT NULL
    ,CONSTRAINT [FKRef_StudentContactPassport_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactPassport_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactPassport] PRIMARY KEY ([StudentContactLocalId],[Number],[Country])
    ,CONSTRAINT [FK_StudentContactPassport_Country] FOREIGN KEY ([Country]) REFERENCES cdm_demo_gold.Dim1Country ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactPassport';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactAddressList (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StudentContactAddressList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactAddressList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactAddressList] PRIMARY KEY ([StudentContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StudentContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StudentContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactPhoneNumberList (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_StudentContactPhoneNumberList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactPhoneNumberList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactPhoneNumberList] PRIMARY KEY ([StudentContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StudentContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim2StudentContactEmailList (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactEmailList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactEmailList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentContactEmailList] PRIMARY KEY ([StudentContactLocalId],[EmailType])
    ,CONSTRAINT [FK_StudentContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactEmailList';
GO

-- Don't think BCE will ever send StudentContact household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Bridge2StudentContactHouseholdContactInfo (
     [StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[StudentContactHouseholdContactId] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StudentContactHouseholdContactInfo_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactHouseholdContactInfo_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [PK_BridgeStudentContactHouseholdContactInfo] PRIMARY KEY ([StudentContactLocalId], [StudentContactHouseholdContactId])
    ,CONSTRAINT [FK_BridgeStudentContactHouseholdContactInfo_HouseholdContactId] FOREIGN KEY ([StudentContactHouseholdContactId]) REFERENCES cdm_demo_gold.Dim1StudentContactHouseholdContactInfo ([HouseholdContactId])
);
PRINT N'Created cdm_demo_gold.Bridge2StudentContactHouseholdContactInfo';
GO

-- Don't think BCE will ever send StudentContact household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentContactHouseholdContactAddressList (
     [StudentContactHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKLocal_StudentContactHouseholdContactAddressList_StudentContactHouseholdContact] FOREIGN KEY ([StudentContactHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentContactHouseholdContactAddressList] PRIMARY KEY ([StudentContactHouseholdContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_StudentContactHouseholdContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactHouseholdContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_StudentContactHouseholdContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactHouseholdContactAddressList';
GO

-- Don't think BCE will ever send StudentContact household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentContactHouseholdContactPhoneNumberList (
     [StudentContactHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKLocal_StudentContactHouseholdContactPhoneNumberList_StudentContactPersonal] FOREIGN KEY ([StudentContactHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentContactHouseholdContactPhoneNumberList] PRIMARY KEY ([StudentContactHouseholdContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_StudentContactHouseholdContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactHouseholdContactPhoneNumberList';
GO

-- Don't think BCE will ever send StudentContact household contact info in SIF messages.
-- Therefore recommend this table be removed for production.
CREATE TABLE cdm_demo_gold.Dim2StudentContactHouseholdContactEmailList (
     [StudentContactHouseholdContactLocalId] VARCHAR (111) NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKLocal_StudentContactHouseholdContactEmailList_StudentContactPersonal] FOREIGN KEY ([StudentContactHouseholdContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactHouseholdContactInfo ([HouseholdContactId])
    ,CONSTRAINT [PK_StudentContactHouseholdContactEmailList] PRIMARY KEY ([StudentContactHouseholdContactLocalId],[EmailType])
    ,CONSTRAINT [FK_StudentContactHouseholdContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2StudentContactHouseholdContactEmailList';
GO

-- -------------- --
-- 3.10.2 LEAInfo --
-- -------------- --

CREATE TABLE cdm_demo_gold.Dim2LEAAddressList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LEAAddressList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAAddressList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [PK_LEAAddressList] PRIMARY KEY ([LEALocalId],[AddressLocalId])
    ,CONSTRAINT [FK_LEAAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_LEAAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_LEAAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2LEAAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim2LEAPhoneNumberList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_LEAPhoneNumberList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAPhoneNumberList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [PK_LEAPhoneNumberList] PRIMARY KEY ([LEALocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_LEAPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2LEAPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim2LEAContactList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[LEAContactLocalId] VARCHAR (111) NOT NULL
    ,[PublishInDirectory] CHAR (1) NULL
    ,[Name_Title] VARCHAR (111) NULL
    ,[Name_FamilyName] VARCHAR (111) NULL
    ,[Name_GivenName] VARCHAR (111) NULL
    ,[Name_MiddleName] VARCHAR (111) NULL
    ,[Name_FamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredFamilyName] VARCHAR (111) NULL
    ,[Name_PreferredFamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredGivenName] VARCHAR (111) NULL
    ,[Name_Suffix] VARCHAR (111) NULL
    ,[Name_FullName] VARCHAR (111) NULL
    ,[PositionTitle] VARCHAR (111) NULL
    ,[Role] VARCHAR (111) NULL
    ,[RegistrationDetails] VARCHAR (111) NULL
    ,[Qualifications] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LEAContactList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAContactList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [PK_LEAContactList] PRIMARY KEY ([LEAContactLocalId])
    ,CONSTRAINT [FK_LEAContactList_PublishInDirectory] FOREIGN KEY ([PublishInDirectory]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LEAContactList_FamilyNameFirst] FOREIGN KEY ([Name_FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LEAContactList_PreferredFamilyNameFirst] FOREIGN KEY ([Name_PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim2LEAContactInfo';
GO

-- ----------------- --
-- 3.10.5 SchoolInfo --
-- ----------------- --

-- BCE eMinerva Campus entity maps to SIF SchoolInfo entity
-- For now, each BCE school (in eMinerva Campus) has a single physical location
-- For as long as the above is true, recommend SIF Campus remains unused by BCE

CREATE TABLE cdm_demo_gold.Dim2SchoolInfo (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[CommonwealthId] VARCHAR (111) NULL
    ,[ParentCommonwealthId] VARCHAR (111) NULL
    ,[ACARAId] VARCHAR (111) NULL
    ,[SchoolName] VARCHAR (111) NOT NULL
    ,[LEAInfoRefId] CHAR (36) NULL
    ,[LEAInfoLocalId] INT NOT NULL
    ,[OtherLEARefId] CHAR (36) NULL
    ,[OtherLEALocalId] INT NOT NULL
    ,[SchoolDistrict] VARCHAR (111) NULL
    ,[SchoolDistrictLocalId] INT NULL
    ,[SchoolType] VARCHAR (17) NULL
    ,[SchoolURL] VARCHAR (255) NULL
    ,[PrincipalName_Title] VARCHAR (111) NULL
    ,[PrincipalName_FamilyName] VARCHAR (111) NULL
    ,[PrincipalName_GivenName] VARCHAR (111) NULL
    ,[PrincipalName_MiddleName] VARCHAR (111) NULL
    ,[PrincipalName_FamilyNameFirst] CHAR (1) NULL
    ,[PrincipalName_PreferredFamilyName] VARCHAR (111) NULL
    ,[PrincipalName_PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PrincipalName_PreferredGivenName] VARCHAR (111) NULL
    ,[PrincipalName_Suffix] VARCHAR (111) NULL
    ,[PrincipalName_FullName] VARCHAR (111) NULL
    ,[PrincipalName_NameUsageTypeKey] CHAR (3) NOT NULL
    ,[PrincipalTitle] VARCHAR (111) NULL
    ,[SessionType] CHAR (4) NULL
    ,[ARIAScore] DECIMAL (5,3) NULL -- 0.000 to 15.000
    ,[ARIAClass] SMALLINT NULL -- 1 to 5
    ,[OperationalStatus] CHAR (1) NULL
    ,[FederalElectorate] SMALLINT NULL
    ,[SchoolSector] VARCHAR (3) NOT NULL
    ,[IndependentSchool] CHAR (1) NULL
    ,[NonGovSystemicStatus] CHAR (1) NULL
    ,[SchoolSystem] CHAR (4) NULL
    ,[ReligiousAffiliation] VARCHAR (6) NULL
    ,[SchoolGeographicLocation] VARCHAR (5) NULL
    ,[LocalGovernmentArea] VARCHAR (111) NULL
    ,[JurisdictionLowerHouse] VARCHAR (111) NULL
    ,[SLA] VARCHAR (111) NULL
    ,[SchoolCoEdStatus] CHAR (1) NULL
    ,[BoardingSchoolStatus] CHAR (1) NULL
    ,[TotalEnrolled_AllStudents] INT NULL
    ,[TotalEnrolled_Girls] INT NULL
    ,[TotalEnrolled_Boys] INT NULL
    ,[Entity_Open] DATETIME NULL
    ,[Entity_Close] DATETIME NULL
    ,[SchoolTimeZone] VARCHAR (5) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_SchoolInfo] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_SchoolInfo] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_SchoolInfo] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_SchoolInfo_LEARefId] FOREIGN KEY ([LEAInfoRefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FK_SchoolInfo_LEALocalId] FOREIGN KEY ([LEAInfoLocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FK_SchoolInfo_OtherLEARefId] FOREIGN KEY ([OtherLEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FK_SchoolInfo_OtherLEALocalId] FOREIGN KEY ([OtherLEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FK_SchoolInfo_SchoolDistrictLocalId] FOREIGN KEY ([SchoolDistrictLocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FK_SchoolInfo_SchoolType] FOREIGN KEY ([SchoolType]) REFERENCES cdm_demo_gold.Dim0SchoolLevelType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_FamilyNameFirst] FOREIGN KEY ([PrincipalName_FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_PreferredFamilyNameFirst] FOREIGN KEY ([PrincipalName_PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_NameUsageType] FOREIGN KEY ([PrincipalName_NameUsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_SessionType] FOREIGN KEY ([SessionType]) REFERENCES cdm_demo_gold.Dim0SessionType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_ARIAClass] FOREIGN KEY ([ARIAClass]) REFERENCES cdm_demo_gold.Dim0ARIAClass ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_OperationalStatus] FOREIGN KEY ([OperationalStatus]) REFERENCES cdm_demo_gold.Dim0OperationalStatus ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_FederalElectorate] FOREIGN KEY ([FederalElectorate]) REFERENCES cdm_demo_gold.Dim0FederalElectorateList ([FederalDivisionAlphabeticalId])
    ,CONSTRAINT [FK_SchoolInfo_SchoolSector] FOREIGN KEY ([SchoolSector]) REFERENCES cdm_demo_gold.Dim0SchoolSectorCode ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_IndependentSchool] FOREIGN KEY ([IndependentSchool]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_NonGovSystemicStatus] FOREIGN KEY ([NonGovSystemicStatus]) REFERENCES cdm_demo_gold.Dim0SystemicStatus ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_SchoolSystem] FOREIGN KEY ([SchoolSystem]) REFERENCES cdm_demo_gold.Dim0SchoolSystemType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_ReligiousAffiliation] FOREIGN KEY ([ReligiousAffiliation]) REFERENCES cdm_demo_gold.Dim0ReligionType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_SchoolGeographicLocation] FOREIGN KEY ([SchoolGeographicLocation]) REFERENCES cdm_demo_gold.Dim0SchoolGeographicLocationType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_SchoolCoEdStatus] FOREIGN KEY ([SchoolCoEdStatus]) REFERENCES cdm_demo_gold.Dim0SchoolCoEdStatus ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_BoardingSchoolStatus] FOREIGN KEY ([BoardingSchoolStatus]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolInfo_SchoolTimeZone] FOREIGN KEY ([SchoolTimeZone]) REFERENCES cdm_demo_gold.Dim0AusTimeZoneList ([TimeZoneCode])
);
PRINT N'Created cdm_demo_gold.Dim2SchoolInfo';
GO

-- --------------- --
-- 3.10.1 Identity --
-- --------------- --

CREATE TABLE cdm_demo_gold.Dim2PartyList (
-- Party RefId & LocalId are just the three Dim1 party types coalesced together
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[PartyType] VARCHAR (14) NOT NULL
    ,[StaffRefId] CHAR (36) NULL
    ,[StaffLocalId] INT NULL
    ,[StudentRefId] CHAR (36) NULL
    ,[StudentLocalId] INT NULL
    ,[StudentContactRefId] CHAR (36) NULL
    ,[StudentContactLocalId] INT NULL
    ,CONSTRAINT [RefUnique_Party] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_Party] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_Party] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_Party_PartyType] FOREIGN KEY ([PartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FKRef_PartyList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_PartyList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FKRef_PartyList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_PartyList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [FKRef_PartyList_StudentContactPersonal] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_PartyList_StudentContactPersonal] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2PartyList';
GO

-- ---------------------------------- --
-- SUBSECTION: 3.8.1 LearningResource --
-- ---------------------------------- --

CREATE TABLE cdm_demo_gold.Dim2LearningResource (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[Name] VARCHAR (111) NOT NULL
    ,[Author] VARCHAR (111) NULL
    ,[LocationReference] VARCHAR (111) NULL
    ,[LocationType] VARCHAR (111) NULL
    ,[Status] VARCHAR (111) NULL
    ,[Description] VARCHAR (800) NULL
    ,[UseAgreement] VARCHAR (800) NULL
    ,[AgreementDate] DATETIME NULL
    ,[LearningResourcePackageRefId] CHAR (36) NULL
    ,CONSTRAINT [RefUnique_LearningResource] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_LearningResource] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LearningResource] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FKRef_LearningResource_LearningResourcePackage] FOREIGN KEY ([LearningResourcePackageRefId]) REFERENCES cdm_demo_gold.Dim1LearningResourcePackage ([RefId])
);
PRINT N'Created cdm_demo_gold.Dim2LearningResource';
GO

CREATE TABLE cdm_demo_gold.Dim2LearningResourceContactList (
     [LocalId] INT NOT NULL
    ,CONSTRAINT [PK_LearningResourceContactList] PRIMARY KEY ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2LearningResourceContactList';
GO

-- TO-DO: Dim2LearningStandardDocument = a catalogue of learning standards documentation





-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 3 in name have FK to table(s) with 2               --
-- -------------------------------------------------------------------------- --

-- -------------- --
-- 3.10.2 LEAInfo --
-- -------------- --

CREATE TABLE cdm_demo_gold.Dim3LEAContactAddressList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[LEAContactLocalId] VARCHAR (111) NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LEAContactAddressList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAContactAddressList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FKLocal_LEAContactAddressList_LEAContactInfo] FOREIGN KEY ([LEAContactLocalId]) REFERENCES cdm_demo_gold.Dim2LEAContactList ([LEAContactLocalId])
    ,CONSTRAINT [PK_LEAContactAddressList] PRIMARY KEY ([LEAContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_LEAContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_LEAContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_LEAContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3LEAContactAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim3LEAContactPhoneNumberList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[LEAContactLocalId] VARCHAR (111) NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_LEAContactPhoneNumberList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAContactPhoneNumberList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FKLocal_LEAContactPhoneNumberList_LEAContactInfo] FOREIGN KEY ([LEAContactLocalId]) REFERENCES cdm_demo_gold.Dim2LEAContactList ([LEAContactLocalId])
    ,CONSTRAINT [PK_LEAContactPhoneNumberList] PRIMARY KEY ([LEAContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_LEAContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3LEAContactPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim3LEAContactEmailList (
     [LEARefId] CHAR (36) NOT NULL
    ,[LEALocalId] INT NOT NULL
    ,[LEAContactLocalId] VARCHAR (111) NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_LEAContactEmailList_LEAInfo] FOREIGN KEY ([LEARefId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([RefId])
    ,CONSTRAINT [FKLocal_LEAContactEmailList_LEAInfo] FOREIGN KEY ([LEALocalId]) REFERENCES cdm_demo_gold.Dim1LEAInfo ([LocalId])
    ,CONSTRAINT [FKLocal_LEAContactEmailList_LEAContactInfo] FOREIGN KEY ([LEAContactLocalId]) REFERENCES cdm_demo_gold.Dim2LEAContactList ([LEAContactLocalId])
    ,CONSTRAINT [PK_LEAContactEmailList] PRIMARY KEY ([LEAContactLocalId],[EmailType])
    ,CONSTRAINT [FK_LEAContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3LEAContactEmailList';
GO

-- ----------------- --
-- 3.10.5 SchoolInfo --
-- ----------------- --

CREATE TABLE cdm_demo_gold.Dim3SchoolOtherIdList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[OtherIdValue] VARCHAR (111) NULL
    ,[OtherIdType] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_SchoolOtherIdList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolOtherIdList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolOtherIdList] PRIMARY KEY ([SchoolLocalId],[OtherIdType])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolOtherIdList';

CREATE TABLE cdm_demo_gold.Dim3SchoolFocus (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolFocus] CHAR(2) NOT NULL
    ,CONSTRAINT [FKRef_SchoolFocus_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolFocus_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolFocus] PRIMARY KEY ([SchoolLocalId],[SchoolFocus])
    ,CONSTRAINT [FK_SchoolFocus] FOREIGN KEY ([SchoolFocus]) REFERENCES cdm_demo_gold.Dim0SchoolFocusCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolFocus';

CREATE TABLE cdm_demo_gold.Dim3SchoolAddressList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_SchoolAddressList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolAddressList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolAddressList] PRIMARY KEY ([SchoolLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_SchoolAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_SchoolAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_SchoolAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim3SchoolPhoneNumberList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_SchoolPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolPhoneNumberList] PRIMARY KEY ([SchoolLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_SchoolPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim3SchoolEmailList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_SchoolEmailList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolEmailList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolEmailList] PRIMARY KEY ([SchoolLocalId],[EmailType])
    ,CONSTRAINT [FK_SchoolEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolEmailList';
GO

CREATE TABLE cdm_demo_gold.Dim3SchoolPrincipalPhoneNumberList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_SchoolPrincipalPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolPrincipalPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolPrincipalPhoneNumberList] PRIMARY KEY ([SchoolLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_SchoolPrincipalPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolPrincipalPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim3SchoolPrincipalEmailList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_SchoolPrincipalEmailList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolPrincipalEmailList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolPrincipalEmailList] PRIMARY KEY ([SchoolLocalId],[EmailType])
    ,CONSTRAINT [FK_SchoolPrincipalEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolPrincipalEmailList';
GO

CREATE TABLE cdm_demo_gold.Dim3SchoolContactList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolContactLocalId] VARCHAR (111) NOT NULL
    ,[PublishInDirectory] CHAR (1) NULL
    ,[Name_Title] VARCHAR (111) NULL
    ,[Name_FamilyName] VARCHAR (111) NULL
    ,[Name_GivenName] VARCHAR (111) NULL
    ,[Name_MiddleName] VARCHAR (111) NULL
    ,[Name_FamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredFamilyName] VARCHAR (111) NULL
    ,[Name_PreferredFamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredGivenName] VARCHAR (111) NULL
    ,[Name_Suffix] VARCHAR (111) NULL
    ,[Name_FullName] VARCHAR (111) NULL
    ,[PositionTitle] VARCHAR (111) NULL
    ,[Role] VARCHAR (111) NULL
    ,[RegistrationDetails] VARCHAR (111) NULL
    ,[Qualifications] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_SchoolContactList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolContactList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolContactList] PRIMARY KEY ([SchoolContactLocalId])
    ,CONSTRAINT [FK_SchoolContactList_PublishInDirectory] FOREIGN KEY ([PublishInDirectory]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolContactList_FamilyNameFirst] FOREIGN KEY ([Name_FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_SchoolContactList_PreferredFamilyNameFirst] FOREIGN KEY ([Name_PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolContactInfo';
GO

-- For now, each BCE school (in eMinerva Campus) has a single physical location
-- For as long as the above is true, recommend SIF Campus remains unused by BCE
CREATE TABLE cdm_demo_gold.Dim3SchoolCampus (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolCampusId] VARCHAR (111) NOT NULL
    ,[CampusType] VARCHAR (17) NULL
    ,[AdminStatus] CHAR (1) NOT NULL
    ,CONSTRAINT [FKRef_SchoolCampus_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolCampus_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolCampus] PRIMARY KEY ([SchoolCampusId])
    ,CONSTRAINT [FK_SchoolCampus_CampusType] FOREIGN KEY ([CampusType]) REFERENCES cdm_demo_gold.Dim0SchoolLevelType ([TypeKey])
    ,CONSTRAINT [FK_SchoolCampus_AdminStatus] FOREIGN KEY ([AdminStatus]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolCampus';
GO

-- While BCE may not need SIF Campus it does have geographic clusters to put into SchoolGroup
CREATE TABLE cdm_demo_gold.Dim3SchoolGroup (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[GroupId] VARCHAR (111) NOT NULL
    ,[GroupName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_SchoolGroup_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolGroup_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolGroup] PRIMARY KEY ([SchoolLocalId],[GroupId])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolGroup';
GO

-- This table to capture schools and the years they teach, doubles up with enrollment by year, below
-- Both included to show complete SIF spec, but just implement enrollment by year and drop this one
CREATE TABLE cdm_demo_gold.Dim3SchoolYearLevels (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[YearLevelCode] VARCHAR (8) NOT NULL
    ,CONSTRAINT [FKRef_SchoolYearLevels_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolYearLevels_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [PK_SchoolYearLevels] PRIMARY KEY ([SchoolLocalId],[YearLevelCode])
    ,CONSTRAINT [FK_SchoolYearLevels_YearLevelCode] FOREIGN KEY ([YearLevelCode]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolYearLevels';
GO

-- This table to capture school enrollment by year, doubles up with Dim3SchoolYearLevel, above
-- Both included to show complete SIF spec, but just implement this table & drop the one above
CREATE TABLE cdm_demo_gold.Dim3SchoolEnrollmentByYearLevel (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[Year] VARCHAR (8) NOT NULL
    ,[Enrollment] INT NULL
    ,CONSTRAINT [FKRef_SchoolEnrollmentByYear_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolEnrollmentByYear_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FK_SchoolEnrollmentByYear_SchoolInfo] FOREIGN KEY ([Year]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [PK_SchoolEnrollmentByYear] PRIMARY KEY ([SchoolLocalId],[Year])
);
PRINT N'Created cdm_demo_gold.Dim3SchoolEnrollmentByYearLevel';
GO

-- --------------- --
-- 3.10.1 Identity --
-- --------------- --

CREATE TABLE cdm_demo_gold.Dim3Identity (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[PartyRefId] CHAR (36) NOT NULL
    ,[PartyLocalId] INT NOT NULL
    ,[PartyType] VARCHAR (14) NOT NULL
    ,[AuthenticationSource] VARCHAR (63) NOT NULL
    ,[AuthenticationSourceGlobalUID] CHAR (36) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_Identity] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_Identity] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_Identity] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_Identity_PartyRefId] FOREIGN KEY ([PartyRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FK_Identity_PartyLocalId] FOREIGN KEY ([PartyLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_Identity_PartyType] FOREIGN KEY ([PartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FK_Identity_AuthenticationSource] FOREIGN KEY ([AuthenticationSource]) REFERENCES cdm_demo_gold.Dim0AuthenticationSource ([TypeKey])
    ,CONSTRAINT [AuthenticationSourceGlobalUID] CHECK ([RefId] LIKE '________-____-____-____-____________')
);
PRINT N'Created cdm_demo_gold.Dim3Identity';
GO

-- -------------------- --
-- 3.10.3 PersonPicture --
-- -------------------- --

CREATE TABLE cdm_demo_gold.Dim3PersonPicture (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] VARCHAR (111) NOT NULL
    ,[PartyRefId] CHAR (36) NOT NULL
    ,[PartyLocalId] INT NOT NULL
    ,[PartyType] VARCHAR (14) NOT NULL
    ,[SchoolYear] SMALLINT NOT NULL
    ,[URLtoPicture] VARCHAR (255) NULL
    ,[PictureBase64] VARCHAR (max) NULL
    ,[OKToPublish] CHAR (1) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_PersonPic] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_PersonPic] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_PersonPic] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FKRef_PersonPic_PartyList] FOREIGN KEY ([PartyRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_PersonPic_PartyList] FOREIGN KEY ([PartyLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_PersonPic_PartyType] FOREIGN KEY ([PartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FK_PersonPic_OKToPublish] FOREIGN KEY ([OKToPublish]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3PersonPicture';
GO

-- -------------------------------------- --
-- 3.10.4 PersonPrivacyObligationDocument --
-- -------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim3PersonPrivacyObligationDocument (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] VARCHAR (111) NOT NULL
    ,[PartyRefId] CHAR (36) NOT NULL
    ,[PartyLocalId] INT NOT NULL
    ,[PartyType] VARCHAR (14) NOT NULL
    ,[SchoolYear] SMALLINT NOT NULL
    ,[StartDate] DATETIME NULL
    ,[EndDate] DATETIME NULL
    ,[ContactForRequestsRefId] CHAR (36) NOT NULL
    ,[ContactForRequestsLocalId] INT NOT NULL
    ,[ContactForRequestsPartyType] VARCHAR (14) NOT NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_PersonPrivacy] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_PersonPrivacy] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_PersonPrivacy] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FKRef_PersonPrivacy_PartyList] FOREIGN KEY ([PartyRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_PersonPrivacy_PartyList] FOREIGN KEY ([PartyLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_PersonPrivacy_PartyType] FOREIGN KEY ([PartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FKRef_PersonPrivacy_ContactForRequestsPartyList] FOREIGN KEY ([ContactForRequestsRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_PersonPrivacy_ContactForRequestsPartyList] FOREIGN KEY ([ContactForRequestsLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_PersonPrivacy_ContactForRequestsPartyType] FOREIGN KEY ([ContactForRequestsPartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3PersonPrivacyObligationDocument';
GO

-- ---------------------- --
-- 3.10.6 StaffAssignment --
-- ---------------------- --

CREATE TABLE cdm_demo_gold.Fact3StaffAssignment (
     [RefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[SchoolYear] SMALLINT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[Description] VARCHAR (111) NULL
    ,[PrimaryAssignment] CHAR (1) NOT NULL
    ,[JobStartDate] DATETIME NULL
    ,[JobEndDate] DATETIME NULL
    ,[JobFTE] DECIMAL (3,2) NULL
    ,[JobFunction] VARCHAR (111) NULL
    ,[EmploymentStatus] CHAR (1) NULL
    ,[CasualReliefTeacher] CHAR (1) NULL
    ,[Homegroup] VARCHAR (111) NULL
    ,[House] VARCHAR (111) NULL
    ,[PreviousSchoolName] VARCHAR (111) NULL
    ,[AvailableForTimetable] CHAR (1) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StaffAssignment] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StaffAssignment] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StaffAssignment] PRIMARY KEY ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignment_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignment_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignment_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignment_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FK_StaffAssignment_PrimaryAssignment] FOREIGN KEY ([PrimaryAssignment]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [Check_StaffAssignment_JobFTE] CHECK (JobFTE >= 0 AND JobFTE <= 1)
    ,CONSTRAINT [FK_StaffAssignment_EmploymentStatus] FOREIGN KEY ([EmploymentStatus]) REFERENCES cdm_demo_gold.Dim0StaffEmploymentStatus ([TypeKey])
    ,CONSTRAINT [FK_StaffAssignment_CasualReliefTeacher] FOREIGN KEY ([CasualReliefTeacher]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StaffAssignment_AvailableForTimetable] FOREIGN KEY ([AvailableForTimetable]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact3StaffAssignment';
GO

-- --------------------------------- --
-- 3.10.9 StudentContactRelationship --
-- --------------------------------- --

CREATE TABLE cdm_demo_gold.Fact3StudentContactRelationship (
     [RefId] CHAR (36) NOT NULL
    ,[StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[StudentContactRefId] CHAR (36) NOT NULL
    ,[StudentContactLocalId] INT NOT NULL
    ,[RelationshipToStudent] CHAR (2) NOT NULL
    ,[ParentRelationshipStatus] VARCHAR (15) NULL
    ,[MainlySpeaksEnglishAtHome] CHAR (1) NULL
    ,[ContactSequence] INT NULL
    ,[ContactSequenceSource] CHAR (1) NULL
    ,[ContactMethod] VARCHAR (12) NULL
    ,[FeePercentage_Curriculum] DECIMAL (6,3) NULL
    ,[FeePercentage_Other] DECIMAL (6,3) NULL
    ,[SchoolInfoRefId] CHAR (36) NULL
    ,[SchoolInfoLocalId] INT NULL
    ,[ContactFlag_ParentLegalGuardian] CHAR (1) NULL
    ,[ContactFlag_PickupRights] CHAR (1) NULL
    ,[ContactFlag_LivesWith] CHAR (1) NULL
    ,[ContactFlag_AccessToRecords] CHAR (1) NULL
    ,[ContactFlag_ReceivesAssessmentReport] CHAR (1) NULL
    ,[ContactFlag_EmergencyContact] CHAR (1) NULL
    ,[ContactFlag_HasCustody] CHAR (1) NULL
    ,[ContactFlag_DisciplinaryContact] CHAR (1) NULL
    ,[ContactFlag_AttendanceContact] CHAR (1) NULL
    ,[ContactFlag_PrimaryCareProvider] CHAR (1) NULL
    ,[ContactFlag_FeesBilling] CHAR (1) NULL
    ,[ContactFlag_FeesAccess] CHAR (1) NULL
    ,[ContactFlag_FamilyMail] CHAR (1) NULL
    ,[ContactFlag_InterventionOrder] CHAR (1) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StudentContactRelationship] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentContactRelationship] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentContactRelationship] PRIMARY KEY ([RefId])
    ,CONSTRAINT [FKRef_StudentContactRelationship_Student] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactRelationship_Student] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [FKRef_StudentContactRelationship_Contact] FOREIGN KEY ([StudentContactRefId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactRelationship_Contact] FOREIGN KEY ([StudentContactLocalId]) REFERENCES cdm_demo_gold.Dim1StudentContactPersonal ([LocalId])
    ,CONSTRAINT [FK_StudentContactRelationship_RelationshipToStudent] FOREIGN KEY ([RelationshipToStudent]) REFERENCES cdm_demo_gold.Dim0RelationshipToStudentType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ParentRelationshipStatus] FOREIGN KEY ([ParentRelationshipStatus]) REFERENCES cdm_demo_gold.Dim0ParentRelationshipStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_MainlySpeaksEnglishAtHome] FOREIGN KEY ([MainlySpeaksEnglishAtHome]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactSequenceSource] FOREIGN KEY ([ContactSequenceSource]) REFERENCES cdm_demo_gold.Dim0ContactSourceType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactMethod] FOREIGN KEY ([ContactMethod]) REFERENCES cdm_demo_gold.Dim0ContactMethod ([TypeKey])
    ,CONSTRAINT [Check_StudentContactRelationship_FeePercentage_Curriculum] CHECK (FeePercentage_Curriculum >= 0 AND FeePercentage_Curriculum <= 100)
    ,CONSTRAINT [Check_StudentContactRelationship_FeePercentage_Other] CHECK (FeePercentage_Other >= 0 AND FeePercentage_Other <= 100)
    ,CONSTRAINT [FKRef_StudentContactRelationship_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentContactRelationship_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_ParentLegalGuardian] FOREIGN KEY ([ContactFlag_ParentLegalGuardian]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_PickupRights] FOREIGN KEY ([ContactFlag_PickupRights]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_LivesWith] FOREIGN KEY ([ContactFlag_LivesWith]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_AccessToRecords] FOREIGN KEY ([ContactFlag_AccessToRecords]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_ReceivesAssessmentReport] FOREIGN KEY ([ContactFlag_ReceivesAssessmentReport]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_EmergencyContact] FOREIGN KEY ([ContactFlag_EmergencyContact]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_HasCustody] FOREIGN KEY ([ContactFlag_HasCustody]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_DisciplinaryContact] FOREIGN KEY ([ContactFlag_DisciplinaryContact]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_AttendanceContact] FOREIGN KEY ([ContactFlag_AttendanceContact]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_PrimaryCareProvider] FOREIGN KEY ([ContactFlag_PrimaryCareProvider]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_FeesBilling] FOREIGN KEY ([ContactFlag_FeesBilling]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_FeesAccess] FOREIGN KEY ([ContactFlag_FeesAccess]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_FamilyMail] FOREIGN KEY ([ContactFlag_FamilyMail]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentContactRelationship_ContactFlag_InterventionOrder] FOREIGN KEY ([ContactFlag_InterventionOrder]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact3StudentContactRelationship';
GO

-- ------------------------------- --
-- 3.10.11 StudentSchoolEnrollment --
-- ------------------------------- --

CREATE TABLE cdm_demo_gold.Fact3StudentSchoolEnrollment (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[MembershipType] CHAR (2) NOT NULL
    ,[TimeFrame] CHAR (1) NOT NULL
    ,[SchoolYear] SMALLINT NOT NULL
    ,[IntendedEntryDate] DATETIME NULL
    ,[EntryDate] DATETIME NOT NULL
    ,[EntryCode] CHAR (4) NULL
    ,[YearLevel] VARCHAR (8) NULL
-- No entity to become FK for Homeroom (yet) in Phase 1 implementation:
    ,[HomeroomRefId] CHAR (36) NULL
    ,[HomeroomLocalId] VARCHAR (111) NULL
-- FKs to staff for Advisor & Counselor:
    ,[AdvisorRefId] CHAR (36) NULL
    ,[AdvisorLocalId] INT NULL
    ,[CounselorRefId] CHAR (36) NULL
    ,[CounselorLocalId] INT NULL
    ,[Homegroup] VARCHAR (111) NULL
    ,[ACARASchoolId] VARCHAR (111) NULL
    ,[ClassCode] VARCHAR (111) NULL
-- FK to Dim0YearLevelCode:
    ,[TestLevel] VARCHAR (8) NULL
    ,[ReportingSchool] CHAR (1) NULL
    ,[House] VARCHAR (111) NULL
-- No entity to become FK for Calendar (yet) in Phase 1 implementation:
    ,[CalendarRefId] CHAR (36) NULL
    ,[CalendarLocalId] VARCHAR (111) NULL
    ,[IndividualLearningPlan] CHAR (1) NULL
    ,[ExitDate] DATETIME NULL
    ,[ExitCode] CHAR (4) NULL
    ,[ExitStatus] CHAR (4) NULL
    ,[FTE] DECIMAL (3,2) NULL
    ,[FTPTStatus] VARCHAR (2) NULL
    ,[FFPOS] INT NULL
    ,[CatchmentStatusCode] CHAR (4) NULL
    ,[RecordClosureReason] VARCHAR (23) NULL
    ,[PromotionInfo] VARCHAR (8) NULL
    ,[PreviousSchool] VARCHAR (111) NULL
    ,[PreviousSchoolName] VARCHAR (111) NULL
    ,[DestinationSchool] VARCHAR (111) NULL
    ,[DestinationSchoolName] VARCHAR (111) NULL
    ,[StartedAtSchoolDate] DATETIME NULL
    ,[DisabilityLevelOfAdjustment] VARCHAR (71) NULL
    ,[DisabilityCategory] VARCHAR (16) NULL
    ,[CensusAge] INT NULL
    ,[DistanceEducationStudent] CHAR (1) NULL
    ,[BoardingStatus] CHAR (1) NULL
    ,[InternationalStudent] CHAR (1) NULL
    ,[ToSchool_TravelMode] CHAR (1) NULL
    ,[ToSchool_TravelDetails] VARCHAR (255) NULL
    ,[ToSchool_TravelAccompaniment] CHAR (1) NULL
    ,[FromSchool_TravelMode] CHAR (1) NULL
    ,[FromSchool_TravelDetails] VARCHAR (255) NULL
    ,[FromSchool_TravelAccompaniment] CHAR (1) NULL
    ,CONSTRAINT [RefUnique_StudentSchoolEnrollment] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentSchoolEnrollment] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentSchoolEnrollment] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollment_Student] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollment_Student] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollment_School] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollment_School] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_MembershipType] FOREIGN KEY ([MembershipType]) REFERENCES cdm_demo_gold.Dim0SchoolEnrollmentType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_TimeFrame] FOREIGN KEY ([TimeFrame]) REFERENCES cdm_demo_gold.Dim0EnrollmentTimeFrame ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_EntryCode] FOREIGN KEY ([EntryCode]) REFERENCES cdm_demo_gold.Dim0EnrollmentEntryType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_YearLevel] FOREIGN KEY ([YearLevel]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollment_AdvisorStaff] FOREIGN KEY ([AdvisorRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollment_AdvisorStaff] FOREIGN KEY ([AdvisorLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollment_CounselorStaff] FOREIGN KEY ([CounselorRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollment_CounselorStaff] FOREIGN KEY ([CounselorLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_TestLevel] FOREIGN KEY ([TestLevel]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_ReportingSchool] FOREIGN KEY ([ReportingSchool]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_IndividualLearningPlan] FOREIGN KEY ([IndividualLearningPlan]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_ExitCode] FOREIGN KEY ([ExitCode]) REFERENCES cdm_demo_gold.Dim0EnrollmentExitWithdrawalType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_ExitStatus] FOREIGN KEY ([ExitStatus]) REFERENCES cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus ([TypeKey])
    ,CONSTRAINT [Check_StudentSchoolEnrollment_FTE] CHECK (FTE >= 0 AND FTE <= 1)
    ,CONSTRAINT [FK_StudentSchoolEnrollment_FTPTStatus] FOREIGN KEY ([FTPTStatus]) REFERENCES cdm_demo_gold.Dim0FullTimePartTimeStatusCode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_FFPOS] FOREIGN KEY ([FFPOS]) REFERENCES cdm_demo_gold.Dim0FFPOSStatusCode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_CatchmentStatusCode] FOREIGN KEY ([CatchmentStatusCode]) REFERENCES cdm_demo_gold.Dim0PublicSchoolCatchmentStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_RecordClosureReason] FOREIGN KEY ([RecordClosureReason]) REFERENCES cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_PromotionInfo] FOREIGN KEY ([PromotionInfo]) REFERENCES cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_DisabilityLevelOfAdjustment] FOREIGN KEY ([DisabilityLevelOfAdjustment]) REFERENCES cdm_demo_gold.Dim0DisabilityLevelOfAdjustment ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_DisabilityCategory] FOREIGN KEY ([DisabilityCategory]) REFERENCES cdm_demo_gold.Dim0DisabilityNCCDCategory ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_DistanceEducationStudent] FOREIGN KEY ([DistanceEducationStudent]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_BoardingStatus] FOREIGN KEY ([BoardingStatus]) REFERENCES cdm_demo_gold.Dim0BoardingStatus ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_InternationalStudent] FOREIGN KEY ([InternationalStudent]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_ToSchool_TravelMode] FOREIGN KEY ([ToSchool_TravelMode]) REFERENCES cdm_demo_gold.Dim0TravelMode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_ToSchool_TravelAccompaniment] FOREIGN KEY ([ToSchool_TravelAccompaniment]) REFERENCES cdm_demo_gold.Dim0TravelAccompaniment ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_FromSchool_TravelMode] FOREIGN KEY ([FromSchool_TravelMode]) REFERENCES cdm_demo_gold.Dim0TravelMode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollment_FromSchool_TravelAccompaniment] FOREIGN KEY ([FromSchool_TravelAccompaniment]) REFERENCES cdm_demo_gold.Dim0TravelAccompaniment ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact3StudentSchoolEnrollment';
GO

-- ---------------------------------- --
-- SUBSECTION: 3.8.1 LearningResource --
-- ---------------------------------- --

CREATE TABLE cdm_demo_gold.Bridge3LearningResourceContacts (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ContactLocalId] INT NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceContacts_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceContacts_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKLocal_LearningResourceContacts_ContactLocalId] FOREIGN KEY ([ContactLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResourceContactList ([LocalId])
    ,CONSTRAINT [PK_LearningResourceContacts] PRIMARY KEY ([LearningResourceLocalId],[ContactLocalId])
);
PRINT N'Created cdm_demo_gold.Bridge3LearningResourceContacts';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceYearLevels (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[YearLevelCode] VARCHAR (8) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceYearLevels_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceYearLevels_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FK_LearningResourceYearLevels_YearLevelCode] FOREIGN KEY ([YearLevelCode]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [PK_LearningResourceYearLevels] PRIMARY KEY ([LearningResourceLocalId],[YearLevelCode])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceYearLevels';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceAustralianCurriculumStrandandSubjectAreas (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ACStrand] CHAR (1) NOT NULL
    ,[SubjectAreaCode] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LearningResourceAustralianCurriculumStrandandSubjectAreas_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceAustralianCurriculumStrandandSubjectAreas_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FK_LearningResourceAustralianCurriculumStrandandSubjectAreas_ACStrand] FOREIGN KEY ([ACStrand]) REFERENCES cdm_demo_gold.Dim0AustralianCurriculumStrand ([TypeKey])
    ,CONSTRAINT [PK_LearningResourceAustralianCurriculumStrandandSubjectAreas] PRIMARY KEY ([LearningResourceLocalId],[ACStrand])
    ,CONSTRAINT [RefUnique_SearningResourceAustralianCurriculumStrandandSubjectAreas] UNIQUE ([LearningResourceLocalId],[ACStrand],[SubjectAreaCode])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceAustralianCurriculumStrandandSubjectAreas';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceMediaTypes (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[MIMEType] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceMediaTypes_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceMediaTypes_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [PK_LearningResourceMediaTypes] PRIMARY KEY ([LearningResourceLocalId],[MIMEType])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceMediaTypes';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceApprovals (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ApprovalOrganisation] VARCHAR (111) NOT NULL
    ,[ApprovalDate] DATETIME NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceApprovals_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceApprovals_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [PK_LearningResourceApprovals] PRIMARY KEY ([LearningResourceLocalId],[ApprovalOrganisation],[ApprovalDate])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceApprovals';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceEvaluations (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[EvaluationRefId] CHAR (36) NOT NULL
    ,[Description] VARCHAR (111) NOT NULL
    ,[EvaluationDate] DATETIME NOT NULL
    ,[Name_Title] VARCHAR (111) NULL
    ,[Name_FamilyName] VARCHAR (111) NULL
    ,[Name_GivenName] VARCHAR (111) NULL
    ,[Name_MiddleName] VARCHAR (111) NULL
    ,[Name_FamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredFamilyName] VARCHAR (111) NULL
    ,[Name_PreferredFamilyNameFirst] CHAR (1) NULL
    ,[Name_PreferredGivenName] VARCHAR (111) NULL
    ,[Name_Suffix] VARCHAR (111) NULL
    ,[Name_FullName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LearningResourceEvaluations_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceEvaluations_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [RefUnique_LearningResourceEvaluations] UNIQUE ([EvaluationRefId])
    ,CONSTRAINT [RefUUID_LearningResourceEvaluations] CHECK ([EvaluationRefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LearningResourceEvaluations] PRIMARY KEY ([LearningResourceLocalId],[EvaluationRefId])
    ,CONSTRAINT [FK_LearningResourceEvaluations_Name_FamilyNameFirst] FOREIGN KEY ([Name_FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceEvaluations_Name_PreferredFamilyNameFirst] FOREIGN KEY ([Name_PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceEvaluations';
GO

CREATE TABLE cdm_demo_gold.Dim3LearningResourceComponents (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ComponentName] VARCHAR (111) NOT NULL
    ,[ComponentReference] VARCHAR (111) NOT NULL
    ,[Description] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LearningResourceComponents_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceComponents_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [PK_LearningResourceComponents] PRIMARY KEY ([LearningResourceLocalId],[ComponentName])
);
PRINT N'Created cdm_demo_gold.Dim3LearningResourceComponents';
GO

-- TO-DO: Bridge3LearningResourcesLearningStandardItems = links relevant learning standard items to each learning resource

-- -------------------------------------- --
-- SUBSECTION: 3.11.2 LibraryPatronStatus --
-- -------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim3LibraryPatronStatus (
     [RefId] CHAR (36) NOT NULL
    ,[LibraryType] VARCHAR (111) NOT NULL
    ,[PatronRefId] CHAR (36) NOT NULL
    ,[PatronLocalId] INT NOT NULL
    ,[PatronRefObject] VARCHAR (14) NOT NULL
    ,[PatronName_Title] VARCHAR (111) NULL
    ,[PatronName_FamilyName] VARCHAR (111) NULL
    ,[PatronName_GivenName] VARCHAR (111) NULL
    ,[PatronName_MiddleName] VARCHAR (111) NULL
    ,[PatronName_FamilyNameFirst] CHAR (1) NULL
    ,[PatronName_PreferredFamilyName] VARCHAR (111) NULL
    ,[PatronName_PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PatronName_PreferredGivenName] VARCHAR (111) NULL
    ,[PatronName_Suffix] VARCHAR (111) NULL
    ,[PatronName_FullName] VARCHAR (111) NULL
    ,[PatronName_UsageTypeKey] CHAR (3) NOT NULL
    ,[NumberOfCheckouts] INT NOT NULL
    ,[NumberOfHoldItems] INT NULL
    ,[NumberOfOverdues] INT NULL
    ,[NumberOfFines] INT NULL
    ,[NumberOfRefunds] INT NULL
-- Not fining/refunding more than AUD 9,999.99
    ,[FineAmount] DECIMAL (6,4) NULL
    ,[RefundAmount] DECIMAL (6,4) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_LibraryPatronStatus] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_LibraryPatronStatus] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LibraryPatronStatus] PRIMARY KEY ([PatronLocalId])
    ,CONSTRAINT [FKRef_LibraryPatronStatus_PartyList] FOREIGN KEY ([PatronRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_LibraryPatronStatus_PartyList] FOREIGN KEY ([PatronLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_LibraryPatronStatus_PartyType] FOREIGN KEY ([PatronRefObject]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FK_LibraryPatronStatus_FamilyNameFirst] FOREIGN KEY ([PatronName_FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LibraryPatronStatus_PreferredFamilyNameFirst] FOREIGN KEY ([PatronName_PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LibraryPatronStatus_NameUsageTypeKey] FOREIGN KEY ([PatronName_UsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
    ,CONSTRAINT [Check_LibraryPatronStatus_NumberOfCheckouts] CHECK ([NumberOfCheckouts]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_NumberOfHoldItems] CHECK ([NumberOfHoldItems]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_NumberOfOverdues] CHECK ([NumberOfOverdues]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_NumberOfFines] CHECK ([NumberOfFines]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_NumberOfRefunds] CHECK ([NumberOfRefunds]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_FineAmount] CHECK ([FineAmount]>=0)
    ,CONSTRAINT [Check_LibraryPatronStatus_RefundAmount] CHECK ([RefundAmount]>=0)
);
PRINT N'Created cdm_demo_gold.Dim3LibraryPatronStatus';
GO

-- --------------- --
-- 3.10.5 RoomInfo --
-- --------------- --

CREATE TABLE cdm_demo_gold.Dim3RoomInfo (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[RoomNumber] VARCHAR (111) NOT NULL
    ,[Description] VARCHAR (111) NULL
    ,[Building] VARCHAR (111) NULL
    ,[HomeroomNumber] VARCHAR (111) NULL
    ,[Size] DECIMAL (9,6) NULL
    ,[Capacity] INT NULL
    ,[RoomPhone_Number] VARCHAR (111) NULL
    ,[RoomPhone_Extension] VARCHAR (111) NULL
    ,[RoomType] VARCHAR (111) NULL
    ,[AvailableForTimetable] CHAR (1) NULL
    ,[ee_Placeholder] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_RoomInfo] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_RoomInfo] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_RoomInfo] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FKRef_RoomInfo_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_RoomInfo_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKLocal_RoomInfo_AvailableForTimetable] FOREIGN KEY ([AvailableForTimetable]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim3RoomInfo';
GO





-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 4 in name have FK to table(s) with 3               --
-- -------------------------------------------------------------------------- --

-- ----------------- --
-- 3.10.5 SchoolInfo --
-- ----------------- --

CREATE TABLE cdm_demo_gold.Dim4SchoolContactAddressList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolContactLocalId] VARCHAR (111) NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_SchoolContactAddressList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolContactAddressList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKLocal_SchoolContactAddressList_SchoolContactInfo] FOREIGN KEY ([SchoolContactLocalId]) REFERENCES cdm_demo_gold.Dim3SchoolContactList ([SchoolContactLocalId])
    ,CONSTRAINT [PK_SchoolContactAddressList] PRIMARY KEY ([SchoolContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_SchoolContactAddressList_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_SchoolContactAddressList_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_SchoolContactAddressList_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4SchoolContactAddressList';
GO

CREATE TABLE cdm_demo_gold.Dim4SchoolContactPhoneNumberList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolContactLocalId] VARCHAR (111) NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_SchoolContactPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolContactPhoneNumberList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKLocal_SchoolContactPhoneNumberList_SchoolContactInfo] FOREIGN KEY ([SchoolContactLocalId]) REFERENCES cdm_demo_gold.Dim3SchoolContactList ([SchoolContactLocalId])
    ,CONSTRAINT [PK_SchoolContactPhoneNumberList] PRIMARY KEY ([SchoolContactLocalId],[PhoneNumberType])
    ,CONSTRAINT [FK_SchoolContactPhoneNumberList_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4SchoolContactPhoneNumberList';
GO

CREATE TABLE cdm_demo_gold.Dim4SchoolContactEmailList (
     [SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[SchoolContactLocalId] VARCHAR (111) NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_SchoolContactEmailList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_SchoolContactEmailList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKLocal_SchoolContactEmailList_SchoolContactInfo] FOREIGN KEY ([SchoolContactLocalId]) REFERENCES cdm_demo_gold.Dim3SchoolContactList ([SchoolContactLocalId])
    ,CONSTRAINT [PK_SchoolContactEmailList] PRIMARY KEY ([SchoolContactLocalId],[EmailType])
    ,CONSTRAINT [FK_SchoolContactEmailList_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4SchoolContactEmailList';
GO

-- --------------- --
-- 3.10.1 Identity --
-- --------------- --

CREATE TABLE cdm_demo_gold.Dim4IdentityAssertions (
     [IdentityRefId] CHAR (36) NOT NULL
    ,[IdentityLocalId] INT NOT NULL
    ,[IdentityAssertionString] VARCHAR (111) NOT NULL
    ,[SchemaName] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FK_IdentityAssertions_IdentityRefId] FOREIGN KEY ([IdentityRefId]) REFERENCES cdm_demo_gold.Dim3Identity ([RefId])
    ,CONSTRAINT [FK_IdentityAssertions_IdentityLocalId] FOREIGN KEY ([IdentityLocalId]) REFERENCES cdm_demo_gold.Dim3Identity ([LocalId])
    ,CONSTRAINT [PK_IdentityAssertions] PRIMARY KEY ([IdentityLocalId],[SchemaName])
);
PRINT N'Created cdm_demo_gold.Dim4IdentityAssertions';
GO

CREATE TABLE cdm_demo_gold.Dim4IdentityPasswordList (
     [IdentityRefId] CHAR (36) NOT NULL
    ,[IdentityLocalId] INT NOT NULL
    ,[EncryptedPassword] VARCHAR (111) NOT NULL
    ,[EncryptionAlgorithm] VARCHAR (16) NOT NULL
    ,[KeyName] VARCHAR (111) NULL -- Don't need a named key with all algorithm types
    ,CONSTRAINT [FK_IdentityPasswordList_IdentityRefId] FOREIGN KEY ([IdentityRefId]) REFERENCES cdm_demo_gold.Dim3Identity ([RefId])
    ,CONSTRAINT [FK_IdentityPasswordList_IdentityLocalId] FOREIGN KEY ([IdentityLocalId]) REFERENCES cdm_demo_gold.Dim3Identity ([LocalId])
    ,CONSTRAINT [PK_IdentityPasswordList] PRIMARY KEY ([IdentityLocalId],[EncryptionAlgorithm])
    ,CONSTRAINT [FK_IdentityPasswordList_EncryptionAlgorithm] FOREIGN KEY ([EncryptionAlgorithm]) REFERENCES cdm_demo_gold.Dim0EncryptionAlgorithm ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4IdentityPasswordList';
GO

-- -------------------- --
-- 3.10.3 PersonPicture --
-- -------------------- --

CREATE TABLE cdm_demo_gold.Dim4PersonPicturePublishingPermissions (
     [PersonPictureRefId] CHAR (36) NOT NULL
    ,[PersonPictureLocalId]VARCHAR (111) NOT NULL
    ,[PermissionCategory] VARCHAR (32) NOT NULL
    ,[PermissionValue] CHAR (1) NOT NULL
    ,CONSTRAINT [FKRef_PersonPicPublishingPermissions_PersonPic] FOREIGN KEY ([PersonPictureRefId]) REFERENCES cdm_demo_gold.Dim3PersonPicture ([RefId])
    ,CONSTRAINT [FKLocal_PersonPicPublishingPermissions_PersonPic] FOREIGN KEY ([PersonPictureLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPicture ([LocalId])
    ,CONSTRAINT [PK_PersonPicPublishingPermissions] PRIMARY KEY ([PersonPictureLocalId],[PermissionCategory])
    ,CONSTRAINT [FK_PersonPicPublishingPermissions_PermissionCategory] FOREIGN KEY ([PermissionCategory]) REFERENCES cdm_demo_gold.Dim0PermissionCategoryCode ([TypeKey])
    ,CONSTRAINT [FK_PersonPicPublishingPermissions_PermissionValue] FOREIGN KEY ([PermissionValue]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4PersonPicturePublishingPermissions';
GO

-- -------------------------------------- --
-- 3.10.4 PersonPrivacyObligationDocument --
-- -------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim4PersonPrivacySettingLocation (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[SettingLocationName] VARCHAR (111) NULL
    ,[SettingLocationType] VARCHAR (111) NULL
-- These Ids to "setting locations" may be FKs to just SchoolInfo or SchoolInfo plus others
-- No FK relationship set for the two below fields yet
    ,[SettingLocationRefId] CHAR (36) NULL
    ,[SettingLocationLocalId] VARCHAR (111) NULL
-- Not an enumerated list, to be the location equivalent of PartyType, yet
-- Note that as this is the only other not null field to include in PK, you can only have one location of each type (e.g. SchoolInfo) per privacy record
    ,[SettingLocationObjectTypeName] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_SettingLocation_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_SettingLocation_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [PK_SettingLocation] PRIMARY KEY ([PersonPrivacyLocalId],[SettingLocationObjectTypeName])
);
PRINT N'Created cdm_demo_gold.Dim4PersonPrivacySettingLocation';
GO

CREATE TABLE cdm_demo_gold.Dim4PersonPrivacyDataDomain (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[LocalId] VARCHAR (111) NOT NULL
    ,[DataDomain] VARCHAR (111) NOT NULL
    ,[DomainComments] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_DataDomain_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_DataDomain_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [PK_DataDomain] PRIMARY KEY ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim4PersonPrivacyDataDomain';
GO

CREATE TABLE cdm_demo_gold.Dim4PersonPrivacyPermissionToParticipate (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[LocalId] VARCHAR (111) NOT NULL
    ,[PermissionCategory] VARCHAR (111) NOT NULL
    ,[Permission] VARCHAR (111) NOT NULL
    ,[PermissionValue] CHAR (1) NULL
    ,[PermissionStartDate] DATETIME NULL
    ,[PermissionEndDate] DATETIME NULL
    ,[PermissionGranteeRefId] CHAR (36) NULL
    ,[PermissionGranteeLocalId] INT NULL
    ,[PermissionGranteePartyType] VARCHAR (14) NULL
    ,[PermissionGranteeName] VARCHAR (111) NULL
    ,[PermissionGranteeRelationship] VARCHAR (111) NULL
    ,[PermissionComments] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_PermissionToParticipate_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_PermissionToParticipate_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [PK_PermissionToParticipate] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_PermissionToParticipate_PermissionValue] FOREIGN KEY ([PermissionValue]) REFERENCES cdm_demo_gold.Dim0PermissionYesNoType ([TypeKey])
    ,CONSTRAINT [FKRef_PermissionToParticipate_PartyList] FOREIGN KEY ([PermissionGranteeRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_PermissionToParticipate_PartyList] FOREIGN KEY ([PermissionGranteeLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_PermissionToParticipate_PartyType] FOREIGN KEY ([PermissionGranteePartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4PersonPrivacyPermissionToParticipate';
GO

CREATE TABLE cdm_demo_gold.Dim4PersonPrivacyApplicableLaw (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[ApplicableCountry] VARCHAR (111) NOT NULL
    ,[ApplicableLawName] VARCHAR (111) NOT NULL
    ,[ApplicableLawURL] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_ApplicableLaw_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_ApplicableLaw_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [PK_ApplicableLaw] PRIMARY KEY ([PersonPrivacyLocalId],[ApplicableLawName])
);
PRINT N'Created cdm_demo_gold.Dim4PersonPrivacyApplicableLaw';
GO

-- ---------------------- --
-- 3.10.6 StaffAssignment --
-- ---------------------- --

-- TO-DO: Constrain SubjectLocalId and TimeTableSubjectRefId with FKs when reach that phase of SIF Spec target data structure implementation
CREATE TABLE cdm_demo_gold.Fact4StaffAssignmentSubjectList (
     [StaffAssignmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[PreferenceNumber] INT NOT NULL
    ,[SubjectLocalId] VARCHAR (111) NULL
    ,[TimeTableSubjectRefId] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_StaffAssignmentSubjectList_StaffAssignment] FOREIGN KEY ([StaffAssignmentRefId]) REFERENCES cdm_demo_gold.Fact3StaffAssignment ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignmentSubjectList_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentSubjectList_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignmentSubjectList_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentSubjectList_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffAssignmentSubjectList] PRIMARY KEY ([StaffAssignmentRefId],[PreferenceNumber])
);
PRINT N'Created cdm_demo_gold.Fact4StaffAssignmentSubjectList';
GO

CREATE TABLE cdm_demo_gold.Fact4StaffAssignmentActivityExtension (
     [StaffAssignmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[ActivityCode] CHAR (4) NOT NULL
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtension_StaffAssignment] FOREIGN KEY ([StaffAssignmentRefId]) REFERENCES cdm_demo_gold.Fact3StaffAssignment ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtension_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentActivityExtension_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtension_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentActivityExtension_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FK_StaffAssignmentActivityExtension_ActivityCode] FOREIGN KEY ([ActivityCode]) REFERENCES cdm_demo_gold.Dim0StaffActivity ([TypeKey])
    ,CONSTRAINT [PK_StaffAssignmentActivityExtension] PRIMARY KEY ([StaffAssignmentRefId],[ActivityCode])
);
PRINT N'Created cdm_demo_gold.Fact4StaffAssignmentActivityExtension';
GO

CREATE TABLE cdm_demo_gold.Fact4StaffAssignmentActivityExtensionOtherCode (
     [StaffAssignmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[Codeset] VARCHAR (13) NOT NULL
    ,[OtherCode] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtensionOtherCode_StaffAssignment] FOREIGN KEY ([StaffAssignmentRefId]) REFERENCES cdm_demo_gold.Fact3StaffAssignment ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtensionOtherCode_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentActivityExtensionOtherCode_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignmentActivityExtensionOtherCode_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentActivityExtensionOtherCode_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FK_StaffAssignmentActivityExtensionOtherCode_Codeset] FOREIGN KEY ([Codeset]) REFERENCES cdm_demo_gold.Dim0CodesetForOtherCodeListType ([TypeKey])
    ,CONSTRAINT [PK_StaffAssignmentActivityExtensionOtherCode] PRIMARY KEY ([StaffAssignmentRefId],[CodeSet])
);
PRINT N'Created cdm_demo_gold.Fact4StaffAssignmentActivityExtensionOtherCode';
GO

CREATE TABLE cdm_demo_gold.Fact4StaffAssignmentYearLevels (
     [StaffAssignmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[YearLevelCode] VARCHAR (8) NOT NULL
    ,CONSTRAINT [FKRef_StaffAssignmentYearLevels_StaffAssignment] FOREIGN KEY ([StaffAssignmentRefId]) REFERENCES cdm_demo_gold.Fact3StaffAssignment ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignmentYearLevels_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentYearLevels_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignmentYearLevels_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentYearLevels_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [FK_StaffAssignmentYearLevels_YearLevelCode] FOREIGN KEY ([YearLevelCode]) REFERENCES cdm_demo_gold.Dim0YearLevelCode ([TypeKey])
    ,CONSTRAINT [PK_StaffAssignmentYearLevels] PRIMARY KEY ([StaffAssignmentRefId],[YearLevelCode])
);
PRINT N'Created cdm_demo_gold.Fact4StaffAssignmentYearLevels';
GO

-- TO-DO: Constrain CalendarSummaryRefId with FK when reach that phase of SIF Spec target data structure implementation
CREATE TABLE cdm_demo_gold.Fact4StaffAssignmentCalendarSummaryList (
     [StaffAssignmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StaffPersonalRefId] CHAR (36) NOT NULL
    ,[StaffPersonalLocalId] INT NOT NULL
    ,[CalendarSummaryRefId] CHAR (36) NOT NULL
    ,CONSTRAINT [FKRef_StaffAssignmentCalendarSummaryList_StaffAssignment] FOREIGN KEY ([StaffAssignmentRefId]) REFERENCES cdm_demo_gold.Fact3StaffAssignment ([RefId])
    ,CONSTRAINT [FKRef_StaffAssignmentCalendarSummaryList_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentCalendarSummaryList_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StaffAssignmentCalendarSummaryList_StaffPersonal] FOREIGN KEY ([StaffPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffAssignmentCalendarSummaryList_StaffPersonal] FOREIGN KEY ([StaffPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffAssignmentCalendarSummaryList] PRIMARY KEY ([StaffAssignmentRefId],[CalendarSummaryRefId])
);
PRINT N'Created cdm_demo_gold.Fact4StaffAssignmentCalendarSummaryList';
GO

-- --------------------------------- --
-- 3.10.9 StudentContactRelationship --
-- --------------------------------- --

CREATE TABLE cdm_demo_gold.Fact4StudentContactRelationshipHouseholdList (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[PartyRefId] CHAR (36) NOT NULL
    ,[PartyLocalId] INT NOT NULL
    ,[PartyType] VARCHAR (14) NOT NULL
    ,CONSTRAINT [RefUnique_StudentHouseholdList] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentHouseholdList] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentHouseholdList] PRIMARY KEY ([LocalId],[PartyLocalId])
    ,CONSTRAINT [FK_StudentHouseholdList_PartyRefId] FOREIGN KEY ([PartyRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FK_StudentHouseholdList_PartyLocalId] FOREIGN KEY ([PartyLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_StudentHouseholdList_PartyType] FOREIGN KEY ([PartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact4StudentContactRelationshipHouseholdList';
GO

-- ------------------------------- --
-- 3.10.11 StudentSchoolEnrollment --
-- ------------------------------- --

CREATE TABLE cdm_demo_gold.Fact4StudentSchoolEnrollmentOtherCodes (
     [StudentSchoolEnrollmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StudentPersonalRefId] CHAR (36) NOT NULL
    ,[StudentPersonalLocalId] INT NOT NULL
    ,[OtherCodeField] VARCHAR (16) NOT NULL
    ,[Codeset] VARCHAR (13) NOT NULL
    ,[OtherCodeValue] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentOtherCodes_StudentSchoolEnrollment] FOREIGN KEY ([StudentSchoolEnrollmentRefId]) REFERENCES cdm_demo_gold.Fact3StudentSchoolEnrollment ([RefId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentOtherCodes_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentOtherCodes_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentOtherCodes_StudentPersonal] FOREIGN KEY ([StudentPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentOtherCodes_StudentPersonal] FOREIGN KEY ([StudentPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [FK_StudentSchoolEnrollmentOtherCodes_OtherCodeField] FOREIGN KEY ([OtherCodeField]) REFERENCES cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollmentOtherCodes_Codeset] FOREIGN KEY ([Codeset]) REFERENCES cdm_demo_gold.Dim0CodesetForOtherCodeListType ([TypeKey])
    ,CONSTRAINT [PK_StudentSchoolEnrollmentOtherCodes] PRIMARY KEY ([StudentSchoolEnrollmentRefId],[OtherCodeField],[CodeSet])
);
PRINT N'Created cdm_demo_gold.Fact4StudentSchoolEnrollmentOtherCodes';
GO

CREATE TABLE cdm_demo_gold.Fact4StudentSubjectChoice (
     [StudentSchoolEnrollmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StudentPersonalRefId] CHAR (36) NOT NULL
    ,[StudentPersonalLocalId] INT NOT NULL
    ,[PreferenceNumber] INT NULL
    ,[SubjectLocalId] INT NOT NULL
    ,[SubjectAreaTypeCode] VARCHAR (111) NULL
    ,[OtherSchoolLocalId] INT NULL
    ,CONSTRAINT [FKRef_StudentSubjectChoice_StudentSchoolEnrollment] FOREIGN KEY ([StudentSchoolEnrollmentRefId]) REFERENCES cdm_demo_gold.Fact3StudentSchoolEnrollment ([RefId])
    ,CONSTRAINT [FKRef_StudentSubjectChoice_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSubjectChoice_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StudentSubjectChoice_StudentPersonal] FOREIGN KEY ([StudentPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSubjectChoice_StudentPersonal] FOREIGN KEY ([StudentPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
-- TO-DO: Need an FK constraint to a PK for SubjectLocalId, here
    ,CONSTRAINT [PK_StudentSubjectChoice] PRIMARY KEY ([StudentSchoolEnrollmentRefId],[SubjectLocalId])
    ,CONSTRAINT [FKLocal_StudentSubjectChoice_OtherSchoolInfo] FOREIGN KEY ([OtherSchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
);
PRINT N'Created cdm_demo_gold.Fact4StudentSubjectChoice';
GO

CREATE TABLE cdm_demo_gold.Fact4StudentSchoolEnrollmentStudentGroup (
     [StudentSchoolEnrollmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StudentPersonalRefId] CHAR (36) NOT NULL
    ,[StudentPersonalLocalId] INT NOT NULL
    ,[GroupCategory] VARCHAR (16) NOT NULL
    ,[GroupLocalId] INT NOT NULL
    ,[GroupDescription] VARCHAR (255) NULL
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentStudentGroup_StudentSchoolEnrollment] FOREIGN KEY ([StudentSchoolEnrollmentRefId]) REFERENCES cdm_demo_gold.Fact3StudentSchoolEnrollment ([RefId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentStudentGroup_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentStudentGroup_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentStudentGroup_StudentPersonal] FOREIGN KEY ([StudentPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentStudentGroup_StudentPersonal] FOREIGN KEY ([StudentPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentSchoolEnrollmentStudentGroup] PRIMARY KEY ([StudentSchoolEnrollmentRefId],[GroupLocalId])
    ,CONSTRAINT [FK_StudentSchoolEnrollmentStudentGroup_GroupCategory] FOREIGN KEY ([GroupCategory]) REFERENCES cdm_demo_gold.Dim0StudentGroupCategoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact4StudentSchoolEnrollmentStudentGroup';
GO

CREATE TABLE cdm_demo_gold.Fact4StudentSchoolEnrollmentPublishingPermissions (
     [StudentSchoolEnrollmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StudentPersonalRefId] CHAR (36) NOT NULL
    ,[StudentPersonalLocalId] INT NOT NULL
    ,[PermissionCategory] VARCHAR (32) NOT NULL
    ,[PermissionValue] CHAR (1) NOT NULL
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentPublishingPermissions_StudentSchoolEnrollment] FOREIGN KEY ([StudentSchoolEnrollmentRefId]) REFERENCES cdm_demo_gold.Fact3StudentSchoolEnrollment ([RefId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentPublishingPermissions_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentPublishingPermissions_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StudentSchoolEnrollmentPublishingPermissions_StudentPersonal] FOREIGN KEY ([StudentPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSchoolEnrollmentPublishingPermissions_StudentPersonal] FOREIGN KEY ([StudentPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentSchoolEnrollmentPublishingPermissions] PRIMARY KEY ([StudentSchoolEnrollmentRefId],[PermissionCategory])
    ,CONSTRAINT [FK_StudentSchoolEnrollmentPublishingPermissions_PermissionCategory] FOREIGN KEY ([PermissionCategory]) REFERENCES cdm_demo_gold.Dim0PermissionCategoryCode ([TypeKey])
    ,CONSTRAINT [FK_StudentSchoolEnrollmentPublishingPermissions_PermissionValue] FOREIGN KEY ([PermissionValue]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Fact4StudentSchoolEnrollmentPublishingPermissions';
GO

-- ---------------------------------- --
-- SUBSECTION: 3.8.1 LearningResource --
-- ---------------------------------- --

CREATE TABLE cdm_demo_gold.Dim4LearningResourceContactNames (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ContactLocalId] INT NOT NULL
    ,[Title] VARCHAR (111) NULL
    ,[FamilyName] VARCHAR (111) NULL
    ,[GivenName] VARCHAR (111) NULL
    ,[MiddleName] VARCHAR (111) NULL
    ,[FamilyNameFirst] CHAR (1) NULL
    ,[PreferredFamilyName] VARCHAR (111) NULL
    ,[PreferredFamilyNameFirst] CHAR (1) NULL
    ,[PreferredGivenName] VARCHAR (111) NULL
    ,[Suffix] VARCHAR (111) NULL
    ,[FullName] VARCHAR (111) NULL
    ,[NameUsageTypeKey] CHAR (3) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceContactNames_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceContactNames_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKLocal_LearningResourceContactNames_LearningResourceContact] FOREIGN KEY ([ContactLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResourceContactList ([LocalId])
    ,CONSTRAINT [PK_LearningResourceContactNames] PRIMARY KEY ([LearningResourceLocalId],[ContactLocalId],[NameUsageTypeKey])
    ,CONSTRAINT [FK_LearningResourceContactNames_FamilyNameFirst] FOREIGN KEY ([FamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceContactNames_PreferredFamilyNameFirst] FOREIGN KEY ([PreferredFamilyNameFirst]) REFERENCES cdm_demo_gold.Dim0YesNoType ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceContactNames_NameUsageType] FOREIGN KEY ([NameUsageTypeKey]) REFERENCES cdm_demo_gold.Dim0NameUsageType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceContactNames';
GO

CREATE TABLE cdm_demo_gold.Dim4LearningResourceContactAddresses (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ContactLocalId] INT NOT NULL
    ,[AddressLocalId] VARCHAR (111) NOT NULL
    ,[AddressType] VARCHAR (5) NOT NULL
    ,[AddressRole] CHAR (4) NOT NULL
    ,[EffectiveFromDate] DATETIME NULL
    ,[EffectiveToDate] DATETIME NULL
    ,[AddressStreet_Line1] VARCHAR (111) NULL
    ,[AddressStreet_Line2] VARCHAR (111) NULL
    ,[AddressStreet_Line3] VARCHAR (111) NULL
    ,[AddressStreet_Complex] VARCHAR (111) NULL
    ,[AddressStreet_StreetNumber] VARCHAR (111) NULL
    ,[AddressStreet_StreetPrefix] VARCHAR (111) NULL
    ,[AddressStreet_StreetName] VARCHAR (111) NULL
    ,[AddressStreet_StreetType] VARCHAR (111) NULL
    ,[AddressStreet_StreetSuffix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentType] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberPrefix] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumber] VARCHAR (111) NULL
    ,[AddressStreet_ApartmentNumberSuffix] VARCHAR (111) NULL
    ,[City] VARCHAR (111) NOT NULL
    ,[StateProvince] VARCHAR (3) NULL
    ,[Country] VARCHAR (111) NULL
    ,[PostalCode] VARCHAR (111) NOT NULL
-- LatLong to 5dp is accurate to about 1 metre on Earth
    ,[GridLocation_DecimalLatitude] DECIMAL (7,5) NULL
    ,[GridLocation_DecimalLongitude] DECIMAL (8,5) NULL
    ,[MapReference_MapType] VARCHAR (111) NULL
    ,[MapReference_XCoordinate] VARCHAR (111) NULL
    ,[MapReference_YCoordinate] VARCHAR (111) NULL
    ,[MapReference_MapNumber] VARCHAR (111) NULL
    ,[RadioContact] VARCHAR (111) NULL
    ,[Community] VARCHAR (111) NULL
    ,[AddressGlobalUID] VARCHAR (111) NULL
    ,[StatisticalAreaLevel4Code] CHAR (3) NULL
    ,[StatisticalAreaLevel4Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel3Code] CHAR (5) NULL
    ,[StatisticalAreaLevel3Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel2Code] CHAR (9) NULL
    ,[StatisticalAreaLevel2Name] VARCHAR (50) NULL
    ,[StatisticalAreaLevel1] CHAR (11) NULL
    ,[StatisticalAreaMeshBlock] CHAR (11) NULL
    ,[LocalGovernmentAreaName] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_LearningResourceContactAddresses_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceContactAddresses_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKLocal_LearningResourceContactAddresses_LearningResourceContact] FOREIGN KEY ([ContactLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResourceContactList ([LocalId])
    ,CONSTRAINT [PK_LearningResourceContactAddresses] PRIMARY KEY ([LearningResourceLocalId],[ContactLocalId],[AddressLocalId])
    ,CONSTRAINT [FK_LearningResourceContactAddresses_AddressType] FOREIGN KEY ([AddressType]) REFERENCES cdm_demo_gold.Dim0AddressType ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceContactAddresses_AddressRole] FOREIGN KEY ([AddressRole]) REFERENCES cdm_demo_gold.Dim0AddressRole ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceContactAddresses_StateProvince] FOREIGN KEY ([StateProvince]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceContactAddresses';
GO

CREATE TABLE cdm_demo_gold.Dim4LearningResourceContactPhoneNumbers (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ContactLocalId] INT NOT NULL
    ,[PhoneNumberType] CHAR (4) NOT NULL
    ,[Number] VARCHAR (111) NOT NULL
    ,[Extension] VARCHAR (111) NULL
    ,[ListedStatus] VARCHAR (111) NULL
    ,[Preference] INT NULL
    ,CONSTRAINT [FKRef_LearningResourceContactPhoneNumbers_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceContactPhoneNumbers_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKLocal_LearningResourceContactPhoneNumbers_LearningResourceContact] FOREIGN KEY ([ContactLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResourceContactList ([LocalId])
    ,CONSTRAINT [FK_LearningResourceContactPhoneNumbers_PhoneNumberType] FOREIGN KEY ([PhoneNumberType]) REFERENCES cdm_demo_gold.Dim0PhoneNumberType ([TypeKey])
    ,CONSTRAINT [PK_LearningResourceContactPhoneNumbers] PRIMARY KEY ([LearningResourceLocalId],[ContactLocalId],[PhoneNumberType])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceContactPhoneNumbers';
GO

CREATE TABLE cdm_demo_gold.Dim4LearningResourceContactEmails (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ContactLocalId] INT NOT NULL
    ,[EmailType] CHAR (2) NOT NULL
    ,[Email] VARCHAR (255) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceContactEmails_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceContactEmails_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKLocal_LearningResourceContactEmails_LearningResourceContact] FOREIGN KEY ([ContactLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResourceContactList ([LocalId])
    ,CONSTRAINT [FK_LearningResourceContactEmails_EmailType] FOREIGN KEY ([EmailType]) REFERENCES cdm_demo_gold.Dim0EmailType ([TypeKey])
    ,CONSTRAINT [PK_LearningResourceContactEmails] PRIMARY KEY ([LearningResourceLocalId],[ContactLocalId],[EmailType])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceContactEmails';
GO

-- ---------------------------------- --
-- SUBSECTION: 3.8.1 LearningResource --
-- ---------------------------------- --

CREATE TABLE cdm_demo_gold.Dim4LearningResourceSubjectAreaOtherCodes (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ACStrand] CHAR (1) NOT NULL
    ,[SubjectAreaCode] VARCHAR (111) NOT NULL
    ,[Codeset] VARCHAR (13) NOT NULL
    ,[OtherCodeValue] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceSubjectAreaOtherCodes_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceSubjectAreaOtherCodes_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FK_LearningResourceSubjectAreaOtherCodes_ACStrand] FOREIGN KEY ([ACStrand]) REFERENCES cdm_demo_gold.Dim0AustralianCurriculumStrand ([TypeKey])
    ,CONSTRAINT [FK_LearningResourceSubjectAreaOtherCodes_Codeset] FOREIGN KEY ([Codeset]) REFERENCES cdm_demo_gold.Dim0CodesetForOtherCodeListType ([TypeKey])
    ,CONSTRAINT [PK_LearningResourceSubjectAreaOtherCodes] PRIMARY KEY ([LearningResourceLocalId],[ACStrand],[SubjectAreaCode])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceSubjectAreaOtherCodes';
GO

CREATE TABLE cdm_demo_gold.Dim4LearningResourceComponentTeachingLearningStrategies (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ComponentName] VARCHAR (111) NOT NULL
    ,[TeachingLearningStrategy] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceComponentTeachingLearningStrategies_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceComponentTeachingLearningStrategies_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [PK_LearningResourceComponentTeachingLearningStrategies] PRIMARY KEY ([LearningResourceLocalId],[ComponentName],[TeachingLearningStrategy])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceComponentTeachingLearningStrategies';
GO

CREATE TABLE cdm_demo_gold.Dim4LearningResourceComponentAssociatedObjects (
     [LearningResourceRefId] CHAR (36) NOT NULL
    ,[LearningResourceLocalId] INT NOT NULL
    ,[ComponentName] VARCHAR (111) NOT NULL
    ,[AssociatedObjectRefId] CHAR (36) NOT NULL
    ,[SIF_RefObject] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_LearningResourceComponentAssociatedObjects_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_LearningResourceComponentAssociatedObjects_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [RefUUID_LearningResourceComponentAssociatedObjects] CHECK ([AssociatedObjectRefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_LearningResourceComponentAssociatedObjects] PRIMARY KEY ([LearningResourceLocalId],[ComponentName],[AssociatedObjectRefId])
);
PRINT N'Created cdm_demo_gold.Dim4LearningResourceComponentAssociatedObjects';
GO

-- -------------------------------------- --
-- SUBSECTION: 3.11.2 LibraryPatronStatus --
-- -------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim4LibraryPatronElectronicIdList (
     [LibraryPatronRefId] CHAR (36) NOT NULL
    ,[LibraryPatronLocalId] INT NOT NULL
    ,[ElectronicIdValue] VARCHAR (111) NULL
    ,[ElectronicIdTypeKey] CHAR (2) NOT NULL
    ,CONSTRAINT [FKRef_LibraryPatronElectronicIdList_StaffPersonal] FOREIGN KEY ([LibraryPatronRefId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([RefId])
    ,CONSTRAINT [FKLocal_LibraryPatronElectronicIdList_StaffPersonal] FOREIGN KEY ([LibraryPatronLocalId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([PatronLocalId])
    ,CONSTRAINT [PK_LibraryPatronElectronicIdList] PRIMARY KEY ([LibraryPatronLocalId],[ElectronicIdTypeKey])
    ,CONSTRAINT [FK_LibraryPatronElectronicIdList_ElectronicIdListType] FOREIGN KEY ([ElectronicIdTypeKey]) REFERENCES cdm_demo_gold.Dim0ElectronicIdType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim4LibraryPatronElectronicIdList';
GO

CREATE TABLE cdm_demo_gold.Dim4LibraryPatronTransactionList (
     [LibraryPatronRefId] CHAR (36) NOT NULL
    ,[LibraryPatronLocalId] INT NOT NULL
    ,[LibraryTransactionLocalId] VARCHAR(111) NOT NULL
    ,[ItemInfo_Type] VARCHAR (111) NOT NULL
    ,[ItemInfo_Title] VARCHAR (111) NULL
    ,[ItemInfo_Author] VARCHAR (111) NULL
    ,[ItemInfo_CallNumber] VARCHAR (111) NULL
    ,[ItemInfo_ISBN] VARCHAR (111) NULL
-- Will any library item be worth more than AUD 9,999.99 ?
-- Data types below currently set assuming no, nothing more valuable:
    ,[ItemInfo_Cost] DECIMAL (6,4) NULL
    ,[ItemInfo_ReplacementCost] DECIMAL (6,4) NULL
    ,[Checkout_CheckedOutOn] DATETIME NULL
    ,[Checkout_ReturnBy] DATETIME NULL
    ,[Checkout_RenewalCount] INT NULL
    ,[Fine_Type] VARCHAR (111) NULL
    ,[Fine_AppliedOn] DATETIME NULL
    ,[Fine_Description] VARCHAR (111) NULL
    ,[Fine_Amount] DECIMAL (6,4) NULL
    ,[Fine_Reference] VARCHAR (111) NULL
    ,[Hold_Type] VARCHAR (111) NULL
    ,[Hold_DatePlaced] DATETIME NULL
    ,[Hold_DateNeeded] DATETIME NULL
    ,[Hold_ReservationExpiry] DATETIME NULL
    ,[Hold_MadeAvailable] DATETIME NULL
    ,[Hold_Expires] DATETIME NULL
    ,CONSTRAINT [FKRef_LibraryPatronTransactionList_StaffPersonal] FOREIGN KEY ([LibraryPatronRefId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([RefId])
    ,CONSTRAINT [FKLocal_LibraryPatronTransactionList_StaffPersonal] FOREIGN KEY ([LibraryPatronLocalId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([PatronLocalId])
    ,CONSTRAINT [PK_LibraryPatronTransactionList] PRIMARY KEY ([LibraryTransactionLocalId])
);
PRINT N'Created cdm_demo_gold.Dim4LibraryPatronTransactionList';
GO

CREATE TABLE cdm_demo_gold.Dim4LibraryPatronMessageList (
     [LibraryPatronRefId] CHAR (36) NOT NULL
    ,[LibraryPatronLocalId] INT NOT NULL
    ,[Priority] VARCHAR (111) NOT NULL
    ,[PriorityCodeset] VARCHAR (111) NULL
    ,[SentDateTime] DATETIME NOT NULL
    ,[Text] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_LibraryPatronMessageList_StaffPersonal] FOREIGN KEY ([LibraryPatronRefId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([RefId])
    ,CONSTRAINT [FKLocal_LibraryPatronMessageList_StaffPersonal] FOREIGN KEY ([LibraryPatronLocalId]) REFERENCES cdm_demo_gold.Dim3LibraryPatronStatus ([PatronLocalId])
    ,CONSTRAINT [PK_LibraryPatronMessageList] PRIMARY KEY ([LibraryPatronLocalId],[SentDateTime],[Text])
);
PRINT N'Created cdm_demo_gold.Dim4LibraryPatronMessageList';
GO

-- --------------- --
-- 3.10.5 RoomInfo --
-- --------------- --

CREATE TABLE cdm_demo_gold.Bridge4RoomInfoStaffList (
     [RoomRefId] CHAR (36) NOT NULL
    ,[RoomLocalId] INT NOT NULL
    ,[SchoolRefId] CHAR (36) NOT NULL
    ,[SchoolLocalId] INT NOT NULL
    ,[StaffRefId] CHAR (36) NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,CONSTRAINT [PK_RoomInfoStaffList] PRIMARY KEY ([RoomLocalId],[SchoolLocalId],[StaffLocalId])
    ,CONSTRAINT [FKRef_RoomInfoStaffList_RoomInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim3RoomInfo ([RefId])
    ,CONSTRAINT [FKLocal_RoomInfoStaffList_RoomInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim3RoomInfo ([LocalId])
    ,CONSTRAINT [FKRef_RoomInfoStaffList_SchoolInfo] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_RoomInfoStaffList_SchoolInfo] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_RoomInfoStaffList_StaffPersonal] FOREIGN KEY ([SchoolRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_RoomInfoStaffList_StaffPersonal] FOREIGN KEY ([SchoolLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim4RoomInfoStaffList';
GO

CREATE TABLE cdm_demo_gold.Dim4ResourceList (
-- Resource RefId & LocalId are just the three other Dim keys coalesced together
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[ResourceType] VARCHAR (16) NOT NULL
    ,[EquipmentInfoRefId] CHAR (36) NULL
    ,[EquipmentInfoLocalId] INT NULL
    ,[LearningResourceRefId] CHAR (36) NULL
    ,[LearningResourceLocalId] INT NULL
    ,[RoomInfoContactRefId] CHAR (36) NULL
    ,[RoomInfoContactLocalId] INT NULL
    ,CONSTRAINT [RefUnique_Resource] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_Resource] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_Resource] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_Resource_ResourceType] FOREIGN KEY ([ResourceType]) REFERENCES cdm_demo_gold.Dim0ResourceType ([TypeKey])
    ,CONSTRAINT [FKRef_ResourceList_EquipmentInfo] FOREIGN KEY ([EquipmentInfoRefId]) REFERENCES cdm_demo_gold.Dim1EquipmentInfo ([RefId])
    ,CONSTRAINT [FKLocal_ResourceList_EquipmentInfo] FOREIGN KEY ([EquipmentInfoLocalId]) REFERENCES cdm_demo_gold.Dim1EquipmentInfo ([LocalId])
    ,CONSTRAINT [FKRef_ResourceList_LearningResource] FOREIGN KEY ([LearningResourceRefId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([RefId])
    ,CONSTRAINT [FKLocal_ResourceList_LearningResource] FOREIGN KEY ([LearningResourceLocalId]) REFERENCES cdm_demo_gold.Dim2LearningResource ([LocalId])
    ,CONSTRAINT [FKRef_ResourceList_RoomInfo] FOREIGN KEY ([RoomInfoContactRefId]) REFERENCES cdm_demo_gold.Dim3RoomInfo ([RefId])
    ,CONSTRAINT [FKLocal_ResourceList_RoomInfo] FOREIGN KEY ([RoomInfoContactLocalId]) REFERENCES cdm_demo_gold.Dim3RoomInfo ([LocalId])
);
PRINT N'Created cdm_demo_gold.Dim2ResourceList';
GO





-- -------------------------------------------------------------------------- --
-- DEPENDENCY: Tables with 5 in name have FK to table(s) with 4               --
-- -------------------------------------------------------------------------- --

-- -------------------------------------- --
-- 3.10.4 PersonPrivacyObligationDocument --
-- -------------------------------------- --

-- Note that SIF has both a "DoNotShareWith" and "NeverShareWith" duplicate data structures, that only differ in "Never" versus "DoNot" prefixes.
-- There will never be any different data to put in "Never" versus "DoNot", so this structure has only been built here once, under "DoNot".
-- Use the "DoNot" database data to fill both "DoNotShareWith" and "NeverShareWith" with duplicated data, as necessary in SIF messages.
-- If you really wanted the "Never" table too, copy-paste the "DoNot" table and do the appropriate "DoNot" to "Never" find and replace.

CREATE TABLE cdm_demo_gold.Dim5PersonPrivacyDataDomainShareWith (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[DataDomainLocalId] VARCHAR (111) NOT NULL
    ,[ShareWithParty] VARCHAR (111) NOT NULL
    ,[ShareWithRefId] CHAR (36) NULL
    ,[ShareWithLocalId] INT NULL
    ,[ShareWithPartyType] VARCHAR (14) NULL
    ,[ShareWithName] VARCHAR (111) NULL
    ,[ShareWithRelationship] VARCHAR (111) NULL
    ,[ShareWithPurpose] VARCHAR (111) NOT NULL
    ,[ShareWithRole] VARCHAR (111) NOT NULL
    ,[ShareWithComments] VARCHAR (111) NULL
    ,[PermissionToOnShare] CHAR (1) NOT NULL
    ,[ShareWithURL] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_ShareWith_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_ShareWith_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [FKLocal_ShareWith_DataDomain] FOREIGN KEY ([DataDomainLocalId]) REFERENCES cdm_demo_gold.Dim4PersonPrivacyDataDomain ([LocalId])
    ,CONSTRAINT [PK_ShareWith] PRIMARY KEY ([DataDomainLocalId])
    ,CONSTRAINT [FKRef_ShareWith_PartyList] FOREIGN KEY ([ShareWithRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_ShareWith_PartyList] FOREIGN KEY ([ShareWithLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_ShareWith_PartyType] FOREIGN KEY ([ShareWithPartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
    ,CONSTRAINT [FK_ShareWith_PermissionToOnShare] FOREIGN KEY ([PermissionToOnShare]) REFERENCES cdm_demo_gold.Dim0PermissionYesNoType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim5PersonPrivacyDataDomainShareWith';
GO

CREATE TABLE cdm_demo_gold.Dim5PersonPrivacyDataDomainDoNotShareWith (
     [PersonPrivacyRefId] CHAR (36) NOT NULL
    ,[PersonPrivacyLocalId] VARCHAR (111) NOT NULL
    ,[DataDomainLocalId] VARCHAR (111) NOT NULL
    ,[DoNotShareWithParty] VARCHAR (111) NOT NULL
    ,[DoNotShareWithRefId] CHAR (36) NULL
    ,[DoNotShareWithLocalId] INT NULL
    ,[DoNotShareWithPartyType] VARCHAR (14) NULL
    ,[DoNotShareWithName] VARCHAR (111) NULL
    ,[DoNotShareWithRelationship] VARCHAR (111) NULL
    ,[DoNotShareWithPurpose] VARCHAR (111) NOT NULL
    ,[DoNotShareWithRole] VARCHAR (111) NOT NULL
    ,[DoNotShareWithComments] VARCHAR (111) NULL
    ,[DoNotShareWithURL] VARCHAR (111) NULL
    ,CONSTRAINT [FKRef_DoNotShareWith_PersonPrivacy] FOREIGN KEY ([PersonPrivacyRefId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([RefId])
    ,CONSTRAINT [FKLocal_DoNotShareWith_PersonPrivacy] FOREIGN KEY ([PersonPrivacyLocalId]) REFERENCES cdm_demo_gold.Dim3PersonPrivacyObligationDocument ([LocalId])
    ,CONSTRAINT [FKLocal_DoNotShareWith_DataDomain] FOREIGN KEY ([DataDomainLocalId]) REFERENCES cdm_demo_gold.Dim4PersonPrivacyDataDomain ([LocalId])
    ,CONSTRAINT [PK_DoNotShareWith] PRIMARY KEY ([DataDomainLocalId])
    ,CONSTRAINT [FKRef_DoNotShareWith_PartyList] FOREIGN KEY ([DoNotShareWithRefId]) REFERENCES cdm_demo_gold.Dim2PartyList ([RefId])
    ,CONSTRAINT [FKLocal_DoNotShareWith_PartyList] FOREIGN KEY ([DoNotShareWithLocalId]) REFERENCES cdm_demo_gold.Dim2PartyList ([LocalId])
    ,CONSTRAINT [FK_DoNotShareWith_PartyType] FOREIGN KEY ([DoNotShareWithPartyType]) REFERENCES cdm_demo_gold.Dim0PartyType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim5PersonPrivacyDataDomainDoNotShareWith';
GO

-- ------------------------------- --
-- 3.10.11 StudentSchoolEnrollment --
-- ------------------------------- --

CREATE TABLE cdm_demo_gold.Fact5StudentSubjectChoiceOtherCode (
     [StudentSchoolEnrollmentRefId] CHAR (36) NOT NULL
    ,[SchoolInfoRefId] CHAR (36) NOT NULL
    ,[SchoolInfoLocalId] INT NOT NULL
    ,[StudentPersonalRefId] CHAR (36) NOT NULL
    ,[StudentPersonalLocalId] INT NOT NULL
    ,[SubjectChoiceLocalId] INT NOT NULL
    ,[Codeset] VARCHAR (13) NOT NULL
    ,[OtherCodeValue] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StudentSubjectChoiceOtherCode_StudentSchoolEnrollment] FOREIGN KEY ([StudentSchoolEnrollmentRefId]) REFERENCES cdm_demo_gold.Fact3StudentSchoolEnrollment ([RefId])
    ,CONSTRAINT [FKRef_StudentSubjectChoiceOtherCode_SchoolInfo] FOREIGN KEY ([SchoolInfoRefId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([RefId])
    ,CONSTRAINT [FKLocal_StudentSubjectChoiceOtherCode_SchoolInfo] FOREIGN KEY ([SchoolInfoLocalId]) REFERENCES cdm_demo_gold.Dim2SchoolInfo ([LocalId])
    ,CONSTRAINT [FKRef_StudentSubjectChoiceOtherCode_StudentPersonal] FOREIGN KEY ([StudentPersonalRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentSubjectChoiceOtherCode_StudentPersonal] FOREIGN KEY ([StudentPersonalLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
-- TO-DO: This commented out FK cannot be used until we have a deduplicated list of subjects, setting a PK for SubjectLocalId:
--    ,CONSTRAINT [FKLocal_StudentSubjectChoiceOtherCode_SubjectChoiceLocalId] FOREIGN KEY ([SubjectChoiceLocalId]) REFERENCES cdm_demo_gold.Fact4StudentSubjectChoice ([SubjectLocalId])
    ,CONSTRAINT [FK_StudentSubjectChoiceOtherCode_Codeset] FOREIGN KEY ([Codeset]) REFERENCES cdm_demo_gold.Dim0CodesetForOtherCodeListType ([TypeKey])
    ,CONSTRAINT [PK_StudentSubjectChoiceOtherCode] PRIMARY KEY ([StudentSchoolEnrollmentRefId],[SubjectChoiceLocalId],[Codeset])
);
PRINT N'Created cdm_demo_gold.Fact5StudentSubjectChoiceOtherCode';
GO

-- -------------------------------------- --
-- SUBSECTION: 3.11.2 LibraryPatronStatus --
-- -------------------------------------- --

CREATE TABLE cdm_demo_gold.Dim5LibraryItemElectronicIdList (
     [LibraryTransactionLocalId] VARCHAR (111) NOT NULL
    ,[ElectronicIdValue] VARCHAR (111) NULL
    ,[ElectronicIdTypeKey] CHAR (2) NOT NULL
    ,CONSTRAINT [FKRef_LibraryItemElectronicIdList_StaffPersonal] FOREIGN KEY ([LibraryTransactionLocalId]) REFERENCES cdm_demo_gold.Dim4LibraryPatronTransactionList ([LibraryTransactionLocalId])
    ,CONSTRAINT [PK_LibraryItemElectronicIdList] PRIMARY KEY ([LibraryTransactionLocalId],[ElectronicIdTypeKey])
    ,CONSTRAINT [FK_LibraryItemElectronicIdList_ElectronicIdListType] FOREIGN KEY ([ElectronicIdTypeKey]) REFERENCES cdm_demo_gold.Dim0ElectronicIdType ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim5LibraryItemElectronicIdList';
GO





