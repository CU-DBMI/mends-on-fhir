FROM ubuntu:jammy

COPY /root /

RUN apt-get update && apt-get install -y curl

ENTRYPOINT ["/usr/local/bin/fhir-load"]

