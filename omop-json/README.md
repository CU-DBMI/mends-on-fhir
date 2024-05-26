# OMOP\_TO\_JSON.PY

This program connects to a RDBMS that contains clinical data in the OMOP Common Data Model (CDM) Version 5.3 and creates JSON files that conform to the structure expected by the MENDS\_ON\_FHIR project. 

## Supported RDBMS:

* Postgresql (tested)
* BigQuery (tested)
* MySQL (untested, need test instance)
* Microsoft SQL Server (untested, need test instance)

## Command syntax

Example #1:  A postgresql database using SQL statements contained in test.sql in the same directory. The default location of the environment file (./.env) is used for additional needed postgres variables (user, password, host, database, schema):

```
./omop_to_json.py --db_type postgresql --sqlfile ./test.sql \
    [optional commands] \
    [optional db-specific commands]
```

Example #2: A bigquery database with both runtime and bigquery-specific command line variables. This example uses the file ../myenvfile for environment variables not set on the command line, generates 100 rows (nrows 100) total across 10 files. Each output file contains up to 10 rows (chunksize 10). The JSON files are written to a local directory named outputdir under the current directory and also prints output to stdout. It uses a BigQuery dataset named test_omop in a bigquery project named sandbox that is located in the US region:

```
./omop_to_json.py --db_type bigquery -- sqlfile ./test.sql \
  --envfile ../myenvfile \
  --nrows 100 \
  --chunksize 10 \
  --locadir ./outputdir \
  --stdout \
  --bq_projectid sandbox \
  --bq_datasetid test_omop \
  --bq_location us
```


## Runtime variables
Runtime variables may be set on command line or in a .env file located in the same directory as the OMOP\_TO\_JSON.PY file. Variables declared in the command line overwrite values declared in the .env file. See below for comment regarding LIMIT/NROWS.

Default values, where listed below, are used when variable values are not set in the command line or .env file.

RDBMS-specific variables are mandatory for specified db_type

| **Command line** | **.env file** | **Defintion** |
| :----------- | :--------: | :---------|
| **Mandatory** |
| db_type | DB_TYPE | One of {postgresql, bigquery, mysql, sqlserver} |
| sqlfile | SQLFILE | Full or relative path for OMOP SQL commands |
| **Optional** |
| envfile | Not applicable | path to file with environment variables. Default ./.env |
| stdout | STDOUT | Boolean flag to include output in standard output. Default False |
| localdir | LOCALDIR | Full or relative path for local directory for output. |
| nrows | NROWS | Number of total rows, across all chunks. Default = -1  (see note below)|
| chunksize | CHUNKSIZE | Number of rows per chunk/output file. Default = 1 row per file|
| **Postgresql-specific** (Required if db_type=postgresql)|
| pg_user | PG_USER | Postgresql user name |
| pg_password | PG_PASSWORD | Postgresql user password |
| pg_host | PG_HOST | Postgresql host name or IP address |
| pg_database | PG_DATABASE | Postgresql database for connection |
| pg_schema | PG_SCHEMA | Postgresql schema to use for queries |
| **BigQuery-specific** (Required if db_type=bigquery) |
| bq_projectid | BQ_PROJECTID | Bigquery projectID |
| bq_datasetid | BQ_DATASETID | Bigquery dataset ID |
| bq_location | BQ_LOCATION | Location or region of Bigquery project |
| **MySQL-specific** (db_type=mysql) |
| | | Not implemented -- need test instance |
| **Microsoft SQL Server-specific** (db_type=sqlserver) |
| | | Not implemented -- need test instance |


## JSON output format
This program creates a single valid JSON object from any SQL statement although the intended use case is creating A JSON object from an OMOP CDM. The output JSON format is in KEY: [{},{}....{}] pretty-print format where each element in the array is a list of column_name: value returned by the SQL query:

```
{
"KEY" : 
[
   { 
     "column1_name" : "value",
     "column2_name" : "value",
     .......
     "columnN_name" : "value"
   },
   { 
     "column1_name" : "value2",
     "column2_name" : "value2",
     .......
     "columnN_name" : "value2"
]
}
```

All keys and values are quoted strings. NULL SQL values are represented by the empty JSON string ("").

Example from OMOP Person table (synthetic data) (NROWS=2, CHUNKSIZE=2):

```
{
"test_key" :
[
  {
    "person_id":"7496",
    "gender_concept_id":"8507",
    "year_of_birth":"1980",
    "month_of_birth":"1",
    "day_of_birth":"8",
    "birth_datetime":"1980-01-08",
    "race_concept_id":"8527",
    "ethnicity_concept_id":"0",
    "location_id":"",
    "provider_id":"",
    "care_site_id":"",
    "person_source_value":"a6f34a22-45e5-602d-5340-b1798a7aa519",
    "gender_source_value":"M",
    "gender_source_concept_id":"0",
    "race_source_value":"white",
    "race_source_concept_id":"0",
    "ethnicity_source_value":"nonhispanic",
    "ethnicity_source_concept_id":"0"
  },
  {
    "person_id":"1987",
    "gender_concept_id":"8507",
    "year_of_birth":"1984",
    "month_of_birth":"1",
    "day_of_birth":"8",
    "birth_datetime":"1984-01-08",
    "race_concept_id":"8527",
    "ethnicity_concept_id":"0",
    "location_id":"",
    "provider_id":"",
    "care_site_id":"",
    "person_source_value":"2c2d8bba-db75-a58b-61f7-edc3b6595479",
    "gender_source_value":"M",
    "gender_source_concept_id":"0",
    "race_source_value":"white",
    "race_source_concept_id":"0",
    "ethnicity_source_value":"nonhispanic",
    "ethnicity_source_concept_id":"0"
  }
]
}

```

## MENDS_metadata.json file
This output file is unique to the MENDS project and is unique to the OMOP CDM. The code creates a Context JSON object and currently contains a single "omop_source" key-value pair that holds OMOP CDM metadata from the OMOP-specific cdm_source table. The MENDS_metadata.json file has a fixed structure that conforms to rules in the MENDS Whistle transformation rules for a FHIR META resource. It is mostly used to help debug different MENDS runs.

Example MENDS_metadata.json file

```
{
"Context": {
 "omop_source":
  {
    "cdm_source_name":"Synthea synthetic health database",
    "cdm_source_abbreviation":"Synthea",
    "cdm_holder":"OHDSI Community",
    "source_description":"SyntheaTM is a Synthetic Patient Population Simulator. The goal is to output synthetic, realistic (but not real), patient data and associated health records in a variety of formats.",
    "source_documentation_reference":"https:\/\/synthetichealth.github.io\/synthea\/",
    "cdm_etl_reference":"https:\/\/github.com\/OHDSI\/ETL-Synthea",
    "source_release_date":"2021-06-24",
    "cdm_release_date":"2021-06-24",
    "cdm_version":"v5.3",
    "vocabulary_version":"v5.0 08-OCT-20"
  }
}
}
```



## SQLFILE syntax
OMOP\_TO\_JSON.PY expects a specific syntax to create a valid Key-Array JSON object.

### JSON\_KEY
A specific string sequence in the SQLFILE is used to detect/define the JSON Key value for the JSON object that is created. This string sequence must appear at the start of a new line:

```
--JSON_KEY: key_value
```
**There is no space between the two hyphens and JSON_KEY.**

Example:

```
--JSON_KEY: test_key
```
   
All other SQL comment lines are ignored.

**A unique JSON Key value is required for each SQL statement contained in SQLFILE.** Each query result will be associated with the JSON Key value. For this reason, it is typical to place the --JSON_KEY: declaration just prior to each SQL statement. 
Example:


```
 -- SQL comments above are ignored
 
 --JSON_KEY: test_key   
 SELECT * FROM @cdmDatabaseSchema.person LIMIT 10; 
 
 -- SQL comments after are ignored 
```


### @cdmDatabaseSchema
All occurrences of the string @cdmDatabaseSchema in the SQLFILE are replaced with the by the string database.schema as declared by runtime or env variables. If @cdmDatabaseSchema is not present, it is assumed that the provided SQL is fully qualified for the target RDBMS.

### TOP N/LIMIT/NROWS
Microsoft SQL server (db_type = 'sqlserver') uses TOP N in the SELECT clause to limit the total number of rows returned in a query. All other RDBMSs use LIMIT N at the end of an SQL statement.

If NROWS is < 0, the  SQL statement in --sqlfile/SQLFILE is passed unchanged. 

**WARNING: NROWS < 0 DOES NOT MODIFY THE SOURCE SQL TO CONFORM TO THE EXECUTION RDBMS SYNTAX.** If the source SQL statement is written with one syntax but is executed on a RDBMS that uses the other syntax, the SQL will fail with a illegal SQL syntax error. 

If NROWS is >= 0, any  LIMIT N or TOP N clause in the source SQLFILE is *replaced* with LIMIT NROWS or TOP NROWS. If there is no existing LIMIT/TOP clause, the LIMIT NROWS or TOP NROWS clause is *added*. The use of LIMIT versus TOP is appropriate for the RDBMS set by db_type/DB_TYPE.

It is recommended that TOP N/LIMIT N clauses  not be included in the source SQL file (--sqlfile/SQLFILE). Use --nrows/NROWS to limit output. By following this recommendation, setting NROWS = -1 will return all rows.
