---
name: docker-deployment
description: Docker containerization patterns for any project. Use when working on containerization or deployment.
---

# Docker Deployment

## Dockerfile Best Practices
- Use specific base image tags (not `latest`)
- Use multi-stage builds to separate build and runtime
- Order layers from least to most frequently changed (deps before source)
- Use `.dockerignore` to exclude unnecessary files
- Run as non-root user in production
- Minimize layer count — combine related RUN commands

## Multi-Stage Build Pattern
```dockerfile
# Stage 1: Build
FROM <language-image> AS builder
WORKDIR /app
COPY dependency-files .
RUN install-dependencies
COPY . .
RUN build-command

# Stage 2: Runtime
FROM <minimal-runtime-image>
WORKDIR /app
COPY --from=builder /app/output .
USER nonroot
CMD ["run-command"]
```

## docker-compose.yml Patterns
```yaml
services:
  app:
    build: .
    ports: ["8080:8080"]
    depends_on: [db]
    environment:
      - DATABASE_URL=${DATABASE_URL}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  db:
    image: postgres:16-alpine  # or mysql, mongo, etc.
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:
```

## Common Commands
```bash
docker compose up -d            # start all services
docker compose exec app sh      # shell into container
docker compose logs -f app      # tail logs
docker compose down             # stop services
docker compose down -v          # stop and remove volumes (destructive)
docker compose build --no-cache # rebuild without cache
```

## Production Differences
- Use multi-stage builds to exclude dev dependencies
- Set production environment variables
- Mount secrets via environment or secret managers, not .env files
- Use named volumes for persistent data
- Add health checks to all services
- Set resource limits (memory, CPU)
- Use restart policies (`restart: unless-stopped`)

## Security
- Scan images for vulnerabilities (`docker scout`, `trivy`)
- Don't store secrets in image layers
- Use read-only filesystem where possible (`read_only: true`)
- Limit container capabilities
