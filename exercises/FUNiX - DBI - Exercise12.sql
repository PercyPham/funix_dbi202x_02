USE BANHANG;
GO

-- 1. Giá bán của một vật tư bất kỳ cần lớn hơn hoặc bằng giá mua của sản phẩm đó.
CREATE TRIGGER tg_GiaBanGreaterThanGiaMua
    ON CHITIETHOADON
    AFTER INSERT
    AS
BEGIN
    DECLARE @MaVT NVARCHAR(5);
    DECLARE @GiaBan INT;
    DECLARE @GiaMua INT;
    SELECT @MaVT = MAVT, @GiaBan = GIABAN FROM inserted;
    SELECT @GiaMua = GIAMUA FROM VATTU WHERE MAVT = @MaVT;

    IF @GiaBan < @GiaMua
        RAISERROR (N'Selling price cannot be lower than buying price: %d', 18, -1, @GiaMua);
END
GO

-- 2. Mỗi khi một vật tư được bán ra với một số lượng nào đó, thì thuộc tính SLTon trong bảng VATTU cần giảm đi tương ứng.
CREATE TRIGGER tg_GiamSLTonKhiBan
    ON CHITIETHOADON
    AFTER INSERT
    AS
BEGIN
    DECLARE @MaVT NVARCHAR(5);
    DECLARE @Quantity INT;
    DECLARE @OldStock INT;
    SELECT @MaVT = MAVT, @Quantity = SL FROM inserted;
    SELECT @OldStock = SLTON FROM VATTU WHERE MAVT = @MaVT;

    DECLARE @NewStock INT = @OldStock - @Quantity;

    IF @NewStock < 0
        RAISERROR (N'So luong ton hien tai khong du: %d', 18, -1, @OldStock);

    UPDATE VATTU
    SET SLTON = @NewStock
    WHERE MAVT = @MaVT;
END


-- 3. Đảm bảo giá bán của một sản phẩm bất kỳ, chỉ có thể cập nhật tăng, không thể cập nhật giảm.
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

-- 4. Mỗi khi có sự thay đổi về vật tư được bán trong một hóa đơn nào đó, thuộc tính TONGGT trong bảng HOADON được cập nhật tương ứng.
CREATE TRIGGER tg_UpdateTotalPriceOfOrder
ON CHITIETHOADON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @MaHD NVARCHAR(10);
    DECLARE @Total INT = 0;
    SELECT @MaHD = MAHD FROM deleted;
    SELECT @MaHD = COALESCE(@MaHD, MAHD) FROM inserted;
    SELECT @Total += (SL * GIABAN) FROM CHITIETHOADON WHERE MAHD = @MaHD;
    UPDATE HOADON SET TONGTG=@Total WHERE MAHD=@MaHD;
END
