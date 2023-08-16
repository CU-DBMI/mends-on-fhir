
-- You can write anthing you want here

--JSON_KEY: Measurement
select cast(m.measurement_id as string) as measurement_id 
    , cast(m.person_id as string) as person_id
    , cast(m.measurement_concept_id as string) as measurement_concept_id
    , cast(c1.concept_code as string) as measurement_concept_code
    , cast(c1.concept_name as string) as measurement_concept_name
    , cast(c1.vocabulary_id as string) as measurement_concept_vocabulary_id
    , cast(m.measurement_source_value as string) as measurement_source_value
    , cast(m.measurement_source_concept_id as string) as measurement_source_concept_id
    , cast(c2.concept_code as string) as measurement_source_concept_code
    , cast(c2.concept_name as string) as measurement_source_concept_name
    , cast(c2.vocabulary_id as string) as measurement_source_vocabulary_id
    , cast(m.measurement_type_concept_id as string) as measurement_type_concept_id
    , cast(m.operator_concept_id as string) as operator_concept_id
    , cast(c5.concept_code as string) as operator_concept_code
    , cast(c5.concept_name as string) as operator_concept_name
    , cast(m.provider_id as string) as provider_id
    , cast(m.measurement_date as string) as measurement_date
    , cast(m.measurement_datetime as string) as measurement_datetime
    , cast(m.range_low as string) as range_low
    , cast(m.range_high as string) as range_high
    , cast(m.unit_source_value as string) as unit_source_value
    , cast(m.unit_concept_id as string) as unit_concept_id
    , cast(c4.concept_code as string) as unit_concept_code
    , cast(c4.concept_name as string) as unit_concept_name
    , cast(c4.vocabulary_id as string) as unit_vocabulary_id
    , cast(m.value_source_value as string) as value_source_value
    , cast(m.value_as_number as string) as value_as_number
    , cast(m.value_as_concept_id as string) as value_as_concept_id
    , cast(c3.concept_code as string) as value_as_concept_code
    , cast(c3.concept_name as string) as value_as_concept_name
    , cast(c3.vocabulary_id as string) as value_as_concept_vocabulary_id
    , cast(m.visit_detail_id as string) as visit_detail_id
    , cast(m.visit_occurrence_id as string) as visit_occurrence_id
from @cdmDatabaseSchema.measurement m
JOIN @cdmDatabaseSchema.concept c1 on m.measurement_concept_id = c1.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c2 on m.measurement_source_concept_id = c2.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c3 on m.value_as_concept_id = c3.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c4 on m.unit_concept_id = c4.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c5 on m.operator_concept_id = c5.concept_id
where m.measurement_date >= '2010-01-01'
and m.measurement_date <= '2018-12-31' 
-- and m.value_as_number is null and (value_as_concept_id is null or value_as_concept_id = 0) and value_source_value is not null
-- above records only have value_source_value only and nothing else
;

-- You can write anthing you want here

--JSON_KEY: Measurement2
select cast(m.measurement_id as string) as measurement_id 
    , cast(m.person_id as string) as person_id
    , cast(m.measurement_concept_id as string) as measurement_concept_id
    , cast(c1.concept_code as string) as measurement_concept_code
    , cast(c1.concept_name as string) as measurement_concept_name
    , cast(c1.vocabulary_id as string) as measurement_concept_vocabulary_id
    , cast(m.measurement_source_value as string) as measurement_source_value
    , cast(m.measurement_source_concept_id as string) as measurement_source_concept_id
    , cast(c2.concept_code as string) as measurement_source_concept_code
    , cast(c2.concept_name as string) as measurement_source_concept_name
    , cast(c2.vocabulary_id as string) as measurement_source_vocabulary_id
    , cast(m.measurement_type_concept_id as string) as measurement_type_concept_id
    , cast(m.operator_concept_id as string) as operator_concept_id
    , cast(c5.concept_code as string) as operator_concept_code
    , cast(c5.concept_name as string) as operator_concept_name
    , cast(m.provider_id as string) as provider_id
    , cast(m.measurement_date as string) as measurement_date
    , cast(m.measurement_datetime as string) as measurement_datetime
    , cast(m.range_low as string) as range_low
    , cast(m.range_high as string) as range_high
    , cast(m.unit_source_value as string) as unit_source_value
    , cast(m.unit_concept_id as string) as unit_concept_id
    , cast(c4.concept_code as string) as unit_concept_code
    , cast(c4.concept_name as string) as unit_concept_name
    , cast(c4.vocabulary_id as string) as unit_vocabulary_id
    , cast(m.value_source_value as string) as value_source_value
    , cast(m.value_as_number as string) as value_as_number
    , cast(m.value_as_concept_id as string) as value_as_concept_id
    , cast(c3.concept_code as string) as value_as_concept_code
    , cast(c3.concept_name as string) as value_as_concept_name
    , cast(c3.vocabulary_id as string) as value_as_concept_vocabulary_id
    , cast(m.visit_detail_id as string) as visit_detail_id
    , cast(m.visit_occurrence_id as string) as visit_occurrence_id
from @cdmDatabaseSchema.measurement m
JOIN @cdmDatabaseSchema.concept c1 on m.measurement_concept_id = c1.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c2 on m.measurement_source_concept_id = c2.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c3 on m.value_as_concept_id = c3.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c4 on m.unit_concept_id = c4.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c5 on m.operator_concept_id = c5.concept_id
where m.measurement_date > '2018-12-31'
and m.measurement_date <= '2020-12-31'
-- and m.value_as_concept_id != 0
-- These records will create valueCodedConcepts only
;

-- You can write anthing you want here

--JSON_KEY: Measurement3
select cast(m.measurement_id as string) as measurement_id 
    , cast(m.person_id as string) as person_id
    , cast(m.measurement_concept_id as string) as measurement_concept_id
    , cast(c1.concept_code as string) as measurement_concept_code
    , cast(c1.concept_name as string) as measurement_concept_name
    , cast(c1.vocabulary_id as string) as measurement_concept_vocabulary_id
    , cast(m.measurement_source_value as string) as measurement_source_value
    , cast(m.measurement_source_concept_id as string) as measurement_source_concept_id
    , cast(c2.concept_code as string) as measurement_source_concept_code
    , cast(c2.concept_name as string) as measurement_source_concept_name
    , cast(c2.vocabulary_id as string) as measurement_source_vocabulary_id
    , cast(m.measurement_type_concept_id as string) as measurement_type_concept_id
    , cast(m.operator_concept_id as string) as operator_concept_id
    , cast(c5.concept_code as string) as operator_concept_code
    , cast(c5.concept_name as string) as operator_concept_name
    , cast(m.provider_id as string) as provider_id
    , cast(m.measurement_date as string) as measurement_date
    , cast(m.measurement_datetime as string) as measurement_datetime
    , cast(m.range_low as string) as range_low
    , cast(m.range_high as string) as range_high
    , cast(m.unit_source_value as string) as unit_source_value
    , cast(m.unit_concept_id as string) as unit_concept_id
    , cast(c4.concept_code as string) as unit_concept_code
    , cast(c4.concept_name as string) as unit_concept_name
    , cast(c4.vocabulary_id as string) as unit_vocabulary_id
    , cast(m.value_source_value as string) as value_source_value
    , cast(m.value_as_number as string) as value_as_number
    , cast(m.value_as_concept_id as string) as value_as_concept_id
    , cast(c3.concept_code as string) as value_as_concept_code
    , cast(c3.concept_name as string) as value_as_concept_name
    , cast(c3.vocabulary_id as string) as value_as_concept_vocabulary_id
    , cast(m.visit_detail_id as string) as visit_detail_id
    , cast(m.visit_occurrence_id as string) as visit_occurrence_id
from @cdmDatabaseSchema.measurement m
JOIN @cdmDatabaseSchema.concept c1 on m.measurement_concept_id = c1.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c2 on m.measurement_source_concept_id = c2.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c3 on m.value_as_concept_id = c3.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c4 on m.unit_concept_id = c4.concept_id
LEFT JOIN @cdmDatabaseSchema.concept c5 on m.operator_concept_id = c5.concept_id
where m.measurement_date > '2020-12-31'
and m.measurement_date <= current_date()
;