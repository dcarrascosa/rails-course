# Módulo 05 — Autenticación con Devise vs ASP.NET Identity

## Objetivos

- Instalar y configurar Devise en una app Rails existente
- Entender qué genera Devise y cómo personalizarlo
- Implementar autorización básica con Pundit

---

## 1. Instalación — ASP.NET Identity vs Devise

```bash
# ASP.NET — se configura en Program.cs
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
```

```bash
# Rails — Gemfile
gem "devise"
bundle install
rails generate devise:install
rails generate devise User
rails db:migrate
```

Devise genera automáticamente:
- Modelo `User` con campos de autenticación
- Migraciones para `users` tabla
- Rutas de login/logout/registro/password reset
- Vistas (opcionales con `rails generate devise:views`)

---

## 2. Rutas generadas

💎 **Ruby / Rails**
```ruby
# config/routes.rb
devise_for :users
# Genera:
# GET  /users/sign_in       → sessions#new
# POST /users/sign_in       → sessions#create
# DELETE /users/sign_out    → sessions#destroy
# GET  /users/sign_up       → registrations#new
# POST /users/password      → passwords#create  (reset)
```

---

## 3. Proteger controladores

🔵 **C# / ASP.NET**
```csharp
// ASP.NET — atributo [Authorize]
[Authorize]
public class TasksController : Controller { ... }

// Usuario actual
var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
```

💎 **Ruby / Rails**
```ruby
# Rails con Devise
class TasksController < ApplicationController
  before_action :authenticate_user!  # redirige a login si no autenticado

  def index
    @tasks = current_user.tasks  # current_user disponible en controladores y vistas
  end
end
```

---

## 4. Personalizar el modelo User

💎 **Ruby / Rails**
```ruby
# db/migrate/add_fields_to_users.rb
class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :string, default: "member"
    add_column :users, :avatar_url, :string
  end
end

# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy

  enum :role, { member: "member", admin: "admin" }

  def admin?
    role == "admin"
  end
end
```

---

## 5. Autorización con Pundit

Equivalente a los **Authorization Policies** de ASP.NET:

🔵 **C# / ASP.NET**
```csharp
// ASP.NET Policy
public class TaskAuthorizationHandler
    : AuthorizationHandler<SameUserRequirement, Task>
{
    protected override Task HandleRequirementAsync(...)
    {
        if (task.UserId == context.User.GetUserId())
            context.Succeed(requirement);
        return Task.CompletedTask;
    }
}
```

💎 **Ruby / Rails**
```ruby
# gem "pundit"
# app/policies/task_policy.rb
class TaskPolicy < ApplicationPolicy
  def update?
    record.user == user  # record = tarea, user = current_user
  end

  def destroy?
    record.user == user || user.admin?
  end
end

# En el controlador
class TasksController < ApplicationController
  def update
    @task = Task.find(params[:id])
    authorize @task  # lanza Pundit::NotAuthorizedError si falla
    # ...
  end
end
```

---

## 6. Trampas comunes

> ⚠️ **Rails 8 trae autenticación built-in** — desde Rails 8 puedes generar autenticación básica con `bin/rails generate authentication`. Es minimal y sin features extra (sin password reset por email, sin OAuth). Devise sigue siendo el estándar de facto para cualquier cosa medianamente real, pero **no es obligatorio**.

> ⚠️ **`devise_for :users` debe ir antes que `resources :tasks`** en `routes.rb` si hay rutas colisionantes. Y no toques las rutas que genera Devise sin saber qué haces; los formularios y mailers asumen los nombres por defecto.

> ⚠️ **`current_user` puede ser `nil` aunque `before_action :authenticate_user!` esté declarado** — si lo usas en un controlador que también tiene acciones públicas, o en un helper de vista compartida. Comprueba con `user_signed_in?` antes.

> ⚠️ **Devise no aplica strong params al registro automáticamente** — si añades un campo (`name`, `role`) tienes que declararlo en `ApplicationController`:
> ```ruby
> before_action :configure_permitted_parameters, if: :devise_controller?
>
> protected
>
> def configure_permitted_parameters
>   devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
> end
> ```

> ⚠️ **Pundit lanza `Pundit::NotAuthorizedError`, no un 403 directo** — tienes que rescatarlo en `ApplicationController`:
> ```ruby
> rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
>
> def user_not_authorized
>   redirect_to root_path, alert: "No autorizado."
> end
> ```

---

## Ejercicios

### ✅ Ejercicio 1 — Instalar Devise

Instala Devise en TaskFlow, genera el modelo User y protege `TasksController` con `before_action :authenticate_user!`. Verifica que el login/logout funciona.

### ✅ Ejercicio 2 — Campos personalizados

Añade el campo `name` al registro. Asegúrate de que se guarda correctamente (necesitarás permitir el parámetro en `ApplicationController`).

### ✅ Ejercicio 3 — Política con Pundit

Instala Pundit y crea `TaskPolicy` que solo permita editar/eliminar tareas propias. Prueba que un usuario no puede modificar tareas de otro.

---

## Proyecto TaskFlow — avance

- Login, registro y logout funcionando
- Tareas asociadas al usuario logueado
- Autorización: solo el propietario puede editar/eliminar

---

## Solución

Ver [`ejercicios/solucion/modulo05.rb`](./ejercicios/solucion/modulo05.rb)
