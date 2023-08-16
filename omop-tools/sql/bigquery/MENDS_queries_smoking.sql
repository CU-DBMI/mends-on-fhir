-- You can write anthing you want here

--JSON_KEY: Observation_Smoking
select cast(person_id as string) as person_id, cast(observation_date as string) as observation_date,
        array_to_string(
            array_agg(
                distinct
                    case observation_source_concept_name
                        when 'CigarettePacksPerDay' then
                            concat('(',trim(observation_source_concept_name),':', if(cig_per_day <= 0, "<=0", 
                                if(cig_per_day < 1, '<1',
                                    if(cig_per_day < 10, '<10', 
                                        if(cig_per_day < 20, '<20', 
                                            if(cig_per_day < 30, '<30', 
                                                if(cig_per_day < 40, '<40', '>=40')
                                            )
                                        )
                                    )
                                )
                            ), ')'
                        )
                        else
                            concat('(',trim(observation_source_concept_name), if(value_as_number is null, "", concat(":", if(value_as_number = 0, "0", "+"))),')')
                    end
                order by
                    case observation_source_concept_name
                        when 'CigarettePacksPerDay' then
                            concat('(',trim(observation_source_concept_name),':', if(cig_per_day <= 0, "<=0", 
                                if(cig_per_day < 1, '<1',
                                    if(cig_per_day < 10, '<10', 
                                        if(cig_per_day < 20, '<20', 
                                            if(cig_per_day < 30, '<30', 
                                                if(cig_per_day < 40, '<40', '>=40')
                                            )
                                        )
                                    )
                                )
                            ), ')'
                        )
                        else
                            concat('(',trim(observation_source_concept_name), if(value_as_number is null, "", concat(":", if(value_as_number = 0, "0", "+"))),')')
                    end
            ),
            " -- "
        ) as panel
from (
    select 
    o.person_id, o.observation_date, o.observation_source_concept_name, o.value_as_number,
        case o.observation_source_concept_name
            when 'CigarettePacksPerDay' then
                if ( o.value_as_number <= 3, o.value_as_number * 20, o.value_as_number)
        end as cig_per_day
    from `hdcdmmends.mends.concepts_of_interest` i
    inner join
    `hdcdmmends.mends.observation` o
    on i.concept_id = o.observation_concept_id
    where i.concept_set like 'smoking'
) as t
group by t.person_id, t.observation_date
;
