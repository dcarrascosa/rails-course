# Solución Módulo 00 — Ejercicio de verificación

# config/routes.rb
Rails.application.routes.draw do
  get "hello", to: "hello#index"
  root "hello#index"
end

# app/controllers/hello_controller.rb
class HelloController < ApplicationController
  def index
    render plain: "Hola, soy Rails 8 en #{RUBY_PLATFORM}"
  end
end

# Comprobación:
#   bin/rails server
#   curl http://localhost:3000/hello
#   # → "Hola, soy Rails 8 en x86_64-linux" (o lo que toque)
