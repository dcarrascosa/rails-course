# Solución Módulo 09

# ---------------------------------------------------------------------------
# Ejercicio 1 — CRUD API bajo /api/v1/tasks
# ---------------------------------------------------------------------------

# config/routes.rb
Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post   "auth/login", to: "auth#login"
      resources :tasks
    end
  end
end

# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def not_found
        render json: error_payload("Recurso no encontrado"), status: :not_found
      end

      def error_payload(message, details: nil)
        { error: { message: message, details: details }.compact }
      end
    end
  end
end

# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < BaseController
      before_action :authenticate_with_token!
      before_action :set_task, only: %i[show update destroy]

      def index
        tasks = current_user.tasks.includes(:user)
        render json: tasks.map { |t| TaskResource.new(t).serializable_hash }
      end

      def show
        render json: TaskResource.new(@task).serializable_hash
      end

      def create
        task = current_user.tasks.build(task_params)
        if task.save
          render json: TaskResource.new(task).serializable_hash,
                 status: :created,
                 location: api_v1_task_url(task)
        else
          render json: error_payload("Tarea inválida", details: task.errors),
                 status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: TaskResource.new(@task).serializable_hash
        else
          render json: error_payload("Tarea inválida", details: @task.errors),
                 status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :description, :completed, :deadline)
      end
    end
  end
end

# app/resources/task_resource.rb  (Alba; equivalente con Jbuilder en views/)
class TaskResource
  include Alba::Resource

  attributes :id, :title, :description, :completed, :deadline, :created_at, :updated_at
end

# ---------------------------------------------------------------------------
# Ejercicio 2 — Autenticación con token
# ---------------------------------------------------------------------------

# bin/rails generate migration AddApiTokenToUsers api_token:string:index
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token
end

# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < BaseController
      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          render json: { token: user.api_token }
        else
          render json: error_payload("Credenciales inválidas"), status: :unauthorized
        end
      end
    end
  end
end

# app/controllers/api/v1/base_controller.rb (extracto añadido)
module Api
  module V1
    class BaseController < ActionController::API
      # ...

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

# ---------------------------------------------------------------------------
# Ejercicio 3 — rswag
# ---------------------------------------------------------------------------

# bundle add rswag-api rswag-ui rswag-specs --group development,test
# bin/rails generate rswag:install
# bin/rails generate rspec:swagger Api::V1::Tasks

# spec/integration/api/v1/tasks_spec.rb
require "swagger_helper"

RSpec.describe "API::V1::Tasks", type: :request do
  let(:user)         { create(:user) }
  let(:Authorization) { "Bearer #{user.api_token}" }

  path "/api/v1/tasks" do
    get "Lista de tareas" do
      tags "Tasks"
      produces "application/json"
      security [bearer_auth: []]

      response "200", "ok" do
        run_test!
      end

      response "401", "sin token" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post "Crear tarea" do
      tags "Tasks"
      consumes "application/json"
      security [bearer_auth: []]
      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title:       { type: :string },
              description: { type: :string },
              completed:   { type: :boolean }
            },
            required: [:title]
          }
        }
      }

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

# Generar el yaml:
#   bundle exec rake rswag:specs:swaggerize
# Servir la UI: ya configurada por el generator en /api-docs
