-- You can write anthing you want here

--JSON_KEY: Observation_Smoking
select cast(person_id as text) as person_id, cast(observation_date as text) as observation_date,
        array_to_text(
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
                            concat('(',trim(observation_source_concept_name), if(value_as_number is null, '', concat(":", if(value_as_number = 0, "0", "+"))),')')
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
                            concat('(',trim(observation_source_concept_name), if(value_as_number is null, '', concat(":", if(value_as_number = 0, "0", "+"))),')')
                    end
            ),
            " -- "
        ) as panel
from (
    select 
    o.person_id, o.observation_date, c1.concept_name as observation_source_concept_name, o.value_as_number,
        case c1.concept_name
            when 'CigarettePacksPerDay' then
                IF o.value_as_number <= 3 then o.value_as_number * 20; else o.value_as_number; END IF;
        end case; as cig_per_day
    from 
   concepts_of_interest i inner join observation o on i.concept_id = o.observation_concept_id
   join concept c1 on c1.concept_id = o.observation_source_concept_id
   where i.concept_set like 'smoking'
) as t
group by t.person_id, t.observation_date
;
