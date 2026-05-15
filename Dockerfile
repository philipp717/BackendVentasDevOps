# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos Maven y POM
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn
COPY pom.xml .

# Copiar código fuente
COPY src ./src

# Construir la aplicación
RUN mvn clean package -DskipTests -Dmaven.wagon.http.ssl.insecure=true

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine

# Labels
LABEL maintainer="Philipp Reyes <philipp@example.com>" \
      version="1.0" \
      description="Backend Ventas - Spring Boot REST API"

# Instalar tini y ca-certificates
RUN apk add --no-cache tini ca-certificates

# Variables de entorno
ENV APP_HOME=/app \
    JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200" \
    SPRING_PROFILES_ACTIVE=prod

# Crear directorio de la aplicación
WORKDIR ${APP_HOME}

# Crear usuario no root
RUN addgroup -g 1000 spring && \
    adduser -D -u 1000 -G spring spring && \
    mkdir -p ${APP_HOME} && \
    chown -R spring:spring ${APP_HOME}

# Copiar JAR desde builder
COPY --from=builder --chown=spring:spring /app/target/*.jar ${APP_HOME}/app.jar

# Usuario no root
USER spring

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Usar tini para ejecutar la aplicación
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["java", "-jar", "app.jar"]
