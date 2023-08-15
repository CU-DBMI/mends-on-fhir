
docker image build . -t first_db:latest
docker container run -d --rm -p 5432:5432 -e POSTGRES_PASSWORD=synthea -e POSTGRES_USER=postgres --name test_db first_db:latest
docker container run -d --rm -p 5432:5432 -e POSTGRES_PASSWORD=synthea -e POSTGRES_USER=postgres --name test_preloaded_db pg_synthea:latest