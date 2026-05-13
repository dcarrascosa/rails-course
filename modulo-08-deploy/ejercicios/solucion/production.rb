# Solución Módulo 08 — Ejercicio 1: config/environments/production.rb
# Solo se muestran las líneas relevantes para el ejercicio (el fichero real
# es más largo y lo genera Rails).

Rails.application.configure do
  # --- Logging --------------------------------------------------------------
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym

  # Si reemplazas el logger por uno "plano", config.log_tags queda sin efecto:
  # el logger por defecto de Rails es TaggedLogging y los tags necesitan ese
  # wrapper. Por eso envolvemos el STDOUT logger explícitamente.
  base_logger     = ActiveSupport::Logger.new(STDOUT)
  config.logger   = ActiveSupport::TaggedLogging.new(base_logger)
  config.log_tags = [:request_id]

  # --- Cache ----------------------------------------------------------------
  # En Rails 8, Solid Cache es el default; usa la propia DB.
  config.cache_store = :solid_cache_store

  # --- Assets ---------------------------------------------------------------
  config.public_file_server.enabled = true
  config.assets.compile             = false
  config.active_storage.service     = :amazon  # o el adapter que toque

  # --- SSL ------------------------------------------------------------------
  # force_ssl + assume_ssl evita bucle infinito si el proxy ya terminó TLS.
  config.force_ssl  = true
  config.assume_ssl = true

  # --- Acción mailer --------------------------------------------------------
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST") }
  config.action_mailer.delivery_method     = :smtp
  config.action_mailer.smtp_settings       = {
    address:        ENV.fetch("SMTP_HOST"),
    port:           ENV.fetch("SMTP_PORT", "587").to_i,
    user_name:      ENV.fetch("SMTP_USER"),
    password:       ENV.fetch("SMTP_PASSWORD"),
    authentication: :plain,
    enable_starttls_auto: true
  }
end

# Generar SECRET_KEY_BASE:
#   bin/rails secret
#
# Y en producción exportarlo (Railway/Render/Fly lo configuran como env var,
# nunca en el repo):
#   export SECRET_KEY_BASE=<output del comando anterior>
