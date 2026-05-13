# Módulo 07 — Testing con RSpec vs xUnit / NUnit

## Objetivos

- Escribir tests de modelos, controladores y vistas con RSpec
- Usar FactoryBot como equivalente a los builders de C#
- Implementar tests de integración con Capybara

---

## 1. Setup — xUnit vs RSpec

```bash
# Gemfile
gem "rspec-rails", group: [:development, :test]
gem "factory_bot_rails", group: [:development, :test]
gem "faker", group: [:development, :test]
gem "capybara", group: :test

bundle install
rails generate rspec:install
```

Estructura generada:
```
spec/
  models/
  controllers/
  requests/       # tests de integración HTTP (como WebApplicationFactory)
  system/         # tests end-to-end con Capybara
  factories/      # FactoryBot
  support/
```

---

## 2. Tests de modelo

🔵 **C# / ASP.NET**
```csharp
// xUnit
public class TaskTests
{
    [Fact]
    public void Task_WithEmptyTitle_FailsValidation()
    {
        var task = new Task { Title = "" };
        var results = ValidateModel(task);
        Assert.Contains(results, r => r.MemberNames.Contains("Title"));
    }
}
```

💎 **Ruby / Rails**
```ruby
# RSpec — spec/models/task_spec.rb
RSpec.describe Task, type: :model do
  describe "validaciones" do
    it "es inválida sin título" do
      task = Task.new(title: nil)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it "es válida con atributos correctos" do
      task = build(:task)  # FactoryBot
      expect(task).to be_valid
    end
  end

  describe "scopes" do
    it "devuelve solo tareas pendientes" do
      create(:task, completed: true)
      pending_task = create(:task, completed: false)

      expect(Task.pending).to contain_exactly(pending_task)
    end
  end
end
```

---

## 3. FactoryBot — equivalente a builders / ObjectMother

🔵 **C# / ASP.NET**
```csharp
// C# — builder pattern manual
var task = new TaskBuilder()
    .WithTitle("Mi tarea")
    .WithUser(user)
    .Build();
```

💎 **Ruby / Rails**
```ruby
# spec/factories/tasks.rb
FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    completed { false }
    association :user

    trait :completed do
      completed { true }
    end

    trait :overdue do
      deadline { 1.day.ago }
      completed { false }
    end
  end
end

# Uso en tests
build(:task)                  # instancia sin guardar en DB
create(:task)                 # guarda en DB
create(:task, :completed)     # con trait
create_list(:task, 5, user:)  # lista de 5 tareas
```

---

## 4. Tests de request (integración HTTP)

Equivalente a `WebApplicationFactory` + `HttpClient` en ASP.NET:

💎 **Ruby / Rails**
```ruby
# spec/requests/tasks_spec.rb
RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }  # helper de Devise

  describe "GET /tasks" do
    it "devuelve 200" do
      get tasks_path
      expect(response).to have_http_status(:ok)
    end

    it "lista las tareas del usuario" do
      task = create(:task, user: user)
      get tasks_path
      expect(response.body).to include(task.title)
    end
  end

  describe "POST /tasks" do
    it "crea una tarea válida" do
      expect {
        post tasks_path, params: { task: { title: "Nueva", completed: false } }
      }.to change(Task, :count).by(1)
    end
  end
end
```

---

## 5. Tests de sistema con Capybara (E2E)

Equivalente a Playwright o Selenium en .NET:

💎 **Ruby / Rails**
```ruby
# spec/system/tasks_spec.rb
RSpec.describe "Gestión de tareas", type: :system do
  let(:user) { create(:user) }

  before { sign_in user }

  it "el usuario puede crear una tarea" do
    visit new_task_path
    fill_in "Título", with: "Revisar PRs"
    fill_in "Descripción", with: "Revisar los PRs pendientes"
    click_button "Guardar"

    expect(page).to have_text("Tarea creada")
    expect(page).to have_text("Revisar PRs")
  end

  it "el usuario puede marcar una tarea como completada" do
    task = create(:task, user: user)
    visit tasks_path
    check "completed_#{task.id}"
    expect(page).to have_css(".badge-success")
  end
end
```

---

## 6. Trampas comunes

> ⚠️ **`build` no toca la DB, `create` sí** — usa `build` para tests de validación (más rápido, no ensucia transacción). Usa `create` cuando el test depende del registro estando persistido (`belongs_to`, scopes con SQL).

> ⚠️ **`let` es lazy, `let!` es eager** — `let(:user) { create(:user) }` solo crea el user si lo invocas. Si el test setup depende de que exista sin referenciarlo, necesitas `let!` o el test pasa por error.

> ⚠️ **`expect { ... }.to change { ... }` evalúa el bloque antes y después** — el bloque de `change` se ejecuta dos veces. Si tiene efectos colaterales (no debería, pero pasa), debuggearlo es un infierno.

> ⚠️ **System specs son lentos y flakeados** — usan navegador real (headless Chrome). Cada test arranca y para uno. Limita system specs al "happy path crítico" del usuario; lo demás cúbrelo con request specs (mucho más rápidos, sin navegador).

> ⚠️ **`sign_in` de Devise solo funciona en request/controller specs si incluyes los helpers** — en `spec/rails_helper.rb`:
> ```ruby
> config.include Devise::Test::IntegrationHelpers, type: :request
> config.include Devise::Test::IntegrationHelpers, type: :system
> ```
> En model specs no aplica — no hay sesión HTTP.

> ⚠️ **FactoryBot llama al callback de creación de ActiveRecord** — si tu modelo tiene `after_create :send_email`, el factory lo dispara. En tests, suele querer mockearse para no enviar emails reales. Patrón: `skip_callback` en `rails_helper.rb` o usar `build_stubbed` cuando no necesitas persistir.

---

## Ejercicios

### ✅ Ejercicio 1 — Factories y model specs

Crea factories para `User` y `Task`. Escribe specs para todas las validaciones y scopes del modelo `Task`.

### ✅ Ejercicio 2 — Request specs

Escribe request specs para `TasksController`: GET index, GET show, POST create (válido e inválido), PATCH update y DELETE destroy.

### ✅ Ejercicio 3 — System spec

Escribe un test de sistema que pruebe el flujo completo: registro → login → crear tarea → marcar completada → logout.

---

## Proyecto TaskFlow — avance

- Cobertura de tests > 80% en modelos
- Request specs para todos los endpoints
- Al menos un system spec de flujo crítico

---

## Solución

Ver [`ejercicios/solucion/modulo07.rb`](./ejercicios/solucion/modulo07.rb)
