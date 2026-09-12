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

-- Insert Orders all User to Orders table
INSERT INTO orders (user_id)
SELECT id FROM users;




-- ## ROLL BACK:

-- Delete all records from the orders table
DELETE FROM orders;
DELETE FROM products;
DELETE FROM users;
