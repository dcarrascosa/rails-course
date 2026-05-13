# Módulo 00 — Setup del entorno

## Objetivos

- Tener Ruby 3.3+ y Rails 8+ funcionando en tu máquina
- Tener PostgreSQL local listo para los módulos 03 en adelante
- Tener Redis instalado para el módulo 06 (jobs)
- Comprobar que `rails new` funciona end-to-end

> Si vienes de .NET, esto te va a chocar: en Ruby/Rails **no hay "el SDK oficial"**. Versiones, gemas globales, y el propio runtime se gestionan con managers tipo `rbenv` o `asdf`. Sáltate este módulo solo si ya tienes Rails 8 corriendo.

---

## 1. Elegir tu sistema

Las herramientas son distintas según el SO. Salta a tu sección:

- [macOS (Intel y Apple Silicon)](#macos)
- [Linux (Ubuntu/Debian/Fedora)](#linux)
- [Windows con WSL2](#windows-con-wsl2)
- [Windows nativo (no recomendado)](#windows-nativo)

> ⚠️ **Windows nativo**: Rails *funciona* en Windows, pero la gran mayoría de gemas, gemas nativas (las que compilan C) y tutoriales asumen Unix. Vas a perder horas resolviendo problemas que en macOS/Linux/WSL no existen. **Si estás en Windows, usa WSL2** salvo que tengas una razón fuerte para no hacerlo.

---

## 2. macOS

### Homebrew (gestor de paquetes)

🔵 **Equivalente en .NET:** `winget` o Chocolatey en Windows.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### rbenv + ruby-build

`rbenv` es el equivalente conceptual a tener varios SDK de .NET instalados en paralelo: te permite cambiar de versión de Ruby por proyecto sin romper el sistema.

```bash
brew install rbenv ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc   # o ~/.zshrc según tu shell
exec $SHELL

rbenv install 3.3.5
rbenv global 3.3.5
ruby -v   # ruby 3.3.5
```

### PostgreSQL

```bash
brew install postgresql@16
brew services start postgresql@16
createuser -s postgres    # rol superusuario, para los ejemplos del curso
```

### Redis

```bash
brew install redis
brew services start redis
```

### Rails 8

```bash
gem install rails -v "~> 8.0"
rails -v   # Rails 8.0.x
```

---

## 3. Linux

### Ubuntu / Debian

```bash
# Dependencias para compilar Ruby
sudo apt update
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev \
  libyaml-dev libffi-dev libgmp-dev libpq-dev git curl

# rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"'          >> ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
exec $SHELL

rbenv install 3.3.5
rbenv global 3.3.5

# PostgreSQL
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable --now postgresql
sudo -u postgres createuser -s "$USER"

# Redis
sudo apt install -y redis-server
sudo systemctl enable --now redis-server

# Rails
gem install rails -v "~> 8.0"
```

### Fedora

```bash
sudo dnf install -y @development-tools openssl-devel readline-devel zlib-devel \
  libyaml-devel libffi-devel gmp-devel postgresql-server postgresql-devel \
  redis git curl

# rbenv igual que en Ubuntu (los pasos del clone)
# postgresql necesita init:
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql redis
```

---

## 4. Windows con WSL2

**Esta es la ruta recomendada para Windows.** Te da un Ubuntu real dentro de Windows, con integración con VS Code y rendimiento bueno.

### Instalar WSL2

```powershell
# En PowerShell como Administrador
wsl --install -d Ubuntu-22.04
```

Reinicia. Al volver, te pedirá usuario y contraseña de Linux (no del Windows).

### Dentro de Ubuntu (WSL)

Sigue los pasos de la sección [Ubuntu/Debian](#ubuntu--debian) **exactos**. Estás trabajando en Linux a todos los efectos.

### VS Code integrado

Instala la extensión **"WSL"** de Microsoft. Después, desde tu home de WSL:

```bash
code .
```

Abre VS Code en Windows pero ejecutando todo el lado servidor (Ruby, Rails, terminal) dentro de Linux.

### Trampas comunes con WSL

> ⚠️ **No pongas tu repo en `/mnt/c/...`** — el filesystem cruzado Windows↔WSL es 5-10× más lento. Usa `~/proyectos/` (dentro del filesystem nativo de Linux).

> ⚠️ **PostgreSQL escucha solo en localhost del WSL** — desde Windows, accede vía `localhost` (WSL2 lo expone automáticamente), no vía la IP del WSL.

> ⚠️ **`systemctl` no funciona por defecto en WSL** — añade `systemd=true` a `/etc/wsl.conf` o usa `sudo service postgresql start` en su lugar.

---

## 5. Windows nativo

> ⚠️ Última vez que lo aviso: **NO lo hagas si puedes evitarlo**. Sigue.

Usa [RubyInstaller con DevKit](https://rubyinstaller.org/) (ruta `Ruby+DevKit`). Para PostgreSQL, el instalador oficial de [postgresql.org](https://www.postgresql.org/download/windows/). Redis no tiene build oficial Windows — usa [Memurai](https://www.memurai.com/) (drop-in Windows replacement) o, mejor aún, WSL solo para Redis.

A partir de aquí, los comandos `rails`, `bundle`, etc., funcionan igual, pero gemas con extensiones C (`pg`, `nokogiri`, `bcrypt`...) compilarán contra MSYS2 y puede fallar. Si pasa, **migra a WSL2**.

---

## 6. Comprobación final

Independientemente del SO, debes poder ejecutar esto sin errores:

```bash
ruby -v          # ruby 3.3.x
rails -v         # Rails 8.0.x
psql --version   # postgres 16.x (o 15.x)
redis-cli ping   # PONG

# Crear una app de prueba
rails new ping --database=postgresql
cd ping
bin/rails db:create
bin/rails server
# abrir http://localhost:3000 → debes ver el splash de Rails
```

Si los cuatro `--version` responden bien y `bin/rails server` sirve la página de Rails, has terminado el módulo.

---

## 7. Herramientas opcionales recomendadas

- **`overmind`** o **`foreman`**: corren Procfile.dev (web + jobs + assets) con un solo comando. Equivalente a "Run All" de Visual Studio.
- **`tldr`**: man pages legibles. `tldr rails` te resume los comandos.
- **VS Code + extensiones**: "Ruby LSP" (Shopify), "Rails", "endwise", "Rainbow CSV".
- **Cursor / Zed**: si vienes de Rider, son los IDEs modernos más parecidos en filosofía a JetBrains.
- **`rubocop`**: el linter estándar. Equivale a `dotnet format` + analizadores Roslyn.

---

## ✅ Ejercicio

Crea una app `ping` siguiendo la "Comprobación final", añade un controlador `HelloController` con una acción `index` que devuelva `"Hola, soy Rails 8 en <tu SO>"`, monta la ruta y verifica en el navegador. Borra la app después (es un check, no la usaremos).

---

## Solución

Ver [`ejercicios/solucion/hello_controller.rb`](./ejercicios/solucion/hello_controller.rb)
