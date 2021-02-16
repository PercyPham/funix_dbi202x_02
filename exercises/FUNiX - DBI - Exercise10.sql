-- 1. Trường GiaMua trong bảng VATTU
CREATE NONCLUSTERED INDEX idx_GiaMua on VATTU(GIAMUA);
GO

-- 2. Trường SLTon trong bảng VATTU
CREATE NONCLUSTERED INDEX idx_SLTon on VATTU(SLTON);
GO

-- 3. Trường Ngay trong bảng HOADON.
CREATE NONCLUSTERED INDEX idx_Ngay on HOADON(NGAY);
GO
