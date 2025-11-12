--TRIGGER
-- =============================================
-- TRIGGER 1: Khi nộp tiền -> cộng vào sổ tiết kiệm
-- =============================================
CREATE TRIGGER trg_Insert_GiaoDichNop
ON GIAODICHNOP
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT + inserted.SoTienNop
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi nộp tiền.';
END;
GO

-- =============================================
-- TRIGGER 2: Khi rút tiền -> trừ vào sổ tiết kiệm
-- =============================================
CREATE TRIGGER trg_Insert_GiaoDichRut
ON GIAODICHRUT
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - inserted.SoTienRut
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi rút tiền.';
END;
GO

-- =============================================
-- TRIGGER 3: Khi thay đổi loại hình tiết kiệm -> cập nhật ngày đáo hạn
-- =============================================
CREATE TRIGGER trg_Update_SoTietKiem
ON SOTIETKIEM
AFTER UPDATE
AS
BEGIN
    IF UPDATE(MaLoaiHinh)
    BEGIN
        UPDATE SOTIETKIEM
        SET NgayDaoHan = DATEADD(MONTH, LOAIHINHTK.KyHanThang, SOTIETKIEM.NgayMoSo)
        FROM SOTIETKIEM, LOAIHINHTK, inserted
        WHERE SOTIETKIEM.MaSTK = inserted.MaSTK
          AND SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh;

        PRINT N'Đã cập nhật lại ngày đáo hạn do thay đổi loại hình tiết kiệm.';
    END;
END;
GO

--Đức


-- Trigger: xóa STK nếu k có giao dịch và ngược lại (đã check)
CREATE OR ALTER TRIGGER trg_Delete_SoTietKiem
ON STK
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @MaSTK CHAR(20);
    SELECT @MaSTK = MaSTK FROM DELETED;
    IF EXISTS (
        SELECT 1 FROM GDnop WHERE MaSTK = @MaSTK
        UNION
        SELECT 1 FROM GDrut WHERE MaSTK = @MaSTK
    )
    BEGIN
        PRINT N'Sổ tiết kiệm này đã có giao dịch phát sinh — KHÔNG THỰC HIỆN XÓA.';
        RETURN;
    END
    ELSE
    BEGIN
        DELETE FROM STK WHERE MaSTK = @MaSTK;
        PRINT N'Đã xóa sổ tiết kiệm thành công (không có giao dịch).';
    END
END;
GO
SELECT * FROM STK
SELECT * FROM GDnop
SELECT * FROM GDrut
SELECT * FROM BangSoDuSTK
DELETE FROM BangSoDuSTK WHERE MaSTK = 'STK11'
DELETE FROM STK WHERE MaSTK = 'STK11';

-- Trigger: tính lãi tích lũy sau khi insert vô Bảng tính lãi (đã check)
CREATE OR ALTER TRIGGER trg_Insert_BangTinhLai
ON BangTinhLai
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET 
        s.LaiTichLuy = ISNULL(s.LaiTichLuy, 0) + i.LaiThangNay,
        s.NgayCapNhat = GETDATE()
    FROM BangSoDuSTK s, INSERTED i
    WHERE s.MaSTK = i.MaSTK;

    PRINT N'Đã cập nhật lãi tích lũy vào bảng số dư.';
END;
GO
SELECT * FROM BangTinhLai
SELECT * FROM BangSoDuSTK
INSERT INTO BangTinhLai (MaTinhLai,MaSTK,MaNVTinh,NgayTinhLai,LaiThangNay,LaiSuatApDung,SoDuTinhLai) VALUES ('BTL12','STK02','NV01', '2025-10-31',2000000,4,2000000)


-- Trigger: update BSD thì sẽ auto update cả ngày cập nhật (đã check)
CREATE OR ALTER TRIGGER trg_Update_BangSoDu
ON BangSoDuSTK
AFTER UPDATE
AS
BEGIN
    UPDATE s
    SET 
        s.NgayCapNhat = GETDATE()
    FROM BangSoDuSTK s, inserted i
	WHERE s.MaSoDu = i.MaSoDu;

    PRINT N'Đã cập nhật lại số dư thực tế và ngày cập nhật.';
END;
GO
SELECT * FROM BangSoDuSTK
UPDATE BangSoDuSTK
	SET LaiTichLuy = 1
	WHERE MaSoDu = 'BSD01'

