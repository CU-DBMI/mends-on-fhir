# MENDS-on-FHIR
The Multi-State EHR-Based Network for Disease Surveillance (MENDS) is a CDC-funded pilot of an electronic health record (EHR)-based chronic disease surveillance system coordinated by the National Association of Chronic Disease Directors (NACDD). See [https://chronicdisease.org/page/mendsinfo/](https://chronicdisease.org/page/mendsinfo/)).

This repository is a specialized version of a pipeline that converts a limited number of tables in the OMOP Version 5.3 Common Data Model into a limited set of HL7 R4/US Core compliant FHIR resources that can populate the back-end database for the MENDS project using a single standard-based [FHIR Bulk FHIR API](https://hl7.org/fhir/uv/bulkdata/) . This active reposistory at Health Data Compass implements the pipeline described in the [technical publication] (https://medrxiv.org/cgi/content/short/2023.08.09.23293900v1). 

This repository is a limited version of the transformation rules used in the production system, but the demo pipeline exercises all components used in MENDS. Synthetic data produced by the [Synthea system](https://synthea.mitre.org) has less complete vocabulary mappings than we see in our EHR-based production OMOP instance.

**This repository is not intended to support additional community contributions to build out a more complete set of OMOP-FHIR transformation.** A refactored repo that is more modular that accepts alternative transformations (different versions of the OMOP CDM, core FHIR, Implementation Guides) is being created and a link will be added when available.

## Overall design

The figure is an expanded pipeline compared to the pipeline described in the tehcnical publication.

![High level processing flow](/assets/images/MENDS-generalized.png)

Yellow components are existing systems. Green components are available in this repository and are described in the technical pubication. Green components with asterisk extended an existing, abandoned open-access proof-of-concept [GitHub project by the Google healthcare (HCLS) API team](https://github.com/GoogleCloudPlatform/healthcare-data-harmonization). Blue components are available in the [omop-fhir-data](https://github.com/cu-dbmi/omop-fhir-data) GitHub repository. Blue components are not described in the technical publication.

## TL;DR (aka the short story version)

[[TODO: Create a short video of the demo]]

The demo begins with OMOP CDM V5.3 data extracted from a PostgreSQL database in NDJSON format. The Python tool/SQL queries that create these files can be found in the DEV branch but will be merged here when cleaned up. Shell scripts create Docker images and launch containers that perform the following tasks:

### Make sure you are using the latest version of Docker (on MacOS: 4.22.1 at the time of writing). Otherwise, you will get a complaint from docker compose about "Additional property required is not allowed."

1. Attach demo data from a separate repository as a submodule:
    * `docker-compose/bin/omop-fhir-data-update.sh`
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
<ul>A separate <a href="https://github.com/CU-DBMI/omop-fhir-data">Github repo</a> for sample data was created to add more data sources, query methods, and sample sizes as they become available in the future. Each combination of data source, processing method, sample size will have its own directory. There are two data sets at the time of this writing. The one used by this demo is in the `synthea-cohort-115` directory and an additional data set named `synthea-random-20`. Future data sets may come from other public domain sources, such as MIMIC and i2b2. Query methods will be one of {random, cohort}. Random rows do not maintain referential integrity across tables. Cohort rows will be based on a random cohort of persons and will retain referential integrity across tables. When using the "random" query method, rows refers to the number of tuples per table. When using the "cohort" query method, rows refers to the number of persons. For cohort queries, the number of rows in tables other than the PERSON table will vary according to the number of data elements associated with the cohort. Cohort-based queries have not yet ben implemented. See the <a href="https://github.com/CU-DBMI/omop-fhir-data">omop-fhir-data</a> repo for more details about how these data sets are created.
</ul>
<ul>
Raw source (Synthea) data are found in the _RAW folder. <br><br>
OMOP-JSON formatted data are found in their corresponding directory.
</ul>
2. Build all of the required Docker images
<ul>
Docker images can be built with and without using cached layers (docker-compose/bin/all-build.sh versus docker-compose/bin/all-build-no-cache.sh respectively). All previous images and containers are destroyed by these scripts. Some of the containers attach to local directories within the MENDS-on-FHIR directory tree so you need to have file write permissions in the directory where you place the MENDS-on-FHIR repo.
</ul>
<ul>
If preferred to build images separately, each Docker Compose service (convert, validate, hapi, load) has an "up" script (e.g,, docker-compose/bin/convert-up.sh). These scripts will create new images if needed prior to starting a new Docker service.
</ul>
3. Evoke the Whistle JSON-to-JSON transformation engine, read the Whistle transformation rules and OMOP-to-FHIR concept maps and create FHIR R4 US Core IG (mostly) compliant R4 FHIR Bundle resources.
<ul>
Whistle is a domain-specific functional JSON-to-JSON transformation language with functions tailored to supporting healthcare data transformation written in Golang. The original proof-of-concept code was developed by Google and if found at <a href="https://github.com/GoogleCloudPlatform/healthcare-data-harmonization">https://github.com/GoogleCloudPlatform/healthcare-data-harmonization</a>. This repo is no longer supported. Our fork and updates can be found at <a href="https://github.com/CU-DBMI/healthcare-data-harmonization">https://github.com/CU-DBMI/healthcare-data-harmonization</a>. Extensive documentation on the Whistle language functions and a tutorial can be found at these locations. 
</ul>
<ul>
The Whistle Docker image (convert service) expects three mounted directories:
<ol>
    <li>mapping-config/concept\_maps</li>
    <li>mapping-config/whistle-functions</li>
    <li>mapping-config/whistle-mains</li>
</ol>
</ul>
<ul>Four variables defined in docker-compose/.env specify where these files are found:
<ol>
    <li>CONVERT\_INPUT=Directory with OMOP JSON extracts to be converted into FHIR resources. Demo uses submodule data at ../input-examples/omop-fhir-data/synthea-cohort-115</li>
    <li>CONVERT\_MAPPING\_FUNCTIONS=Directory of transformation functions that restructure OMOP JSON into FHIR resources. Demo uses submodule folder at ../whistle-mappings/synthea/whistle-functions</li>
    <li>CONVERT\_MAPPING\_CONCEPT_MAPS=Directory of terminology maps from OMOP terminology to IG-specific FHIR terminology. Demo uses submodule folder at ../whistle-mappings/synthea/concept-maps</li>
    <li>CONVERT\_MAIN=the "starting call" that begins the transformation process. Demo uses submodule folder at ./whistle-mappings/synthea/whistle-mains/main.wstl</li>
</ol>
</ul>
<ul>
The main branch in <a href="https://github.com/CU-DBMI/omop-fhir-data">omop-fhir-data</a> has its own set of Whistle transformations to capture any source-specific differences, such as terminology transformations, in the OMOP JSON output.
</ul>
<br>
[[TO-DO: More description of how the Whistle engine executes]]

<br>
<ul>The convert service writes it output (FHIR Bundle resources) into a mounted folder at docker-compose/convert/volume/output. These output resources are used by the validate and load Docker services. These Docker services execute only after the convert Docker service terminates.
</ul>
4. Validate the above resources against FHIR R4.01 and US Core 4.0 using the <a href="https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator">HL7-supported Java-based validator</a>.
<ul>
HL7 provides a high-quality FHIR validator that can be configured to leverage the online HL7 terminology server for both structural and vocabulary/value set compliance. Multiple Implementation Guides can be included. Only conversion rules for US Core Version 4.0.0 was implemented. The IG used by the validator is specified in the docker-compose/.env file. The current value is: VALIDATE\_IG=hl7.fhir.us.core#4.0.0. Other IGs can be included/substituted and will be used by the validator.
</ul>
<ul>
The validator assumes HL7 FHIR bundles are located in the same directory that is used by the OMOP-to-FHIR convert service (docker-compose/convert/volume/output).  Validation findings are written into docker-compose/validate/volume/results.
</ul>
<ul>
The validator service becomes active after the convert process completes. For unclear reasons, the validator service always ends with status=1. The validator Docker service then terminates.
</ul>
5. Launch a vanilla version of the <a href="https://github.com/hapifhir/hapi-fhir">HAPI FHIR server</a>.
<ul>
A vanilla version of the HAPI Docker image was used. The Docker build replaces the default HAPI home page sample-logo.jpg with the  MENDS logo. HAPI-specific configuration values are declared in mends-on-fhir/docker-compose/hapi/config/application.yaml. The server is found at localhost:8080.
</ul>
6. Import the above FHIR Bundle resources into the HAPI server.
<ul>
The import service loops through all FHIR Bundle files in docker-compose/convert/volume/output and does a simple POST REST call to the HAPI server. The import service is not activated until after the validate service has terminated (completed) and the HAPI server service is "healthy". 
</ul>
7. Bring up the HAPI server and search various resources to see the imported OMOP data as FHIR resources.
<ul>
HAPI lists all FHIR resource types down the left navigation bar. In the Synthea data, only FHIR resources for BASIC, CONDITION, COVERAGE, ENCOUNTER, MEDICATION, OBSERVATION and PATIENT were created. Select one of these FHIR resource types then select the green "Search" button. After a few seconds, the imported FHIR resources will appear underneath the Search panel. Apply FHIR search parameters to select a subset of the available resources.
</ul>

---








