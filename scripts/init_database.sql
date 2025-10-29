/*==============================================================================
 Script : Create_DataWarehouse_Structure.sql
 Objet  : (Re)crée la base 'DataWarehouse' + schémas bronze/silver/gold
 Date   : 2025-10-29 (Asia/Makassar) | Version : 1.0
 Note   : DROP conditionnel (SINGLE_USER + ROLLBACK IMMEDIATE). ⚠ Supprime les données.
 Usage  : Exécuter avec droits suffisants (sysadmin/dbcreator) depuis SSMS/SQLCMD.
==============================================================================*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
