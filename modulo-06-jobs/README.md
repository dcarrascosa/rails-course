# Módulo 06 — Background Jobs con Sidekiq vs Hangfire / Azure Functions

## Objetivos

- Entender cómo Rails gestiona trabajo asíncrono con Active Job
- Configurar Sidekiq como backend de jobs
- Enviar emails en background y programar jobs recurrentes

---

## 1. El problema — trabajo en background

En .NET usas Hangfire para jobs en background o Azure Functions para tareas programadas:

🔵 **C# / ASP.NET**
```csharp
// Hangfire — encolar job
BackgroundJob.Enqueue<EmailService>(s => s.SendWelcomeEmail(userId));

// Job recurrente
RecurringJob.AddOrUpdate<ReportService>(
    "daily-report",
    s => s.Generate(),
    Cron.Daily
);
```

En Rails, **Active Job** es la abstracción de jobs (igual que `IHostedService` + cola en .NET). Para el backend tienes dos opciones modernas:

- **Solid Queue** — backend por defecto en Rails 8, sin Redis (usa la propia base de datos como cola). Recomendado si arrancas en Rails 8 y quieres infra mínima.
- **Sidekiq** — el clásico, requiere Redis. Más maduro, dashboard mejor, ecosistema de gemas enorme. Lo usamos en este curso para mantener paridad con Hangfire (que también persiste estado).

```bash
# Opción A — Solid Queue (default Rails 8)
# Ya viene generado en config/queue.yml si creaste la app con `rails new --solid`
config.active_job.queue_adapter = :solid_queue

# Opción B — Sidekiq (la que usaremos)
gem "sidekiq"
```

💎 **Ruby / Rails**
```ruby
# config/application.rb
config.active_job.queue_adapter = :sidekiq
```

---

## 2. Crear y encolar un Job

```bash
rails generate job WelcomeEmail
```

💎 **Ruby / Rails**
```ruby
# app/jobs/welcome_email_job.rb
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

# Encolar desde cualquier sitio
WelcomeEmailJob.perform_later(user.id)           # asíncrono
WelcomeEmailJob.perform_later(user.id)           # en background
WelcomeEmailJob.set(wait: 5.minutes).perform_later(user.id)  # con delay
WelcomeEmailJob.set(wait_until: Date.tomorrow.noon).perform_later(user.id)
```

---

## 3. Action Mailer — emails

Equivalente a los servicios de email de .NET con plantillas Razor:

```bash
rails generate mailer UserMailer
```

💎 **Ruby / Rails**
```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: "noreply@taskflow.app"

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenido a TaskFlow")
  end

  def task_reminder(task)
    @task = task
    @user = task.user
    mail(to: @user.email, subject: "Tienes tareas pendientes")
  end
end
```

💎 **ERB**
```erb
<%# app/views/user_mailer/welcome.html.erb %>
<h1>Hola <%= @user.name %>,</h1>
<p>Tu cuenta en TaskFlow está lista.</p>
<%= link_to "Acceder", root_url %>
```

💎 **Ruby / Rails**
```ruby
# Enviar en background (el patrón recomendado)
UserMailer.welcome(@user).deliver_later  # encola un job automáticamente
```

---

## 4. Jobs recurrentes con Sidekiq Cron

💎 **Ruby / Rails**
```ruby
# gem "sidekiq-cron"
# config/initializers/sidekiq.rb
Sidekiq::Cron::Job.create(
  name:  "Daily Task Reminder",
  cron:  "0 8 * * *",   # cada día a las 8:00
  class: "DailyReminderJob"
)
```

💎 **Ruby / Rails**
```ruby
# app/jobs/daily_reminder_job.rb
class DailyReminderJob < ApplicationJob
  def perform
    User.all.each do |user|
      pending = user.tasks.pending
      UserMailer.task_reminder_digest(user, pending).deliver_now if pending.any?
    end
  end
end
```

---

## 5. Dashboard de Sidekiq

💎 **Ruby / Rails**
```ruby
# config/routes.rb
require "sidekiq/web"
mount Sidekiq::Web => "/sidekiq"  # proteger con Devise en producción
```

Equivalente al dashboard de Hangfire en ASP.NET.

---

## 6. Trampas comunes

> ⚠️ **No pases objetos ActiveRecord al `perform_later`** — pasa el ID. Active Job serializa argumentos a JSON; si pasas `WelcomeEmailJob.perform_later(user)` Active Job lo serializa con GlobalID, pero si el usuario se borra antes de que el job corra, lanza `ActiveJob::DeserializationError`. Patrón seguro: `perform_later(user.id)` + `User.find(user_id)` dentro del job.

> ⚠️ **`deliver_now` bloquea el request** — si lo llamas en un controlador, el usuario espera. Para webhooks, formularios de contacto, etc., **siempre** `deliver_later`. `deliver_now` solo para scripts/console o cuando explícitamente quieres bloqueo.

> ⚠️ **Sidekiq no reintenta indefinidamente** — por defecto reintenta 25 veces con backoff exponencial (~21 días). Si tu job no es idempotente, un reintento puede duplicar efectos (mandar dos emails, cobrar dos veces). Diseña jobs idempotentes o usa `sidekiq_options retry: false` para los que no toleran reintentos.

> ⚠️ **El dashboard de Sidekiq en `/sidekiq` es PÚBLICO si no lo proteges** — en producción cualquiera ve y manipula tu cola. Protégelo:
> ```ruby
> authenticate :user, ->(u) { u.admin? } do
>   mount Sidekiq::Web => "/sidekiq"
> end
> ```

> ⚠️ **Sidekiq Cron no es Sidekiq Pro** — `sidekiq-cron` es gratis; los recurring jobs nativos de Sidekiq son de pago. No mezcles documentación. Alternativa OSS popular: `gem "whenever"` (genera crontab del sistema).

---

## Ejercicios

### ✅ Ejercicio 1 — Email de bienvenida

Configura Action Mailer en desarrollo con la gema `letter_opener`. Envía un email de bienvenida al registrarse con Devise (usa el callback `after_create_commit`).

### ✅ Ejercicio 2 — Notificación de tarea asignada

Cuando se crea una tarea, encola un job que envía un email de notificación al usuario propietario con `perform_later`.

### ✅ Ejercicio 3 — Job recurrente

Configura un job que se ejecute cada mañana y envíe un resumen de tareas pendientes. Usa Sidekiq Cron o la gema `whenever` para la programación.

---

## Proyecto TaskFlow — avance

- Email de bienvenida al registrarse
- Notificación al crear/asignar tarea
- Job recurrente de resumen diario
