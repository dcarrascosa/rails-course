# Módulo 08 — Deploy vs Azure App Service

## Objetivos

- Preparar una app Rails para producción
- Hacer deploy en Railway (equivalente moderno a Azure App Service para Rails)
- Configurar variables de entorno, base de datos y jobs en producción

---

## 1. Preparar para producción

### Variables de entorno

```bash
# .env (nunca en git)
DATABASE_URL=postgresql://user:pass@host/taskflow_production
REDIS_URL=redis://localhost:6379
SECRET_KEY_BASE=generated_with_rails_secret
DEVISE_SECRET_KEY=another_secret
```

💎 **Ruby / Rails**
```ruby
# config/database.yml
production:
  url: <%= ENV["DATABASE_URL"] %>
```

### Assets y precompilación

```bash
rails assets:precompile RAILS_ENV=production
# Equivale a: dotnet publish -c Release
```

---

## 2. Deploy en Railway

Railway detecta automáticamente apps Rails. Equivalente conceptual a Azure App Service:

| Azure App Service | Railway |
|-------------------|---------|
| App Service Plan | Environment |
| Configuration → App settings | Variables |
| Deployment Center | GitHub integration |
| Log stream | Logs en tiempo real |
| Scale out | Replicas |

```bash
# Instalar Railway CLI
npm install -g @railway/cli
railway login
railway init
railway up
```

### Procfile

```
# Procfile
web:    bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

Equivalente al startup de `Program.cs` + el Hangfire server en background.

---

## 3. Deploy en Render (alternativa)

```yaml
# render.yaml
services:
  - type: web
    name: taskflow
    runtime: ruby
    buildCommand: bundle install && rails assets:precompile
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: RAILS_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: taskflow-db
          property: connectionString

databases:
  - name: taskflow-db
    plan: free
```

---

## 4. Docker — equivalente al Dockerfile de .NET

> Rails 8 genera un `Dockerfile` listo para producción al crear la app (`rails new`). Lo de abajo es la versión simplificada para entender qué hace.

```dockerfile
# Dockerfile
FROM ruby:3.3-slim

RUN apt-get update && apt-get install -y \
    build-essential libpq-dev nodejs npm

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .
RUN rails assets:precompile RAILS_ENV=production

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

### Kamal — el deploy "oficial" de Rails 8

Rails 8 incluye **Kamal 2** como herramienta de deploy. Despliega un contenedor Docker en cualquier VPS (Hetzner, DigitalOcean, tu propio servidor) sin depender de un PaaS:

```bash
bin/kamal setup    # primera vez
bin/kamal deploy   # despliegues posteriores
```

```yaml
# config/deploy.yml
service: taskflow
image: tu-usuario/taskflow
servers:
  web:
    - 203.0.113.10
registry:
  username: tu-usuario
  password:
    - KAMAL_REGISTRY_PASSWORD
env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
```

Equivale a tener tu propio Azure App Service en una VM por una fracción del precio, a cambio de gestionar el servidor tú.

---

## 5. CI/CD con GitHub Actions

Equivalente a los pipelines de Azure DevOps:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - run: bundle exec rails db:create db:migrate
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/test
          RAILS_ENV: test
      - run: bundle exec rspec
```

---

## 6. Trampas comunes

> ⚠️ **`RAILS_MASTER_KEY` y `SECRET_KEY_BASE` no son lo mismo** — `RAILS_MASTER_KEY` desencripta `config/credentials.yml.enc`. `SECRET_KEY_BASE` firma cookies y sesiones. Si rotas `SECRET_KEY_BASE`, todos los usuarios pierden sesión. Cuídalas como contraseñas root.

> ⚠️ **`rails assets:precompile` falla silenciosamente si Node/JS engine no está disponible** — en imágenes Docker minimalistas, falta `nodejs` y `yarn`. Usa la imagen oficial de Rails 8 o instálalos en el Dockerfile.

> ⚠️ **`config.force_ssl = true` en producción puede dejarte fuera** — si tu proxy (Nginx, Cloudflare) ya termina TLS y no manda los headers correctos, Rails rebota a `https://` y entra en bucle infinito. Verifica `config.assume_ssl = true` + headers `X-Forwarded-Proto`.

> ⚠️ **`heroku run rails db:migrate` está deprecated** — Heroku ya no es gratis. Si vienes de tutoriales antiguos, busca el equivalente del PaaS que uses (Railway tiene `railway run`, Render hace migraciones como build step, Fly.io tiene `fly ssh console`).

> ⚠️ **CSRF y APIs cross-origin** — si expones una API consumida desde otro origen (móvil, SPA externa), `protect_from_forgery` puede bloquear requests legítimas. La solución correcta: usa `ActionController::API` para esos controladores, no desactives CSRF globalmente.

> ⚠️ **Variables de entorno con valores numéricos llegan como string** — `ENV["MAX_RETRIES"]` es `"3"`, no `3`. Convierte: `ENV.fetch("MAX_RETRIES", "3").to_i`. Y usa `fetch` en vez de `[]` para fallar rápido si falta una env crítica.

---

## Ejercicios

### ✅ Ejercicio 1 — Preparar para producción

Configura `config/environments/production.rb` con las opciones de logging, caché y assets correctas. Genera una `SECRET_KEY_BASE` con `rails secret`.

### ✅ Ejercicio 2 — Deploy en Railway

Haz un deploy real de TaskFlow en Railway con base de datos PostgreSQL. Configura las variables de entorno desde el dashboard.

### ✅ Ejercicio 3 — Pipeline CI/CD

Configura el workflow de GitHub Actions para que ejecute los tests en cada push a `main` y haga deploy automático a Railway si pasan.

---

## Proyecto TaskFlow — versión final

Al completar el curso, TaskFlow es una app en producción con:
- Autenticación completa con Devise
- CRUD de tareas con Turbo Frames
- Notificaciones por email con Sidekiq
- Tests con > 80% de cobertura
- Deploy automático con GitHub Actions

---

## Solución

Ver:
- [`ejercicios/solucion/production.rb`](./ejercicios/solucion/production.rb)
- [`ejercicios/solucion/ci.yml`](./ejercicios/solucion/ci.yml)
