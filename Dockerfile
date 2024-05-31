FROM gradle:8-jdk17 AS builder

WORKDIR /usr/src/app

COPY . .

RUN gradle bootJar

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=builder /usr/src/app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
