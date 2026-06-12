import csv
import random
import os
import sys

NUM_ROWS = 50


COLUMNS = ["COLUMN_1", "COLUMN_2", "COLUMN_3", "COLUMN_4"]

def generate_row():

    return {
        "COLUMN_1": random.randint(0, 100),
        "COLUMN_2": round(random.uniform(1.5, 9.9), 2),
        "COLUMN_3": random.randint(0, 100),
        "COLUMN_4": random.choice(["A", "B", "C"]),
    }

OUTPUT_DIR = sys.argv[1] if len(sys.argv) > 1 else "/data"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "data.csv")

os.makedirs(OUTPUT_DIR, exist_ok=True)

rows = [generate_row() for _ in range(NUM_ROWS)]

with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(rows)

