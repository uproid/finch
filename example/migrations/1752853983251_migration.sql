-- 2025-07-18 17:53:03.252054 
-- ## NEW VERSION:
-- 2. Products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    stock INT
);


-- ## ROLL BACK:
DROP TABLE IF EXISTS products;


