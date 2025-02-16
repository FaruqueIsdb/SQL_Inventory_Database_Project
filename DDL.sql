
project titel :Hotelmanagement

----DDL----------



Create database [Hotelmanagement]

go

create login omarfaruque with password ='Admin@123', DEFAULT_DATABASE = [Hotelmanagement] ;

go
alter server role serveradmin
add member omarfaruque
go
use  [Hotelmanagement]
go
create role UserRole
go
alter role db_owner
add member UserRole
go
create schema UserSchema
go
grant select,insert, update, delete, execute
on schemas::UserSchema
to UserRole
go
create user omarfaruque  for login omarfaruque
with default_schema=UserSchema
go
alter role UserRole
add member omarfaruque

go


create  table Hotel(
    hotel_id INT PRIMARY KEY identity,
    hotel_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL
);



-- Create rooms table


Create table rooms (
    room_id INT PRIMARY KEY identity,
    hotel_id INT,
    room_number INT,
    room_type_id INT,
    price DECIMAL(8, 2),
    FOREIGN KEY (hotel_ID) REFERENCES hotel(hotel_id) on delete cascade on update cascade,
	unique (hotel_id,room_number )
);

-- Create customers table

create table customers (
customer_id INT PRIMARY KEY identity,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(100),
phone VARCHAR(20)
);




-- Create bookings table

Create table bookings (
 booking_id INT PRIMARY KEY identity,
 customer_id INT,
 room_id INT,
 heck_in_date DATE,
 check_out_date DATE,
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
 FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);




-- Create room_types table

create table room_type (
    room_type_id INT PRIMARY KEY identity,
    type_name VARCHAR(50) NOT NULL
);



-- Create facilities table

Create table facilitie (
    facility_id INT PRIMARY KEY identity,
    facility_name VARCHAR(100) NOT NULL
);


--procedure-------------

go
CREATE PROCEDURE GetBookingsByCustomer
    @CustomerID INT
AS
BEGIN
    SELECT b.booking_id, c.customer_name, h.hotel_name, r.room_number, b.check_in_date, b.check_out_date
    FROM bookings b
    INNER JOIN customers c ON b.customer_id = c.customer_id
    INNER JOIN rooms r ON b.room_id = r.room_id
    INNER JOIN hotel h ON r.hotel_id = h.hotel_id
    WHERE c.customer_id = @CustomerID;
END;

go


---Trigger----------


CREATE TRIGGER PreventDoubleBooking
ON bookings
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN bookings b ON i.room_id = b.room_id
        WHERE i.check_in_date<b.check_out_date
        AND i.check_out_date >b.check_in_date
        AND i.booking_id != b.booking_id
    )
BEGIN
RAISERROR('Room is already booked for this period.',16,1);
rollback transaction;
end
end;
go

--function--
go
CREATE FUNCTION CalculateTotalPrice
(
 @BookingID INT
)
RETURNS  decimal(8, 2)
AS
BEGIN
 DECLARE @TotalPrice DECIMAL(8, 2);

 SELECT @TotalPrice = SUM(price)
 FROM rooms r
 INNER JOIN bookings b ON r.room_id = b.room_id
 WHERE b.booking_id = @BookingID;

RETURN @TotalPrice;
END;
go






------view--------


CREATE VIEw AvailableRooms AS
SELECT r.room_id, r.room_number, h.hotel_name
FROM rooms r
INNER JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE r.room_id NOT IN(
SELECT b.room_id
FROM bookings b
WHERE GETDATE()<b.check_out_date
AND GETDATE()>b.check_in_date
);
go




-- Tabular Function:


go
CREATE FUNCTION GetBookingsByHotel (@HotelID INT)
RETURNS TABLE
AS
RETURN (
SELECT b.booking_id, c.customer_name, h.hotel_name, r.room_number, b.check_in_date, b.check_out_date
FROM bookings b
INNER JOIN customers c ON b.customer_id = c.customer_id
INNER JOIN rooms r ON b.room_id = r.room_id
INNER JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE h.hotel_id = @HotelID
);
go


-- Multi-Statement Function: GetCustomerBookings


CREATE FUNCTION GetCustomerBookings (@CustomerID INT)
RETURNS @Bookings TABLE (
booking_id INT,
hotel_name VARCHAR(100),
room_number INT,
check_in_date DATE,
check_out_date DATE
)
AS
BEGIN
INSERT INTO @Bookings (booking_id, hotel_name, room_number, check_in_date, check_out_date)
SELECT b.booking_id, h.hotel_name, r.room_number, b.check_in_date, b.check_out_date
FROM bookings b
INNER JOIN customers c ON b.customer_id = c.customer_id
INNER JOIN rooms r ON b.room_id = r.room_id
INNER JOIN hotel h ON r.hotel_id = h.hotel_id
WHERE c.customer_id = @CustomerID;
RETURN;
END;
