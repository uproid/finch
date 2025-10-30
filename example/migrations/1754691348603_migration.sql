-- 2025-08-09 00:15:48.604706 
-- ## NEW VERSION:
ALTER TABLE `books`
ADD COLUMN `category_id` INT DEFAULT NULL,
ADD CONSTRAINT `fk_books_category_id`
FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`)
ON DELETE SET NULL ON UPDATE CASCADE;


-- ## ROLL BACK:
ALTER TABLE `books`
DROP FOREIGN KEY `fk_books_category_id`,
DROP COLUMN `category_id`;


