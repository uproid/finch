-- 2025-07-18 17:53:11.065002 
-- ## NEW VERSION:
-- 4. Order Items table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);


-- ## ROLL BACK:
DROP TABLE IF EXISTS order_items;

