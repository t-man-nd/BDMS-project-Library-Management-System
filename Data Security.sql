# Propose solutions for data security
# 1. Tạo tài khoản người dùng và cấp quyền
# Tài khoản của Reader
CREATE USER 'read_user'@'localhost' IDENTIFIED BY 'ReadOnlyPass!';

GRANT SELECT ON mytinylibrary.Books TO 'read_user'@'localhost';
GRANT SELECT ON mytinylibrary.Categories TO 'read_user'@'localhost';
GRANT SELECT ON mytinylibrary.Authors TO 'read_user'@'localhost';
GRANT SELECT ON mytinylibrary.Readers TO 'read_user'@'localhost';
GRANT SELECT ON mytinylibrary.Borrowing TO 'read_user'@'localhost';

# Tài khoản của Staff
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'StaffPass!';

GRANT SELECT, INSERT, UPDATE, DELETE ON mytinylibrary.* TO 'staff_user'@'localhost';

# Tài khoản của người lập báo cáo mượn trả sách
CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'ReportPass!';

GRANT SELECT ON mytinylibrary.* TO 'report_user'@'localhost';

# 2. Yêu cầu đổi mật khẩu
ALTER USER 'read_user'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'staff_user'@'localhost' PASSWORD EXPIRE INTERVAL 180 DAY;
ALTER USER 'report_user'@'localhost' PASSWORD EXPIRE INTERVAL 180 DAY;

# 3. Sao lưu và phục hồi (Sử dụng mysqldump)
# mysqldump -u root -p mytinylibrary > backup_mytinylibrary.sql

# 4. SSL/TLS Connection
# Bật SSL trong cài đặt máy chủ MySQL và yêu cầu SSL cho người dùng nhạy cảm
CREATE USER 'secure_user'@'localhost' REQUIRE SSL;

# 5. Kiểm toán và giám sát
# Bật general log trong MySQL để theo dõi các hoạt động đáng ngờ như truy cập trái phép hoặc truy vấn bất thường
SET GLOBAL general_log = 'ON';
SHOW VARIABLES LIKE 'general_log_file';

# 6. Bảo vệ tệp cơ sở dữ liệu
# Giới hạn quyền truy cập tệp trên máy chủ chỉ dành cho người dùng hệ thống được ủy quyền (ví dụ: tài khoản dịch vụ MySQL)
# chown -R mysql:mysql /var/lib/mysql
# chmod -R 750 /var/lib/mysql (Hai lệnh này viết trong terminal)