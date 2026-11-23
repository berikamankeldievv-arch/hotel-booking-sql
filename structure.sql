-- =====================================================
-- CASE 04: HOTEL BOOKING MANAGEMENT SYSTEM (PostgreSQL)
-- structure.sql  |  15 кесте
-- =====================================================

DROP TABLE IF EXISTS reviews, maintenance, housekeeping, payments,
    booking_services, booking_guests, bookings, discounts, guests,
    services, rooms, room_types, employees, departments, hotels CASCADE;

-- 1. hotels
CREATE TABLE hotels (
    hotel_id     SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    country      VARCHAR(60)  NOT NULL,
    city         VARCHAR(60)  NOT NULL,
    address      VARCHAR(200) NOT NULL,
    phone        VARCHAR(30),
    email        VARCHAR(100) UNIQUE,
    star_rating  SMALLINT NOT NULL DEFAULT 3 CHECK (star_rating BETWEEN 1 AND 5),
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. departments
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name          VARCHAR(80) NOT NULL UNIQUE,
    description   VARCHAR(200)
);

-- 3. employees
CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    hotel_id      INT NOT NULL REFERENCES hotels(hotel_id),
    department_id INT NOT NULL REFERENCES departments(department_id),
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    position      VARCHAR(80) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(30),
    hire_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    salary        NUMERIC(10,2) NOT NULL CHECK (salary > 0),
    status        VARCHAR(20) NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','on_leave','fired'))
);

-- 4. room_types
CREATE TABLE room_types (
    room_type_id SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL UNIQUE,
    description  VARCHAR(200),
    capacity     SMALLINT NOT NULL CHECK (capacity > 0),
    base_price   NUMERIC(10,2) NOT NULL CHECK (base_price >= 0)
);

-- 5. rooms
CREATE TABLE rooms (
    room_id      SERIAL PRIMARY KEY,
    hotel_id     INT NOT NULL REFERENCES hotels(hotel_id),
    room_type_id INT NOT NULL REFERENCES room_types(room_type_id),
    room_number  VARCHAR(10) NOT NULL,
    floor        SMALLINT NOT NULL CHECK (floor >= 0),
    status       VARCHAR(20) NOT NULL DEFAULT 'available'
                 CHECK (status IN ('available','occupied','cleaning','maintenance')),
    UNIQUE (hotel_id, room_number)
);

-- 6. guests
CREATE TABLE guests (
    guest_id        SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    phone           VARCHAR(30),
    passport_number VARCHAR(30) UNIQUE,
    country         VARCHAR(60),
    birth_date      DATE CHECK (birth_date < CURRENT_DATE),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. discounts
CREATE TABLE discounts (
    discount_id      SERIAL PRIMARY KEY,
    code             VARCHAR(30) NOT NULL UNIQUE,
    description      VARCHAR(200),
    discount_percent NUMERIC(5,2) NOT NULL CHECK (discount_percent BETWEEN 0 AND 100),
    valid_from       DATE NOT NULL,
    valid_to         DATE NOT NULL,
    CHECK (valid_to >= valid_from)
);

-- 8. bookings
CREATE TABLE bookings (
    booking_id     SERIAL PRIMARY KEY,
    guest_id       INT NOT NULL REFERENCES guests(guest_id),      -- негізгі қонақ
    room_id        INT NOT NULL REFERENCES rooms(room_id),
    discount_id    INT REFERENCES discounts(discount_id),
    booking_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_in_date  DATE NOT NULL,
    check_out_date DATE NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'confirmed'
                   CHECK (status IN ('confirmed','checked_in','checked_out','cancelled')),
    total_amount   NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    CHECK (check_out_date > check_in_date)
);

-- 9. booking_guests (M:M: bookings <-> guests)
CREATE TABLE booking_guests (
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    guest_id   INT NOT NULL REFERENCES guests(guest_id),
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (booking_id, guest_id)
);

-- 10. services
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name       VARCHAR(80) NOT NULL UNIQUE,
    category   VARCHAR(40) NOT NULL
               CHECK (category IN ('food','spa','transport','laundry','other')),
    price      NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

-- 11. booking_services (M:M: bookings <-> services)
CREATE TABLE booking_services (
    booking_service_id SERIAL PRIMARY KEY,
    booking_id   INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    service_id   INT NOT NULL REFERENCES services(service_id),
    quantity     SMALLINT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    service_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 12. payments
CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    booking_id     INT NOT NULL REFERENCES bookings(booking_id),
    amount         NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20) NOT NULL
                   CHECK (payment_method IN ('cash','card','transfer','online')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'paid'
                   CHECK (payment_status IN ('paid','pending','refunded','failed')),
    payment_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. housekeeping
CREATE TABLE housekeeping (
    housekeeping_id SERIAL PRIMARY KEY,
    room_id         INT NOT NULL REFERENCES rooms(room_id),
    employee_id     INT NOT NULL REFERENCES employees(employee_id),
    cleaning_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'done'
                    CHECK (status IN ('planned','in_progress','done')),
    notes           VARCHAR(200)
);

-- 14. maintenance
CREATE TABLE maintenance (
    maintenance_id    SERIAL PRIMARY KEY,
    room_id           INT NOT NULL REFERENCES rooms(room_id),
    employee_id       INT REFERENCES employees(employee_id),
    issue_description VARCHAR(250) NOT NULL,
    reported_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    resolved_date     DATE,
    status            VARCHAR(20) NOT NULL DEFAULT 'open'
                      CHECK (status IN ('open','in_progress','resolved')),
    cost              NUMERIC(10,2) DEFAULT 0 CHECK (cost >= 0),
    CHECK (resolved_date IS NULL OR resolved_date >= reported_date)
);

-- 15. reviews
CREATE TABLE reviews (
    review_id   SERIAL PRIMARY KEY,
    booking_id  INT NOT NULL UNIQUE REFERENCES bookings(booking_id),
    guest_id    INT NOT NULL REFERENCES guests(guest_id),
    rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     VARCHAR(500),
    review_date DATE NOT NULL DEFAULT CURRENT_DATE
);
