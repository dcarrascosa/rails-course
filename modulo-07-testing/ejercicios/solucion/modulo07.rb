# Solución Módulo 07
# Nota: en un proyecto real estos ficheros van en spec/. Aquí van juntos
# como referencia. Los nombres de fichero originales aparecen como comentario.

# ---------------------------------------------------------------------------
# Ejercicio 1 — Factories + model specs
# ---------------------------------------------------------------------------

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@taskflow.test" }
    name             { Faker::Name.first_name }
    password         { "password123" }
  end
end

# spec/factories/tasks.rb
FactoryBot.define do
  factory :task do
    title       { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    completed   { false }
    deadline    { 1.week.from_now }
    association :user

    trait :completed do
      completed { true }
    end

    trait :overdue do
      deadline  { 1.day.ago }
      completed { false }
    end
  end
end

# spec/models/task_spec.rb
RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe "validaciones" do
    it { is_expected.to be_valid }

    it "es inválida sin título" do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to be_present
    end
  end

  describe ".overdue" do
    it "incluye tareas con deadline pasada y no completadas" do
      overdue_task   = create(:task, :overdue)
      _on_time_task  = create(:task, deadline: 2.days.from_now)
      _completed_old = create(:task, :completed, deadline: 1.day.ago)

      expect(Task.overdue).to contain_exactly(overdue_task)
    end
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 2 — Request specs
# ---------------------------------------------------------------------------

# spec/requests/tasks_spec.rb
RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /tasks" do
    it "devuelve 200" do
      get tasks_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /tasks/:id" do
    it "muestra la tarea del usuario" do
      task = create(:task, user: user)
      get task_path(task)
      expect(response.body).to include(task.title)
    end
  end

  describe "POST /tasks" do
    context "con params válidos" do
      it "crea la tarea y redirige" do
        expect {
          post tasks_path, params: { task: { title: "Nueva", description: "d" } }
        }.to change(Task, :count).by(1)
        expect(response).to redirect_to(Task.last)
      end
    end

    context "con params inválidos" do
      it "devuelve 422 y re-renderiza el form" do
        post tasks_path, params: { task: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /tasks/:id" do
    it "actualiza la tarea" do
      task = create(:task, user: user, title: "viejo")
      patch task_path(task), params: { task: { title: "nuevo" } }
      expect(task.reload.title).to eq("nuevo")
    end
  end

  describe "DELETE /tasks/:id" do
    it "elimina la tarea" do
      task = create(:task, user: user)
      expect {
        delete task_path(task)
      }.to change(Task, :count).by(-1)
    end
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 3 — System spec del flujo completo
# ---------------------------------------------------------------------------

# spec/system/task_flow_spec.rb
RSpec.describe "Flujo completo de TaskFlow", type: :system do
  it "registro → login → crear → completar → logout" do
    visit new_user_registration_path
    fill_in "Email",                 with: "demo@taskflow.test"
    fill_in "Nombre",                with: "Demo"
    fill_in "Contraseña",            with: "password123"
    fill_in "Confirmar contraseña",  with: "password123"
    click_button "Registrarse"

    expect(page).to have_text("Bienvenido")

    click_link "Nueva tarea"
    fill_in "Título", with: "Repasar el módulo 7"
    click_button "Guardar"

    expect(page).to have_text("Repasar el módulo 7")

    check "Completada"
    expect(page).to have_css(".task--done")

    click_button "Cerrar sesión"
    expect(page).to have_text("Entrar")
  end
end
