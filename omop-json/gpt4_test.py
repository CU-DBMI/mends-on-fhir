#!/usr/bin/env python3

# -*- coding: utf-8 -*-

import sqlite3
import psycopg2
import mysql.connector
import pyodbc
from google.cloud import bigquery

class DatabaseConnector:
    def __init__(self, db_type, connection_string):
        self.db_type = db_type.lower()
        self.connection = None
        self.cursor = None

        if self.db_type == 'postgresql':
            self.connection = psycopg2.connect(connection_string)
        elif self.db_type == 'bigquery':
#mgk            self.client = bigquery.Client.from_service_account_json(connection_string)
            self.client = bigquery.Client(connection_string)
        elif self.db_type == 'sqlite':
            self.connection = sqlite3.connect(connection_string)
        elif self.db_type == 'mysql':
            self.connection = mysql.connector.connect(connection_string)
        elif self.db_type == 'sqlserver':
            self.connection = pyodbc.connect(connection_string)
        else:
            raise ValueError(f"Unsupported database type: {db_type}")

        if self.db_type in ['postgresql', 'sqlite', 'mysql', 'sqlserver']:
            self.cursor = self.connection.cursor()

    def execute_query(self, query):
        if self.db_type in ['postgresql', 'sqlite', 'mysql', 'sqlserver']:
            self.cursor.execute(query)
            return self.cursor.fetchall()
        elif self.db_type == 'bigquery':
            print(query)
            query_job = self.client.query(query)
            return query_job.result()
        else:
            raise ValueError(f"Unsupported operation for database type: {self.db_type}")

    def download_query_results_in_chunks(self, query, chunksize):
        print("Hello d/l chunks")
        if self.db_type in ['postgresql', 'mysql', 'sqlserver']:
            if self.db_type == 'sqlserver':
                # For SQL Server, pyodbc supports fetching rows in chunks with the .fetchmany() method.
                self.cursor.execute(query)
                while True:
                    rows = self.cursor.fetchmany(chunksize)
                    if not rows:
                        break
                    yield rows
            else:
                # For PostgreSQL and MySQL, use the SSCursor or a similar server-side cursor if available.
                self.cursor.execute(query)
                while True:
                    rows = self.cursor.fetchmany(chunksize)
                    if not rows:
                        break
                    yield rows
        elif self.db_type == 'bigquery':
            # For BigQuery, use the `result()` method with page_size set for chunked downloading.
            print("Hello Bigquery")
            query_job = self.client.query(query)
            iterator = query_job.result(page_size=chunksize)
            for page in iterator.pages:
#                yield [dict(row) for row in page]
                return [dict(row) for row in page]
        elif self.db_type == 'sqlite':
            # SQLite does not natively support chunked fetching in the same way; 
            # you'd have to manage offsets and limits manually.
            raise NotImplementedError("Chunked downloads are not implemented for SQLite.")
        else:
            raise ValueError(f"Unsupported operation for database type: {self.db_type}")
    
    def get_column_names(self, query):
        if self.db_type in ['postgresql', 'mysql', 'sqlserver', 'sqlite']:
            self.cursor.execute(query)
            # For these databases, column names can be extracted from the cursor description attribute.
            return [column[0] for column in self.cursor.description]
        elif self.db_type == 'bigquery':
            query_job = self.client.query(query)
            # Wait for the job to complete to ensure the schema is available.
            query_job.result()
            # Extract column names from the schema of the query result.
            return [field.name for field in query_job.schema]
        else:
            raise ValueError(f"Unsupported database type: {self.db_type}")

    def close(self):
        if self.cursor is not None:
            self.cursor.close()
        if self.connection is not None:
            self.connection.close()


# Example usage
# Connection strings should be constructed according to the requirements of the respective database system

# PostgreSQL Connection String Example
# postgres_conn_str = "dbname='yourdbname' user='yourusername' host='yourhost' password='yourpassword'"
# db = DatabaseConnector('postgresql', postgres_conn_str)

# BigQuery - For BigQuery, the connection string is the path to the service account JSON key file
# bigquery_conn_str = "/path/to/your/service/account/key.json"
# db = DatabaseConnector('bigquery', bigquery_conn_str)

# SQLite Connection String Example
# sqlite_conn_str = "yourdatabase.db"
# db = DatabaseConnector('sqlite', sqlite_conn_str)

# MySQL Connection String Example
# mysql_conn_str = "host='yourhost' database='yourdbname' user='yourusername' password='yourpassword'"
# db = DatabaseConnector('mysql', mysql_conn_str)

# SQL Server Connection String Example
# sqlserver_conn_str = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=your_server;DATABASE=your_db;UID=your_user;PWD=your_password"
# db = DatabaseConnector('sqlserver', sqlserver_conn_str)

# Remember to replace the placeholders with your actual database credentials

def main():
    project_id = "hdcdmmends"  # Replace with your project ID
    dataset_id = "mends"  # Replace with your dataset ID
    table_id = "cdm_source"  # Replace with your table ID
    connection_string = f"bq://{project_id}.{dataset_id}"  # BigQuery connection string
    query = f"SELECT * FROM `{dataset_id}.{table_id}`"
    chunksize = 100

#    db_engine = DatabaseConnector('bigquery',connection_string)
#    print(db_engine.db_type)
#    results = db_engine.download_query_results_in_chunks(query,chunksize)
#    print(results)


    try:
        conn = DatabaseConnector('bigquery', connection_string)
        print(conn)
        print("Before query_results_in_chunks")
        results = conn.download_query_results_in_chunks(query, chunksize)
        print(results)
    except Exception as error:
    # handle the exception
        print("An exception occurred:", type(error).__name__, "–", error)


if __name__ == "__main__":
    main()


    
