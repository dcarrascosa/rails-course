# Módulo 04 — Vistas, Layouts y Hotwire

## Objetivos

- Dominar ERB, partials y helpers de Rails
- Entender Turbo (Hotwire) como alternativa a Blazor para UI reactiva
- Implementar actualizaciones de página sin JavaScript manual

---

## 1. Layouts — equivalente a `_Layout.cshtml`

```html
<!-- ASP.NET: Views/Shared/_Layout.cshtml -->
<!DOCTYPE html>
<html>
<head><title>@ViewData["Title"]</title></head>
<body>
  <nav>...</nav>
  @RenderBody()
</body>
</html>
```

```erb
<%# Rails: app/views/layouts/application.html.erb %>
<!DOCTYPE html>
<html>
<head><title><%= content_for?(:title) ? yield(:title) : "TaskFlow" %></title></head>
<body>
  <nav>...</nav>
  <%= yield %>  <%# equivalente a @RenderBody() %>
</body>
</html>
```

---

## 2. Partials — equivalente a Partial Views

```csharp
// ASP.NET Razor
@await Html.PartialAsync("_TaskCard", task)
```

```erb
<%# Rails — el fichero se llama _task_card.html.erb (con guión bajo) %>
<%= render "task_card", task: task %>

<%# O pasando colección directamente — muy útil %>
<%= render @tasks %>  <%# busca _task.html.erb automáticamente %>
```

---

## 3. Helpers — equivalente a Tag Helpers

```erb
<%# Links %>
<%= link_to "Ver tarea", task_path(@task) %>
<%= link_to "Eliminar", task_path(@task), data: { turbo_method: :delete, turbo_confirm: "¿Seguro?" } %>

<%# Formularios %>
<%= form_with model: @task do |f| %>
  <%= f.label :title, "Título" %>
  <%= f.text_field :title, class: "input" %>
  <%= f.submit "Guardar" %>
<% end %>

<%# Condicionales en vistas %>
<%= "Completada" if task.completed? %>
```

---

## 4. Hotwire / Turbo — UI reactiva sin JavaScript

En .NET usarías Blazor Server para actualizar partes de la página sin recargar. Rails lo resuelve con **Turbo** (parte de Hotwire).

### Turbo Drive — navegación SPA automática

Turbo Drive intercepta clicks en links y submissions de formularios y actualiza solo el `<body>` sin recargar la página completa. Viene activado por defecto en Rails 8.

### Turbo Frames — equivalente a componentes Blazor

```erb
<%# Enmarca una sección actualizable %>
<%= turbo_frame_tag "task_#{@task.id}" do %>
  <p><%= @task.title %></p>
  <%= link_to "Editar", edit_task_path(@task) %>  <%# la respuesta actualiza solo este frame %>
<% end %>
```

```erb
<%# En edit.html.erb — mismo frame_tag para que Rails sepa dónde inyectar %>
<%= turbo_frame_tag "task_#{@task.id}" do %>
  <%= render "form", task: @task %>
<% end %>
```

### Turbo Streams — actualizaciones granulares desde el servidor

```ruby
# tasks_controller.rb
def create
  @task = Task.new(task_params)
  if @task.save
    respond_to do |format|
      format.turbo_stream  # busca create.turbo_stream.erb
      format.html { redirect_to tasks_path }
    end
  end
end
```

```erb
<%# app/views/tasks/create.turbo_stream.erb %>
<%= turbo_stream.prepend "tasks", @task %>  <%# añade al principio de #tasks %>
<%= turbo_stream.replace "task_form", partial: "form", locals: { task: Task.new } %>
```

---

## 5. ViewComponents vs Helpers complejos

Para lógica compleja en vistas, Rails tiene **ViewComponents** (gema) como alternativa a los Razor Components:

```ruby
# app/components/task_status_component.rb
class TaskStatusComponent < ViewComponent::Base
  def initialize(task:)
    @task = task
  end
end
```

```erb
<%# app/components/task_status_component.html.erb %>
<span class="badge <%= @task.completed? ? 'badge-success' : 'badge-warning' %>">
  <%= @task.completed? ? "✓ Completada" : "Pendiente" %>
</span>
```

```erb
<%# Uso en cualquier vista %>
<%= render(TaskStatusComponent.new(task: task)) %>
```

---

## Ejercicios

### Ejercicio 1 — Layout con navbar

Crea un layout con navbar responsive que muestre el usuario logueado y tenga links a las secciones principales.

### Ejercicio 2 — Partial con colección

Extrae `_task.html.erb` como partial y úsalo con `render @tasks`. Asegúrate de que muestra el estado, título y un link a la tarea.

### Ejercicio 3 — Turbo Frame en edición inline

Implementa edición inline de una tarea usando Turbo Frames: al pulsar "Editar", el card se convierte en formulario sin cambiar de página.

---

## Proyecto TaskFlow — avance

- Layout con navbar y flash messages
- Partial `_task.html.erb` reutilizable
- Edición inline con Turbo Frames
- Formulario con validaciones client-side
