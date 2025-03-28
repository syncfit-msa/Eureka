FROM openjdk:17-ea-11-jdk-slim
WORKDIR /app
COPY build/libs/Syncfit-Eureka-0.0.1-SNAPSHOT.jar service-discovery.jar
ENTRYPOINT ["java", "-jar", "service-discovery.jar"]