# Solución Módulo 02 — Ejercicio 2
# Controlador sin scaffold

class ProjectsController < ApplicationController
  def index
    @projects = Project.order(created_at: :desc)
  end

  def show
    @project = Project.find(params[:id])
  end
end
