-- 2025-07-18 17:53:06.747950 
-- ## NEW VERSION:
-- 3. Orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);


-- ## ROLL BACK:
DROP TABLE IF EXISTS orders;


