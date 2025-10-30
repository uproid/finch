-- 2025-08-08 23:50:58.077376
-- ## NEW VERSION:
CREATE TABLE IF NOT EXISTS `categories` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO
    `categories` (`title`)
VALUES ('Fiction'),
    ('Non-Fiction'),
    ('Science Fiction'),
    ('Fantasy'),
    ('Mystery'),
    ('Biography'),
    ('History'),
    ('Self-Help'),
    ('Health & Wellness'),
    ('Travel');

-- ## ROLL BACK:
DROP TABLE IF EXISTS `categories`;