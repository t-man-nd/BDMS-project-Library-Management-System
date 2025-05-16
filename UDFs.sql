
-- Show all function
SELECT 
    ROUTINE_NAME
FROM
    INFORMATION_SCHEMA.ROUTINES
WHERE
    ROUTINE_TYPE = 'FUNCTION'
        AND ROUTINE_SCHEMA = DATABASE();


-- Searching info by BookID
DELIMITER $$

CREATE FUNCTION GetBookInfoByID(book_id SMALLINT)
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
  DECLARE info VARCHAR(1000);
  SELECT CONCAT(
           'Name: ', b.BookName,
           ', Year: ', b.PublishYear,
           ', Authors: ', GROUP_CONCAT(a.AuthorName SEPARATOR ', '),
           ', Quantity: ', b.Quantity
         )
  INTO info
  FROM Books b
  LEFT JOIN BookAuthor ba ON b.BookID = ba.BookID
  LEFT JOIN Authors a ON ba.AuthorID = a.AuthorID
  WHERE b.BookID = book_id
  GROUP BY b.BookID;
  
  RETURN info;
END $$

DELIMITER ;

SELECT GETBOOKINFOBYID(6);


-- Find reader by ID
DELIMITER $$

CREATE FUNCTION GetReaderbyID(reader_id INT)
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
  DECLARE result VARCHAR(1000);

  SELECT 
    CONCAT('Name: ',
            r.ReaderName,
            ' | Borrowed books: ',
            GROUP_CONCAT(CONCAT(b.BookName,
                        ' (',
                        DATE_FORMAT(br.BorrowDate, '%Y-%m-%d'),
                        ')')
                SEPARATOR ', '))
INTO result FROM
    Readers r
        JOIN
    Borrowing br ON r.ReaderID = br.ReaderID
        JOIN
    Books b ON br.BookID = b.BookID
WHERE
    r.ReaderID = reader_id
GROUP BY br.ReaderID
ORDER BY MAX(br.BorrowDate) DESC;
  RETURN result;
END $$

DELIMITER ;

SELECT GETREADERBYID(1);

-- find books by keyword
DELIMITER $$

CREATE FUNCTION GetBookByKeyword(keyword VARCHAR(255))
RETURNS VARCHAR(2000)
DETERMINISTIC
BEGIN
  DECLARE book_infos VARCHAR(2000);

  SELECT GROUP_CONCAT(
    CONCAT(
      'Name: ', BookName, 
      ', Year: ', PublishYear, 
      ', Quantity: ', Quantity
    )
    SEPARATOR ' \n '
  )
  INTO book_infos
  FROM Books
  WHERE BookName LIKE CONCAT('%', keyword, '%');

  RETURN book_infos;
END $$

DELIMITER ;

SELECT GETBOOKBYKEYWORD('The');

-- Check overdue books by readerID
DELIMITER $$

CREATE FUNCTION CheckOverdueBooksByReader(reader_id INT)
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
  DECLARE overdue_books VARCHAR(1000);

  SELECT GROUP_CONCAT(bk.BookName SEPARATOR ' \n ')
  INTO overdue_books
  FROM Borrowing br
  JOIN Books bk ON br.BookID = bk.BookID
  WHERE br.ReaderID = reader_id
    AND DATEDIFF(br.ReturnDate, br.BorrowDate) > 20;

  RETURN overdue_books;
END $$

DELIMITER ;

SELECT CHECKOVERDUEBOOKSBYREADER(1);

-- Top n most borrowed books
DELIMITER $$

CREATE FUNCTION GetTopBooks(limit_n INT)
RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN
  DECLARE top_books VARCHAR(1000);

  SELECT GROUP_CONCAT(book_info SEPARATOR '\n')
  INTO top_books
  FROM (
    SELECT CONCAT(b.BookName, ' (', COUNT(*) , ' borrowings)') AS book_info
    FROM Borrowing br
    JOIN Books b ON br.BookID = b.BookID
    GROUP BY b.BookID
    ORDER BY COUNT(*) DESC
    LIMIT limit_n
  ) AS ranked_books;

  RETURN top_books;
END $$

DELIMITER ;

SELECT GETTOPBOOKS(3);

-- Example of use of function
SELECT 
  r.ReaderID,
  GetReaderbyID(r.ReaderID) AS ReaderInfo,
  CheckOverdueBooksByReader(r.ReaderID) AS OverdueBooks
FROM Readers r;





