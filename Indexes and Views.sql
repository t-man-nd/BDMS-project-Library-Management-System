
#Truy vấn cho bảng Books
CREATE INDEX idx_books_bookname ON Books(BookName);
CREATE INDEX idx_books_publishyear ON Books(PublishYear);

#Truy vấn cho bảng Authors
CREATE INDEX idx_authors_authorname ON Authors(AuthorName);

#Truy vấn cho bảng BookAuthors
CREATE INDEX idx_bookauthor_authorid ON BookAuthor(AuthorID);

#Truy vấn cho bảng Categories
CREATE INDEX idx_categories_categoryname ON Categories(CategoryName);

#Truy vấn cho bảng BookCategory
CREATE INDEX idx_bookcategory_categoryid ON BookCategory(CategoryID);

#Truy vấn cho bảng Readers
CREATE INDEX idx_reader_name ON Readers(ReaderName);
CREATE UNIQUE INDEX idx_reader_phone ON Readers(PhoneNumber);#câu lệnh unique vì do số điện thoại của reader có thể đều là duy nhất , tiết kiệm thời gian truy vấn bằng số điện thoại

#Truy vấn cho bảng Staff
CREATE INDEX idx_staff_name ON Staff(StaffName);
CREATE INDEX idx_staff_email ON Staff(Email);

#Truy vấn cho bảng Borrowing
CREATE INDEX idx_borrowing_reader_book ON Borrowing(ReaderID, BookID);
CREATE INDEX idx_borrowing_dates ON Borrowing(BorrowDate, ReturnDate);
CREATE INDEX idx_borrowing_return_null ON Borrowing(ReturnDate);

CREATE OR REPLACE VIEW View_BorrowingHistory AS
SELECT
    b.BorrowID,
    r.ReaderName,
    bk.BookName,
    a.AuthorName,
    c.CategoryName,
    b.BorrowDate,
    b.ReturnDate,
    s1.StaffName AS BorrowedBy,
    s2.StaffName AS ReturnedTo
FROM Borrowing b
JOIN Readers r ON b.ReaderID = r.ReaderID
JOIN Books bk ON b.BookID = bk.BookID
LEFT JOIN BookAuthor ba ON bk.BookID = ba.BookID
LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
LEFT JOIN BookCategory bc ON bk.BookID = bc.BookID
LEFT JOIN Categories c ON bc.CategoryID = c.CategoryID
LEFT JOIN Staff s1 ON b.BorrowStaffID = s1.StaffID
LEFT JOIN Staff s2 ON b.ReturnStaffID = s2.StaffID;









