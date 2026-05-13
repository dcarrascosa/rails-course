# Módulo 03 — ActiveRecord vs Entity Framework Core

## Objetivos

- Crear modelos, migraciones y relaciones en ActiveRecord
- Mapear queries LINQ a su equivalente ActiveRecord
- Entender validaciones como alternativa a FluentValidation

---

## 1. Migraciones

```bash
# EF Core
dotnet ef migrations add CreateTasks
dotnet ef database update

# Rails
rails generate migration CreateTasks title:string completed:boolean
rails db:migrate
rails db:rollback  # equivale a dotnet ef migrations remove
```

Fichero de migración generado:

💎 **Ruby / Rails**
```ruby
# db/migrate/20240501_create_tasks.rb
class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps  # created_at y updated_at automáticos
    end
  end
end
```

> **Clave:** `t.timestamps` equivale a las propiedades `CreatedAt`/`UpdatedAt` con auditoría automática de EF.

---

## 2. Modelo y validaciones

🔵 **C# / ASP.NET**
```csharp
// EF Core + FluentValidation
public class Task
{
    public int Id { get; set; }
    public string Title { get; set; }
    public bool Completed { get; set; }
    public int UserId { get; set; }
    public User User { get; set; }
}

public class TaskValidator : AbstractValidator<Task>
{
    public TaskValidator()
    {
        RuleFor(t => t.Title).NotEmpty().MaximumLength(200);
    }
}
```

💎 **Ruby / Rails**
```ruby
# ActiveRecord — app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :completed, inclusion: { in: [true, false] }

  scope :completed,   -> { where(completed: true) }
  scope :pending,     -> { where(completed: false) }
  scope :recent,      -> { order(created_at: :desc) }
end
```

---

## 3. Queries — LINQ vs ActiveRecord

🔵 **C# / ASP.NET**
```csharp
// C# LINQ
var tasks = db.Tasks
    .Where(t => !t.Completed)
    .OrderBy(t => t.CreatedAt)
    .Take(10)
    .ToList();

var task = db.Tasks.FirstOrDefault(t => t.Id == id);

var count = db.Tasks.Count(t => t.UserId == userId);
```

💎 **Ruby / Rails**
```ruby
# ActiveRecord — lazy evaluation, igual que IQueryable
tasks = Task
  .where(completed: false)
  .order(created_at: :asc)
  .limit(10)
  .to_a  # ejecuta la query (como .ToList())

task  = Task.find(id)          # lanza excepción si no existe (como FindOrFail)
task  = Task.find_by(id: id)   # nil si no existe (como FirstOrDefault)
count = Task.where(user: user).count
```

### Queries con joins

🔵 **C# / ASP.NET**
```csharp
// EF Core
var tasks = db.Tasks
    .Include(t => t.User)
    .Where(t => t.User.Email.Contains("@empresa.com"))
    .ToList();
```

💎 **Ruby / Rails**
```ruby
# ActiveRecord
tasks = Task
  .joins(:user)
  .where("users.email LIKE ?", "%@empresa.com")  # parametrizado: nada de interpolación de strings
  .includes(:user)                               # eager loading — evita N+1
```

> ⚠️ **Trampa común:** `where(users: { email: /regex/ })` **no funciona** — ActiveRecord no traduce expresiones regulares de Ruby a SQL en el `where` hash. Usa `LIKE ?` con `?` (placeholder seguro contra inyección) o la API `Arel`.

---

## 4. Relaciones

🔵 **C# / ASP.NET**
```csharp
// EF Core — Data Annotations
public class User
{
    public ICollection<Task> Tasks { get; set; }
}

public class Task
{
    public int UserId { get; set; }
    [ForeignKey("UserId")]
    public User User { get; set; }
}
```

💎 **Ruby / Rails**
```ruby
# ActiveRecord — app/models/user.rb
class User < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :projects
  has_many :project_tasks, through: :projects, source: :tasks  # many-to-many
end

# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user
end

# Uso
user.tasks           # SELECT * FROM tasks WHERE user_id = ?
user.tasks.create(title: "Nueva tarea")  # INSERT automático con user_id
```

---

## 5. Trampas comunes

> ⚠️ **`find` vs `find_by` vs `where(...).first`** — son tres cosas distintas:
> - `Task.find(id)` → lanza `ActiveRecord::RecordNotFound` (404 automático en controladores). Equivale a `FindOrFail`.
> - `Task.find_by(id: id)` → devuelve `nil` si no existe. Equivale a `FirstOrDefault`.
> - `Task.where(id: id).first` → igual que `find_by`, pero genera otra query.
>
> Usa `find` cuando la ausencia es un error; `find_by` cuando es una posibilidad esperada.

> ⚠️ **Las asociaciones no son lazy "a lo EF"** — `user.tasks` ejecuta la query inmediatamente al iterar. Si solo necesitas comprobar existencia, `user.tasks.exists?` es 1000x más barato que `user.tasks.any?` sobre un array cargado.

> ⚠️ **`pluck` vs `select` no es lo mismo que LINQ** — en Rails:
> - `Task.pluck(:title)` → array de strings, **una sola columna en SQL**. Equivale a un `Select(t => t.Title).ToList()` optimizado.
> - `Task.select(:title)` → array de objetos `Task` parcialmente cargados. Llamar a otra columna lanza `MissingAttributeError`.

> ⚠️ **Las validaciones de modelo NO son constraints de base de datos** — `validates :email, uniqueness: true` no crea un índice único. Bajo concurrencia, dos requests pasarán la validación a la vez y meterán dos filas. Añade SIEMPRE `add_index :users, :email, unique: true` en la migración.

> ⚠️ **`update_columns` y `update_column` saltan validaciones, callbacks y `updated_at`** — útiles para scripts de migración de datos, peligrosos en lógica de negocio. Si te encuentras usándolos en un controlador, replantéatelo.

> ⚠️ **Strings en `where` son inyectables si interpolas** — `where("name = '#{params[:name]}'")` es vulnerable. Siempre `where("name = ?", params[:name])` o `where(name: params[:name])`.

---

## 6. Callbacks

Equivalente a los eventos de EF Core (`SavingChanges`, etc.):

💎 **Ruby / Rails**
```ruby
class Task < ApplicationRecord
  before_save  :normalize_title
  after_create :notify_user

  private

  def normalize_title
    self.title = title.strip.capitalize
  end

  def notify_user
    TaskMailer.created(self).deliver_later
  end
end
```

---

## Ejercicios

### ✅ Ejercicio 1 — Migración y modelo

Crea el modelo `Project` con campos `name`, `description`, `deadline` (fecha) y relación con `User`. Añade validaciones de presencia y que `deadline` sea futura.

### ✅ Ejercicio 2 — Scopes y queries

En el modelo `Task`, añade:
- Un scope `overdue` que devuelva tareas con `deadline` pasada y no completadas
- Un scope `by_user(user)` que filtre por usuario
- Un método de clase `summary_for(user)` que devuelva un hash con totales

### ✅ Ejercicio 3 — N+1 y eager loading

Identifica el problema N+1 en este código y corrígelo:

💎 **Ruby / Rails**
```ruby
# tasks_controller.rb
def index
  @tasks = Task.all
end

# index.html.erb
<% @tasks.each do |task| %>
  <p><%= task.user.name %></p>  <%# ← problema N+1 %>
<% end %>
```

---

## Proyecto TaskFlow — avance

Al final de este módulo, TaskFlow tiene:
- Modelo `User` con Devise (adelantamos la relación)
- Modelo `Task` con validaciones completas y scopes
- Relaciones `User has_many Tasks`
- Seeds con datos de prueba (`db/seeds.rb`)

---

## Solución

Ver [`ejercicios/solucion/modulo03.rb`](./ejercicios/solucion/modulo03.rb)
