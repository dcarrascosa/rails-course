# Rails para Desarrolladores C#

Curso práctico de Ruby on Rails 8 orientado a desarrolladores con experiencia en C# y .NET. Cada módulo establece puentes explícitos entre ambos ecosistemas para acelerar el aprendizaje.

## Prerrequisitos

- Experiencia con C# y .NET (ASP.NET MVC o, como mínimo, Web API).
- Conocimiento básico de SQL y Entity Framework.
- Git instalado.
- Ruby 3.3+ y Rails 8+ funcionando. **Si todavía no los tienes**, sigue el [Módulo 00 — Setup](./modulo-00-setup/), donde se cubre la instalación por sistema operativo (macOS, Linux, Windows con WSL2).

> ⚠️ **Si estás en Windows**: usa WSL2. Rails funciona en Windows nativo pero el ecosistema asume Unix y vas a perder tiempo con gemas con extensiones C. El módulo 00 explica el setup con WSL2 paso a paso.

## Mapa del curso

| Módulo | Tema | Equivalente .NET |
|--------|------|------------------|
| 00 | [Setup del entorno](./modulo-00-setup/) | Instalación de SDK + tooling |
| 01 | [Ruby para devs C#](./modulo-01-introduccion/) | Sintaxis C# → Ruby |
| 02 | [MVC en Rails](./modulo-02-mvc/) | ASP.NET MVC |
| 03 | [ActiveRecord](./modulo-03-activerecord/) | Entity Framework Core |
| 04 | [Vistas y Hotwire](./modulo-04-vistas/) | Razor / Blazor |
| 05 | [Autenticación con Devise](./modulo-05-autenticacion/) | ASP.NET Identity |
| 06 | [Background Jobs con Sidekiq](./modulo-06-jobs/) | Hangfire / Azure Functions |
| 07 | [Testing con RSpec](./modulo-07-testing/) | xUnit / NUnit |
| 08 | [Deploy](./modulo-08-deploy/) | Azure App Service / Railway / Kamal |
| 09 | [JSON APIs](./modulo-09-api-json/) | Minimal APIs / Web API |

📌 [**CHEATSHEET.md**](./CHEATSHEET.md) — referencia rápida de una página con todos los mapeos C# ↔ Ruby/Rails.

## Proyecto del curso

A lo largo del curso construirás **TaskFlow**, una app de gestión de tareas con autenticación, notificaciones por email y jobs en background. Cada módulo añade una capa funcional nueva; el módulo 09 expone TaskFlow también como API JSON.

## Convenciones del curso

A lo largo de los módulos verás estos marcadores:

| Marcador | Significado |
|----------|-------------|
| 🔵 **C# / ASP.NET** | Bloque de código equivalente en C# o ASP.NET |
| 💎 **Ruby / Rails** | Bloque de código Ruby on Rails |
| 💎 **ERB** | Plantilla ERB (vistas) |
| ⚠️ **Trampa común** | Diferencia que suele confundir a devs .NET |
| ✅ **Ejercicio** | Práctica propuesta |

## Licencia

- **Código** (snippets, soluciones de ejercicios, configs): MIT.
- **Texto, explicaciones, diagramas**: CC BY 4.0.

Ver [`LICENSE`](./LICENSE) para el texto completo. Resumen: puedes usarlo, modificarlo y compartirlo, citando autoría.

## Cómo contribuir

Las contribuciones son bienvenidas. Para mantener la calidad del material, **todo cambio debe llegar a `main` a través de una Pull Request** — los pushes directos están desactivados.

### Pasos

1. Haz fork del repositorio.
2. Crea una rama descriptiva desde `main`:
   ```bash
   git checkout -b fix/modulo-03-typo
   # o
   git checkout -b feat/modulo-05-nuevo-ejercicio
   ```
3. Realiza tus cambios y escribe un commit claro (Conventional Commits: `fix:`, `feat:`, `docs:`, `refactor:`).
4. Abre una Pull Request hacia `main` con una descripción del cambio.
5. Espera la revisión antes del merge.

### Qué tipos de contribuciones se aceptan

- 🐛 Correcciones de errores en el código de los ejemplos
- 📝 Mejoras en las explicaciones o comparativas C# ↔ Rails
- ➕ Nuevos ejercicios o soluciones alternativas
- 🌐 Traducciones (si el curso se expande a otros idiomas)

### Convención de ramas

| Prefijo | Uso |
|---------|-----|
| `fix/` | Correcciones de errores o typos |
| `feat/` | Nuevo contenido o ejercicios |
| `docs/` | Cambios solo en documentación |
| `refactor/` | Reorganización sin cambio de contenido |
