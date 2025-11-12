
CREATE DATABASE S03_QLTKNH;
GO
USE S03_QLTKNH;
GO
USE master;
GO
ALTER DATABASE S03_QLTKNH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE S03_QLTKNH;
GO
-- =============================================
-- HỆ THỐNG QUẢN LÝ TIẾT KIỆM NGÂN HÀNG
-- =============================================
-- =============================================
-- BẢNG DANH MỤC
-- =============================================

CREATE TABLE HINHTHUCTRALAI (
    MaHTTraLai CHAR(10) PRIMARY KEY,
    TenHTTraLai NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);

CREATE TABLE HINHTHUCGUI (
    MaHTGui CHAR(10) PRIMARY KEY,
    TenHTGui NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);

CREATE TABLE LOAIGIAODICH (
    MaLoaiGD CHAR(10) PRIMARY KEY,
    TenLoaiGD NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);

CREATE TABLE LOAIHINHTK (
    MaLoaiHinh CHAR(10) PRIMARY KEY,
    TenLoaiHinh NVARCHAR(100) NOT NULL,
    KyHanThang INT,
    LaiSuatNam DECIMAL(5,2),
    LaiSuatThang DECIMAL(5,2),
    MoTa NVARCHAR(200)
);

-- =============================================
-- BẢNG CHÍNH - THỰC THỂ
-- =============================================

CREATE TABLE NHANVIEN (
    MaNV CHAR(10) PRIMARY KEY,
    TenNV NVARCHAR(100) NOT NULL,
    ChucVu NVARCHAR(50),
    PhongBan NVARCHAR(50),
    Email VARCHAR(100),
    SDT CHAR(10),
    NgayVL DATE,
    LuongCB DECIMAL(18,2),
    TrangThai NVARCHAR(50) DEFAULT N'Đang làm việc'
);

CREATE TABLE KHACHHANG (
    MaKH CHAR(10) PRIMARY KEY,
    MaNVTiepTan CHAR(10) NULL,
    TenKH NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(200),
    SDT CHAR(10),
    Email VARCHAR(100),
    CMND CHAR(12) UNIQUE NOT NULL,
    NgayTaoTK DATE DEFAULT GETDATE(),
    FOREIGN KEY (MaNVTiepTan) REFERENCES NHANVIEN(MaNV)
);

CREATE TABLE TAIKHOAN (
    MaTK CHAR(10) PRIMARY KEY,
    MaKH CHAR(10) NOT NULL,
    MaNVQL CHAR(10) NULL,
    SoTK CHAR(12) UNIQUE NOT NULL,
    SoDu DECIMAL(18,2) DEFAULT 0,
    NgayMoTK DATE DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) DEFAULT N'Hoạt động',
    FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH),
    FOREIGN KEY (MaNVQL) REFERENCES NHANVIEN(MaNV)
);

CREATE TABLE SOTIETKIEM (
    MaSTK CHAR(10) PRIMARY KEY,
    MaTK CHAR(10) NOT NULL,
    MaNVTao CHAR(10) NULL,
    MaLoaiHinh CHAR(10) NOT NULL,
    MaHTTraLai CHAR(10) NOT NULL,
    MaHTGui CHAR(10) NOT NULL,
    TienGoc DECIMAL(18,2) NOT NULL,
    TienHT DECIMAL(18,2) NOT NULL,
    NgayMoSo DATE DEFAULT GETDATE(),
    NgayDaoHan DATE,
    TrangThai NVARCHAR(50) DEFAULT N'Đang hoạt động',
    FOREIGN KEY (MaTK) REFERENCES TAIKHOAN(MaTK),
    FOREIGN KEY (MaNVTao) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaLoaiHinh) REFERENCES LOAIHINHTK(MaLoaiHinh),
    FOREIGN KEY (MaHTTraLai) REFERENCES HINHTHUCTRALAI(MaHTTraLai),
    FOREIGN KEY (MaHTGui) REFERENCES HINHTHUCGUI(MaHTGui)
);

-- =============================================
-- BẢNG GIAO DỊCH
-- =============================================

CREATE TABLE GIAODICHNOP (
    MaGDnop CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    MaNVThucHien CHAR(10) NOT NULL,
    MaLoaiGD CHAR(10) NOT NULL,
    SoTienNop DECIMAL(18,2) NOT NULL,
    NgayGD DATE DEFAULT GETDATE(),
    HTThanhToan NVARCHAR(50) DEFAULT N'Tiền mặt',
    GhiChu NVARCHAR(255) NULL,
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK),
    FOREIGN KEY (MaNVThucHien) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaLoaiGD) REFERENCES LOAIGIAODICH(MaLoaiGD)
);

CREATE TABLE GIAODICHRUT (
    MaGDrut CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    MaNVThucHien CHAR(10) NOT NULL,
    MaLoaiGD CHAR(10) NOT NULL,
    SoTienRut DECIMAL(18,2) NOT NULL,
    NgayGD DATE DEFAULT GETDATE(),
    LaiSuatApDung DECIMAL(5,2) NULL,
    LaiNhanDuoc DECIMAL(18,2) NULL,
    GhiChu NVARCHAR(255) NULL,
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK),
    FOREIGN KEY (MaNVThucHien) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaLoaiGD) REFERENCES LOAIGIAODICH(MaLoaiGD)
);

-- =============================================
-- BẢNG TÍNH TOÁN
-- =============================================

CREATE TABLE BANGTINHLAI (
    MaTinhLai CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    MaNVTinh CHAR(10) NOT NULL,
    NgayTinhLai DATE DEFAULT GETDATE(),
    LaiSuatApDung DECIMAL(5,2) NOT NULL,
    SoDuTinhLai DECIMAL(18,2) NOT NULL,
    LaiThangNay DECIMAL(18,2) NULL,
    LaiTichLuy DECIMAL(18,2) NULL,
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK),
    FOREIGN KEY (MaNVTinh) REFERENCES NHANVIEN(MaNV)
);

CREATE TABLE BANGSODU (
    MaSoDu CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    NgayCapNhat DATE DEFAULT GETDATE(),
    SoDuGoc DECIMAL(18,2) NOT NULL,
    LaiTichLuy DECIMAL(18,2) NULL,
    SoDuThucTe AS (SoDuGoc + ISNULL(LaiTichLuy, 0)) PERSISTED,
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK)
);

CREATE TABLE BAOCAO (
    MaBaoCao CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    MaNVTao CHAR(10) NOT NULL,
    NgayBaoCao DATE DEFAULT GETDATE(),
    LoaiBaoCao NVARCHAR(50),
    TongTienGui DECIMAL(18,2),
    TongLaiNhan DECIMAL(18,2),
    SoDuHienTai DECIMAL(18,2),
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK),
    FOREIGN KEY (MaNVTao) REFERENCES NHANVIEN(MaNV)
);

-- =============================================
-- DỮ LIỆU MẪU - DANH MỤC
-- =============================================

INSERT INTO HINHTHUCTRALAI VALUES
('HTTL01', N'Cuối kỳ', N'Trả lãi khi đáo hạn'),
('HTTL02', N'Hàng tháng', N'Trả lãi định kỳ hàng tháng'),
('HTTL03', N'Hàng quý', N'Trả lãi theo quý'),
('HTTL04', N'Hàng năm', N'Trả lãi mỗi năm một lần'),
('HTTL05', N'Trả trước', N'Trả lãi khi gửi'),
('HTTL06', N'Trả sau', N'Trả lãi khi rút'),
('HTTL07', N'Lãi nhập gốc', N'Lãi tự động nhập gốc'),
('HTTL08', N'Trả linh hoạt', N'Trả theo yêu cầu KH'),
('HTTL09', N'Trả theo ngày', N'Trả lãi hằng ngày'),
('HTTL10', N'Trả cuối hợp đồng', N'Trả lãi khi tất toán');

INSERT INTO HINHTHUCGUI VALUES
('HTG01', N'Tiền mặt', N'Nộp tại quầy'),
('HTG02', N'Chuyển khoản', N'Từ tài khoản khác'),
('HTG03', N'Internet Banking', N'Gửi qua ứng dụng ngân hàng'),
('HTG04', N'ATM', N'Nộp tiền qua máy ATM'),
('HTG05', N'POS', N'Thông qua thiết bị POS'),
('HTG06', N'Mobile Banking', N'Nộp bằng app di động'),
('HTG07', N'Quầy GD', N'Thực hiện tại chi nhánh'),
('HTG08', N'Auto Debit', N'Tự động trích tiền gửi'),
('HTG09', N'Trung gian thanh toán', N'Ví điện tử, Momo...'),
('HTG10', N'Chuyển tiền quốc tế', N'Gửi tiền từ nước ngoài');

INSERT INTO LOAIGIAODICH VALUES
('LGD01', N'Gửi tiền', N'Khách hàng nộp tiền vào sổ tiết kiệm'),
('LGD02', N'Rút tiền', N'Khách hàng rút tiền tiết kiệm'),
('LGD03', N'Tất toán', N'Đóng sổ tiết kiệm'),
('LGD04', N'Gia hạn', N'Mở lại sổ mới khi đáo hạn'),
('LGD05', N'Chuyển khoản', N'Transfer nội bộ'),
('LGD06', N'Nhận lãi', N'Khách nhận tiền lãi'),
('LGD07', N'Trích lãi', N'Tự động chuyển lãi sang TK'),
('LGD08', N'Phí dịch vụ', N'Trừ phí quản lý'),
('LGD09', N'Điều chỉnh', N'Điều chỉnh số dư sổ'),
('LGD10', N'Khuyến mãi', N'Thưởng thêm tiền gửi');

INSERT INTO LOAIHINHTK VALUES
('LHTK01', N'Tiết kiệm 3 tháng', 3, 4.00, 0.33, N'Ngắn hạn'),
('LHTK02', N'Tiết kiệm 6 tháng', 6, 4.50, 0.38, N'Trung hạn'),
('LHTK03', N'Tiết kiệm 12 tháng', 12, 5.00, 0.42, N'Dài hạn'),
('LHTK04', N'Tiết kiệm linh hoạt', 0, 3.50, 0.29, N'Linh hoạt rút vốn'),
('LHTK05', N'Tiết kiệm có kỳ hạn', 9, 4.80, 0.40, N'Cố định thời gian'),
('LHTK06', N'Tiết kiệm bậc thang', 12, 5.20, 0.43, N'Lãi suất theo số tiền'),
('LHTK07', N'Tiết kiệm gửi góp', 12, 5.10, 0.42, N'Gửi góp hàng tháng'),
('LHTK08', N'Tiết kiệm tích lũy', 24, 5.30, 0.44, N'Dành cho tiết kiệm lâu dài'),
('LHTK09', N'Tiết kiệm ưu đãi', 6, 4.70, 0.39, N'Ưu đãi khách hàng thân thiết'),
('LHTK10', N'Tiết kiệm trẻ em', 12, 4.80, 0.40, N'Dành cho trẻ em');

-- =============================================
-- NHÂN VIÊN & KHÁCH HÀNG
-- =============================================

INSERT INTO NHANVIEN VALUES
('NV01', N'Nguyễn Văn An', N'Giao dịch viên', N'Chi nhánh 1', 'an.nv@bank.vn', '0901110001', '2020-01-10', 12000000, N'Đang làm việc'),
('NV02', N'Lê Thị Bình', N'Thu ngân', N'Chi nhánh 1', 'binh.lt@bank.vn', '0901110002', '2020-03-12', 11000000, N'Đang làm việc'),
('NV03', N'Trần Văn Cường', N'Quản lý', N'Chi nhánh 1', 'cuong.tv@bank.vn', '0901110003', '2019-05-20', 18000000, N'Đang làm việc'),
('NV04', N'Phạm Thu Dung', N'Giao dịch viên', N'Chi nhánh 2', 'dung.pt@bank.vn', '0901110004', '2021-06-15', 12000000, N'Đang làm việc'),
('NV05', N'Đỗ Mạnh Hùng', N'Bảo vệ', N'Chi nhánh 1', 'hung.dm@bank.vn', '0901110005', '2018-04-11', 9000000, N'Nghỉ việc'),
('NV06', N'Nguyễn Quốc Huy', N'Tiếp tân', N'Chi nhánh 2', 'huy.nq@bank.vn', '0901110006', '2022-02-01', 10000000, N'Đang làm việc'),
('NV07', N'Lưu Thanh Lan', N'Chuyên viên', N'Chi nhánh 3', 'lan.lt@bank.vn', '0901110007', '2020-07-10', 15000000, N'Đang làm việc'),
('NV08', N'Đặng Hữu Minh', N'Kế toán', N'Chi nhánh 1', 'minh.dh@bank.vn', '0901110008', '2019-09-19', 14000000, N'Đang làm việc'),
('NV09', N'Ngô Bích Ngọc', N'Giao dịch viên', N'Chi nhánh 2', 'ngoc.nb@bank.vn', '0901110009', '2023-01-05', 12000000, N'Đang làm việc'),
('NV10', N'Lý Minh Quân', N'Trưởng chi nhánh', N'Chi nhánh 3', 'quan.lm@bank.vn', '0901110010', '2017-10-30', 20000000, N'Đang làm việc');

INSERT INTO KHACHHANG VALUES
('KH01', 'NV06', N'Nguyễn Văn A', N'Hà Nội', '0902221001', 'a.nguyen@gmail.com', '123456789001', '2023-03-01'),
('KH02', 'NV06', N'Lê Thị B', N'Hải Phòng', '0902221002', 'b.le@gmail.com', '123456789002', '2023-03-02'),
('KH03', 'NV06', N'Trần Văn C', N'Hà Nội', '0902221003', 'c.tran@gmail.com', '123456789003', '2023-03-03'),
('KH04', 'NV06', N'Phạm Thị D', N'Hà Nam', '0902221004', 'd.pham@gmail.com', '123456789004', '2023-03-04'),
('KH05', 'NV06', N'Đỗ Mạnh E', N'Ninh Bình', '0902221005', 'e.do@gmail.com', '123456789005', '2023-03-05'),
('KH06', 'NV06', N'Vũ Thanh F', N'Hải Dương', '0902221006', 'f.vu@gmail.com', '123456789006', '2023-03-06'),
('KH07', 'NV06', N'Hoàng Gia G', N'Hà Nội', '0902221007', 'g.hoang@gmail.com', '123456789007', '2023-03-07'),
('KH08', 'NV06', N'Lưu Lan H', N'Hà Nam', '0902221008', 'h.luu@gmail.com', '123456789008', '2023-03-08'),
('KH09', 'NV06', N'Ngô Việt I', N'Hà Nội', '0902221009', 'i.ngo@gmail.com', '123456789009', '2023-03-09'),
('KH10', 'NV06', N'Phan Thanh K', N'Hải Phòng', '0902221010', 'k.phan@gmail.com', '123456789010', '2023-03-10');

-- =============================================
-- TÀI KHOẢN & SỔ TIẾT KIỆM
-- =============================================

INSERT INTO TAIKHOAN VALUES
('TKNH01', 'KH01', 'NV03', '100000000001', 20000000, '2023-03-01', N'Hoạt động'),
('TKNH02', 'KH02', 'NV03', '100000000002', 30000000, '2023-03-02', N'Hoạt động'),
('TKNH03', 'KH03', 'NV03', '100000000003', 15000000, '2023-03-03', N'Hoạt động'),
('TKNH04', 'KH04', 'NV03', '100000000004', 25000000, '2023-03-04', N'Hoạt động'),
('TKNH05', 'KH05', 'NV03', '100000000005', 22000000, '2023-03-05', N'Hoạt động'),
('TKNH06', 'KH06', 'NV03', '100000000006', 18000000, '2023-03-06', N'Hoạt động'),
('TKNH07', 'KH07', 'NV03', '100000000007', 35000000, '2023-03-07', N'Hoạt động'),
('TKNH08', 'KH08', 'NV03', '100000000008', 12000000, '2023-03-08', N'Hoạt động'),
('TKNH09', 'KH09', 'NV03', '100000000009', 28000000, '2023-03-09', N'Hoạt động'),
('TKNH10', 'KH10', 'NV03', '100000000010', 32000000, '2023-03-10', N'Hoạt động');

INSERT INTO SOTIETKIEM VALUES
('STK01','TKNH01','NV01','LHTK01','HTTL01','HTG01',20000000,0,'2023-03-01','2023-06-01',N'Đang hoạt động'),
('STK02','TKNH02','NV02','LHTK02','HTTL02','HTG02',30000000,0,'2023-03-02','2023-09-02',N'Đang hoạt động'),
('STK03','TKNH03','NV01','LHTK03','HTTL03','HTG03',15000000,0,'2023-03-03','2024-03-03',N'Đang hoạt động'),
('STK04','TKNH04','NV01','LHTK04','HTTL04','HTG04',25000000,0,'2023-03-04','2023-12-04',N'Đang hoạt động'),
('STK05','TKNH05','NV01','LHTK05','HTTL05','HTG05',22000000,0,'2023-03-05','2023-12-05',N'Đang hoạt động'),
('STK06','TKNH06','NV01','LHTK06','HTTL06','HTG06',18000000,0,'2023-03-06','2024-03-06',N'Đang hoạt động'),
('STK07','TKNH07','NV01','LHTK07','HTTL07','HTG07',35000000,0,'2023-03-07','2024-03-07',N'Đang hoạt động'),
('STK08','TKNH08','NV01','LHTK08','HTTL08','HTG08',12000000,0,'2023-03-08','2024-03-08',N'Đang hoạt động'),
('STK09','TKNH09','NV01','LHTK09','HTTL09','HTG09',28000000,0,'2023-03-09','2024-03-09',N'Đang hoạt động'),
('STK10','TKNH10','NV01','LHTK10','HTTL10','HTG10',32000000,0,'2023-03-10','2024-03-10',N'Đang hoạt động');

-- =============================================
-- GIAO DỊCH NỘP & RÚT
-- =============================================

INSERT INTO GIAODICHNOP VALUES
('GDnop01','STK01','NV01','LGD01',5000000,'2023-03-10',N'Tiền mặt',NULL),
('GDnop02','STK02','NV02','LGD01',7000000,'2023-03-11',N'Tiền mặt',NULL),
('GDnop03','STK03','NV02','LGD01',6000000,'2023-03-12',N'Tiền mặt',NULL),
('GDnop04','STK04','NV02','LGD01',8000000,'2023-03-13',N'Tiền mặt',NULL),
('GDnop05','STK05','NV02','LGD01',9000000,'2023-03-14',N'Tiền mặt',NULL),
('GDnop06','STK06','NV02','LGD01',4000000,'2023-03-15',N'Tiền mặt',NULL),
('GDnop07','STK07','NV02','LGD01',10000000,'2023-03-16',N'Tiền mặt',NULL),
('GDnop08','STK08','NV02','LGD01',2000000,'2023-03-17',N'Tiền mặt',NULL),
('GDnop09','STK09','NV02','LGD01',3000000,'2023-03-18',N'Tiền mặt',NULL),
('GDnop10','STK10','NV02','LGD01',12000000,'2023-03-19',N'Tiền mặt',NULL);

INSERT INTO GIAODICHRUT VALUES
('GDrut01','STK01','NV02','LGD02',2000000,'2023-06-01',4.0,250000,N'Rút 1 phần'),
('GDrut02','STK02','NV02','LGD02',3000000,'2023-09-02',4.5,340000,N'Rút 1 phần'),
('GDrut03','STK03','NV02','LGD02',1500000,'2024-03-03',5.0,210000,N'Rút 1 phần'),
('GDrut04','STK04','NV02','LGD02',2500000,'2023-12-04',4.2,260000,N'Rút 1 phần'),
('GDrut05','STK05','NV02','LGD02',2000000,'2023-12-05',4.8,290000,N'Rút 1 phần'),
('GDrut06','STK06','NV02','LGD02',3000000,'2024-03-06',5.2,320000,N'Rút 1 phần'),
('GDrut07','STK07','NV02','LGD02',3500000,'2024-03-07',5.1,330000,N'Rút 1 phần'),
('GDrut08','STK08','NV02','LGD02',1500000,'2024-03-08',5.3,280000,N'Rút 1 phần'),
('GDrut09','STK09','NV02','LGD02',4000000,'2024-03-09',4.7,310000,N'Rút 1 phần'),
('GDrut10','STK10','NV02','LGD02',5000000,'2024-03-10',4.8,360000,N'Rút 1 phần');

-- =============================================
-- BẢNG TÍNH LÃI & SỐ DƯ
-- =============================================

INSERT INTO BANGTINHLAI VALUES
('BTL01','STK01','NV01','2023-04-01',4.00,20000000,66666,66666),
('BTL02','STK02','NV01','2023-04-01',4.50,30000000,112500,112500),
('BTL03','STK03','NV01','2023-04-01',5.00,15000000,62500,62500),
('BTL04','STK04','NV01','2023-04-01',4.20,25000000,87500,87500),
('BTL05','STK05','NV01','2023-04-01',4.80,22000000,88000,88000),
('BTL06','STK06','NV01','2023-04-01',5.20,18000000,78000,78000),
('BTL07','STK07','NV01','2023-04-01',5.10,35000000,148750,148750),
('BTL08','STK08','NV01','2023-04-01',5.30,12000000,53000,53000),
('BTL09','STK09','NV01','2023-04-01',4.70,28000000,109667,109667),
('BTL10','STK10','NV01','2023-04-01',4.80,32000000,128000,128000);

INSERT INTO BANGSODU (MaSoDu, MaSTK, NgayCapNhat, SoDuGoc, LaiTichLuy)
VALUES
('BSD01','STK01','2023-04-01',20000000,66666),
('BSD02','STK02','2023-04-01',30000000,112500),
('BSD03','STK03','2023-04-01',15000000,62500),
('BSD04','STK04','2023-04-01',25000000,87500),
('BSD05','STK05','2023-04-01',22000000,88000),
('BSD06','STK06','2023-04-01',18000000,78000),
('BSD07','STK07','2023-04-01',35000000,148750),
('BSD08','STK08','2023-04-01',12000000,53000),
('BSD09','STK09','2023-04-01',28000000,109667),
('BSD10','STK10','2023-04-01',32000000,128000);

INSERT INTO BAOCAO VALUES
('BC01','STK01','NV01','2023-06-01',N'Lãi tháng',20000000,66666,20066666),
('BC02','STK02','NV01','2023-06-01',N'Lãi tháng',30000000,112500,30112500),
('BC03','STK03','NV01','2023-06-01',N'Lãi tháng',15000000,62500,15062500),
('BC04','STK04','NV01','2023-06-01',N'Lãi tháng',25000000,87500,25087500),
('BC05','STK05','NV01','2023-06-01',N'Lãi tháng',22000000,88000,22088000),
('BC06','STK06','NV01','2023-06-01',N'Lãi tháng',18000000,78000,18078000),
('BC07','STK07','NV01','2023-06-01',N'Lãi tháng',35000000,148750,35148750),
('BC08','STK08','NV01','2023-06-01',N'Lãi tháng',12000000,53000,12053000),
('BC09','STK09','NV01','2023-06-01',N'Lãi tháng',28000000,109667,28109667),
('BC10','STK10','NV01','2023-06-01',N'Lãi tháng',32000000,128000,32128000);




