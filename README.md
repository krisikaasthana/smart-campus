# Smart Campus Event & Digital Certificate Management System

## Stack
- Frontend: HTML, CSS, Bootstrap-style custom CSS, JavaScript, Chart.js
- Backend: Flask
- Database: PostgreSQL
- DB driver: psycopg2

## Setup
1. Create PostgreSQL database `smart_campus_events`.
2. Run `database.sql` in pgAdmin Query Tool.
3. Create a Python virtual environment.
4. Install: `pip install -r requirements.txt`
5. If your PostgreSQL password is not `postgres`, set `DB_PASSWORD`.
6. Run: `python app.py`
7. Open http://127.0.0.1:5000

Environment variables:
DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, SECRET_KEY

The SQL file is the user's supplied database script and is included unchanged.
