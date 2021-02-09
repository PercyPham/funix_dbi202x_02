-- 1) Hiển danh sách tất cả các khách hàng 
-- gồm mã khách hàng, tên khách hàng, địa chỉ, điện thoại, và địa chỉ E-mail
SELECT *
FROM KHACHHANG;
GO

-- 2) Hiển danh sách các khách hàng có địa chỉ là “TAN BINH”
-- gồm mã khách hàng, tên khách hàng, địa chỉ, điện thoại, và địa chỉ E-mail
SELECT *
FROM KHACHHANG
WHERE DIACHI = 'TAN BINH';
GO

-- 3) Hiển danh sách các khách hàng đã có số điện thoại và địa chỉ E-mail 
-- gồm mã khách hàng, tên khách hàng, địa chỉ, điện thoại, và địa chỉ E-mail
SELECT *
FROM KHACHHANG
WHERE DT IS NOT NULL AND EMAIL IS NOT NULL;
GO

-- 4) Hiển danh sách tất cả các vật tư gồm mã vật tư, tên vật tư, đơn vị tính và giá mua
SELECT MAVT, TENVT, DVT, GIAMUA
FROM VATTU;
GO

-- 5) Hiển danh sách các vật tư gồm mã vật tư, tên vật tư, đơn vị tính và giá mua 
-- mà có giá mua nằm trong khoảng từ 20000 đến 40000
SELECT MAVT, TENVT, DVT, GIAMUA
FROM VATTU
WHERE GIAMUA BETWEEN 20000 AND 40000;
GO

-- 6) Hiển danh sách các vật tư là “GẠCH” (bao gồm các loại gạch) 
-- gồm mã vật tư, tên vật tư, đơn vị tính và giá mua
SELECT MAVT, TENVT, DVT, GIAMUA
FROM VATTU
WHERE TENVT LIKE '%GACH%';
GO

-- 7) Hiển thị số lượng vật tư có trong CSDL
SELECT COUNT(*) AS SoLuongVatTu
FROM VATTU;
GO

-- 8) Hiển thị cho biết mỗi hóa đơn đã mua bao nhiêu loại vật tư.
-- Thông tin lấy về gồm: Mã hóa đơn, số loại vật tư trong hóa đơn này
SELECT MAHD as MaHoaDon, COUNT(*) AS SoLoaiVatTu
FROM CHITIETHOADON
GROUP BY MAHD;
GO

-- 9. Hiển thị cho biết tổng tiền của mỗi hóa đơn. 
-- Thông tin lấy về gồm: mã hóa đơn, tổng tiền của hóa đơn 
-- (biết rằng tổng tiền của 1 hóa đơn là tổng tiền của các vật tư trong hóa đơn đó)
SELECT MAHD, SUM(SL * GIABAN) AS TongTien
FROM CHITIETHOADON
GROUP BY MAHD;
GO

-- 10) Hiển thị cho biết mỗi khách hàng đã mua bao nhiêu hóa đơn. 
-- Thông tin lấy về gồm: Mã khách hàng, số lượng hóa đơn khách hàng này đã mua
SELECT MAKH, COUNT(*) AS SLHoaDon
FROM HOADON
GROUP BY MAKH;
GO
