-- HỆ THỐNG QUẢN LÝ TIẾT KIỆM NGÂN HÀNG 

CREATE DATABASE S03_QLTKNH;
GO
USE S03_QLTKNH;
GO
--USE master;
--GO
--ALTER DATABASE S03_QLTKNH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO
--DROP DATABASE S03_QLTKNH;
--GO

-- BẢNG DANH MỤC
CREATE TABLE HINHTHUCTRALAI (
    MaHTTraLai CHAR(10) PRIMARY KEY,
    TenHTTraLai NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);
GO

CREATE TABLE HINHTHUCGUI (
    MaHTGui CHAR(10) PRIMARY KEY,
    TenHTGui NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);
GO

CREATE TABLE LOAIGIAODICH (
    MaLoaiGD CHAR(10) PRIMARY KEY,
    TenLoaiGD NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
);
GO

CREATE TABLE LOAIHINHTK (
    MaLoaiHinh CHAR(10) PRIMARY KEY,
    TenLoaiHinh NVARCHAR(100) NOT NULL,
    KyHanThang INT,
    LaiSuatNam DECIMAL(5,2),
    LaiSuatThang DECIMAL(5,2),
    MoTa NVARCHAR(200)
);
GO

-- BẢNG CHÍNH
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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

CREATE TABLE BANGSODU (
    MaSoDu CHAR(10) PRIMARY KEY,
    MaSTK CHAR(10) NOT NULL,
    NgayCapNhat DATE DEFAULT GETDATE(),
    SoDuGoc DECIMAL(18,2) NOT NULL,
    LaiTichLuy DECIMAL(18,2) NULL,
    SoDuThucTe AS (SoDuGoc + ISNULL(LaiTichLuy, 0)) PERSISTED,
    FOREIGN KEY (MaSTK) REFERENCES SOTIETKIEM(MaSTK)
);
GO

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
GO


-- INSERT DỮ LIỆU MẪU

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

INSERT INTO SOTIETKIEM VALUES
('STK01','TKNH01','NV01','LHTK01','HTTL01','HTG01',20000000,20000000,'2023-03-01','2023-06-01',N'Đang hoạt động'),
('STK02','TKNH02','NV02','LHTK02','HTTL02','HTG02',30000000,30000000,'2023-03-02','2023-09-02',N'Đang hoạt động'),
('STK03','TKNH03','NV01','LHTK03','HTTL03','HTG03',15000000,15000000,'2023-03-03','2024-03-03',N'Đang hoạt động'),
('STK04','TKNH04','NV01','LHTK04','HTTL04','HTG04',25000000,25000000,'2023-03-04','2023-12-04',N'Đang hoạt động'),
('STK05','TKNH05','NV01','LHTK05','HTTL05','HTG05',22000000,22000000,'2023-03-05','2023-12-05',N'Đang hoạt động'),
('STK06','TKNH06','NV01','LHTK06','HTTL06','HTG06',18000000,18000000,'2023-03-06','2024-03-06',N'Đang hoạt động'),
('STK07','TKNH07','NV01','LHTK07','HTTL07','HTG07',35000000,35000000,'2023-03-07','2024-03-07',N'Đang hoạt động'),
('STK08','TKNH08','NV01','LHTK08','HTTL08','HTG08',12000000,12000000,'2023-03-08','2024-03-08',N'Đang hoạt động'),
('STK09','TKNH09','NV01','LHTK09','HTTL09','HTG09',28000000,28000000,'2023-03-09','2024-03-09',N'Đang hoạt động'),
('STK10','TKNH10','NV01','LHTK10','HTTL10','HTG10',32000000,32000000,'2023-03-10','2024-03-10',N'Đang hoạt động');
GO

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
GO

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
GO

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
GO

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
GO

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
GO

SELECT * FROM TAIKHOAN

-- =============================================
-- TỔNG HỢP CÁC VIEW
-- =============================================


GO

-- =============================================
-- I. VIEW LẤY THÔNG TIN TỪ 2 BẢNG TRỞ LÊN
-- =============================================

-- 1. View thông tin khách hàng (2 bảng)
CREATE OR ALTER VIEW V_ThongTinKH AS
SELECT 
    KHACHHANG.MaKH, 
    KHACHHANG.TenKH, 
    KHACHHANG.SDT, 
    KHACHHANG.Email, 
    KHACHHANG.MaNVTiepTan, 
    NHANVIEN.TenNV
FROM KHACHHANG, NHANVIEN
WHERE KHACHHANG.MaNVTiepTan = NHANVIEN.MaNV;
GO

-- 2. View tài khoản khách hàng (2 bảng)
CREATE OR ALTER VIEW V_TaiKhoanKH AS
SELECT 
    TAIKHOAN.MaTK, 
    TAIKHOAN.SoTK, 
    KHACHHANG.TenKH, 
    TAIKHOAN.SoDu, 
    TAIKHOAN.TrangThai
FROM TAIKHOAN, KHACHHANG
WHERE TAIKHOAN.MaKH = KHACHHANG.MaKH;
GO

-- 3. View sổ tiết kiệm chi tiết (6 bảng)
CREATE OR ALTER VIEW V_STKChiTiet AS
SELECT
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    LOAIHINHTK.TenLoaiHinh,
    HINHTHUCGUI.TenHTGui,
    HINHTHUCTRALAI.TenHTTraLai,
    SOTIETKIEM.TienGoc,
    SOTIETKIEM.TrangThai
FROM SOTIETKIEM, TAIKHOAN, KHACHHANG, LOAIHINHTK, HINHTHUCGUI, HINHTHUCTRALAI
WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
  AND SOTIETKIEM.MaLoaiHinh = LOAIHINHTK.MaLoaiHinh
  AND SOTIETKIEM.MaHTGui = HINHTHUCGUI.MaHTGui
  AND SOTIETKIEM.MaHTTraLai = HINHTHUCTRALAI.MaHTTraLai;
GO

-- 4. View sổ tiết kiệm đang hoạt động (3 bảng)
CREATE OR ALTER VIEW V_STK_DANGHOATDONG AS
SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    SOTIETKIEM.NgayMoSo,
    SOTIETKIEM.NgayDaoHan,
    SOTIETKIEM.TrangThai
FROM SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
  AND SOTIETKIEM.TrangThai = N'Đang hoạt động';
GO
Select * from V_STK_DANGHOATDONG

-- 5. View sổ tiết kiệm sắp đáo hạn (3 bảng)
CREATE OR ALTER VIEW V_STK_SAPDAOHAN AS
SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    SOTIETKIEM.NgayMoSo,
    SOTIETKIEM.NgayDaoHan,
    SOTIETKIEM.TrangThai
FROM SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
  AND SOTIETKIEM.NgayDaoHan BETWEEN GETDATE() AND DATEADD(DAY,7,GETDATE());
GO

Select * from V_STK_SAPDAOHAN

-- 6. View giao dịch nộp tiền (5 bảng)
CREATE OR ALTER VIEW V_GDNOPTIEN AS
SELECT 
    GIAODICHNOP.MaGDnop,
    KHACHHANG.TenKH,
    NHANVIEN.TenNV,
    GIAODICHNOP.SoTienNop,
    GIAODICHNOP.NgayGD,
    GIAODICHNOP.HTThanhToan
FROM GIAODICHNOP, SOTIETKIEM, TAIKHOAN, KHACHHANG, NHANVIEN
WHERE GIAODICHNOP.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
  AND GIAODICHNOP.MaNVThucHien = NHANVIEN.MaNV;
GO

-- 7. View giao dịch rút tiền (5 bảng)
CREATE OR ALTER VIEW V_GDRUTTIEN AS
SELECT 
    GIAODICHRUT.MaGDrut,
    KHACHHANG.TenKH,
    NHANVIEN.TenNV,
    GIAODICHRUT.SoTienRut,
    GIAODICHRUT.NgayGD,
    GIAODICHRUT.LaiNhanDuoc
FROM GIAODICHRUT, SOTIETKIEM, TAIKHOAN, KHACHHANG, NHANVIEN
WHERE GIAODICHRUT.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
  AND GIAODICHRUT.MaNVThucHien = NHANVIEN.MaNV;
GO

-- 8. View lịch sử giao dịch theo sổ (4 bảng)
CREATE OR ALTER VIEW V_LichSuGD_STK AS
SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    GIAODICHNOP.NgayGD,
    N'Gửi tiền' AS LoaiGD,
    GIAODICHNOP.SoTienNop AS SoTien
FROM GIAODICHNOP, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE GIAODICHNOP.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH

UNION ALL

SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    GIAODICHRUT.NgayGD,
    N'Rút tiền' AS LoaiGD,
    GIAODICHRUT.SoTienRut AS SoTien
FROM GIAODICHRUT, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE GIAODICHRUT.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH;
GO

-- 9. View bảng tính lãi chi tiết (4 bảng)
CREATE OR ALTER VIEW V_BANGTINHLAICHITIET AS
SELECT 
    BANGTINHLAI.MaTinhLai,
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    BANGTINHLAI.LaiSuatApDung,
    BANGTINHLAI.LaiThangNay,
    BANGTINHLAI.LaiTichLuy
FROM BANGTINHLAI, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE BANGTINHLAI.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH;
GO

-- 10. View số dư sổ tiết kiệm (4 bảng)
CREATE OR ALTER VIEW V_SODUSTK AS
SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    BANGSODU.SoDuGoc,
    BANGSODU.LaiTichLuy,
    BANGSODU.SoDuThucTe
FROM BANGSODU, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE BANGSODU.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH;
GO

-- 11. View tổng hợp số dư (4 bảng)
CREATE OR ALTER VIEW V_TONGHOPSODU AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    SUM(BANGSODU.SoDuThucTe) AS TongSoDu
FROM BANGSODU, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE BANGSODU.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
GROUP BY KHACHHANG.MaKH, KHACHHANG.TenKH;
GO

-- 12. View chi tiết báo cáo (4 bảng)
CREATE OR ALTER VIEW V_BaoCaoChiTiet AS
SELECT 
    BAOCAO.MaBaoCao,
    KHACHHANG.TenKH,
    BAOCAO.NgayBaoCao,
    BAOCAO.LoaiBaoCao,
    BAOCAO.SoDuHienTai
FROM BAOCAO, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE BAOCAO.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH;
GO

-- 13. View báo cáo theo khách hàng (4 bảng)
CREATE OR ALTER VIEW V_BaoCaoTheoKH AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    SUM(BAOCAO.TongTienGui) AS TongTienGui,
    SUM(BAOCAO.TongLaiNhan) AS TongLaiNhan,
    SUM(BAOCAO.SoDuHienTai) AS TongSoDu
FROM BAOCAO, SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE BAOCAO.MaSTK = SOTIETKIEM.MaSTK
  AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
  AND TAIKHOAN.MaKH = KHACHHANG.MaKH
GROUP BY KHACHHANG.MaKH, KHACHHANG.TenKH;
GO

-- 14. View báo cáo theo nhân viên (2 bảng)
CREATE OR ALTER VIEW V_BaoCaoTheoNV AS
SELECT 
    NHANVIEN.MaNV,
    NHANVIEN.TenNV,
    COUNT(BAOCAO.MaSTK) AS SoLuongBaoCao,
    SUM(BAOCAO.TongTienGui) AS TongTienGui
FROM BAOCAO, NHANVIEN
WHERE BAOCAO.MaNVTao = NHANVIEN.MaNV
GROUP BY NHANVIEN.MaNV, NHANVIEN.TenNV;
GO

-- 15. View khách hàng không hoạt động (4 bảng)
CREATE OR ALTER VIEW V_KhachHangKhongHoatDong_ChiTiet AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    KHACHHANG.SDT,
    KHACHHANG.Email,
    TAIKHOAN.MaTK,
    TAIKHOAN.SoTK,
    TAIKHOAN.SoDu,
    TAIKHOAN.TrangThai AS TrangThaiTaiKhoan,
    COUNT(SOTIETKIEM.MaSTK) AS SoLuongSTK,
    GiaoDichCuoi.NgayGDCuoi,
    DATEDIFF(DAY, GiaoDichCuoi.NgayGDCuoi, GETDATE()) AS SoNgayKhongGiaoDich
FROM KHACHHANG, TAIKHOAN, SOTIETKIEM,
    (SELECT GiaoDichTongHop.MaSTK, MAX(GiaoDichTongHop.NgayGD) AS NgayGDCuoi
     FROM (SELECT GIAODICHNOP.MaSTK, GIAODICHNOP.NgayGD FROM GIAODICHNOP
           UNION ALL
           SELECT GIAODICHRUT.MaSTK, GIAODICHRUT.NgayGD FROM GIAODICHRUT) AS GiaoDichTongHop
     GROUP BY GiaoDichTongHop.MaSTK) AS GiaoDichCuoi
WHERE KHACHHANG.MaKH = TAIKHOAN.MaKH
  AND TAIKHOAN.MaTK = SOTIETKIEM.MaTK
  AND SOTIETKIEM.MaSTK = GiaoDichCuoi.MaSTK
  AND (TAIKHOAN.TrangThai IN (N'Không hoạt động', N'Tạm khóa', N'Đóng băng')
       OR DATEDIFF(DAY, GiaoDichCuoi.NgayGDCuoi, GETDATE()) > 180)
GROUP BY KHACHHANG.MaKH, KHACHHANG.TenKH, KHACHHANG.SDT, KHACHHANG.Email,
         TAIKHOAN.MaTK, TAIKHOAN.SoTK, TAIKHOAN.SoDu, TAIKHOAN.TrangThai,
         GiaoDichCuoi.NgayGDCuoi;
GO
SELECT * FROM V_KhachHangKhongHoatDong_ChiTiet

-- 16. View khách hàng tiềm năng (4 bảng)
CREATE OR ALTER VIEW V_KhachHangTiemNang AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    COUNT(SOTIETKIEM.MaSTK) AS SoLuongSTK,
    SUM(BANGSODU.SoDuThucTe) AS TongSoDu
FROM KHACHHANG, TAIKHOAN, SOTIETKIEM, BANGSODU
WHERE KHACHHANG.MaKH = TAIKHOAN.MaKH
  AND TAIKHOAN.MaTK = SOTIETKIEM.MaTK
  AND SOTIETKIEM.MaSTK = BANGSODU.MaSTK
GROUP BY KHACHHANG.MaKH, KHACHHANG.TenKH
HAVING COUNT(SOTIETKIEM.MaSTK) >= 2 OR SUM(BANGSODU.SoDuThucTe) >= 50000000;
GO

-- =============================================
-- II. VIEW MỚI: TỔNG HỢP SỔ TIẾT KIỆM THEO KHÁCH HÀNG
-- =============================================

-- 17. View tổng hợp sổ tiết kiệm theo khách hàng (4 bảng)
CREATE OR ALTER VIEW V_TongHopSTK_KH AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    KHACHHANG.SDT,
    KHACHHANG.Email,
    COUNT(SOTIETKIEM.MaSTK) AS TongSoSTK,
    SUM(SOTIETKIEM.TienGoc) AS TongTienGoc,
    SUM(BANGSODU.SoDuThucTe) AS TongSoDuHienTai,
    MAX(SOTIETKIEM.NgayMoSo) AS NgayMoSoGanNhat
FROM KHACHHANG, TAIKHOAN, SOTIETKIEM, BANGSODU
WHERE KHACHHANG.MaKH = TAIKHOAN.MaKH
  AND TAIKHOAN.MaTK = SOTIETKIEM.MaTK
  AND SOTIETKIEM.MaSTK = BANGSODU.MaSTK
  AND SOTIETKIEM.TrangThai = N'Đang hoạt động'
GROUP BY KHACHHANG.MaKH, KHACHHANG.TenKH, KHACHHANG.SDT, KHACHHANG.Email;
GO

-- =============================================
-- III. VIEW TỔNG HỢP GIAO DỊCH (2 bảng)
-- =============================================

-- 18. View tổng hợp giao dịch (2 bảng)
CREATE OR ALTER VIEW V_TONGHOPGD AS
SELECT 
    GIAODICHNOP.MaGDnop AS MaGD,
    GIAODICHNOP.MaSTK,
    GIAODICHNOP.SoTienNop AS SoTien,
    N'Nộp tiền' AS LoaiGD,
    GIAODICHNOP.NgayGD
FROM GIAODICHNOP
UNION ALL
SELECT 
    GIAODICHRUT.MaGDrut AS MaGD,
    GIAODICHRUT.MaSTK,
    GIAODICHRUT.SoTienRut AS SoTien,
    N'Rút tiền' AS LoaiGD,
    GIAODICHRUT.NgayGD
FROM GIAODICHRUT;
GO

-- 19. View giao dịch theo ngày (2 bảng)
CREATE OR ALTER VIEW V_GD_THEONGAY AS
SELECT 
    GIAODICHNOP.MaGDnop AS MaGD,
    GIAODICHNOP.MaSTK,
    GIAODICHNOP.NgayGD,
    GIAODICHNOP.SoTienNop AS SoTien,
    N'Nộp tiền' AS LoaiGD
FROM GIAODICHNOP
WHERE CONVERT(DATE, GIAODICHNOP.NgayGD) = CONVERT(DATE, GETDATE())

UNION ALL

SELECT 
    GIAODICHRUT.MaGDrut AS MaGD,
    GIAODICHRUT.MaSTK,
    GIAODICHRUT.NgayGD,
    GIAODICHRUT.SoTienRut AS SoTien,
    N'Rút tiền' AS LoaiGD
FROM GIAODICHRUT
WHERE CONVERT(DATE, GIAODICHRUT.NgayGD) = CONVERT(DATE, GETDATE());
GO

-- ============================================
-- TỔNG HỢP CÁC THỦ TỤC
-- ============================================

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
        MaKH = COALESCE(@MaKH, MaKH),
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
        
        (SELECT COUNT(*) FROM SOTIETKIEM) AS TongSoSoTietKiem,
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
        SET @CurrentDate = DATEFROMPARTS(YEAR(@TuNgay), ((MONTH(@TuNgay)-1)/3)*3+1, 1)
        WHILE @CurrentDate <= @DenNgay
        BEGIN
            INSERT INTO #ThoiGianThongKe VALUES (
                N'Q' + CAST((MONTH(@CurrentDate)-1)/3 + 1 AS NVARCHAR(1)) + '/' + CAST(YEAR(@CurrentDate) AS NVARCHAR(4)),
                @CurrentDate,
                DATEADD(DAY, -1, DATEADD(MONTH, 3, @CurrentDate))
            )
            SET @CurrentDate = DATEADD(MONTH, 3, @CurrentDate)
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

-- =============================================
-- TỔNG HỢP TRIGGER
-- =============================================

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

-- Trigger: Cập nhật ngày đáo hạn (soduthucte da duoc set tu dong cap nhat san)
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

-- =============================================
-- TỔNG HỢP CÁC FUNCTION
-- =============================================


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

-- =============================================
-- VÍ DỤ CHO CÁC THỦ TỤC
-- =============================================

-- 1. Thủ tục quản lý tài khoản
EXEC sp_Them_TaiKhoan 'TKNH11', 'KH01', 'NV03', '100000000011', 50000000, '2024-01-15', N'Hoạt động';
EXEC sp_Sua_TaiKhoan 'TKNH01', @SoDu = 25000000;
EXEC sp_Xoa_TaiKhoan 'TKNH11';

-- 2. Thủ tục quản lý sổ tiết kiệm
EXEC sp_MoSoTietKiemMoi 'STK11', 'BSD11', 'KH01', 'LHTK01', 'HTG01', 'HTTL01', 50000000, 'NV01';
EXEC sp_GuiTienVaoSo 'GDnop11', 'STK01', 10000000, 'NV01', 'LGD01';
EXEC sp_RutTienTuSo 'GDrut11', 'STK01', 5000000, 'NV02', 'LGD02';
EXEC sp_Sua_SoTietKiem 'STK01', @TienGoc = 25000000;

-- 3. Thủ tục tính lãi và số dư
EXEC sp_Them_BangTinhLai 'BTL11', 'STK01', 'NV01', '2024-01-31', 4.00, 25000000, 83333, 150000;
EXEC sp_TinhLaiHangThang 'BTL12', 'STK01', 'NV01';
EXEC sp_Them_BangSoDu 'BSD11', 'STK01', 25000000, 150000;

-- 4. Thủ tục quản lý nhân viên và khách hàng
EXEC sp_Them_NhanVien 'NV11', N'Trần Thị Mai', N'Giao dịch viên', N'Chi nhánh 1', 'mai.tt@bank.vn', '0901110011', '2024-01-01', 13000000, N'Đang làm việc';
EXEC sp_Them_KhachHang 'KH11', 'NV06', N'Nguyễn Văn Mới', N'Hà Nội', '0902221011', 'new@gmail.com', '123456789011';
EXEC sp_Sua_KhachHang 'KH01', @SDT = '0902221111';

-- 5. Thủ tục tra cứu và thống kê
EXEC sp_TraCuuSoTietKiem @MaSTK = 'STK01';
EXEC sp_TraCuuKhachHangTheoCMND '123456789001';
EXEC sp_KiemTraSoDu 'STK01';
EXEC sp_ThongKeTongQuanHeThong '2023-01-01', '2024-01-31';
EXEC sp_ThongKeTheoLoaiHinhTK 'LHTK01';
EXEC sp_ThongKeDoanhSoTheoThoiGian N'THANG', '2023-01-01', '2024-01-31';

-- =============================================
-- VÍ DỤ KÍCH HOẠT TRIGGER
-- =============================================

-- 1. Trigger trên bảng SOTIETKIEM
DELETE FROM SOTIETKIEM WHERE MaSTK = 'STK01'; -- Sẽ bị trigger chặn
UPDATE SOTIETKIEM SET MaLoaiHinh = 'LHTK03' WHERE MaSTK = 'STK01'; -- Trigger tự động tính lại ngày đáo hạn
Select * from SOTIETKIEM

-- 2. Trigger trên bảng GIAODICH
INSERT INTO GIAODICHNOP VALUES ('GDnop11', 'STK01', 'NV01', 'LGD01', 5000000, GETDATE(), N'Tiền mặt', NULL);
INSERT INTO GIAODICHRUT VALUES ('GDrut11', 'STK01', 'NV02', 'LGD02', 2000000, GETDATE(), 4.0, 25000, N'Rút 1 phần');

-- 3. Trigger trên bảng BANGTINHLAI
INSERT INTO BANGTINHLAI VALUES ('BTL11', 'STK01', 'NV01', '2024-01-31', 4.00, 25000000, 83333, 83333);
Select * from BANGTINHLAI

-- 4. Trigger trên bảng NHANVIEN
UPDATE NHANVIEN SET TrangThai = N'Nghỉ việc' WHERE MaNV = 'NV01'; -- Trigger tự động cập nhật tài khoản
DELETE FROM NHANVIEN WHERE MaNV = 'NV02'; -- Trigger chuyển thành đánh dấu nghỉ việc

-- 5. Trigger trên bảng KHACHHANG
INSERT INTO KHACHHANG VALUES ('KH11', 'NV06', N'Nguyễn Văn Trùng', N'Hà Nội', '0902221011', 'trung@gmail.com', '123456789001', GETDATE()); -- Sẽ bị trigger chặn

-- 6. Trigger trên bảng BAOCAO
INSERT INTO BAOCAO VALUES ('BC11', 'STK01', 'NV01', GETDATE(), N'Lãi tháng', 0, 0, 0); -- Trigger tự động tính toán

-- =============================================
-- SELECT TẤT CẢ CÁC VIEW
-- =============================================

SELECT * FROM V_ThongTinKH;
SELECT * FROM V_TaiKhoanKH;
SELECT * FROM V_STKChiTiet;
SELECT * FROM V_STK_DANGHOATDONG;
SELECT * FROM V_STK_SAPDAOHAN;
SELECT * FROM V_GDNOPTIEN;
SELECT * FROM V_GDRUTTIEN;
SELECT * FROM V_LichSuGD_STK;
SELECT * FROM V_BANGTINHLAICHITIET;
SELECT * FROM V_SODUSTK;
SELECT * FROM V_TONGHOPSODU;
SELECT * FROM V_BaoCaoChiTiet;
SELECT * FROM V_BaoCaoTheoKH;
SELECT * FROM V_BaoCaoTheoNV;
SELECT * FROM V_KhachHangKhongHoatDong_ChiTiet;
SELECT * FROM V_KhachHangTiemNang;
SELECT * FROM V_TongHopSTK_KH;
SELECT * FROM V_TONGHOPGD;
SELECT * FROM V_GD_THEONGAY;

-- =============================================
-- VÍ DỤ SỬ DỤNG CÁC HÀM (FUNCTION)
-- =============================================

-- Tính lãi đến ngày bất kỳ
SELECT dbo.fn_TinhLaiDenNgay(20000000, 4.00, '2023-03-01', '2024-01-31') AS LaiTichLuy;

-- Tính lãi theo số ngày
SELECT dbo.fn_TinhLaiTheoNgay(20000000, 4.00, 90) AS Lai90Ngay;

-- Tính ngày đáo hạn
SELECT dbo.fn_TinhNgayDaoHan('2023-03-01', 3) AS NgayDaoHan;

-- Kiểm tra đáo hạn
SELECT dbo.fn_KiemTraDaoHan('2024-06-01') AS TrangThaiDaoHan;

-- Tính tổng tiền đã nạp vào STK
SELECT dbo.fn_TongTienDaNhapSTK('STK01') AS TongTienNhap;

-- Tính tổng tiền đã rút từ STK
SELECT dbo.fn_TongTienDaRutSTK('STK01') AS TongTienRut;

-- Sử dụng hàm trong truy vấn phức tạp
SELECT 
    MaSTK,
    TienGoc,
    dbo.fn_TinhLaiDenNgay(TienGoc, 4.00, NgayMoSo, GETDATE()) AS LaiDuTinh,
    dbo.fn_TongTienDaNhapSTK(MaSTK) AS TongNhap,
    dbo.fn_TongTienDaRutSTK(MaSTK) AS TongRut
FROM SOTIETKIEM
WHERE TrangThai = N'Đang hoạt động';

-- =============================================
-- VÍ DỤ TỔNG HỢP - BÁO CÁO DOANH SỐ
-- =============================================

-- Báo cáo tổng hợp hiệu suất nhân viên
EXEC sp_ThongKeTheoNhanVien 'NV01', '2023-01-01', '2024-01-31';

-- Báo cáo doanh số theo tháng
EXEC sp_ThongKeDoanhSoTheoThoiGian N'THANG', '2023-01-01', '2024-01-31';

-- Xem tất cả khách hàng tiềm năng
SELECT * FROM V_KhachHangTiemNang;

-- Xem tất cả sổ sắp đáo hạn
SELECT * FROM V_STK_SAPDAOHAN;

-- Thống kê tổng quan hệ thống
EXEC sp_ThongKeTongQuanHeThong;



