FROM eclipse-temurin:17-jdk-jammy

ARG USER_UID
ARG USER_GID

WORKDIR /validation

RUN curl -L https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar  --output validator.jar

RUN set -x; getent group ${USER_GID} || groupadd -g ${USER_GID} validator
RUN set -x; getent passwd ${USER_UID} ||  useradd validator -u ${USER_UID}  -g ${USER_GID} -m -s /bin/bash
RUN set -x; usermod  -m -d /validation/results  $(getent passwd ${USER_UID} | cut -d':' -f1)

ENTRYPOINT ["java", "-jar", "/validation/validator.jar"]
