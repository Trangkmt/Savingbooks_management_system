-- ============================================
-- TỔNG HỢP CÁC THỦ TỤC
-- ============================================
USE S03_QLTKNH;
GO

-- =============================================
-- PHẦN 1: THỦ TỤC QUẢN LÝ TÀI KHOẢN NGÂN HÀNG
-- =============================================

-- Thủ tục: Thêm tài khoản ngân hàng
CREATE OR ALTER PROCEDURE sp_Them_TaiKhoan
    @MaTK CHAR(10),
    @MaKH CHAR(10),
    @MaNVQL CHAR(10),
    @SoTK CHAR(12),
    @SoDu DECIMAL(18,2),
    @NgayMoTK DATE,
    @TrangThai NVARCHAR(50)
AS
BEGIN
    -- Kiểm tra tài khoản đã tồn tại
    IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE MaTK = @MaTK)
    BEGIN
        PRINT N'Mã tài khoản đã tồn tại';
        RETURN;
    END;
    
    -- Kiểm tra số tài khoản đã tồn tại
    IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE SoTK = @SoTK)
    BEGIN
        PRINT N'Số tài khoản đã tồn tại';
        RETURN;
    END;
    
    INSERT INTO TAIKHOAN (MaTK, MaKH, MaNVQL, SoTK, SoDu, NgayMoTK, TrangThai)
    VALUES (@MaTK, @MaKH, @MaNVQL, @SoTK, @SoDu, @NgayMoTK, @TrangThai);
    
    PRINT N'Thêm tài khoản thành công';
END;
GO

-- Thủ tục: Sửa tài khoản ngân hàng
CREATE OR ALTER PROCEDURE sp_Sua_TaiKhoan
    @MaTK CHAR(10),
    @MaKH CHAR(10) = NULL,
    @MaNVQL CHAR(10) = NULL,
    @SoTK CHAR(12) = NULL,
    @SoDu DECIMAL(18,2) = NULL,
    @NgayMoTK DATE = NULL,
    @TrangThai NVARCHAR(50) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM TAIKHOAN WHERE MaTK = @MaTK)
    BEGIN
        PRINT N'Tài khoản không tồn tại';
        RETURN;
    END;
    
    UPDATE TAIKHOAN
    SET 
        MaKH = COALESCE(@MaKH, MaKH), --coalesce() trả về null hoặc ko null nếu giá trị biến khác ban đầu --> giúp chỉnh sửa 1 hay nhiều thông tin
        MaNVQL = COALESCE(@MaNVQL, MaNVQL),
        SoTK = COALESCE(@SoTK, SoTK),
        SoDu = COALESCE(@SoDu, SoDu),
        NgayMoTK = COALESCE(@NgayMoTK, NgayMoTK),
        TrangThai = COALESCE(@TrangThai, TrangThai)
    WHERE MaTK = @MaTK;
    
    PRINT N'Cập nhật tài khoản thành công';
END;
GO

-- Thủ tục: Xóa tài khoản ngân hàng
CREATE OR ALTER PROCEDURE sp_Xoa_TaiKhoan
    @MaTK CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM TAIKHOAN WHERE MaTK = @MaTK)
    BEGIN
        PRINT N'Tài khoản không tồn tại';
        RETURN;
    END;
    
    -- Kiểm tra có sổ tiết kiệm liên quan không
    IF EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaTK = @MaTK)
    BEGIN
        PRINT N'Không thể xóa vì tài khoản có sổ tiết kiệm liên quan';
        RETURN;
    END;
    
    DELETE FROM TAIKHOAN WHERE MaTK = @MaTK;
    PRINT N'Xóa tài khoản thành công';
END;
GO

-- =============================================
-- PHẦN 2: THỦ TỤC QUẢN LÝ SỔ TIẾT KIỆM
-- =============================================
-- Thủ tục: Mở sổ tiết kiệm mới
CREATE OR ALTER PROCEDURE sp_MoSoTietKiemMoi
    @MaSTK CHAR(10),
    @MaSoDu CHAR(10),
    @MaKH CHAR(10),
    @MaLoaiHinh CHAR(10),
    @MaHTGui CHAR(10),
    @MaHTTraLai CHAR(10),
    @TienGoc DECIMAL(18,2),
    @MaNV CHAR(10)
AS
BEGIN
    DECLARE @KyHan INT, @NgayMo DATE = GETDATE(), @NgayDaoHan DATE, @MaTK CHAR(10);

    -- Kiểm tra khách hàng tồn tại
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
    BEGIN
        PRINT N'Khách hàng không tồn tại';
        RETURN;
    END;

    -- Kiểm tra số tiền gửi tối thiểu
    IF @TienGoc < 100000
    BEGIN
        PRINT N'Số tiền gửi tối thiểu phải từ 100.000đ trở lên';
        RETURN;
    END;

    -- Lấy kỳ hạn từ loại hình TK
    SELECT @KyHan = KyHanThang FROM LOAIHINHTK WHERE MaLoaiHinh = @MaLoaiHinh;

    IF @KyHan IS NULL
    BEGIN
        PRINT N'Loại hình tiết kiệm không hợp lệ';
        RETURN;
    END;

    SET @NgayDaoHan = DATEADD(MONTH, @KyHan, @NgayMo);

    -- Lấy tài khoản ngân hàng của khách
    SELECT TOP 1 @MaTK = MaTK FROM TAIKHOAN WHERE MaKH = @MaKH;
    
    IF @MaTK IS NULL
    BEGIN
        PRINT N'Khách hàng chưa có tài khoản ngân hàng';
        RETURN;
    END;

    -- Kiểm tra mã stk
    IF EXISTS (SELECT * FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Mã sổ tiết kiệm đã tồn tại. Vui lòng nhập lại mã khác';
        RETURN;
    END;
    -- Thêm sổ tiết kiệm
    INSERT INTO SOTIETKIEM(MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                    TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
    VALUES (@MaSTK, @MaTK, @MaNV, @MaLoaiHinh, @MaHTTraLai, @MaHTGui,
            @TienGoc, @TienGoc, @NgayMo, @NgayDaoHan, N'Đang hoạt động');

    -- Tạo dòng trong bảng số dư
    INSERT INTO BANGSODU(MaSoDu, MaSTK, NgayCapNhat, SoDuGoc, LaiTichLuy)
    VALUES (@MaSoDu, @MaSTK, @NgayMo, @TienGoc, 0);

    PRINT N'Mở sổ tiết kiệm mới thành công. Mã sổ: ' + @MaSTK;
END;
GO



-- Thủ tục: Sửa sổ tiết kiệm
CREATE OR ALTER PROCEDURE sp_Sua_SoTietKiem
    @MaSTK CHAR(10),
    @MaTK CHAR(10) = NULL,
    @MaNVTao CHAR(10) = NULL,
    @MaLoaiHinh CHAR(10) = NULL,
    @MaHTTraLai CHAR(10) = NULL,
    @MaHTGui CHAR(10) = NULL,
    @TienGoc DECIMAL(18,2) = NULL,
    @TienHT DECIMAL(18,2) = NULL,
    @NgayMoSo DATE = NULL,
    @TrangThai NVARCHAR(50) = NULL
AS
BEGIN
    DECLARE @KyHanThang INT;
    DECLARE @NgayDaoHan DATE;

    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Sổ tiết kiệm không tồn tại';
        RETURN;
    END;

    -- Nếu thay đổi loại hình, tính lại ngày đáo hạn
    IF @MaLoaiHinh IS NOT NULL
    BEGIN
        SELECT @KyHanThang = KyHanThang
        FROM LOAIHINHTK
        WHERE MaLoaiHinh = @MaLoaiHinh;

        IF @NgayMoSo IS NULL
            SELECT @NgayMoSo = NgayMoSo FROM SOTIETKIEM WHERE MaSTK = @MaSTK;

        SET @NgayDaoHan = DATEADD(MONTH, ISNULL(@KyHanThang, 0), @NgayMoSo);
    END;

    -- Cập nhật thông tin sổ tiết kiệm
    UPDATE SOTIETKIEM
    SET 
        MaTK = COALESCE(@MaTK, MaTK),
        MaNVTao = COALESCE(@MaNVTao, MaNVTao),
        MaLoaiHinh = COALESCE(@MaLoaiHinh, MaLoaiHinh),
        MaHTTraLai = COALESCE(@MaHTTraLai, MaHTTraLai),
        MaHTGui = COALESCE(@MaHTGui, MaHTGui),
        TienGoc = COALESCE(@TienGoc, TienGoc),
        TienHT = COALESCE(@TienHT, TienHT),
        NgayMoSo = COALESCE(@NgayMoSo, NgayMoSo),
        NgayDaoHan = COALESCE(@NgayDaoHan, NgayDaoHan),
        TrangThai = COALESCE(@TrangThai, TrangThai)
    WHERE MaSTK = @MaSTK;

    -- Cập nhật số dư gốc trong bảng số dư
    IF @TienGoc IS NOT NULL
    BEGIN
        UPDATE BANGSODU
        SET SoDuGoc = @TienGoc
        WHERE MaSTK = @MaSTK;
    END;
    
    PRINT N'Cập nhật sổ tiết kiệm thành công';
END;
GO

-- Thủ tục: Gửi thêm tiền vào sổ tiết kiệm
CREATE OR ALTER PROCEDURE sp_GuiTienVaoSo
    @MaGD CHAR(10),      
    @MaSTK CHAR(10),
    @SoTien DECIMAL(18,2),
    @MaNV CHAR(10),
    @MaLoaiGD CHAR(10)
AS
BEGIN
    -- Kiểm tra sổ tiết kiệm hoạt động
    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK AND TrangThai = N'Đang hoạt động')
    BEGIN
        PRINT N'Sổ tiết kiệm không hoạt động';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM GIAODICHNOP WHERE MaGDnop = @MaGD)
    BEGIN 
        PRINT N'Mã giao dịch đã tồn tại. Vui lòng nhập mã giao dịch khác'
        RETURN;
    END;
    
    -- Kiểm tra số tiền hợp lệ
    IF @SoTien <= 0
    BEGIN
        PRINT N'Số tiền gửi phải lớn hơn 0';
        RETURN;
    END;

    -- Cập nhật số dư gốc
    UPDATE BANGSODU
    SET SoDuGoc = SoDuGoc + @SoTien,
        NgayCapNhat = GETDATE()
    WHERE MaSTK = @MaSTK;

    -- Cập nhật tiền hiện tại trong sổ tiết kiệm
    UPDATE SOTIETKIEM
    SET TienHT = TienHT + @SoTien,
        TienGoc = TienGoc + @SoTien
    WHERE MaSTK = @MaSTK;

    -- Ghi vào bảng giao dịch nộp
    INSERT INTO GIAODICHNOP(MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, SoTienNop, NgayGD, HTThanhToan)
    VALUES (@MaGD, @MaSTK, @MaNV, @MaLoaiGD, @SoTien, GETDATE(), N'Tiền mặt');

    PRINT N'Nộp tiền thành công. Số tiền nộp: ' + CAST(@SoTien AS NVARCHAR(20));
END;
GO

-- Thủ tục: Rút tiền từ sổ tiết kiệm
CREATE OR ALTER PROCEDURE sp_RutTienTuSo
    @MaGD CHAR(10),
    @MaSTK CHAR(10),
    @SoTienRut DECIMAL(18,2),
    @MaNV CHAR(10),
    @MaLoaiGD CHAR(10)
AS
BEGIN
    DECLARE @SoDu DECIMAL(18,2), 
            @NgayDaoHan DATE, 
            @LaiSuat DECIMAL(5,2),
            @NgayHienTai DATE = GETDATE(),
            @LaiNhan DECIMAL(18,2);

    -- Lấy thông tin số dư và ngày đáo hạn
    SELECT 
        @SoDu = B.SoDuThucTe, 
        @NgayDaoHan = S.NgayDaoHan
    FROM SOTIETKIEM S, BANGSODU B
    WHERE S.MaSTK = B.MaSTK AND S.MaSTK = @MaSTK;

    IF EXISTS(SELECT * FROM GIAODICHRUT WHERE MaGDrut = @MaGD)
    BEGIN
        PRINT N'Mã giao dịch đã tồn tại. Vui lòng nhập mã giao dịch khác';
        RETURN;
    END;

    -- Kiểm tra đủ tiền rút hay không
    IF @SoTienRut > @SoDu
    BEGIN
        PRINT N'Số dư không đủ để rút';
        RETURN;
    END;

    -- Xác định lãi suất (nếu rút trước hạn)
    IF @NgayHienTai < @NgayDaoHan
        SET @LaiSuat = 0.3;  -- 0.3% nếu rút trước hạn
    ELSE
        SELECT @LaiSuat = LaiSuatNam / 12 
        FROM LOAIHINHTK
        WHERE MaLoaiHinh = (SELECT MaLoaiHinh FROM SOTIETKIEM WHERE MaSTK = @MaSTK);

    -- Tính lãi nhận được
    SET @LaiNhan = @SoTienRut * @LaiSuat / 100;

    -- Cập nhật số dư sau khi rút
    UPDATE BANGSODU
    SET SoDuGoc = SoDuGoc - @SoTienRut,
        NgayCapNhat = GETDATE()
    WHERE MaSTK = @MaSTK;

    -- Cập nhật tiền hiện tại trong sổ tiết kiệm
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - @SoTienRut
    WHERE MaSTK = @MaSTK;

    -- Ghi vào bảng giao dịch rút
    INSERT INTO GIAODICHRUT(MaGDrut, MaSTK, MaNVThucHien, MaLoaiGD, 
                            SoTienRut, NgayGD, LaiSuatApDung, LaiNhanDuoc)
    VALUES (@MaGD, @MaSTK, @MaNV, @MaLoaiGD, 
            @SoTienRut, GETDATE(), @LaiSuat, @LaiNhan);

    -- Nếu rút hết tiền, đóng sổ
    IF @SoTienRut = @SoDu
        UPDATE SOTIETKIEM SET TrangThai = N'Đã tất toán' WHERE MaSTK = @MaSTK;

    PRINT N'Rút tiền thành công. Số tiền rút: ' + CAST(@SoTienRut AS NVARCHAR(20)) 
        + N', Lãi nhận được: ' + CAST(@LaiNhan AS NVARCHAR(20));
END;
GO

-- Thủ tục: Xóa sổ tiết kiệm
CREATE OR ALTER PROCEDURE sp_Xoa_SoTietKiem
    @MaSTK CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Sổ tiết kiệm không tồn tại';
        RETURN;
    END;
    
    -- Xóa các bản ghi liên quan
    DELETE FROM BANGTINHLAI WHERE MaSTK = @MaSTK;
    DELETE FROM BANGSODU WHERE MaSTK = @MaSTK;
    DELETE FROM GIAODICHNOP WHERE MaSTK = @MaSTK;
    DELETE FROM GIAODICHRUT WHERE MaSTK = @MaSTK;
    DELETE FROM BAOCAO WHERE MaSTK = @MaSTK;
    DELETE FROM SOTIETKIEM WHERE MaSTK = @MaSTK;
    
    PRINT N'Xóa sổ tiết kiệm thành công';
END;
GO


-- =============================================
-- PHẦN 3: THỦ TỤC QUẢN LÝ BẢNG TÍNH LÃI
-- =============================================

-- Thủ tục: Thêm bảng tính lãi
CREATE OR ALTER PROCEDURE sp_Them_BangTinhLai
    @MaTinhLai CHAR(10),
    @MaSTK CHAR(10),
    @MaNVTinh CHAR(10),
    @NgayTinhLai DATE,
    @LaiSuatApDung DECIMAL(5,2),
    @SoDuTinhLai DECIMAL(18,2),
    @LaiThangNay DECIMAL(18,2),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM BANGTINHLAI WHERE MaTinhLai = @MaTinhLai)
    BEGIN
        PRINT N'Mã tính lãi đã tồn tại';
        RETURN;
    END;

    INSERT INTO BANGTINHLAI (MaTinhLai, MaSTK, MaNVTinh, NgayTinhLai, 
                             LaiSuatApDung, SoDuTinhLai, LaiThangNay, LaiTichLuy)
    VALUES (@MaTinhLai, @MaSTK, @MaNVTinh, @NgayTinhLai, 
            @LaiSuatApDung, @SoDuTinhLai, @LaiThangNay, @LaiTichLuy);

    -- Cập nhật lãi tích lũy vào bảng số dư
    UPDATE BANGSODU
    SET LaiTichLuy = ISNULL(LaiTichLuy, 0) + @LaiThangNay
    WHERE MaSTK = @MaSTK;
    
    PRINT N'Thêm bảng tính lãi thành công';
END;
GO

-- Thủ tục: Sửa bảng tính lãi
CREATE OR ALTER PROCEDURE sp_Sua_BangTinhLai
    @MaTinhLai CHAR(10),
    @LaiSuatApDung DECIMAL(5,2) = NULL,
    @SoDuTinhLai DECIMAL(18,2) = NULL,
    @LaiThangNay DECIMAL(18,2) = NULL,
    @LaiTichLuy DECIMAL(18,2) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGTINHLAI WHERE MaTinhLai = @MaTinhLai)
    BEGIN
        PRINT N'Bảng tính lãi không tồn tại';
        RETURN;
    END;

    UPDATE BANGTINHLAI
    SET 
        LaiSuatApDung = COALESCE(@LaiSuatApDung, LaiSuatApDung),
        SoDuTinhLai = COALESCE(@SoDuTinhLai, SoDuTinhLai),
        LaiThangNay = COALESCE(@LaiThangNay, LaiThangNay),
        LaiTichLuy = COALESCE(@LaiTichLuy, LaiTichLuy)
    WHERE MaTinhLai = @MaTinhLai;
    
    PRINT N'Cập nhật bảng tính lãi thành công';
END;
GO

-- Thủ tục: Xóa bảng tính lãi
CREATE OR ALTER PROCEDURE sp_Xoa_BangTinhLai
    @MaTinhLai CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGTINHLAI WHERE MaTinhLai = @MaTinhLai)
    BEGIN
        PRINT N'Bảng tính lãi không tồn tại';
        RETURN;
    END;
    
    DELETE FROM BANGTINHLAI WHERE MaTinhLai = @MaTinhLai;
    PRINT N'Xóa bảng tính lãi thành công';
END;
GO

-- =============================================
-- PHẦN 4: THỦ TỤC QUẢN LÝ BẢNG SỐ DƯ
-- =============================================

-- Thủ tục: Thêm bảng số dư
CREATE OR ALTER PROCEDURE sp_Them_BangSoDu
    @MaSoDu CHAR(10),
    @MaSTK CHAR(10),
    @SoDuGoc DECIMAL(18,2),
    @LaiTichLuy DECIMAL(18,2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM BANGSODU WHERE MaSoDu = @MaSoDu)
    BEGIN
        PRINT N'Mã số dư đã tồn tại';
        RETURN;
    END;

    INSERT INTO BANGSODU (MaSoDu, MaSTK, NgayCapNhat, SoDuGoc, LaiTichLuy)
    VALUES (@MaSoDu, @MaSTK, GETDATE(), @SoDuGoc, @LaiTichLuy);
    
    PRINT N'Thêm bảng số dư thành công';
END;
GO

-- Thủ tục: Sửa bảng số dư
CREATE OR ALTER PROCEDURE sp_Sua_BangSoDu
    @MaSoDu CHAR(10),
    @SoDuGoc DECIMAL(18,2) = NULL,
    @LaiTichLuy DECIMAL(18,2) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGSODU WHERE MaSoDu = @MaSoDu)
    BEGIN
        PRINT N'Bảng số dư không tồn tại';
        RETURN;
    END;

    UPDATE BANGSODU
    SET 
        SoDuGoc = COALESCE(@SoDuGoc, SoDuGoc),
        LaiTichLuy = COALESCE(@LaiTichLuy, LaiTichLuy),
        NgayCapNhat = GETDATE()
    WHERE MaSoDu = @MaSoDu;
    
    PRINT N'Cập nhật bảng số dư thành công';
END;
GO

-- Thủ tục: Xóa bảng số dư
CREATE OR ALTER PROCEDURE sp_Xoa_BangSoDu
    @MaSoDu CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGSODU WHERE MaSoDu = @MaSoDu)
    BEGIN
        PRINT N'Bảng số dư không tồn tại';
        RETURN;
    END;
    
    DELETE FROM BANGSODU WHERE MaSoDu = @MaSoDu;
    PRINT N'Xóa bảng số dư thành công';
END;
GO

-- =============================================
-- PHẦN 5: THỦ TỤC QUẢN LÝ BÁO CÁO
-- =============================================

-- Thủ tục: Thêm báo cáo
CREATE OR ALTER PROCEDURE sp_Them_BaoCao
    @MaBaoCao CHAR(10),
    @MaSTK CHAR(10),
    @MaNVTao CHAR(10),
    @LoaiBaoCao NVARCHAR(50),
    @TongTienGui DECIMAL(18,2),
    @TongLaiNhan DECIMAL(18,2),
    @SoDuHienTai DECIMAL(18,2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM BAOCAO WHERE MaBaoCao = @MaBaoCao)
    BEGIN
        PRINT N'Mã báo cáo đã tồn tại';
        RETURN;
    END;

    INSERT INTO BAOCAO (MaBaoCao, MaSTK, MaNVTao, NgayBaoCao, LoaiBaoCao, 
                        TongTienGui, TongLaiNhan, SoDuHienTai)
    VALUES (@MaBaoCao, @MaSTK, @MaNVTao, GETDATE(), @LoaiBaoCao, 
            @TongTienGui, @TongLaiNhan, @SoDuHienTai);
    
    PRINT N'Thêm báo cáo thành công';
END;
GO

-- Thủ tục: Xóa báo cáo
CREATE OR ALTER PROCEDURE sp_Xoa_BaoCao
    @MaBaoCao CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BAOCAO WHERE MaBaoCao = @MaBaoCao)
    BEGIN
        PRINT N'Báo cáo không tồn tại';
        RETURN;
    END;
    
    DELETE FROM BAOCAO WHERE MaBaoCao = @MaBaoCao;
    PRINT N'Xóa báo cáo thành công';
END;
GO

-- =============================================
-- PHẦN 6: THỦ TỤC TÍNH LÃI HÀNG THÁNG
-- =============================================

CREATE OR ALTER PROCEDURE sp_TinhLaiHangThang
    @MaTinhLai CHAR(10),
    @MaSTK CHAR(10),
    @MaNV CHAR(10)
AS
BEGIN
    DECLARE @LaiSuatThang DECIMAL(5,2),
            @SoDu DECIMAL(18,2),
            @LaiThang DECIMAL(18,2),
            @LaiTichLuy DECIMAL(18,2),
            @NgayTinhLai DATE = GETDATE();

    -- Lấy lãi suất tháng từ loại hình tiết kiệm
    SELECT @LaiSuatThang = LOAIHINHTK.LaiSuatThang
    FROM LOAIHINHTK, SOTIETKIEM
    WHERE SOTIETKIEM.MaSTK = @MaSTK AND SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh;

    IF @LaiSuatThang IS NULL
    BEGIN
        PRINT N'Không tìm thấy thông tin lãi suất cho sổ tiết kiệm này';
        RETURN;
    END;

    -- Lấy số dư thực tế từ bảng số dư
    SELECT TOP 1 @SoDu = BANGSODU.SoDuThucTe
    FROM BANGSODU
    WHERE BANGSODU.MaSTK = @MaSTK
    ORDER BY BANGSODU.NgayCapNhat DESC;

    IF @SoDu IS NULL
    BEGIN
        PRINT N'Không tìm thấy số dư cho sổ tiết kiệm này';
        RETURN;
    END;

    -- Tính lãi tháng
    SET @LaiThang = @SoDu * @LaiSuatThang / 100;
    
    -- Lấy lãi tích lũy hiện tại
    SELECT TOP 1 @LaiTichLuy = BANGSODU.LaiTichLuy
    FROM BANGSODU
    WHERE BANGSODU.MaSTK = @MaSTK
    ORDER BY BANGSODU.NgayCapNhat DESC;

    IF @LaiTichLuy IS NULL
        SET @LaiTichLuy = 0;

    SET @LaiTichLuy = @LaiTichLuy + @LaiThang;

    -- Thêm bản ghi vào bảng tính lãi
    INSERT INTO BANGTINHLAI (MaTinhLai, MaSTK, MaNVTinh, NgayTinhLai, 
                             LaiSuatApDung, SoDuTinhLai, LaiThangNay, LaiTichLuy)
    VALUES (@MaTinhLai, @MaSTK, @MaNV, @NgayTinhLai, 
            @LaiSuatThang, @SoDu, @LaiThang, @LaiTichLuy);

    -- Cập nhật lãi tích lũy vào bảng số dư
    UPDATE BANGSODU
    SET BANGSODU.LaiTichLuy = @LaiTichLuy,
        BANGSODU.NgayCapNhat = @NgayTinhLai
    WHERE BANGSODU.MaSTK = @MaSTK;

    PRINT N'Tính lãi thành công cho sổ ' + @MaSTK;
    PRINT N'Lãi tháng này: ' + CAST(@LaiThang AS NVARCHAR(50));
    PRINT N'Lãi tích lũy: ' + CAST(@LaiTichLuy AS NVARCHAR(50));
END;
GO

-- =============================================
-- PHẦN 7: THỦ TỤC QUẢN LÝ DANH MỤC
-- =============================================

-- Thủ tục: Thêm hình thức trả lãi
CREATE OR ALTER PROCEDURE sp_Them_HinhThucTraLai
    @MaHTTraLai CHAR(10),
    @TenHTTraLai NVARCHAR(100),
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM HINHTHUCTRALAI WHERE HINHTHUCTRALAI.MaHTTraLai = @MaHTTraLai)
    BEGIN
        PRINT N'Mã hình thức trả lãi đã tồn tại';
        RETURN;
    END;

    INSERT INTO HINHTHUCTRALAI (MaHTTraLai, TenHTTraLai, MoTa)
    VALUES (@MaHTTraLai, @TenHTTraLai, @MoTa);
    
    PRINT N'Thêm hình thức trả lãi thành công';
END;
GO

-- Thủ tục: Thêm hình thức gửi
CREATE OR ALTER PROCEDURE sp_Them_HinhThucGui
    @MaHTGui CHAR(10),
    @TenHTGui NVARCHAR(100),
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM HINHTHUCGUI WHERE HINHTHUCGUI.MaHTGui = @MaHTGui)
    BEGIN
        PRINT N'Mã hình thức gửi đã tồn tại';
        RETURN;
    END;

    INSERT INTO HINHTHUCGUI (MaHTGui, TenHTGui, MoTa)
    VALUES (@MaHTGui, @TenHTGui, @MoTa);
    
    PRINT N'Thêm hình thức gửi thành công';
END;
GO

-- Thủ tục: Thêm loại giao dịch
CREATE OR ALTER PROCEDURE sp_Them_LoaiGiaoDich
    @MaLoaiGD CHAR(10),
    @TenLoaiGD NVARCHAR(100),
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM LOAIGIAODICH WHERE LOAIGIAODICH.MaLoaiGD = @MaLoaiGD)
    BEGIN
        PRINT N'Mã loại giao dịch đã tồn tại';
        RETURN;
    END;

    INSERT INTO LOAIGIAODICH (MaLoaiGD, TenLoaiGD, MoTa)
    VALUES (@MaLoaiGD, @TenLoaiGD, @MoTa);
    
    PRINT N'Thêm loại giao dịch thành công';
END;
GO

-- Thủ tục: Thêm loại hình tiết kiệm
CREATE OR ALTER PROCEDURE sp_Them_LoaiHinhTK
    @MaLoaiHinh CHAR(10),
    @TenLoaiHinh NVARCHAR(100),
    @KyHanThang INT = NULL,
    @LaiSuatNam DECIMAL(5,2) = NULL,
    @LaiSuatThang DECIMAL(5,2) = NULL,
    @MoTa NVARCHAR(200) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM LOAIHINHTK WHERE LOAIHINHTK.MaLoaiHinh = @MaLoaiHinh)
    BEGIN
        PRINT N'Mã loại hình tiết kiệm đã tồn tại';
        RETURN;
    END;

    INSERT INTO LOAIHINHTK (MaLoaiHinh, TenLoaiHinh, KyHanThang, LaiSuatNam, LaiSuatThang, MoTa)
    VALUES (@MaLoaiHinh, @TenLoaiHinh, @KyHanThang, @LaiSuatNam, @LaiSuatThang, @MoTa);
    
    PRINT N'Thêm loại hình tiết kiệm thành công';
END;
GO

-- =============================================
-- PHẦN 8: THỦ TỤC TRA CỨU VÀ BÁO CÁO
-- =============================================

-- Thủ tục: Tra cứu sổ tiết kiệm
CREATE OR ALTER PROCEDURE sp_TraCuuSoTietKiem
    @MaSTK CHAR(10) = NULL,
    @MaKH CHAR(10) = NULL,
    @SoTK CHAR(12) = NULL
AS
BEGIN
    IF @MaSTK IS NULL AND @MaKH IS NULL AND @SoTK IS NULL
    BEGIN
        PRINT N'Vui lòng cung cấp ít nhất một thông tin để tra cứu';
        RETURN;
    END;

    SELECT 
        SOTIETKIEM.MaSTK,
        KHACHHANG.MaKH,
        KHACHHANG.TenKH,
        KHACHHANG.CMND,
        KHACHHANG.SDT,
        TAIKHOAN.SoTK,
        SOTIETKIEM.TienGoc,
        SOTIETKIEM.TienHT,
        SOTIETKIEM.NgayMoSo,
        SOTIETKIEM.NgayDaoHan,
        SOTIETKIEM.TrangThai,
        LOAIHINHTK.TenLoaiHinh,
        BANGSODU.SoDuThucTe
    FROM SOTIETKIEM, TAIKHOAN, KHACHHANG, LOAIHINHTK, BANGSODU
    WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK
        AND TAIKHOAN.MaKH = KHACHHANG.MaKH
        AND SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh
        AND SOTIETKIEM.MaSTK = BANGSODU.MaSTK
        AND (@MaSTK IS NULL OR SOTIETKIEM.MaSTK = @MaSTK)
        AND (@MaKH IS NULL OR KHACHHANG.MaKH = @MaKH)
        AND (@SoTK IS NULL OR TAIKHOAN.SoTK = @SoTK);
END;
GO

-- Thủ tục: Thống kê theo nhân viên
CREATE OR ALTER PROCEDURE sp_ThongKeTheoNhanVien
    @MaNV CHAR(10),
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNV)
    BEGIN
        PRINT N'Nhân viên không tồn tại';
        RETURN;
    END;

    SELECT 
        NHANVIEN.MaNV,
        NHANVIEN.TenNV,
        COUNT(SOTIETKIEM.MaSTK) AS SoSoMo,
        SUM(SOTIETKIEM.TienGoc) AS TongTienGui,
        COUNT(GIAODICHNOP.MaGDnop) AS SoGiaoDichNop,
        COUNT(GIAODICHRUT.MaGDrut) AS SoGiaoDichRut
    FROM NHANVIEN, SOTIETKIEM, GIAODICHNOP, GIAODICHRUT
    WHERE NHANVIEN.MaNV = @MaNV
        AND SOTIETKIEM.MaNVTao = NHANVIEN.MaNV
        AND GIAODICHNOP.MaNVThucHien = NHANVIEN.MaNV
        AND GIAODICHRUT.MaNVThucHien = NHANVIEN.MaNV
        AND (SOTIETKIEM.NgayMoSo BETWEEN @TuNgay AND @DenNgay 
            OR GIAODICHNOP.NgayGD BETWEEN @TuNgay AND @DenNgay 
            OR GIAODICHRUT.NgayGD BETWEEN @TuNgay AND @DenNgay)
    GROUP BY NHANVIEN.MaNV, NHANVIEN.TenNV;
END;
GO

-- Thủ tục: Kiểm tra số dư
CREATE OR ALTER PROCEDURE sp_KiemTraSoDu
    @MaSTK CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BANGSODU WHERE BANGSODU.MaSTK = @MaSTK)
    BEGIN
        PRINT N'Không có dữ liệu số dư cho sổ này';
        RETURN;
    END;

    SELECT 
        BANGSODU.MaSoDu,
        BANGSODU.MaSTK,
        BANGSODU.NgayCapNhat,
        BANGSODU.SoDuGoc,
        BANGSODU.LaiTichLuy,
        BANGSODU.SoDuThucTe,
        KHACHHANG.TenKH,
        TAIKHOAN.SoTK
    FROM BANGSODU, SOTIETKIEM, TAIKHOAN, KHACHHANG
    WHERE BANGSODU.MaSTK = SOTIETKIEM.MaSTK
        AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
        AND TAIKHOAN.MaKH = KHACHHANG.MaKH
        AND BANGSODU.MaSTK = @MaSTK
    ORDER BY BANGSODU.NgayCapNhat DESC;
END;
GO

-- Thủ tục: Tra cứu khách hàng theo CMND
CREATE OR ALTER PROCEDURE sp_TraCuuKhachHangTheoCMND
    @CMND CHAR(12)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.CMND = @CMND)
    BEGIN
        PRINT N'CMND không tồn tại trong hệ thống';
        RETURN;
    END;

    SELECT 
        KHACHHANG.MaKH,
        KHACHHANG.TenKH,
        KHACHHANG.SDT,
        KHACHHANG.Email,
        KHACHHANG.DiaChi,
        KHACHHANG.NgayTaoTK,
        TAIKHOAN.MaTK,
        TAIKHOAN.SoTK,
        TAIKHOAN.SoDu,
        TAIKHOAN.TrangThai
    FROM KHACHHANG, TAIKHOAN
    WHERE KHACHHANG.CMND = @CMND
        AND KHACHHANG.MaKH = TAIKHOAN.MaKH;
END;
GO

-- =============================================
-- PHẦN 9: THỦ TỤC QUẢN LÝ NHÂN VIÊN
-- =============================================

-- Thủ tục: Thêm nhân viên
CREATE OR ALTER PROCEDURE sp_Them_NhanVien
    @MaNV CHAR(10),
    @TenNV NVARCHAR(100),
    @ChucVu NVARCHAR(50) = NULL,
    @PhongBan NVARCHAR(50) = NULL,
    @Email VARCHAR(100) = NULL,
    @SDT CHAR(10) = NULL,
    @NgayVL DATE = NULL,
    @LuongCB DECIMAL(18,2) = NULL,
    @TrangThai NVARCHAR(50) = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNV)
    BEGIN
        PRINT N'Mã nhân viên đã tồn tại';
        RETURN;
    END;

    IF @NgayVL IS NULL
        SET @NgayVL = GETDATE();

    IF @TrangThai IS NULL
        SET @TrangThai = N'Đang làm việc';

    INSERT INTO NHANVIEN (MaNV, TenNV, ChucVu, PhongBan, Email, SDT, NgayVL, LuongCB, TrangThai)
    VALUES (@MaNV, @TenNV, @ChucVu, @PhongBan, @Email, @SDT, @NgayVL, @LuongCB, @TrangThai);
    
    PRINT N'Thêm nhân viên thành công';
END;
GO

-- Thủ tục: Sửa thông tin nhân viên
CREATE OR ALTER PROCEDURE sp_Sua_NhanVien
    @MaNV CHAR(10),
    @TenNV NVARCHAR(100) = NULL,
    @ChucVu NVARCHAR(50) = NULL,
    @PhongBan NVARCHAR(50) = NULL,
    @Email VARCHAR(100) = NULL,
    @SDT CHAR(10) = NULL,
    @NgayVL DATE = NULL,
    @LuongCB DECIMAL(18,2) = NULL,
    @TrangThai NVARCHAR(50) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNV)
    BEGIN
        PRINT N'Nhân viên không tồn tại';
        RETURN;
    END;

    UPDATE NHANVIEN
    SET TenNV = CASE WHEN @TenNV IS NOT NULL THEN @TenNV ELSE TenNV END,
        ChucVu = CASE WHEN @ChucVu IS NOT NULL THEN @ChucVu ELSE ChucVu END,
        PhongBan = CASE WHEN @PhongBan IS NOT NULL THEN @PhongBan ELSE PhongBan END,
        Email = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END,
        SDT = CASE WHEN @SDT IS NOT NULL THEN @SDT ELSE SDT END,
        NgayVL = CASE WHEN @NgayVL IS NOT NULL THEN @NgayVL ELSE NgayVL END,
        LuongCB = CASE WHEN @LuongCB IS NOT NULL THEN @LuongCB ELSE LuongCB END,
        TrangThai = CASE WHEN @TrangThai IS NOT NULL THEN @TrangThai ELSE TrangThai END
    WHERE NHANVIEN.MaNV = @MaNV;
    
    PRINT N'Cập nhật nhân viên thành công';
END;
GO

-- Thủ tục: Xóa nhân viên
CREATE OR ALTER PROCEDURE sp_Xoa_NhanVien
    @MaNV CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNV)
    BEGIN
        PRINT N'Nhân viên không tồn tại';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.MaNVTiepTan = @MaNV)
        OR EXISTS (SELECT 1 FROM TAIKHOAN WHERE TAIKHOAN.MaNVQL = @MaNV)
        OR EXISTS (SELECT 1 FROM SOTIETKIEM WHERE SOTIETKIEM.MaNVTao = @MaNV)
        OR EXISTS (SELECT 1 FROM GIAODICHNOP WHERE GIAODICHNOP.MaNVThucHien = @MaNV)
        OR EXISTS (SELECT 1 FROM GIAODICHRUT WHERE GIAODICHRUT.MaNVThucHien = @MaNV)
        OR EXISTS (SELECT 1 FROM BANGTINHLAI WHERE BANGTINHLAI.MaNVTinh = @MaNV)
        OR EXISTS (SELECT 1 FROM BAOCAO WHERE BAOCAO.MaNVTao = @MaNV)
    BEGIN
        PRINT N'Không thể xóa nhân viên vì có dữ liệu liên quan';
        RETURN;
    END;

    DELETE FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNV;
    PRINT N'Xóa nhân viên thành công';
END;
GO

-- =============================================
-- PHẦN 10: THỦ TỤC QUẢN LÝ KHÁCH HÀNG
-- =============================================

-- Thủ tục: Thêm khách hàng
CREATE OR ALTER PROCEDURE sp_Them_KhachHang
    @MaKH CHAR(10),
    @MaNVTiepTan CHAR(10) = NULL,
    @TenKH NVARCHAR(100),
    @DiaChi NVARCHAR(200) = NULL,
    @SDT CHAR(10) = NULL,
    @Email VARCHAR(100) = NULL,
    @CMND CHAR(12),
    @NgayTaoTK DATE = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.MaKH = @MaKH)
    BEGIN
        PRINT N'Mã khách hàng đã tồn tại';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.CMND = @CMND)
    BEGIN
        PRINT N'CMND đã tồn tại trong hệ thống';
        RETURN;
    END;

    IF @MaNVTiepTan IS NOT NULL AND NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNVTiepTan)
    BEGIN
        PRINT N'Nhân viên tiếp tân không tồn tại';
        RETURN;
    END;

    IF @NgayTaoTK IS NULL
        SET @NgayTaoTK = GETDATE();

    INSERT INTO KHACHHANG (MaKH, MaNVTiepTan, TenKH, DiaChi, SDT, Email, CMND, NgayTaoTK)
    VALUES (@MaKH, @MaNVTiepTan, @TenKH, @DiaChi, @SDT, @Email, @CMND, @NgayTaoTK);
    
    PRINT N'Thêm khách hàng thành công';
END;
GO

-- Thủ tục: Sửa thông tin khách hàng
CREATE OR ALTER PROCEDURE sp_Sua_KhachHang
    @MaKH CHAR(10),
    @MaNVTiepTan CHAR(10) = NULL,
    @TenKH NVARCHAR(100) = NULL,
    @DiaChi NVARCHAR(200) = NULL,
    @SDT CHAR(10) = NULL,
    @Email VARCHAR(100) = NULL,
    @CMND CHAR(12) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.MaKH = @MaKH)
    BEGIN
        PRINT N'Khách hàng không tồn tại';
        RETURN;
    END;

    IF @CMND IS NOT NULL AND EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.CMND = @CMND AND KHACHHANG.MaKH <> @MaKH)
    BEGIN
        PRINT N'CMND đã tồn tại cho khách hàng khác';
        RETURN;
    END;

    IF @MaNVTiepTan IS NOT NULL AND NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE NHANVIEN.MaNV = @MaNVTiepTan)
    BEGIN
        PRINT N'Nhân viên tiếp tân không tồn tại';
        RETURN;
    END;

    UPDATE KHACHHANG
    SET MaNVTiepTan = CASE WHEN @MaNVTiepTan IS NOT NULL THEN @MaNVTiepTan ELSE MaNVTiepTan END,
        TenKH = CASE WHEN @TenKH IS NOT NULL THEN @TenKH ELSE TenKH END,
        DiaChi = CASE WHEN @DiaChi IS NOT NULL THEN @DiaChi ELSE DiaChi END,
        SDT = CASE WHEN @SDT IS NOT NULL THEN @SDT ELSE SDT END,
        Email = CASE WHEN @Email IS NOT NULL THEN @Email ELSE Email END,
        CMND = CASE WHEN @CMND IS NOT NULL THEN @CMND ELSE CMND END
    WHERE KHACHHANG.MaKH = @MaKH;
    
    PRINT N'Cập nhật khách hàng thành công';
END;
GO

-- Thủ tục: Xóa khách hàng
CREATE OR ALTER PROCEDURE sp_Xoa_KhachHang
    @MaKH CHAR(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE KHACHHANG.MaKH = @MaKH)
    BEGIN
        PRINT N'Khách hàng không tồn tại';
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE TAIKHOAN.MaKH = @MaKH)
    BEGIN
        PRINT N'Không thể xóa khách hàng vì có tài khoản liên quan';
        RETURN;
    END;

    DELETE FROM KHACHHANG WHERE KHACHHANG.MaKH = @MaKH;
    PRINT N'Xóa khách hàng thành công';
END;
GO


GO

-- =============================================
-- THỦ TỤC THỐNG KÊ
-- =============================================

CREATE OR ALTER PROCEDURE sp_ThongKeTongQuanHeThong
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    IF @TuNgay IS NULL
        SET @TuNgay = DATEADD(MONTH, -6, GETDATE())
    IF @DenNgay IS NULL
        SET @DenNgay = GETDATE()

    SELECT 
        (SELECT COUNT(*) FROM KHACHHANG) AS TongSoKhachHang,
        (SELECT COUNT(*) FROM KHACHHANG WHERE KHACHHANG.MaKH IN (
            SELECT DISTINCT TAIKHOAN.MaKH FROM TAIKHOAN WHERE TAIKHOAN.TrangThai = N'Hoạt động'
        )) AS SoKhachHangCoTaiKhoan,
        
        (SELECT COUNT(*) FROM TAIKHOAN) AS TongSoTaiKhoan,
        (SELECT COUNT(*) FROM TAIKHOAN WHERE TAIKHOAN.TrangThai = N'Hoạt động') AS SoTaiKhoanHoatDong,
        
        (SELECT COUNT(*) FROM SOTIETKIEM) AS TongSoSoTietKiem, --đếm tất cả các dòng
        (SELECT COUNT(*) FROM SOTIETKIEM WHERE SOTIETKIEM.TrangThai = N'Đang hoạt động') AS SoSoDangHoatDong,
        (SELECT COUNT(*) FROM SOTIETKIEM WHERE SOTIETKIEM.TrangThai = N'Đã tất toán') AS SoSoDaTatToan,
        
        (SELECT SUM(TAIKHOAN.SoDu) FROM TAIKHOAN WHERE TAIKHOAN.TrangThai = N'Hoạt động') AS TongSoDuTaiKhoan,
        (SELECT SUM(SOTIETKIEM.TienGoc) FROM SOTIETKIEM WHERE SOTIETKIEM.TrangThai = N'Đang hoạt động') AS TongTienGuiTietKiem,
        (SELECT SUM(BANGSODU.SoDuThucTe) FROM BANGSODU WHERE BANGSODU.MaSTK IN (
            SELECT SOTIETKIEM.MaSTK FROM SOTIETKIEM WHERE SOTIETKIEM.TrangThai = N'Đang hoạt động'
        )) AS TongSoDuThucTe,
        
        (SELECT COUNT(*) FROM GIAODICHNOP WHERE GIAODICHNOP.NgayGD BETWEEN @TuNgay AND @DenNgay) AS SoGiaoDichNop,
        (SELECT COUNT(*) FROM GIAODICHRUT WHERE GIAODICHRUT.NgayGD BETWEEN @TuNgay AND @DenNgay) AS SoGiaoDichRut,
        (SELECT SUM(GIAODICHNOP.SoTienNop) FROM GIAODICHNOP WHERE GIAODICHNOP.NgayGD BETWEEN @TuNgay AND @DenNgay) AS TongTienNop,
        (SELECT SUM(GIAODICHRUT.SoTienRut) FROM GIAODICHRUT WHERE GIAODICHRUT.NgayGD BETWEEN @TuNgay AND @DenNgay) AS TongTienRut,
        
        (SELECT COUNT(*) FROM NHANVIEN) AS TongSoNhanVien,
        (SELECT COUNT(*) FROM NHANVIEN WHERE NHANVIEN.TrangThai = N'Đang làm việc') AS SoNhanVienDangLamViec
        
END;
GO

CREATE OR ALTER PROCEDURE sp_ThongKeTheoLoaiHinhTK
    @MaLoaiHinh CHAR(10) = NULL
AS
BEGIN
    SELECT 
        LOAIHINHTK.MaLoaiHinh,
        LOAIHINHTK.TenLoaiHinh,
        LOAIHINHTK.KyHanThang,
        LOAIHINHTK.LaiSuatNam,
        COUNT(SOTIETKIEM.MaSTK) AS TongSoSo,
        SUM(SOTIETKIEM.TienGoc) AS TongTienGoc,
        SUM(BANGSODU.SoDuThucTe) AS TongSoDuThucTe,
        AVG(BANGSODU.SoDuThucTe) AS SoDuTrungBinh,
        COUNT(CASE WHEN SOTIETKIEM.TrangThai = N'Đang hoạt động' THEN 1 END) AS SoSoDangHoatDong,
        COUNT(CASE WHEN SOTIETKIEM.TrangThai = N'Đã tất toán' THEN 1 END) AS SoSoDaTatToan,
        (SELECT COUNT(DISTINCT TAIKHOAN.MaKH) 
         FROM SOTIETKIEM, TAIKHOAN 
         WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK 
           AND SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh) AS SoKhachHangSuDung
    FROM LOAIHINHTK, SOTIETKIEM, BANGSODU
    WHERE LOAIHINHTK.MaLoaiHinh = SOTIETKIEM.MaLoaiHinh
      AND SOTIETKIEM.MaSTK = BANGSODU.MaSTK
      AND (@MaLoaiHinh IS NULL OR LOAIHINHTK.MaLoaiHinh = @MaLoaiHinh)
    GROUP BY LOAIHINHTK.MaLoaiHinh, LOAIHINHTK.TenLoaiHinh, LOAIHINHTK.KyHanThang, LOAIHINHTK.LaiSuatNam
    ORDER BY TongTienGoc DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_ThongKeDoanhSoTheoThoiGian
    @LoaiThongKe NVARCHAR(20) = N'THANG',
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    IF @TuNgay IS NULL
        SET @TuNgay = DATEADD(MONTH, -12, GETDATE())
    IF @DenNgay IS NULL
        SET @DenNgay = GETDATE()

    CREATE TABLE #ThoiGianThongKe (
        KhoangThoiGian NVARCHAR(20),
        NgayBatDau DATE,
        NgayKetThuc DATE
    )

    DECLARE @CurrentDate DATE
    
    IF @LoaiThongKe = N'NGAY'
    BEGIN
        SET @CurrentDate = @TuNgay
        WHILE @CurrentDate <= @DenNgay
        BEGIN
            INSERT INTO #ThoiGianThongKe VALUES (
                CONVERT(NVARCHAR(10), @CurrentDate, 103),
                @CurrentDate,
                @CurrentDate
            )
            SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
        END
    END
    ELSE IF @LoaiThongKe = N'THANG'
    BEGIN
        SET @CurrentDate = DATEFROMPARTS(YEAR(@TuNgay), MONTH(@TuNgay), 1)
        WHILE @CurrentDate <= @DenNgay
        BEGIN
            INSERT INTO #ThoiGianThongKe VALUES (
                FORMAT(@CurrentDate, 'MM/yyyy'),
                @CurrentDate,
                DATEADD(DAY, -1, DATEADD(MONTH, 1, @CurrentDate))
            )
            SET @CurrentDate = DATEADD(MONTH, 1, @CurrentDate)
        END
    END
    ELSE IF @LoaiThongKe = N'QUY'
    BEGIN
            --Tính quý bắt đầu: Q1: 1->3, Q2: 4->6,... 
            --ví dụ: date: 3-3-2025 -> current date (ngày đầu quý): 2025/1/1
            --(3-1)/3+1=1 -> tháng 1 là đầu quý 1
        SET @CurrentDate = DATEFROMPARTS(YEAR(@TuNgay), ((MONTH(@TuNgay)-1)/3)*3+1, 1)
        WHILE @CurrentDate <= @DenNgay
        BEGIN
            INSERT INTO #ThoiGianThongKe VALUES (
                N'Q' + CAST((MONTH(@CurrentDate)-1)/3 + 1 AS NVARCHAR(1)) + '/' + CAST(YEAR(@CurrentDate) AS NVARCHAR(4)),
                @CurrentDate,
                DATEADD(DAY, -1, DATEADD(MONTH, 3, @CurrentDate))
            )
            SET @CurrentDate = DATEADD(MONTH, 3, @CurrentDate)
            --cú pháp vd: Q1/2025 - 1/1/2025 - 31/3/2025
            --              Q2/2025 - 31/3/2025 - 30/6/2025
        END
    END
    ELSE IF @LoaiThongKe = N'NAM'
    BEGIN
        SET @CurrentDate = DATEFROMPARTS(YEAR(@TuNgay), 1, 1)
        WHILE @CurrentDate <= @DenNgay
        BEGIN
            INSERT INTO #ThoiGianThongKe VALUES (
                CAST(YEAR(@CurrentDate) AS NVARCHAR(4)),
                @CurrentDate,
                DATEFROMPARTS(YEAR(@CurrentDate), 12, 31)
            )
            SET @CurrentDate = DATEADD(YEAR, 1, @CurrentDate)
        END
    END

    SELECT 
        #ThoiGianThongKe.KhoangThoiGian,
        #ThoiGianThongKe.NgayBatDau,
        #ThoiGianThongKe.NgayKetThuc,
        --isnull() trả về 0
        --sum() tính tổng
        ISNULL(SUM(CASE WHEN GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc THEN GiaoDichTongHop.SoTienNop ELSE 0 END), 0) AS TongTienNop,
        ISNULL(SUM(CASE WHEN GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc THEN GiaoDichTongHop.SoTienRut ELSE 0 END), 0) AS TongTienRut,
        ISNULL(COUNT(CASE WHEN GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc THEN GiaoDichTongHop.MaGD END), 0) AS TongSoGiaoDich,
        ISNULL(COUNT(DISTINCT CASE WHEN GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc THEN GiaoDichTongHop.MaSTK END), 0) AS SoSoThamGia,
        ISNULL(SUM(CASE WHEN GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc THEN GiaoDichTongHop.SoTienNop - GiaoDichTongHop.SoTienRut END), 0) AS DoanhSoRong
    FROM #ThoiGianThongKe, (
        SELECT GIAODICHNOP.MaGDnop AS MaGD, GIAODICHNOP.MaSTK, GIAODICHNOP.NgayGD, GIAODICHNOP.SoTienNop, 0 AS SoTienRut FROM GIAODICHNOP
        UNION ALL
        SELECT GIAODICHRUT.MaGDrut AS MaGD, GIAODICHRUT.MaSTK, GIAODICHRUT.NgayGD, 0 AS SoTienNop, GIAODICHRUT.SoTienRut FROM GIAODICHRUT
    ) AS GiaoDichTongHop
    WHERE GiaoDichTongHop.NgayGD BETWEEN #ThoiGianThongKe.NgayBatDau AND #ThoiGianThongKe.NgayKetThuc
    GROUP BY #ThoiGianThongKe.KhoangThoiGian, #ThoiGianThongKe.NgayBatDau, #ThoiGianThongKe.NgayKetThuc
    ORDER BY #ThoiGianThongKe.NgayBatDau

    DROP TABLE #ThoiGianThongKe
END;
GO