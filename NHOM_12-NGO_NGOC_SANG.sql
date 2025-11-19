USE master;
GO
IF EXISTS(SELECT * FROM sysdatabases WHERE name='QLRAPPHIM')
    DROP DATABASE QLRAPPHIM;
GO

CREATE DATABASE QLRAPPHIM;
GO

USE QLRAPPHIM;
GO


-- BẢNG PHIM
CREATE TABLE PHIM (
    MaPhim        INT IDENTITY(1,1) PRIMARY KEY,
    TenPhim       NVARCHAR(100) NOT NULL,
    TheLoai       NVARCHAR(50)  NOT NULL,
    ThoiGianChieu INT NOT NULL CHECK (ThoiGianChieu > 0),
    MoTa          NVARCHAR(255)
);
GO

-- BẢNG RẠP CHIẾU
CREATE TABLE RAPCHIEU (
    MaRap   INT IDENTITY(1,1) PRIMARY KEY,
    TenRap  NVARCHAR(100) NOT NULL,
    DiaChi  NVARCHAR(200) NOT NULL
);
GO

-- BẢNG LỊCH CHIẾU
CREATE TABLE LICHCHIEU (
    MaLichChieu INT IDENTITY(1,1) PRIMARY KEY,
    MaPhim      INT NOT NULL,
    MaRap       INT NOT NULL,
    NgayChieu   DATE NOT NULL,
    GioChieu    TIME(0) NOT NULL,

    FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim),
    FOREIGN KEY (MaRap)  REFERENCES RAPCHIEU(MaRap),

    UNIQUE (MaRap, NgayChieu, GioChieu) 
);
GO

-- BẢNG KHÁCH HÀNG
CREATE TABLE KHACHHANG (
    MaKhachHang  INT IDENTITY(1,1) PRIMARY KEY,
    TenKhachHang NVARCHAR(100) NOT NULL,
    SDT          VARCHAR(15)   NOT NULL,

    UNIQUE (SDT) 
);
GO

-- BẢNG ĐẶT VÉ
CREATE TABLE DATVE (
    MaDatVe      INT IDENTITY(1,1) PRIMARY KEY,
    MaKhachHang  INT NOT NULL,
    MaLichChieu  INT NOT NULL,
    SoGhe        INT NOT NULL CHECK (SoGhe > 0),
    NgayDat      DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (MaKhachHang) REFERENCES KHACHHANG(MaKhachHang),
    FOREIGN KEY (MaLichChieu) REFERENCES LICHCHIEU(MaLichChieu),

    UNIQUE (MaLichChieu, SoGhe) 
);
GO



-- PHIM
INSERT INTO PHIM (TenPhim, TheLoai, ThoiGianChieu, MoTa) VALUES
(N'Bão Đêm', N'Hành động', 110, N'Phim hành động Việt Nam'),
(N'Ánh Trăng', N'Tâm lý', 125, N'Phim tâm lý tình cảm'),
(N'Lạc Giữa Sao Trời', N'Khoa học viễn tưởng', 138, N'Phim về vũ trụ'),
(N'Gõ Cửa Trái Tim', N'Romance', 102, N'Chuyện tình lãng mạn'),
(N'Kẻ Theo Dõi', N'Kinh dị', 95, N'Trinh thám - kinh dị'),
(N'Nhật Ký Tuổi 18', N'Học đường', 105, N'Tuổi học trò'),
(N'Xứ Sở Diệu Kỳ', N'Hoạt hình', 99, N'Phim hoạt hình thiếu nhi');
GO

-- RẠP
INSERT INTO RAPCHIEU (TenRap, DiaChi) VALUES
(N'CGV Royal City', N'72A Nguyễn Trãi, Thanh Xuân, Hà Nội'),
(N'BHD Phạm Ngọc Thạch', N'02 Phạm Ngọc Thạch, Đống Đa'),
(N'Lotte Landmark', N'Keangnam, Nam Từ Liêm');
GO

-- LỊCH CHIẾU
INSERT INTO LICHCHIEU (MaPhim, MaRap, NgayChieu, GioChieu) VALUES
(1, 1, CONVERT(date, DATEADD(DAY, 1, GETDATE())), '18:30'),
(2, 1, CONVERT(date, DATEADD(DAY, 1, GETDATE())), '21:00'),
(3, 2, CONVERT(date, DATEADD(DAY, 2, GETDATE())), '19:00'),
(4, 3, CONVERT(date, DATEADD(DAY, 1, GETDATE())), '17:00'),
(5, 3, CONVERT(date, DATEADD(DAY, 3, GETDATE())), '20:30');
GO

-- KHÁCH HÀNG
INSERT INTO KHACHHANG (TenKhachHang, SDT) VALUES
(N'Ngô Ngọc Sang', '0912345678'),
(N'Trần Minh An', '0987654321'),
(N'Nguyễn Lan', '0901122334'),
(N'Phạm Thu Thảo', '0933112244'),
(N'Lê Tuấn Anh', '0977778888');
GO

-- ĐẶT VÉ
INSERT INTO DATVE (MaKhachHang, MaLichChieu, SoGhe) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(1, 2, 5),
(4, 3, 10),
(5, 3, 11),
(2, 4, 7),
(3, 5, 4);
GO


--CHỈ MỤC
CREATE INDEX IX_LICHCHIEU_Ngay_Rap   ON LICHCHIEU(NgayChieu, MaRap);
CREATE INDEX IX_DATVE_MaLich         ON DATVE(MaLichChieu);
CREATE INDEX IX_KHACHHANG_SDT        ON KHACHHANG(SDT);
GO



CREATE VIEW v_LichChieuChiTiet AS
SELECT 
    lc.MaLichChieu,
    p.TenPhim,
    p.TheLoai,
    r.TenRap,
    r.DiaChi,
    lc.NgayChieu,
    lc.GioChieu
FROM LICHCHIEU lc
JOIN PHIM p ON p.MaPhim = lc.MaPhim
JOIN RAPCHIEU r ON r.MaRap = lc.MaRap;
GO

CREATE VIEW v_VeKhachHang AS
SELECT
    dv.MaDatVe,
    kh.TenKhachHang,
    kh.SDT,
    p.TenPhim,
    lc.NgayChieu,
    lc.GioChieu,
    dv.SoGhe,
    dv.NgayDat
FROM DATVE dv
JOIN KHACHHANG kh ON kh.MaKhachHang = dv.MaKhachHang
JOIN LICHCHIEU lc ON lc.MaLichChieu = dv.MaLichChieu
JOIN PHIM p ON p.MaPhim = lc.MaPhim;
GO



--THỦ TỤC
-- Tìm phim theo thể loại
CREATE PROCEDURE sp_TimPhimTheoTheLoai
    @TheLoai NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM PHIM
    WHERE TheLoai = @TheLoai;
END;
GO

-- Báo cáo vé theo ngày chiếu
CREATE PROCEDURE sp_BaoCaoVeTheoNgayChieu
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.TenPhim,
        lc.NgayChieu,
        COUNT(dv.MaDatVe) AS SoVeDaDat
    FROM LICHCHIEU lc
    JOIN PHIM p ON p.MaPhim = lc.MaPhim
    LEFT JOIN DATVE dv ON dv.MaLichChieu = lc.MaLichChieu
    WHERE lc.NgayChieu BETWEEN @TuNgay AND @DenNgay
    GROUP BY p.TenPhim, lc.NgayChieu
    ORDER BY lc.NgayChieu, p.TenPhim;
END;
GO


CREATE FUNCTION fn_SoVeTheoLich (@MaLichChieu INT)
RETURNS INT
AS
BEGIN
    DECLARE @SoVe INT;
    SELECT @SoVe = COUNT(*) FROM DATVE WHERE MaLichChieu = @MaLichChieu;
    RETURN ISNULL(@SoVe, 0);
END;
GO


CREATE TRIGGER trg_KhongDatVeSauGioChieu
ON DATVE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LICHCHIEU lc ON lc.MaLichChieu = i.MaLichChieu
        WHERE GETDATE() >
              CAST(CONVERT(VARCHAR(10), lc.NgayChieu, 120) + ' ' +
                   CONVERT(VARCHAR(8), lc.GioChieu, 108) AS DATETIME)
    )
    BEGIN
        RAISERROR (N'Không được đặt vé sau giờ chiếu.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


USE master;
GO

IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name='RapUser')
BEGIN
    CREATE LOGIN RapUser WITH PASSWORD='RapUser@123', CHECK_POLICY=OFF;
END
GO

USE QLRAPPHIM;
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name='RapUser')
    CREATE USER RapUser FOR LOGIN RapUser;
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name='RapNhanVien')
    CREATE ROLE RapNhanVien;
GO

GRANT SELECT ON PHIM TO RapNhanVien;
GRANT SELECT ON RAPCHIEU TO RapNhanVien;
GRANT SELECT ON LICHCHIEU TO RapNhanVien;
GRANT SELECT, INSERT ON DATVE TO RapNhanVien;
GRANT SELECT ON v_LichChieuChiTiet TO RapNhanVien;
GRANT SELECT ON v_VeKhachHang TO RapNhanVien;
GO

ALTER ROLE RapNhanVien ADD MEMBER RapUser;
GO


--TEST
--VIEW
PRINT N'===== TEST VIEW v_LichChieuChiTiet =====';
SELECT * FROM v_LichChieuChiTiet;
GO

PRINT N'===== TEST VIEW v_VeKhachHang =====';
SELECT * FROM v_VeKhachHang;
GO


--CHỈ MỤC
PRINT N'===== TEST INDEX IX_KHACHHANG_SDT (tìm theo SDT) =====';
SELECT * FROM KHACHHANG WHERE SDT = '0912345678';
GO

PRINT N'===== TEST INDEX IX_DATVE_MaLich (tìm vé theo mã lịch chiếu) =====';
SELECT * FROM DATVE WHERE MaLichChieu = 1;
GO

PRINT N'===== TEST INDEX IX_LICHCHIEU_Ngay_Rap (tìm lịch theo ngày + rạp) =====';
SELECT * 
FROM LICHCHIEU
WHERE NgayChieu = CONVERT(date, DATEADD(DAY, 1, GETDATE()))
  AND MaRap = 1;
GO


--THỦ TỤC
PRINT N'===== TEST PROC sp_TimPhimTheoTheLoai =====';
EXEC sp_TimPhimTheoTheLoai N'Hành động';
GO

PRINT N'===== TEST PROC sp_BaoCaoVeTheoNgayChieu =====';
DECLARE @TuNgay DATE = '2025-11-10';  
DECLARE @DenNgay DATE = '2025-11-30';  

EXEC sp_BaoCaoVeTheoNgayChieu @TuNgay, @DenNgay;
GO


--HÀM
PRINT N'===== TEST FUNCTION fn_SoVeTheoLich (trả về số vé theo từng lịch) =====';
SELECT 
    lc.MaLichChieu,
    p.TenPhim,
    lc.NgayChieu,
    lc.GioChieu,
    dbo.fn_SoVeTheoLich(lc.MaLichChieu) AS SoVeDaDat
FROM LICHCHIEU lc
JOIN PHIM p ON p.MaPhim = lc.MaPhim;
GO


--TRIGGER
INSERT INTO LICHCHIEU VALUES (1, 1, '2020-11-11', '08:00');
INSERT INTO DATVE (MaKhachHang, MaLichChieu, SoGhe)
SELECT 1, MAX(MaLichChieu), 99 FROM LICHCHIEU;


BACKUP DATABASE QLRAPPHIM
TO DISK = 'D:\'   
WITH INIT, STATS = 5;
GO