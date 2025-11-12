-- =============================================
-- 5. Hàm fn_LaiTichLuyHienTai
-- Mục đích: Lấy tổng lãi tích lũy hiện tại của 1 sổ tiết kiệm
-- =============================================
CREATE FUNCTION fn_LaiTichLuyHienTai (@MaSTK CHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @LaiTichLuy DECIMAL(18,2);

    SELECT @LaiTichLuy = LaiTichLuy
    FROM BANGSODU
    WHERE MaSTK = @MaSTK;

    IF @LaiTichLuy IS NULL
        SET @LaiTichLuy = 0;

    RETURN @LaiTichLuy;
END;
GO

-- =============================================
-- 6. Hàm fn_TongTienNop
-- Mục đích: Tính tổng tiền nộp của 1 sổ tiết kiệm
-- =============================================
CREATE FUNCTION fn_TongTienNop (@MaSTK CHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongNop DECIMAL(18,2);

    SELECT @TongNop = SUM(SoTienNop)
    FROM GIAODICHNOP
    WHERE MaSTK = @MaSTK;

    IF @TongNop IS NULL
        SET @TongNop = 0;

    RETURN @TongNop;
END;
GO

-- =============================================
-- 7. Hàm fn_TongTienRut
-- Mục đích: Tính tổng tiền rút của 1 sổ tiết kiệm
-- =============================================
CREATE FUNCTION fn_TongTienRut (@MaSTK CHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongRut DECIMAL(18,2);

    SELECT @TongRut = SUM(SoTienRut)
    FROM GIAODICHRUT
    WHERE MaSTK = @MaSTK;

    IF @TongRut IS NULL
        SET @TongRut = 0;

    RETURN @TongRut;
END;
GO

--Đức
