# Tạo stored procedure quản lí việc mượn sách
DROP PROCEDURE IF EXISTS borrow_book;
DELIMITER $$
CREATE PROCEDURE borrow_book (
		IN inputReaderID INT,
    	IN inputBookID INT,
    	IN inputStaffID INT,
    	IN inputBorrowDate DATE,
    	OUT message VARCHAR(200)
)
BEGIN
	DECLARE book_quantity INT;
    
	SELECT Quantity INTO book_quantity
	FROM Books
	WHERE BookID = inputBookID;
    
   	IF book_quantity IS NULL THEN
		SET message = "Book does not exist";
	ELSEIF book_quantity <= 0 THEN
		SET message = "Book is out of stock";
	ELSE
		UPDATE Books
		SET Quantity = Quantity - 1
		WHERE BookID = inputBookID;
        
		INSERT INTO Borrowing (BorrowDate, ReturnDate, ReaderID, BookID, BorrowStaffID, ReturnStaffID)
		VALUES (inputBorrowDate, NULL, inputReaderID, inputBookID, inputStaffID, NULL);
        
		SET message = "Borrowing successful";
	END IF;
END $$
DELIMITER ;


# Tạo stored procedure quản lí việc trả sách
DROP PROCEDURE IF EXISTS return_book;
DELIMITER $$
CREATE PROCEDURE return_book (
    IN inputBorrowID INT,
    IN inputReturnStaffID INT,
    IN inputReturnDate DATE,
    OUT message VARCHAR(200)
)
BEGIN
    UPDATE Borrowing
    SET ReturnStaffID = inputReturnStaffID, ReturnDate = inputReturnDate
    WHERE BorrowID = inputBorrowID AND ReturnStaffID IS NULL;
    
    UPDATE Books
    SET Quantity = Quantity + 1
    WHERE BookID = (SELECT BookID FROM Borrowing WHERE BorrowID = inputBorrowID);
    
    SET message = "Return process successful";
END $$
DELIMITER ;


# Tạo stored procedure báo cáo sách bị quá hạn
DROP PROCEDURE IF EXISTS overdue_report;
DELIMITER $$
CREATE PROCEDURE overdue_report ()
BEGIN
	SELECT b.BorrowID, r.ReaderName, bo.BookName, b.BorrowDate, b.ReturnDate
	FROM Borrowing b
	JOIN Readers r ON b.ReaderID = r.ReaderID
	JOIN Books bo ON b.BookID = bo.BookID
	WHERE (DATEDIFF(b.ReturnDate, b.BorrowDate) > 30)
		OR (b.ReturnDate IS NULL AND DATEDIFF(CURDATE(), b.BorrowDate) > 30);
END $$
DELIMITER ;


# Tạo stored procedure get all books
DROP PROCEDURE IF EXISTS get_all_books;
DELIMITER $$
CREATE PROCEDURE get_all_books()
BEGIN
    SELECT BookID, BookName, Quantity
    FROM Books;
END $$
DELIMITER ;


# Tạo stored procedure get book info by bookid
DELIMITER $$
CREATE PROCEDURE get_book_by_id(IN inputBookID SMALLINT)
BEGIN
    SELECT * FROM Books
    WHERE BookID = inputBookID;
END $$
DELIMITER ;


# Tạo stored procedure get reader info by readerid
DELIMITER $$
CREATE PROCEDURE get_reader_by_id(IN inputReaderID INT)
BEGIN
    SELECT * FROM Readers
    WHERE ReaderID = inputReaderID;
END $$
DELIMITER ;


# Tạo stored procedure get all borrowing of this readerid
DROP PROCEDURE IF EXISTS get_borrowings_of_readerid;
DELIMITER $$
CREATE PROCEDURE get_borrowings_of_readerid(IN inputReaderID INT)
BEGIN
    SELECT *
    FROM Borrowing
    WHERE ReaderID = inputReaderID;
END $$
DELIMITER ;


# Tạo stored procedure get all borrowing of this bookid
DELIMITER $$
CREATE PROCEDURE get_borrowings_of_bookid(IN inputBookID SMALLINT)
BEGIN
    SELECT *
    FROM Borrowing
    WHERE BookID = inputBookID;
END $$
DELIMITER ;


# Tạo stored procedure get all currently borrowed books
DELIMITER $$
CREATE PROCEDURE get_currently_borrowed_books()
BEGIN
    SELECT bo.BookID, bo.BookName, b.ReaderID, r.ReaderName, b.BorrowDate
    FROM Borrowing b
    JOIN Books bo ON b.BookID = bo.BookID
    JOIN Readers r ON b.ReaderID = r.ReaderID
    WHERE b.ReturnDate IS NULL;
END $$
DELIMITER ;
