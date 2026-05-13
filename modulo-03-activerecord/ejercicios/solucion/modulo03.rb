# Solución Módulo 03

# ---------------------------------------------------------------------------
# Ejercicio 1 — Migración y modelo Project
# ---------------------------------------------------------------------------

# db/migrate/20240501000000_create_projects.rb
class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.date :deadline, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

# app/models/project.rb
class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true, length: { maximum: 200 }
  validates :deadline, presence: true
  validate :deadline_must_be_in_the_future

  private

  def deadline_must_be_in_the_future
    return if deadline.blank?

    errors.add(:deadline, "debe ser futura") if deadline <= Date.current
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 2 — Scopes y queries en Task
# ---------------------------------------------------------------------------

class Task < ApplicationRecord
  belongs_to :user

  scope :overdue, -> { where("deadline < ? AND completed = ?", Date.current, false) }
  scope :by_user, ->(user) { where(user: user) }

  def self.summary_for(user)
    user_tasks = by_user(user)
    {
      total:     user_tasks.count,
      pending:   user_tasks.where(completed: false).count,
      completed: user_tasks.where(completed: true).count,
      overdue:   user_tasks.overdue.count
    }
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 3 — N+1 corregido con eager loading
# ---------------------------------------------------------------------------

# tasks_controller.rb (mal)
# def index
#   @tasks = Task.all
# end
#
# index.html.erb (mal — 1 + N queries)
# <% @tasks.each do |task| %>
#   <p><%= task.user.name %></p>
# <% end %>

# tasks_controller.rb (bien — 2 queries total)
class TasksController < ApplicationController
  def index
    @tasks = Task.includes(:user).all
  end
end

# Diagnóstico en desarrollo:
#  - gem "bullet" en Gemfile :development te avisa de N+1 en el log
#  - rails db:migrate y luego mirar el log de SQL en development.log
