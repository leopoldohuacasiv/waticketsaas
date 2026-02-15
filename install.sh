#!/bin/bash

# =============================================================================
# WHATICKETSAAS - INSTALADOR PARA UBUNTU LINUX (VPS)
# =============================================================================
# Script de instalación manual automatizado para WhaticketSaaS
# Uso exclusivo: Ubuntu / Debian
# Basado en: 0003-Instalador para ubuntu linux.md
# Versión: 1.0.0 | Febrero 2026
# =============================================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"
LOG_FILE="$SCRIPT_DIR/install_ubuntu.log"

# Variables predeterminadas (hardcodeadas para evitar errores del usuario)
BACKEND_PORT="4010"
FRONTEND_PORT="3005"
DB_NAME="whaticket"
DB_USER="whaticket"
DB_PASS="whaticket"

# Funciones de log
log_info()    { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_ok()      { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_step()    { echo -e "\n${CYAN}===> $1${NC}" | tee -a "$LOG_FILE"; }

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         WHATICKETSAAS - INSTALADOR UBUNTU LINUX              ║"
    echo "║                                                              ║"
    echo "║  PostgreSQL | Redis | Nginx | PM2 | Certbot                 ║"
    echo "║  Documentación: 0003-Instalador para ubuntu linux.md        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# =============================================================================
# NODE.JS 20 (requerido por Baileys/crypto, evita "crypto is not defined")
# =============================================================================

ensure_node20() {
    log_step "Verificando Node.js 20 (requerido)"
    
    local need_install=0
    if ! command -v node &>/dev/null; then
        need_install=1
    else
        local node_ver
        node_ver=$(node -v 2>/dev/null | cut -d. -f1 | tr -d 'v')
        if [ -z "$node_ver" ] || [ "$node_ver" -lt 20 ]; then
            log_warn "Node.js actual: $(node -v). Baileys/WhatsApp requiere Node 20+ (crypto global)."
            need_install=1
        fi
    fi
    
    if [ "$need_install" -eq 1 ]; then
        log_info "Instalando Node.js 20 desde NodeSource..."
        if curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null; then
            if sudo apt install -y nodejs 2>/dev/null; then
                log_ok "Node.js instalado: $(node -v)"
                log_info "Reinstalando PM2 con Node 20..."
                sudo npm install -g pm2 2>/dev/null || true
            else
                log_error "Fallo instalación Node.js. Ejecutar manualmente: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
                exit 1
            fi
        else
            log_error "No se pudo configurar NodeSource. Instalar Node 20 manualmente y volver a ejecutar."
            echo -e "${YELLOW}  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -${NC}"
            echo -e "${YELLOW}  sudo apt install -y nodejs${NC}"
            exit 1
        fi
    else
        log_ok "Node.js: $(node -v)"
    fi
}

# =============================================================================
# VERIFICACIÓN DE REQUISITOS
# =============================================================================

check_prerequisites() {
    log_step "Verificando requisitos del sistema"
    
    local missing=()
    
    if ! command -v node &>/dev/null; then
        missing+=("Node.js")
    else
        log_ok "Node.js: $(node -v)"
    fi
    
    if ! command -v npm &>/dev/null; then
        missing+=("npm")
    else
        log_ok "npm: $(npm -v)"
    fi
    
    if ! command -v psql &>/dev/null && ! systemctl is-active --quiet postgresql 2>/dev/null; then
        missing+=("PostgreSQL (sudo apt install postgresql postgresql-contrib)")
    else
        log_ok "PostgreSQL instalado"
    fi
    
    if ! command -v redis-cli &>/dev/null; then
        missing+=("Redis (sudo apt install redis-server)")
    else
        if redis-cli ping 2>/dev/null | grep -q PONG; then
            log_ok "Redis corriendo"
        else
            log_warn "Redis instalado pero no responde. Ejecutar: sudo systemctl start redis-server"
        fi
    fi
    
    if ! command -v nginx &>/dev/null; then
        missing+=("Nginx (sudo apt install nginx)")
    else
        log_ok "Nginx instalado"
    fi
    
    if ! command -v pm2 &>/dev/null; then
        log_warn "PM2 no encontrado. Se instalará: sudo npm i -g pm2"
        read -p "¿Instalar PM2 ahora? (s/n): " inst_pm2
        if [[ "$inst_pm2" =~ ^[Ss]$ ]]; then
            sudo npm install -g pm2 || log_warn "Fallo instalación PM2. Instalar manualmente después."
        fi
    else
        log_ok "PM2 instalado"
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Faltan dependencias: ${missing[*]}"
        echo -e "\n${YELLOW}Instalar con:${NC}"
        echo "  sudo apt update && sudo apt install -y nodejs npm postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx"
        echo "  sudo npm install -g pm2"
        exit 1
    fi
    
    log_ok "Todos los requisitos verificados"
}

# =============================================================================
# CAPTURA DE DATOS - Solo 2 subdominios (resto predeterminado)
# =============================================================================

capture_config() {
    log_step "Solo necesitas ingresar tus 2 subdominios"
    
    echo -e "${YELLOW}Ejemplo: si tu dominio es mimarca.com, usa api.mimarca.com y aplication.mimarca.com${NC}"
    echo ""
    
    read -p "Subdominio API (ej: api.tudominio.com): " API_DOMAIN
    API_DOMAIN="${API_DOMAIN:-api.tudominio.com}"
    
    read -p "Subdominio Frontend (ej: aplication.tudominio.com): " FRONTEND_DOMAIN
    FRONTEND_DOMAIN="${FRONTEND_DOMAIN:-aplication.tudominio.com}"
    
    # JWT secrets (predeterminados para instalación sin errores)
    JWT_SECRET="kZaOTd+YZpjRUyyuQUpigJaEMk4vcW4YOymKPZX0Ts8="
    JWT_REFRESH="dBSXqFg9TaNUEDXVp6fhMTRLBysP+j2DSqf7+raxD3A="
    
    log_ok "Subdominios configurados: $API_DOMAIN | $FRONTEND_DOMAIN"
}

# =============================================================================
# CORREGIR PERMISOS
# =============================================================================

fix_permissions() {
    log_step "Corrigiendo permisos del proyecto"
    sudo chown -R "$USER:$USER" "$PROJECT_ROOT" 2>/dev/null || true
    log_ok "Permisos corregidos"
}

# =============================================================================
# BASE DE DATOS
# =============================================================================

setup_database() {
    log_step "Configurando base de datos PostgreSQL"
    
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" 2>/dev/null | grep -q 1; then
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
        log_ok "Usuario $DB_USER creado"
    else
        log_info "Usuario $DB_USER ya existe"
    fi
    
    if ! sudo -u postgres psql -lqt 2>/dev/null | cut -d'|' -f1 | tr -d ' ' | grep -qx "$DB_NAME"; then
        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
        log_ok "Base de datos $DB_NAME creada"
    else
        log_info "Base de datos $DB_NAME ya existe"
    fi
    
    sudo -u postgres psql -d "$DB_NAME" -c "GRANT ALL ON SCHEMA public TO $DB_USER;" 2>/dev/null || true
    sudo -u postgres psql -d "$DB_NAME" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;" 2>/dev/null || true
    
    log_ok "Base de datos configurada"
}

# =============================================================================
# ARCHIVOS .ENV
# =============================================================================

create_backend_env() {
    log_step "Creando backend/.env"
    
    cat > "$BACKEND_DIR/.env" << EOF
NODE_ENV=production
BACKEND_URL=https://$API_DOMAIN
FRONTEND_URL=https://$FRONTEND_DOMAIN
PROXY_PORT=8080
PORT=$BACKEND_PORT

DB_DIALECT=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME

JWT_SECRET=$JWT_SECRET
JWT_REFRESH_SECRET=$JWT_REFRESH

REDIS_URI=redis://127.0.0.1:6379
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000

USER_LIMIT=10000
CONNECTIONS_LIMIT=100000
CLOSED_SEND_BY_ME=true

GERENCIANET_SANDBOX=true
GERENCIANET_CLIENT_ID=Client_Id_Gerencianet
GERENCIANET_CLIENT_SECRET=Client_Secret_Gerencianet
GERENCIANET_PIX_CERT=certificado-Gerencianet
GERENCIANET_PIX_KEY=chave pix gerencianet
EOF
    
    log_ok "backend/.env creado"
}

create_frontend_env() {
    log_step "Creando frontend/.env"
    
    cat > "$FRONTEND_DIR/.env" << EOF
REACT_APP_BACKEND_URL=https://$API_DOMAIN
REACT_APP_FRONTEND_URL=https://$FRONTEND_DOMAIN
REACT_APP_SOCKET_URL=https://$API_DOMAIN
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
PORT=$BACKEND_PORT
EOF
    
    log_ok "frontend/.env creado"
}

# =============================================================================
# BACKEND
# =============================================================================

install_backend() {
    log_step "Instalando y compilando backend"
    
    cd "$BACKEND_DIR"
    
    log_info "npm install (backend)..."
    npm install --legacy-peer-deps
    
    log_info "npm run build..."
    npm run build
    
    log_info "Migraciones..."
    npm run db:migrate
    
    log_info "Seeds (puede dar error si ya existen)..."
    npm run db:seed 2>/dev/null || log_warn "Seeds omitidos (datos pueden existir)"
    
    cd "$PROJECT_ROOT"
    log_ok "Backend listo"
}

# =============================================================================
# FRONTEND
# =============================================================================

install_frontend() {
    log_step "Instalando y compilando frontend"
    
    cd "$FRONTEND_DIR"
    
    log_info "npm install (frontend)..."
    npm install --legacy-peer-deps
    
    # Asegurar @emotion/react (requerido por @mui/material)
    log_info "Verificando @emotion/react..."
    npm install @emotion/react@^11.11.1 --legacy-peer-deps
    
    log_info "Build con NODE_OPTIONS (OpenSSL legacy)..."
    export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider'
    export GENERATE_SOURCEMAP=false
    if ! npm run build; then
        log_error "El build del frontend falló. Revisar errores arriba."
        exit 1
    fi
    
    if [ ! -f "build/index.html" ]; then
        log_error "No se generó build/index.html. El frontend no compiló correctamente."
        exit 1
    fi
    log_ok "Build verificado: build/index.html existe"
    
    # Corregir server.js si tiene comentario mal formado (/simple -> // simple)
    if [ -f server.js ] && head -1 server.js 2>/dev/null | grep -q '^/simple'; then
        sed -i '1s|^/simple|// simple|' server.js
        log_ok "server.js corregido (comentario)"
    fi
    
    cd "$PROJECT_ROOT"
    log_ok "Frontend listo"
}

# =============================================================================
# PM2 Y ECOSYSTEM
# =============================================================================

setup_pm2() {
    log_step "Configurando PM2"
    
    cat > "$BACKEND_DIR/ecosystem.config.js" << EOF
module.exports = [
  {
    script: 'dist/server.js',
    name: 'waticketsaas-backend',
    cwd: '$BACKEND_DIR',
    exec_mode: 'fork',
    cron_restart: '0 5 * * *',
    max_memory_restart: '769M',
    node_args: '--max-old-space-size=769',
    watch: false
  },
  {
    script: 'server.js',
    name: 'waticketsaas-frontend',
    cwd: '$FRONTEND_DIR',
    exec_mode: 'fork',
    max_memory_restart: '512M',
    watch: false
  }
];
EOF
    
    cd "$BACKEND_DIR"
    pm2 delete waticketsaas-backend waticketsaas-frontend 2>/dev/null || true
    pm2 start ecosystem.config.js
    pm2 save
    
    log_info "Configurando arranque automático..."
    pm2 startup 2>/dev/null || log_warn "Ejecutar manualmente el comando que muestre: pm2 startup"
    
    cd "$PROJECT_ROOT"
    log_ok "PM2 configurado"
}

# =============================================================================
# NGINX
# =============================================================================

setup_nginx() {
    log_step "Configurando Nginx"
    
    local nginx_backend="/etc/nginx/sites-available/whaticket-backend"
    local nginx_frontend="/etc/nginx/sites-available/whaticket-frontend"
    
    sudo tee "$nginx_backend" > /dev/null << EOF
server {
  listen 80;
  server_name $API_DOMAIN;
  location / {
    proxy_pass http://127.0.0.1:$BACKEND_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
EOF
    
    sudo tee "$nginx_frontend" > /dev/null << EOF
server {
  listen 80;
  server_name $FRONTEND_DOMAIN;
  location / {
    proxy_pass http://127.0.0.1:$FRONTEND_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
EOF
    
    sudo ln -sf "$nginx_backend" /etc/nginx/sites-enabled/ 2>/dev/null
    sudo ln -sf "$nginx_frontend" /etc/nginx/sites-enabled/ 2>/dev/null
    
    # Remover configs duplicadas que puedan causar conflictos
    sudo rm -f /etc/nginx/sites-enabled/spaiid-backend 2>/dev/null
    sudo rm -f /etc/nginx/sites-enabled/spaiid-frontend 2>/dev/null
    
    sudo nginx -t && sudo systemctl reload nginx
    log_ok "Nginx configurado"
}

setup_ssl() {
    log_step "Configurando SSL (Let's Encrypt)"
    
    log_info "Certbot configurará HTTPS automáticamente. Dominios: $API_DOMAIN, $FRONTEND_DOMAIN"
    if sudo certbot --nginx -d "$API_DOMAIN" -d "$FRONTEND_DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email 2>/dev/null; then
        log_ok "SSL configurado correctamente"
    else
        log_warn "SSL no se pudo configurar (¿DNS apunta a este servidor?). Ejecutar después: sudo certbot --nginx -d $API_DOMAIN -d $FRONTEND_DOMAIN"
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    print_banner
    echo "Inicio: $(date)" > "$LOG_FILE"
    
    if [ ! -d "$BACKEND_DIR" ] || [ ! -d "$FRONTEND_DIR" ]; then
        log_error "Ejecutar desde la raíz del proyecto (donde están backend/ y frontend/)"
        exit 1
    fi
    
    # Iniciar Redis si no está corriendo
    if ! redis-cli ping 2>/dev/null | grep -q PONG; then
        log_info "Iniciando Redis..."
        sudo systemctl start redis-server 2>/dev/null || true
    fi
    
    ensure_node20
    check_prerequisites
    capture_config
    fix_permissions
    setup_database
    create_backend_env
    create_frontend_env
    install_backend
    install_frontend
    setup_pm2
    setup_nginx
    setup_ssl
    
    # Resumen final
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           INSTALACIÓN COMPLETADA EXITOSAMENTE               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}URL Frontend:${NC}  https://$FRONTEND_DOMAIN"
    echo -e "${CYAN}URL API:${NC}       https://$API_DOMAIN"
    echo ""
    echo -e "${CYAN}Credenciales por defecto:${NC}"
    echo -e "  Email:    admin@admin.com"
    echo -e "  Password: 123456"
    echo ""
    echo -e "${YELLOW}Comandos útiles:${NC}"
    echo -e "  pm2 list          # Ver procesos"
    echo -e "  pm2 logs          # Ver logs"
    echo -e "  pm2 restart all   # Reiniciar todo"
    echo ""
    echo -e "Log: $LOG_FILE"
    echo ""
}

main "$@"
