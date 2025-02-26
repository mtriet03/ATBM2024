----------------------------------------FILE CÀI ĐẶT 6 CHÍNH SÁCH-------------------------------------------------

----------------------------------------------CHÍNH SÁCH 1--------------------------------------------------------
--select * from nhansu where VAITRO = 'Nhân viên cơ bản';
--select * from dba_sys_privs

CREATE OR REPLACE VIEW V_NHANSU
AS
    SELECT * 
    FROM NHANSU
    WHERE MANV = SYS_CONTEXT('USERENV','SESSION_USER')
        --OR SYS_CONTEXT('USERENV', 'SESSION_USER') = 'PHANHE2' -- Exception for PHANHE2 user, uses for debugging
    WITH CHECK OPTION;
    
--select * from v_nhansu;

--Xem dòng dữ liệu của chính mình trong quan hệ NHANSU, có thể chỉnh sửa số điện
--thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT SELECT, UPDATE (dt) ON v_nhansu TO NhanVienCoBan;

--Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
GRANT SELECT ON SINHVIEN TO NhanVienCoBan;
GRANT SELECT ON DONVI TO NhanVienCoBan;
GRANT SELECT ON HOCPHAN TO NhanVienCoBan;
GRANT SELECT ON KHMO TO NhanVienCoBan;

----------------------------------------------CHÍNH SÁCH 2------------------------------------------------------
--select * from nhansu where VAITRO = 'Giảng viên';
--SELECT * FROM HOCPHAN;

--Gồm CS1
GRANT NhanVienCoBan TO GIANGVIEN;

--Check grant quyền thành công
--SELECT *
--FROM DBA_ROLE_PRIVS
--WHERE GRANTEE = 'GIANGVIEN';

--Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
--select * from PHANCONG;

CREATE OR REPLACE VIEW V_PHANCONG
AS
    SELECT * 
    FROM PHANCONG
    WHERE MAGV = SYS_CONTEXT('USERENV','SESSION_USER')
        --OR SYS_CONTEXT('USERENV', 'SESSION_USER') = 'PHANHE2' -- Exception for PHANHE2 user, uses for debugging
    WITH CHECK OPTION;

--select * from V_PHANCONG;

GRANT SELECT ON V_PHANCONG TO GIANGVIEN;

--Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên
--được phân công giảng dạy.
--select * from DANGKY --WHERE MAGV = 'NS011'
--;

CREATE OR REPLACE VIEW V_DANGKY
AS
    SELECT * 
    FROM DANGKY
    WHERE MAGV = SYS_CONTEXT('USERENV','SESSION_USER')
        --OR SYS_CONTEXT('USERENV', 'SESSION_USER') = 'PHANHE2' -- Exception for PHANHE2 user, uses for debugging
    WITH CHECK OPTION;
    
GRANT SELECT ON V_DANGKY TO GIANGVIEN;
--Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
--sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. Các
--trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
--select * from v_dangky;

GRANT UPDATE (DIEMTH,DIEMQT,DIEMCK,DIEMTK) ON V_DANGKY TO GIANGVIEN;

----------------------------------------------CHÍNH SÁCH 3------------------------------------------------------
--CS#3
--SELECT * FROM HOCPHAN WHERE MADV = 'DV01';

--SELECT * FROM DANGKY
--Như một người dùng có vài trò "Nhân viên cơ bản"
GRANT NHANVIENCOBAN to GIAOVU;

--Xem, Thêm mới hoặc Cập nhật dữ liệu trên các quan hệ SINHVIEN, ĐONVI,
--HOCPHAN, KHMO, theo yêu cầu của trưởng khoa.
GRANT SELECT,INSERT, UPDATE ON PHANHE2.SINHVIEN TO GIAOVU;

GRANT SELECT,INSERT, UPDATE ON PHANHE2.DONVI TO GIAOVU;

GRANT SELECT,INSERT, UPDATE ON PHANHE2.HOCPHAN TO GIAOVU;

GRANT SELECT,INSERT, UPDATE ON PHANHE2.KHMO TO GIAOVU;


CREATE OR REPLACE VIEW V_PHANCONG_GIAOVU AS
SELECT PC.PHANCONG_ID,PC.MAGV,PC.MAHP,PC.HK,PC.NAM,PC.MACT
FROM PHANCONG PC
JOIN (
    SELECT MAHP, MADV FROM HOCPHAN 
    WHERE MADV IN (
        SELECT MADV FROM DONVI WHERE TENDV = 'VPK'
    )
) HP ON PC.MAHP = HP.MAHP
JOIN DONVI DV ON DV.MADV = HP.MADV
WITH CHECK OPTION;
/

---SELECT * FROM V_PHANCONG_GIAOVU;
GRANT SELECT ON PHANHE2.PHANCONG TO GIAOVU;
GRANT SELECT,UPDATE ON PHANHE2.V_PHANCONG_GIAOVU TO GIAOVU;
GRANT SELECT ON PHANHE2.DANGKY TO GIAOVU;

CREATE OR REPLACE VIEW V_THOA_DANGKY_GIAOVU AS
SELECT 
    DK.DANGKY_ID,
    DK.MASV,
    DK.MAGV,
    DK.MAHP,
    DK.HK,
    DK.NAM,
    DK.MACT
FROM 
    DANGKY DK
WHERE 
    TO_NUMBER(SUBSTR(DK.NAM, 1, 4)) >= TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) - 1
    AND (
        (DK.HK = 1 AND EXTRACT(MONTH FROM SYSDATE) = 1) OR
        (DK.HK = 2 AND EXTRACT(MONTH FROM SYSDATE) = 5) OR
        (DK.HK = 3 AND EXTRACT(MONTH FROM SYSDATE) = 9)
    )
    AND EXTRACT(DAY FROM SYSDATE) <=15
    WITH CHECK OPTION;
/

--SELECT *FROM DANGKY
--SELECT * FROM V_THOA_DANGKY_GIAOVU;
GRANT SELECT,INSERT,DELETE ON PHANHE2.V_THOA_DANGKY_GIAOVU TO GIAOVU;

----------------------------------------------CHÍNH SÁCH 4------------------------------------------------------
--SELECT * FROM NHANSU WHERE VAITRO = 'Trưởng đơn vị';

--Như một người dùng có vai trò “Giảng viên” (xem mô tả CS#2).
GRANT GIANGVIEN TO TRUONGDONVI;

--select * from hocphan where madv = 'DV03'; --Test dùng NS101 là trưởng ĐV 3 nên xem DV03

--select * from sinhvien;
--select * from donvi;

--Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
--phụ trách chuyên môn bởi đơn vị mà mình làm trưởng,
CREATE OR REPLACE VIEW V_TRGDV_PHANCONG_HP
AS
    SELECT *
    FROM PHANCONG
    WHERE MAHP IN (SELECT MAHP
                      FROM HOCPHAN
                      WHERE MADV IN (SELECT MADV 
                                FROM DONVI 
                                WHERE TRGDV = SYS_CONTEXT('USERENV','SESSION_USER')
                                --OR SYS_CONTEXT('USERENV','SESSION_USER') = 'PHANHE2' --DEBUG
                                )
                      )
    WITH CHECK OPTION;      
--NEED SELECT PRIVILEGE IN ORDER TO USER WHERE CLAUSES WHEN I,U,D           
GRANT SELECT,INSERT,UPDATE,DELETE ON V_TRGDV_PHANCONG_HP TO TRUONGDONVI;

--Được xem dữ liệu phân công giảng dạy của các giảng viên thuộc các đơn vị mà mình
--làm trưởng.
CREATE OR REPLACE VIEW V_TRGDV_PHANCONG_GV
AS
    SELECT *
    FROM PHANCONG
    WHERE MAGV IN (SELECT MANV
                    FROM NHANSU 
                    WHERE LOWER(VAITRO) IN ('giảng viên' , 'trưởng đơn vị', 'trưởng khoa')
                    AND MADV IN (SELECT MADV 
                                FROM DONVI 
                                WHERE TRGDV = SYS_CONTEXT('USERENV','SESSION_USER')
                                --OR SYS_CONTEXT('USERENV','SESSION_USER') = 'PHANHE2' --DEBUG
                                )
                    )
    WITH CHECK OPTION;     

GRANT SELECT ON V_TRGDV_PHANCONG_GV TO TRUONGDONVI;

----------------------------------------------CHÍNH SÁCH 5------------------------------------------------------
CREATE OR REPLACE VIEW V_PHANCONG_TRUONGKHOA AS
SELECT *
FROM PHANCONG
WHERE MAHP IN (SELECT MAHP FROM HOCPHAN 
                    WHERE MADV IN (SELECT MADV FROM DONVI WHERE TENDV = 'VPK'))
WITH CHECK OPTION;
/

GRANT GIANGVIEN TO TRUONGKHOA;
GRANT SELECT, INSERT, DELETE, UPDATE ON NHANSU TO TRUONGKHOA;
GRANT SELECT ANY TABLE TO TRUONGKHOA;
GRANT SELECT, INSERT, DELETE, UPDATE ON V_PHANCONG_TRUONGKHOA TO TRUONGKHOA;

----------------------------------------------CHÍNH SÁCH 6------------------------------------------------------
--CS6
--GẮN VỊ TỪ TƯƠNG ỨNG MASV = SYSCONTEXT
GRANT SELECT ON PHANHE2.SINHVIEN TO SINHVIEN;
CREATE OR REPLACE FUNCTION POLICY1_ON_SINHVIEN (P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2 
AS 
    predicate VARCHAR2(4000);
    v_current_user VARCHAR2(10);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MASV = ''' || v_current_user || '''';
    END IF;
    RETURN predicate;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
                        OBJECT_SCHEMA => 'PHANHE2',
                        OBJECT_NAME => 'SINHVIEN',
                        POLICY_NAME => 'POLICY1',
                        POLICY_FUNCTION => 'POLICY1_ON_SINHVIEN',
                        STATEMENT_TYPES => 'SELECT'
                        );
END;
/

--SELECT * FROM SINHVIEN;
GRANT UPDATE (DT, DCHI) ON SINHVIEN TO SINHVIEN;
---------------------------------------------------------------------------------
--TUONG TU VOI CAU TREN
CREATE OR REPLACE FUNCTION UPDATE_POLICY_ON_SINHVIEN(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    predicate VARCHAR2(4000);
    v_current_user VARCHAR2(10);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MASV = ''' || v_current_user || '''';
    END IF;
    RETURN predicate;
END;
/
BEGIN
    DBMS_RLS.ADD_POLICY(
                        OBJECT_SCHEMA => 'PHANHE2',
                        OBJECT_NAME => 'SINHVIEN',
                        POLICY_NAME => 'POLICY2',
                        POLICY_FUNCTION => 'UPDATE_POLICY_ON_SINHVIEN',
                        STATEMENT_TYPES => 'UPDATE',
                        UPDATE_CHECK => TRUE,
                        sec_relevant_cols => 'DT, DCHI'
                        );
END;
/
--ĐỂ THỰC HIỆN CÂU TRUY VẤN TÌM CÁC HỌC PHẦN LIÊN QUAN TỚI CHƯƠNG TRÌNH HỌC CỦA
--SINH VIÊN, SINH VIÊN CẦN CÓ QUYỀN ĐỌC TRÊN HOCPHAN, DONVI.
GRANT SELECT ON HOCPHAN TO SINHVIEN;
--------------------------------------------------------------------------------- 
CREATE OR REPLACE FUNCTION POLICY1_ON_HOCPHAN(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    predicate VARCHAR2(4000);
    v_current_user VARCHAR2(10);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MADV = (SELECT MADV
                        FROM DONVI
                        JOIN SINHVIEN ON SINHVIEN.MANGANH = DONVI.TENDV)';
    END IF;
    RETURN predicate;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
                        OBJECT_SCHEMA => 'PHANHE2',
                        OBJECT_NAME => 'HOCPHAN',
                        POLICY_NAME => 'POLICY1',
                        POLICY_FUNCTION => 'POLICY1_ON_HOCPHAN',
                        STATEMENT_TYPES => 'SELECT'
                        );
END;
/

---------------------------------------------------------------------------------
/*
SELECT *
FROM KHMO
WHERE MACT = (SELECT MACT FROM SINHVIEN WHERE MASV = <MASV> ) AND MAHP IN (SELECT MAHP FROM HOCPHAN WHERE MADV = (SELECT MADV
                                                                        FROM DONVI
                                                                        JOIN SINHVIEN ON SINHVIEN.MANGANH = DONVI.TENDV
                                                                        WHERE MASV = <MASV>));
CÂU TRUY VẤN ĐỂ TÌM CÁC KH MỞ MÔN LIÊN QUAN TỚI CHƯƠNG TRÌNH HỌC VÀ NGÀNH HỌC CỦA SINH VIÊN
CÓ DẠNG NHƯ TRÊN, DO CÁC CÂU QUERY CON CÓ SỬ DỤNG ĐẾN BẢNG SINHVIEN, POLICY SẼ ÁP VỊ TỪ
MASV = SYS_CONTEXT ... nên vị từ của câu truy vấn trên được rút gọn lại thành:
                    MACT = (SELECT MACT FROM SINHVIEN) AND MAHP IN (SELECT MAHP 
                                                                    FROM HOCPHAN
                                                                    WHERE MADV = (SELECT MADV
                                                                                FROM DONVI
                                                                                JOIN SINHVIEN ON SINHVIEN.MANGANH = DONVI.TENDV)
*/
GRANT SELECT ON KHMO TO SINHVIEN;

CREATE OR REPLACE FUNCTION POLICY1_ON_KHMO(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    predicate VARCHAR2(1000);
    v_current_user VARCHAR2(10);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MACT = (SELECT MACT FROM SINHVIEN) AND MAHP IN (SELECT MAHP 
                                                                    FROM HOCPHAN
                                                                    WHERE MADV = (SELECT MADV
                                                                                FROM DONVI
                                                                                JOIN SINHVIEN ON SINHVIEN.MANGANH = DONVI.TENDV))';
    END IF;
    RETURN predicate;
END;
/
BEGIN
    DBMS_RLS.ADD_POLICY(
                        OBJECT_SCHEMA => 'PHANHE2',
                        OBJECT_NAME => 'KHMO',
                        POLICY_NAME => 'POLICY1',
                        POLICY_FUNCTION => 'POLICY1_ON_KHMO',
                        STATEMENT_TYPES => 'SELECT'
                        );
END;
/

-------------------------------------------------------
--HÀM LẤY SỐ KÌ TRONG NĂM
CREATE OR REPLACE FUNCTION GET_SEMESTER(input_date DATE)
RETURN VARCHAR2
AS
    semester NUMBER;
BEGIN
    IF input_date >= TO_DATE('01-01', 'DD-MM') AND input_date < TO_DATE('01-05', 'DD-MM') THEN
        semester := 1;
    ELSIF input_date >= TO_DATE('01-05', 'DD-MM') AND input_date < TO_DATE('01-09', 'DD-MM') THEN
        semester := 2;
    ELSE
        semester := 3;
    END IF;
    
    RETURN semester;
END GET_SEMESTER;
/
------------------------------------------------------------------
--CHÍNH SÁCH XÓA,THÊM
--VỊ TỪ BAO GỒM CÁC ĐIỀU KIỆN: KỲ HỌC LÀ KỲ HIỆN TẠI, NĂM HỌC LÀ NĂM HIỆN TẠI
--NGÀY KHÔNG QUÁ 2 TUẦN KỂ TỪ ĐẦU KÌ HỌC
--MÃ SV LÀ MÃ SV CỦA USER ĐANG LOG IN
GRANT DELETE, INSERT ON DANGKY TO SINHVIEN;

CREATE OR REPLACE FUNCTION POLICY1_ON_DANGKY(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    predicate VARCHAR2(4000);
    v_current_user VARCHAR2(20);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MASV = ''' || v_current_user || ''' AND HK = ' || GET_SEMESTER(SYSDATE) || 
                     ' AND NAM LIKE ''' || TO_CHAR(EXTRACT(YEAR FROM SYSDATE)-1) || '-%''' || 
                     ' AND ' || EXTRACT(DAY FROM SYSDATE) || ' <= 15'||
                     ' AND EXTRACT(MONTH FROM SYSDATE) IN (1,5,9)';
    END IF;
    RETURN predicate;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA   => 'PHANHE2',
        OBJECT_NAME     => 'DANGKY',
        POLICY_NAME     => 'DELETE_INSERT_POLICY',
        POLICY_FUNCTION => 'POLICY1_ON_DANGKY',
        STATEMENT_TYPES => 'DELETE,INSERT',
        UPDATE_CHECK => TRUE
    );
END;
/

GRANT SELECT ON DANGKY TO SINHVIEN;
---------------------------------------------------------------------------------
--ĐƯỢC XEM TẤT CẢ CÁC DÒNG LIÊN QUAN TỚI BẢN THÂN
CREATE OR REPLACE FUNCTION SELECT_POLICY_ON_DANGKY(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    predicate VARCHAR2(4000);
    v_current_user VARCHAR2(10);
BEGIN
    v_current_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF v_current_user LIKE 'SV%' THEN
        predicate := 'MASV = ''' || v_current_user || '''';
    END IF;
    RETURN predicate;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
                        OBJECT_SCHEMA => 'PHANHE2',
                        OBJECT_NAME => 'DANGKY',
                        POLICY_NAME => 'POLICY1',
                        POLICY_FUNCTION => 'SELECT_POLICY_ON_DANGKY',
                        STATEMENT_TYPES => 'SELECT'
                        );
END;
/

--Trigger chống nhập điểm
CREATE OR REPLACE TRIGGER trg_prevent_confidential_insert
BEFORE INSERT ON DANGKY
FOR EACH ROW
DECLARE
    v_username VARCHAR2(100);
BEGIN
    SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') INTO v_username FROM DUAL;

    IF NOT REGEXP_LIKE(v_username, '^SV\d{4}$') THEN
        RETURN;
    END IF;

    IF :NEW.DIEMTH IS NOT NULL OR :NEW.DIEMQT IS NOT NULL OR :NEW.DIEMCK IS NOT NULL OR :NEW.DIEMTK IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'SInh viên không được phép nhập điểm.');
    END IF;
    
END;
/

