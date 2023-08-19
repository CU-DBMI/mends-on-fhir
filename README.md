# MENDS-on-FHIR
The Multi-State EHR-Based Network for Disease Surveillance (MENDS) is a CDC-funded demonstration of an electronic health record (EHR)-based chronic disease surveillance system hosted by the National Association of Chronic Disease Directors (NACDD). See [https://chronicdisease.org/page/mendsinfo/](https://github.com/GoogleCloudPlatform/healthcare-data-harmonization)).

This repository is a specialized version of a pipeline that converts a limited number of tables in the OMOP Version 5.3 Common Data Model into a limited set of HL7 R4/US Core compliant FHIR resources that can populate the back-end database for the MENDS project using a single standard-based Bulk FHIR call. This reposistory implements the pipeline descrbed in the our [technical publication] (https://medrxiv.org/cgi/content/short/2023.08.09.23293900v1). 

This repository is a stripped down version of the transformation rules used in the production system but the demo pipeline exercises all of the components used in MENDS. Synthetic data produced by the (truly outstanding) [Synthea system](https://synthea.mitre.org) has less complete vocabulary mappings than we see in our EHR-based production OMOP instance.

**This repo is not intended to support additional community contributions to build out a more complete set of OMOP-FHIR transformation.** A refactored repo that is more modular that accepts alternative transformations (different versions of the OMOP CDM, core FHIR, Implementation Guides) is being created and a link will be placed here when available.

## Overall design

The figure, taken from the technical publication, below shows the overall data pipeline. Only those parts highlighted in green are implemented in this repository

![High level processing flow](/assets/images/dataflow.png)

Yellow components are existing systems. Green components are available on GitHub. Green components with asterisk extended an existing, abandoned open-access proof-of-concept [GitHub project by the Google helathcare API team](https://github.com/GoogleCloudPlatform/healthcare-data-harmonization).

## TL;DR (aka the short story version)

[[TODO: Create a short video of the demo]]

The demo begins with OMOP CDM V5.3 data extracted from a Postgresql database in NDJSON format. The Python tool/SQL queries that create these files can be found in the DEV branch but will be merged here when cleaned up. Shell scripts create Docker images and launch containers that perform the following tasks:

1. Attach demo data from a separate repository as a submodule:
    * `docker-compose/bin/synthea-random-20-example-data-update.sh`
2. Build all of the required Docker images:
    * `docker-compose/bin/all-build-no-cache.sh`
3. Evoke the Whistle JSON-to-JSON transformation engine, read the Whistle transformation rules and OMOP-to-FHIR concept maps and create FHIR R4 (mostly compliant) US Core IG compliant R4  FHIR Bundle resources.
    * `docker-compose/bin/convert-up.sh`
4. Validate the above resources against FHIR R4.01 and US Core 4.0 using the [HL7-supported Java-based validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator).
    * `docker-compose/bin/validate-up.sh`
5. Launch a vanilla version of the [HAPI FHIR server](https://github.com/hapifhir/hapi-fhir)).
    * `docker-compose/bin/hapi-up.sh`
6. Import the above FHIR Bundle resources into the HAPI server.
    * `docker-compose/bin/load-up.sh`
7. Bring up the HAPI server and search various resources to see the imported OMOP data as FHIR resources
    * localhost:8080
    * FHIR resources imported: Basic, Condition, Coverage, Encounter, Medication, Observation, Patient
The script `docker-compose/all-up.sh` runs the entire pipeline (Steps 1-4). The HAPI server does not launch automatically.

The analogous "down" scripts stop the docker containers.

## The Longer Story
1. Attach demo data from a separate repository as a submodule
<ul>We have created a separate [Github repo](https://github.com/CU-DBMI/mends-on-fhir-example-data) for sample data in anticipation of adding more data sources, query methods, and sample sizes. Each combination of data source, processing method, sample size will have its own branch. At the time of this writing, the only data branch is synthea-random-20, which is "saying" this branch holds OMOP JSON drawn from Synthea, selecting random row, 20 rows per table. Future data sets may come from other public domain sources, such as MIMIC and i2b2. Query methods will be one of {random, cohort}. Random rows do not maintain referential integrity across tables. Cohort rows will be based on a random cohort of persons and will retain referential integrity across tables. When using the "random" query method, rows refers to the number of tuples per table. When using the "cohort" query method, rows refers to the number of persons. For cohort queries, the number of rows in tables other than the PERSON table will vary according to the number of data elements associated with the cohort. We have not yet implemented cohort-based queries. See the [mends-on-fhir-example-data](https://github.com/CU-DBMI/mends-on-fhir-example-data) repo for more details about how these data sets are created.
</ul>
<ul>
Raw source data are found in the _RAW folder. <br>
OMOP-JSON formatted data are found in the input-data folder.
</ul>
2. Build all of the required Docker images
<ul>
Docker images can be built with and without using cached layers (docker-compose/bin/all-build.sh versus docker-compose/bin/all-build-no-cache.sh respectively). All previous images and containers are destroyed by these scripts. Some of the containers attach to local directories within the MENDS-on-FHIR directory tree so you need to have file wrie permissions in the directory where you place the MENDS-on-FHIR repo.
</ul>
<ul>
If you prefer to build images separately, each Docker Compose service (convert, validate, hapi, load) has an "up" script (e.g,, docker-compose/bin/convert-up.sh). These scripts will create new images if needed prior to starting a new Docker service.
</ul>
3. Evoke the Whistle JSON-to-JSON transformation engine, read the Whistle transformation rules and OMOP-to-FHIR concept maps and create FHIR R4 US Core IG (mostly) compliant R4 FHIR Bundle resources.
<ul>
Whistle is a domain-specific functioanl JSON-to-JSON tranformation language with functions tailored to supporting healthcare data transformation written in Golang. The original proof-of-concept code was developed by Google and if found at [https://github.com/GoogleCloudPlatform/healthcare-data-harmonization](https://github.com/GoogleCloudPlatform/healthcare-data-harmonization). This repo is not longer supported. Our clone and updates can be found at [NEED WHISTLE REPO]. Extensive documentation on the Whistle language functions and a tutorial can be found at these locations. 
</ul>
<ul>
The Whistle Docker image (convert service) expects three mounted directories:
    * mapping-config/concept_maps
    * mapping-config/whistle-functions
    * mapping-config/whistle-mains
</ul>
<ul>Four variables defined in docker-compose/.env specify where these files are found:

    * CONVERT_INPUT=Directory with OMOP JSON extracts to be converted into FHIR resources. Demo uses submodule data at ../input-examples/synthea-random-20/input-data
    * CONVERT_MAPPING_FUNCTIONS=Directory of transformation functions that restructure OMOP JSON into FHIR resources. Demo uses submodule folder at ../input-examples/synthea-random-20/mapping-config/whistle-functions
    * CONVERT_MAPPING_CONCEPT_MAPS=Directory of terminology maps from OMOP terminology to IG-specific FHIR terminology. Demo uses submodule folder at ../input-examples/synthea-random-20/mapping-config/concept-maps
    * CONVERT_MAIN=the "starting call" that begins the transformation process. Demo uses submodule folder at ../input-examples/synthea-random-20/mapping-config/whistle-mains/main.wst
</ul>
<ul>
Each branch in [mends-on-fhir-example-data](https://github.com/CU-DBMI/mends-on-fhir-example-data) has its own set of Whistle transformations to capture any source-specific differences, such as terminology transformations, in the OMOP JSON output.
</ul>
<br>
[[TO-DO: More description of how the Whistle engine executes]]

<br>
<ul>The convert service writes it output (FHIR Bundle resources) into a mounted folder at docker-compose/convert/volume/output. These output resources are used by the validate and load Docker services. These Docker services execute only after the convert Docker service terminates.
</ul>
4. Validate the above resources against FHIR R4.01 and US Core 4.0 using the [HL7-supported Java-based validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator).
<ul>
HL7 provides a high-quality FHIR validator that can be configured to leverage the online HL7 terminology server for both structural and vocabulary/value set compliance. Multiple Implementation Guides can be included. We only implemented US Core Version 4.0.0. The IG used by the validator is specified in the docker-compose/.env file. The current value is: VALIDATE_IG=hl7.fhir.us.core#4.0.0. Other IGs can be includes/substituted and will be used by the validator.
</ul>
<ul>
The validator assumes HL7 FHIR bundles are located in the same directory that is used by the OMOP-to-FHIR convert service (docker-compose/convert/volume/output).  Validation findings are written into docker-compose/validate/volume/results.
</ul>
<ul>
The validator service becomes active after the convert process completes. For unclear reasons, the validator service always ends with status=1. The validator Docker service then terminates.
</ul>
5. Launch a vanilla version of the [HAPI FHIR server](https://github.com/hapifhir/hapi-fhir)).
<ul>
Not much to say here. We use a vanilla version of the HAPI Docker image. We have made no attempt to put any project "branding" on the image. Our HAPI-specific configuration values are in mends-on-fhir/docker-compose/hapi/config/application.yaml. The server is found at localhost:8080.
</ul>
6. Import the above FHIR Bundle resources into the HAPI server.
<ul>
The import service loops thru all FHIR Bundle files in docker-compose/convert/volume/output and does a simple POST REST call to the HAPI server. The import service is not activated until after the validate service has terminated (completed) and the HAPI server service is "healthy". 
7. Bring up the HAPI server and search various resources to see the imported OMOP data as FHIR resources.
<ul>
HAPI lists all FHIR resource types down the left navigation bar. In the Synthea data, we only create FHIR resources for BASIC, CONDITION, COVERAGE, ENCOUNTER, MEDICATION, OBSERVATION and PATIENT. Select one of these FHIR resource types then select the green "Search" button. After a few seconds, the imported FHIR resources will appear underneath the Search panel. You can play with FHIR search parameters to select a subset of the available resources.
</ul>

---








