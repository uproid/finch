-- 2025-07-18 17:53:11.065002 
-- ## NEW VERSION:
-- 4. Order Items table
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);


-- ## ROLL BACK:
DROP TABLE IF EXISTS order_items;

