-- Project: Advanced Library Database Analysis
-- Description: Performed deep analysis on borrowing patterns, member engagement, and late return behaviors using complex SQL queries.

-- 1. Create the Library Database
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- 2. Create Tables
CREATE TABLE Books (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    PublishedYear INT NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    ISBN VARCHAR(13) UNIQUE NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Members (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    JoinDate DATE NOT NULL,
    MembershipStatus ENUM('Active', 'Inactive') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE BorrowingRecords (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT,
    BookID INT,
    BorrowDate DATE NOT NULL,
    ReturnDate DATE,
    DueDate DATE NOT NULL,
    ReturnedLate TINYINT AS (IF(ReturnDate IS NOT NULL AND ReturnDate > DueDate, 1, 0)) STORED,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- 3. Insert Sample Data
INSERT INTO Books (Title, Author, PublishedYear, Genre, ISBN) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Fiction', '9780743273565'),
('1984', 'George Orwell', 1949, 'Dystopian', '9780451524935'),
('Pride and Prejudice', 'Jane Austen', 1813, 'Romance', '9780141040349'),
('Moby Dick', 'Herman Melville', 1851, 'Adventure', '9781503280786'),
('To Kill a Mockingbird', 'Harper Lee', 1960, 'Classic', '9780060935467');

INSERT INTO Members (FullName, Email, JoinDate) VALUES
('Alice Johnson', 'alice@example.com', '2022-01-15'),
('Bob Smith', 'bob@example.com', '2021-11-22'),
('Charlie Brown', 'charlie@example.com', '2023-03-05');

INSERT INTO BorrowingRecords (MemberID, BookID, BorrowDate, ReturnDate, DueDate) VALUES
(1, 1, '2024-01-10', '2024-01-20', '2024-01-17'), -- Late
(2, 2, '2024-02-01', '2024-02-10', '2024-02-10'), -- On time
(1, 3, '2024-03-05', NULL, '2024-03-19'),         -- Not returned
(3, 4, '2024-04-01', '2024-04-20', '2024-04-15'), -- Late
(2, 5, '2024-05-01', '2024-05-05', '2024-05-10'); -- Early

-- 4. Advanced Analysis Queries

-- Q1: Most Borrowed Books
SELECT B.Title, COUNT(*) AS BorrowCount
FROM BorrowingRecords BR
JOIN Books B ON BR.BookID = B.BookID
GROUP BY BR.BookID
ORDER BY BorrowCount DESC;

-- Q2: Active Members with Most Borrowings
SELECT M.FullName, COUNT(*) AS TotalBorrowed
FROM BorrowingRecords BR
JOIN Members M ON BR.MemberID = M.MemberID
WHERE M.MembershipStatus = 'Active'
GROUP BY BR.MemberID
ORDER BY TotalBorrowed DESC;

-- Q3: Late Return Behavior
SELECT M.FullName, COUNT(*) AS LateReturns
FROM BorrowingRecords BR
JOIN Members M ON BR.MemberID = M.MemberID
WHERE BR.ReturnedLate = TRUE
GROUP BY M.MemberID
ORDER BY LateReturns DESC;

-- Q4: Average Borrow Duration
SELECT AVG(DATEDIFF(ReturnDate, BorrowDate)) AS AvgBorrowDays
FROM BorrowingRecords
WHERE ReturnDate IS NOT NULL;

-- Q5: Engagement Over Time (Monthly Borrowing Trend)
SELECT DATE_FORMAT(BorrowDate, '%Y-%m') AS Month, COUNT(*) AS Borrowings
FROM BorrowingRecords
GROUP BY Month
ORDER BY Month;

-- Q6: Books Currently Borrowed (Not Yet Returned)
SELECT B.Title, M.FullName, BR.BorrowDate, BR.DueDate
FROM BorrowingRecords BR
JOIN Books B ON BR.BookID = B.BookID
JOIN Members M ON BR.MemberID = M.MemberID
WHERE BR.ReturnDate IS NULL;

