# Solución Módulo 05

# ---------------------------------------------------------------------------
# Ejercicio 1 — Devise instalado y TasksController protegido
# ---------------------------------------------------------------------------

# Pasos (no van en código):
#   bundle add devise
#   bin/rails generate devise:install
#   bin/rails generate devise User
#   bin/rails db:migrate
#
# Después:

# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 2 — Campos personalizados (añadir :name al registro)
# ---------------------------------------------------------------------------

# bin/rails generate migration AddNameToUsers name:string

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 3 — TaskPolicy con Pundit
# ---------------------------------------------------------------------------

# bundle add pundit
# bin/rails generate pundit:install

# app/policies/application_policy.rb (lo genera Pundit)
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
end

# app/policies/task_policy.rb
class TaskPolicy < ApplicationPolicy
  def show?
    record.user == user
  end

  def create?
    user.present?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end

# app/controllers/tasks_controller.rb (extracto con Pundit)
class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @tasks = policy_scope(Task)
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to @task, notice: "Tarea actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end

  def user_not_authorized
    redirect_to tasks_path, alert: "No tienes permiso para esa acción."
  end
end
