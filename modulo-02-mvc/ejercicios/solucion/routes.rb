# Solución Módulo 02 — Rutas
#
# Ejercicio 1 — Scaffold genera resources :tasks automáticamente.
# Equivalencia con ASP.NET MVC:
#   GET    /tasks          → tasks#index      ≡  [HttpGet]
#   GET    /tasks/new      → tasks#new        ≡  [HttpGet("create")]
#   POST   /tasks          → tasks#create     ≡  [HttpPost]
#   GET    /tasks/:id      → tasks#show       ≡  [HttpGet("{id}")]
#   GET    /tasks/:id/edit → tasks#edit       ≡  [HttpGet("{id}/edit")]
#   PATCH  /tasks/:id      → tasks#update     ≡  [HttpPut("{id}")]
#   DELETE /tasks/:id      → tasks#destroy    ≡  [HttpDelete("{id}")]

Rails.application.routes.draw do
  # Ejercicio 1
  resources :tasks

  # Ejercicio 2 — Controlador sin scaffold
  resources :projects, only: %i[index show]

  # Ejercicio 3 — Rutas anidadas
  # Genera helpers como project_tasks_path(@project), project_task_path(@project, @task)
  # y URLs como /projects/:project_id/tasks
  resources :projects do
    resources :tasks
  end

  root "tasks#index"
end
