#https://cadu.dev/creating-a-docker-image-with-database-preloaded/
ARG PG_IMAGE

FROM ${PG_IMAGE} as builder
ARG PG_USER
ARG PG_PASSWORD
ARG PG_DATA

COPY pgdump_synthea.sql /docker-entrypoint-initdb.d/

RUN ["sed", "-i", "s/exec \"$@\"/echo \"skipping...\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV POSTGRES_USER=${PG_USER}
ENV POSTGRES_PASSWORD=${PG_PASSWORD}
ENV PGDATA=${PG_DATA}

RUN ["/usr/local/bin/docker-entrypoint.sh", "postgres", "-c" , "max_wal_size=1GB"]

# final build stage
FROM ${PG_IMAGE}
ARG PG_DATA

ENV PGDATA=${PG_DATA}
COPY --from=builder /data ${PG_DATA}