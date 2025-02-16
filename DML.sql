
---DML___


-- Insert sample data into hotels table


Insert into hotel (hotel_name, city, address) values
('radison hotel', 'chittagong', '123 ABC Road, ctg'),
('Chittagong Inn', 'Chittagong', '456 XYZ Road, Chittagong'),
('khulna Palace', 'khulna', '789 PQR Road, khulna'),
('Cox''s Bazar Resort', 'Cox''s Bazar', '101 LMN Road, Cox''s Bazar'),
('feni Lodge', 'feni', '234 DEF Road, feni');

-- Insert sample data into rooms table

INSERT INTO rooms (hotel_id, room_number, room_type_id, price) VALUES
(1, 101, 1, 36000.00),
(1, 102, 2, 5000.00),
(2, 201, 1, 4300.00),
(2, 202, 2, 5400.00),
(3, 301, 1, 60000.00),
(3, 302, 2, 3000.00),
(4, 401, 1, 23000.00),
(4, 402, 2, 11000.00),
(5, 501, 1, 33200.00),
(5, 502, 2, 7500.00);


-- Insert sample data into customers table

Insert into customers (customer_name, email, phone) Values
('qazi faruque', 'qazi60@example.com', '1977338912'),
('adil hossain', 'adil40@example.com', '01977338913'),
('lokman khan', 'lokman30@example.com', '0197733823'),
('tariff', 'tariff30@example.com', '1955338912'),
('hanif hossain', 'hanif90@example.com', '1977336612');


-- Insert sample data into bookings table

Insert into bookings (customer_id, room_id, check_in_date, check_out_date) VALUES
(1, 1, '2025-06-01', '2024-06-05'),
(2, 3, '2025-06-10', '2024-06-15'),
(3, 5, '2025-07-01', '2024-07-05'),
(4, 7, '2025-07-10', '2024-07-15'),
(5, 9, '2025-08-01', '2024-08-05');


-- Insert sample data into room_types table

INSERT INTO room_type (type_name) VALUES
('Standard'),
('high standard');


-- Insert sample data into room_types table

INSERT INTO room_type (type_name) VALUES
('Standard'),
('high standard');


---Query--

SELECT r.room_id, r.room_number, h.hotel_name
FROM rooms r
INNER JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE r.room_id NOT IN (
    SELECT b.room_id
    FROM bookings b
    WHERE @CheckInDate < b.check_out_date
    AND @CheckOutDate > b.check_in_date
);

