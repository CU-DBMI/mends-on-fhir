FROM hapiproject/hapi:v6.6.0-tomcat
USER 0
RUN install_packages curl
COPY ./MENDS-Logo.jpg img/sample-logo.jpg
RUN jar -uvf /opt/bitnami/tomcat/webapps/ROOT.war img/sample-logo.jpg; rm -fr img
USER 1001


