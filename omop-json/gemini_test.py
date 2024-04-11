# Initial code from Google Gemini

import psycopg2  # for Postgresql
from google.cloud import bigquery  # for BigQuery
import pyodbc  # for Microsoft SQL Server (install with pip install pyodbc)
import mysql.connector  # for MySQL


class DatabaseConnection:
  """
  A class representing a database connection.
  """

  def __init__(self, connection_string, database_type="postgresql"):
    """
    Connects to a database using a connection string.

    Args:
        connection_string: The connection string for the database.
        database_type: The type of database (postgresql, bigquery, mssql, mysql).
    """
    self.connection = self._connect(connection_string, database_type)

  def _connect(self, connection_string, database_type):
    """
    Establishes a connection to the database.

    Args:
        connection_string: The connection string for the database.
        database_type: The type of database (postgresql, bigquery, mssql, mysql).

    Returns:
        A database connection object or client depending on the database type.
    """

    if database_type == "postgresql":
      return psycopg2.connect(connection_string)

    elif database_type == "bigquery":
      return bigquery.Client(connection_string)

    elif database_type == "mssql":
      return pyodbc.connect(connection_string)

    elif database_type == "mysql":
      return mysql.connector.connect(connection_string)

    else:
      raise ValueError("Unsupported database type: {}".format(database_type))

  def get_column_names(self, query):
    """
    Gets the column names from a query.

    Args:
        query: The SQL query.

    Returns:
        A list of column names from the query.
    """

    if isinstance(self.connection, (psycopg2.extensions.connection, pyodbc.connect)):
      cursor = self.connection.cursor()
      cursor.execute(query)
      column_names = [desc[0] for desc in cursor.description]
      return column_names

    elif isinstance(self.connection, bigquery.Client):
      # BigQuery doesn't directly return column names from a query string
      raise NotImplementedError("Getting column names directly from query not supported for BigQuery")

    else:
      raise ValueError("Unsupported connection type")

  def execute_query_chunked(self, query, chunksize):
    """
    Executes a query with chunking and yields results.

    Args:
        query: The SQL query to execute.
        chunksize: The number of rows to fetch at a time.

    Yields:
        Chunks of results from the query.
    """

    if isinstance(self.connection, (psycopg2.extensions.connection, pyodbc.connect)):
      cursor = self.connection.cursor()
      cursor.execute(query)
      for row in cursor.fetchmany(chunksize):
        yield row

    elif isinstance(self.connection, bigquery.Client):
      query_job = self.connection.query(query)
      for row in query_job.result():
        yield row.to_dict()  # Convert BigQuery row to dictionary

    else:
      raise ValueError("Unsupported connection type")

  def close(self):
    """
    Closes the database connection.
    """

    if isinstance(self.connection, (psycopg2.extensions.connection, pyodbc.connect)):
      self.connection.close()

    elif isinstance(self.connection, bigquery.Client):
      self.connection.close()  # Not strictly necessary, but good practice

    else:
      raise ValueError("Unsupported connection type")


# Example usage (BigQuery)
project_id = "hdcdmmends"  # Replace with your project ID
dataset_id = "mends"  # Replace with your dataset ID
table_id = "cdm_source"  # Replace with your table ID
connection_string = f"bq://{project_id}.{dataset_id}"  # BigQuery connection string
query = f"SELECT * FROM `{dataset_id}.{table_id}`"
chunksize = 100

try:
  with DatabaseConnection(connection_string, database_type="bigquery") as conn:
    # Get column names (alternative approach for BigQuery needed)
    conn.execute_query_chunked(query, chunksize)
except Exception as error:
    # handle the exception
    print("An exception occurred:", type(error).__name__, "–", error)


