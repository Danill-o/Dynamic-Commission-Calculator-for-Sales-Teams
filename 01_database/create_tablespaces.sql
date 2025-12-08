-- create_tablespaces.sql
-- Single consolidated script to configure tablespaces, memory, archive logging,
-- and create admin user for the Dynamic Commission Calculator PDB.
--
-- IMPORTANT: Run as SYSDBA in SQL*Plus or SQL Developer. Execute sections in order.
-- Usage (example): sqlplus / as sysdba
-- Then: @create_tablespaces.sql  (or copy-paste sections step-by-step)

/* ==========================================
   CONFIGURATION PARAMETERS (EDIT IF NEEDED)
   ========================================== */
-- PDB name
DEFINE PDB_NAME = mon_27296_daniel_commissioncalc_db

-- File path root (change if different)
DEFINE ORA_PATH = D:\Oracle_db21\product_21\oradata\XE

-- Admin user & password
DEFINE ADMIN_USER = commission_admin
DEFINE ADMIN_PWD  = Daniel

-- Memory settings (set in CDB$ROOT)
DEFINE SGA_TARGET = 700M
DEFINE PGA_TARGET = 400M

-- Tablespace sizes and autoextend increments
DEFINE DATA_SIZE   = 200M
DEFINE DATA_NEXT   = 50M
DEFINE INDEX_SIZE  = 100M
DEFINE INDEX_NEXT  = 20M
DEFINE TEMP_SIZE   = 200M
DEFINE TEMP_NEXT   = 50M

/* ============================
   SECTION 1: Set MEMORY (CDB$ROOT)
   ============================ */
PROMPT ===== Setting SGA/PGA in CDB$ROOT =====
ALTER SESSION SET CONTAINER = CDB$ROOT;
SHOW CON_NAME;

-- Review current values
SHOW PARAMETER sga_target;
SHOW PARAMETER pga_aggregate_target;

-- Set new values (may need adjustment for your server)
ALTER SYSTEM SET sga_target = &SGA_TARGET SCOPE = BOTH;
ALTER SYSTEM SET pga_aggregate_target = &PGA_TARGET SCOPE = BOTH;

SHOW PARAMETER sga_target;
SHOW PARAMETER pga_aggregate_target;

/* ============================
   SECTION 2: Enable ARCHIVELOG
   (This will SHUTDOWN and STARTUP the DB)
   ============================ */
PROMPT ===== Enabling ARCHIVELOG mode (will shutdown/startup) =====
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;

-- Set archive destination (create the directory on Windows beforehand)
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=&ORA_PATH.\\arch' SCOPE=BOTH;

ALTER DATABASE OPEN;

-- Verify
SELECT LOG_MODE FROM V$DATABASE;

/* ============================
   SECTION 3: Switch to PDB
   ============================ */
PROMPT ===== Switching to PDB: &PDB_NAME =====
ALTER SESSION SET CONTAINER = &PDB_NAME;
SHOW CON_NAME;

/* ============================
   SECTION 4: Create TABLESPACES (DATA, INDEX) and TEMP
   ============================ */
PROMPT ===== Creating tablespaces and temp tablespace =====

CREATE TABLESPACE commission_data
  DATAFILE '&ORA_PATH.\\commission_data01.dbf'
  SIZE &DATA_SIZE
  AUTOEXTEND ON NEXT &DATA_NEXT MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE commission_index
  DATAFILE '&ORA_PATH.\\commission_index01.dbf'
  SIZE &INDEX_SIZE
  AUTOEXTEND ON NEXT &INDEX_NEXT MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE commission_temp
  TEMPFILE '&ORA_PATH.\\commission_temp01.dbf'
  SIZE &TEMP_SIZE
  AUTOEXTEND ON NEXT &TEMP_NEXT MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
  UNIFORM SIZE 1M;

/* ============================
   SECTION 5: Create Admin User & Grants
   ============================ */
PROMPT ===== Creating admin user & grants =====
CREATE USER &ADMIN_USER IDENTIFIED BY "&ADMIN_PWD"
  DEFAULT TABLESPACE commission_data
  TEMPORARY TABLESPACE commission_temp
  QUOTA UNLIMITED ON commission_data;

GRANT CONNECT, RESOURCE TO &ADMIN_USER;
-- Grant DBA only if you require full DBA privileges for this user
-- GRANT DBA TO &ADMIN_USER;

/* ============================
   SECTION 6: Enable AUTOEXTEND on datafiles (safety)
   (If files already exist, this ensures autoextend is on)
   ============================ */
PROMPT ===== Ensuring DATAFILES AUTOEXTEND is enabled =====
ALTER DATABASE DATAFILE '&ORA_PATH.\\commission_data01.dbf' AUTOEXTEND ON NEXT &DATA_NEXT MAXSIZE UNLIMITED;
ALTER DATABASE DATAFILE '&ORA_PATH.\\commission_index01.dbf' AUTOEXTEND ON NEXT &INDEX_NEXT MAXSIZE UNLIMITED;
ALTER DATABASE TEMPFILE '&ORA_PATH.\\commission_temp01.dbf' AUTOEXTEND ON NEXT &TEMP_NEXT MAXSIZE UNLIMITED;

/* ============================
   SECTION 7: Verification Queries
   ============================ */
PROMPT ===== Verification: List tablespaces and files =====
SELECT TABLESPACE_NAME, CONTENTS, STATUS FROM DBA_TABLESPACES ORDER BY TABLESPACE_NAME;
SELECT FILE_NAME, TABLESPACE_NAME, BYTES/1024/1024 AS SIZE_MB, AUTOEXTENSIBLE FROM DBA_DATA_FILES WHERE TABLESPACE_NAME IN ('COMMISSION_DATA','COMMISSION_INDEX');
SELECT FILE_NAME, BYTES/1024/1024 AS SIZE_MB FROM DBA_TEMP_FILES;
SELECT USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE FROM DBA_USERS WHERE USERNAME = UPPER('&ADMIN_USER');

PROMPT ===== Script complete. Review output above for any errors =====
