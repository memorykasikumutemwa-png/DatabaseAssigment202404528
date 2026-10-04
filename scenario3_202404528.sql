DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL
);

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    doctor_name VARCHAR(100) NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL
);
INSERT INTO patients (patient_name)
VALUES
('John Banda'),
('Mary Phiri'),
('Peter Z
ulu');
CREATE OR REPLACE PROCEDURE book_appointment(p_patient INT, p_doctor VARCHAR, p_date DATE)
LANGUAGE plpgsql AS $$
DECLARE
    v_count INT;
BEGIN
    -- Check if doctor already has an appointment on that date
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE doctor_name = p_doctor
      AND appointment_date = p_date
      AND status = 'Booked';

    IF v_count = 0 THEN
        INSERT INTO appointments(patient_id, doctor_name, appointment_date, status)
        VALUES (p_patient, p_doctor, p_date, 'Booked');

        RAISE NOTICE 'Appointment booked for patient % with doctor % on %', p_patient, p_doctor, p_date;
    ELSE
        RAISE NOTICE 'Doctor % already has an appointment on %', p_doctor, p_date;
    END IF;
END;
$$;
CALL book_appointment(1, 'Dr. Mwansa', '2026-10-05');
CALL book_appointment(2, 'Dr. Mwansa', '2026-10-05'); -- should fail (already booked)
CALL book_appointment(3, 'Dr. Phiri', '2026-10-06');
SELECT * FROM appointments;