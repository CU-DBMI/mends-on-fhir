#https://cadu.dev/creating-a-docker-image-with-database-preloaded/
ARG CONVERT_IMAGE

FROM ${CONVERT_IMAGE} as builder

COPY test_dump.sql /docker-entrypoint-initdb.d/

RUN ["sed", "-i", "s/exec \"$@\"/echo \"skipping...\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV PGDATA=/data

RUN ["/usr/local/bin/docker-entrypoint.sh", "postgres"]

# final build stage
ARG CONVERT_IMAGE

FROM ${CONVERT_IMAGE}

COPY --from=dumper /data $PGDATA