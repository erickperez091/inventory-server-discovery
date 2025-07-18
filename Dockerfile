# Stage 1: Build con Maven
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app
# Copy source code
COPY . .

# Copy setting with credentials for Nexus repository (must be in root project folder)
COPY settings.xml /root/.m2/settings.xml
RUN cat /root/.m2/settings.xml
# Compile microservice and download libraries from Nexus repository
ENV MAVEN_OPTS="-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true"
RUN mvn clean package -s /root/.m2/settings.xml

# Stage 2: Final image with JAVA
FROM eclipse-temurin:21-alpine
WORKDIR /app

# Copy generated JAR from builder
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "app.jar"]
