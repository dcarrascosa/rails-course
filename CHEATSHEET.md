# Cheatsheet — C# / .NET ↔ Ruby / Rails

Una página, sin paja. Imprime, pega en el monitor, consulta.

---

## Sintaxis básica

| C# | Ruby |
|----|------|
| `string s = "x";` | `s = "x"` |
| `var x = 1;` | `x = 1` |
| `name == null` | `name.nil?` |
| `name ?? "default"` | `name || "default"` |
| `user?.Name` | `user&.name` |
| `$"Hola {name}"` | `"Hola #{name}"` |
| `someBool ? "a" : "b"` | `some_bool ? "a" : "b"` |
| `// comentario` | `# comentario` |
| `using System;` | `require "system"` |
| `throw new ArgumentException("x");` | `raise ArgumentError, "x"` |
| `try { ... } catch (Ex e) { ... }` | `begin ... rescue Ex => e ... end` |

---

## Tipos y colecciones

| C# | Ruby |
|----|------|
| `List<int>` | `Array` (sin tipo) |
| `Dictionary<string,string>` | `Hash` |
| `new List<int> {1,2,3}` | `[1, 2, 3]` |
| `new Dictionary<string,object> { {"k","v"} }` | `{ k: "v" }` (símbolos) o `{ "k" => "v" }` |
| `list.Count` | `array.size` o `array.length` |
| `dict["k"]` | `hash[:k]` |
| `enum Status { Active, Off }` | en AR: `enum :status, { active: 0, off: 1 }` |
| `null` | `nil` |
| `bool? maybe` | un valor que puede ser `nil` |

---

## LINQ ↔ Enumerable / ActiveRecord

| C# (LINQ) | Ruby (Enumerable) | ActiveRecord (SQL) |
|-----------|-------------------|--------------------|
| `Select(x => x.Y)` | `map { |x| x.y }` | `pluck(:y)` (más eficiente) |
| `Where(x => x.A)` | `select { |x| x.a }` | `where(a: true)` |
| `Any(x => ...)` | `any? { |x| ... }` | `exists?` |
| `All(x => ...)` | `all? { |x| ... }` | — |
| `First()` | `first` | `first` |
| `FirstOrDefault()` | — | `find_by(...)` |
| `Find / FirstOrDefault by id` | — | `find_by(id:)` (nil) / `find` (raises) |
| `Single()` | `one?` (predicado, no devuelve) | — |
| `OrderBy(x => x.A)` | `sort_by { |x| x.a }` | `order(a: :asc)` |
| `GroupBy(x => x.A)` | `group_by { |x| x.a }` | `group(:a)` |
| `Count(x => x.A)` | `count { |x| x.a }` | `where(a: true).count` |
| `Sum(x => x.A)` | `sum { |x| x.a }` | `sum(:a)` |
| `Include(x => x.B)` | — | `includes(:b)` |
| `ToList()` | `to_a` | `to_a` |
| `Skip(10).Take(5)` | `drop(10).take(5)` | `offset(10).limit(5)` |
| `Distinct()` | `uniq` | `distinct` |

---

## Clases y herencia

| C# | Ruby |
|----|------|
| `public class User { }` | `class User; end` |
| `class Admin : User { }` | `class Admin < User; end` |
| `public string Name { get; set; }` | `attr_accessor :name` |
| `public string Name { get; }` (readonly) | `attr_reader :name` |
| `interface IGreet { ... }` + `: IGreet` | `module Greet; end` + `include Greet` |
| `abstract class` | no existe formal; convención + `raise NotImplementedError` |
| `static` method | `def self.method_name` |
| `this` | `self` |
| `base.Method()` | `super` |
| `private` | `private` (modifier siguiente, no por método) |

---

## Frameworks — ASP.NET ↔ Rails

| ASP.NET / .NET | Rails |
|----------------|-------|
| `dotnet new mvc` | `rails new app` |
| `dotnet new webapi` | `rails new app --api` |
| `dotnet run` | `bin/rails server` |
| `dotnet ef migrations add X` | `bin/rails generate migration X` |
| `dotnet ef database update` | `bin/rails db:migrate` |
| `dotnet test` | `bundle exec rspec` |
| `Program.cs` + `Startup.cs` | `config/application.rb` + `config/routes.rb` |
| `appsettings.json` | `config/database.yml`, `config/credentials.yml.enc` |
| `[Route("...")]` + `[HttpGet]` | `routes.rb`: `resources :tasks` |
| `IActionResult` | implícito — render por convención |
| `View(model)` | `@model` + `render :template` |
| `[Authorize]` | `before_action :authenticate_user!` |
| `User.Identity.Name` | `current_user.email` |
| `_Layout.cshtml` | `app/views/layouts/application.html.erb` |
| `@RenderBody()` | `<%= yield %>` |
| `@Html.PartialAsync("_X", m)` | `render "x", m: m` |
| Razor `@var` | ERB `<%= var %>` |
| `DbContext` | `ApplicationRecord` |
| `DbSet<Task>` | la propia clase `Task < ApplicationRecord` |
| `[Required]`, `[StringLength(50)]` | `validates :x, presence: true, length: { maximum: 50 }` |
| FluentValidation | `validates ...` + `validate :custom_method` |
| AutoMapper | `Alba` / `Jbuilder` / `as_json` |
| ASP.NET Identity | Devise |
| `IAuthorizationPolicy` | Pundit |
| Hangfire | Sidekiq / Solid Queue |
| `IHostedService` | Active Job |
| SignalR | Action Cable |
| Blazor Server (UI reactiva) | Hotwire (Turbo + Stimulus) |
| Swashbuckle | rswag |
| xUnit / NUnit | RSpec |
| Moq | RSpec mocks (`double`, `instance_double`, `allow`) |
| Builder pattern manual | FactoryBot |

---

## CLI rápida

| Quiero... | Comando |
|-----------|---------|
| Generar modelo | `bin/rails generate model Task title:string completed:boolean` |
| Generar controller | `bin/rails generate controller Tasks index show` |
| Generar scaffold (todo) | `bin/rails generate scaffold Task title:string` |
| Ver todas las rutas | `bin/rails routes` (o `bin/rails routes -g task`) |
| Consola interactiva | `bin/rails console` (≈ `dotnet script`) |
| Conectar a la DB | `bin/rails dbconsole` |
| Servidor con jobs y assets | `bin/dev` (usa Foreman + `Procfile.dev`) |
| Limpiar y resembrar DB | `bin/rails db:reset` |
| Solo migrar | `bin/rails db:migrate` |
| Deshacer última migración | `bin/rails db:rollback` |
| Generar secret | `bin/rails secret` |
| Tests con cobertura | `COVERAGE=true bundle exec rspec` |
| Linter | `bundle exec rubocop` |

---

## ERB en 30 segundos

| Razor | ERB |
|-------|-----|
| `@variable` | `<%= variable %>` |
| `@{ var x = 1; }` | `<% x = 1 %>` |
| `@foreach (var t in tasks)` | `<% tasks.each do |t| %>` ... `<% end %>` |
| `@if (cond) { }` | `<% if cond %>` ... `<% end %>` |
| `@Html.Raw(html)` | `<%= raw(html) %>` (ojo XSS) |
| `@Url.Action("Show", new {id})` | `<%= task_path(task) %>` |
| `@Html.PartialAsync("_x")` | `<%= render "x" %>` |
| `@RenderBody()` | `<%= yield %>` |
| `@section Foo { }` + `@RenderSection("Foo")` | `<% content_for :foo do %>...<% end %>` + `<%= yield :foo %>` |

---

## Naming a recordar

| Concepto | C# | Ruby |
|----------|-----|------|
| Clase | `PascalCase` | `PascalCase` |
| Método / variable | `camelCase` / `PascalCase` | `snake_case` |
| Constante | `PascalCase` o `UPPER_CASE` | `UPPER_CASE` |
| Booleano | `IsX`, `HasX` | `x?` (acaba en `?`) |
| Método mutador / peligroso | (sin convención) | `x!` (acaba en `!`) |
| Privado | `private` keyword | `private` modifier de sección |

---

## "Cuando algo no funciona..."

1. **`undefined method 'foo' for nil`** → algo es `nil` que no esperabas. Mira el stack trace y la línea exacta.
2. **`ActiveRecord::RecordNotFound`** → `find` no encontró el id. Usa `find_by` o maneja la excepción.
3. **`ActiveRecord::RecordInvalid`** → estás llamando `save!` y las validaciones fallan. Mira `record.errors.full_messages`.
4. **`Missing template`** → el método del controller no tiene su `index.html.erb` asociado o renderizas un format que no existe.
5. **`Routing Error: No route matches`** → mira `bin/rails routes`. La ruta no está declarada o el verbo HTTP no coincide.
6. **N+1 queries en logs** → añade `includes(:asociacion)` a la query.
7. **`Encoding::UndefinedConversionError`** → datos con encoding distinto a UTF-8. Fuerza con `string.force_encoding("UTF-8")` o limpia en la fuente.

---

📌 Para profundizar, ver los módulos correspondientes del curso.
