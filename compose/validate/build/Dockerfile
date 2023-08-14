FROM eclipse-temurin:17-jdk-jammy

ARG USER_UID
ARG USER_GID

WORKDIR /validation

RUN curl -L https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar  --output validator.jar

RUN groupadd -g ${USER_GID} validator
RUN useradd validator -u ${USER_UID}  -g ${USER_GID} -m -d /validation/results -s /bin/bash

ENTRYPOINT ["java", "-jar", "/validation/validator.jar"]
