USE BANHANG;
GO

-- 1. Viết hàm fc_Cau1 có kiểu dữ liệu trả về là int, nhập vào 1 mã vật tư, tìm xem giá mua của vật tư này là bao nhiêu.
-- Kết quả trả về cho hàm là giá mua tìm được.
CREATE FUNCTION fc_Cau1(@MaVT NVARCHAR(5)) RETURNS INT AS
BEGIN
    DECLARE @GiaMua INT;
    SELECT @GiaMua = GIAMUA FROM VATTU WHERE MAVT = @MaVT;
    RETURN @GiaMua;
END
GO

-- 2. Viết hàm fc_Cau2 có kiểu dữ liệu trả về là nvarchar(30), nhập vào 1 mã khách hàng, tìm xem khách hàng này có tên là gì.
-- Kết quả trả về cho hàm là tên khách hàng tìm được.
CREATE FUNCTION fc_Cau2(@MaKH NVARCHAR(5)) RETURNS NVARCHAR(30) AS
BEGIN
    DECLARE @TenKH NVARCHAR(30);
    SELECT @TenKH = TENKH FROM KHACHHANG WHERE MAKH = @MaKH;
    RETURN @TenKH;
END
GO

-- 3. Viết hàm fc_Cau3 có kiểu dữ liệu trả về là int, nhập vào 1 mã khách hàng rồi đếm xem khách hàng này đã mua tổng cộng bao nhiêu tiền.
-- Kết quả trả về cho hàm là tổng số tiền mà khách hàng đã mua.
CREATE FUNCTION fc_Cau3(@MaKH NVARCHAR(5)) RETURNS INT AS
BEGIN
    DECLARE @Total INT = 0;

    SELECT @Total = SUM(TONGTG)
    FROM HOADON
    WHERE MAKH = @MaKH
    GROUP BY MAKH

    RETURN @Total;
END
GO

-- 4. Viết hàm fc_Cau4 có kiểu dữ liệu trả về là nvarchar(5), tìm xem vật tư nào là vật tư bán được nhiều nhất (nhiều tiền nhất).
-- Kết quả trả về cho hàm là mã của vật tư này (trường hợp có nhiều vật tư cùng bán được nhiều nhất, chỉ cần trả về 1 mã bất kỳ trong số đó).
CREATE FUNCTION GetTotalSaleOfMaterial(@MaVT NVARCHAR(5)) RETURNS INT AS
BEGIN
	DECLARE @Total INT = 0;
	SELECT @Total += SL * GIABAN FROM CHITIETHOADON WHERE MAVT = @MaVT;
	RETURN @Total
END
GO

CREATE FUNCTION fc_Cau4() RETURNS NVARCHAR(5) AS
BEGIN
    DECLARE @maxSale INT = 0;
    DECLARE @maxMaVT NVARCHAR(5);

	DECLARE @Cursor CURSOR;
	SET @Cursor = CURSOR FOR SELECT MAVT FROM VATTU;

	DECLARE @MaVT NVARCHAR(5);

	OPEN @Cursor FETCH NEXT FROM @Cursor INTO @MaVT;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @Total INT = dbo.GetTotalSaleOfMaterial(@MaVT);

		IF @maxSale < @Total
		BEGIN
			SET @maxSale = @Total;
			SET @maxMaVT = @MaVT;
		END

		
		FETCH NEXT FROM @Cursor INTO @MaVT
	END

    RETURN @maxMaVT;
END
GO
