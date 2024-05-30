# Use an official OpenJDK base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven executable and project definition files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Build the project and skip tests to speed up the build
RUN ./mvnw clean package -DskipTests

# Copy the built jar file
COPY target/*.jar app.jar

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
