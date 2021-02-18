USE BANHANG;
GO

-- 1. Viết câu lệnh tạo SP có tên sp_Cau1 cập nhật thông tin TONGGT trong bảng HOADON theo dữ liệu thực tế trong bảng CHITIETHOADON.
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

-- 2. Viết câu lệnh tạo hàm (function) có tên fc_Cau3 có kiểu dữ liệu trả về là INT, nhập vào 1 mã khách hàng rồi 
-- đếm xem khách hàng này đã mua tổng cộng bao nhiêu tiền. Kết quả trả về của hàm là số tiền mà khách hàng đã mua.
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

-- 3. Viết câu lệnh tạo hàm fc_cau4 có kiểu dữ liệu trả về là NVARCHAR(5), tìm xem vật tư nào là vật tư bán được nhiều tiền nhất. 
-- Kết quả trả về cho hàm là mã của vật tư này. Trong trường hợp có nhiều vật tư cùng bán được số tiền nhiều nhất như nhau,
-- chỉ cần trả về mã của một trong số các vật tư này.
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

-- 4. Viết câu lệnh tạo SP có sp_Cau5, có hai tham số kiểu output là @MaVT NVARCHAR(5) và @TenVT NVARCHAR(30) để trả về mã 
-- và tên của vật tư bán được nhiều tiền nhất. Trong trường hợp có nhiều vật tư cùng bán được số tiền nhiều nhất như nhau, 
-- chỉ cần trả về mã và tên của một trong số các vật tư này.
CREATE PROCEDURE sp_Cau5(@MaVT NVARCHAR(5) OUTPUT, @TenVT NVARCHAR(30) OUTPUT) AS
BEGIN
	EXEC @MaVT = fc_Cau4;
	SELECT @TenVT = TENVT FROM VATTU WHERE MAVT = @MaVT;
END
GO

-- 5. Viết câu lệnh tạo trigger có tên tg_Cau6 để đảm bảo ràng buộc: nếu cập nhật giá mua của vật tư (trong bảng VATTU) 
-- thì chỉ có thể cập nhật tăng, không được cập nhật giảm giá.
CREATE TRIGGER tg_OnlyIncreaseSellingPrice
ON CHITIETHOADON
AFTER UPDATE
AS
BEGIN
    DECLARE @OldSellingPrice INT, @NewSellingPrice INT;
    SELECT @OldSellingPrice = GIABAN FROM deleted;
    SELECT @NewSellingPrice = GIABAN FROM inserted;

    IF @NewSellingPrice < @OldSellingPrice
        RAISERROR(N'Gia ban moi khong duoc thap hon gia ban cu: %d', 18, -1, @OldSellingPrice);
END
GO

-- 6. Viết câu lệnh tạo trigger có tên tg_Cau7 để đảm bảo ràng buộc: khi thêm một hóa đơn vào CSDL, cần đảm bảo khách 
-- hàng đã mua hóa đơn này đã có trong bảng KHACHHANG. Trường hợp khách hàng chưa có trong bảng khách hàng, hãy thêm 
-- thông tin khách hàng vào bảng KHACHHANG trước. Trong đó, KHACHHANG sẽ có tên và mã số giống nhau, chính là 
-- mã số khách hàng trong thông tin hóa đơn. Các thông tin còn lại của khách hàng lấy giá trị NULL.

-- Bởi vì table HOADON có sẵn foreign key constraint cho MAKH nên phải xóa nó đi thì trigger mới chơi được:
ALTER TABLE HOADON DROP CONSTRAINT FK_HOADON_MAKH;
GO

CREATE TRIGGER tg_Cau7 ON HOADON
AFTER INSERT
AS
BEGIN
	DECLARE @MaKH NVARCHAR(5);

	SELECT @MaKH = MAKH FROM inserted;

	IF NOT EXISTS(SELECT * FROM KHACHHANG WHERE MAKH = @MaKH)
		BEGIN
			INSERT INTO KHACHHANG(MAKH, TENKH) VALUES (@MaKH, @MaKH);
		END
END
GO

-- 7. Hãy viết một Transaction, đảm bảo thực hiện việc xóa thông tin về một hóa đơn sẽ xóa đồng thời thông tin 
-- về hóa đơn này trong cả hai bảng CHITIETHOADON và HOADON.
BEGIN TRAN
	DECLARE @MaHD NVARCHAR(10) = 'HD001';

	DELETE FROM CHITIETHOADON WHERE MAHD = @MaHD;
	DELETE FROM HOADON WHERE MAHD = @MaHD;
COMMIT TRAN
