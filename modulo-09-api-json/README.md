# Módulo 09 — JSON APIs en Rails vs Minimal APIs / Web API

## Objetivos

- Construir endpoints JSON puros con `ActionController::API`
- Serializar con `jbuilder` o **Alba** (alternativa moderna, más rápida)
- Versionar la API y manejar autenticación con tokens
- Documentar con OpenAPI usando `rswag`

---

## 1. ¿Cuándo elegir API-only?

En .NET tienes dos opciones para APIs: **Minimal APIs** (ligeras, top-level statements) y **MVC Web API** (controladores tradicionales). Rails tiene una distinción equivalente:

- **App Rails completa** (`rails new myapp`) — el default. Sirve HTML, JSON, Turbo Streams. Útil si vas a tener UI.
- **App Rails API-only** (`rails new myapp --api`) — descarta toda la pila de vistas, cookies, sesión por defecto, assets. Más rápida, menos memoria, equivalente a un proyecto `dotnet new webapi`.

🔵 **C# / ASP.NET**
```csharp
// Minimal API
var app = WebApplication.CreateBuilder(args).Build();

app.MapGet("/tasks", async (AppDbContext db) =>
    await db.Tasks.ToListAsync());

app.MapPost("/tasks", async (TaskDto dto, AppDbContext db) => {
    var task = new Task { Title = dto.Title };
    db.Tasks.Add(task);
    await db.SaveChangesAsync();
    return Results.Created($"/tasks/{task.Id}", task);
});

app.Run();
```

💎 **Ruby / Rails**
```bash
rails new taskflow_api --api --database=postgresql
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks
    end
  end
end

# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy]

      def index
        @tasks = Task.all
        render json: @tasks
      end

      def show
        render json: @task
      end

      def create
        @task = Task.new(task_params)
        if @task.save
          render json: @task, status: :created, location: api_v1_task_url(@task)
        else
          render json: { errors: @task.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_task
        @task = Task.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :completed)
      end
    end
  end
end
```

---

## 2. Serialización — `to_json` no es suficiente

`render json: @task` llama a `to_json` por defecto: devuelve **todos** los atributos del modelo, incluida cualquier columna sensible (`password_digest`, `api_token`...). Esto es lo equivalente a devolver una entity de EF sin DTO. **No lo hagas en producción.**

### Opción A — Jbuilder (incluido en Rails)

🔵 **C# / ASP.NET**
```csharp
// AutoMapper o un DTO a mano
public class TaskDto {
    public int Id { get; init; }
    public string Title { get; init; }
    public bool Completed { get; init; }
    public string UserName { get; init; }
}
```

💎 **Ruby / Rails**
```ruby
# app/views/api/v1/tasks/show.json.jbuilder
json.id          @task.id
json.title       @task.title
json.completed   @task.completed
json.user_name   @task.user.name
json.created_at  @task.created_at
```

```ruby
# El controlador se reduce a:
def show
  @task = Task.find(params[:id])
  # render :show es implícito y Rails busca show.json.jbuilder
end
```

### Opción B — Alba (recomendado para APIs serias)

[Alba](https://github.com/okuramasafumi/alba) es 3-5× más rápido que Jbuilder y la sintaxis es más cercana a un DTO:

```ruby
# Gemfile
gem "alba"

# app/resources/task_resource.rb
class TaskResource
  include Alba::Resource

  attributes :id, :title, :completed, :created_at

  attribute :user_name do |task|
    task.user.name
  end
end

# Controlador
def show
  task = Task.find(params[:id])
  render json: TaskResource.new(task).serialize
end
```

---

## 3. Versionado de API

```ruby
# config/routes.rb
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    resources :tasks
  end

  namespace :v2 do
    resources :tasks
  end
end
```

URLs: `/api/v1/tasks`, `/api/v2/tasks`. El equivalente de .NET es `app.MapGroup("/api/v1")`.

> ⚠️ **No versiones a base de query params** (`/tasks?v=2`). Aunque "funciona", rompe el caché por URL y complica los clientes. Versiona por path o por header (`Accept: application/vnd.taskflow.v2+json`).

---

## 4. Autenticación con tokens

Olvídate de cookies en una API pura. Dos patrones:

### Patrón A — Token por usuario (simple, no expirable)

```ruby
# bin/rails generate migration AddApiTokenToUsers api_token:string:index

class User < ApplicationRecord
  has_secure_token :api_token
end
```

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_with_token!

      private

      def authenticate_with_token!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_user = User.find_by(api_token: token)
        head :unauthorized unless @current_user
      end

      attr_reader :current_user
    end
  end
end
```

### Patrón B — JWT (con expiración, sin estado en servidor)

```ruby
# gem "jwt"

class JwtService
  SECRET = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp: 24.hours.from_now)
    JWT.encode(payload.merge(exp: exp.to_i), SECRET, "HS256")
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: "HS256").first
  rescue JWT::DecodeError
    nil
  end
end

# En el controlador
def authenticate_with_jwt!
  token   = request.headers["Authorization"]&.split(" ")&.last
  payload = JwtService.decode(token)
  @current_user = User.find_by(id: payload && payload["user_id"])
  head :unauthorized unless @current_user
end
```

> ⚠️ **No metas JWT en localStorage si la API es de uso público desde navegadores** — vulnerable a XSS. Usa cookies `HttpOnly` + CSRF, o autenticación por token con scope limitado.

---

## 5. CORS — abrir la API a clientes externos

```ruby
# Gemfile
gem "rack-cors"

# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGIN", "http://localhost:5173")  # Vite, Next, etc.
    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization]
  end
end
```

Equivalente a `services.AddCors(...)` + `app.UseCors(...)` en .NET.

---

## 6. Documentación con OpenAPI (rswag)

`rswag` genera documentación Swagger/OpenAPI **a partir de tus tests**. Si los tests pasan, la docu refleja el comportamiento real (no se desincroniza como pasa con Swashbuckle si cambias controllers sin tocar comentarios).

```ruby
# Gemfile group :development, :test
gem "rswag-api"
gem "rswag-specs"
gem "rswag-ui"
```

```ruby
# spec/integration/tasks_spec.rb
require "swagger_helper"

RSpec.describe "Tasks API", type: :request do
  path "/api/v1/tasks" do
    get "Lista de tareas" do
      tags "Tasks"
      produces "application/json"
      security [bearer_auth: []]

      response "200", "lista devuelta" do
        schema type: :array, items: { "$ref" => "#/components/schemas/Task" }
        run_test!
      end
    end

    post "Crear tarea" do
      consumes "application/json"
      parameter name: :task, in: :body, schema: { "$ref" => "#/components/schemas/TaskInput" }

      response "201", "creada" do
        let(:task) { { task: { title: "Demo" } } }
        run_test!
      end

      response "422", "inválida" do
        let(:task) { { task: { title: "" } } }
        run_test!
      end
    end
  end
end
```

`bundle exec rake rswag:specs:swaggerize` genera `swagger/v1/swagger.yaml`. Sirve `swagger-ui` en `/api-docs`.

---

## 7. Trampas comunes

> ⚠️ **`ActionController::API` no incluye `protect_from_forgery`** — esto es bueno (no quieres CSRF en una API de tokens) pero pésimo si mezclas controllers HTML y JSON. **No** heredes API controllers de `ApplicationController` si la app es full-stack.

> ⚠️ **`render json: collection` no incluye relaciones por defecto** — para devolver `task.user`, pásalo explícito: `render json: @tasks.as_json(include: :user)`. Mejor: usa un serializador.

> ⚠️ **Devuelve errores en estructura consistente** — escoge un formato (JSON:API, RFC 7807 "Problem Details", o el tuyo) y mantenlo. Lo peor para un consumidor de tu API es que `400` devuelva `{ "error": "..." }` y `422` devuelva `{ "errors": [...] }`.

> ⚠️ **`page` y `per_page` no son nativos** — añade gema `kaminari` o `pagy` para paginación. Sin esto, `Task.all` con 50k registros revienta.

> ⚠️ **No reutilices URLs HTML y JSON** — `/tasks` (HTML) y `/api/v1/tasks` (JSON) deberían ser controllers separados, con sus tests, sus serializadores y su versionado. Mezclar `respond_to do |format|` funciona para apps pequeñas; en cuanto crece, ensucia todo.

---

## ✅ Ejercicios

### ✅ Ejercicio 1 — API CRUD básica

Crea una nueva app Rails con `--api` y expón un CRUD completo de `Task` bajo `/api/v1/tasks`. Devuelve errores 422 en formato consistente.

### ✅ Ejercicio 2 — Autenticación con token

Añade `has_secure_token :api_token` al modelo `User`. Crea un endpoint `POST /api/v1/auth/login` que reciba email + password y devuelva el token. Protege los endpoints de tareas con `before_action :authenticate_with_token!`.

### ✅ Ejercicio 3 — Documentar con rswag

Configura `rswag-specs`, escribe specs para los endpoints de tareas y genera el `swagger.yaml`. Sirve la UI en `/api-docs`.

---

## Solución

Ver [`ejercicios/solucion/modulo09.rb`](./ejercicios/solucion/modulo09.rb)
