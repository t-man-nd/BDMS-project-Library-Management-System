CREATE DATABASE IF NOT EXISTS mytinylibrary;

-- DROP TABLE IF EXISTS Books;
-- DROP TABLE IF EXISTS Categories;
-- DROP TABLE IF EXISTS BookCategory;
-- DROP TABLE IF EXISTS Authors;
-- DROP TABLE IF EXISTS BookAuthor; 
-- DROP TABLE IF EXISTS Readers;
-- DROP TABLE IF EXISTS Borrowing;

USE mytinylibrary;

CREATE TABLE Books
(
  BookID SMALLINT AUTO_INCREMENT,
  BookName VARCHAR(255),
  PublishYear SMALLINT,
  Quantity INT NOT NULL,
  PRIMARY KEY (BookID)
);

CREATE TABLE Authors
(
  AuthorID SMALLINT AUTO_INCREMENT,
  AuthorName VARCHAR(255),
  PRIMARY KEY (AuthorID)
);

CREATE TABLE BookAuthor
( 
  BookID SMALLINT NOT NULL,
  AuthorID SMALLINT NOT NULL,
  PRIMARY KEY (BookID, AuthorID),
  FOREIGN KEY (BookID) REFERENCES Books(BookID),
  FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Categories
(
  CategoryID SMALLINT AUTO_INCREMENT,
  CategoryName VARCHAR(255),
  PRIMARY KEY (CategoryID)
);

CREATE TABLE BookCategory
(
  BookID SMALLINT NOT NULL,
  CategoryID SMALLINT NOT NULL,
  PRIMARY KEY (BookID, CategoryID),
  FOREIGN KEY (BookID) REFERENCES Books(BookID),
  FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Readers
(
  ReaderID INT AUTO_INCREMENT,
  ReaderName VARCHAR(255) NOT NULL,
  Address VARCHAR(255) NOT NULL,
  PhoneNumber VARCHAR(20) NOT NULL,
  PRIMARY KEY (ReaderID)
);

CREATE TABLE Staff (
  StaffID INT AUTO_INCREMENT,
  StaffName VARCHAR(255) NOT NULL,
  Position VARCHAR(100),
  PhoneNumber VARCHAR(20),
  Email VARCHAR(255),
  PRIMARY KEY (StaffID)
);	

CREATE TABLE Borrowing (
  BorrowID INT AUTO_INCREMENT,
  BorrowDate DATE NOT NULL,
  ReturnDate DATE,
  ReaderID INT NOT NULL,
  BookID SMALLINT NOT NULL,
  BorrowStaffID INT,
  ReturnStaffID INT,   
  PRIMARY KEY (BorrowID),
  FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
  FOREIGN KEY (BookID) REFERENCES Books(BookID),
  FOREIGN KEY (BorrowStaffID) REFERENCES Staff(StaffID),
  FOREIGN KEY (ReturnStaffID) REFERENCES Staff(StaffID),
  UNIQUE (ReaderID, BookID)
);

insert into Books (BookName, PublishYear, Quantity) values
('Dracula', 1897, 15),
('Harry Potter and the Sorcerer''s Stone', 1997, 27),
('Honor among Thieves', 2018, 20),
('Interview with the Vampire', 1976, 36),
('Lords of the Rings', 1954, 21),
('Sherlock Holmes', 1890, 14),
('Stillhouse Lake', 2017, 24),
('The Hobbit', 1937, 20),
('The Mummy, or Ramses the Damned', 1989, 12),
('The War of the Worlds', 1897, 8);


insert into Authors (AuthorName) values
('J. K. Rowling'),
('Rachel Caine'),
('J. R. R. Tolkien'),
('Ann Aguirre'),
('Bram Stoker'),
('Anne Rice'),
('Conan Doyle'),
('H. G. Wells');

insert into BookAuthor (BookID, AuthorID) values
(1, 5),
(2, 1),
(3, 2),
(3, 4),
(4, 6),
(5, 3),
(6, 7),
(7, 2),
(8, 3),
(9, 6),
(10, 8);

insert into Categories (CategoryName) values
('fantasy'),
('adventure'),
('mystery'),
('sci-fi'),
('horror'),
('detective');

insert into BookCategory (BookID, CategoryID) values
(1, 5),
(2, 1),
(3, 4),
(4, 5),
(5, 1),
(5, 2),
(6, 6),
(7, 3),
(8, 2),
(9, 3),
(9, 5),
(10, 4);
	

insert into Readers (ReaderID, ReaderName, Address, PhoneNumber) values
(1, 'Nguyen Van An', '12 Kim Ma, Ba Dinh, Ha Noi', '0987654321'),
(2, 'Tran Thi Binh', '45 Nguyen Chi Thanh, Dong Da, Ha Noi', '0987654322'),
(3, 'Le Minh Chau', '23 Tran Duy Hung, Cau Giay, Ha Noi', '0914567890'),
(4, 'Pham Duc Duy', '67 Doi Can, Ba Dinh, Ha Noi', '0915678901'),
(5, 'Hoang Mai Lan', '89 Tay Son, Dong Da, Ha Noi', '0916789012');

insert into Staff (StaffName, Position, PhoneNumber, Email) values
('Nguyen Van Hoa', 'Librarian', '0912345678', 'hoa.nguyen@library.vn'),
('Tran Thi Thu', 'Assistant', '0912345679', 'thu.tran@library.vn'),
('Le Minh Tam', 'Manager', '0912345680', 'tam.le@library.vn'),
('Pham Quoc Anh', 'Librarian', '0912345681', 'anh.pham@library.vn'),
('Doan Minh Chau', 'Assistant', '0912345682', 'chau.doan@library.vn');

insert into Borrowing (BorrowDate, ReturnDate, ReaderID, BookID, BorrowStaffID, ReturnStaffID) values
('2025-04-01', '2025-04-08', 1, 1, 1, 2),
('2025-04-02', '2025-04-11', 2, 2, 2, 3),
('2025-04-04', '2025-04-07', 3, 3, 3, 1),
('2025-04-05', '2025-04-12', 4, 4, 1, 2),
('2025-04-07', '2025-04-11', 5, 5, 2, 3),
('2025-04-09', '2025-05-10', 1, 6, 3, 1),
('2025-04-10', '2025-04-14', 2, 7, 1, 2),
('2025-04-14', '2025-04-18', 3, 8, 2, 3),
('2025-04-15', null, 4, 9, 3, 1),
('2025-04-22', null , 5, 10, 1, 2);

