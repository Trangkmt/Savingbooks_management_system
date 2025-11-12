
-- =============================================
-- THỦ TỤC THÊM GIAO DỊCH NỘP TIỀN
-- =============================================
CREATE OR ALTER PROCEDURE sp_Them_GiaoDichNop
    @MaGDNop        CHAR(10),
    @MaSTK          CHAR(10),
    @MaNVThucHien   CHAR(10),
    @MaLoaiGD       CHAR(10),
    @SoTienNop      DECIMAL(18,2),
    @NgayGD         DATE,
    @HTThanhToan    NVARCHAR(50),
    @GhiChu         NVARCHAR(255)
AS
BEGIN
     ;

    -- Kiểm tra sổ tiết kiệm có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Sổ tiết kiệm không tồn tại.';
        RETURN;
    END;

    -- Cập nhật tiền gốc và tiền hiện tại
    UPDATE SOTIETKIEM
    SET 
        TienGoc = TienGoc + @SoTienNop,
        TienHT = TienHT + @SoTienNop
    WHERE MaSTK = @MaSTK;

    -- Ghi nhận giao dịch nộp tiền
    INSERT INTO GIAODICHNOP (
        MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, 
        SoTienNop, NgayGD, HTThanhToan, GhiChu
    )
    VALUES (
        @MaGDNop, @MaSTK, @MaNVThucHien, @MaLoaiGD,
        @SoTienNop, @NgayGD, @HTThanhToan, @GhiChu
    );

    PRINT N'Nộp tiền thành công.';
END;
GO


-- =============================================
-- THỦ TỤC THÊM GIAO DỊCH RÚT TIỀN
-- =============================================
CREATE OR ALTER PROCEDURE sp_Them_GiaoDichRut
    @MaGDRut        CHAR(10),
    @MaSTK          CHAR(10),
    @MaNVThucHien   CHAR(10),
    @MaLoaiGD       CHAR(10),
    @SoTienRut      DECIMAL(18,2),
    @NgayGD         DATE,
    @LaiSuatApDung  DECIMAL(9,4),
    @LaiNhanDuoc    DECIMAL(18,2),
    @GhiChu         NVARCHAR(255)
AS
BEGIN
    DECLARE @TienHT DECIMAL(18,2);

    -- Lấy tiền hiện tại
    SELECT @TienHT = TienHT FROM SOTIETKIEM WHERE MaSTK = @MaSTK;

    -- Kiểm tra sổ tồn tại
    IF @TienHT IS NULL
    BEGIN
        PRINT N'Sổ tiết kiệm không tồn tại.';
        RETURN;
    END;

    -- Kiểm tra đủ tiền rút
    IF @TienHT < @SoTienRut
    BEGIN
        PRINT N'Số tiền trong sổ không đủ để rút.';
        PRINT N'Tiền hiện tại: ' + CAST(@TienHT AS NVARCHAR(50));
        PRINT N'Số tiền cần rút: ' + CAST(@SoTienRut AS NVARCHAR(50));
        RETURN;
    END;

    -- Cập nhật số tiền hiện tại
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - @SoTienRut
    WHERE MaSTK = @MaSTK;

    -- Thêm bản ghi giao dịch rút
    INSERT INTO GIAODICHRUT (
        MaGDRut, MaSTK, MaNVThucHien, MaLoaiGD,
        SoTienRut, NgayGD, LaiSuatApDung, LaiNhanDuoc, GhiChu
    )
    VALUES (
        @MaGDRut, @MaSTK, @MaNVThucHien, @MaLoaiGD,
        @SoTienRut, @NgayGD, @LaiSuatApDung, @LaiNhanDuoc, @GhiChu
    );

    PRINT N'Rút tiền thành công.';
END;
GO

CREATE OR ALTER PROCEDURE sp_TraCuuSoTietKiem
    @MaSTK CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Sổ tiết kiệm không tồn tại!';
        RETURN;
    END;

    SELECT 
        SOTIETKIEM.MaSTK,
        SOTIETKIEM.MaTK,
        KHACHHANG.MaKH,
        KHACHHANG.TenKH,
        KHACHHANG.CMND,
        KHACHHANG.SDT,
        SOTIETKIEM.TienGoc,
        SOTIETKIEM.TienHT,
        SOTIETKIEM.NgayMoSo,
        SOTIETKIEM.NgayDaoHan,
        SOTIETKIEM.TrangThai,
        TAIKHOAN.SoTK,
        NHANVIEN.TenNV AS NhanVienTao
    FROM SOTIETKIEM, TAIKHOAN, KHACHHANG, NHANVIEN
    WHERE SOTIETKIEM.MaSTK = @MaSTK
      AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
      AND TAIKHOAN.MaKH = KHACHHANG.MaKH
      AND SOTIETKIEM.MaNVTao = NHANVIEN.MaNV;
END;
GO

CREATE OR ALTER PROCEDURE sp_ThongKeTheoNhanVien
    @MaNV CHAR(10),
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNV = @MaNV)
    BEGIN
        PRINT N'Nhân viên không tồn tại!';
        RETURN;
    END;

    SELECT 
        NHANVIEN.MaNV,
        NHANVIEN.TenNV,
        COUNT(DISTINCT SOTIETKIEM.MaSTK) AS SoSoMo,
        SUM(ISNULL(GIAODICHNOP.SoTienNop, 0)) AS TongTienGui,
        SUM(ISNULL(GIAODICHRUT.SoTienRut, 0)) AS TongTienRut
    FROM NHANVIEN, SOTIETKIEM, GIAODICHNOP, GIAODICHRUT
    WHERE NHANVIEN.MaNV = @MaNV
      AND SOTIETKIEM.MaNVTao = NHANVIEN.MaNV
      AND GIAODICHNOP.MaSTK = SOTIETKIEM.MaSTK
      AND GIAODICHRUT.MaSTK = SOTIETKIEM.MaSTK
      AND (GIAODICHNOP.NgayGD BETWEEN @TuNgay AND @DenNgay 
        OR GIAODICHRUT.NgayGD BETWEEN @TuNgay AND @DenNgay)
    GROUP BY NHANVIEN.MaNV, NHANVIEN.TenNV;
END;
GO

CREATE OR ALTER PROCEDURE sp_KiemTraSoDu
    @MaSTK CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGSODU WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Không có dữ liệu số dư cho sổ này!';
        RETURN;
    END;

    SELECT 
        BANGSODU.MaSoDu,
        BANGSODU.MaSTK,
        BANGSODU.NgayCapNhat,
        BANGSODU.SoDuGoc,
        BANGSODU.LaiTichLuy,
        BANGSODU.SoDuThucTe
    FROM BANGSODU
    WHERE BANGSODU.MaSTK = @MaSTK;
END;
GO

CREATE OR ALTER PROCEDURE sp_TraCuuKhachHangTheoCMND
    @CMND CHAR(12)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE CMND = @CMND)
    BEGIN
        PRINT N'CMND không tồn tại trong hệ thống!';
        RETURN;
    END;

    SELECT 
        KHACHHANG.MaKH,
        KHACHHANG.TenKH,
        KHACHHANG.SDT,
        KHACHHANG.Email,
        KHACHHANG.DiaChi,
        TAIKHOAN.MaTK,
        TAIKHOAN.SoTK,
        TAIKHOAN.SoDu,
        SOTIETKIEM.MaSTK,
        SOTIETKIEM.TienGoc,
        SOTIETKIEM.TienHT,
        SOTIETKIEM.NgayMoSo,
        SOTIETKIEM.TrangThai
    FROM KHACHHANG, TAIKHOAN, SOTIETKIEM
    WHERE KHACHHANG.CMND = @CMND
      AND KHACHHANG.MaKH = TAIKHOAN.MaKH
      AND TAIKHOAN.MaTK = SOTIETKIEM.MaTK;
END;
GO

--ĐỨC

-- ======Thêm bớt sửa xóa =================
-- THỦ TỤC: Thêm tài khoản ngân hàng (đã check)
CREATE PROCEDURE sp_Them_TaiKhoan
    @MaTK CHAR(20),
    @MaKH CHAR(20),
    @MaNVQL CHAR(20),
    @SoTK CHAR(12),
    @SoDu DECIMAL(18,2),
    @NgayMoTK DATE,
    @TrangThai NVARCHAR(50)
AS
BEGIN
    INSERT INTO TKNH (MaTK, MaKH, MaNVQL, SoTK, SoDu, NgayMoTK, TrangThai)
    VALUES (@MaTK, @MaKH, @MaNVQL, @SoTK, @SoDu, @NgayMoTK, @TrangThai);
END;
GO
SELECT * FROM TKNH
EXEC sp_Them_TaiKhoan 'TKNH11','KH10','NV03','100000000011', '40000000', '2025-10-31', N'Hoạt động'

-- THỦ TỤC: Cập nhật thông tin tài khoản ngân hàng (đã check)
CREATE PROCEDURE sp_Sua_TaiKhoan
    @MaTK CHAR(20),
    @MaKH CHAR(20),
    @MaNVQL CHAR(20),
    @SoTK CHAR(12),
    @SoDu DECIMAL(18,2),
    @NgayMoTK DATE,
    @TrangThai NVARCHAR(50)
AS
BEGIN
    UPDATE TKNH
    SET 
        MaKH = @MaKH,
        MaNVQL = @MaNVQL,
        SoTK = @SoTK,
        SoDu = @SoDu,
        NgayMoTK = @NgayMoTK,
        TrangThai = @TrangThai
    WHERE MaTK = @MaTK;
END;
GO
SELECT * FROM TKNH
EXEC sp_Sua_TaiKhoan 'TKNH11', 'KH10', 'NV01', '092102148294','100000000', ' 2025-11-01', N'Hoạt động'

-- THỦ TỤC: Xóa tài khoản ngân hàng (đã check)
CREATE PROCEDURE sp_Xoa_TaiKhoan
    @MaTK CHAR(20)
AS
BEGIN
    DELETE FROM TKNH
    WHERE MaTK = @MaTK;
END;
GO
EXEC sp_Xoa_TaiKhoan 'TKNH11'

-- THỦ TỤC: Thêm sổ tiết kiệm mới (đã check)
CREATE OR ALTER PROCEDURE sp_Them_SoTietKiem
    @MaSTK CHAR(20),
    @MaTK CHAR(20),
    @MaNVTao CHAR(20),
    @MaLoaiHinh CHAR(20),
    @MaHTTraLai CHAR(20),
    @MaHTGui CHAR(20),
    @TienGoc DECIMAL(18,2),
    @TienHT DECIMAL(18,2),
    @NgayMoSo DATE,
    @TrangThai NVARCHAR(50)
AS
BEGIN

    DECLARE @KyHanThang INT;
    DECLARE @NgayDaoHan DATE;

    SELECT @KyHanThang = KyHanThang
    FROM LoaiHinhTK
    WHERE MaLoaiHinh = @MaLoaiHinh;

    SET @NgayDaoHan = DATEADD(MONTH, ISNULL(@KyHanThang, 0), @NgayMoSo);

    INSERT INTO STK (
        MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
        TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai
    )
    VALUES (
        @MaSTK, @MaTK, @MaNVTao, @MaLoaiHinh, @MaHTTraLai, @MaHTGui,
        @TienGoc, @TienHT, @NgayMoSo, @NgayDaoHan, @TrangThai
    );

    INSERT INTO BANGSODU (MaSoDu, MaSTK, NgayCapNhat, SoDuGoc, LaiTichLuy)
    VALUES (
        CONCAT('SD', @MaSTK),  -- Mã số dư = 'SD' + mã sổ, bạn có thể đổi cách sinh mã
        @MaSTK,
        @NgayMoSo,
        @TienGoc,
        0
    );
END;
GO
SELECT * FROM LoaiHinhTK
SELECT * FROM STK
SELECT * FROM BANGSODU
EXEC sp_Them_SoTietKiem
	@MaSTK = 'STK11',
	@MaTK = 'TKNH05',
	@MaNVTao = 'NV01',
	@MaLoaiHinh = 'LHTK01',
	@MaHTTraLai = 'HTTL01',
	@MaHTGui = 'HTG01',
	@TienHT = '0',
    @TienGoc = 10000000,
	@NgayMoSo = '2025-11-1',
	@TrangThai = N'Đang hoạt động'



-- THỦ TỤC: Cập nhật thông tin sổ tiết kiệm (đã check)
CREATE OR ALTER PROCEDURE sp_Sua_SoTietKiem
    @MaSTK CHAR(20),
    @MaTK CHAR(20),
    @MaNVTao CHAR(20),
    @MaLoaiHinh CHAR(20),
    @MaHTTraLai CHAR(20),
    @MaHTGui CHAR(20),
    @TienGoc DECIMAL(18,2),
    @TienHT DECIMAL(18,2),
    @NgayMoSo DATE,
    @TrangThai NVARCHAR(50)
AS
BEGIN

    DECLARE @KyHanThang INT;
    DECLARE @NgayDaoHan DATE;

    -- 1. Lấy lại kỳ hạn để tính lại ngày đáo hạn (nếu đổi loại hình)
    SELECT @KyHanThang = KyHanThang
    FROM LoaiHinhTK
    WHERE MaLoaiHinh = @MaLoaiHinh;

    SET @NgayDaoHan = DATEADD(MONTH, ISNULL(@KyHanThang, 0), @NgayMoSo);

    -- 2. Cập nhật thông tin sổ tiết kiệm
    UPDATE STK
    SET 
        MaTK = @MaTK,
        MaNVTao = @MaNVTao,
        MaLoaiHinh = @MaLoaiHinh,
        MaHTTraLai = @MaHTTraLai,
        MaHTGui = @MaHTGui,
        TienGoc = @TienGoc,
        TienHT = @TienHT,
        NgayMoSo = @NgayMoSo,
        NgayDaoHan = @NgayDaoHan,
        TrangThai = @TrangThai
    WHERE MaSTK = @MaSTK;

    -- 3. Cập nhật lại số dư gốc trong BANGSODU nếu có thay đổi
    UPDATE BANGSODU
    SET SoDuGoc = @TienGoc
    WHERE MaSTK = @MaSTK;
END;
GO

SELECT * FROM STK
EXEC sp_Sua_SoTietKiem
    @MaSTK = 'STK01',
    @MaTK = 'TKNH01',
    @MaNVTao = 'NV02',
    @MaLoaiHinh = 'LHTK03',
    @MaHTTraLai = 'HTTL03',
    @MaHTGui = 'HTG03',
    @TienGoc = 25000000,
    @TienHT = 25000000,
    @NgayMoSo = '2025-03-01',
    @TrangThai = N'Gia hạn';


-- Thủ Tục: Thêm bảng tính lãi (đã check)
CREATE OR ALTER PROCEDURE sp_Them_BangTinhLai
    @MaTinhLai CHAR(20),
    @MaSTK CHAR(20),
    @MaNVTinh CHAR(20),
    @NgayTinhLai DATE,
    @LaiSuatApDung DECIMAL(5,2),
    @SoDuTinhLai DECIMAL(18,2),
    @LaiThangNay DECIMAL(18,2),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    INSERT INTO BangTinhLai (MaTinhLai, MaSTK, MaNVTinh, NgayTinhLai, LaiSuatApDung, SoDuTinhLai, LaiThangNay, LaiTichLuy)
    VALUES (@MaTinhLai, @MaSTK, @MaNVTinh, @NgayTinhLai, @LaiSuatApDung, @SoDuTinhLai, @LaiThangNay, @LaiTichLuy);

    -- Cập nhật lãi tích lũy vào bảng số dư
    UPDATE BANGSODU
    SET LaiTichLuy = ISNULL(LaiTichLuy, 0) + @LaiThangNay
    WHERE MaSTK = @MaSTK;
END;
GO
SELECT * FROM BangTinhLai
EXEC sp_Them_BangTinhLai @MaTinhLai = 'BTL11', @MaSTK = 'STK01', @MaNVTinh = 'NV01', @NgayTinhLai = '2025-11-1', @LaiSuatApDung = '4', @SoDuTinhLai = '2000000000', @LaiThangNay = '100000', @LaiTichLuy = '1000000'


-- Thủ tục: sửa bảng tính lãi (đã check)
CREATE OR ALTER PROCEDURE sp_Sua_BangTinhLai
    @MaTinhLai CHAR(20),
    @LaiSuatApDung DECIMAL(5,2),
    @SoDuTinhLai DECIMAL(18,2),
    @LaiThangNay DECIMAL(18,2),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    UPDATE BangTinhLai
    SET 
        LaiSuatApDung = @LaiSuatApDung,
        SoDuTinhLai = @SoDuTinhLai,
        LaiThangNay = @LaiThangNay,
        LaiTichLuy = @LaiTichLuy
    WHERE MaTinhLai = @MaTinhLai;
END;
GO
SELECT * FROM BangTinhLai
EXEC sp_Sua_BangTinhLai
	@MaTinhLai = 'BTL11',
    @LaiSuatApDung = '5',
    @SoDuTinhLai = '10000000',
    @LaiThangNay = '20000',
    @LaiTichLuy = '10000'


-- Thủ tục: them bảng số dư (đã check)
CREATE OR ALTER PROCEDURE sp_Them_BangSoDu
    @MaSoDu CHAR(20),
    @MaSTK CHAR(20),
    @SoDuGoc DECIMAL(18,2),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    INSERT INTO BANGSODU (MaSoDu, MaSTK, SoDuGoc, LaiTichLuy)
    VALUES (@MaSoDu, @MaSTK, @SoDuGoc, @LaiTichLuy);
END;
GO
SELECT * FROM BANGSODU
EXEC sp_Them_BangSoDu
	@MaSoDu = 'BSD11',
    @MaSTK = 'STK11',
    @SoDuGoc = 200000000,
    @LaiTichLuy = 100000


-- thủ tục: sửa bảng số dư (đã check)
CREATE OR ALTER PROCEDURE sp_Sua_BangSoDu
    @MaSoDu CHAR(20),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    UPDATE BANGSODU
    SET LaiTichLuy = @LaiTichLuy
    WHERE MaSoDu = @MaSoDu;
END;
GO
SELECT * FROM BANGSODU
EXEC sp_Sua_BangSoDu 'BSD11','3000'

-- Thủ tục: thêm báo cáo (đã check)
CREATE OR ALTER PROCEDURE sp_Them_BaoCao
    @MaBaoCao CHAR(20),
    @MaSTK CHAR(20),
    @MaNVTao CHAR(20),
    @LoaiBaoCao NVARCHAR(50),
    @TongTienGui DECIMAL(18,2),
    @TongLaiNhan DECIMAL(18,2),
    @SoDuHienTai DECIMAL(18,2)
AS
BEGIN
    INSERT INTO BaoCao (MaBaoCao, MaSTK, MaNVTao, LoaiBaoCao, TongTienGui, TongLaiNhan, SoDuHienTai)
    VALUES (@MaBaoCao, @MaSTK, @MaNVTao, @LoaiBaoCao, @TongTienGui, @TongLaiNhan, @SoDuHienTai);
END;
GO
SELECT * FROM BaoCao
EXEC sp_Them_BaoCao 'BC11','STK01','NV01',N'Lãi tháng', '20000000', '2000000', '22000000'


--===================THỦ TỤC CÁC CHỨC NĂNG CHÍNH ===================
-- Thủ tục: mở sổ tiết kiệm mới (đã check)
CREATE OR ALTER PROCEDURE sp_MoSoTietKiemMoi
    @MaSTK CHAR(20),
    @MaSoDu CHAR(20),
    @MaKH CHAR(20),
    @MaLoaiHinh CHAR(20),
    @MaHTGui CHAR(20),
    @MaHTTraLai CHAR(20),
    @TienGoc DECIMAL(18,2),
    @MaNV CHAR(20)
AS
BEGIN
    DECLARE @KyHan INT, @NgayMo DATE = GETDATE(), @NgayDaoHan DATE, @MaTK CHAR(20);

    --Kiểm tra khách hàng tồn tại
    IF NOT EXISTS (SELECT 1 FROM KH WHERE MaKH = @MaKH)
    BEGIN
        PRINT N'Khách hàng không tồn tại.';
        RETURN;
    END;

    --Kiểm tra số tiền gửi tối thiểu
    IF @TienGoc < 100000
    BEGIN
        PRINT N'Số tiền gửi tối thiểu phải từ 100.000đ trở lên.';
        RETURN;
    END;

    --Lấy kỳ hạn từ loại hình TK
    SELECT @KyHan = KyHanThang FROM LoaiHinhTK WHERE MaLoaiHinh = @MaLoaiHinh;

    IF @KyHan IS NULL
    BEGIN
        PRINT N'Loại hình tiết kiệm không hợp lệ.';
        RETURN;
    END;

    SET @NgayDaoHan = DATEADD(MONTH, @KyHan, @NgayMo);

    --Lấy tài khoản ngân hàng của khách
    SELECT TOP 1 @MaTK = MaTK FROM TKNH WHERE MaKH = @MaKH;

    IF @MaTK IS NULL
    BEGIN
        PRINT N'Khách hàng chưa có tài khoản ngân hàng.';
        RETURN;
    END;

    --Thêm sổ tiết kiệm
    INSERT INTO STK(MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                    TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
    VALUES (@MaSTK, @MaTK, @MaNV, @MaLoaiHinh, @MaHTTraLai, @MaHTGui,
            @TienGoc, @TienGoc, @NgayMo, @NgayDaoHan, N'Đang hoạt động');

    --Tạo dòng trong bảng số dư
    INSERT INTO BANGSODU(MaSoDu, MaSTK, SoDuGoc, LaiTichLuy)
    VALUES (@MaSoDu, @MaSTK, @TienGoc, 0);

    PRINT N'Mở sổ tiết kiệm mới thành công. Mã sổ: ' + @MaSTK;
END;
GO
SELECT * FROM STK
SELECT * FROM BANGSODU
SELECT * FROM KH
SELECT * FROM LoaiHinhTK
SELECT * FROM HTGui
SELECT * FROM HinhThucTraLai

EXEC sp_MoSoTietKiemMoi
	@MaSTK = 'STK11',
    @MaSoDu = 'BSD11',
    @MaKH = 'KH10',
    @MaLoaiHinh = 'LHTK01',
    @MaHTGui = 'HTG02',
    @MaHTTraLai = 'HTTL01',
    @TienGoc = '1000000',
    @MaNV = 'NV02'


-- thủ tục: gửi thêm tiền vô sổ tiết kiệm (đã check)
CREATE OR ALTER PROCEDURE sp_GuiTienVaoSo
    @MaGD CHAR(20),      
    @MaSTK CHAR(20),
    @SoTien DECIMAL(18,2),
    @MaNV CHAR(20),
    @MaLoaiGD CHAR(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM STK WHERE MaSTK = @MaSTK AND TrangThai = N'Đang hoạt động')
    BEGIN
        PRINT N'Sổ tiết kiệm không hoạt động.';
        RETURN;
    END;
    IF @SoTien <= 0
    BEGIN
        PRINT N'Số tiền gửi phải lớn hơn 0.';
        RETURN;
    END;

    -- 🔹 Cập nhật số dư gốc
    UPDATE BANGSODU
    SET SoDuGoc = SoDuGoc + @SoTien
    WHERE MaSTK = @MaSTK;

    -- 🔹 Ghi vào bảng giao dịch nộp (dùng mã bạn nhập)
    INSERT INTO GDnop(MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, SoTienNop)
    VALUES (@MaGD, @MaSTK, @MaNV, @MaLoaiGD, @SoTien);

    -- 🔹 Thông báo kết quả
    PRINT N'Nộp tiền thành công. Số tiền nộp: ' + CAST(@SoTien AS NVARCHAR(20));
END;
GO
EXEC sp_GuiTienVaoSo 
    @MaGD = 'GDnop11', 
    @MaSTK = 'STK10', 
    @SoTien = 2000000, 
    @MaNV = 'NV01', 
    @MaLoaiGD = 'LGD01';
SELECT * FROM GDnop
SELECT * FROM LoaiGD
SELECT * FROM BANGSODU


-- thủ tục: rút tiền (đã check)
CREATE OR ALTER PROCEDURE sp_RutTienTuSo
    @MaGD CHAR(20),
    @MaSTK CHAR(20),
    @SoTienRut DECIMAL(18,2),
    @MaNV CHAR(20),
    @MaLoaiGD CHAR(20)
AS
BEGIN
    DECLARE @SoDu DECIMAL(18,2), 
            @NgayDaoHan DATE, 
            @LaiSuat DECIMAL(5,2),
            @NgayHienTai DATE = GETDATE(),
            @LaiNhan DECIMAL(18,2);

    -- 🔹 Lấy thông tin số dư và ngày đáo hạn (dùng WHERE thay vì JOIN)
    SELECT 
        @SoDu = B.SoDuThucTe, 
        @NgayDaoHan = S.NgayDaoHan
    FROM STK S, BANGSODU B
    WHERE S.MaSTK = B.MaSTK AND S.MaSTK = @MaSTK;

    -- 🔹 Kiểm tra đủ tiền rút hay không
    IF @SoTienRut > @SoDu
    BEGIN
        PRINT N'Số dư không đủ để rút.';
        RETURN;
    END;

    -- 🔹 Xác định lãi suất (nếu rút trước hạn)
    IF @NgayHienTai < @NgayDaoHan
        SET @LaiSuat = 0.3;  -- ví dụ: 0.3% nếu rút trước hạn
    ELSE
        SELECT @LaiSuat = LaiSuatNam / 12 
        FROM LoaiHinhTK
        WHERE MaLoaiHinh = (SELECT MaLoaiHinh FROM STK WHERE MaSTK = @MaSTK);

    -- 🔹 Tính lãi nhận được
    SET @LaiNhan = @SoTienRut * @LaiSuat / 100;

    -- 🔹 Cập nhật số dư sau khi rút
    UPDATE BANGSODU
    SET SoDuGoc = SoDuGoc - @SoTienRut
    WHERE MaSTK = @MaSTK;

    -- 🔹 Ghi vào bảng giao dịch rút (dùng mã bạn nhập)
    INSERT INTO GDrut(MaGDrut, MaSTK, MaNVThucHien, MaLoaiGD, SoTienRut, LaiSuatApDung, LaiNhanDuoc)
    VALUES (@MaGD, @MaSTK, @MaNV, @MaLoaiGD, @SoTienRut, @LaiSuat, @LaiNhan);

    -- 🔹 Nếu rút hết tiền, đóng sổ
    IF @SoTienRut = @SoDu
        UPDATE STK SET TrangThai = N'Đã tất toán' WHERE MaSTK = @MaSTK;

    PRINT N'Rút tiền thành công. Số tiền rút: ' + CAST(@SoTienRut AS NVARCHAR(20)) 
        + N', Lãi nhận được: ' + CAST(@LaiNhan AS NVARCHAR(20));
END;
GO
DELETE GDrut WHERE MaGDrut = 'GDrut11' 
EXEC sp_RutTienTuSo 'GDrut11','STK10',2000000,'NV01', 'LGD02'
SELECT * FROM STK
SELECT * FROM GDrut
SELECT * FROM LoaiGD
SELECT * FROM BANGSODU

-- thủ tục: tính và cộng dồn lãi theo tháng (đã check)
CREATE OR ALTER PROCEDURE sp_TinhLaiHangThang
    @MaTinhLai CHAR(20),
    @MaSTK CHAR(20),
    @MaNV CHAR(20)
AS
BEGIN
    DECLARE @LaiSuatThang DECIMAL(5,2),
            @SoDu DECIMAL(18,2),
            @LaiThang DECIMAL(18,2),
            @LaiTichLuy DECIMAL(18,2);

    SELECT @LaiSuatThang = LaiSuatThang
    FROM LoaiHinhTK
    WHERE MaLoaiHinh = (SELECT MaLoaiHinh FROM STK WHERE MaSTK = @MaSTK);

    SELECT @SoDu = SoDuThucTe FROM BANGSODU WHERE MaSTK = @MaSTK;

    SET @LaiThang = @SoDu * @LaiSuatThang / 100;
    SET @LaiTichLuy = ISNULL((SELECT LaiTichLuy FROM BANGSODU WHERE MaSTK = @MaSTK), 0) + @LaiThang;

    INSERT INTO BangTinhLai(MaTinhLai, MaSTK, MaNVTinh, LaiSuatApDung, SoDuTinhLai, LaiThangNay, LaiTichLuy)
    VALUES (@MaTinhLai, @MaSTK, @MaNV, @LaiSuatThang, @SoDu, @LaiThang, @LaiTichLuy);

    UPDATE BangSoDu
    SET LaiTichLuy = @LaiTichLuy
    WHERE MaSTK = @MaSTK;
END;
GO
EXEC sp_TinhLaiHangThang 'BTL15','STK01','NV01'
GO
SELECT * FROM BANGSODU
SELECT * FROM BangTinhLai
SELECT * FROM STK
SELECT * FROM LoaiHinhTK

--Nghĩa
