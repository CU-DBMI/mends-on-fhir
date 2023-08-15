/*

Creates JSON name:array output with Key = Condition_Occurrence (case sensitive)
JOINS to concept table to denormalize condition_source_concept_id
JOINS to concept table to denormalize condition_concept_id

All returned fields are cast to strings and exported as JSONSTR

*/


-- You can write anthing you want here

--JSON_KEY: Condition_Occurrence
select
    cast(co.condition_occurrence_id as string) as condition_occurrence_id
    , cast(co.person_id as string) as person_id
    , cast(co.condition_source_concept_id as string) as condition_source_concept_id
    , cast(c1.concept_code as string) as condition_source_concept_code
    , cast(c1.concept_name as string) as condition_source_concept_name
    , cast(c1.vocabulary_id as string) as condition_source_vocabulary_id
    , cast(co.condition_concept_id as string) as condition_concept_id
    , cast(c2.concept_code as string) as condition_concept_code
    , cast(c2.concept_name as string) as condition_concept_name
    , cast(c2.vocabulary_id as string) as condition_vocabulary_id
    , cast(co.condition_status_concept_id as string) as condition_status_concept_id
    , cast(co.condition_type_concept_id as string) as condition_type_concept_id
    , cast(co.provider_id as string) as provider_id
    , cast(co.visit_detail_id as string) as visit_detail_id
    , cast(co.visit_occurrence_id as string) as visit_occurrence_id
    , cast(co.condition_start_date as string) as condition_start_date
    , cast(co.condition_end_date as string) as condition_end_date
 from @cdmDatabaseSchema.condition_occurrence co
      JOIN @cdmDatabaseSchema.concept c1 on co.condition_source_concept_id = c1.concept_id
      JOIN @cdmDatabaseSchema.concept c2 on co.condition_concept_id = c2.concept_id
-- order by condition_occurrence_id
 ;
