from datetime import datetime

import mysql.connector


def connect_to_mysql() -> mysql.connector.connection.MySQLConnection:
    return mysql.connector.connect(
        host="${db_address}",
        user="${db_user}",
        password="${db_password}",
        database="${db_database}",
        port="${db_port}",
    )


def fetch_earthquake_data(cursor: mysql.connector.cursor, limit: int = 100) -> list:
    if limit <= 0:
        cursor.execute(
            """
SELECT mag, time, tsunami, sig, rms, longitude, latitude, depth
FROM earthquakespast
ORDER BY time;
"""
        )
    else:
        cursor.execute(
            """
    SELECT *
    FROM (
        SELECT mag, time, tsunami, sig, rms, longitude, latitude, depth
        FROM earthquakespast
        ORDER BY time DESC
        LIMIT %s
    ) AS sub
    ORDER BY time;
    """,
            (limit,),
        )
    return cursor.fetchall()


def write_predictions(cursor: mysql.connector.cursor, predictions: list) -> bool:
    timestamp = datetime.now().timestamp()
    for i, prediction in enumerate(predictions):
        cursor.execute(
            "INSERT INTO earthquakesfuture(id, mag, time, tsunami, sig, rms, longitude, latitude, depth) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (str(timestamp) + "_" + str(i),) + prediction,
        )
    return True


def write_predictions_only_mag(
    cursor: mysql.connector.cursor, predictions: list
) -> bool:
    timestamp = datetime.now().timestamp()
    for i, prediction in enumerate(predictions):
        cursor.execute(
            "INSERT INTO earthquakesfuture(id, mag, time) VALUES (%s, %s, %s)",
            (str(timestamp) + "_" + str(i),) + prediction,
        )
    return True
