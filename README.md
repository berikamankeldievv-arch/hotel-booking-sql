# Hotel Booking Management System

**SQL және деректер қорын басқару | Case 04**
ДҚБЖ: **PostgreSQL**

## Жоба сипаттамасы

Халықаралық қонақүй желісін басқаруға арналған реляциялық дерекқор. Жүйе қонақүйлерді, бөлмелерді, қонақтарды, брондауларды, қосымша қызметтерді, төлемдерді, қызметкерлерді, тазалау мен жөндеу жұмыстарын, пікірлер мен жеңілдіктерді сақтайды.

**Бизнес-функциялар:** бос бөлмелерді іздеу, брондау жасау, check-in/check-out тіркеу, қосымша қызметтер есебі, бөлме тазалығын бақылау.

**Аналитикалық есептер:** бөлмелердің толу пайызы (Occupancy Rate), орташа тұру ұзақтығы, бас тартылған брондар, маусымдық табыс және т.б.

## Дерекқор құрылымы (15 кесте)

| Топ | Кестелер |
|---|---|
| Анықтамалықтар | `hotels`, `departments`, `room_types`, `services`, `discounts` |
| Қонақтар мен қызметкерлер | `guests`, `employees` |
| Негізгі транзакциялар | `rooms`, `bookings`, `payments` |
| Байланыс кестелері (M:M) | `booking_guests`, `booking_services` |
| Операциялық | `housekeeping`, `maintenance` |
| Қосымша | `reviews` |

**Негізгі байланыстар:**
- `hotels` → `rooms`, `employees` (1:M)
- `room_types` → `rooms` (1:M)
- `departments` → `employees` (1:M)
- `guests` → `bookings` (1:M)
- `bookings` → `payments` (1:M), `bookings` → `reviews` (1:1)
- `bookings` ↔ `guests` (M:M, `booking_guests` арқылы)
- `bookings` ↔ `services` (M:M, `booking_services` арқылы)

## Файлдар

| Файл | Мазмұны |
|---|---|
| `structure.sql` | CREATE TABLE командалары (PK, FK, NOT NULL, UNIQUE, DEFAULT, CHECK) |
| `insert.sql` | Тест деректері (500 бөлме, 350 қонақ, 400 брондау және т.б.) |
| `queries.sql` | SELECT, JOIN, GROUP BY, CASE, UPDATE/DELETE/ALTER/DROP және 10 аналитикалық есеп |

## Іске қосу

1. PostgreSQL дерекқорын жасаңыз: `CREATE DATABASE hotel_db;`
2. `hotel_db` ішінде файлдарды ретімен іске қосыңыз:
   1. `structure.sql`
   2. `insert.sql`
   3. `queries.sql`

## Авторы

Аты-жөні: _осы жерге жазыңыз_
Курс: SQL және деректер қорын басқару
