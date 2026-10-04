DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS rooms;

CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL,
    available INT NOT NULL
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    guest_name VARCHAR(100) NOT NULL,
    room_id INT REFERENCES rooms(room_id),
    status VARCHAR(20) NOT NULL
);
INSERT INTO rooms (room_type, available)
VALUES
('Single', 2),
('Double', 1),
('Suite', 0);
CREATE OR REPLACE PROCEDURE book_room(p_guest VARCHAR, p_room INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_available INT;
BEGIN
    SELECT available INTO v_available
    FROM rooms
    WHERE room_id = p_room;

    IF v_available > 0 THEN
        UPDATE rooms
        SET available = available - 1
        WHERE room_id = p_room;

        INSERT INTO bookings(guest_name, room_id, status)
        VALUES (p_guest, p_room, 'Booked');

        RAISE NOTICE 'Guest % booked room % successfully', p_guest, p_room;
    ELSE
        RAISE NOTICE 'Room % is not available. Booking failed.', p_room;
    END IF;
END;
$$;
CALL book_room('Alice', 1); -- Single room
CALL book_room('Bob', 2);   -- Double room
CALL book_room('Charlie', 3); -- Suite (fails, no availability)
SELECT * FROM rooms;
SELECT * FROM bookings;