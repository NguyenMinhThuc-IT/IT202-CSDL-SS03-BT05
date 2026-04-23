use baitap4;

-- 1. Cấu trúc bảng được tối ưu hóa
CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    -- Thêm NOT NULL cho các trường bắt buộc để tránh dữ liệu rác
    CustomerName VARCHAR(100) NOT NULL, 
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    -- Sử dụng ENUM hoặc thêm Index cho Status để tăng tốc độ tìm kiếm
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending', 
    -- Soft Delete: Giữ nguyên TINYINT(1) nhưng phải có Index mới hiệu quả
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0,
    
    -- QUAN TRỌNG: Thêm Index (Chỉ mục)
    -- Đây là lý do tại sao hệ thống quét chậm (Full Table Scan)
    INDEX idx_status (Status),
    INDEX idx_is_deleted (IsDeleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Dữ liệu mẫu (Sửa lại đúng cú pháp và logic)
-- Lưu ý: Khi Insert, nên liệt kê cả cột IsDeleted nếu muốn kiểm soát chặt chẽ
INSERT INTO ORDERS (CustomerName, OrderDate, TotalAmount, Status, IsDeleted) VALUES
('Nguyen Van A', '2023-01-10 10:00:00', 500000, 'Completed', 0),
('Khach hang vang lai', '2023-02-15 14:30:00', 1200000, 'Canceled', 0),
('Tran Thi B', '2023-05-20 09:15:00', 300000, 'Canceled', 0),
('Le Van C', '2024-01-05 16:45:00', 850000, 'Completed', 0);

-- 3. Giải quyết vấn đề truy vấn chậm
-- SAI LẦM TRONG ẢNH: Truy vấn SELECT * nhưng không lọc IsDeleted
-- và thiếu Index khiến MySQL phải đọc hàng trăm ngàn dòng "Hủy".

-- CÁCH SỬA:
-- Bước 1: Luôn lọc theo IsDeleted = 0
-- Bước 2: Chỉ lấy các cột cần thiết thay vì SELECT * (để tiết kiệm RAM/Network)
SELECT OrderID, CustomerName, TotalAmount, Status 
FROM ORDERS 
WHERE Status = 'Completed' 
AND IsDeleted = 0;

-- Chỉ lấy những đơn hàng "sống" (chưa bị xóa logic)
SELECT * FROM ORDERS 
WHERE IsDeleted = 0;

-- Lưu ý kỹ thuật: 
-- Phải luôn có điều kiện "IsDeleted = 0" trong tất cả các truy vấn thông thường.

-- Truy vấn phục vụ đối soát cuối năm hoặc kiểm tra đơn hủy
SELECT * FROM ORDERS 
WHERE Status = 'Canceled';

-- Hoặc cụ thể hơn để xem danh sách đã bị ẩn:
-- SELECT * FROM ORDERS WHERE IsDeleted = 1;