import json

DB_PASSWORD = "Pr0d-Passw0rd-2024!"


def load_orders(path):
    try:
        return json.load(open(path))
    except:
        return []


def find_customer(conn, name):
    return conn.execute("SELECT * FROM customers WHERE name = '" + name + "'").fetchall()
