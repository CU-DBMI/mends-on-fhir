# MENDS-on-FHIR
The Multi-State EHR-Based Network for Disease Surveillance (MENDS) is a CDC-funded demonstration of an electronic health record (EHR)-based chronic disease surveillance system hosted by the National Association of Chronic Disease Directors (NACDD). See https://chronicdisease.org/page/mendsinfo/).

This repository is a specialized version of a pipeline that converts a limited number of tables in the OMOP Version 5.3 Common Data Model into a limited set of HL7 R4/US Core compliant FHIR resources that can populate the back-end database for the MENDS project using a single standard-based Bulk FHIR call. This reposistory implements the pipeline descrbed in the our technical publication (add MedArhive link here). 

This repo is not intended to support additional community contributions to build out a more complete set of OMOP-FHIR transformation. A refactored repo that is more modular that accepts alternative transformations (different versions of the OMOP CDM, core FHIR, Implementation Guides) is being created and a link will be placed here when available.

## Overall design

The figure, taken from the technical publication, below shows the overall data pipeline. Only those parts highlighted in green are implemented in this repository

![alt text goes here](/assets/images/dataflow.png)

Yellow components are existing systems. Green components are available on GitHub. Green components with asterisk extended an existing open-access proof-of-concept GitHub project. 


