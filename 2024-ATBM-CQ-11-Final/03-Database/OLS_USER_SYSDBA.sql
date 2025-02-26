-- CONNECT AS SYS

SELECT VALUE FROM v$option WHERE parameter = 'Oracle Label Security';
SELECT status FROM dba_ols_status WHERE name = 'OLS_CONFIGURE_STATUS';

-- Neu chua bat OLS thi chay 2 dong nay
EXEC LBACSYS.CONFIGURE_OLS;
EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;

-- Unlock lbacsys
Alter Session Set "_Oracle_Script"=True;
ALTER USER lbacsys IDENTIFIED BY lbacsys ACCOUNT UNLOCK;


-- Open pdb
ALTER PLUGGABLE DATABASE PDBQLNOIBO OPEN READ WRITE;
ALTER PLUGGABLE DATABASE PDBQLNOIBO SAVE STATE;

-- Chuyen sang pdb
ALTER SESSION SET CONTAINER = PDBQLNOIBO;
ALTER DATABASE OPEN;

-- Tao user admin_ols
DROP USER admin_ols CASCADE;
CREATE USER ADMIN_OLS IDENTIFIED BY 123;
GRANT CREATE SESSION TO ADMIN_OLS WITH ADMIN OPTION;
GRANT CONNECT,RESOURCE TO ADMIN_OLS; 
GRANT UNLIMITED TABLESPACE TO ADMIN_OLS; 
GRANT SELECT ANY DICTIONARY TO ADMIN_OLS; 
GRANT CREATE SESSION TO admin_ols;
GRANT EXECUTE ON LBACSYS.SA_COMPONENTS TO ADMIN_OLS WITH GRANT OPTION;
GRANT EXECUTE ON LBACSYS.sa_user_admin TO ADMIN_OLS WITH GRANT OPTION;
GRANT EXECUTE ON LBACSYS.sa_label_admin TO ADMIN_OLS WITH GRANT OPTION;
GRANT EXECUTE ON sa_policy_admin TO ADMIN_OLS WITH GRANT OPTION;
GRANT EXECUTE ON char_to_label TO ADMIN_OLS WITH GRANT OPTION;
GRANT EXECUTE ON TO_DATA_LABEL TO ADMIN_OLS WITH GRANT OPTION;
GRANT LBAC_DBA TO ADMIN_OLS;
GRANT EXECUTE ON sa_sysdba TO ADMIN_OLS;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO ADMIN_OLS; 
Grant alter session to admin_ols;
Grant set container to admin_ols;
Grant create table to admin_ols;
Grant unlimited tablespace to admin_ols;
Grant create user to admin_ols;
GRANT SELECT ANY TABLE TO ADMIN_OLS;