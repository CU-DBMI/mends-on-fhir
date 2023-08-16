/*

Creates JSON name:array output with Key = Person (case sensitive)
JOINS to location table to pull zip code and state, which are MANDATORY fields for MENDS (not mandatory for USCore)

LEFT JOIN to death table to pull death date if deceased.

DOB is constructed to be YYYY-MM-DD using SQL formating, which is GBQ specific syntax

All returned fields are cast to strings and exported as JSONSTR

*/

-- You can write anthing you want here

--JSON_KEY: Person
select
    cast(p.person_id as string) as person_id
    , cast(p.ethnicity_source_value as string) as ethnicity_source_value
    , cast(p.ethnicity_concept_id as string) as ethnicity_concept_id
    , cast(p.ethnicity_source_concept_id as string) as ethnicity_source_concept_id
    , cast(p.gender_source_value as string) as gender_source_value
    , cast(p.gender_concept_id as string) as gender_concept_id
    , cast(p.gender_source_concept_id as string) as gender_source_concept_id
    , cast(p.race_source_value as string) as race_source_value
    , cast(p.race_source_concept_id as string) as race_source_concept_id
    , cast(p.race_concept_id as string) as race_concept_id
    , cast(p.location_id as string) as location_id
    , cast(p.provider_id as string) as provider_id
    , substr(cast(p.year_of_birth as string), 1,4) as year_of_birth
    , case when length(cast(p.month_of_birth as string)) = 2 then 
        substr(cast(p.month_of_birth as string), 1,2)  
        when length(cast(p.month_of_birth as string)) = 1 then
        "0" || substr(cast(p.month_of_birth as string), 1,1)
        end as month_of_birth
    , case when length(cast(p.day_of_birth as string)) = 2 then 
        substr(cast(p.day_of_birth as string), 1,2)  
        when length(cast(p.day_of_birth as string)) = 1 then
        "0" || substr(cast(p.day_of_birth as string), 1,1)
        end as day_of_birth
    , cast(l.state as string) as state
    , cast(l.zip as string) as zip
    , cast(dth.death_date as string) as death_date
 from @cdmDatabaseSchema.person p
 JOIN @cdmDatabaseSchema.location l on p.location_id = l.location_id
 LEFT JOIN @cdmDatabaseSchema.death dth on p.person_id = dth.person_id
-- order by p.person_id
;
