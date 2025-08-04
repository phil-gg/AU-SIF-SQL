-- Need Azure SQL Database or Azure SQL Managed Instance for this demo.
-- Enforcement of Primary Keys, Foreign Keys, and unique constraints test our mapping is correct.
-- Such instance types can switch database with 'USE' command
USE [demo_integration_gold];
PRINT N'Using database [demo_integration_gold].';
GO

/* ************************************************************************** */
/* SECTION: Conditional drop table for every table created by this script     */
/* ************************************************************************** */

-- SUBSECTION: Drop tables with 2 in name first (could reference 1 or 0)

IF OBJECT_ID('cdm_demo_gold.Dim2StaffList', 'U') IS NOT NULL
BEGIN 
    DROP TABLE cdm_demo_gold.Dim2StaffList;
    PRINT N'Dropped cdm_demo_gold.Dim2StaffList';
END
GO

-- SUBSECTION: Drop tables with 1 in name second (could reference 0)

IF OBJECT_ID('cdm_demo_gold.Dim1StaffPersonal', 'U') IS NOT NULL
BEGIN 
    DROP TABLE cdm_demo_gold.Dim1StaffPersonal;
    PRINT N'Dropped cdm_demo_gold.Dim1StaffPersonal';
END
GO

-- SUBSECTION: Drop tables with 0 in name last

  -- TO-DO

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
GO



-- SUBSECTION: Tables with 1 in name define a new PK used by child 2 table(s) 

CREATE TABLE cdm_demo_gold.Dim1StaffPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[Title] VARCHAR (111) NULL
    ,[EmploymentStatus] VARCHAR (111) NULL
    ,CONSTRAINT [RefUnique_StaffPersonal] UNIQUE ([RefId])
    ,CONSTRAINT [RefUUID_StaffPersonal] CHECK ([RefId] LIKE '________-____-7___-____-____________')
    ,CONSTRAINT [PK_StaffPersonal] PRIMARY KEY ([LocalId])
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



