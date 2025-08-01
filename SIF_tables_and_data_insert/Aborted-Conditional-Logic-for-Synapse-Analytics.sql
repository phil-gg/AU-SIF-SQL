-- Check if running on Azure SQL Database
DECLARE @IsAzureSQL BIT;
IF CAST(SERVERPROPERTY('EngineEdition') AS INT) > 5 -- 6+ are Azure-hosted SQL Engines
BEGIN
    SET @IsAzureSQL = 1;
END
ELSE
BEGIN
    SET @IsAzureSQL = 0;
END

-- Set the database context and appropriate variables
IF @IsAzureSQL = 1
BEGIN
-- Azure Synapse Analytics does not support enforcing unique contraints or clustered keys
-- We turn off the enforcement on Azure only
    EXEC sp_set_session_context @key = N'IsClustered', @value = N'NONCLUSTERED';
    EXEC sp_set_session_context @key = N'IsUniqueEnforced', @value = N'NOT ENFORCED';
    PRINT N'Detected Azure SQL.  Set IsClustered & IsUniqueEnforced to NONCLUSTERED & NOT ENFORCED';
    PRINT N'If this script fails, please change your connection to the ''CommonDataModel_Schema'' database.';
    PRINT N'This can be done using the drop-down menu in the Synapse Workspace UI.';
END
ELSE
BEGIN
-- Blank string variables to enforce unique contraints and use clustered keys
    EXEC sp_set_session_context @key = N'IsClustered', @value = N'';
    EXEC sp_set_session_context @key = N'IsUniqueEnforced', @value = N'';
    PRINT N'Detected On-premises SQL Server. Unique will be enforced and clustered keys will be used.';
-- Yes, bit of a shame Schema is in the DB name, but it is the client config received, and sticking with it
    USE [CommonDataModel_Schema];
    PRINT N'Using database [CommonDataModel_Schema].';
END
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

  -- TO-DO

-- SUBSECTION: Tables with 1 in name define a new PK used by child 2 table(s) 

BEGIN
DECLARE @IsClusteredValue VARCHAR (16);
DECLARE @IsUniqueEnforcedValue VARCHAR (16);
DECLARE @DynamicSql NVARCHAR(MAX);
SET @IsClusteredValue = CAST(SESSION_CONTEXT(N'IsClustered') AS  VARCHAR (16));
SET @IsUniqueEnforcedValue = CAST(SESSION_CONTEXT(N'IsUniqueEnforced') AS VARCHAR (16));
SET @DynamicSql = '
CREATE TABLE cdm_demo_gold.Dim1StaffPersonal (
     [RefId] CHAR (36) NOT NULL
    ,[LocalId] INT NOT NULL
    ,[StateProvinceId] VARCHAR (111) NULL
    ,[Title] VARCHAR (111) NULL
    ,[EmploymentStatus] VARCHAR (111) NULL
    ,CONSTRAINT [PK_StaffPersonal] PRIMARY KEY ' + @IsClusteredValue + ' ([RefId]) ' + @IsUniqueEnforcedValue + '
    ,CONSTRAINT [StaffPersonalLocalIdUnique] UNIQUE ([LocalId]) ' + @IsUniqueEnforcedValue + '
);
';
EXEC sp_executesql @DynamicSql;
PRINT N'Created cdm_demo_gold.Dim1StaffPersonal';
END
GO

-- SUBSECTION: Tables with 2 in name have FK referencing parent 1 table(s)

BEGIN
DECLARE @IsClusteredValue VARCHAR (16);
DECLARE @IsUniqueEnforcedValue VARCHAR (16);
DECLARE @DynamicSql NVARCHAR(MAX);
SET @IsClusteredValue = CAST(SESSION_CONTEXT(N'IsClustered') AS  VARCHAR (16));
SET @IsUniqueEnforcedValue = CAST(SESSION_CONTEXT(N'IsUniqueEnforced') AS VARCHAR (16));
SET @DynamicSql = '
CREATE TABLE cdm_demo_gold.Dim2StaffList (
     [StaffRefId] CHAR (36)  NOT NULL
    ,[StaffLocalId] INT NOT NULL
    ,CONSTRAINT [PK_StaffList] PRIMARY KEY ' + @IsClusteredValue + ' ([StaffRefId]) ' + @IsUniqueEnforcedValue + '
    ,CONSTRAINT [StaffListLocalIdUnique] UNIQUE ([StaffLocalId]) ' + @IsUniqueEnforcedValue + '
    ,CONSTRAINT [FK_StaffList_StaffPersonal_RefId] FOREIGN KEY ([StaffRefId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([RefId]) ' + @IsUniqueEnforcedValue + '
    ,CONSTRAINT [FK_StaffList_StaffPersonal_LocalId] FOREIGN KEY ([StaffLocalId]) REFERENCES cdm_demo_gold.Dim1StaffPersonal ([LocalId]) ' + @IsUniqueEnforcedValue + '
);
';
PRINT @DynamicSql;
EXEC sp_executesql @DynamicSql;
PRINT N'Created cdm_demo_gold.Dim2StaffList';
END
GO
