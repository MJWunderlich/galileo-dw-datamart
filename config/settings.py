import os
from dotenv import load_dotenv


ENV_FILE = os.path.join(os.path.dirname(__file__), '.env')
load_dotenv(ENV_FILE, override=True)

MYSQL = {
    "host":     os.getenv("DB_HOST"),
    "user":     os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "port":     int(os.getenv("DB_PORT", 3306)),
    "database": os.getenv("DB_NAME", "sakila"),
}

CLICKHOUSE = {
    "host":         os.getenv("CH_HOST"),
    "user":         os.getenv("CH_USER"),
    "password":     os.getenv("CH_PASSWORD"),
    "port_native":  int(os.getenv("CH_PORT_NATIVE", 9000)),
    "port_http":    int(os.getenv("CH_PORT_HTTP", 8123)),
    "bronze":       os.getenv("CH_DB_BRONZE", "bronze"),
    "silver":       os.getenv("CH_DB_SILVER", "silver"),
    "gold":         os.getenv("CH_DB_GOLD", "gold"),
}
