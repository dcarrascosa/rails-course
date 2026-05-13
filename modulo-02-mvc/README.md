# Módulo 02 — MVC en Rails vs ASP.NET MVC

## Objetivos

- Crear una app Rails desde cero y entender su estructura
- Mapear los conceptos de ASP.NET MVC a Rails
- Implementar un CRUD completo usando scaffolding y sin él

---

## 1. Crear una nueva app

```bash
# ASP.NET
dotnet new mvc -n TaskFlow

# Rails
rails new taskflow --database=postgresql
cd taskflow
```

Estructura equivalente:

| ASP.NET MVC | Rails |
|-------------|-------|
| `Controllers/` | `app/controllers/` |
| `Views/` | `app/views/` |
| `Models/` | `app/models/` |
| `Program.cs` | `config/application.rb` + `config/routes.rb` |
| `appsettings.json` | `config/database.yml` + `.env` |
| `wwwroot/` | `public/` + `app/assets/` |

---

## 2. Rutas — Routes vs Attribute Routing

```csharp
// ASP.NET — atributos en el controlador
[Route("tasks")]
public class TasksController : Controller
{
    [HttpGet]        public IActionResult Index() { ... }
    [HttpGet("{id}")] public IActionResult Show(int id) { ... }
    [HttpPost]       public IActionResult Create(TaskDto dto) { ... }
}
```

```ruby
# Rails — config/routes.rb
Rails.application.routes.draw do
  resources :tasks  # genera los 7 endpoints RESTful de una vez
end

# Equivale a:
# GET    /tasks          tasks#index
# GET    /tasks/:id      tasks#show
# GET    /tasks/new      tasks#new
# POST   /tasks          tasks#create
# GET    /tasks/:id/edit tasks#edit
# PATCH  /tasks/:id      tasks#update
# DELETE /tasks/:id      tasks#destroy
```

Ver todas las rutas generadas:
```bash
rails routes
```

---

## 3. Controlador

```csharp
// ASP.NET
public class TasksController : Controller
{
    private readonly AppDbContext _db;
    public TasksController(AppDbContext db) => _db = db;

    public IActionResult Index()
    {
        var tasks = _db.Tasks.ToList();
        return View(tasks);
    }
}
```

```ruby
# Rails — app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  def index
    @tasks = Task.all  # @tasks disponible en la vista automáticamente
  end

  def show
    @task = Task.find(params[:id])
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to @task, notice: "Tarea creada"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def task_params  # equivale a un DTO con binding
    params.require(:task).permit(:title, :description, :completed)
  end
end
```

> **Clave:** Las variables de instancia `@variable` se pasan a la vista automáticamente. No necesitas `return View(model)` explícito.

---

## 4. Vistas ERB

```html
<!-- ASP.NET Razor: Views/Tasks/Index.cshtml -->
@model List<Task>
@foreach (var task in Model)
{
    <p>@task.Title</p>
}
```

```erb
<%# Rails ERB: app/views/tasks/index.html.erb %>
<% @tasks.each do |task| %>
  <p><%= task.title %></p>
<% end %>
```

| Razor | ERB |
|-------|-----|
| `@expression` | `<%= expression %>` |
| `@{ code }` | `<% code %>` |
| `@Html.ActionLink(...)` | `<%= link_to "Texto", tasks_path %>` |
| `@Html.BeginForm(...)` | `<%= form_with model: @task %>` |

---

## 5. Strong Parameters — el DTO de Rails

En ASP.NET defines DTOs para el binding. Rails usa **strong parameters** para evitar mass assignment:

```ruby
def task_params
  params.require(:task).permit(:title, :description, :completed)
end
```

Solo los campos declarados en `permit` se asignan al modelo.

---

## 6. Trampas comunes

> ⚠️ **`params` no es type-safe** — todo llega como string. `params[:id]` es `"42"`, no `42`. ActiveRecord hace el cast en `find`, pero si comparas a mano (`params[:age] > 18`) explota. Convierte explícito: `params[:age].to_i`.

> ⚠️ **No existe binding automático a un DTO tipado** — el equivalente es `permit`. Si olvidas un campo en `permit`, se ignora silenciosamente al guardar (no error, no warning). Test → revisa lo que se guarda.

> ⚠️ **`@variable` se pasa a la vista, las locales no** — en `def index`, `tasks = Task.all` (sin `@`) no llega a la vista. La instancia (`@tasks`) sí. Es la fuente número 1 de "por qué la vista ve nil".

> ⚠️ **`render` vs `redirect_to`** — `render` renderiza la vista en la misma request (no cambia URL). `redirect_to` devuelve 302 al navegador para que haga una nueva request. Usar `render` en `create` cuando hay error es lo correcto; usar `redirect_to` perdería los errores de validación.

> ⚠️ **`resources :tasks` genera 7 rutas, no 8** — no hay ruta para "destroy_all" ni similares. Si necesitas acciones custom, añádelas con `member` / `collection`:
> ```ruby
> resources :tasks do
>   member { patch :complete }     # /tasks/:id/complete
>   collection { delete :purge }   # /tasks/purge
> end
> ```

---

## Ejercicios

### Ejercicio 1 — CRUD completo con scaffold

```bash
rails generate scaffold Task title:string description:text completed:boolean
rails db:migrate
rails server
```

Explora las rutas generadas con `rails routes` e identifica el equivalente en ASP.NET de cada acción.

### Ejercicio 2 — Controlador sin scaffold

Crea manualmente un controlador `ProjectsController` con acciones `index` y `show`. Crea las vistas ERB correspondientes.

### Ejercicio 3 — Rutas anidadas

Modifica `routes.rb` para que las tareas estén anidadas bajo proyectos:
```ruby
resources :projects do
  resources :tasks
end
```
¿Cómo cambian las URLs y los helpers de ruta?

---

## Proyecto TaskFlow — avance

Al final de este módulo, TaskFlow tiene:
- Scaffold de `Task` con CRUD funcionando
- Layout base con navbar
- Rutas RESTful definidas
