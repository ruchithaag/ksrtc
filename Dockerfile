# ----------- STAGE 1: BUILD -----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app
# Copy pom and download dependencies (better caching)
COPY pom.xml .
RUN mvn dependency:go-offline
# Copy source code
COPY src ./src
# Build WAR file
RUN mvn clean package -DskipTests
# ----------- STAGE 2: TOMCAT -----------
FROM tomcat:10.1-jdk17
# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy WAR from build stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
# Expose port
EXPOSE 8080
# Start Tomcat
CMD ["catalina.sh", "run"]