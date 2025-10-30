-- Insert Users
INSERT INTO users (name, email) VALUES 
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com');

-- Insert Products
INSERT INTO products (name, price, stock) VALUES
('Laptop', 999.99, 10),
('Smartphone', 499.50, 20),
('Headphones', 89.99, 50),
('Keyboard', 45.00, 30);

-- Insert Orders
INSERT INTO orders (user_id) VALUES
(1), -- Alice
(2); -- Bob

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1), -- Alice bought 1 Laptop
(1, 4, 2), -- Alice bought 2 Keyboards
(2, 2, 1), -- Bob bought 1 Smartphone
(2, 3, 1); -- Bob bought 1 Headphones

-- ## ROLL BACK:

-- no sql