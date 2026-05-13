# Solución Módulo 06

# ---------------------------------------------------------------------------
# Ejercicio 1 — Email de bienvenida con letter_opener
# ---------------------------------------------------------------------------

# Gemfile (group :development):
#   gem "letter_opener"
#
# config/environments/development.rb:
#   config.action_mailer.delivery_method = :letter_opener
#   config.action_mailer.perform_deliveries = true
#   config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: "noreply@taskflow.app"

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Bienvenido a TaskFlow")
  end
end

# app/views/user_mailer/welcome.html.erb
# <h1>Hola <%= @user.name %></h1>
# <p>Tu cuenta en TaskFlow ya está activa.</p>

# app/models/user.rb — disparar al registrar
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create_commit :send_welcome_email

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 2 — Job al crear tarea
# ---------------------------------------------------------------------------

# app/jobs/task_assigned_notification_job.rb
class TaskAssignedNotificationJob < ApplicationJob
  queue_as :default
  retry_on ActiveRecord::Deadlocked, attempts: 3

  # Recibe el ID, no el objeto — ver "trampas comunes" del módulo.
  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task

    UserMailer.task_assigned(task).deliver_now
  end
end

# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user

  after_create_commit :notify_owner

  private

  def notify_owner
    TaskAssignedNotificationJob.perform_later(id)
  end
end

# ---------------------------------------------------------------------------
# Ejercicio 3 — Job recurrente (resumen diario)
# ---------------------------------------------------------------------------

# app/jobs/daily_reminder_job.rb
class DailyReminderJob < ApplicationJob
  queue_as :reminders

  def perform
    User.includes(:tasks).find_each do |user|
      pending = user.tasks.where(completed: false)
      next if pending.empty?

      UserMailer.daily_digest(user, pending).deliver_now
    end
  end
end

# Opción A — sidekiq-cron:
# config/initializers/sidekiq.rb
#   Sidekiq::Cron::Job.create(
#     name:  "Daily reminder",
#     cron:  "0 8 * * *",
#     class: "DailyReminderJob"
#   )

# Opción B — whenever (genera crontab del sistema):
# config/schedule.rb
#   every 1.day, at: "8:00 am" do
#     runner "DailyReminderJob.perform_now"
#   end
