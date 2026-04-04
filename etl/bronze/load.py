import mysql.connector
from clickhouse_driver import Client
from config.settings import MYSQL, CLICKHOUSE
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
log = logging.getLogger(__name__)


def get_mysql_connection():
    """
    Establece una conexión a la base de datos MySQL utilizando los parámetros configurados.

    Devuelve:
        mysql.connector.connection: Una instancia de la conexión de MySQL.
    """
    return mysql.connector.connect(
        host=MYSQL["host"],
        user=MYSQL["user"],
        password=MYSQL["password"],
        port=MYSQL["port"],
        database=MYSQL["database"]
    )


def get_clickhouse_client():
    """
    Establece una conexión al cliente de ClickHouse utilizando los parámetros configurados.

    Devuelve:
        clickhouse_driver.Client: Una instancia del cliente de ClickHouse.
    """
    return Client(
        host=CLICKHOUSE["host"],
        port=CLICKHOUSE["port_native"],
        user=CLICKHOUSE["user"],
        password=CLICKHOUSE["password"],
    )


def get_mysql_tables(mysql_conn):
    """
    Recupera todas las tablas base de datos en una conexión de MySQL.

    Args:
        mysql_conn (mysql.connector.connection): Conexión a la base de datos MySQL.

    Devuelve:
        list: Lista de nombres de las tablas base en la base de datos.
    """
    cursor = mysql_conn.cursor()
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
    tables = [row[0] for row in cursor.fetchall()]
    cursor.close()
    return tables


def get_table_schema(mysql_conn, table_name):
    """
    Recupera el esquema de una tabla específica en una base de datos MySQL.

    Args:
        mysql_conn (mysql.connector.connection): La conexión a la base de datos MySQL.
        table_name (str): El nombre de la tabla cuyo esquema se desea obtener.

    Devuelve:
        list: Una lista de tuplas que representan las columnas de la tabla 
        y sus propiedades, como nombre, tipo de dato, nulabilidad, etc.
    """
    cursor = mysql_conn.cursor()
    cursor.execute(f"DESCRIBE {table_name}")
    schema = cursor.fetchall()
    cursor.close()
    return schema


def mysql_type_to_clickhouse(mysql_type: str) -> str:
    """
    Convierte un tipo de dato de MySQL al tipo equivalente en ClickHouse.

    Args:
        mysql_type (str): El tipo de dato en MySQL que se desea convertir.

    Devuelve:
        str: El tipo de dato correspondiente en ClickHouse.
    """
    mysql_type = mysql_type.lower()
    if "tinyint(1)" in mysql_type:
        return "UInt8"
    elif "tinyint" in mysql_type:
        return "Int8"
    elif "smallint" in mysql_type:
        return "Int16"
    elif "mediumint" in mysql_type or "int" in mysql_type:
        return "Int32"
    elif "bigint" in mysql_type:
        return "Int64"
    elif "decimal" in mysql_type or "numeric" in mysql_type:
        return "Decimal(10, 2)"
    elif "float" in mysql_type:
        return "Float32"
    elif "double" in mysql_type:
        return "Float64"
    elif "datetime" in mysql_type or "timestamp" in mysql_type:
        return "DateTime"
    elif "date" in mysql_type:
        return "Date"
    elif "year" in mysql_type:
        return "UInt16"
    elif "time" in mysql_type:
        return "String"
    elif "char" in mysql_type or "text" in mysql_type or "enum" in mysql_type or "set" in mysql_type:
        return "String"
    elif "blob" in mysql_type or "binary" in mysql_type:
        return "String"
    else:
        return "String"


def create_bronze_table(ch_client, table_name, schema):
    """
    Crea una tabla en el nivel de bronce en ClickHouse basada en el esquema de MySQL.

    Args:
        ch_client (clickhouse_driver.Client): El cliente de ClickHouse a utilizar.
        table_name (str): El nombre de la tabla que se va a crear.
        schema (list): Una lista de columnas con sus propiedades, como nombre, tipo de dato,
                       nulabilidad, clave primaria, etc., extraídas de la tabla MySQL.
    """
    columns = []
    primary_key = None

    for col_name, col_type, nullable, key, default, extra in schema:
        ch_type = mysql_type_to_clickhouse(col_type)
        if nullable == "YES":
            ch_type = f"Nullable({ch_type})"
        if key == "PRI" and primary_key is None:
            primary_key = col_name
        columns.append(f"`{col_name}` {ch_type}")

    # Add ingestion metadata columns
    columns.append("`_ingested_at` DateTime DEFAULT now()")
    columns.append("`_source` String DEFAULT 'mysql.sakila'")

    columns_sql = ",\n  ".join(columns)
    order_by = f"`{primary_key}`" if primary_key else "`_ingested_at`"

    
    # Esta instrucción DDL crea una tabla en ClickHouse dentro del esquema especificado.
    # La tabla incluye las columnas derivadas del esquema de MySQL, junto con las 
    # columnas adicionales `_ingested_at` (fecha/hora de ingestión) y `_source` (origen de los datos).
    # - ENGINE = MergeTree(): Utiliza el motor MergeTree para soportar ordenación y particionado.
    # - ORDER BY: Define la clave de ordenación de la tabla, que puede ser la clave primaria
    #   de MySQL o la columna `_ingested_at` en caso de no tener una clave primaria.
    ddl = f"""
        CREATE TABLE IF NOT EXISTS {CLICKHOUSE["bronze"]}.{table_name}
        (
          {columns_sql}
        )
        ENGINE = MergeTree()
        ORDER BY {order_by}
    """

    log.info(f"Creating table {CLICKHOUSE['bronze']}.{table_name}")
    ch_client.execute(ddl)


def sanitize_row(row):
    """
    Sanitiza una fila de datos, convirtiendo distintos tipos de valores en
    cadenas compatibles para su ingestión en ClickHouse.

    Args:
        row (tuple): Una tupla que representa una fila de datos extraída de MySQL.

    Devuelve:
        tuple: Una nueva tupla con los valores sanitizados. Los valores de tipo 
        conjunto o lista se convierten en cadenas separadas por comas, y los 
        demás valores se mantienen sin cambios.
    """
    sanitized = []
    for value in row:
        if isinstance(value, set):
            sanitized.append(", ".join(sorted(value)))
        elif isinstance(value, list):
            sanitized.append(", ".join(str(v) for v in value))
        else:
            sanitized.append(value)
    return tuple(sanitized)


def load_table(mysql_conn, ch_client, table_name):
    """
    Carga los datos de una tabla en MySQL en el nivel de bronce de ClickHouse.

    Args:
        mysql_conn (mysql.connector.connection): Conexión a la base de datos MySQL.
        ch_client (clickhouse_driver.Client): Cliente de ClickHouse para la operación de carga.
        table_name (str): Nombre de la tabla que se debe cargar desde MySQL.

    Realiza las siguientes acciones:
        - Recupera todas las filas de la tabla indicada desde MySQL.
        - Agrega metadatos a las filas para identificar el momento de ingestión 
          y la fuente de los datos.
        - Inserta los datos en la tabla correspondiente en ClickHouse con el esquema de bronce.

    Importante:
        Si la tabla no contiene filas, la operación se registra y la carga se omite.
    """
    cursor = mysql_conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]
    cursor.close()

    if not rows:
        log.info(f"  {table_name} — no rows, skipping")
        return

    # Add metadata values
    from datetime import datetime
    rows_with_meta = [
        sanitize_row(row) + (datetime.now(), "mysql.sakila")
        for row in rows
    ]
    columns_with_meta = columns + ["_ingested_at", "_source"]

    ch_client.execute(
        f"INSERT INTO {CLICKHOUSE['bronze']}.{table_name} ({', '.join(f'`{c}`' for c in columns_with_meta)}) VALUES",
        rows_with_meta
    )
    log.info(f"  {table_name} — {len(rows)} rows loaded")


def exec_bronze_etl():
    """
    Ejecuta el proceso ETL (Extract, Transform, Load) para cargar datos desde
    MySQL hacia el nivel de bronce en ClickHouse.

    Este metodo realiza las siguientes acciones:
        - Establece una conexión con las bases de datos MySQL y ClickHouse.
        - Obtiene una lista de todas las tablas disponibles en la base de datos MySQL.
        - Para cada tabla:
            * Recupera su esquema desde MySQL.
            * Crea la tabla correspondiente en ClickHouse con el esquema de bronce.
            * Carga los datos desde MySQL hacia ClickHouse, añadiendo metadatos
              como timestamp de ingestión y la fuente de los datos.
        - Cierra las conexiones a las bases de datos al finalizar el proceso.

    Este metodo registra los eventos relevantes usando el módulo de logging, incluidos
    mensajes sobre el número de tablas encontradas, éxito en las operaciones de carga,
    y tablas sin datos que se omiten.

    Importante:
        Asegúrese de que las configuraciones para las conexiones a MySQL y ClickHouse
        estén correctamente definidas en `config.settings`.

    Raises:
        mysql.connector.Error: Si ocurre algún problema con la conexión o las operaciones
        en la base de datos MySQL.
        clickhouse_driver.errors.Error: Si ocurre algún problema con las operaciones
        en la base de datos ClickHouse.
    """
    log.info("Starting bronze layer load")

    mysql_conn = get_mysql_connection()
    ch_client = get_clickhouse_client()

    tables = get_mysql_tables(mysql_conn)
    log.info(f"Found {len(tables)} tables in sakila: {tables}")

    for table in tables:
        schema = get_table_schema(mysql_conn, table)
        create_bronze_table(ch_client, table, schema)
        load_table(mysql_conn, ch_client, table)

    mysql_conn.close()
    log.info("Bronze layer load complete")


if __name__ == "__main__":
    exec_bronze_etl()
