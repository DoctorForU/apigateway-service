# Stage 1: Build JAR
FROM openjdk:21-slim as builder

WORKDIR /app

# Gradle Wrapper 및 소스 복사
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
COPY src src

# Gradle 빌드 수행 (테스트 제외)
RUN ./gradlew clean build -x test

# Stage 2: Create Custom JRE
FROM openjdk:21-slim as jre-builder

# objcopy 설치를 위해 binutils 추가
RUN apt-get update && apt-get install -y binutils && apt-get clean

# jlink로 커스텀 JRE 생성
RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.logging,java.sql \
    --output /custom-jre \
    --strip-debug \
    --compress=2 \
    --no-header-files \
    --no-man-pages

# Stage 3: Runtime
FROM debian:bullseye-slim

WORKDIR /app

# Custom JRE 복사
COPY --from=jre-builder /custom-jre /opt/java

# 빌드된 JAR 복사
COPY --from=builder /app/build/libs/apigateway-service.jar .

# JAVA_HOME 설정
ENV JAVA_HOME=/opt/java
ENV PATH="$JAVA_HOME/bin:$PATH"

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "apigateway-service.jar"]
