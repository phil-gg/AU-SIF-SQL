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

-- 3. Drop all Check Constraints
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

-- SUBSECTION: Tables with 0 in name implement SIF codes (no other dependencies)

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
     CONSTRAINT [PK_ElectronicIdType] PRIMARY KEY ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim0NameUsageType';
INSERT INTO cdm_demo_gold.Dim0NameUsageType ([TypeKey], [TypeValue]) VALUES
-- Add values here
PRINT N'Inserted SIF values into cdm_demo_gold.Dim0NameUsageType';
GO



-- SUBSECTION: Tables with 1 in name define a new PK used by child 2 table(s) 

CREATE TABLE cdm_demo_gold.Dim1StaffPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[Title] VARCHAR (111) NULL
    ,[EmploymentStatus] CHAR (1) NULL
    ,CONSTRAINT [RefUnique_StaffPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StaffPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StaffPersonal] PRIMARY KEY ([LocalId])
    ,CONSTRAINT [FK_StaffPersonal_EmploymentStatus] FOREIGN KEY ([EmploymentStatus]) REFERENCES cdm_demo_gold.Dim0StaffEmploymentStatus ([TypeKey])
);
PRINT N'Created cdm_demo_gold.Dim1StaffPersonal';
GO



-- SUBSECTION: Tables with 2 in name have FK referencing parent 1 table(s)

CREATE TABLE cdm_demo_gold.Dim2StaffList (
     [StaffRefId] CHAR (36)  NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,CONSTRAINT [FKRef_StaffList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffList] PRIMARY KEY ([StaffLocalId])
);
PRINT N'created cdm_demo_gold.Dim2StaffList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffElectronicIdList (
     [StaffRefId] CHAR (36)  NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[ElectronicIdValue] VARCHAR (111) NULL
    ,[ElectronicIdTypeKey] CHAR (2) NULL
    ,CONSTRAINT [FKRef_StaffElectronicIdList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffElectronicIdList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffElectronicIdList] PRIMARY KEY ([StaffLocalId])
    ,CONSTRAINT [FK_StaffElectronicIdList_ElectronicIdListType] FOREIGN KEY ([ElectronicIdTypeKey]) REFERENCES cdm_demo_gold.Dim0ElectronicIdType ([TypeKey])
);
PRINT N'created cdm_demo_gold.Dim2StaffElectronicIdList';
GO

CREATE TABLE cdm_demo_gold.Dim2StaffOtherIdList (
     [StaffRefId] CHAR (36)  NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,[OtherIdValue] VARCHAR (111) NULL
    ,[OtherIdType] VARCHAR (111) NULL -- Not a key, and no FK relationship this time, unlike electronic, above
    ,CONSTRAINT [FKRef_StaffOtherIdList_StaffPersonal] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId])
    ,CONSTRAINT [FKLocal_StaffOtherIdList_StaffPersonal] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId])
    ,CONSTRAINT [PK_StaffOtherIdList] PRIMARY KEY ([StaffLocalId])
);
PRINT N'created cdm_demo_gold.Dim2StaffOtherIdList';
GO



