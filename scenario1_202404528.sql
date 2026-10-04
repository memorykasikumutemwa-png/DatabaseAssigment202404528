DROP TABLE IF EXISTS book_loans;
DROP TABLE IF EXISTS books;
-- Books table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    available_copies INT NOT NULL
);

-- Book loans table
CREATE TABLE book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    book_id INT REFERENCES books(book_id),
    quantity INT NOT NULL,
    status VARCHAR(20) NOT NULL
);
CREATE OR REPLACE FUNCTION check_book_stock(p_book_id INT)
RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    v_copies INT;
    v_message TEXT;
BEGIN
    SELECT available_copies INTO v_copies
    FROM books
    WHERE book_id = p_book_id;

    IF v_copies = 0 THEN
        v_message := 'Book is unavailable';
    ELSIF v_copies <= 2 THEN
        v_message := 'Book is low on copies';
    ELSE
        v_message := 'Book is sufficiently stocked';
    END IF;

    RETURN v_message;
END;
$$;
SELECT check_book_stock(1); -- Database Systems (5 copies)
SELECT check_book_stock(2); -- Operating Systems (2 copies)
SELECT check_book_stock(3); -- Computer Networks (0 copies)
DO $$
DECLARE
    counter INT := 1;
BEGIN
    -- WHILE loop for reminders
    WHILE counter <= 3 LOOP
        RAISE NOTICE 'Reminder %: Return overdue books!', counter;
        counter := counter + 1;
    END LOOP;

    -- Numeric FOR loop for shelf numbers
    FOR shelf IN 1..3 LOOP
        RAISE NOTICE 'Shelf number: %', shelf;
    END LOOP;
END;
$$;
DROP TABLE IF EXISTS book_loans;
CREATE TABLE book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    book_id INT REFERENCES books(book_id),
    quantity INT NOT NULL,
    status VARCHAR(20) NOT NULL
);
CREATE OR REPLACE PROCEDURE borrow_book(p_student VARCHAR, p_book INT, p_qty INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_copies INT;
BEGIN
    -- Check invalid quantity
    IF p_qty <= 0 THEN
        RAISE EXCEPTION 'Invalid quantity requested';
    END IF;

    -- Get current stock
    SELECT available_copies INTO v_copies
    FROM books
    WHERE book_id = p_book;

    -- Check availability
    IF v_copies >= p_qty THEN
        UPDATE books
        SET available_copies = available_copies - p_qty
        WHERE book_id = p_book;

        INSERT INTO book_loans(student_number, book_id, quantity, status)
        VALUES (p_student, p_book, p_qty, 'Borrowed');
    ELSE
        RAISE NOTICE 'Not enough copies available for book %', p_book;
    END IF;
END;
$$;
CALL borrow_book('STU001', 1, 2); -- valid: Database Systems (5 → 3 copies)
CALL borrow_book('STU002', 2, 1); -- valid: Operating Systems (2 → 1 copy)
CALL borrow_book('STU003', 3, 1); -- invalid: Computer Networks (0 copies)
SELECT * FROM books;
SELECT * FROM book_loans;
CREATE OR REPLACE PROCEDURE return_book(p_loan_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_book INT;
    v_qty INT;
    v_status VARCHAR(20);
BEGIN
    -- Get loan details
    SELECT book_id, quantity, status
    INTO v_book, v_qty, v_status
    FROM book_loans
    WHERE loan_id = p_loan_id;

    -- Check if already returned
    IF v_status = 'Returned' THEN
        RAISE NOTICE 'Loan % has already been returned', p_loan_id;
    ELSE
        -- Update stock
        UPDATE books
        SET available_copies = available_copies + v_qty
        WHERE book_id = v_book;

        -- Update loan status
        UPDATE book_loans
        SET status = 'Returned'
        WHERE loan_id = p_loan_id;

        RAISE NOTICE 'Loan % returned successfully', p_loan_id;
    END IF;
END;
$$;
CALL return_book(1); -- STU001’s loan
CALL return_book(2); -- STU002’s loan
SELECT * FROM books;
SELECT * FROM book_loans;
CALL return_book(2); -- Try returning again (should show notice)