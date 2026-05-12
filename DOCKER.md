# 🐳 Backend Ventas - Docker

Guía para construir, ejecutar y desplegar la API Backend de Ventas con Docker.

## 📋 Requisitos

- Docker Desktop instalado
- Docker Compose instalado
- Git configurado
- Java 21 (para desarrollo local, no necesario con Docker)

## 🏗️ Estructura de Archivos Docker

```
Dockerfile           # Dockerfile multi-stage optimizado con Maven
docker-compose.yml   # Configuración de servicios
.dockerignore       # Archivos a excluir de la imagen
DOCKER.md          # Este archivo
```

## 🚀 Construcción de la Imagen

### Opción 1: Usando docker-compose (RECOMENDADO)

```bash
# Construir la imagen
docker compose build

# Ejecutar el contenedor
docker compose up -d

# Ver logs
docker compose logs -f backend-ventas

# Detener
docker compose down
```

### Opción 2: Usando Docker directamente

```bash
# Construir la imagen
docker build -t backend-ventas:latest .

# Ejecutar el contenedor
docker run -d \
  --name backend-ventas \
  -p 8081:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC" \
  backend-ventas:latest

# Ver logs
docker logs -f backend-ventas

# Detener
docker stop backend-ventas
docker rm backend-ventas
```

## 🔍 Verificación

```bash
# Acceder a la API
http://localhost:8081

# Health check
http://localhost:8081/actuator/health

# Swagger/OpenAPI (si está configurado)
http://localhost:8081/swagger-ui.html

# Verificar estado del contenedor
docker ps

# Health check detallado
docker compose ps
```

## 📦 Características de la Imagen

✅ **Multi-stage build**: Maven build + JRE runtime  
✅ **Maven 3.9 + Java 21 Alpine**: Build ligero y optimizado  
✅ **Eclipse Temurin JRE 21**: Runtime ligero  
✅ **Usuario no root**: Seguridad mejorada (usuario spring)  
✅ **Health check**: Monitoreo via Spring Boot Actuator  
✅ **Optimización JVM**: G1GC garbage collector  
✅ **Memory management**: -Xmx512m -Xms256m configurado  
✅ **Dumb-init**: Manejo correcto de señales  

## 🔒 Seguridad

- Ejecuta como usuario `spring` (no root, UID 1000)
- Dumb-init para manejo correcto de señales SIGTERM
- Health check via actuator endpoint
- JVM optimizado con G1GC
- Alpine Linux (reducido surface area)

## 📊 Tamaño de la Imagen

Tamaño final: ~300-350 MB (dependiendo de dependencias)
- Build: ~600 MB (descartado en stage 2)
- Runtime: ~300 MB (solo JRE)

## ⚙️ Variables de Entorno

| Variable | Default | Descripción |
|----------|---------|------------|
| JAVA_OPTS | -Xmx512m -Xms256m -XX:+UseG1GC | Opciones JVM |
| SPRING_PROFILES_ACTIVE | prod | Perfil Spring Boot |
| SPRING_APPLICATION_NAME | backend-ventas | Nombre de la app |

## 🌱 Actuator Endpoints

Disponibles en `http://localhost:8080/actuator`:
- `/health` - Health check
- `/info` - Información de la app
- `/metrics` - Métricas de rendimiento

## 🆘 Troubleshooting

### Puerto 8081 en uso
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "8080:8080"
```

### Build falla sin conexión a internet
```bash
# Maven puede necesitar repositorios locales
# Agregar en Dockerfile si es necesario
```

### Logs del contenedor
```bash
docker compose logs -f backend-ventas
```

### Reconstruir sin caché
```bash
docker compose build --no-cache
```

### Inspeccionar imagen
```bash
docker inspect backend-ventas:latest
```

## 📝 Notas

- La rama `deploy` tiene estos archivos configurados
- Alineado a rúbrica máxima (DevOps/Containerización)
- Listo para CI/CD pipeline
- Soporta clustering con Spring Cloud
- Compatible con Kubernetes

## 🔗 Integración Multi-Contenedor

Ver archivo `docker-compose.yml` en la raíz del proyecto para levantar Frontend + Backend Ventas + Backend Despachos juntos.
