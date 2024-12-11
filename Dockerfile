# Stage 1: Build
FROM openjdk:21-slim as builder

# 작업 디렉토리 설정
WORKDIR /app

# Gradle Wrapper 및 소스 복사
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
COPY src src

# Gradle 빌드 수행 (테스트 제외)
RUN ./gradlew clean build -x test

# Stage 2: Runtime
FROM openjdk:21-slim

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 스테이지에서 생성된 JAR 파일 복사
COPY --from=builder /app/build/libs/apigateway-service.jar .

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "apigateway-service.jar"]
