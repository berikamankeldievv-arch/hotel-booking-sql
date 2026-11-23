-- =====================================================
-- CASE 04: HOTEL BOOKING MANAGEMENT SYSTEM (PostgreSQL)
-- insert.sql  |  алдымен structure.sql іске қосылуы керек
-- =====================================================

-- 1. hotels (5)
INSERT INTO hotels (name, country, city, address, phone, email, star_rating) VALUES
('Almaty Grand Hotel',  'Kazakhstan',     'Almaty',   'Dostyk Ave 100',      '+7 727 111 1111', 'almaty@hotelchain.com',   5),
('Astana Palace',       'Kazakhstan',     'Astana',   'Mangilik El 25',      '+7 717 222 2222', 'astana@hotelchain.com',   5),
('Bosphorus Plaza',     'Turkey',         'Istanbul', 'Istiklal Cad. 50',    '+90 212 333 3333','istanbul@hotelchain.com', 4),
('Desert Pearl Resort', 'UAE',            'Dubai',    'Sheikh Zayed Rd 200', '+971 4 444 4444', 'dubai@hotelchain.com',    5),
('Thames View Hotel',   'United Kingdom', 'London',   'Baker Street 12',     '+44 20 5555 5555','london@hotelchain.com',   4);

-- 2. departments (8)
INSERT INTO departments (name, description) VALUES
('Reception',        'Қонақтарды қабылдау, check-in/check-out'),
('Housekeeping',     'Бөлмелерді тазалау'),
('Maintenance',      'Техникалық қызмет көрсету және жөндеу'),
('Food & Beverage',  'Ас үй және мейрамхана'),
('Management',       'Қонақүй басшылығы'),
('Security',         'Қауіпсіздік қызметі'),
('Spa & Wellness',   'Спа және сауықтыру қызметтері'),
('Finance',          'Бухгалтерия және қаржы');

-- 3. room_types (5)
INSERT INTO room_types (name, description, capacity, base_price) VALUES
('Standard Single', 'Бір кісілік стандартты бөлме', 1,  60.00),
('Standard Double', 'Екі кісілік стандартты бөлме', 2,  90.00),
('Deluxe',          'Кең бөлме, қала көрінісі',     2, 140.00),
('Family',          'Отбасылық бөлме',              4, 180.00),
('Suite',           'Люкс нөмір',                   3, 300.00);

-- 4. services (12)
INSERT INTO services (name, category, price) VALUES
('Breakfast',        'food',      15.00),
('Dinner',           'food',      30.00),
('Room Service',     'food',      20.00),
('Spa Massage',      'spa',       70.00),
('Sauna',            'spa',       25.00),
('Airport Transfer', 'transport', 40.00),
('Taxi',             'transport', 20.00),
('Laundry',          'laundry',   10.00),
('Dry Cleaning',     'laundry',   18.00),
('Mini Bar',         'other',     12.00),
('Late Check-out',   'other',     35.00),
('Gym Access',       'other',      8.00);

-- 5. discounts (6)
INSERT INTO discounts (code, description, discount_percent, valid_from, valid_to) VALUES
('WELCOME10',  'Жаңа қонақтарға',     10, '2025-01-01', '2026-12-31'),
('SUMMER15',   'Жазғы жеңілдік',      15, '2025-06-01', '2025-08-31'),
('WINTER20',   'Қысқы жеңілдік',      20, '2025-12-01', '2026-02-28'),
('LOYALTY25',  'Тұрақты қонақтарға',  25, '2025-01-01', '2026-12-31'),
('EARLYBIRD12','Ерте брондау',        12, '2025-01-01', '2026-12-31'),
('GROUP30',    'Топтық брондау',      30, '2025-01-01', '2026-12-31');

-- 6. employees (150)
INSERT INTO employees (hotel_id, department_id, first_name, last_name, position, email, phone, hire_date, salary, status)
SELECT 1 + (i % 5),
       d,
       (ARRAY['Aidar','Dana','Ali','Aigerim','Timur','Madina','Nursultan','Zhanna','Erlan','Saule'])[1 + i % 10],
       (ARRAY['Akhmetov','Sarsenova','Kenzhebek','Omarova','Nurlan','Bekova','Seitov','Dosova','Ismailov','Karimova'])[1 + (i * 3) % 10],
       (ARRAY['Receptionist','Housekeeper','Technician','Waiter','Manager','Security Guard','Spa Therapist','Accountant'])[d],
       'employee' || i || '@hotelchain.com',
       '+7700' || lpad(i::text, 7, '0'),
       DATE '2018-01-01' + ((i * 17) % 2500),
       800 + ((i * 53) % 2200),
       CASE WHEN i % 25 = 0 THEN 'on_leave' ELSE 'active' END
FROM (SELECT i, 1 + (i % 8) AS d FROM generate_series(1, 150) i) e;

-- 7. rooms (5 қонақүй x 100 = 500)
INSERT INTO rooms (hotel_id, room_type_id, room_number, floor, status)
SELECT h,
       1 + (n % 5),
       (((n - 1) / 10 + 1) * 100 + ((n - 1) % 10 + 1))::text,
       (n - 1) / 10 + 1,
       'available'
FROM generate_series(1, 5) h, generate_series(1, 100) n;

-- 8. guests (350)
INSERT INTO guests (first_name, last_name, email, phone, passport_number, country, birth_date)
SELECT (ARRAY['John','Anna','Mehmet','Fatima','Oliver','Emma','Ahmed','Sofia','Daniel','Laura',
              'Ivan','Olga','Hassan','Chloe','Marco','Yuki','Carlos','Nina','Omar','Elena'])[1 + i % 20],
       (ARRAY['Smith','Ivanova','Yilmaz','Khan','Brown','Wilson','Hassan','Rossi','Garcia','Muller',
              'Petrov','Tanaka','Lopez','Kim','Ali','Novak','Silva','Martin','Popov','Jones'])[1 + (i * 7) % 20],
       'guest' || i || '@mail.com',
       '+1555' || lpad(i::text, 7, '0'),
       'P' || lpad(i::text, 7, '0'),
       (ARRAY['Kazakhstan','Turkey','UAE','United Kingdom','Germany','France','Russia','USA','Japan','Italy'])[1 + i % 10],
       DATE '1950-01-01' + ((i * 37) % 18000)
FROM generate_series(1, 350) i;

-- 9. bookings (400)
INSERT INTO bookings (guest_id, room_id, discount_id, booking_date, check_in_date, check_out_date, status, total_amount)
SELECT b.g,
       b.r,
       b.d,
       b.ci - (b.i % 30 + 1),
       b.ci,
       b.ci + b.nights,
       CASE WHEN b.i % 10 = 0 THEN 'cancelled'
            WHEN b.ci + b.nights < DATE '2026-11-01' THEN 'checked_out'
            ELSE 'confirmed' END,
       ROUND(rt.base_price * b.nights * (1 - COALESCE(dc.discount_percent, 0) / 100), 2)
FROM (
    SELECT i,
           1 + ((i * 11) % 350) AS g,
           1 + ((i * 13) % 500) AS r,
           CASE WHEN i % 5 = 0 THEN 1 + (i % 6) END AS d,
           DATE '2025-01-01' + ((i * 37) % 700) AS ci,
           1 + (i % 7) AS nights
    FROM generate_series(1, 400) i
) b
JOIN rooms ro       ON ro.room_id = b.r
JOIN room_types rt  ON rt.room_type_id = ro.room_type_id
LEFT JOIN discounts dc ON dc.discount_id = b.d;

-- 10. booking_guests (негізгі қонақ + кейбір брондауға қосымша қонақ)
INSERT INTO booking_guests (booking_id, guest_id, is_primary)
SELECT booking_id, guest_id, TRUE FROM bookings;

INSERT INTO booking_guests (booking_id, guest_id, is_primary)
SELECT booking_id, 1 + ((guest_id + 49) % 350), FALSE
FROM bookings
WHERE booking_id % 3 = 0;

-- 11. booking_services (700)
INSERT INTO booking_services (booking_id, service_id, quantity, unit_price, service_date)
SELECT b.booking_id, s.service_id, 1 + (i % 3), s.price, b.check_in_date
FROM generate_series(1, 700) i
JOIN bookings b ON b.booking_id = 1 + ((i * 3) % 400)
JOIN services s ON s.service_id = 1 + (i % 12);

-- 12. payments (бас тартылмаған брондаулар + бас тартылғандардың жартысына refund)
INSERT INTO payments (booking_id, amount, payment_method, payment_status, payment_date)
SELECT booking_id,
       total_amount,
       (ARRAY['cash','card','transfer','online'])[1 + booking_id % 4],
       CASE WHEN status = 'checked_out' THEN 'paid' ELSE 'pending' END,
       booking_date
FROM bookings
WHERE status <> 'cancelled';

INSERT INTO payments (booking_id, amount, payment_method, payment_status, payment_date)
SELECT booking_id, total_amount, 'card', 'refunded', booking_date
FROM bookings
WHERE status = 'cancelled' AND booking_id % 20 = 0;

-- 13. housekeeping (300)
WITH hk AS (
    SELECT array_agg(employee_id ORDER BY employee_id) AS ids
    FROM employees WHERE department_id = 2
)
INSERT INTO housekeeping (room_id, employee_id, cleaning_date, status, notes)
SELECT 1 + ((i * 7) % 500),
       hk.ids[1 + i % array_length(hk.ids, 1)],
       DATE '2025-01-01' + ((i * 3) % 700),
       CASE WHEN i % 10 = 0 THEN 'planned'
            WHEN i % 10 = 1 THEN 'in_progress'
            ELSE 'done' END,
       CASE WHEN i % 4 = 0 THEN 'Толық тазалау' ELSE NULL END
FROM generate_series(1, 300) i, hk;

-- 14. maintenance (120)
WITH mt AS (
    SELECT array_agg(employee_id ORDER BY employee_id) AS ids
    FROM employees WHERE department_id = 3
)
INSERT INTO maintenance (room_id, employee_id, issue_description, reported_date, resolved_date, status, cost)
SELECT m.room_id,
       mt.ids[1 + m.i % array_length(mt.ids, 1)],
       m.issue,
       m.rep,
       CASE WHEN m.i % 4 >= 2 THEN m.rep + (1 + m.i % 10) END,
       CASE WHEN m.i % 4 = 0 THEN 'open'
            WHEN m.i % 4 = 1 THEN 'in_progress'
            ELSE 'resolved' END,
       CASE WHEN m.i % 4 >= 2 THEN 50 + ((m.i * 37) % 450) ELSE 0 END
FROM (
    SELECT i,
           1 + ((i * 11) % 500) AS room_id,
           (ARRAY['Кондиционер бұзылған','Су құбыры ағып жатыр','Жарық жұмыс істемейді',
                  'Теледидар бұзылған','Есік құлпы істен шыққан','Қыздыру жүйесі'])[1 + i % 6] AS issue,
           DATE '2025-01-01' + ((i * 5) % 650) AS rep
    FROM generate_series(1, 120) i
) m, mt;

-- 15. reviews (аяқталған брондаулардың жартысына)
INSERT INTO reviews (booking_id, guest_id, rating, comment, review_date)
SELECT booking_id,
       guest_id,
       r,
       CASE r WHEN 5 THEN 'Тамаша қызмет, міндетті түрде қайта келемін'
              WHEN 4 THEN 'Жақсы қонақүй'
              WHEN 3 THEN 'Орташа, жақсартуға болады'
              ELSE 'Қызмет сапасы төмен' END,
       check_out_date + 1
FROM (
    SELECT booking_id, guest_id, check_out_date,
           CASE WHEN booking_id % 11 = 0 THEN 2
                WHEN booking_id % 7  = 0 THEN 3
                WHEN booking_id % 3  = 0 THEN 4
                ELSE 5 END AS r
    FROM bookings
    WHERE status = 'checked_out' AND booking_id % 2 = 0
) x;

-- =====================================================
-- ТЕКСЕРУ: әр кестедегі жазба саны
-- =====================================================
SELECT 'hotels' AS table_name, COUNT(*) AS rows FROM hotels
UNION ALL SELECT 'departments',      COUNT(*) FROM departments
UNION ALL SELECT 'room_types',       COUNT(*) FROM room_types
UNION ALL SELECT 'rooms',            COUNT(*) FROM rooms
UNION ALL SELECT 'guests',           COUNT(*) FROM guests
UNION ALL SELECT 'employees',        COUNT(*) FROM employees
UNION ALL SELECT 'services',         COUNT(*) FROM services
UNION ALL SELECT 'discounts',        COUNT(*) FROM discounts
UNION ALL SELECT 'bookings',         COUNT(*) FROM bookings
UNION ALL SELECT 'booking_guests',   COUNT(*) FROM booking_guests
UNION ALL SELECT 'booking_services', COUNT(*) FROM booking_services
UNION ALL SELECT 'payments',         COUNT(*) FROM payments
UNION ALL SELECT 'housekeeping',     COUNT(*) FROM housekeeping
UNION ALL SELECT 'maintenance',      COUNT(*) FROM maintenance
UNION ALL SELECT 'reviews',          COUNT(*) FROM reviews;
