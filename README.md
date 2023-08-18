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
The demo begins with OMOP CDM V5.3 data extracted from a Postgresql database in NDJSON format. The Python tool/SQL queries that create these files can be found in the DEV branch but will be merged here when cleaned up. Shell scripts create Docker images and launch containers that perform the following tasks:

1. Attach demo data from a separate repository as a submodule:
    * `docker-compose/bin/synthea-random-20-example-data-update.sh`
2. Build all of the required Docker images:
    * `docker-compose/bin/all-build-no-cache.sh`
3. Evoke the Whistle JSON-to-JSON transformation engine, read the Whistle transformation rules and OMOP-to-FHIR concept maps and create FHIR R4 (mostly compliant) US Core IG compliant R4 Bulk FHIR resources.
    * `docker-compose/bin/convert-up.sh`
4. Validate the above resources against FHIR R4.01 and US Core 4.0 using the [HL7-supported Java-based validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator).
    * `docker-compose/bin/validate-up.sh`
5. Launch a vanilla version of the [HAPI FHIR server](https://github.com/hapifhir/hapi-fhir)).
    * `docker-compose/bin/hapi-up.sh`
6. Import the above Bulk FHIR resources into the HAPI server.
    * `docker-compose/bin/load-up.sh`

The script `docker-compose/all-up.sh` runs the entire pipeline (Steps 1-4). 

The analogous "down" scripts stop the docker containers.

## The Longer Story
1. Attach demo data from a separate repository as a submodule
<ul>We have created a separate [Github repo](https://github.com/CU-DBMI/mends-on-fhir-example-data) for sample data in anticipation of adding more data sources, query methods, and sample sizes. Each combination of data source, processing method, sample size will have its own branch. At the time of this writing, the only data branch is synthea-random-20, which is "saying" this branch holds OMOP JSON drawn from Synthea, selecting random row, 20 rows per table. Future data sets may come from other public domain sources, such as MIMIC and i2b2. Query methods will be {random, cohort}. Random rows do not maintain referential integrity across tables. Cohort rows will be based on a random cohort of persons and will retain referential integrity. Rows refers to the number of tuples per table using "random" queries and the number of persons in the cohort using "cohort" queries. For cohort queries, the number of rows in tables other than the PERSON table will vary according to the number of data elements associated with the cohort. We have not yet implemented the cohort queries.
</ul>
2. Build all of the required Docker images
<ul>
Docker images can be built with and without using cached layers (all-build.sh versus all-build-no-cache.sh). All previous images and containers are destroyed by these scripts. Some of the containers attach to local directories within the MENDS-on-FHIR directory tree so you need to have file wrie permissions in the directory where you place the MENDS-on-FHIR repo.
</ul>
<ul>
If you prefer to build images separately, each Docker Compose service has an "up" script (e.g,, docker-compose/bin/convert-up.sh). These scripts will create new images if needed prior to starting a new Docker service.
</ul>
3. Evoke the Whistle JSON-to-JSON transformation engine, read the Whistle transformation rules and OMOP-to-FHIR concept maps and create FHIR R4 (mostly compliant) US Core IG compliant R4 Bulk FHIR resources.
<ul>


