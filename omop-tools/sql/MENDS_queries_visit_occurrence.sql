/*

Creates JSON name:array output with Key = Visit_Occurrence (case sensitive)
JOINS to concept table to denormalize visit_concept_id
JOINS to concept table to denormalize visit_source_concept_id
JOINS to concept table to denormalize visit_type_concept_id
LEFT JOINS to concept table for admitted_from/discharged_to_concept_ids


All returned fields are cast to strings and exported as JSONSTR

*/

-- You can write anthing you want here

--JSON_KEY: Visit_Occurrence
select
    cast(visit_occurrence_id as string) as visit_occurrence_id
    , cast(vo.person_id as string) as person_id
    , cast(vo.visit_concept_id as string) as visit_concept_id
    , cast(c1.concept_code as string) as visit_concept_code
    , cast(c1.concept_name as string) as visit_concept_name
    , cast(c1.vocabulary_id as string) as visit_concept_vocabulary_id
    , cast(vo.visit_start_date as string) as visit_start_date
    , cast(vo.visit_start_datetime as string) as visit_start_datetime
    , cast(vo.visit_end_date as string) as visit_end_date
    , cast(vo.visit_end_datetime as string) as visit_end_datetime    
    , cast(vo.visit_type_concept_id as string) as visit_type_concept_id    
    , cast(c2.concept_code as string) as visit_type_concept_code
    , cast(c2.concept_name as string) as visit_type_concept_name
    , cast(c2.vocabulary_id as string) as visit_type_vocabulary_id
    , cast(vo.provider_id as string) as provider_id 
    , cast(vo.care_site_id as string) as care_site_id
    , cast(vo.visit_source_value as string) as visit_source_value
    , cast(visit_source_concept_id as string) as visit_source_concept_id
    , cast(c3.concept_code as string) as visit_source_concept_code
    , cast(c3.concept_name as string) as visit_source_concept_name
    , cast(c3.vocabulary_id as string) as visit_source_vocabulary_id
    , cast(vo.admitted_from_source_value as string) as admitted_from_source_value
    , cast(vo.admitted_from_source_value as string) as admitting_source_value
    , cast(vo.admitted_from_concept_id as string) as admitted_from_concept_id
    , cast(c4.concept_code as string) as admitted_from_concept_code
    , cast(c4.concept_name as string) as admitted_from_concept_name
    , cast(c4.vocabulary_id as string) as admitted_from_vocabulary_id
    , cast(vo.admitted_from_concept_id as string) as admitting_concept_id
    , cast(c4.concept_code as string) as admitting_concept_code
    , cast(c4.concept_name as string) as admitting_concept_name
    , cast(c4.vocabulary_id as string) as admitting_vocabulary_id
    , cast(vo.discharged_to_source_value as string) as discharged_to_source_value
    , cast(vo.discharged_to_source_value as string) as discharge_source_value
    , cast(vo.discharged_to_concept_id as string) discharged_to_concept_id
    , cast(c5.concept_code as string) as discharged_to_concept_code
    , cast(c5.concept_name as string) as discharged_to_concept_name
    , cast(c5.vocabulary_id as string) as discharged_to_vocabulary_id
    , cast(vo.discharged_to_concept_id as string) discharge_to_concept_id
    , cast(c5.concept_code as string) as discharge_to_concept_code
    , cast(c5.concept_name as string) as discharge_to_concept_name
    , cast(c5.vocabulary_id as string) as discharge_to_vocabulary_id
    , cast(vo.preceding_visit_occurrence_id as string) as preceding_visit_occurrence_id
from @cdmDatabaseSchema.visit_occurrence vo
join @cdmDatabaseSchema.concept c1 on vo.visit_concept_id = c1.concept_id
join @cdmDatabaseSchema.concept c2 on vo.visit_type_concept_id = c2.concept_id
join @cdmDatabaseSchema.concept c3 on vo.visit_source_concept_id = c3.concept_id
left join @cdmDatabaseSchema.concept c4 on vo.admitted_from_concept_id = c4.concept_id
left join @cdmDatabaseSchema.concept c5 on vo.discharged_to_concept_id = c5.concept_id
-- order by vo.visit_occurrence_id
 ;



   
