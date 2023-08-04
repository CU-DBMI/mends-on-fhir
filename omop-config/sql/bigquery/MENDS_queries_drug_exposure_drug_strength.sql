/*

Creates JSON name:array output with Key = Drug_Exposure (case sensitive)
LEFT JOINS to drug_strength to obtain zero:many ingredients
JOINS to concept table to denormalize drug_source_concept_id
JOINS to concept table to denormalize drug_concept_id
LEFT JOINS to concept table to denormalize zero:one route_concept_id

SPECIAL NOTE: Zero:Many link to drug_strength causes duplication of drug_exposure_id
Modified drug_exposure_id concatenates ingredient_concept_id if present for unique drug-ingredient combination
If no ingredient_concept_id (LEFT JOIN), add "-0" as convention for "no ingredient"

Query is partitioned by time due to "Return set too large" error with unpartitioned query

All returned fields are cast to strings and exported as JSONSTR

Remove all rows where drug_concept_id AND drug_source_concept_id are ZERO (unmapped)

*/




-- You can write anthing you want here

--JSON_KEY: Drug_Exposure
select  concat(cast(de.drug_exposure_id as string),'-',cast(ifnull(ds.ingredient_concept_id,0) as string)) as drug_exposure_id
      , cast(de.person_id as string) as person_id
      , cast(de.drug_concept_id as string) as drug_concept_id
      , cast(c1.concept_name as string) as drug_concept_name
      , cast(c1.concept_code as string) as drug_concept_code
      , cast(c1.vocabulary_id as string) as drug_concept_vocabulary_id
      , cast(de.drug_source_value as string) as drug_source_value
      , cast(de.drug_source_concept_id as string) as drug_source_concept_id
      , cast(c2.concept_name as string) as drug_source_concept_name
      , cast(c2.concept_code as string) as drug_source_concept_code
      , cast(c2.vocabulary_id as string) as drug_source_vocabulary_id
      , cast(de.drug_type_concept_id as string) as drug_type_concept_id
      , cast(de.lot_number as string) as lot_number
      , cast(de.days_supply as string) as days_supply
      , cast(de.quantity as string) as quantity
      , cast(de.refills as string) as refills
      , cast(de.sig as string) as sig
      , cast(de.route_source_value as string) as route_source_value
      , cast(de.route_concept_id as string) as route_concept_id
      , cast(c3.concept_name as string) as route_concept_name
      , cast(c3.concept_code as string) as route_concept_code
      , cast(c3.vocabulary_id as string) as route_vocabulary_id
      , cast(de.stop_reason as string) as stop_reason
      , cast(de.dose_unit_source_value as string) as dose_unit_source_value
      , cast(de.provider_id as string) as provider_id
      , cast(de.drug_exposure_start_date as string) as drug_exposure_start_date
      , cast(de.drug_exposure_start_datetime as string) as drug_exposure_start_datetime
      , cast(de.drug_exposure_end_date as string) as drug_exposure_end_date
      , cast(de.drug_exposure_end_datetime as string) as drug_exposure_end_datetime
      , cast(de.visit_detail_id as string) as visit_detail_id
      , cast(de.visit_occurrence_id as string) as visit_occurrence_id
      , cast(ds.ingredient_concept_id as string) as ingredient_concept_id
      , cast(ds.amount_unit_concept_id as string) as amount_unit_concept_id
      , cast(ds.numerator_unit_concept_id as string) as numerator_unit_concept_id
      , cast(ds.denominator_unit_concept_id as string) as denominator_unit_concept_id
 from @cdmDatabaseSchema.drug_exposure de
 LEFT JOIN @cdmDatabaseSchema.drug_strength ds on de.drug_concept_id = ds.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c1 on c1.concept_id = de.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c2 on c2.concept_id = de.drug_source_concept_id
 LEFT JOIN @cdmDatabaseSchema.concept c3 on c3.concept_id = de.route_concept_id
 where de.drug_concept_id !=0 and de.drug_source_concept_id != 0
 and cast(de.drug_exposure_start_date as date) >= '2010-01-01'
 and cast(de.drug_exposure_start_date as date) <= '2019-12-31'
-- order by de.drug_exposure_id
 ;


-- You can write anthing you want here

--JSON_KEY: Drug_Exposure2
select  concat(cast(de.drug_exposure_id as string),'-',cast(ifnull(ds.ingredient_concept_id,0) as string)) as drug_exposure_id
      , cast(de.person_id as string) as person_id
      , cast(de.drug_concept_id as string) as drug_concept_id
      , cast(c1.concept_name as string) as drug_concept_name
      , cast(c1.concept_code as string) as drug_concept_code
      , cast(c1.vocabulary_id as string) as drug_concept_vocabulary_id
      , cast(de.drug_source_value as string) as drug_source_value
      , cast(de.drug_source_concept_id as string) as drug_source_concept_id
      , cast(c2.concept_name as string) as drug_source_concept_name
      , cast(c2.concept_code as string) as drug_source_concept_code
      , cast(c2.vocabulary_id as string) as drug_source_vocabulary_id
      , cast(de.drug_type_concept_id as string) as drug_type_concept_id
      , cast(de.lot_number as string) as lot_number
      , cast(de.days_supply as string) as days_supply
      , cast(de.quantity as string) as quantity
      , cast(de.refills as string) as refills
      , cast(de.sig as string) as sig
      , cast(de.route_source_value as string) as route_source_value
      , cast(de.route_concept_id as string) as route_concept_id
      , cast(c3.concept_name as string) as route_concept_name
      , cast(c3.concept_code as string) as route_concept_code
      , cast(c3.vocabulary_id as string) as route_vocabulary_id
      , cast(de.stop_reason as string) as stop_reason
      , cast(de.dose_unit_source_value as string) as dose_unit_source_value
      , cast(de.provider_id as string) as provider_id
      , cast(de.drug_exposure_start_date as string) as drug_exposure_start_date
      , cast(de.drug_exposure_start_datetime as string) as drug_exposure_start_datetime
      , cast(de.drug_exposure_end_date as string) as drug_exposure_end_date
      , cast(de.drug_exposure_end_datetime as string) as drug_exposure_end_datetime
      , cast(de.visit_detail_id as string) as visit_detail_id
      , cast(de.visit_occurrence_id as string) as visit_occurrence_id
      , cast(ds.ingredient_concept_id as string) as ingredient_concept_id
      , cast(ds.amount_unit_concept_id as string) as amount_unit_concept_id
      , cast(ds.numerator_unit_concept_id as string) as numerator_unit_concept_id
      , cast(ds.denominator_unit_concept_id as string) as denominator_unit_concept_id
 from @cdmDatabaseSchema.drug_exposure de
 LEFT JOIN @cdmDatabaseSchema.drug_strength ds on de.drug_concept_id = ds.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c1 on c1.concept_id = de.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c2 on c2.concept_id = de.drug_source_concept_id
 LEFT JOIN @cdmDatabaseSchema.concept c3 on c3.concept_id = de.route_concept_id
 where de.drug_concept_id !=0 and de.drug_source_concept_id != 0
 and cast(de.drug_exposure_start_date as date) > '2019-12-31'
 and cast(de.drug_exposure_start_date as date) <= '2021-12-31'
-- order by de.drug_exposure_id
;



-- You can write anthing you want here

--JSON_KEY: Drug_Exposure3
select  concat(cast(de.drug_exposure_id as string),'-',cast(ifnull(ds.ingredient_concept_id,0) as string)) as drug_exposure_id
      , cast(de.person_id as string) as person_id
      , cast(de.drug_concept_id as string) as drug_concept_id
      , cast(c1.concept_name as string) as drug_concept_name
      , cast(c1.concept_code as string) as drug_concept_code
      , cast(c1.vocabulary_id as string) as drug_concept_vocabulary_id
      , cast(de.drug_source_value as string) as drug_source_value
      , cast(de.drug_source_concept_id as string) as drug_source_concept_id
      , cast(c2.concept_name as string) as drug_source_concept_name
      , cast(c2.concept_code as string) as drug_source_concept_code
      , cast(c2.vocabulary_id as string) as drug_source_vocabulary_id
      , cast(de.drug_type_concept_id as string) as drug_type_concept_id
      , cast(de.lot_number as string) as lot_number
      , cast(de.days_supply as string) as days_supply
      , cast(de.quantity as string) as quantity
      , cast(de.refills as string) as refills
      , cast(de.sig as string) as sig
      , cast(de.route_source_value as string) as route_source_value
      , cast(de.route_concept_id as string) as route_concept_id
      , cast(c3.concept_name as string) as route_concept_name
      , cast(c3.concept_code as string) as route_concept_code
      , cast(c3.vocabulary_id as string) as route_vocabulary_id
      , cast(de.stop_reason as string) as stop_reason
      , cast(de.dose_unit_source_value as string) as dose_unit_source_value
      , cast(de.provider_id as string) as provider_id
      , cast(de.drug_exposure_start_date as string) as drug_exposure_start_date
      , cast(de.drug_exposure_start_datetime as string) as drug_exposure_start_datetime
      , cast(de.drug_exposure_end_date as string) as drug_exposure_end_date
      , cast(de.drug_exposure_end_datetime as string) as drug_exposure_end_datetime
      , cast(de.visit_detail_id as string) as visit_detail_id
      , cast(de.visit_occurrence_id as string) as visit_occurrence_id
      , cast(ds.ingredient_concept_id as string) as ingredient_concept_id
      , cast(ds.amount_unit_concept_id as string) as amount_unit_concept_id
      , cast(ds.numerator_unit_concept_id as string) as numerator_unit_concept_id
      , cast(ds.denominator_unit_concept_id as string) as denominator_unit_concept_id
 from @cdmDatabaseSchema.drug_exposure de
 LEFT JOIN @cdmDatabaseSchema.drug_strength ds on de.drug_concept_id = ds.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c1 on c1.concept_id = de.drug_concept_id
 JOIN @cdmDatabaseSchema.concept c2 on c2.concept_id = de.drug_source_concept_id
 LEFT JOIN @cdmDatabaseSchema.concept c3 on c3.concept_id = de.route_concept_id
 where de.drug_concept_id !=0 and de.drug_source_concept_id != 0
 and cast(de.drug_exposure_start_date as date) > '2021-12-31'
 and cast(de.drug_exposure_start_date as date) <= current_date()
-- order by de.drug_exposure_id
;
