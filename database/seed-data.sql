-- Seed Data for QA Validation

INSERT INTO users (name, email, status)
VALUES
('Alice Johnson', 'alice@example.com', 'ACTIVE'),
('Bob Silva', 'bob@example.com', 'ACTIVE'),
('Carlos Mendes', 'carlos@example.com', 'INACTIVE'),
('Diana Costa', 'diana@example.com', 'ACTIVE');

INSERT INTO orders (user_id, product_name, amount, status)
VALUES
(1, 'Wireless Mouse', 25.90, 'COMPLETED'),
(1, 'Keyboard', 45.00, 'COMPLETED'),
(2, 'Monitor', 199.99, 'PENDING'),
(2, 'USB Cable', 9.90, 'COMPLETED'),
(3, 'Laptop Stand', 34.50, 'CANCELLED'),
(4, 'Headphones', 79.99, 'COMPLETED');