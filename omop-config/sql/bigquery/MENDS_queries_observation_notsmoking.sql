-- You can write anthing you want here
 

--JSON_KEY: ObservationNotSmoking
select cast(o.observation_id as string) as observation_id 
    , cast(o.person_id as string) as person_id
    , cast(o.observation_concept_id as string) as observation_concept_id
    , cast(c1.concept_code as string) as observation_concept_code
    , cast(c1.concept_name as string) as observation_concept_name
    , cast(c1.vocabulary_id as string) as observation_concept_vocabulary_id
    , cast(o.observation_source_value as string) as observation_source_value
    , cast(o.observation_source_concept_id as string) as observation_source_concept_id
    , cast(c2.concept_code as string) as observation_source_concept_code
    , cast(c2.concept_name as string) as observation_source_concept_name
    , cast(c2.vocabulary_id as string) as observation_source_vocabulary_id
    , cast(o.observation_type_concept_id as string) as observation_type_concept_id
    , cast (c5.concept_name as string) as observation_type_concept_name
    , cast(o.qualifier_source_value as string) as qualifier_source_value
    , cast(o.qualifier_concept_id as string) as qualifier_concept_id
    , cast(c6.concept_name as string) as qualifier_concept_name
    , cast(o.provider_id as string) as provider_id
    , cast(o.observation_date as string) as observation_date
    , cast(o.observation_datetime as string) as observation_datetime
    , cast(o.unit_source_value as string) as unit_source_value
    , cast(o.unit_concept_id as string) as unit_concept_id
    , cast(c4.concept_code as string) as unit_concept_code
    , cast(c4.concept_name as string) as unit_concept_name
    , cast(c4.vocabulary_id as string) as unit_vocabulary_id
    , cast(o.value_as_string as string) as value_as_string
    , cast(o.value_as_number as string) as value_as_number
    , cast(o.value_as_concept_id as string) as value_as_concept_id
    , cast(c3.concept_code as string) as value_as_concept_code
    , cast(c3.concept_name as string) as value_as_concept_name
    , cast(c3.vocabulary_id as string) as value_as_concept_vocabulary_id
    , cast(o.visit_detail_id as string) as visit_detail_id
    , cast(o.visit_occurrence_id as string) as visit_occurrence_id
 from @cdmDatabaseSchema.observation o
JOIN @cdmDatabaseSchema.concepts_of_interest coi on o.observation_concept_id = coi.concept_id
JOIN @cdmDatabaseSchema.concept c1 on o.observation_concept_id = c1.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c2 on o.observation_source_concept_id = c2.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c3 on o.value_as_concept_id = c3.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c4 on o.unit_concept_id = c4.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c5 on o.observation_type_concept_id = c5.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c6 on o.qualifier_concept_id = c6.concept_id
where coi.concept_set != 'smoking'
;




   
