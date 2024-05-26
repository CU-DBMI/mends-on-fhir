--JSON_KEY: test_limit10
select * from person limit 10;

-- This is a comment
-- This is another comment

--JSON_KEY: test_topn
select TOP 2000 person_id, year_of_birth from person
;


--JSON_KEY: test_nolimit
select person_id from person;

