USE BANHANG;

-- 1. Viết procedure sp_Cau1 cập nhật thông tin TONGGT trong bảng hóa đơn theo dữ liệu thực tế của bảng CHITIETHOADON
CREATE PROCEDURE GetTotal(@MaHD NVARCHAR(10), @Total INT OUTPUT) AS
BEGIN
    SET @Total = 0;
    SELECT @Total += SL * GIABAN FROM CHITIETHOADON WHERE MAHD = @MaHD;
END
GO

CREATE PROCEDURE sp_Cau1 AS
BEGIN
    DECLARE @MaHD NVARCHAR(10);

    SET rowcount 0;
    SELECT * INTO #tempTbl FROM HOADON;

    SET rowcount 1;

    SELECT @MaHD = MAHD FROM #tempTbl

    WHILE @@ROWCOUNT <> 0
        BEGIN
            SET rowcount 0

            DECLARE @Total INT = 0;
            EXEC GetTotal @MaHD, @Total OUTPUT;
            UPDATE HOADON SET TONGTG = @Total WHERE MAHD = @MaHD;

            DELETE #tempTbl WHERE MAHD = @MaHD

            SET rowcount 1
            SELECT @MaHD = MAHD FROM #tempTbl
        END
END
GO

-- 2. Viết procedure sp_Cau2 có đầu vào là số điện thoại, kiểm tra xem đã có khách hàng có số điện thoại này trong CSDL chưa?
-- Hiện thông báo (bằng lệnh print) để nêu rõ đã có/ chưa có khách hàng này.
CREATE PROCEDURE sp_Cau2(@Phone NVARCHAR(10)) AS
BEGIN
    IF EXISTS(SELECT * FROM KHACHHANG WHERE DT = @Phone)
        PRINT 'Customer with phone number ' + @Phone + ' does exist.'
    ELSE
        PRINT 'Customer with phone number ' + @Phone + ' does NOT exist.'
END
GO

-- 3. Viết procedure sp_Cau3 có đầu vào là mã khách hàng, hãy tính tổng số tiền mà khách hàng này đã mua trong toàn hệ thống,
-- kết quả trả về trong một tham số kiểu output.
CREATE PROCEDURE sp_Cau3(@MaKH NVARCHAR(5), @Total INT OUTPUT) AS
BEGIN
    SET @Total = 0;
    SELECT @Total += TONGTG FROM HOADON WHERE MAKH = @MaKH;
END
GO

-- 4. Viết procedure sp_Cau4 có hai tham số kiểu output là @mavt nvarchar(5) và @tenvt nvarchar(30) để trả về mã
-- và tên của vật tư đã bán được nhiều nhất (được tổng tiền nhiều nhất).
CREATE PROCEDURE sp_Cau4(@mavt nvarchar(5) OUTPUT, @tenvt nvarchar(30) OUTPUT) AS
BEGIN
    DECLARE @iMaVT NVARCHAR(5);
    DECLARE @maxMaVT NVARCHAR(5);
    DECLARE @maxSale INT;

    SET rowcount 0;
    SELECT * INTO #tempTbl FROM VATTU;

    SET rowcount 1;

    SELECT @iMaVT = MAVT FROM #tempTbl

    WHILE @@ROWCOUNT <> 0
        BEGIN
            SET rowcount 0

            DECLARE @TotalSale INT = 0;
            SELECT @TotalSale += SL * GIABAN FROM CHITIETHOADON WHERE MAVT = @iMaVT;

            IF @maxMaVT IS NULL SET @maxMaVT = @iMaVT;
            IF @maxSale IS NULL SET @maxSale = @TotalSale;

            IF @TotalSale > @maxSale
                BEGIN
                    SET @maxSale = @TotalSale;
                    SET @maxMaVT = @iMaVT;
                END

            DELETE #tempTbl WHERE MAVT = @iMaVT

            SET rowcount 1
            SELECT @iMaVT = MAVT FROM #tempTbl
        END

    SET @mavt = @maxMaVT;
    SELECT @tenvt = TENVT FROM VATTU WHERE MAVT = @maxMaVT;
END
GO
