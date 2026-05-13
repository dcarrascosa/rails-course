# Rails para Desarrolladores C#

Curso práctico de Ruby on Rails orientado a desarrolladores con experiencia en C# y .NET. Cada módulo establece puentes explícitos entre ambos ecosistemas para acelerar el aprendizaje.

## Prerrequisitos

- Experiencia con C# y .NET (ASP.NET MVC o mínimo Web API)
- Conocimiento básico de SQL y Entity Framework
- Git instalado
- Ruby 3.3+ y Rails 8+ instalados ([rbenv](https://github.com/rbenv/rbenv) recomendado)

## Mapa del curso

| Módulo | Tema | Equivalente .NET |
|--------|------|------------------|
| 01 | [Ruby para devs C#](./modulo-01-introduccion/) | Sintaxis C# → Ruby |
| 02 | [MVC en Rails](./modulo-02-mvc/) | ASP.NET MVC |
| 03 | [ActiveRecord](./modulo-03-activerecord/) | Entity Framework Core |
| 04 | [Vistas y Hotwire](./modulo-04-vistas/) | Razor / Blazor |
| 05 | [Autenticación con Devise](./modulo-05-autenticacion/) | ASP.NET Identity |
| 06 | [Background Jobs con Sidekiq](./modulo-06-jobs/) | Hangfire / Azure Functions |
| 07 | [Testing con RSpec](./modulo-07-testing/) | xUnit / NUnit |
| 08 | [Deploy](./modulo-08-deploy/) | Azure App Service / Railway |

## Proyecto del curso

A lo largo del curso construirás **TaskFlow**, una app de gestión de tareas con autenticación, notificaciones por email y jobs en background. Cada módulo añade una capa funcional nueva.

## Convenciones del curso

- 🔵 **C#/.NET** — bloque de código equivalente en C# o ASP.NET
- 💎 **Ruby/Rails** — bloque de código Ruby on Rails
- ⚠️ **Trampa común** — diferencia que suele confundir a devs .NET
- ✅ **Ejercicio** — práctica propuesta

## Cómo contribuir

¡Las contribuciones son bienvenidas! Para mantener la calidad del material, **todo cambio debe llegar a `main` a través de una Pull Request** — los pushes directos están desactivados.

### Pasos

1. Haz fork del repositorio
2. Crea una rama descriptiva desde `main`:
   ```bash
   git checkout -b fix/modulo-03-typo
   # o
   git checkout -b feat/modulo-05-nuevo-ejercicio
   ```
3. Realiza tus cambios y escribe un commit claro
4. Abre una Pull Request hacia `main` con una descripción del cambio
5. Espera la revisión antes del merge

### Qué tipos de contribuciones se aceptan

- 🐛 Correcciones de errores en el código de los ejemplos
- 📝 Mejoras en las explicaciones o comparativas C#/Rails
- ➕ Nuevos ejercicios o soluciones alternativas
- 🌐 Traducciones (si el curso se expande a otros idiomas)

### Convención de ramas

| Prefijo | Uso |
|---------|-----|
| `fix/` | Correcciones de errores o typos |
| `feat/` | Nuevo contenido o ejercicios |
| `docs/` | Cambios solo en documentación |
| `refactor/` | Reorganización sin cambio de contenido |
