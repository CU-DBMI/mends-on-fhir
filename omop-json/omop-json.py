#!/usr/bin/env python3

import argparse
from dotenv import load_dotenv
import os

import sqlite3
import psycopg2
import mysql.connector
import pyodbc
from google.cloud import bigquery


class DatabaseConnector:
 

    def __init__(self, db_type):
        self.db_type = db_type.lower()
        self.connection = None
        self.cursor = None

        if self.db_type == 'postgresql':
            connection_string = os.getenv('pg_connection_string')
            if connection_string is None: raise ValueError("No connection string for db_type = postgresql in .env file")
            self.connection = psycopg2.connect(connection_string)
        elif self.db_type == 'bigquery':
#mgk            self.client = bigquery.Client.from_service_account_json(connection_string)
            connection_string = os.getenv('bq_connection_string')
            if connection_string is None: raise ValueError("No connection string for db_type = bigquery in .env file")
            connection_string = 'bq://hdcdmmends.mends'
            print(connection_string)
            self.client = bigquery.Client(project="hdcdmmends", location="us")
            print(self.client)
        elif self.db_type == 'sqlite':
            connection_string = os.getenv('sqlite_connection_string')
            if connection_string is None: raise ValueError("No connection string for db_type = sqlite in .env file")
            self.connection = sqlite3.connect(connection_string)
        elif self.db_type == 'mysql':
            connection_string = os.getenv('mysql_connection_string')
            if connection_string is None: raise ValueError("No connection string for db_type = mysql in .env file")
            self.connection = mysql.connector.connect(connection_string)
        elif self.db_type == 'sqlserver':
            connection_string = os.getenv('sqlserver_connection_string')
            if connection_string is None: raise ValueError("No connection string for db_type = sqlserver in .env file")
            self.connection = pyodbc.connect(connection_string)
        else:
            raise ValueError(f"Unsupported database type: {db_type}. Supported db_types are: postgresql, bigquery, sqlite, mysql, sqlserver")

        if self.db_type in ['postgresql', 'sqlite', 'mysql', 'sqlserver']:
            self.cursor = self.connection.cursor()

    def execute_query(self, query):
        if self.db_type in ['postgresql', 'sqlite', 'mysql', 'sqlserver']:
            self.cursor.execute(query)
            return self.cursor.fetchall()
        elif self.db_type == 'bigquery':
            print('in execute_query for bigquery')
            query_job = self.client.query(query)
            return query_job.result()
        else:
            raise ValueError(f"Unsupported operation for database type: ${self.db_type}")

    def close(self):
        if self.cursor is not None:
            self.cursor.close()
        if self.connection is not None:
            self.connection.close()


def load_env():
    # Setup command line argument parsing
    parser = argparse.ArgumentParser(description='Load environment variables from a .env file.')
    parser.add_argument('env_file', nargs='?', default='.env', type=str, help='Path to the .env file. Defaults to .env in the current directory.')
    args = parser.parse_args()

    # Determine the path to the .env file
    # If env_file is just a file name, assume it's in the current directory
    env_path = args.env_file if os.path.isabs(args.env_file) else os.path.join(os.getcwd(), args.env_file)

    # Load the environment variables from the specified file
    load_dotenv(env_path)


def main():
    load_env()

    db_type = os.getenv('db_type')
    conn = DatabaseConnector(db_type)


    table_id = "cdm_source" 
    query = f"SELECT * FROM hdcdmmends.mends.cdm_source"
    print(query)
    chunksize = 100
    print(conn.db_type)
    results = conn.execute_query(query)
    print(results)



if __name__ == '__main__':
    main()

