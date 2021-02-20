-- HungpmSE00234x
-- DBI - Assignment 02

-- 1. Create 'newspaper' database
CREATE DATABASE newspaper;
GO

-- 2. Change context to 'newspaper' database
USE newspaper;
GO

-- 3. Role Table
CREATE TABLE roles
(
    role_id     VARCHAR(10) PRIMARY KEY,
    name        NVARCHAR(30),
    description NVARCHAR(200),
    created_at  DATETIME DEFAULT GETUTCDATE() NOT NULL,
    updated_at  DATETIME DEFAULT GETUTCDATE() NOT NULL
);
GO

-- Create trigger to update updated_at whenever record on 'roles' table is updated
CREATE TRIGGER tg_RoleUpdateTime
    ON roles
    AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Id VARCHAR(10);
    SELECT @Id = role_id FROM inserted;
    IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.tg_RoleUpdateTime')) > 1 RETURN
    UPDATE dbo.roles SET updated_at = GETUTCDATE() WHERE role_id = @Id;
END
GO

-- Test tg_RoleUpdateTime
BEGIN TRAN
    INSERT INTO roles(role_id, name, description) VALUES ('Role1', 'Role1Name', 'Role1Desc');
    SELECT role_id, name, created_at, updated_at, 'inserted' FROM roles WHERE role_id = 'Role1';
    GO
    WAITFOR DELAY '00:00:01'; -- delay one second before updating
    UPDATE roles SET name='Role1Name - Updated' WHERE role_id = 'Role1';
    SELECT role_id, name, created_at, updated_at, 'updated' FROM roles WHERE role_id = 'Role1';
ROLLBACK TRAN
GO

-- Insert seed data to 'roles' table
INSERT INTO roles(role_id, name, description)
VALUES ('sa', 'Super Admin', 'S/HE can do all the configurations'),
       ('admin', 'Admin', 'S/HE can manage all editors and all business aspects'),
       ('editor', 'Editor', 'S/HE can manage all writers and their articles'),
       ('writer', 'Writer', 'S/HE can manage all of his/her own articles'),
       ('viewer', 'Viewer', 'S/HE can reads articles');
GO

-- 4. User table
CREATE TABLE users
(
    user_id       INT IDENTITY (1,1) PRIMARY KEY,
    role_id       VARCHAR(10)                   NOT NULL,
    email         NVARCHAR(320) UNIQUE          NOT NULL, -- "local part": 64 + "@": 1 + "domain part": 255 which sums to 320 -- Ref: tools.ietf.org/html/rfc3696
    password      NVARCHAR(64),                           -- hmac-sha256 output 64 byte-length
    first_name    NVARCHAR(30),
    last_name     NVARCHAR(30),
    profile_image NVARCHAR(100),
    intro_text    NVARCHAR(200),
    gender        CHAR(1),                                -- 'm' for male, and 'f' for female
    created_at    DATETIME DEFAULT GETUTCDATE() NOT NULL,
    updated_at    DATETIME DEFAULT GETUTCDATE() NOT NULL,

    CONSTRAINT FK_USER_ROLE FOREIGN KEY (role_id) REFERENCES roles (role_id)
);
GO

-- Create trigger to update updated_at whenever record on 'users' table is updated
CREATE TRIGGER tg_UserUpdateTime
    ON users
    AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @UserId INT;
    SELECT @UserId = user_id FROM inserted;
    IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.tg_UserUpdateTime')) > 1 RETURN
    UPDATE users SET updated_at = GETUTCDATE() WHERE user_id = @UserId;
END
GO

-- Test tg_UserUpdateTime
BEGIN TRAN
    INSERT INTO users(role_id, email) VALUES ('sa', 'abc@gmail.com');
    SELECT user_id, first_name, created_at, updated_at, 'inserted' FROM users WHERE email = 'abc@gmail.com';
    GO
    WAITFOR DELAY '00:00:01'; -- delay one second before updating
    UPDATE users SET first_name='FirstName' WHERE email = 'abc@gmail.com';
    SELECT user_id, first_name, created_at, updated_at, 'updated' FROM users WHERE email = 'abc@gmail.com';
ROLLBACK TRAN
GO

-- Insert seed data into 'users' table
SET IDENTITY_INSERT users ON;
INSERT INTO users(user_id, role_id, email, first_name, last_name, gender)
VALUES (1, 'sa', 'hungpmse00234x@funix.edu.vn', 'Hung', 'Pham', 'm'),
       (2, 'admin', 'jen@gmail.com', 'Jennifer', 'Pham', 'f'),
       (3, 'editor', 'james@gmail.com', 'James', 'Potter', 'm'),
       (4, 'editor', 'evelyn@gmail.com', 'Evelyn', 'Truong', 'f'),
       (5, 'writer', 'jackson@gmail.com', 'Jackson', 'Stewart', 'm'),
       (6, 'writer', 'ellie@gmail.com', 'Ellie', 'Lopez', 'f'),
       (7, 'writer', 'dorian@gmail.com', 'Dorian', 'Bell', 'm'),
       (8, 'viewer', 'tasha@gmail.com', 'Tashia', 'Thompson', 'f'),
       (9, 'viewer', 'norris@gmail.com', 'Norris', 'Howard', 'm'),
       (10, 'viewer', 'vince@gmail.com', 'Vince', 'Blake', 'm'),
       (11, 'viewer', 'ned@gmail.com', 'Ned', 'Alexander', 'm'),
       (12, 'viewer', 'jessica@gmail.com', 'Jessica', 'Valdez', 'f');
SET IDENTITY_INSERT users OFF;
GO

-- 5. Article table
CREATE TABLE articles
(
    article_id   INT IDENTITY (1,1) PRIMARY KEY,
    writer       INT                           NOT NULL,
    editor       INT,
    title        NVARCHAR(200),
    brief        NVARCHAR(500),
    content      NVARCHAR(MAX),
    is_published BIT      DEFAULT 0,
    published_at DATETIME,
    created_at   DATETIME DEFAULT GETUTCDATE() NOT NULL,
    updated_at   DATETIME DEFAULT GETUTCDATE() NOT NULL,

    CONSTRAINT FK_ARTICLE_WRITER FOREIGN KEY (writer) REFERENCES users (user_id),
    CONSTRAINT FK_ARTICLE_EDITOR FOREIGN KEY (editor) REFERENCES users (user_id)
);
GO

-- Create index for article's published_at
CREATE NONCLUSTERED INDEX idx_ArticlePublishedAt
    ON articles (published_at DESC);
GO

-- Create trigger to update updated_at whenever record on 'articles' table is updated
CREATE TRIGGER tg_ArticleUpdateTime
    ON articles
    AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Id INT;
    SELECT @Id = article_id FROM inserted;
    IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.tg_ArticleUpdateTime')) > 1 RETURN
    UPDATE articles SET updated_at = GETUTCDATE() WHERE article_id = @Id;
END
GO

-- Test tg_ArticleUpdateTime
BEGIN TRAN
    SET IDENTITY_INSERT articles ON;
    INSERT INTO articles(article_id, writer, title) VALUES (1, 5, 'article title');
    SET IDENTITY_INSERT articles OFF;

    SELECT article_id, title, created_at, updated_at, 'inserted' FROM articles WHERE article_id = 1;
    GO
    WAITFOR DELAY '00:00:01'; -- delay one second before updating
    UPDATE articles SET title='updated article title' WHERE article_id = 1;
    SELECT article_id, title, created_at, updated_at, 'updated' FROM articles WHERE article_id = 1;
ROLLBACK TRAN
GO

-- Insert seed data to 'articles' table
SET IDENTITY_INSERT articles ON;
INSERT INTO articles(article_id, writer, editor, title, is_published, published_at)
VALUES (1, 5, NULL, 'article 1', 0, NULL),
       (2, 6, NULL, 'article 2', 0, NULL),
       (3, 7, 3, 'article 3', 0, DATEFROMPARTS(2021, 9, 1)),
       (4, 5, 4, 'article 4', 1, DATEFROMPARTS(2021, 8, 1)),
       (5, 6, 3, 'article 5', 1, DATEFROMPARTS(2021, 6, 1));
SET IDENTITY_INSERT articles OFF;
GO

-- Select statement
-- SELECT TOP 10 * FROM articles ORDER BY published_at DESC

-- 6. Comment table
CREATE TABLE comments
(
    comment_id INT IDENTITY (1,1) PRIMARY KEY,
    user_id    INT                           NOT NULL,
    article_id INT                           NOT NULL,
    content    NVARCHAR(500)                 NOT NULL,
    created_at DATETIME DEFAULT GETUTCDATE() NOT NULL,
    updated_at DATETIME DEFAULT GETUTCDATE() NOT NULL,

    CONSTRAINT FK_COMMENT_USER FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT FK_COMMENT_ARTICLE FOREIGN KEY (article_id) REFERENCES users (user_id),
);
GO

-- Create index to look for comments in one article in desc order
CREATE NONCLUSTERED INDEX idx_CommentArticle
    ON comments (article_id, created_at DESC)
GO

-- Create trigger to update updated_at whenever record on 'comments' table is updated
CREATE TRIGGER tg_CommentUpdateTime
    ON comments
    AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Id INT;
    SELECT @Id = comment_id FROM inserted;
    IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.tg_CommentUpdateTime')) > 1 RETURN
    UPDATE comments SET updated_at = GETUTCDATE() WHERE comment_id = @Id;
END
GO

-- Test tg_CommentUpdateTime
BEGIN TRAN
    SET IDENTITY_INSERT comments ON;
    INSERT INTO comments(comment_id, user_id, article_id, content) VALUES (1, 10, 2, 'some comment');
    SET IDENTITY_INSERT comments OFF;

    SELECT comment_id, content, created_at, updated_at, 'inserted' FROM comments WHERE comment_id = 1;
    GO
    WAITFOR DELAY '00:00:01'; -- delay one second before updating
    UPDATE comments SET content='updated comment' WHERE comment_id = 1;
    SELECT comment_id, content, created_at, updated_at, 'updated' FROM comments WHERE comment_id = 1;
ROLLBACK TRAN
GO

-- Insert seed data to 'comment's table
SET IDENTITY_INSERT comments ON;
INSERT INTO comments(comment_id, user_id, article_id, content, created_at)
VALUES (1, 8, 3, 'some comment', DATEFROMPARTS(2021, 10, 01)),
       (2, 11, 3, 'some comment', DATEFROMPARTS(2021, 10, 02)),
       (3, 12, 4, 'some comment', DATEFROMPARTS(2021, 10, 03)),
       (4, 9, 3, 'some comment', DATEFROMPARTS(2021, 10, 04)),
       (5, 10, 4, 'some comment', DATEFROMPARTS(2021, 10, 05)),
       (6, 8, 3, 'some comment', DATEFROMPARTS(2021, 10, 06)),
       (7, 12, 5, 'some comment', DATEFROMPARTS(2021, 10, 07)),
       (8, 9, 5, 'some comment', DATEFROMPARTS(2021, 10, 08)),
       (9, 12, 3, 'some comment', DATEFROMPARTS(2021, 10, 09)),
       (10, 8, 3, 'some comment', DATEFROMPARTS(2021, 10, 10)),
       (11, 10, 4, 'some comment', DATEFROMPARTS(2021, 10, 11)),
       (12, 9, 3, 'some comment', DATEFROMPARTS(2021, 10, 12)),
       (13, 11, 5, 'some comment', DATEFROMPARTS(2021, 10, 13)),
       (14, 10, 3, 'some comment', DATEFROMPARTS(2021, 10, 14)),
       (15, 8, 4, 'some comment', DATEFROMPARTS(2021, 10, 15)),
       (16, 10, 3, 'some comment', DATEFROMPARTS(2021, 10, 16));
SET IDENTITY_INSERT comments OFF;
GO

-- Select statement
-- SELECT top 2 * from comments where article_id = 3 order by created_at DESC

-- 7. Category table
CREATE TABLE categories
(
    cat_id      INT IDENTITY (1,1) PRIMARY KEY,
    name        NVARCHAR(20),
    description NVARCHAR(100),
    created_at  DATETIME DEFAULT GETUTCDATE() NOT NULL,
    updated_at  DATETIME DEFAULT GETUTCDATE() NOT NULL
);
GO


-- Create trigger to update updated_at whenever record on 'categories' table is updated
CREATE TRIGGER tg_CategoryUpdateTime
    ON categories
    AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON
    DECLARE @Id INT;
    SELECT @Id = cat_id FROM inserted;
    IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.tg_CategoryUpdateTime')) > 1 RETURN
    UPDATE categories SET updated_at = GETUTCDATE() WHERE cat_id = @Id;
END
GO

-- Test tg_CategoryUpdateTime
BEGIN TRAN
    SET IDENTITY_INSERT categories ON;
    INSERT INTO categories(cat_id, name, description) VALUES (1, 'cat name', 'cat description');
    SET IDENTITY_INSERT categories OFF;

    SELECT cat_id, name, created_at, updated_at, 'inserted' FROM categories WHERE cat_id = 1;
    GO
    WAITFOR DELAY '00:00:01'; -- delay one second before updating
    UPDATE categories SET name='updated name' WHERE cat_id = 1;
    SELECT cat_id, name, created_at, updated_at, 'updated' FROM categories WHERE cat_id = 1;
ROLLBACK TRAN
GO

-- Insert seed data to categories
SET IDENTITY_INSERT categories ON;
INSERT INTO categories(cat_id, name, description)
VALUES (1, 'POV', 'Point Of View'),
       (2, 'World', 'World news'),
       (3, 'Business', 'Business news'),
       (4, 'Health', 'Health news'),
       (5, 'Science', 'Science news');
SET IDENTITY_INSERT categories OFF;
GO

-- 8. CategoryArticle table
CREATE TABLE category_articles
(
    cat_id     INT NOT NULL,
    article_id INT NOT NULL,

    CONSTRAINT PK_CategoryArticle PRIMARY KEY (cat_id, article_id),
    CONSTRAINT FK_CategoryArticle_Category FOREIGN KEY (cat_id) REFERENCES categories (cat_id),
    CONSTRAINT FK_CategoryArticle_Article FOREIGN KEY (article_id) REFERENCES articles (article_id),
);
GO

-- Add index to category since it's useful when searching articles in one category
CREATE NONCLUSTERED INDEX idx_CategoryArticle_Category
    ON category_articles (cat_id)
GO

-- Insert seed data
INSERT INTO category_articles(cat_id, article_id)
VALUES (2, 1),
       (2, 2),
       (3, 3),
       (3, 4),
       (3, 5);
GO

-- Select statement
-- SELECT * FROM category_articles WHERE cat_id = 3

--- Truy vấn dữ liệu trên một bảng
SELECT * FROM users;
GO

--- Truy vấn có sử dụng Order by
SELECT * FROM comments ORDER BY created_at DESC;
GO

--- Truy vấn dữ liệu từ nhiều bảng sử dụng Inner join
SELECT *
FROM users U
         INNER JOIN comments C
                    ON U.user_id = C.user_id
WHERE U.user_id = 8;
GO

--- Truy vấn thống kê sử dụng Group by và Having
SELECT U.user_id, count(*) AS comment_num
FROM users U
         INNER JOIN comments C
                    ON U.user_id = C.user_id
GROUP BY U.user_id
HAVING count(*) >= 3;
GO

--- Truy vấn sử dụng truy vấn con.
SELECT U.user_id,
       ISNULL((SELECT count(*) FROM comments C WHERE U.user_id = C.user_id GROUP BY C.user_id), 0) as comment_num
FROM users U;
GO

--- Truy vấn sử dụng toán tử Like và các so sánh xâu ký tự.
SELECT *
FROM roles
WHERE name LIKE '%admin%';
GO

--- Truy vấn liên quan tới điều kiện về thời gian
SELECT *
FROM articles
WHERE published_at >= DATEFROMPARTS(2021, 8, 1);
GO

--- Truy vấn sử dụng Self join, Outer join.
--- Self Join: ghép cặp cùng role
SELECT A.role_id, A.first_name, B.first_name
FROM users A,
     users B
WHERE A.user_id < B.user_id
  AND A.role_id = B.role_id
ORDER BY A.role_id;
GO

-- Outer Join
SELECT U.user_id, U.first_name, C.article_id, C.content
FROM users U
         LEFT JOIN comments C ON U.user_id = C.user_id;
GO

--- Truy vấn sử dụng With
--- Chọn ra 2 writer viết nhiều nhất
WITH tblWriterArticleCount AS (
    SELECT U.user_id,
           U.first_name,
           U.last_name,
           (SELECT count(*) FROM articles A WHERE U.user_id = A.writer GROUP BY A.writer) as article_count
    FROM users U
    WHERE U.role_id = 'writer'
)

SELECT TOP (2) user_id, first_name, last_name, article_count
FROM tblWriterArticleCount
ORDER BY article_count DESC
GO

--- Truy vấn sử dụng function (hàm) đã viết trong bước trước. GetWriterWithMostPublishedArticles
CREATE FUNCTION GetWriterPublishedArticleCountTable()
    RETURNS TABLE AS RETURN
            (
                SELECT writer, COUNT(*) AS published_article_count
                FROM articles
                WHERE is_published = 1
                GROUP BY writer
            );
GO

CREATE FUNCTION GetWriterwWithMostPublishedArticles()
    RETURNS INT AS
BEGIN
    DECLARE @id INT;

    SELECT @id = writer
    FROM GetWriterPublishedArticleCountTable()
    WHERE published_article_count = (
        SELECT MAX(published_article_count) FROM GetWriterPublishedArticleCountTable()
    )

    RETURN @id
END
GO

--- Test the function GetWriterwWithMostPublishedArticles
BEGIN TRAN
    DECLARE @id INT;
    EXEC @id = GetWriterwWithMostPublishedArticles
    PRINT @id
ROLLBACK TRAN
