# 🧱 Stage 1: Build using Maven y JDK
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY settings.xml /root/.m2/settings.xml
# Copy the project
COPY . .
# Compile the project and generate the JAR file
RUN mvn clean package
# 🐳 Stage 2: Final Image, lighter
FROM eclipse-temurin:21-jre
WORKDIR /app
# Copy JAR from previous stage
COPY --from=build /app/target/server-discovery-*.jar app.jar
# Expose default port of Spring Boot
EXPOSE 9081
# Command to execute the microservice
ENTRYPOINT ["java", "-jar", "app.jar"]
