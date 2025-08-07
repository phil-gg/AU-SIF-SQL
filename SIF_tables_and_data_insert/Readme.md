# Explanation of files in this folder 

 -  **"Drop-then-Create-SIF-tables.sql"** is the most important file in this
    folder.  This is the target SIF data structure, with a complete set of
    relational (PK, FK) and uniqueness constraints.
 -  **"Edited-DDL-for-SIF-AU-v3.6.3.sql"** is a set of tables without constraints
    auto-generated from the SIF XML specification.  Tables have been copied from
    here, then modified to accelerate the build of Drop-then-Create-SIF-tables.sql
 -  **"cdm_demo_gold-local-db-setup.sql"** is a short script to set up a local
    Microsoft SQL Server instance with suitable database and permissions to host
    and run Drop-then-Create-SIF-tables.sql
 -  *"Aborted-Conditional-Logic-for-Synapse-Analytics.sql"* attempted to build
    tables without constraints on Synapse, but tables with constraints on other
    database engines.  This proved too laborious and slow, and is depreciated.
