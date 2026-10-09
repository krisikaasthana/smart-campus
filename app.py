import os
from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "smart-campus-dev-key")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "smart_campus_events"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def fetch_one(sql, params=()):
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, params)
        return cur.fetchone()

def fetch_all(sql, params=()):
    with get_conn() as conn, conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, params)
        return cur.fetchall()

def execute(sql, params=()):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute(sql, params)

@app.route("/")
def dashboard():
    try:
        stats = {
            "students": fetch_one("SELECT COUNT(*) AS n FROM student;")["n"],
            "events": fetch_one("SELECT COUNT(*) AS n FROM event;")["n"],
            "registrations": fetch_one("SELECT COUNT(*) AS n FROM registration;")["n"],
            "certificates": fetch_one("SELECT COUNT(*) AS n FROM certificate;")["n"],
        }
        reg_chart = fetch_all("""
            SELECT e.event_name, COUNT(r.registration_id) AS total
            FROM event e
            LEFT JOIN registration r ON e.event_id = r.event_id
            GROUP BY e.event_id, e.event_name
            ORDER BY total DESC, e.event_name;
        """)
        attendance_chart = fetch_all("""
            SELECT attendance_status, COUNT(*) AS total
            FROM attendance
            GROUP BY attendance_status
            ORDER BY attendance_status;
        """)
        rating_chart = fetch_all("""
            SELECT e.event_name, ROUND(AVG(f.rating)::numeric, 2) AS average_rating
            FROM feedback f
            JOIN event e ON e.event_id = f.event_id
            GROUP BY e.event_id, e.event_name
            ORDER BY e.event_name;
        """)
        recent_events = fetch_all("""
            SELECT e.event_id, e.event_name, e.event_type, e.event_date, e.venue,
                   o.organizer_name
            FROM event e
            JOIN organizer o ON o.organizer_id = e.organizer_id
            ORDER BY e.event_date DESC, e.event_id DESC
            LIMIT 6;
        """)
        recent_registrations = fetch_all("""
            SELECT r.registration_id,
                   s.first_name || ' ' || s.last_name AS student_name,
                   e.event_name, r.registration_date, r.registration_status
            FROM registration r
            JOIN student s ON s.student_id = r.student_id
            JOIN event e ON e.event_id = r.event_id
            ORDER BY r.registration_date DESC, r.registration_id DESC
            LIMIT 8;
        """)
        return render_template("index.html", stats=stats, reg_chart=reg_chart,
                               attendance_chart=attendance_chart,
                               rating_chart=rating_chart,
                               recent_events=recent_events,
                               recent_registrations=recent_registrations)
    except Exception as e:
        return render_template("error.html", error=str(e),
                               message="Check PostgreSQL is running and DB_CONFIG matches your local database.")

@app.route("/students")
def students():
    rows = fetch_all("SELECT * FROM student ORDER BY student_id;")
    return render_template("students.html", rows=rows)

@app.route("/students/add", methods=["POST"])
def add_student():
    execute("""
        INSERT INTO student(first_name,last_name,email,phone,department,academic_year,gender)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (request.form["first_name"], request.form["last_name"], request.form["email"],
          request.form.get("phone") or None, request.form.get("department") or None,
          request.form.get("academic_year") or None, request.form.get("gender") or None))
    flash("Student added successfully.", "success")
    return redirect(url_for("students"))

@app.route("/students/delete/<int:student_id>", methods=["POST"])
def delete_student(student_id):
    execute("DELETE FROM student WHERE student_id=%s", (student_id,))
    flash("Student deleted.", "success")
    return redirect(url_for("students"))

@app.route("/events")
def events():
    rows = fetch_all("""
        SELECT e.*, o.organizer_name
        FROM event e JOIN organizer o ON o.organizer_id=e.organizer_id
        ORDER BY e.event_date, e.event_id;
    """)
    organizers = fetch_all("SELECT organizer_id, organizer_name FROM organizer ORDER BY organizer_name;")
    return render_template("events.html", rows=rows, organizers=organizers)

@app.route("/events/add", methods=["POST"])
def add_event():
    execute("""
        INSERT INTO event(event_name,event_type,event_date,venue,max_participants,organizer_id)
        VALUES (%s,%s,%s,%s,%s,%s)
    """, (request.form["event_name"], request.form["event_type"], request.form["event_date"],
          request.form.get("venue") or None, request.form.get("max_participants") or 0,
          request.form["organizer_id"]))
    flash("Event added successfully.", "success")
    return redirect(url_for("events"))

@app.route("/events/delete/<int:event_id>", methods=["POST"])
def delete_event(event_id):
    execute("DELETE FROM event WHERE event_id=%s", (event_id,))
    flash("Event deleted.", "success")
    return redirect(url_for("events"))

@app.route("/registrations")
def registrations():
    rows = fetch_all("""
        SELECT r.registration_id,
               s.first_name || ' ' || s.last_name AS student_name,
               e.event_name, r.registration_date, r.registration_status
        FROM registration r
        JOIN student s ON s.student_id=r.student_id
        JOIN event e ON e.event_id=r.event_id
        ORDER BY r.registration_date DESC, r.registration_id DESC;
    """)
    return render_template("registrations.html", rows=rows)

@app.route("/attendance")
def attendance():
    rows = fetch_all("""
        SELECT a.attendance_id,
               s.first_name || ' ' || s.last_name AS student_name,
               e.event_name, a.attendance_date, a.attendance_status
        FROM attendance a
        JOIN student s ON s.student_id=a.student_id
        JOIN event e ON e.event_id=a.event_id
        ORDER BY a.attendance_date DESC, a.attendance_id DESC;
    """)
    return render_template("attendance.html", rows=rows)

@app.route("/feedback")
def feedback():
    rows = fetch_all("""
        SELECT f.feedback_id,
               s.first_name || ' ' || s.last_name AS student_name,
               e.event_name, f.rating, f.comments
        FROM feedback f
        JOIN student s ON s.student_id=f.student_id
        JOIN event e ON e.event_id=f.event_id
        ORDER BY f.feedback_id DESC;
    """)
    return render_template("feedback.html", rows=rows)

@app.route("/certificates")
def certificates():
    rows = fetch_all("""
        SELECT c.certificate_id,
               s.first_name || ' ' || s.last_name AS student_name,
               e.event_name, c.issue_date, c.certificate_type
        FROM certificate c
        JOIN student s ON s.student_id=c.student_id
        JOIN event e ON e.event_id=c.event_id
        ORDER BY c.issue_date DESC, c.certificate_id DESC;
    """)
    return render_template("certificates.html", rows=rows)

@app.route("/api/dashboard")
def api_dashboard():
    return jsonify({
        "students": fetch_one("SELECT COUNT(*) AS n FROM student;")["n"],
        "events": fetch_one("SELECT COUNT(*) AS n FROM event;")["n"],
        "registrations": fetch_one("SELECT COUNT(*) AS n FROM registration;")["n"],
        "certificates": fetch_one("SELECT COUNT(*) AS n FROM certificate;")["n"],
        "event_registrations": fetch_all("""
            SELECT e.event_name AS label, COUNT(r.registration_id) AS value
            FROM event e LEFT JOIN registration r ON e.event_id=r.event_id
            GROUP BY e.event_id,e.event_name ORDER BY value DESC;
        """),
        "attendance": fetch_all("""
            SELECT attendance_status AS label, COUNT(*) AS value
            FROM attendance GROUP BY attendance_status;
        """),
        "ratings": fetch_all("""
            SELECT e.event_name AS label, ROUND(AVG(f.rating)::numeric,2) AS value
            FROM feedback f JOIN event e ON e.event_id=f.event_id
            GROUP BY e.event_id,e.event_name ORDER BY e.event_name;
        """)
    })

if __name__ == "__main__":
    app.run(debug=True, host="127.0.0.1", port=5000)
