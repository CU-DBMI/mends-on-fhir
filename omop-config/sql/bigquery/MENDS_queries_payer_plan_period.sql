/*

Creates JSON name:array output with Key = Payer_Plan_Period (case sensitive)
JOINS to concept table to denormalize concept_ids


All returned fields are cast to strings and exported as JSONSTR

*/

-- You can write anthing you want here

--JSON_KEY: Payer_Plan_Period
select
    cast(ppp.payer_plan_period_id as string) as payer_plan_period_id
    , cast(ppp.person_id as string) as person_id
    , cast(ppp.payer_plan_period_start_date as string) as payer_plan_period_start_date
    , cast(ppp.payer_plan_period_end_date as string) as payer_plan_period_end_date
    , cast(ppp.payer_concept_id as string) as payer_concept_id
    , cast(c2.concept_code as string) as payer_concept_code
    , cast(c2.concept_name as string) as payer_concept_name
    , cast(c2.vocabulary_id as string) as payer_vocabulary_id
    , cast(ppp.payer_source_value as string) as payer_source_value
    , cast(ppp.payer_source_concept_id as string) as payer_source_concept_id
    , cast(c1.concept_code as string) as payer_source_concept_code
    , cast(c1.concept_name as string) as payer_source_concept_name
    , cast(c1.vocabulary_id as string) as payer_source_vocabulary_id
    , cast(ppp.plan_source_value as string) as plan_source_value
    , cast(ppp.plan_concept_id as string) as plan_concept_id
    , cast(c3.concept_code as string) as plan_concept_code
    , cast(c3.concept_name as string) as plan_concept_name
    , cast(c3.vocabulary_id as string) as plan_concept_vocabulary_id
    , cast(ppp.plan_source_concept_id as string) as plan_source_concept_id
    , cast(c4.concept_code as string) as plan_source_concept_code
    , cast(c4.concept_name as string) as plan_source_concept_name
    , cast(c4.vocabulary_id as string) as plan_source_vocabulary_id
 from @cdmDatabaseSchema.payer_plan_period ppp
      JOIN @cdmDatabaseSchema.concept c1 on ppp.payer_source_concept_id = c1.concept_id
      JOIN @cdmDatabaseSchema.concept c2 on ppp.payer_concept_id = c2.concept_id
      JOIN @cdmDatabaseSchema.concept c3 on ppp.plan_concept_id = c3.concept_id
      JOIN @cdmDatabaseSchema.concept c4 on ppp.plan_source_concept_id = c4.concept_id
 ;
