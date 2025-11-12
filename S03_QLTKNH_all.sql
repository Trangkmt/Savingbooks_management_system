
-- HỆ THỐNG QUẢN LÝ TIẾT KIỆM NGÂN HÀNG 


CREATE DATABASE S03_QLTKNH;
GO
USE S03_QLTKNH;
GO
--USE master;
GO
--ALTER DATABASE S03_QLTKNH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
--DROP DATABASE S03_QLTKNH;
GO

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

-- PHẦN 1: QUẢN LÝ KHÁCH HÀNG VÀ TÀI KHOẢN


-- VIEW 1: Thông tin khách hàng
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

-- VIEW 2: Tài khoản khách hàng
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

-- VIEW 3: Khách hàng không hoạt động (không giao dịch > 180 ngày)
CREATE OR ALTER VIEW V_KhachHangKhongHoatDong AS
SELECT 
    KHACHHANG.MaKH,
    KHACHHANG.TenKH,
    GiaoDichCuoi.NgayGDCuoi
FROM 
    KHACHHANG,
    TAIKHOAN,
    SOTIETKIEM,
    (
        SELECT 
            GiaoDichTongHop.MaSTK, 
            MAX(GiaoDichTongHop.NgayGD) AS NgayGDCuoi
        FROM (
            SELECT GIAODICHNOP.MaSTK, GIAODICHNOP.NgayGD FROM GIAODICHNOP
            UNION ALL
            SELECT GIAODICHRUT.MaSTK, GIAODICHRUT.NgayGD FROM GIAODICHRUT
        ) AS GiaoDichTongHop
        GROUP BY GiaoDichTongHop.MaSTK
    ) AS GiaoDichCuoi
WHERE 
    KHACHHANG.MaKH = TAIKHOAN.MaKH
    AND TAIKHOAN.MaTK = SOTIETKIEM.MaTK
    AND SOTIETKIEM.MaSTK = GiaoDichCuoi.MaSTK
    AND DATEDIFF(DAY, GiaoDichCuoi.NgayGDCuoi, GETDATE()) > 180;
GO
SELECT * FROM V_KhachHangKhongHoatDong
-- PROCEDURE 1: Tạo tài khoản khách hàng
CREATE OR ALTER PROCEDURE SP_TaoTaiKhoanKhachHang
    @MaKH CHAR(10),
    @MaTK CHAR(10),
    @SoTK CHAR(12),
    @NgayMoTK DATE = NULL
AS
BEGIN
    -- Kiểm tra khách hàng tồn tại
    IF NOT EXISTS (SELECT * FROM KHACHHANG WHERE MaKH = @MaKH)
    BEGIN
        PRINT N'Lỗi: Khách hàng không tồn tại';
        RETURN;
    END

    -- Kiểm tra số tài khoản đã tồn tại
    IF EXISTS (SELECT * FROM TAIKHOAN WHERE SoTK = @SoTK)
    BEGIN
        PRINT N'Lỗi: Số tài khoản đã tồn tại';
        RETURN;
    END

    -- Tạo tài khoản mới
    INSERT INTO TAIKHOAN (MaTK, MaKH, SoTK, SoDu, NgayMoTK, TrangThai)
    VALUES (@MaTK, @MaKH, @SoTK, 0, ISNULL(@NgayMoTK, GETDATE()), N'Hoạt động');

    PRINT N'Tạo tài khoản thành công cho khách hàng ' + @MaKH;
END
GO

-- VÍ DỤ PROCEDURE 1:
EXEC SP_TaoTaiKhoanKhachHang 
    @MaKH = 'KH01', 
    @MaTK = 'TKNH11', 
    @SoTK = '100000000011', 
    @NgayMoTK = '2024-01-15';
GO

-- PROCEDURE 2: Cập nhật thông tin khách hàng
CREATE OR ALTER PROC SP_CapNhatThongTinKhachHang
    @MaKH CHAR(10),
    @TenKH NVARCHAR(100) = NULL,
    @DiaChi NVARCHAR(200) = NULL,
    @SDT CHAR(10) = NULL,
    @Email VARCHAR(100) = NULL
AS
BEGIN
    -- Kiểm tra khách hàng tồn tại
    IF NOT EXISTS (SELECT * FROM KHACHHANG WHERE MaKH = @MaKH)
    BEGIN
        PRINT N'Lỗi: Khách hàng không tồn tại';
        RETURN;
    END

    -- Cập nhật thông tin (chỉ cập nhật các trường không NULL)
    UPDATE KHACHHANG
    SET 
        TenKH = COALESCE(@TenKH, TenKH),
        DiaChi = COALESCE(@DiaChi, DiaChi),
        SDT = COALESCE(@SDT, SDT),
        Email = COALESCE(@Email, Email)
    WHERE MaKH = @MaKH;

    PRINT N'Đã cập nhật thông tin khách hàng ' + @MaKH;
END
GO

-- VÍ DỤ PROCEDURE 2:
EXEC SP_CapNhatThongTinKhachHang 
    @MaKH = 'KH01', 
    @TenKH = N'Nguyễn Văn An Cập Nhật',
    @SDT = '0912345678',
    @Email = 'anvannguyen@gmail.com';
GO

-- TRIGGER 1: Cập nhật bảng số dư
CREATE OR ALTER TRIGGER TRG_CapNhatBangSoDu
ON BANGSODU
AFTER UPDATE
AS
BEGIN
    UPDATE BANGSODU
    SET NgayCapNhat = GETDATE()
    FROM BANGSODU, inserted
    WHERE BANGSODU.MaSoDu = inserted.MaSoDu;

    PRINT N'Đã cập nhật ngày cập nhật số dư';
END;
GO

-- VÍ DỤ TRIGGER 1:
-- Cập nhật lãi tích lũy, trigger sẽ tự động cập nhật NgayCapNhat
UPDATE BANGSODU
SET LaiTichLuy = 100000
WHERE MaSoDu = 'BSD01';
GO

SELECT * FROM BANGSODU WHERE MaSoDu = 'BSD01';
GO


-- PHẦN 2: QUẢN LÝ SỔ TIẾT KIỆM


-- VIEW 4: Lịch sử giao dịch sổ tiết kiệm
CREATE OR ALTER VIEW V_LichSuGDSTK AS
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

-- PROCEDURE 3: Mở sổ tiết kiệm mới
CREATE OR ALTER PROCEDURE SP_MoSoTietKiemMoi
    @MaSTK CHAR(10),
    @MaSoDu CHAR(10),
    @MaKH CHAR(10),
    @MaLoaiHinh CHAR(10),
    @MaHTGui CHAR(10),
    @MaHTTraLai CHAR(10),
    @TienGoc DECIMAL(18,2),
    @MaNVTao CHAR(10)
AS
BEGIN
    DECLARE @KyHanThang INT;
    DECLARE @NgayMoSo DATE;
    DECLARE @NgayDaoHan DATE;
    DECLARE @MaTK CHAR(10);

    SET @NgayMoSo = GETDATE();

    -- Kiểm tra khách hàng tồn tại
    IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
    BEGIN
        PRINT N'Lỗi: Khách hàng không tồn tại';
        RETURN;
    END

    IF EXISTS(SELECT 1 FROM BANGSODU WHERE MaSodu = @MaSoDu)
    BEGIN
        PRINT N'Lỗi: Mã số dư đã tồn tại';
        RETURN;
    END
    -- Kiểm tra số tiền gửi tối thiểu
    IF @TienGoc < 100000
    BEGIN
        PRINT N'Lỗi: Số tiền gửi tối thiểu phải từ 100,000đ trở lên';
        RETURN;
    END

    -- Lấy kỳ hạn từ loại hình tiết kiệm
    SELECT @KyHanThang = KyHanThang 
    FROM LOAIHINHTK 
    WHERE MaLoaiHinh = @MaLoaiHinh;

    IF @KyHanThang IS NULL
    BEGIN
        PRINT N'Lỗi: Loại hình tiết kiệm không hợp lệ';
        RETURN;
    END

    -- Tính ngày đáo hạn
    SET @NgayDaoHan = DATEADD(MONTH, @KyHanThang, @NgayMoSo);

    -- Lấy tài khoản ngân hàng của khách hàng
    SELECT TOP 1 @MaTK = MaTK 
    FROM TAIKHOAN 
    WHERE MaKH = @MaKH;

    IF @MaTK IS NULL
    BEGIN
        PRINT N'Lỗi: Khách hàng chưa có tài khoản ngân hàng';
        RETURN;
    END

    -- Thêm sổ tiết kiệm
    INSERT INTO SOTIETKIEM (MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                            TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
    VALUES (@MaSTK, @MaTK, @MaNVTao, @MaLoaiHinh, @MaHTTraLai, @MaHTGui,
            @TienGoc, @TienGoc, @NgayMoSo, @NgayDaoHan, N'Đang hoạt động');

    -- Tạo dòng trong bảng số dư
    INSERT INTO BANGSODU (MaSoDu, MaSTK, SoDuGoc, LaiTichLuy)
    VALUES (@MaSoDu, @MaSTK, @TienGoc, 0);

    PRINT N'Mở sổ tiết kiệm thành công. Mã sổ: ' + @MaSTK;
END;
GO

-- VÍ DỤ PROCEDURE 3:
EXEC SP_MoSoTietKiemMoi
    @MaSTK = 'STK11',
    @MaSoDu = 'BSD11',
    @MaKH = 'KH01',
    @MaLoaiHinh = 'LHTK03',
    @MaHTGui = 'HTG01',
    @MaHTTraLai = 'HTTL01',
    @TienGoc = 50000000,
    @MaNVTao = 'NV01';
GO
Select * from SOTIETKIEM

EXEC SP_MoSoTietKiemMoi
    @MaSTK = 'STK14',
    @MaSoDu = 'BSD14',
    @MaKH = 'KH01',
    @MaLoaiHinh = 'LHTK03',
    @MaHTGui = 'HTG01',
    @MaHTTraLai = 'HTTL01',
    @TienGoc = 50000000,
    @MaNVTao = 'NV01';
GO

SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK11';
SELECT * FROM BANGSODU WHERE MaSTK = 'STK11';
GO

-- PROCEDURE 4: Đóng sổ tiết kiệm (Tất toán)
CREATE OR ALTER PROCEDURE SP_DongSoTietKiem
    @MaSTK CHAR(10)
AS
BEGIN
    DECLARE @SoDuGoc DECIMAL(18,2);
    DECLARE @LaiTichLuy DECIMAL(18,2);
    DECLARE @SoTienCuoi DECIMAL(18,2);

    -- Kiểm tra sổ tiết kiệm tồn tại
    IF NOT EXISTS (SELECT * FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Lỗi: Sổ tiết kiệm không tồn tại';
        RETURN;
    END

    -- Lấy số dư gốc và lãi tích lũy
    SELECT TOP 1 
        @SoDuGoc = SoDuGoc,
        @LaiTichLuy = ISNULL(LaiTichLuy, 0)
    FROM BANGSODU
    WHERE MaSTK = @MaSTK
    ORDER BY NgayCapNhat DESC;

    -- Nếu không có trong bảng số dư, lấy từ sổ tiết kiệm
    IF @SoDuGoc IS NULL
    BEGIN
        SELECT @SoDuGoc = TienGoc FROM SOTIETKIEM WHERE MaSTK = @MaSTK;
    END

    -- Tính tổng số tiền cuối
    SET @SoTienCuoi = ISNULL(@SoDuGoc, 0) + ISNULL(@LaiTichLuy, 0);

    -- Cập nhật trạng thái sổ tiết kiệm
    UPDATE SOTIETKIEM
    SET TrangThai = N'Đã tất toán'
    WHERE MaSTK = @MaSTK;

    PRINT N'Đã tất toán sổ tiết kiệm ' + @MaSTK;
    PRINT N'Số tiền gốc: ' + CAST(@SoDuGoc AS NVARCHAR(50));
    PRINT N'Lãi tích lũy: ' + CAST(@LaiTichLuy AS NVARCHAR(50));
    PRINT N'Tổng tiền nhận: ' + CAST(@SoTienCuoi AS NVARCHAR(50));
END
GO

-- VÍ DỤ PROCEDURE 4:
EXEC SP_DongSoTietKiem @MaSTK = 'STK01';
GO

SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK01';
GO

-- FUNCTION 1: Tính ngày đáo hạn
CREATE OR ALTER FUNCTION FN_TinhNgayDaoHan
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

-- VÍ DỤ FUNCTION 1:
-- Tính ngày đáo hạn cho sổ mở ngày 2024-01-10, kỳ hạn 6 tháng
SELECT dbo.FN_TinhNgayDaoHan('2024-01-10', 6) AS NgayDaoHan;

-- Tính ngày đáo hạn cho sổ mở ngày 2024-03-15, kỳ hạn 12 tháng
SELECT dbo.FN_TinhNgayDaoHan('2024-03-15', 12) AS NgayDaoHan;
GO

-- FUNCTION 2: Tính lãi đến ngày
CREATE OR ALTER FUNCTION FN_TinhLaiDenNgay
(
    @TienGoc DECIMAL(18,2),
    @LaiSuatNam DECIMAL(5,2),
    @NgayMoSo DATE,
    @NgayTinh DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @SoNgay INT;
    DECLARE @LaiNhanDuoc DECIMAL(18,2);

    -- Tính số ngày giữa hai mốc
    SET @SoNgay = DATEDIFF(DAY, @NgayMoSo, @NgayTinh);

    -- Công thức tính lãi đơn: Lãi = Gốc × Lãi suất × Số ngày / 365
    SET @LaiNhanDuoc = @TienGoc * (@LaiSuatNam / 100) * (@SoNgay / 365.0);

    RETURN ROUND(@LaiNhanDuoc, 2);
END;
GO

-- VÍ DỤ FUNCTION 2:
-- Gửi 10 triệu, lãi suất 5%/năm, từ 01/01/2024 đến 01/07/2024 (6 tháng)
SELECT dbo.FN_TinhLaiDenNgay(10000000, 5.0, '2024-01-01', '2024-07-01') AS LaiNhanDuoc;

-- Gửi 50 triệu, lãi suất 4.5%/năm, từ 01/03/2024 đến 01/03/2025 (1 năm)
SELECT dbo.FN_TinhLaiDenNgay(50000000, 4.5, '2024-03-01', '2025-03-01') AS LaiNhanDuoc;

-- Gửi 100 triệu, lãi suất 6%/năm, từ 15/06/2024 đến 15/09/2024 (3 tháng)
SELECT dbo.FN_TinhLaiDenNgay(100000000, 6.0, '2024-06-15', '2024-09-15') AS LaiNhanDuoc;
GO


-- PHẦN 3: QUẢN LÝ GIAO DỊCH


-- VIEW 5: Giao dịch nộp tiền
CREATE OR ALTER VIEW V_GiaoDichNopTien AS
SELECT 
    GIAODICHNOP.MaGDnop,
    KHACHHANG.TenKH,
    NHANVIEN.TenNV,
    GIAODICHNOP.SoTienNop,
    GIAODICHNOP.NgayGD,
    GIAODICHNOP.HTThanhToan
FROM 
    GIAODICHNOP, SOTIETKIEM, TAIKHOAN, KHACHHANG, NHANVIEN
WHERE 
    GIAODICHNOP.MaSTK = SOTIETKIEM.MaSTK
    AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
    AND TAIKHOAN.MaKH = KHACHHANG.MaKH
    AND GIAODICHNOP.MaNVThucHien = NHANVIEN.MaNV;
GO

-- VIEW 6: Giao dịch rút tiền
CREATE OR ALTER VIEW V_GiaoDichRutTien AS
SELECT 
    GIAODICHRUT.MaGDrut,
    KHACHHANG.TenKH,
    NHANVIEN.TenNV,
    GIAODICHRUT.SoTienRut,
    GIAODICHRUT.NgayGD,
    GIAODICHRUT.LaiNhanDuoc
FROM 
    GIAODICHRUT, SOTIETKIEM, TAIKHOAN, KHACHHANG, NHANVIEN
WHERE 
    GIAODICHRUT.MaSTK = SOTIETKIEM.MaSTK
    AND SOTIETKIEM.MaTK = TAIKHOAN.MaTK
    AND TAIKHOAN.MaKH = KHACHHANG.MaKH
    AND GIAODICHRUT.MaNVThucHien = NHANVIEN.MaNV;
GO

-- PROCEDURE 5: Thêm giao dịch nộp tiền
CREATE OR ALTER PROCEDURE SP_ThemGiaoDichNop
    @MaGDnop CHAR(10),
    @MaSTK CHAR(10),
    @MaNVThucHien CHAR(10),
    @MaLoaiGD CHAR(10),
    @SoTienNop DECIMAL(18,2),
    @NgayGD DATE,
    @HTThanhToan NVARCHAR(50),
    @GhiChu NVARCHAR(255)
AS
BEGIN
    -- Kiểm tra sổ tiết kiệm có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Lỗi: Sổ tiết kiệm không tồn tại';
        RETURN;
    END

    -- Kiểm tra số tiền nộp phải > 0
    IF @SoTienNop <= 0
    BEGIN
        PRINT N'Lỗi: Số tiền nộp phải lớn hơn 0';
        RETURN;
    END

    -- Cập nhật tiền gốc và tiền hiện tại
    UPDATE SOTIETKIEM
    SET 
        TienGoc = TienGoc + @SoTienNop,
        TienHT = TienHT + @SoTienNop
    WHERE MaSTK = @MaSTK;

    -- Ghi nhận giao dịch nộp tiền
    INSERT INTO GIAODICHNOP (MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, 
                             SoTienNop, NgayGD, HTThanhToan, GhiChu)
    VALUES (@MaGDnop, @MaSTK, @MaNVThucHien, @MaLoaiGD,
            @SoTienNop, @NgayGD, @HTThanhToan, @GhiChu);

    PRINT N'Nộp tiền thành công. Số tiền: ' + CAST(@SoTienNop AS NVARCHAR(50));
END;
GO

-- VÍ DỤ PROCEDURE 5:
EXEC SP_ThemGiaoDichNop
    @MaGDnop = 'GDnop11',
    @MaSTK = 'STK02',
    @MaNVThucHien = 'NV01',
    @MaLoaiGD = 'LGD01',
    @SoTienNop = 10000000,
    @NgayGD = '2024-11-01',
    @HTThanhToan = N'Tiền mặt',
    @GhiChu = N'Nộp thêm tiền gửi';
GO

SELECT * FROM GIAODICHNOP WHERE MaGDnop = 'GDnop11';
SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK02';
GO

-- PROCEDURE 6: Thêm giao dịch rút tiền
CREATE OR ALTER PROCEDURE SP_ThemGiaoDichRut
    @MaGDrut CHAR(10),
    @MaSTK CHAR(10),
    @MaNVThucHien CHAR(10),
    @MaLoaiGD CHAR(10),
    @SoTienRut DECIMAL(18,2),
    @NgayGD DATE,
    @LaiSuatApDung DECIMAL(5,2),
    @LaiNhanDuoc DECIMAL(18,2),
    @GhiChu NVARCHAR(255)
AS
BEGIN
    DECLARE @TienHT DECIMAL(18,2);

    -- Lấy tiền hiện tại
    SELECT @TienHT = TienHT 
    FROM SOTIETKIEM 
    WHERE MaSTK = @MaSTK;

    -- Kiểm tra sổ tồn tại
    IF @TienHT IS NULL
    BEGIN
        PRINT N'Lỗi: Sổ tiết kiệm không tồn tại';
        RETURN;
    END

    -- Kiểm tra đủ tiền rút
    IF @TienHT < @SoTienRut
    BEGIN
        PRINT N'Lỗi: Số tiền trong sổ không đủ để rút';
        PRINT N'Tiền hiện tại: ' + CAST(@TienHT AS NVARCHAR(50));
        PRINT N'Số tiền cần rút: ' + CAST(@SoTienRut AS NVARCHAR(50));
        RETURN;
    END

    -- Cập nhật số tiền hiện tại
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - @SoTienRut
    WHERE MaSTK = @MaSTK;

    -- Thêm bản ghi giao dịch rút
    INSERT INTO GIAODICHRUT (MaGDrut, MaSTK, MaNVThucHien, MaLoaiGD,
                             SoTienRut, NgayGD, LaiSuatApDung, LaiNhanDuoc, GhiChu)
    VALUES (@MaGDrut, @MaSTK, @MaNVThucHien, @MaLoaiGD,
            @SoTienRut, @NgayGD, @LaiSuatApDung, @LaiNhanDuoc, @GhiChu);

    PRINT N'Rút tiền thành công. Số tiền: ' + CAST(@SoTienRut AS NVARCHAR(50));
END;
GO

-- VÍ DỤ PROCEDURE 6:
EXEC SP_ThemGiaoDichRut
    @MaGDrut = 'GDrut11',
    @MaSTK = 'STK03',
    @MaNVThucHien = 'NV02',
    @MaLoaiGD = 'LGD02',
    @SoTienRut = 5000000,
    @NgayGD = '2024-11-05',
    @LaiSuatApDung = 5.0,
    @LaiNhanDuoc = 250000,
    @GhiChu = N'Rút một phần tiền gửi';
GO

SELECT * FROM GIAODICHRUT WHERE MaGDrut = 'GDrut11';
SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK03';
GO

-- TRIGGER 2: Tự động cập nhật số dư khi nộp tiền
CREATE OR ALTER TRIGGER TRG_CapNhatSoDuNopTien
ON GIAODICHNOP
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT + inserted.SoTienNop
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi nộp tiền';
END;
GO

-- VÍ DỤ TRIGGER 2:
-- Khi insert vào GIAODICHNOP, trigger sẽ tự động cập nhật TienHT trong SOTIETKIEM
INSERT INTO GIAODICHNOP (MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, SoTienNop, NgayGD, HTThanhToan)
VALUES ('GDnop12', 'STK04', 'NV01', 'LGD01', 8000000, '2024-11-10', N'Chuyển khoản');
GO

SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK04';
GO

-- TRIGGER 3: Tự động cập nhật số dư khi rút tiền
CREATE OR ALTER TRIGGER TRG_CapNhatSoDuRutTien
ON GIAODICHRUT
AFTER INSERT
AS
BEGIN
    UPDATE SOTIETKIEM
    SET TienHT = TienHT - inserted.SoTienRut
    FROM SOTIETKIEM, inserted
    WHERE SOTIETKIEM.MaSTK = inserted.MaSTK;

    PRINT N'Đã cập nhật số dư sổ tiết kiệm sau khi rút tiền';
END;
GO

-- VÍ DỤ TRIGGER 3:
-- Khi insert vào GIAODICHRUT, trigger sẽ tự động cập nhật TienHT trong SOTIETKIEM
INSERT INTO GIAODICHRUT (MaGDrut, MaSTK, MaNVThucHien, MaLoaiGD, SoTienRut, NgayGD, LaiSuatApDung, LaiNhanDuoc)
VALUES ('GDrut12', 'STK05', 'NV02', 'LGD02', 3000000, '2024-11-12', 4.8, 150000);
GO

SELECT * FROM SOTIETKIEM WHERE MaSTK = 'STK05';
GO


-- PHẦN 4: QUẢN LÝ BÁO CÁO


-- VIEW 7: Báo cáo chi tiết
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

-- VIEW 8: Báo cáo tổng hợp
CREATE OR ALTER VIEW V_BaoCaoTongHop AS
SELECT 
    COUNT(MaSTK) AS TongSoSTK,
    SUM(TongTienGui) AS TongTienGui,
    SUM(TongLaiNhan) AS TongLaiNhan
FROM BAOCAO;
GO

-- PROCEDURE 7: Tổng hợp báo cáo sổ tiết kiệm
CREATE OR ALTER PROCEDURE SP_TongHopBaoCaoSoTietKiem
    @MaSTK CHAR(10),
    @MaBaoCao CHAR(10),
    @MaNVTao CHAR(10) = NULL
AS
BEGIN
    DECLARE @SoDuGoc DECIMAL(18,2);
    DECLARE @LaiTichLuy DECIMAL(18,2);
    DECLARE @SoDuThucTe DECIMAL(18,2);

    -- Kiểm tra sổ tiết kiệm tồn tại
    IF NOT EXISTS (SELECT * FROM SOTIETKIEM WHERE MaSTK = @MaSTK)
    BEGIN
        PRINT N'Lỗi: Sổ tiết kiệm không tồn tại';
        RETURN;
    END

    -- Lấy số dư gốc và lãi tích lũy từ bảng số dư
    SELECT TOP 1 
        @SoDuGoc = SoDuGoc, 
        @LaiTichLuy = LaiTichLuy, 
        @SoDuThucTe = SoDuThucTe
    FROM BANGSODU
    WHERE MaSTK = @MaSTK
    ORDER BY NgayCapNhat DESC;

    -- Nếu không có trong bảng số dư, lấy từ sổ tiết kiệm
    IF @SoDuGoc IS NULL
    BEGIN
        SELECT @SoDuGoc = TienGoc FROM SOTIETKIEM WHERE MaSTK = @MaSTK;
    END

    -- Nếu không có lãi tích lũy, tính từ bảng tính lãi
    IF @LaiTichLuy IS NULL
    BEGIN
        SELECT @LaiTichLuy = SUM(ISNULL(LaiTichLuy, 0)) 
        FROM BANGTINHLAI 
        WHERE MaSTK = @MaSTK;
    END

    -- Tính số dư thực tế
    SET @SoDuThucTe = ISNULL(@SoDuGoc, 0) + ISNULL(@LaiTichLuy, 0);

    -- Thêm báo cáo
    INSERT INTO BAOCAO (MaBaoCao, MaSTK, MaNVTao, NgayBaoCao, LoaiBaoCao, 
                        TongTienGui, TongLaiNhan, SoDuHienTai)
    VALUES (@MaBaoCao, @MaSTK, @MaNVTao, GETDATE(), N'Tổng hợp',
            @SoDuGoc, @LaiTichLuy, @SoDuThucTe);

    PRINT N'Đã tạo báo cáo sổ tiết kiệm cho ' + @MaSTK;
    PRINT N'Số dư gốc: ' + CAST(@SoDuGoc AS NVARCHAR(50));
    PRINT N'Lãi tích lũy: ' + CAST(@LaiTichLuy AS NVARCHAR(50));
    PRINT N'Số dư thực tế: ' + CAST(@SoDuThucTe AS NVARCHAR(50));
END
GO

-- VÍ DỤ PROCEDURE 7:
EXEC SP_TongHopBaoCaoSoTietKiem 
    @MaSTK = 'STK02',
    @MaBaoCao = 'BC11',
    @MaNVTao = 'NV01';
GO

SELECT * FROM BAOCAO WHERE MaBaoCao = 'BC11';
GO


-- PHẦN 5: CÁC FUNCTION BỔ SUNG

-- FUNCTION 4: Kiểm tra sổ tiết kiệm đã đáo hạn chưa
CREATE OR ALTER FUNCTION FN_KiemTraDaoHan
(
    @MaSTK CHAR(10),
    @NgayKiemTra DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @NgayDaoHan DATE;
    DECLARE @KetQua BIT;

    SELECT @NgayDaoHan = NgayDaoHan
    FROM SOTIETKIEM
    WHERE MaSTK = @MaSTK;

    IF @NgayDaoHan IS NULL
        SET @KetQua = 0;
    ELSE IF @NgayKiemTra >= @NgayDaoHan
        SET @KetQua = 1;  -- Đã đáo hạn
    ELSE
        SET @KetQua = 0;  -- Chưa đáo hạn

    RETURN @KetQua;
END;
GO

-- VÍ DỤ FUNCTION 4:
-- Kiểm tra sổ STK01 đã đáo hạn chưa tại ngày 01/07/2023
SELECT dbo.FN_KiemTraDaoHan('STK01', '2023-07-01') AS DaDaoHan;

-- Kiểm tra sổ STK01 đã đáo hạn chưa tại ngày 01/05/2023
SELECT dbo.FN_KiemTraDaoHan('STK01', '2023-05-01') AS DaDaoHan;

-- Xem danh sách sổ đã đáo hạn tại ngày hiện tại
SELECT 
    SOTIETKIEM.MaSTK,
    KHACHHANG.TenKH,
    SOTIETKIEM.NgayDaoHan,
    CASE 
        WHEN dbo.FN_KiemTraDaoHan(SOTIETKIEM.MaSTK, GETDATE()) = 1 
        THEN N'Đã đáo hạn' 
        ELSE N'Chưa đáo hạn' 
    END AS TrangThaiDaoHan
FROM SOTIETKIEM, TAIKHOAN, KHACHHANG
WHERE SOTIETKIEM.MaTK = TAIKHOAN.MaTK
    AND TAIKHOAN.MaKH = KHACHHANG.MaKH
    AND SOTIETKIEM.TrangThai = N'Đang hoạt động';
GO


-- PHẦN 6: TRIGGER BỔ SUNG


-- TRIGGER 4: Kiểm tra số tiền gửi tối thiểu khi mở sổ
CREATE OR ALTER TRIGGER TRG_KiemTraTienGuiToiThieu
ON SOTIETKIEM
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @TienGoc DECIMAL(18,2);
    DECLARE @MaSTK CHAR(10);

    SELECT @TienGoc = TienGoc, @MaSTK = MaSTK
    FROM inserted;

    -- Kiểm tra số tiền gửi tối thiểu 100,000đ
    IF @TienGoc < 100000
    BEGIN
        PRINT N'Lỗi: Số tiền gửi tối thiểu phải từ 100,000đ trở lên';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Cho phép insert
    INSERT INTO SOTIETKIEM (MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                            TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
    SELECT MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
           TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai
    FROM inserted;

    PRINT N'Đã tạo sổ tiết kiệm thành công';
END;
GO

-- VÍ DỤ TRIGGER 4:
-- Thử tạo sổ với số tiền < 100,000 (sẽ bị từ chối)
INSERT INTO SOTIETKIEM (MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                        TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
VALUES ('STK99', 'TKNH01', 'NV01', 'LHTK01', 'HTTL01', 'HTG01',
        50000, 50000, GETDATE(), DATEADD(MONTH, 3, GETDATE()), N'Đang hoạt động');
GO

-- Thử tạo sổ với số tiền >= 100,000 (sẽ thành công)
INSERT INTO SOTIETKIEM (MaSTK, MaTK, MaNVTao, MaLoaiHinh, MaHTTraLai, MaHTGui,
                        TienGoc, TienHT, NgayMoSo, NgayDaoHan, TrangThai)
VALUES ('STK12', 'TKNH01', 'NV01', 'LHTK01', 'HTTL01', 'HTG01',
        5000000, 5000000, GETDATE(), DATEADD(MONTH, 3, GETDATE()), N'Đang hoạt động');
GO

-- TRIGGER 5: Tự động cập nhật bảng số dư khi có giao dịch
CREATE OR ALTER TRIGGER TRG_TuDongCapNhatBangSoDu
ON GIAODICHNOP
AFTER INSERT
AS
BEGIN
    DECLARE @MaSTK CHAR(10);
    DECLARE @SoTienNop DECIMAL(18,2);
    DECLARE @SoDuGocMoi DECIMAL(18,2);

    SELECT @MaSTK = MaSTK, @SoTienNop = SoTienNop
    FROM inserted;

    -- Lấy số dư gốc hiện tại
    SELECT TOP 1 @SoDuGocMoi = SoDuGoc + @SoTienNop
    FROM BANGSODU
    WHERE MaSTK = @MaSTK
    ORDER BY NgayCapNhat DESC;

    -- Nếu chưa có bản ghi, lấy từ SOTIETKIEM
    IF @SoDuGocMoi IS NULL
    BEGIN
        SELECT @SoDuGocMoi = TienGoc
        FROM SOTIETKIEM
        WHERE MaSTK = @MaSTK;
    END

    -- Cập nhật hoặc thêm mới bảng số dư
    IF EXISTS (SELECT 1 FROM BANGSODU WHERE MaSTK = @MaSTK)
    BEGIN
        UPDATE BANGSODU
        SET SoDuGoc = @SoDuGocMoi,
            NgayCapNhat = GETDATE()
        WHERE MaSTK = @MaSTK;
    END
    ELSE
    BEGIN
        INSERT INTO BANGSODU (MaSoDu, MaSTK, SoDuGoc, LaiTichLuy, NgayCapNhat)
        VALUES ('BSD_' + @MaSTK, @MaSTK, @SoDuGocMoi, 0, GETDATE());
    END

    PRINT N'Đã cập nhật bảng số dư cho sổ ' + @MaSTK;
END;
GO

-- VÍ DỤ TRIGGER 5:
-- Khi thêm giao dịch nộp tiền, trigger sẽ tự động cập nhật BANGSODU
INSERT INTO GIAODICHNOP (MaGDnop, MaSTK, MaNVThucHien, MaLoaiGD, SoTienNop, NgayGD, HTThanhToan)
VALUES ('GDnop13', 'STK06', 'NV01', 'LGD01', 15000000, '2024-11-15', N'Tiền mặt');
GO

SELECT * FROM BANGSODU WHERE MaSTK = 'STK06';
GO
