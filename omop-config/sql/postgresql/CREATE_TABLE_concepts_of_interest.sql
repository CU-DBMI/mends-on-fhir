CREATE OR REPLACE VIEW concepts_of_interest AS (
  with concept_list as (
    select 'body_temp' as concept_set, 3020891 as concept_id
    UNION ALL select 'body_weight', 3025315
    UNION ALL select 'body_weight', 3026600
    UNION ALL select 'body_weight', 3013762
    UNION ALL select 'body_weight', 3023166
    UNION ALL select 'height', 3036277
    UNION ALL select 'height', 3019171
    UNION ALL select 'sbp' , 4152194
    UNION ALL select 'sbp', 3004249
    UNION ALL select 'sbp', 4353843
    UNION ALL select 'dbp', 4154790
    UNION ALL select 'dbp', 4354253
    UNION ALL select 'dbp', 3012888
    UNION ALL select 'bmi', 3038553
-- Remove BMI Observations that probably belong in Conditions
	--    UNION ALL select 'bmi', 4135421
--    UNION ALL select 'bmi', 4060705
--    UNION ALL select 'bmi', 4060985
--    UNION ALL select 'bmi', 4256640
--    UNION ALL select 'bmi', 4147565
      UNION ALL select 'smoking', 903651
      UNION ALL select 'smoking', 903653
      UNION ALL select 'smoking', 903653
      UNION ALL select 'smoking', 903653
      UNION ALL select 'smoking', 903654
      UNION ALL select 'smoking', 903656
      UNION ALL select 'smoking', 903656
      UNION ALL select 'smoking', 903657
      UNION ALL select 'smoking', 903657
      UNION ALL select 'smoking', 903657
      UNION ALL select 'smoking', 903659
      UNION ALL select 'smoking', 903659
      UNION ALL select 'smoking', 903661
      UNION ALL select 'smoking', 903663
      UNION ALL select 'smoking', 903664
      UNION ALL select 'smoking', 903668
      UNION ALL select 'smoking', 4310250
      UNION ALL select 'smoking', 37017610
      UNION ALL select 'smoking', 44786668
      UNION ALL select 'smoking', 45765917
      UNION ALL select 'smoking', 45765917
      UNION ALL select 'smoking', 45881518
      UNION ALL select 'smoking', 2000000869
      UNION ALL select 'smoking', 2000000872
      UNION ALL select 'smoking', 2000000874
      UNION ALL select 'smoking', 2000000876
      UNION ALL select 'smoking', 2000000877
      UNION ALL select 'smoking', 2000000879
      UNION ALL select 'smoking', 2000000880
      UNION ALL select 'smoking', 2000000881
      UNION ALL select 'smoking', 2000000882
      UNION ALL select 'smoking', 2000000883
      UNION ALL select 'smoking', 2000001183
    UNION ALL 
    select 'labs', c.concept_id 
	from concept c 
	where c.vocabulary_id = 'LOINC' and c.domain_id = 'Measurement' and concept_class_id = 'Lab Test'  )
  select distinct coi_list.concept_set
                 , coi_list.concept_id
				 , c.concept_name, c.domain_id
				 , c.vocabulary_id
  from concept c join concept_list coi_list on c.concept_id = coi_list.concept_id
  order by coi_list.concept_set asc, coi_list.concept_id asc
 )
;
