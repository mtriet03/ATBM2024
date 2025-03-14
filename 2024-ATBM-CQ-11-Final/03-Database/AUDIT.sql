/*--AS SYSDBA
ALTER SYSTEM SET audit_trail=DB, extended SCOPE=SPFILE;

SHUTDOWN IMMEDIATE;
STARTUP;

--Tham số audit_trailt = DB, EXTENDED chỉ định lưu các record audit vào bảng SYS.AUD$, bao gồm cả các SQL statements.
--Reset DB để áp dụng các thay đổi.
select * from nhansu;
GRANT AUDIT_ADMIN TO PHANHE2; --CẤP QUYỀN AUDIT ADMIN ĐỂ THỰC HIỆN FGA
*/

--AS USER PHANHE2
--STANDARD AUDIT
AUDIT ALL ON PHANHE2.NHANSU BY ACCESS; --AUDIT TẤT CẢ HÀNH ĐỘNG TRÊN BẢNG NHANSU, THỰC HIỆN MỖI KHI CÓ HÀNH ĐỘNG XẢY RA.
AUDIT ALL BY NS107; --AUDIT USER CỤ THỂ

AUDIT ALL ON PHANHE2.V_NHANSU BY ACCESS; --AUDIT TẤT CẢ HÀNH ĐỘNG TRÊN VIEW <>, THỰC HIỆN MỖI KHI CÓ HÀNH ĐỘNG XẢY RA.
-- Theo dõi hành vi EXECUTE trên stored procedure cụ thể
AUDIT EXECUTE ON PHANHE2.DROP_USERS_WITH BY ACCESS;

-- Theo dõi hành vi EXECUTE trên function cụ thể
AUDIT EXECUTE ON PHANHE2.GET_SEMESTER BY ACCESS;

AUDIT EXECUTE ON PHANHE2.drop_role_if_exists WHENEVER NOT SUCCESSFUL; --AUDIT KHI THỰC THI KHÔNG THÀNH CÔNG.
AUDIT EXECUTE ON PHANHE2.USP_CREATE_USER_NHSU WHENEVER SUCCESSFUL; --AUDIT KHI THỰC THI THÀNH CÔNG

--ĐỂ XEM CÁC BẢN GHI CỦA STANDARD AUDIT:
SELECT USERNAME, TIMESTAMP, OWNER, OBJ_NAME, ACTION_NAME, SQL_TEXT, SQL_BIND, CURRENT_USER 
FROM DBA_AUDIT_TRAIL 
ORDER BY EXTENDED_TIMESTAMP DESC


--FINE-GRAINED AUDIT
--Câu 1
BEGIN
    DBMS_FGA.ADD_POLICY(
        OBJECT_SCHEMA => 'PHANHE2',
        OBJECT_NAME => 'DANGKY',
        POLICY_NAME => 'AUDIT_ON_DANGKY',
        AUDIT_COLUMN => 'DIEMTH, DIEMQT, DIEMCK, DIEMTK',
        AUDIT_CONDITION => 'SYS_CONTEXT(''SYS_SESSION_ROLES'', ''GIANGVIEN'') = ''FALSE''',
        ENABLE => TRUE,
        STATEMENT_TYPES => 'UPDATE',
        AUDIT_TRAIL => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
END;
/
--NAMESPACE SYS_SESSION_ROLES CHO BIẾT ROLE CÓ TÊN GIỐNG NHƯ THAM SỐ ĐI KÈM CÓ ĐANG ĐƯỢC ACTIVE HAY KHÔNG.
--TẠO POLICY AUDIT_ON_DANGKY, AUDIT TRÊN CÁC CỘT LIÊN QUAN TỚI ĐIỂM SỐ, AUDIT KHI ROLE ACTIVE HIỆN TẠI CỦA USER KHÔNG PHẢI LÀ GIANGVIEN
--VÀ LỆNH ĐƯỢC CHỈ ĐỊNH AUDIT LÀ UPDATE.
/
--cau 2
--TẠO POLICY AUDIT_ON_NHANSU, AUDIT TRÊN CỘT PHUCAP, AUDIT KHI CÓ BẤT KỲ DÒNG NÀO ĐƯỢC TRẢ VỀ MÀ CÓ MANV KHÁC VỚI TÊN ĐĂNG NHẬP CỦA NGƯỜI
--DÙNG HIỆN TẠI (TƯƠNG ỨNG VỚI MANV CỦA USER TRONG BẢNG NHANSU), LỆNH ĐƯỢC CHỈ ĐỊNH AUDIT LÀ SELECT
BEGIN
    DBMS_FGA.ADD_POLICY(
        OBJECT_SCHEMA => 'PHANHE2',
        OBJECT_NAME => 'NHANSU',
        POLICY_NAME => 'AUDIT_ON_NHANSU',
        AUDIT_COLUMN => 'PHUCAP',
        AUDIT_CONDITION => 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') != MANV',
        ENABLE => TRUE,
        STATEMENT_TYPES => 'SELECT',
        AUDIT_TRAIL => DBMS_FGA.DB + DBMS_FGA.EXTENDED
    );
END;
/

--ĐỂ XEM CÁC BẢN GHI FGA
SELECT SESSION_ID, DB_USER, CLIENT_ID, OBJECT_NAME, POLICY_NAME, SQL_TEXT,SQL_BIND, STATEMENT_TYPE, EXTENDED_TIMESTAMP, CURRENT_USER
FROM DBA_FGA_AUDIT_TRAIL
ORDER BY EXTENDED_TIMESTAMP DESC;