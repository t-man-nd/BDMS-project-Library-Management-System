#Cập nhật số sách sau khi cho mượn
DELIMITER $$

CREATE TRIGGER before_borrowing_update
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
    DECLARE available_quantity INT;
    
    -- Lấy số lượng sách hiện có từ bảng Books
    SELECT Quantity INTO available_quantity
    FROM Books
    WHERE BookID = NEW.BookID;
    
    -- Kiểm tra nếu số lượng sách còn lại là 0 hoặc ít hơn
    IF available_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không đủ sách để mượn';
    ELSE
        -- Giảm số lượng sách khi có người mượn
        UPDATE Books
        SET Quantity = Quantity - 1
        WHERE BookID = NEW.BookID;
    END IF;
END$$

DELIMITER ;

#Cập nhật số sách sau khi trả lại
DELIMITER $$

CREATE TRIGGER after_returning
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu có thay đổi trạng thái trả sách và ReturnStaffID được gán
    IF OLD.ReturnDate != NEW.ReturnDate AND NEW.ReturnStaffID IS NOT NULL THEN
        -- Cập nhật lại số lượng sách sau khi trả lại
        UPDATE Books
        SET Quantity = Quantity + 1
        WHERE BookID = NEW.BookID;
    END IF;
END$$

DELIMITER ;

#Giới hạn số sách có thể mượn (tối đa 5)
DELIMITER $$

CREATE TRIGGER check_borrow_limit
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
    DECLARE borrow_count INT;

    SELECT COUNT(*) INTO borrow_count
    FROM Borrowing
    WHERE ReaderID = NEW.ReaderID AND ReturnDate IS NULL;
    
    IF borrow_count >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bạn đọc đã mượn đủ số lượng sách tối đa (5 cuốn)';
    END IF;
END$$

DELIMITER ;

#Cập nhật tính hợp lệ của ngày mượn và ngày trả sách
DELIMITER $$

CREATE TRIGGER check_borrow_dates
BEFORE INSERT ON Borrowing
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate < NEW.BorrowDate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày trả sách không thể trước ngày mượn';
    END IF;
END$$

DELIMITER ;

#Tạo bảng BookLogs để cập nhật những thay đổi trong tủ sách
CREATE TABLE BooksLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    BookID SMALLINT,
    BookName VARCHAR(255),
    PublishYear SMALLINT,
    Quantity INT,
    LogDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE BooksLog ADD COLUMN Action VARCHAR(50);
#Trigger khi có thêm sách mới
DELIMITER $$

CREATE TRIGGER after_insert_book
AFTER INSERT ON Books
FOR EACH ROW
BEGIN
    -- Ghi thông tin về sách mới vào bảng BooksLog
    INSERT INTO BooksLog (BookID, BookName, PublishYear, Quantity)
    VALUES (NEW.BookID, NEW.BookName, NEW.PublishYear, NEW.Quantity);
END$$

DELIMITER ;

#Trigger khi thông tin sách cập nhật 

DELIMITER $$

CREATE TRIGGER after_update_book
AFTER UPDATE ON Books
FOR EACH ROW
BEGIN
    IF OLD.BookName != NEW.BookName OR OLD.PublishYear != NEW.PublishYear OR OLD.Quantity != NEW.Quantity THEN
        -- Ghi log khi có sự thay đổi trong bảng Books
        INSERT INTO BooksLog (BookID, BookName, PublishYear, Quantity, Action)
        VALUES (OLD.BookID, OLD.BookName, OLD.PublishYear, OLD.Quantity, 'Updated');
    END IF;
END$$

DELIMITER ;

#Trigger khi sách bị xóa 
DELIMITER $$

CREATE TRIGGER after_delete_book
AFTER DELETE ON Books
FOR EACH ROW
BEGIN
    -- Ghi log khi có sách bị xóa
    INSERT INTO BooksLog (BookID, BookName, PublishYear, Quantity, Action)
    VALUES (OLD.BookID, OLD.BookName, OLD.PublishYear, OLD.Quantity, 'Deleted');
END$$

DELIMITER ;