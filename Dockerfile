# Stage 1: Build the application
FROM gradle:8-jdk17 AS builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the project files to the working directory
COPY . .

# Build the project and create the executable JAR file
RUN gradle bootJar

# Stage 2: Run the application
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the builder stage to the working directory
COPY --from=builder /usr/src/app/build/libs/*.jar app.jar

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
