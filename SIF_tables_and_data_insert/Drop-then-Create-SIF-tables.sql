-- Need Azure SQL Database or Azure SQL Managed Instance for this demo.
-- Enforcement of Primary Keys, Foreign Keys, and unique constraints test our mapping is correct.
-- Such instance types can switch database with 'USE' command
USE [demo_integration_gold];
PRINT N'Using database [demo_integration_gold].';
GO

/* ************************************************************************** */
/* SECTION: Dynamically drop all constraints & user tables in cdm_demo_gold   */
/* ************************************************************************** */

DECLARE @schemaName SYSNAME = 'cdm_demo_gold';
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
PRINT N'Dropping contraints as shown below...';
PRINT @sql;

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
PRINT N'All constraints (Foreign Key, Primary Key, Unique, Check) for user tables in schema ' + @schemaName + ' have deleted.';
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
PRINT N'Dropping tables as shown below...';
PRINT @sql;

-- Execute the dynamic SQL
EXEC sp_executesql @sql;
PRINT N'All user tables in schema ' + @schemaName + ' have deleted.';
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
    ,[MostRecent_SchoolACARAId] VARCHAR (111) NULL
    ,[MostRecent_LocalCampusId] VARCHAR (111) NULL
    ,[MostRecent_HomeGroup] VARCHAR (111) NULL
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
    ,CONSTRAINT [RefUnique_StudentContactPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StudentContactPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StudentContactPersonal] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_StaffDemographics_EmploymentType] FOREIGN KEY ([EmploymentType]) REFERENCES cdm_demo_gold.Dim0EmploymentType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_SchoolEducationalLevel] FOREIGN KEY ([SchoolEducationalLevel]) REFERENCES cdm_demo_gold.Dim0SchoolEducationLevelType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_NonSchoolEducation] FOREIGN KEY ([NonSchoolEducation]) REFERENCES cdm_demo_gold.Dim0NonSchoolEducationType ([TypeKey])
    ,CONSTRAINT [FK_StaffDemographics_WorkingWithChildrenCheckStateTerritory] FOREIGN KEY ([WorkingWithChildrenCheckStateTerritory]) REFERENCES cdm_demo_gold.Dim0StateTerritoryCode ([TypeKey])
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

CREATE TABLE cdm_demo_gold.Dim2StudentMostRecentNAPLANClassList (
     [StudentRefId] CHAR (36) NOT NULL
    ,[StudentLocalId] INT NOT NULL
    ,[ClassCode] VARCHAR (111) NOT NULL
    ,CONSTRAINT [FKRef_StudentMostRecentNAPLANClassList_StudentPersonal] FOREIGN KEY ([StudentRefId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StudentMostRecentNAPLANClassList_StudentPersonal] FOREIGN KEY ([StudentLocalId]) REFERENCES cdm_demo_gold.Dim1StudentPersonal ([LocalId])
    ,CONSTRAINT [PK_StudentMostRecentNAPLANClassList] PRIMARY KEY ([StudentLocalId],[ClassCode])
);
PRINT N'Created cdm_demo_gold.Dim2StudentMostRecentNAPLANClassList';
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
PRINT N'Created cdm_demo_gold.Dim2StudentContactList';
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



