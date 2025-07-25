# Dockerfile para usar con Jenkins (copiando el JAR generado en la etapa "Build")
FROM eclipse-temurin:21-alpine
WORKDIR /app

# Copiar el JAR generado en Jenkins (ajustar nombre dinámico si es necesario)
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]

