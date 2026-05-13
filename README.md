# Rails para Desarrolladores C#

Curso práctico de Ruby on Rails orientado a desarrolladores con experiencia en C# y .NET. Cada módulo establece puentes explícitos entre los conceptos que ya conoces y su equivalente en Ruby on Rails.

## Prerrequisitos

- Experiencia con C# y .NET (ASP.NET MVC o Web API)
- Conocimiento básico de SQL y Entity Framework Core
- Git instalado y familiaridad con la línea de comandos
- Conocimientos básicos de POO

## Instalación del entorno

```bash
# Instalar rbenv (gestor de versiones de Ruby, equivalente a .NET SDK switcher)
curl -fsSL https://rbenv.org/install.sh | bash

# Instalar Ruby 3.3
rbenv install 3.3.0
rbenv global 3.3.0

# Instalar Rails
gem install rails

# Crear proyecto nuevo con PostgreSQL
rails new taskflow --database=postgresql
cd taskflow

# Arrancar el servidor de desarrollo
rails server  # equivale a dotnet run
```

## Mapa del curso

| Módulo | Tema | Equivalente .NET |
|--------|------|------------------|
| 01 | [Ruby para devs C#](./modulo-01-introduccion/) | Sintaxis, tipos, bloques, módulos |
| 02 | [MVC en Rails](./modulo-02-mvc/) | ASP.NET MVC, controladores, rutas |
| 03 | [ActiveRecord](./modulo-03-activerecord/) | Entity Framework Core, LINQ |
| 04 | [Vistas y Hotwire](./modulo-04-vistas/) | Razor Pages, Blazor |
| 05 | [Autenticación con Devise](./modulo-05-autenticacion/) | ASP.NET Identity, políticas |
| 06 | [Background Jobs con Sidekiq](./modulo-06-jobs/) | Hangfire, Azure Functions |
| 07 | [Testing con RSpec](./modulo-07-testing/) | xUnit, NUnit, Moq, Playwright |
| 08 | [Deploy](./modulo-08-deploy/) | Azure App Service, GitHub Actions |

## Proyecto del curso

A lo largo del curso construirás **TaskFlow**, una aplicación de gestión de tareas con:

- Autenticación completa (registro, login, recuperación de contraseña)
- CRUD de tareas y proyectos con actualización en tiempo real (sin JavaScript manual)
- Notificaciones por email en background
- Tests automatizados con cobertura > 80%
- Deploy continuo con GitHub Actions

Cada módulo añade una capa funcional nueva al proyecto, de manera que al final tienes una app real en producción.

## Convenciones del curso

- 🔵 **C#** — bloque de código equivalente en C#/.NET
- 💎 **Ruby/Rails** — bloque de código Ruby o Rails
- ⚠️ **Trampa común** — diferencia que suele confundir a devs C#
- ✅ **Ejercicio** — práctica propuesta
- 🏗️ **TaskFlow** — avance del proyecto del curso

## Diferencias filosóficas clave

Antes de empezar, es útil conocer las diferencias de mentalidad entre ambos ecosistemas:

| Aspecto | .NET / C# | Ruby / Rails |
|---------|-----------|---------------|
| Tipado | Estático, verificado en compilación | Dinámico, verificado en ejecución |
| Convención | Configuración explícita (`Program.cs`) | Convention over Configuration |
| ORM | EF Core (fluent API, migrations explícitas) | ActiveRecord (integrado en el modelo) |
| Plantillas | Razor (`.cshtml`) | ERB (`.html.erb`) |
| UI reactiva | Blazor / HTMX | Hotwire / Turbo |
| Gestor paquetes | NuGet (`dotnet add package`) | RubyGems (`gem`, `bundle`) |
| CLI | `dotnet new`, `dotnet ef` | `rails new`, `rails generate` |
| Entorno virtual | No necesario (aislado por proyecto) | rbenv + bundler |

## Estructura de cada módulo

Cada módulo sigue la misma estructura:

```
modulo-XX-nombre/
  README.md          ← teoría con comparativas C# ↔ Ruby
  ejercicios/
    enunciado.md     ← descripción de los ejercicios
    solucion/        ← código de solución comentado
```
