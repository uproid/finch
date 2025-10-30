-- 2025-10-20 00:47:38.808973 
-- Name: add categories 
-- ## NEW VERSION:
INSERT INTO
    categories (title)
VALUES ('Fiction'),
    ('Non-Fiction'),
    ('Science Fiction'),
    ('Fantasy'),
    ('Mystery'),
    ('Biography'),
    ('History'),
    ('Self-Help'),
    ('Health & Wellness'),
    ('Travel')


-- ## ROLL BACK:
DELETE FROM categories;



