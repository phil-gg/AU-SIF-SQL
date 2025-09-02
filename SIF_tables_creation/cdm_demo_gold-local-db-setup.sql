/* Setup script to analyse SIF in a local SQL Server instance */
-- Switch context to root
USE master;
GO

-- Check if the database exists and create it if not
IF NOT EXISTS (
                SELECT 1
                FROM sys.databases
                WHERE name = N'demo_integration_gold'
                )
BEGIN
        PRINT 'Database [demo_integration_gold] does not exist. Creating now...';

        CREATE DATABASE [demo_integration_gold];

        PRINT 'Database [demo_integration_gold] created successfully.';
END
ELSE
BEGIN
        PRINT 'Database [demo_integration_gold] already exists.';
END
GO

-- Switch context to the target database
USE [demo_integration_gold];
GO

-- Enable query store if available
IF SERVERPROPERTY('ProductVersion') > '12'
        ALTER DATABASE [demo_integration_gold]

SET QUERY_STORE = ON;

PRINT 'Enabled query store.';
GO

-- Check if the cdm_demo_gold schema exists and create it if not
IF NOT EXISTS (
                SELECT 1
                FROM sys.schemas
                WHERE name = N'cdm_demo_gold'
                )
BEGIN
        PRINT 'Schema [cdm_demo_gold] does not exist. Creating now...';

        EXEC ('CREATE SCHEMA cdm_demo_gold AUTHORIZATION dbo;')
                ;

        -- Note that dbo is the schema owner
        PRINT 'Schema [cdm_demo_gold] created successfully.';
END
ELSE
BEGIN
        PRINT 'Schema [cdm_demo_gold] already exists.';
END
GO

-- WARNING: The following makes the demo_integration_gold database really insecure!
-- Grant db_owner role to guest user for demo_integration_gold database
IF NOT EXISTS (
                SELECT 1
                FROM sys.database_role_members
                WHERE role_principal_id = (
                                SELECT principal_id
                                FROM sys.database_principals
                                WHERE name = 'db_owner'
                                )
                        AND member_principal_id = (
                                SELECT principal_id
                                FROM sys.database_principals
                                WHERE name = 'guest'
                                )
                )
BEGIN
        PRINT 'guest is not yet db_owner for demo_integration_gold. Granting now...';

        ALTER ROLE db_owner ADD MEMBER guest;

        PRINT 'guest user successfully granted db_owner role.';
END
ELSE
BEGIN
        PRINT 'guest is already a db_owner for demo_integration_gold.';
END
GO

-- Make cdm_demo_gold default schema for guest user
IF NOT EXISTS (
                SELECT 1
                FROM sys.database_principals
                WHERE name = 'guest'
                        AND default_schema_name = 'cdm_demo_gold'
                )
BEGIN
        PRINT 'cdm_demo_gold is not yet default schema for guest. Altering now...';

        ALTER USER guest
                WITH DEFAULT_SCHEMA = cdm_demo_gold;

        PRINT 'guest user default schema is now cdm_demo_gold.';
END
ELSE
BEGIN
        PRINT 'cdm_demo_gold is already default schema for guest user.';
END
GO
