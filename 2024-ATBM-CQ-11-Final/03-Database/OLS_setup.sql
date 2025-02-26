--Connect as ADMIN_OLS to use this script
-- Chuyển sang pdb
alter session set container = PDBQLNoiBo;

--Tạo chính sách OLS
EXEC SA_SYSDBA.DROP_POLICY ('ols_policy'); 
EXEC SA_SYSDBA.CREATE_POLICY( policy_name => 'ols_policy',  column_name => 'ols_label' );  
EXEC SA_SYSDBA.ENABLE_POLICY ('ols_policy'); 

--Restart the database after successfully enabled the policy.
--shutdown immediate
--startup
--Use these 2 lines in sql plus to restart the database.

--Tạo level
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',100,'SV','Sinh vien'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',200,'NV','Nhan vien'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',300,'GVu','Giao vu'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',400,'GV','Giang vien'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',500,'TRGDV','Truong don vi'); 
EXECUTE SA_COMPONENTS.CREATE_LEVEL('ols_policy',600,'TRGKH','Truong khoa'); 

--GRANT SELECT ON DBA_SA_LEVELS TO ADMIN_OLS; -- Chạy trao quyền bằng SYS ở Pluggable Database.
--SELECT * FROM DBA_SA_LEVELS; --Xem level

-- Xoá tầng nếu cần.
--BEGIN
--  LBACSYS.SA_COMPONENTS.DROP_LEVEL(
--    policy_name => 'ols_policy',
--    level_num   => 100
--  );
--END;
--/

-- Tạo compartment
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',100,'HTTT','He thong thong tin');
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',120,'CNPM','Cong nghe phan men');
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',140,'KHMT','Khoa hoc may tinh');
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',160,'CNTT','Cong nghe thong tin');
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',180,'TGMT','Thi giac may tinh');
EXECUTE SA_COMPONENTS.CREATE_COMPARTMENT('ols_policy',200,'MMT','Mang may tinh');

--GRANT SELECT ON DBA_SA_COMPARTMENTS TO ADMIN_OLS; -- Chạy trao quyền bằng SYS ở Pluggable Database.
--SELECT * FROM DBA_SA_COMPARTMENTS; 

--Drop compartment nếu cần
--BEGIN
--  SA_COMPONENTS.DROP_COMPARTMENT (
--   policy_name     => 'ols_policy',
--   short_name      => 'MMT');
--END;
--/

--Tạo group
BEGIN
  LBACSYS.SA_COMPONENTS.CREATE_GROUP(
    policy_name => 'ols_policy',
    group_num   => 1,
    short_name  => 'UNI',
    long_name   => 'Dai hoc',
    parent_name => NULL
  );    
END;
/

BEGIN
  LBACSYS.SA_COMPONENTS.CREATE_GROUP(
    policy_name => 'ols_policy',
    group_num   => 100,
    short_name  => 'CS1',
    long_name   => 'Co so 1',
    parent_name => 'UNI'
  );    
END;
/

BEGIN
  LBACSYS.SA_COMPONENTS.CREATE_GROUP(
    policy_name => 'ols_policy',
    group_num   => 200,
    short_name  => 'CS2',
    long_name   => 'Co so 2',
    parent_name => 'UNI'
  );    
END;
/

--Xóa group nếu cần
--BEGIN
--  SA_COMPONENTS.DROP_GROUP (
--   policy_name     => 'ols_policy',
--   group_num       => 200);
--END;
--/

--GRANT SELECT ON DBA_SA_GROUPS TO ADMIN_OLS; -- Chạy trao quyền bằng SYS ở Pluggable Database.
--SELECT * FROM DBA_SA_GROUPS; 
--GRANT SELECT ON DBA_SA_GROUP_HIERARCHY TO ADMIN_OLS; -- Chạy trao quyền bằng SYS ở Pluggable Database.
--SELECT * FROM DBA_SA_GROUP_HIERARCHY; 

DROP TABLE THONGBAO CASCADE CONSTRAINTS;
CREATE TABLE THONGBAO (
    ID NUMBER PRIMARY KEY,
    NOIDUNG NVARCHAR2(2000)
);

INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (1,N'Thông báo này cho Trưởng khoa.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (2,N'Thông báo cho toàn bộ Giáo vụ.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (3,N'Thông báo t1 cho tất cả Trưởng đơn vị.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (4,N'Thông báo t2 cho sinh viên HTTT ở cơ sở 1.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (5,N'Thông báo t3 cho trưởng bộ môn KHMT ở cơ sở 1.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (6,N'Thông báo t4 cho trưởng bộ môn KHMT ở hai cơ sở.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (7,N'Thông báo về việc nghỉ tết của sinh viên.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (8,N'Thông báo về tiền thưởng của nhân viên.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (9,N'Thông báo về lịch làm việc của giảng viên ở cơ sở 2.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (10,N'Thông báo giáo vụ ở cơ sở 2.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (11,N'Thông báo dành cho trưởng bộ môn ở cơ sở 1.');
INSERT INTO THONGBAO(ID,NOIDUNG) VALUES (12,N'Thông báo dành cho giảng viên bộ môn CNPM.');

SELECT * FROM THONGBAO;

GRANT SELECT ON THONGBAO TO SINHVIEN;
GRANT SELECT ON THONGBAO TO NHANVIENCOBAN;
GRANT SELECT ON THONGBAO TO GIANGVIEN;
GRANT SELECT ON THONGBAO TO GIAOVU;
GRANT SELECT ON THONGBAO TO TRUONGDONVI;
GRANT SELECT ON THONGBAO TO TRUONGKHOA;


BEGIN 
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY ( 
        POLICY_NAME => 'ols_policy', 
        SCHEMA_NAME => 'ADMIN_OLS', 
        TABLE_NAME => 'THONGBAO', 
        TABLE_OPTIONS => 'NO_CONTROL' 
    ); 
END; 
/
-- Tạo nhãn
--Dữ liệu test câu a)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','TRGKH')
WHERE ID = 1;

--Dữ liệu test câu b)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','GVu')
WHERE ID = 2;

--d) Hãy cho biết nhãn của dòng thông báo t1 để t1 được phát tán (đọc) bởi tất cả Trưởng đơn vị.
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','TRGDV')
WHERE ID = 3;

--e) Hãy cho biết nhãn của dòng thông báo t2 để phát tán t2 đến Sinh viên thuộc ngành HTTT học ở Cơ sở 1.
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','SV:HTTT:CS1')
WHERE ID = 4;

--f) Hãy cho biết nhãn của dòng thông báo t3 để phát tán t3 đến Trưởng bộ môn KHMT ở Cơ sở 1.
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','TRGDV:KHMT:CS1')
WHERE ID = 5;

--g) Cho biết nhãn của dòng thông báo t4 để phát tán t4 đến Trưởng bộ môn KHMT ở Cơ sở 1 và Cơ sở 2.
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','TRGDV:KHMT')
WHERE ID = 6;

--h1)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','SV')
WHERE ID = 7;

--h2)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','NV')
WHERE ID = 8;

--h3)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','GV::CS2')
WHERE ID = 9;

--h4)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','GVu::CS2')
WHERE ID = 10;

--h5)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','TRGDV::CS1')
WHERE ID = 11;

--h6)
UPDATE THONGBAO 
SET ols_label = TO_DATA_LABEL('ols_policy','GV:CNPM')
WHERE ID = 12;

--Xóa nhãn nếu cần
--BEGIN
--  LBACSYS.SA_LABEL_ADMIN.DROP_LABEL(
--    policy_name => 'ols_policy',
--    label_tag  => '1000000000' -- replace with actual label tag
--  );
--END;
--/

-- Ap dung ols vao bang
BEGIN
    SA_POLICY_ADMIN.REMOVE_TABLE_POLICY(
        policy_name => 'ols_policy',
        schema_name => 'ADMIN_OLS',
        table_name  => 'Thongbao'
    );

    SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
        policy_name => 'ols_policy',
        schema_name => 'ADMIN_OLS',
        table_name => 'Thongbao',
        table_options => 'READ_CONTROL'
    );
END;
/

UPDATE THONGBAO SET ID = ID ;
COMMIT;

--Tạo user test thử
CREATE USER sinhvien_ols IDENTIFIED BY 1;
CREATE USER NHANVIEN_ols IDENTIFIED BY 1;
CREATE USER truongkhoa_ols IDENTIFIED BY 1;
CREATE USER tbmcs2 IDENTIFIED BY 1;
CREATE USER giaovu_ols IDENTIFIED BY 1;
CREATE USER tbm_KHMT_cs1 IDENTIFIED BY 1;
CREATE USER tbm_KHMT_cs2 IDENTIFIED BY 1;
CREATE USER gv_CNPM_cs2 IDENTIFIED BY 1;


GRANT CREATE SESSION TO sinhvien_ols,NHANVIEN_ols,truongkhoa_ols,tbmcs2,giaovu_ols,tbm_KHMT_cs1,tbm_KHMT_cs2,gv_CNPM_cs2;
GRANT SELECT ON ADMIN_OLS.THONGBAO TO sinhvien_ols,NHANVIEN_ols,truongkhoa_ols,tbmcs2,giaovu_ols,tbm_KHMT_cs1,tbm_KHMT_cs2,gv_CNPM_cs2;

--Cho phép ADMIN_OLS thấy tất cả thông báo
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'ADMIN_OLS',
    MAX_READ_LABEL  => 'TRGKH:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:UNI'
    );
END;
/

--a) Hãy gán nhãn cho người dùng là Trưởng khoa có thể đọc được toàn bộ thông báo.
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'TruongKhoa_ols',
    MAX_READ_LABEL  => 'TRGKH:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:UNI'
);
END;
/

--b) Hãy gán nhãn cho các Trưởng bộ môn phụ trách Cơ sở 2 có thể đọc được toàn bộ thông
--báo dành cho trưởng bộ môn không phân biệt vị trí địa lý.
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'tbmcs2',
    MAX_READ_LABEL  => 'TRGDV::UNI'
);
END;
/

--c) Hãy gán nhãn cho 01 Giáo vụ có thể đọc toàn bộ thông báo dành cho giáo vụ
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'giaovu_ols',
    MAX_READ_LABEL  => 'GVu::UNI'
);
END;
/

--e) test
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'sinhvien_ols',
    MAX_READ_LABEL  => 'SV:HTTT:CS1'
    );
END;
/

--f) test
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'tbm_KHMT_cs1',
    MAX_READ_LABEL  => 'TRGDV:KHMT:CS1'
    );
END;
/

--g) test
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'tbm_KHMT_cs2',
    MAX_READ_LABEL  => 'TRGDV:KHMT:CS2'
    );
END;
/

BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'gv_CNPM_cs2',
    MAX_READ_LABEL  => 'GV:CNPM:CS2'
    );
END;
/

--2 Groups: 
--5 Level, 6 Compartment 

BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
    POLICY_NAME  =>'OLS_POLICY',
    USER_NAME  => 'NHANVIEN_ols',
    MAX_READ_LABEL  => 'NV'
    );
END;
/

SELECT * FROM ALL_SA_LABELS;

--Test

--SELECT * FROM ADMIN_OLS.THONGBAO;

CREATE OR REPLACE PROCEDURE USP_LABEL_NHSU
AS 
 CURSOR CUR IS 
   SELECT NS.MANV, NS.VAITRO, DV.TENDV
   FROM PHANHE2.NHANSU NS JOIN PHANHE2.DONVI DV ON NS.MADV = DV.MADV
   WHERE UPPER(MaNV) IN (SELECT UPPER(USERNAME) FROM ALL_USERS); 
 USR PHANHE2.NHANSU.MANV%TYPE; 
 v_label VARCHAR2(100);
 v_role PHANHE2.NHANSU.VAITRO%TYPE;
 v_dv  PHANHE2.DONVI.TENDV%TYPE;
BEGIN 
 OPEN CUR; 
 LOOP 
   FETCH CUR INTO USR, v_role, v_dv; 
   EXIT WHEN CUR%NOTFOUND; 

   IF v_role = 'Nhân viên cơ bản' THEN
      v_label := 'NV'; 
   ELSIF v_role = 'Giảng viên' THEN
      v_label := 'GV';  
   ELSIF v_role = 'Trưởng đơn vị' THEN
      v_label := 'TRGDV'; 
   ELSIF v_role = 'Trưởng khoa' THEN
   BEGIN
      v_label := 'TRGKH:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:UNI'; 
      v_dv := 'TK';
   END;
   ELSIF v_role = 'Giáo vụ' THEN
      v_label := 'GVu';
   ELSE
      v_label := NULL;
   END IF;

    IF v_dv IN ('HTTT','CNPM','KHMT','CNTT','TGMT','MMT') THEN
        v_label := v_label || ':' || v_dv;
    END IF;
   -- Assuming SA_USER_ADMIN.SET_USER_LABELS is a valid procedure and accessible
   IF v_label IS NOT NULL THEN
     SA_USER_ADMIN.SET_USER_LABELS(
        POLICY_NAME  =>'OLS_POLICY',
        USER_NAME  => USR,
        MAX_READ_LABEL  => v_label
     );

     DBMS_OUTPUT.PUT_LINE(' User: ' || to_char(USR) || ' ''s max label: ' || to_char(v_label));
   ELSE
     DBMS_OUTPUT.PUT_LINE(' User: ' || to_char(USR) || ' has no valid role.');
   END IF;
 END LOOP; 
 CLOSE CUR; 
END; 
/

SET SERVEROUTPUT ON;
EXEC USP_LABEL_NHSU;

CREATE OR REPLACE PROCEDURE USP_LABEL_SV
AS 
 CURSOR CUR IS 
   SELECT MaSV,MANGANH
   FROM PHANHE2.SINHVIEN 
   WHERE UPPER(MaSV) IN (SELECT UPPER(USERNAME) FROM ALL_USERS); 
 USR PHANHE2.SINHVIEN.MASV%TYPE; 
 v_label VARCHAR2(20);
BEGIN 
 OPEN CUR; 
 LOOP 
   FETCH CUR INTO USR,v_label;
   EXIT WHEN CUR%NOTFOUND; 

  IF v_label IN ('HTTT','CNPM','KHMT','CNTT','TGMT','MMT') THEN
    v_label := 'SV:'|| v_label;
  ELSE
    v_label := 'SV';
  END IF;
  
  SA_USER_ADMIN.SET_USER_LABELS(
        POLICY_NAME  =>'OLS_POLICY',
        USER_NAME  => USR,
        MAX_READ_LABEL  => v_label
     );

     DBMS_OUTPUT.PUT_LINE(' User: ' || to_char(USR) || ' ''s max label: '|| to_char(v_label));
 END LOOP; 
 CLOSE CUR; 
END; 
/
EXEC USP_LABEL_SV;

