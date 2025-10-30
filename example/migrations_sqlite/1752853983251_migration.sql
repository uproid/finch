-- 2025-07-18 17:53:03.252054 
-- ## NEW VERSION:
-- 2. Products table
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    price REAL,
    stock INTEGER
);


-- ## ROLL BACK:
DROP TABLE IF EXISTS products;


