#!/usr/bin/env python3

# Python script that queries database using raw SQL and converts results into name-array style json,
# "Name" value is obtained from SQL script using JSON_TAG: keyword to detect value
# JSON array contains all rows returned by SQL query. If no rows returned, creates json with empty array.

# Command line options:

# --rows: (optional) reads total NROWS (default = all rows) for all SQL queries in SQLFILE (--sqlfile)
# --sqlfile: (mandatory) zero or more valid SQL statements formatted as described below.
# --database: (mandatory) specifies which DBMS to use. Valid values = bigquery (case insensitive)
#      TODO: add DBMS support for mssql, oracle and postgres via SQLAlchemy
# --dbargs: (mandatory) specifies database/schema to query. In GBQ, this specifies project/dataset. Must have "/" character
#      TODO: Generalize authentication using sqlalchemy methods
# 
#  --chunksize: (optional) Processes rows in sets of rows (default = 1) until all NROWS are processed
# Creates name-array formatted JSON with arraysize = CHUNKSIZE
# All JSON attribute values are returned as strings
#
# SQLFILE format requirements:
##   Each query in SQLFILE must have preceding comment line that includes the string JSON_KEY: (must include underscore & colon)
##   Spaces-trimmed string after JSON_KEY: used as name value for name-array JSON
##   Variable @cdmDatabaseSchema is replaced by values for database/schema specified in --dbargs
##   Each query must end with a semi-colon character to signify end of that query

# JSON name-array printed to STDOUT (--stdout), local files (--localdir), and/or GCS bucket/blob (--gcsdir)
# Any combination of --stdout, --localdir and --gcsdir allowed. 
# All output methods are optional
# Only one output directory can be specified in --localdir and --gcsdir

# --rmdir deletes **ALL** files in localdir and/or gcsdir that end with .json. Does not alter subdirs
# --rmkey deletes **ALL** files in localdir and/or gcsdir that end with .json and starts with JS_KEY declared in SQLFILE (see SQLFILE format requirements above). Does not alter subdirs

# CREDITS:
# clparse() & parse_sql() code modified from N3C Phenotype (https://github.com/National-COVID-Cohort-Collaborative/Phenotype_Data_Acquisition)

# Version 1.0
# 10 January 2022
# Author: Michael Kahn (Michael.Kahn@cuanschutz.edu)

# Reads environment variables using dotenv module
# pip install python-dotenv

# -*- coding: utf-8 -*-

import os
import argparse
import pandas as pd 

from google.cloud import storage
from sqlalchemy import create_engine
from dotenv import load_dotenv

def parse_sql(sqlfile, database, schema, nrows):
    queries = []
    JSON_KEY = "JSON_KEY:"

    with open(sqlfile,"r") as inf:
        inrows = inf.readlines()
    

    sql = ""
    block = False
    if nrows < 0:
        limit = ";"
    else:
        limit = " LIMIT " + str(nrows) + ";"


    for row in inrows:
        if (row.strip().startswith('--') == True) and (row.find(JSON_KEY) < 0):
            continue

        # replace sql params
        row = row.replace("@cdmDatabaseSchema",database + '.' + schema)


        if row.strip().upper().startswith('BEGIN'):
            block = True;

        sql = sql + row


        if row.find(JSON_KEY) >= 0:
            key = row[ row.find(JSON_KEY) + len(JSON_KEY):].strip()

        if block == True:
            if row.strip().upper().startswith('END;'):
                sql = sql + limit
                queries.append({"key":key,"sql":sql})
                sql = ""
                key=""
                block = False
        else:
            if row.find(';') >= 0:
                sql = sql.split(';')[0]
                sql = sql + limit
                queries.append({"key":key,"sql":sql})
                sql = ""
                key=""
        

    return queries

def create_metadata(conn,database,schema):
        json_header = "{\n\"Metadata\": {\n \"omop_source\":"
        json_footer = "}\n}\n"

        cdm_meta_query = """select * from @cdmDatabaseSchema.cdm_source"""
        cdm_meta_query = cdm_meta_query.replace("@cdmDatabaseSchema", database + '.' + schema)
        cdm_metadf = pd.read_sql_query(cdm_meta_query, conn, coerce_float=False)
        cdm_metadf.fillna(value="", inplace=True)
        cdm_metadf = cdm_metadf.astype(str)
        cdm_metajs = cdm_metadf.to_json(orient='records', indent=2)
        cdm_metajs = cdm_metajs.replace("[","")
        cdm_metajs = cdm_metajs.replace("]","")

        js = json_header + cdm_metajs + json_footer
        return(js)

def output_json(js,outf,stdout,local,gcs):
    
 # Print to standard out   
    if stdout is True: 
        print(js)

## Print to local file named in outfile variable
    if local is not None:
        with open(local + "/" + outf, 'wt',encoding="UTF-8") as f:
            print (js, file=f)

## Print to gcs
    if gcs is not None:
        x = gcs.split('/',1)
        bucketName = x[0]
        bucketFolder = x[1]
        if bucketName and bucketFolder:
            storage_client = storage.Client()
            bucket = storage_client.bucket(bucketName)
            blob = bucket.blob(bucketFolder + '/' + outf)  
            blob.upload_from_string(js)

def output_json(js,outf,stdout,local,gcs):
    
 # Print to standard out   
    if stdout is True: 
        print(js)

## Print to local file named in outfile variable
    if local is not None:
        with open(local + "/" + outf, 'wt') as f:
            print (js, file=f)

## Print to gcs
    if gcs is not None:
        x = gcs.split('/',1)
        bucketName = x[0]
        bucketFolder = x[1]
        if bucketName and bucketFolder:
            storage_client = storage.Client()
            bucket = storage_client.bucket(bucketName)
            blob = bucket.blob(bucketFolder + '/' + outf)  
            blob.upload_from_string(js)


def process_sql_to_json():

    clparse = argparse.ArgumentParser(description='Create name-array JSON from SQL statements')
    clparse.add_argument('--stdout', required=False, default=False, help='Boolean if output to STDOUT', action='store_true')
    clparse.add_argument('--localdir', required=False, default=None, help='Name of local output directory')
    clparse.add_argument('--gcsdir', required=False, default=None, help='Path to GCS direcotry (gcs://bucket/dir. Assumes authentication')
    clparse.add_argument('--sqlfile',required=True, default=None, help='Name of local file with SQL statements')
    clparse.add_argument('--rows',required=False, type=int, default=-1, help='Max number of row to extract. Default = extract all row')
    clparse.add_argument('--chunksize',required=False, type=int, default=1, help='Max number of elements per JSON object. Default = 1 object per file')
    clparse.add_argument('--database', required=True, type=str.lower, choices =["mssql","oracle", "postgres","postgresql","pg","bigquery"], help='Specify DBMS: one of MSSQL, Oracle, Postgres, or BigQuery (only BQ currently supported)')
    clparse.add_argument('--dbargs', required=True,help='database/schema (Bigquery: "project/dataset)')
    clparse.add_argument('--rmdir', required=False, default=False, help='remove *.fhir files from localdir and/or gcsdir if provided. Does not process subdirs', action='store_true')
    clparse.add_argument('--rmkey', required=False, default=False, help='remove *.fhir for all JSON key declared ent in sqlfile. Does not process subdirs', action='store_true')
    args = clparse.parse_args()

    stdout_bool = args.stdout
    localdir = os.path.abspath(args.localdir)
    gcsdir = args.gcsdir
    sqlfile = os.path.abspath(args.sqlfile)
    nrows = args.rows
    chunksize = args.chunksize
    dbargs = args.dbargs.split('/',1)
    database = dbargs[0]
    schema = dbargs[1]
    dbms = args.database
    rmdir = args.rmdir
    rmkey = args.rmkey

#
# dotenv() used for PG variables: PG_USERNAME, PG_PASSWORD, PG_IP, PG_PORT
# Postgres database name and schema are passed in -dbargs command line args
#

    load_dotenv()

  # TODO: Generalize by DBTYPE
  # TODO: Use .env for Google parms rather than assume local environment

    if dbms == 'bigquery':
        db_url = "bigquery://" + database + "/" + schema
    elif (dbms == "postgres" or dbms == "postgresql" or dbms == "pg"):
        pg_user = os.getenv("PG_USERNAME")                                   
        pg_password = os.getenv("PG_PASSWORD")                                  
        pg_host = os.getenv("PG_IP")
        pg_port = os.getenv("PG_PORT")
        db_url  = 'postgresql+psycopg2://' + pg_user + ':' + pg_password + '@' + pg_host + ':' + pg_port + '/'  + database + '?options=-csearch_path%3D' + schema
    else:
        print("Error: Should never be here")
        exit()

    db_engine = create_engine(db_url)
    conn = db_engine.connect().execution_options(
        stream_results=True
    )

# If rmdir: Delete all .json files from localdir and/or gcsdir
    if rmdir and localdir:
        files_in_directory = os.listdir(localdir)
        filtered_files = [file for file in files_in_directory if file. endswith(".json")]
        for file in filtered_files:
            path_to_file = os.path.join(localdir,file)
            os.remove(path_to_file)

    if rmdir and (gcsdir != None):
        x = gcsdir.split('/',1)
        bucketName = x[0]
        bucketFolder = x[1]
        if bucketName and bucketFolder:
            storage_client = storage.Client()
            bucket = storage_client.bucket(bucketName)
            blobs = storage_client.list_blobs(bucket,prefix=bucketFolder + '/' ,delimiter='/')
            filtered_blobs = [blob for blob in blobs if blob.name.endswith(".json")]
            for blob in filtered_blobs:
               bucket.delete_blob(blob.name)

# If rmkey, delete all .json files in localdir and/or gcsdir that filename starts with js_key
        if rmkey and localdir:
            files_in_directory = os.listdir(localdir)
            filtered_files = [file for file in files_in_directory if (file.endswith(".json") and file.startswith(js_key))]
            for file in filtered_files:
                path_to_file = os.path.join(localdir,file)
                os.remove(path_to_file)

        if rmkey and (gcsdir != None):
            x = gcsdir.split('/',1)
            bucketName = x[0]
            bucketFolder = x[1]
            if bucketName and bucketFolder:
                storage_client = storage.Client()
                bucket = storage_client.bucket(bucketName)
                blobs = storage_client.list_blobs(bucket,prefix=bucketFolder + '/' ,delimiter='/')
                filtered_blobs = [blob for blob in blobs if (blob.name.endswith(".json") and blob.name.startswith(js_key))]
                for blob in filtered_blobs:
                    bucket.delete_blob(blob.name)

# Create Metadata JSON object file (once per shard)              
    md_js = create_metadata(conn,database,schema)
    output_json(md_js,'MENDS_metadata.json',stdout_bool,localdir,gcsdir)

# parse_sql() returns a list of {key,sql}  -- one for each query
    queries = parse_sql(sqlfile, database, schema, nrows)

    for query in queries:
        i=0
        js_key = query['key']
        sql = query['sql']

 # read_sql converts large ints to floats: 
 # https://stackoverflow.com/questions/37796916/pandas-read-sql-integer-became-float
 # coerce_float = False does not work
        
        for chunkdf in pd.read_sql_query(sql, conn, chunksize=chunksize, coerce_float=False):
            chunkdf.fillna(value="",inplace=True)
            chunkdf = chunkdf.astype(str)

            chunk_index = str(i).zfill(10)
            i=i+1

            data_key = "\"" + js_key + "\" :\n" 


# Construct valid name-array JSON from header, chunkdf, footer
# indent = 2 create a pretty-printed version of the json string
            datajs= data_key + chunkdf.to_json(orient='records', indent=2)
            js = "{\n" + datajs + "\n}\n"
            js_fname = js_key + '_' + chunk_index + '.json'

            output_json(js,js_fname,stdout_bool, localdir,gcsdir)

if __name__ == '__main__':
    process_sql_to_json()
