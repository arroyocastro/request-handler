FROM openjdk:21-jdk

RUN mkdir -p ~/config
RUN mkdir -p ~/logs

COPY target/request-handler-2.0.0-SNAPSHOT.jar .
COPY src/main/resources/bootstrap.yml .
COPY src/main/resources/application.yml .

ENTRYPOINT ["java","-jar","./request-handler-2.0.0-SNAPSHOT.jar"]
