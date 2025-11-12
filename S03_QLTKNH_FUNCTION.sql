-- =============================================
-- TỔNG HỢP CÁC FUNCTION
-- =============================================

USE S03_QLTKNH;
GO

-- =============================================
-- FUNCTION TÍNH TOÁN LÃI SUẤT
-- =============================================

-- Function: Tính lãi đến ngày bất kỳ
CREATE OR ALTER FUNCTION fn_TinhLaiDenNgay(
    @TienGoc DECIMAL(18,2),
    @LaiSuat DECIMAL(5,2),
    @NgayMo DATE,
    @NgayTinh DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @SoNgay INT;
    DECLARE @Lai DECIMAL(18,2);

    SET @SoNgay = DATEDIFF(DAY, @NgayMo, @NgayTinh);
    SET @Lai = @TienGoc * (@LaiSuat / 100) * (@SoNgay / 365.0);

    RETURN ROUND(@Lai, 2);
END;
GO

-- Function: Tính lãi theo số ngày
CREATE OR ALTER FUNCTION fn_TinhLaiTheoNgay
(
    @SoTien DECIMAL(18,2),
    @LaiSuatNam DECIMAL(5,2),
    @SoNgay INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Lai DECIMAL(18,2);
    SET @Lai = @SoTien * (@LaiSuatNam / 100) * (@SoNgay / 365.0);
    RETURN @Lai;
END;
GO

-- =============================================
-- FUNCTION TÍNH TOÁN NGÀY THÁNG
-- =============================================

-- Function: Tính ngày đáo hạn
CREATE OR ALTER FUNCTION fn_TinhNgayDaoHan
(
    @NgayMoSo DATE,
    @KyHanThang INT
)
RETURNS DATE
AS
BEGIN
    RETURN DATEADD(MONTH, @KyHanThang, @NgayMoSo);
END;
GO

-- Function: Kiểm tra đáo hạn
CREATE OR ALTER FUNCTION fn_KiemTraDaoHan(@NgayDaoHan DATE)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @KetQua NVARCHAR(20);

    IF @NgayDaoHan <= GETDATE()
        SET @KetQua = N'Đã đáo hạn';
    ELSE
        SET @KetQua = N'Chưa đáo hạn';

    RETURN @KetQua;
END;
GO

-- =============================================
-- FUNCTION TÍNH TỔNG SỐ TIỀN ĐÃ NẠP VÀO STK
-- =============================================

CREATE OR ALTER FUNCTION fn_TongTienDaNhapSTK(@MaSTK CHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienNhap DECIMAL(18,2);

    SELECT @TongTienNhap = ISNULL(SUM(SoTienNop), 0)
    FROM GIAODICHNOP
    WHERE MaSTK = @MaSTK;

    RETURN @TongTienNhap;
END;
GO

-- =============================================
-- FUNCTION TÍNH TỔNG SỐ TIỀN ĐÃ RÚT TỪ STK
-- =============================================

CREATE OR ALTER FUNCTION fn_TongTienDaRutSTK(@MaSTK CHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienRut DECIMAL(18,2);

    SELECT @TongTienRut = ISNULL(SUM(SoTienRut), 0)
    FROM GIAODICHRUT
    WHERE MaSTK = @MaSTK;

    RETURN @TongTienRut;
END;
GO

