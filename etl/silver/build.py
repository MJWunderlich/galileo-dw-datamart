import os
import glob
import logging
from clickhouse_driver import Client
from config.settings import CLICKHOUSE


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
log = logging.getLogger(__name__)


SQL_DIR = os.path.join(os.path.dirname(__file__), "../../sql/silver")


SILVER_TABLES = [
    "city", "country", "address", "film", "actor",
    "film_actor", "store", "staff", "customer",
    "inventory", "rental", "payment",
    "category", "language", "film_category", "film_text"
]


def get_client() -> Client:
    """
    Obtiene un cliente de ClickHouse para conectarse a la base de datos.

    Retorna:
        Client: Una instancia del cliente ClickHouse configurada con los valores de conexión.
    """
    return Client(
        host=CLICKHOUSE["host"],
        port=CLICKHOUSE["port_native"],
        user=CLICKHOUSE["user"],
        password=CLICKHOUSE["password"],
    )


def teardown(client: Client):
    """
    Elimina todas las tablas de la capa silver en orden inverso para respetar dependencias.

    Args:
        client (Client): El cliente ClickHouse utilizado para ejecutar las operaciones DELETE.
    """
    log.info("--- Tearing down silver layer ---")
    # Reverse order to respect dependencies
    for table in reversed(SILVER_TABLES):
        client.execute(f"DROP TABLE IF EXISTS sakila_silver.{table}")
        log.info(f"  Dropped sakila_silver.{table}")
    log.info("Teardown complete")


def build(client: Client):
    """
    Construye la capa silver ejecutando todos los archivos SQL del directorio correspondiente.

    Args:
        client (Client): El cliente ClickHouse utilizado para ejecutar las consultas SQL.
    """
    log.info("--- Building silver layer ---")
    sql_files = sorted(glob.glob(os.path.join(SQL_DIR, "*.sql")))

    if not sql_files:
        log.error(f"No SQL files found in {SQL_DIR}")
        return

    log.info(f"Found {len(sql_files)} SQL files")

    for filepath in sql_files:
        filename = os.path.basename(filepath)
        with open(filepath, "r") as f:
            sql = f.read().strip()

        if not sql:
            log.warning(f"  {filename} is empty, skipping")
            continue

        log.info(f"  Executing {filename}")
        client.execute(sql)
        log.info(f"  Done — {filename}")

    log.info("Silver layer build complete")


def rebuild_silver_layer():
    """
    Reconstruye la capa silver eliminando las tablas existentes y volviendo a crear las nuevas.

    Este metodo llama a `teardown()` y luego a `build()`.
    """
    client = get_client()
    teardown(client)
    build(client)


def test_silver_layer():
    """
    Verifica la salud de cada tabla en la capa silver revisando el número de filas.

    Este metodo registra las métricas y el estado de cada tabla, indicando si hay errores,
    vacíos o si están correctamente cargadas.
    """
    log.info("--- Running silver layer tests ---")
    client = get_client()

    results = []
    for table in SILVER_TABLES:
        try:
            count = client.execute(f"SELECT COUNT(*) FROM sakila_silver.{table}")[0][0]
            status = "OK" if count > 0 else "EMPTY"
            results.append((table, count, status))
            log.info(f"  sakila_silver.{table:<20} {count:>6} rows  [{status}]")
        except Exception as e:
            results.append((table, 0, "ERROR"))
            log.error(f"  sakila_silver.{table:<20} ERROR — {e}")

    total_ok = sum(1 for _, _, s in results if s == "OK")
    total_empty = sum(1 for _, _, s in results if s == "EMPTY")
    total_error = sum(1 for _, _, s in results if s == "ERROR")

    log.info("---")
    log.info(f"Results: {total_ok} OK  |  {total_empty} EMPTY  |  {total_error} ERROR")

    if total_error == 0 and total_empty == 0:
        log.info("All silver tables healthy")
    else:
        log.warning("Some tables need attention")



if __name__ == "__main__":
    rebuild_silver_layer()
    test_silver_layer()
