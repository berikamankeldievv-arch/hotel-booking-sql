-- =====================================================
-- CASE 04: HOTEL BOOKING MANAGEMENT SYSTEM (PostgreSQL)
-- queries.sql  |  алдымен structure.sql, содан кейін insert.sql іске қосылуы керек
-- Әр сұранысты бөлек таңдап, Ctrl+Enter арқылы іске қосыңыз
-- =====================================================

-- =====================================================
-- 1. СҮЗУ ЖӘНЕ ШЫҒАРУ (8 SELECT)
-- =====================================================

-- 1.1 Қазақстандағы қонақүйлер (WHERE)
SELECT hotel_id, name, city, star_rating
FROM hotels
WHERE country = 'Kazakhstan';

-- 1.2 Қонақтар өкілдік ететін елдер (DISTINCT, ORDER BY)
SELECT DISTINCT country
FROM guests
ORDER BY country;

-- 1.3 1-қонақүйдің 3-6 қабатындағы бөлмелер (AND, BETWEEN, LIMIT)
SELECT room_id, room_number, floor, status
FROM rooms
WHERE hotel_id = 1 AND floor BETWEEN 3 AND 6
ORDER BY floor, room_number
LIMIT 20;

-- 1.4 Құны 500-ден жоғары белсенді брондаулар (IN, ORDER BY)
SELECT booking_id, guest_id, status, total_amount
FROM bookings
WHERE status IN ('confirmed', 'checked_in') AND total_amount > 500
ORDER BY total_amount DESC;

-- 1.5 Тегі S әрпінен басталатын, бірақ Қазақстаннан емес қонақтар (LIKE, NOT)
SELECT guest_id, first_name, last_name, country
FROM guests
WHERE last_name LIKE 'S%' AND NOT country = 'Kazakhstan'
ORDER BY last_name;

-- 1.6 2025 жылғы жазғы брондаулар (BETWEEN, <>)
SELECT booking_id, check_in_date, check_out_date, status
FROM bookings
WHERE check_in_date BETWEEN '2025-06-01' AND '2025-08-31'
  AND status <> 'cancelled'
ORDER BY check_in_date
LIMIT 15;

-- 1.6.1 Жалақысы 1500-2500 аралығындағы белсенді қызметкерлер (BETWEEN, AND)
SELECT employee_id, first_name, last_name, position, salary
FROM employees
WHERE salary BETWEEN 1500 AND 2500 AND status = 'active'
ORDER BY salary DESC
LIMIT 10;

-- 1.7 Спа және тамақ қызметтері, бағасы 20-дан жоғары (IN, OR-ға балама)
SELECT service_id, name, category, price
FROM services
WHERE category IN ('spa', 'food') AND price >= 20
ORDER BY price DESC;

-- =====================================================
-- 2. АГРЕГАТТАУ (5 сұраныс)
-- =====================================================

-- 2.1 Барлық брондау саны (COUNT)
SELECT COUNT(*) AS total_bookings FROM bookings;

-- 2.2 Аяқталған брондаулардың жалпы табысы (SUM)
SELECT SUM(total_amount) AS total_revenue
FROM bookings
WHERE status = 'checked_out';

-- 2.3 Бөлме түрлерінің орташа бағасы (AVG)
SELECT ROUND(AVG(base_price), 2) AS avg_room_price FROM room_types;

-- 2.4 Ең арзан және ең қымбат брондау (MIN, MAX)
SELECT MIN(total_amount) AS min_booking, MAX(total_amount) AS max_booking
FROM bookings
WHERE status <> 'cancelled';

-- 2.5 Брондау жасаған бірегей қонақтар саны (COUNT DISTINCT)
SELECT COUNT(DISTINCT guest_id) AS unique_guests FROM bookings;

-- =====================================================
-- 3. ТОПТАУ ЖӘНЕ СҮЗУ (5 GROUP BY + 5 HAVING)
-- =====================================================

-- 3.1 Брондаулар саны статус бойынша
SELECT status, COUNT(*) AS bookings_count
FROM bookings
GROUP BY status
HAVING COUNT(*) > 10
ORDER BY bookings_count DESC;

-- 3.2 Төлем әдістері бойынша табыс (WHERE + HAVING)
SELECT payment_method, COUNT(*) AS payments_count, SUM(amount) AS total_paid
FROM payments
WHERE payment_status = 'paid'
GROUP BY payment_method
HAVING SUM(amount) > 10000
ORDER BY total_paid DESC;

-- 3.3 Бөлімдер бойынша қызметкерлер саны және орташа жалақы
SELECT d.name AS department, COUNT(e.employee_id) AS employees_count,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY d.name
HAVING COUNT(e.employee_id) > 15 AND AVG(e.salary) > 1500
ORDER BY avg_salary DESC;

-- 3.4 Елдер бойынша қонақтар саны
SELECT country, COUNT(*) AS guests_count
FROM guests
GROUP BY country
HAVING COUNT(*) > 30
ORDER BY guests_count DESC;

-- 3.5 Қосымша қызметтер бойынша түскен табыс (WHERE + HAVING)
SELECT s.name, SUM(bs.quantity) AS total_quantity,
       SUM(bs.quantity * bs.unit_price) AS service_revenue
FROM booking_services bs
JOIN services s ON s.service_id = bs.service_id
WHERE bs.quantity >= 1
GROUP BY s.name
HAVING SUM(bs.quantity * bs.unit_price) > 1000
ORDER BY service_revenue DESC;

-- =====================================================
-- 4. РЕЛЯЦИЯЛЫҚ JOIN (8 сұраныс)
-- =====================================================

-- 4.1 INNER JOIN (4 кесте): брондау, қонақ, бөлме, қонақүй
SELECT b.booking_id, g.first_name || ' ' || g.last_name AS guest,
       h.name AS hotel, r.room_number, b.check_in_date, b.total_amount
FROM bookings b
INNER JOIN guests g ON g.guest_id = b.guest_id
INNER JOIN rooms r  ON r.room_id = b.room_id
INNER JOIN hotels h ON h.hotel_id = r.hotel_id
ORDER BY b.booking_id
LIMIT 20;

-- 4.2 INNER JOIN (3 кесте): қонақүй бойынша бөлме түрлері
SELECT h.name AS hotel, rt.name AS room_type, COUNT(*) AS rooms_count, rt.base_price
FROM rooms r
INNER JOIN hotels h      ON h.hotel_id = r.hotel_id
INNER JOIN room_types rt ON rt.room_type_id = r.room_type_id
GROUP BY h.name, rt.name, rt.base_price
ORDER BY h.name, rt.base_price;

-- 4.3 LEFT JOIN: ешқашан брондалмаған бөлмелер
SELECT r.room_id, r.room_number, h.name AS hotel
FROM rooms r
LEFT JOIN bookings b ON b.room_id = r.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
WHERE b.booking_id IS NULL
ORDER BY h.name, r.room_number
LIMIT 20;

-- 4.4 LEFT JOIN: пікірі жоқ аяқталған брондаулар саны
SELECT COUNT(*) AS bookings_without_review
FROM bookings b
LEFT JOIN reviews rv ON rv.booking_id = b.booking_id
WHERE b.status = 'checked_out' AND rv.review_id IS NULL;

-- 4.5 RIGHT JOIN: төлемі жоқ брондаулар
SELECT b.booking_id, b.status, b.total_amount
FROM payments p
RIGHT JOIN bookings b ON b.booking_id = p.booking_id
WHERE p.payment_id IS NULL
ORDER BY b.booking_id
LIMIT 20;

-- 4.6 RIGHT JOIN: жеңілдік кодтарының қолданылуы
SELECT d.code, d.discount_percent, COUNT(b.booking_id) AS times_used
FROM bookings b
RIGHT JOIN discounts d ON d.discount_id = b.discount_id
GROUP BY d.code, d.discount_percent
ORDER BY times_used DESC;

-- 4.7 FULL OUTER JOIN: бөлмелер мен брондаулар сәйкестігі
SELECT COUNT(r.room_id)    AS rooms_total,
       COUNT(b.booking_id) AS bookings_total,
       COUNT(*) FILTER (WHERE b.booking_id IS NULL) AS rooms_without_booking,
       COUNT(*) FILTER (WHERE r.room_id IS NULL)    AS bookings_without_room
FROM rooms r
FULL OUTER JOIN bookings b ON b.room_id = r.room_id;

-- 4.8 INNER JOIN (4 кесте): қонақтардың қосымша қызметтерге жұмсаған сомасы (топ-10)
SELECT g.guest_id, g.first_name || ' ' || g.last_name AS guest,
       SUM(bs.quantity * bs.unit_price) AS services_spent
FROM booking_services bs
JOIN bookings b ON b.booking_id = bs.booking_id
JOIN guests g   ON g.guest_id = b.guest_id
JOIN services s ON s.service_id = bs.service_id
GROUP BY g.guest_id, guest
ORDER BY services_spent DESC
LIMIT 10;

-- =====================================================
-- 5. ШАРТТЫ ЛОГИКА (4 CASE)
-- =====================================================

-- 5.1 Брондауларды құны бойынша сегменттеу
SELECT booking_id, total_amount,
       CASE WHEN total_amount < 300  THEN 'Economy'
            WHEN total_amount < 800  THEN 'Standard'
            ELSE 'Premium' END AS segment
FROM bookings
WHERE status <> 'cancelled'
ORDER BY total_amount DESC
LIMIT 20;

-- 5.2 Тұру ұзақтығы бойынша санаттау
SELECT booking_id, (check_out_date - check_in_date) AS nights,
       CASE WHEN check_out_date - check_in_date <= 2 THEN 'Short stay'
            WHEN check_out_date - check_in_date <= 5 THEN 'Medium stay'
            ELSE 'Long stay' END AS stay_type
FROM bookings
ORDER BY booking_id
LIMIT 20;

-- 5.3 Пікір бағасын мәтіндік статусқа айналдыру
SELECT review_id, rating,
       CASE rating WHEN 5 THEN 'Excellent'
                   WHEN 4 THEN 'Good'
                   WHEN 3 THEN 'Average'
                   ELSE 'Poor' END AS rating_label
FROM reviews
ORDER BY review_id
LIMIT 20;

-- 5.4 Қызметкерлерге бонус есептеу (жалақыға байланысты)
SELECT employee_id, first_name, last_name, salary,
       CASE WHEN salary >= 2500 THEN ROUND(salary * 0.05, 2)
            WHEN salary >= 1500 THEN ROUND(salary * 0.10, 2)
            ELSE ROUND(salary * 0.15, 2) END AS bonus
FROM employees
ORDER BY salary DESC
LIMIT 20;

-- =====================================================
-- 6. ДЕРЕКТЕРДІ БАСҚАРУ (2 UPDATE, 1 DELETE, 2 ALTER, 1 DROP)
-- =====================================================

-- 6.1 UPDATE: ашық ақауы бар бөлмелерді "maintenance" статусына ауыстыру
UPDATE rooms
SET status = 'maintenance'
WHERE room_id IN (SELECT room_id FROM maintenance WHERE status IN ('open', 'in_progress'));

-- 6.2 UPDATE: ресепшн қызметкерлерінің жалақысын 10%-ға көтеру
UPDATE employees
SET salary = ROUND(salary * 1.10, 2)
WHERE department_id = 1 AND status = 'active';

-- 6.3 DELETE: 2025 жылдың наурызына дейінгі жоспарланған (орындалмаған) тазалау жазбаларын жою
DELETE FROM housekeeping
WHERE status = 'planned' AND cleaning_date < '2025-03-01';

-- 6.4 ALTER TABLE: қонақтарға адалдық ұпайлары бағанын қосу
ALTER TABLE guests
ADD COLUMN loyalty_points INT DEFAULT 0 CHECK (loyalty_points >= 0);

-- 6.5 ALTER TABLE: қонақүй телефонын міндетті ету
ALTER TABLE hotels
ALTER COLUMN phone SET NOT NULL;

-- 6.6 DROP TABLE: уақытша кестені жасап, кейін жою
CREATE TABLE temp_report AS
SELECT status, COUNT(*) AS cnt FROM bookings GROUP BY status;

DROP TABLE temp_report;

-- =====================================================
-- 7. ҚОРЫТЫНДЫ АНАЛИТИКАЛЫҚ ЕСЕП (10 есеп)
-- =====================================================

-- 7.1 Бөлмелердің толық пайызы (Occupancy Rate), 2025 жыл, қонақүй бойынша
-- Ескерту: тест деректері аз болғандықтан пайыз төмен шығады
SELECT h.name AS hotel,
       COUNT(DISTINCT r.room_id) AS total_rooms,
       COALESCE(SUM(GREATEST(0, LEAST(b.check_out_date, DATE '2026-01-01')
                              - GREATEST(b.check_in_date, DATE '2025-01-01'))), 0) AS occupied_nights,
       ROUND(COALESCE(SUM(GREATEST(0, LEAST(b.check_out_date, DATE '2026-01-01')
                              - GREATEST(b.check_in_date, DATE '2025-01-01'))), 0)
             / (COUNT(DISTINCT r.room_id) * 365.0) * 100, 2) AS occupancy_rate_pct
FROM hotels h
JOIN rooms r ON r.hotel_id = h.hotel_id
LEFT JOIN bookings b ON b.room_id = r.room_id AND b.status <> 'cancelled'
GROUP BY h.hotel_id, h.name
ORDER BY occupancy_rate_pct DESC;

-- 7.2 Орташа тұру ұзақтығы қонақүй бойынша
SELECT h.name AS hotel, ROUND(AVG(b.check_out_date - b.check_in_date), 2) AS avg_nights
FROM bookings b
JOIN rooms r  ON r.room_id = b.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
WHERE b.status <> 'cancelled'
GROUP BY h.name
ORDER BY avg_nights DESC;

-- 7.3 Бас тартылған брондаулар үлесі қонақүй бойынша
SELECT h.name AS hotel,
       COUNT(*) AS total_bookings,
       COUNT(*) FILTER (WHERE b.status = 'cancelled') AS cancelled,
       ROUND(COUNT(*) FILTER (WHERE b.status = 'cancelled') * 100.0 / COUNT(*), 2) AS cancel_rate_pct
FROM bookings b
JOIN rooms r  ON r.room_id = b.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
GROUP BY h.name
ORDER BY cancel_rate_pct DESC;

-- 7.4 Маусымдық табыс (жыл және маусым бойынша)
SELECT EXTRACT(YEAR FROM check_in_date)::int AS year,
       CASE WHEN EXTRACT(MONTH FROM check_in_date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM check_in_date) IN (3, 4, 5)  THEN 'Spring'
            WHEN EXTRACT(MONTH FROM check_in_date) IN (6, 7, 8)  THEN 'Summer'
            ELSE 'Autumn' END AS season,
       COUNT(*) AS bookings_count,
       SUM(total_amount) AS revenue
FROM bookings
WHERE status = 'checked_out'
GROUP BY 1, 2
ORDER BY 1, revenue DESC;

-- 7.5 Ең көп жұмсаған 10 қонақ (бөлме + қосымша қызметтер)
WITH room_spend AS (
    SELECT guest_id, SUM(total_amount) AS room_total
    FROM bookings
    WHERE status = 'checked_out'
    GROUP BY guest_id
),
service_spend AS (
    SELECT b.guest_id, SUM(bs.quantity * bs.unit_price) AS service_total
    FROM booking_services bs
    JOIN bookings b ON b.booking_id = bs.booking_id
    WHERE b.status = 'checked_out'
    GROUP BY b.guest_id
)
SELECT g.guest_id, g.first_name || ' ' || g.last_name AS guest,
       COALESCE(r.room_total, 0)    AS room_total,
       COALESCE(s.service_total, 0) AS service_total,
       COALESCE(r.room_total, 0) + COALESCE(s.service_total, 0) AS total_spent
FROM guests g
LEFT JOIN room_spend r    ON r.guest_id = g.guest_id
LEFT JOIN service_spend s ON s.guest_id = g.guest_id
ORDER BY total_spent DESC
LIMIT 10;

-- 7.6 Қонақүйлер бойынша табыс
SELECT h.name AS hotel, COUNT(b.booking_id) AS completed_bookings,
       SUM(b.total_amount) AS revenue
FROM hotels h
JOIN rooms r    ON r.hotel_id = h.hotel_id
JOIN bookings b ON b.room_id = r.room_id
WHERE b.status = 'checked_out'
GROUP BY h.hotel_id, h.name
ORDER BY revenue DESC;

-- 7.7 Ең танымал бөлме түрлері
SELECT rt.name AS room_type, COUNT(b.booking_id) AS bookings_count,
       SUM(b.total_amount) AS revenue
FROM bookings b
JOIN rooms r        ON r.room_id = b.room_id
JOIN room_types rt  ON rt.room_type_id = r.room_type_id
WHERE b.status <> 'cancelled'
GROUP BY rt.name
ORDER BY bookings_count DESC;

-- 7.8 Қосымша қызмет санаттары бойынша табыс
SELECT s.category, SUM(bs.quantity) AS total_units,
       SUM(bs.quantity * bs.unit_price) AS revenue
FROM booking_services bs
JOIN services s ON s.service_id = bs.service_id
GROUP BY s.category
ORDER BY revenue DESC;

-- 7.9 Қонақүйлердің орташа пікір бағасы
SELECT h.name AS hotel, COUNT(rv.review_id) AS reviews_count,
       ROUND(AVG(rv.rating), 2) AS avg_rating
FROM reviews rv
JOIN bookings b ON b.booking_id = rv.booking_id
JOIN rooms r    ON r.room_id = b.room_id
JOIN hotels h   ON h.hotel_id = r.hotel_id
GROUP BY h.name
ORDER BY avg_rating DESC;

-- 7.10 Жөндеу шығыны және шешілмеген ақаулар қонақүй бойынша
SELECT h.name AS hotel,
       COUNT(*) AS total_issues,
       COUNT(*) FILTER (WHERE m.status <> 'resolved') AS unresolved_issues,
       SUM(m.cost) AS total_repair_cost
FROM maintenance m
JOIN rooms r  ON r.room_id = m.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
GROUP BY h.name
ORDER BY total_repair_cost DESC;
