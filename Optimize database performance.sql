USE mytinylibrary;
###TEST DATABASE PERFORMANCE FOR STORED PROCEDURES
-- Phân tích SELECT Quantity
EXPLAIN SELECT Quantity FROM Books WHERE BookID = 1;

-- Phân tích UPDATE Books
EXPLAIN UPDATE Books SET Quantity = Quantity - 1 WHERE BookID = 1;

-- Phân tích truy vấn UPDATE trên Borrowing
EXPLAIN UPDATE Borrowing SET ReturnStaffID = 1, ReturnDate = '2025-16-05' 
WHERE BorrowID = 1 AND ReturnStaffID IS NULL;

-- Phân tích truy vấn con (subquery) trong UPDATE Books
EXPLAIN SELECT BookID FROM Borrowing WHERE BorrowID = 1;

-- Phân tích truy vấn UPDATE trên Books
EXPLAIN UPDATE Books SET Quantity = Quantity + 1 WHERE BookID = (SELECT BookID FROM Borrowing WHERE BorrowID = 1);

#Stored procedures overdue report
EXPLAIN SELECT b.BorrowID, r.ReaderName, bo.BookName, b.BorrowDate, b.ReturnDate
FROM Borrowing b
JOIN Readers r ON b.ReaderID = r.ReaderID
JOIN Books bo ON b.BookID = bo.BookID
WHERE (DATEDIFF(b.ReturnDate, b.BorrowDate) > 30)
    OR (b.ReturnDate IS NULL AND DATEDIFF(CURDATE(), b.BorrowDate) > 30);

#Stored procedures get_all_books
EXPLAIN SELECT BookID, BookName, Quantity FROM Books;

#Stored procedures get_book_by_id
EXPLAIN SELECT * FROM Books WHERE BookID = 1;

#Stored procedures get_reader_by_id
EXPLAIN SELECT * FROM Readers WHERE ReaderID = 1;

#Stored procedures get_borrowings_of_readerid
EXPLAIN SELECT * FROM Borrowing WHERE ReaderID = 1;

#Stored proceduré get_borrowing_of_bookid
EXPLAIN SELECT * FROM Borrowing WHERE BookID = 1;

### TEST PERFORMANCE FOR TRIGGERS
-- Phân tích truy vấn SELECT
EXPLAIN SELECT Quantity FROM Books WHERE BookID = 1;

-- Phân tích truy vấn UPDATE
EXPLAIN UPDATE Books SET Quantity = Quantity - 1 WHERE BookID = 1;

#Trigger after_returning
EXPLAIN UPDATE Books SET Quantity = Quantity + 1 WHERE BookID = 1;

#Trigger check_borrow_limit
EXPLAIN SELECT COUNT(*) FROM Borrowing WHERE ReaderID = 1 AND ReturnDate IS NULL;

###TEST PERFORMANCE FOR USER DEFINED FUNCTIONS
EXPLAIN SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION'
    AND ROUTINE_SCHEMA = DATABASE();
    
#GetBookInfoByID
EXPLAIN SELECT CONCAT(
    'Name: ', b.BookName,
    ', Year: ', b.PublishYear,
    ', Authors: ', GROUP_CONCAT(a.AuthorName SEPARATOR ', '),
    ', Quantity: ', b.Quantity
)
FROM Books b
LEFT JOIN BookAuthor ba ON b.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
WHERE b.BookID = 1
GROUP BY b.BookID;

#GetReaderByID
EXPLAIN SELECT 
    CONCAT('Name: ',
            r.ReaderName,
            ' | Borrowed books: ',
            GROUP_CONCAT(CONCAT(b.BookName,
                        ' (',
                        DATE_FORMAT(br.BorrowDate, '%Y-%m-%d'),
                        ')')
                SEPARATOR ', '))
FROM Readers r
JOIN Borrowing br ON r.ReaderID = br.ReaderID
JOIN Books b ON br.BookID = b.BookID
WHERE r.ReaderID = 1
GROUP BY br.ReaderID
ORDER BY MAX(br.BorrowDate) DESC;

#GetBookByKeyword
EXPLAIN SELECT GROUP_CONCAT(
    CONCAT(
        'Name: ', BookName, 
        ', Year: ', PublishYear, 
        ', Quantity: ', Quantity
    )
    SEPARATOR ' \n '
)
FROM Books
WHERE BookName LIKE '%The%';

#CheckOverdueBooksByReader
EXPLAIN SELECT GROUP_CONCAT(bk.BookName SEPARATOR ' \n ')
FROM Borrowing br
JOIN Books bk ON br.BookID = bk.BookID
WHERE br.ReaderID = 1
    AND DATEDIFF(br.ReturnDate, br.BorrowDate) > 20;

#GetTopBooks
EXPLAIN SELECT CONCAT(b.BookName, ' (', COUNT(*) , ' borrowings)') AS book_info
FROM Borrowing br
JOIN Books b ON br.BookID = b.BookID
GROUP BY b.BookID
ORDER BY COUNT(*) DESC
LIMIT 3;

#Truy van su dung ham
EXPLAIN SELECT 
    r.ReaderID,
    GetReaderbyID(r.ReaderID) AS ReaderInfo,
    CheckOverdueBooksByReader(r.ReaderID) AS OverdueBooks
FROM Readers r;