#!/usr/bin/env python3

# -*- coding: utf-8 -*-

from sqlalchemy import *
from sqlalchemy import create_engine
from sqlalchemy.schema import *

# Postgresql imports
import psycopg2

# BigQuery imports
from google.cloud import bigquery
from google.cloud.bigquery import dbapi
# import sqlalchemy_bigquery
import pyarrow


# SQLlite imports
import sqlite3

# MySQL imports
import mysql.connector

# SqlServer imports
import pyodbc

# System imports
import argparse
from dotenv import load_dotenv
import os
import os.path
import pandas as pd
import re


class DatabaseConnector:
 
    def __init__(self, db_type):
        self.db_type = db_type.lower()
        self.connection_string = None
        self.connection = None
        self.cursor = None

        if self.db_type is None: 
            raise ValueError("No db_type set in enviornment or .env file")
        match self.db_type:
            case 'postgresql': 
                self.connection_string = coalesce(os.getenv('cl_connection_string'), os.getenv('postgresql_connection_string'),"No postgresql connection string")
            case 'bigquery': 
                # Unlike other connections, BigQuery needs Location argument in create.engine()
                self.connection_string = coalesce(os.getenv('cl_connection_string'),os.getenv('bigquery_connection_string'),"No bigquery connection string")
                db_schema = self.connection_string.split("bigquery://",1)[1]
                self.database = db_schema.split("/")[0]
                self.schema = db_schema.split("/")[1]
                self.db_engine = create_engine(self.connection_string, location='US')
                self.connection = self.db_engine.connect().execution_options(stream_results=True)
            case 'sqlite': 
                self.connection_string = coalesce(os.getenv('cl_connection_string'),os.getenv('sqlite_connection_string'),"No sqlite connection string")
            case 'mysql': 
                self.connection_string = coalesce(os.getenv('cl_connection_string'),os.getenv('mysql_connection_string'), "No mysql connection string")
            case 'sqlserver': 
                self.connection_string = coalesce(os.getenv('cl_connection_string'),os.getenv('sqlserver_connection_string'), "No sqlserver connection string")
            case _ : 
                raise ValueError(f"Unsupported db_type value: {self.db_type}")
        
        if self.connection_string is None:
            raise (ValueError(f"No connection string for db_type: {self.connection_string}"))
    

    def execute_querydf(self, query):
        return pd.read_sql_query(query,self.connection, coerce_float=False) 

    def download_query_results_in_chunksdf(self, query, nrows=-1, chunksize=10000):
        if self.db_type == 'sqlite':
            # SQLite does not natively support chunked fetching in the same way; 
            # you'd have to manage offsets and limits manually.
            # Not implemented
            raise NotImplementedError("Chunked downloads are not implemented for SQLite.")

        for chunkdf in pd.read_sql_query(query, self.connection, chunksize=chunksize, coerce_float=False):
            chunkdf.fillna(value="",inplace=True)
            chunkdf = chunkdf.astype(str)
            yield chunkdf
    
    def close(self):
        if self.cursor is not None:
            self.cursor.close()
        if self.connection is not None:
            self.connection.close()

## End of class DatabaseConnector()

def coalesce(*values) :
    """Return the first non-None value or None if all values are None"""
    return next((v for v in values if v is not None), None)

def load_env():
    """Sets environment vars: Vars in command line override vars in .env file"""

    env_path = os.path.join(os.getcwd(), ".env")
    load_dotenv(env_path)
    # Convert stdout from string to Boolean
    if os.environ.get('stdout') is not None and os.environ.get('stdout').lower() == 'true':
        dotenv_stdout = True
    else:
        dotenv_stdout = False

    clparse = argparse.ArgumentParser(description='Create name-array JSON from SQL statements')
    clparse.add_argument('--stdout', required=False, default=False, action="store_true", help='Output to STDOUT if True')
    clparse.add_argument('--localdir', required=False, default=None, help='Name of local output directory')
    clparse.add_argument('--sqlfile',required=False, default=None, help='Name of local file with SQL statements')
    clparse.add_argument('--nrows',required=False, type=int, help='Max number of row to extract. Default = extract all row')
    clparse.add_argument('--chunksize',required=False, type=int, help='Max number of elements per JSON object. Default = 1 object per file')
    clparse.add_argument('--db_type', required=False, default=None, type=str.lower, choices =["postgresql","bigquery", "sqlite","mysql","sqlserver"], help='Specify DBMS: one of postgresql, bigquery, sqlite, mysql, sqlserver')
    clparse.add_argument('--connection_string', required=False, default=None, help='connection string -- must match syntax for db_type')
    args = clparse.parse_args()

    # Convert stdout from None to False
    cl_stdout = args.stdout
    cl_localdir = os.path.abspath(args.localdir) if args.localdir else None
    cl_sqlfile = os.path.abspath(args.sqlfile) if args.sqlfile else None
    cl_nrows = str(args.nrows) if args.nrows else None
    cl_chunksize = str(args.chunksize) if args.chunksize else None
    cl_db_type = args.db_type if args.db_type else None
    cl_connection_string = args.connection_string if args.connection_string else None

   # Precidence: command line vars (cl_vars), .env vars (os.environ), default value. Default value can be invalid to trigger error
   # All environment variables must be strings, including Boolean and integer vars (stdout, nrows, chunksize)
    os.environ['stdout_str'] = "True" if cl_stdout or dotenv_stdout else "False"
    os.environ['localdir'] =  coalesce(cl_localdir, os.environ.get("localdir"),"Foo")
    os.environ['sqlfile'] = coalesce(cl_sqlfile, os.environ.get("sqlfile"), "No sql file provided")
    os.environ['nrows'] =  str(coalesce(cl_nrows, os.environ.get("nrows"), "1"))
    os.environ['chunksize'] =  str(coalesce(cl_chunksize, os.environ.get("chunksize"), 1))
    os.environ['db_type'] =  coalesce(cl_db_type, os.environ.get("db_type"),"No db_type provided")
    # connection string is handled differently: only set environment var if it is provided in command line
    # This connection string, if present, overrides any other connection string set in .env file
    if cl_connection_string : os.environ['cl_connection_string'] = cl_connection_string


def parse_sqlfile(sqlfile, database, schema, nrows) :
    """Returns Python list with {KEY: <WhistleKey>, SQL: <SQL statement>}
    
    Replaces @cdmDatabaseSchema with database.schema
    Appends LIMIT {NROWS} if NROWS != -1
    If SQL statement has LIMIT, NROWS is ignored"""

    JSON_KEY = "JSON_KEY:"
    queries_dict = {}
    sql = ''

    with open(sqlfile,"r") as f :
        for line in f:
            line = line.replace("@cdmDatabaseSchema", database + '.' + schema)
            if line.strip().startswith('--JSON_KEY') :
#                key = line[ line.find(JSON_KEY) + len(JSON_KEY):].strip()
                key = re.split(r'JSON_KEY:',line)[1].strip()
                sql = ''
            elif line.strip().endswith(';') :
                # Remove the semi-colon. We will add it back in with LIMIT
                sql = sql + line.split(';')[0]              
                # Precidence for LIMIT clause:
                #   1. nrows in command line
                #   2. nrows in env file
                #   3. nrows in SQL statement
                limit = f';\n' if nrows < 0  else f' LIMIT {nrows}\n; '
                x = re.split(r'(?i)limit|;', sql)
                sql = x[0] + limit

                # This code implements a different precidence for NROWS:
                # Precidence for LIMIT clause:
                #  1. nrows in SQL statement
                #  2. nrows in command line
                #  3. nrows in env file        
    #           if bool(re.search(r'(?i)limit +\d+ *;*', query) == False:
    #               limit = ";" if nrows < 0  else f' LIMIT {nrows}; '
    #               sql  = sql.split(';')[0] + limit
                
                # Reached the end of an SQL statement so add to query array.
                queries_dict[key] = sql

                # Continue to process file for other SQL statements
            else: 
                # Not at a JSON_KEY line
                # Not at the end of a SQL statement
                sql = sql + line
    
    return(queries_dict)

def create_metadata(conn,database,schema):
    json_header = "{\n\"Context\": {\n \"omop_source\":"
    json_footer = "}\n}\n"

    cdm_meta_query = """select * from @cdmDatabaseSchema.cdm_source"""
    cdm_meta_query = cdm_meta_query.replace("@cdmDatabaseSchema", database + '.' + schema)
    cdm_metadf = pd.read_sql_query(cdm_meta_query, conn, coerce_float=False)
    cdm_metadf.fillna(value="", inplace=True)
    cdm_metadf = cdm_metadf.astype(str)
    cdm_metajs = cdm_metadf.to_json(orient='records', indent=2)
    cdm_metajs = cdm_metajs.replace("[","")
    cdm_metajs = cdm_metajs.replace("]","")

    meta_js = json_header + cdm_metajs + json_footer
    return(meta_js)

def output_json(js,stdout=False, localdir=None, outfile=None):
    """ Print to stdout and/or localdir/outfile"""

    # Print to standard out   
    if stdout is True : print(js)
    
    # Print outfile to local directory
    if localdir is not None and os.path.isdir(localdir):
        with open(localdir + "/" + outfile, 'wt') as f:
            print (js, file=f)

def main():
    load_env()

    db_type = os.environ.get("db_type")
    if db_type is None: raise ValueError("No db_type specified in command line or .env file")

    try:
        conn =  DatabaseConnector(db_type)
        sqlfile = os.environ.get('sqlfile')
        database = conn.database # Extracted from connection string
        schema = conn.schema # Extracted from connection string
        nrows = int(os.environ['nrows']) # Environment vars are always strings
        chunksize = int(os.environ['chunksize']) # Environment vars are always string
        stdout = True if os.environ.get('stdout') == 'True' else False

        # Create Metadata JSON object file (once per shard)              
        meta_js = create_metadata(conn.connection,database,schema)
        output_json(js=meta_js,stdout=stdout, localdir=os.environ.get('localdir'), outfile='MENDS_metadata.json')
        
        # Execute the queries in sqlfile
        queries_dict = parse_sqlfile(sqlfile, database, schema, nrows)
        for key, sql in queries_dict.items() :
            filename_idx = 0
            for chunkdf in conn.download_query_results_in_chunksdf(sql, nrows=nrows, chunksize=chunksize):
                chunkjs = chunkdf.to_json(orient = 'records', indent=2)
                chunkjs_key = f'\"{key}\" :\n'
                js = '{\n' + chunkjs_key + chunkjs +'\n}\n'

                # Output filename: 'key_xxxxxxxxxx.json'
                filename = key + '_' + str(filename_idx).zfill(10) + '.json'
                filename_idx += 1
                output_json(js=js, stdout=stdout, localdir=os.environ.get('localdir'), outfile = filename)
    except Exception as error:
    # handle the exception
        raise RuntimeError("An exception occurred:", type(error).__name__, "–", error)

if __name__ == '__main__':
    main()

