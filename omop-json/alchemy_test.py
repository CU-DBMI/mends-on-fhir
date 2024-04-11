#!/usr/bin/env python3

# -*- coding: utf-8 -*-

from  google.cloud import bigquery
#import google.cloud.bigquery_storage 

import pandas as pd

from sqlalchemy import *
from sqlalchemy.engine import create_engine
from sqlalchemy.orm import sessionmaker
import pybigquery


# Construct the connection URL
connection_string = 'bigquery://hdcdmmends/mends'

# Create an engine
engine = create_engine(connection_string)

# Create a connection
conn = engine.connect().execution_options(stream_results=True)


# Define your SQL query
query = text("SELECT * FROM `person` LIMIT 10")

# Execute the query
result = pd.read_sql_query('select * from drug_exposure limit 10',conn, coerce_float=False, chunksize=1000)

# Fetch and print results
for row in result:
    print(row.to_json(orient='records',indent=2))

# Close the session
conn.close()
