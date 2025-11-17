-- =============================================
-- TỔNG HỢP TRIGGER
-- =============================================
USE S03_QLTKNH;
GO

-- =============================================
-- TRIGGER CHO BẢNG SOTIETKIEM
-- =============================================

-- Trigger: Ngăn xóa sổ tiết kiệm nếu đã có giao dịch
CREATE OR ALTER TRIGGER trg_Delete_SoTietKiem
ON SOTIETKIEM
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @MaSTK CHAR(10);
    SELECT @MaSTK = MaSTK FROM DELETED;
    
    IF EXISTS (SELECT 1 FROM GIAODICHNOP WHERE MaSTK = @MaSTK
               UNION
               SELECT 1 FROM GIAODICHRUT WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Sổ tiết kiệm này đã có giao dịch phát sinh — KHÔNG THỰC HIỆN XÓA.';
        RETURN;
    END
    ELSE
    BEGIN
        DELETE FROM SOTIETKIEM WHERE MaSTK = @MaSTK;
        PRINT N'Đã xóa sổ tiết kiệm thành công (không có giao dịch).';
    END
END;
GO

-- Trigger: Cập nhật ngày đáo hạn 
CREATE OR ALTER TRIGGER trg_Update_SoTietKiem
ON SOTIETKIEM
AFTER UPDATE
AS
BEGIN
    IF UPDATE(MaLoaiHinh)
    BEGIN
        UPDATE SOTIETKIEM
        SET NgayDaoHan = DATEADD(MONTH, LOAIHINHTK.KyHanThang, SOTIETKIEM.NgayMoSo)
        FROM SOTIETKIEM, LOAIHINHTK
        WHERE SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh;
    END
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG GIAODICHNOP
-- =============================================

-- Trigger: Cập nhật số dư khi nộp tiền
CREATE OR ALTER TRIGGER trg_Insert_GiaoDichNop
ON GIAODICHNOP
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT + inserted.SoTienNop
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;
    UPDATE BANGSODU
    SET SoDuGoc = SoDuGoc + inserted.SoTienNop  
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi nộp tiền.';
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG GIAODICHRUT
-- =============================================

-- Trigger: Cập nhật số dư khi rút tiền
CREATE OR ALTER TRIGGER trg_Insert_GiaoDichRut
ON GIAODICHRUT
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - inserted.SoTienRut
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;
    UPDATE BANGSODU 
    SET SoDuGoc = SoDuGoc - inserted.SoTienRut
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;
    

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi rút tiền.';
END;
GO


-- =============================================
-- TRIGGER CHO BẢNG BANGTINHLAI
-- =============================================

-- Trigger: Cập nhật lãi tích lũy sau khi thêm bảng tính lãi
CREATE OR ALTER TRIGGER trg_Insert_BangTinhLai
ON BANGTINHLAI
AFTER INSERT
AS
BEGIN
    UPDATE BANGSODU
    SET LaiTichLuy = ISNULL(BANGSODU.LaiTichLuy, 0) + inserted.LaiThangNay,
        NgayCapNhat = GETDATE()
    FROM BANGSODU, inserted
    WHERE BANGSODU.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật lãi tích lũy vào bảng số dư.';
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG BANGSODU
-- =============================================

-- Trigger: Cập nhật ngày cập nhật khi thay đổi số dư
CREATE OR ALTER TRIGGER trg_Update_BangSoDu
ON BANGSODU
AFTER UPDATE
AS
BEGIN
    UPDATE BANGSODU
    SET NgayCapNhat = GETDATE()
    FROM BANGSODU, inserted
    WHERE BANGSODU.MaSoDu = inserted.MaSoDu;

    PRINT N'Đã cập nhật ngày cập nhật số dư.';
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG KHACHHANG
-- =============================================

-- Trigger: Kiểm tra trùng CCCD khi thêm khách hàng
CREATE OR ALTER TRIGGER trg_Insert_KhachHang
ON KHACHHANG
AFTER INSERT
AS
BEGIN
    DECLARE @MaKH CHAR(10), @CMND CHAR(12);
    SELECT @MaKH = MaKH, @CMND = CMND FROM inserted;

    IF (SELECT COUNT(*) FROM KHACHHANG WHERE CMND = @CMND) > 1
    BEGIN
        DELETE FROM KHACHHANG WHERE MaKH = @MaKH;
        PRINT N'CMND đã tồn tại. Đã hủy thêm khách hàng trùng.';
    END
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG NHANVIEN
-- =============================================

-- Trigger: Cập nhật trạng thái khi nhân viên nghỉ việc
CREATE OR ALTER TRIGGER trg_Update_NhanVien
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    DECLARE @MaNV CHAR(10), @TrangThai NVARCHAR(50);
    SELECT @MaNV = MaNV, @TrangThai = TrangThai FROM inserted;

    IF @TrangThai LIKE N'%Nghỉ%' OR @TrangThai LIKE N'%Nghỉ việc%'
    BEGIN
        UPDATE TAIKHOAN
        SET TrangThai = N'Không hoạt động'
        WHERE MaNVQL = @MaNV;

        PRINT N'Nhân viên nghỉ việc. Đã cập nhật trạng thái tài khoản liên quan.';
    END
END;
GO

-- Trigger: Xử lý khi xóa nhân viên
CREATE OR ALTER TRIGGER trg_Delete_NhanVien
ON NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @MaNV CHAR(10);
    SELECT @MaNV = MaNV FROM deleted;

    UPDATE NHANVIEN
    SET TrangThai = N'Nghỉ việc'
    WHERE MaNV = @MaNV;

    PRINT N'Đã đánh dấu nghỉ việc cho nhân viên ' + @MaNV;
END;
GO

-- =============================================
-- TRIGGER CHO BẢNG BAOCAO
-- =============================================

-- Trigger: Tự động tính toán thông tin khi thêm báo cáo
CREATE OR ALTER TRIGGER trg_Insert_BaoCao
ON BAOCAO
AFTER INSERT
AS
BEGIN
    DECLARE @MaBaoCao CHAR(10), @MaSTK CHAR(10);
    DECLARE @SoTienGoc DECIMAL(18,2),
            @TongNop DECIMAL(18,2),
            @TongRut DECIMAL(18,2),
            @TongLai DECIMAL(18,2),
            @SoDu DECIMAL(18,2);

    SELECT @MaBaoCao = MaBaoCao, @MaSTK = MaSTK FROM inserted;

    SELECT @SoTienGoc = ISNULL(TienGoc,0)
    FROM SOTIETKIEM WHERE MaSTK = @MaSTK;

    SELECT @TongNop = ISNULL(SUM(SoTienNop),0)
    FROM GIAODICHNOP WHERE MaSTK = @MaSTK;

    SELECT @TongRut = ISNULL(SUM(SoTienRut),0)
    FROM GIAODICHRUT WHERE MaSTK = @MaSTK;

    SELECT @TongLai = ISNULL(SUM(LaiThangNay),0)
    FROM BANGTINHLAI WHERE MaSTK = @MaSTK;

    SELECT TOP 1 @SoDu = SoDuThucTe
    FROM BANGSODU
    WHERE MaSTK = @MaSTK
    ORDER BY NgayCapNhat DESC;

    IF @SoDu IS NULL
        SET @SoDu = @SoTienGoc + @TongNop - @TongRut + @TongLai;

    UPDATE BAOCAO
    SET TongTienGui = @SoTienGoc + @TongNop,
        TongLaiNhan = @TongLai,
        SoDuHienTai = @SoDu
    WHERE MaBaoCao = @MaBaoCao;

    PRINT N'Đã tự động tính toán thông tin cho báo cáo mới.';
END;
GO