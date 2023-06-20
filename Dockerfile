FROM openjdk:17.0.2-jdk-slim

RUN mkdir -p ~/config
RUN mkdir -p ~/logs

COPY target/request-handler-1.0.0.jar .
COPY src/main/resources/bootstrap.yml .

ENTRYPOINT ["java","-jar","./request-handler-1.0.0.jar"]
