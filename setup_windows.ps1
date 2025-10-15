# Script de configuración para WhaticketSaaS en Windows (sin verificación PostgreSQL)
# Ejecutar como: powershell -ExecutionPolicy Bypass -File setup_windows_sin_postgres.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CONFIGURACION WHATICKETSAAS WINDOWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Función para verificar si un comando existe
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Verificar Node.js
Write-Host "[1/6] Verificando Node.js..." -ForegroundColor Yellow
if (Test-Command "node") {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js encontrado: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Node.js no esta instalado" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar Redis
Write-Host "[2/6] Verificando Redis..." -ForegroundColor Yellow
try {
    $redisTest = redis-cli ping 2>$null
    if ($redisTest -eq "PONG") {
        Write-Host "[OK] Redis esta corriendo" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Redis no esta corriendo" -ForegroundColor Red
        Write-Host "Inicia Redis antes de continuar" -ForegroundColor Yellow
        Read-Host "Presiona Enter para salir"
        exit 1
    }
} catch {
    Write-Host "[ERROR] Redis no esta instalado o no esta corriendo" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Crear archivos .env si no existen
Write-Host "[3/6] Creando archivos de configuración..." -ForegroundColor Yellow

# Backend .env
$backendEnvPath = "backend\.env"
if (-not (Test-Path $backendEnvPath)) {
    $backendEnvContent = @"
# Configuración para desarrollo local Windows
NODE_ENV=development
BACKEND_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000
PROXY_PORT=80
PORT=8000

# Configuración de Base de Datos PostgreSQL
DB_DIALECT=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=whaticket_user
DB_PASS=mysql123456
DB_NAME=whaticketsaas
DB_DEBUG=true

# Configuración JWT
JWT_SECRET=whaticket_jwt_secret_dev_2024_super_seguro
JWT_REFRESH_SECRET=whaticket_refresh_secret_dev_2024_super_seguro

# Configuración Redis
REDIS_URI=redis://localhost:6379
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000

# Límites del sistema
USER_LIMIT=999
CONNECTIONS_LIMIT=999
CLOSED_SEND_BY_ME=true

# Configuración de Email (opcional para desarrollo)
MAIL_HOST=smtp.gmail.com
MAIL_USER=tu_email@gmail.com
MAIL_PASS=tu_app_password
MAIL_FROM=Whaticket Dev tu_email@gmail.com
MAIL_PORT=587
"@
    Set-Content -Path $backendEnvPath -Value $backendEnvContent
    Write-Host "[OK] Archivo backend\.env creado" -ForegroundColor Green
} else {
    Write-Host "[OK] Archivo backend\.env ya existe" -ForegroundColor Green
}

# Frontend .env
$frontendEnvPath = "frontend\.env"
if (-not (Test-Path $frontendEnvPath)) {
    $frontendEnvContent = @"
# Configuración para desarrollo local Windows
REACT_APP_BACKEND_URL=http://localhost:8000
REACT_APP_FRONTEND_URL=http://localhost:3000
REACT_APP_SOCKET_URL=http://localhost:3040
"@
    Set-Content -Path $frontendEnvPath -Value $frontendEnvContent
    Write-Host "[OK] Archivo frontend\.env creado" -ForegroundColor Green
} else {
    Write-Host "[OK] Archivo frontend\.env ya existe" -ForegroundColor Green
}

# Instalar dependencias del backend
Write-Host "[4/6] Instalando dependencias del backend..." -ForegroundColor Yellow
Set-Location "backend"
try {
    npm install
    Write-Host "[OK] Dependencias del backend instaladas" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Fallo la instalacion de dependencias del backend" -ForegroundColor Red
    Set-Location ".."
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Instalar dependencias del frontend
Write-Host "[5/6] Instalando dependencias del frontend..." -ForegroundColor Yellow
Set-Location "..\frontend"
try {
    npm install
    Write-Host "[OK] Dependencias del frontend instaladas" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Fallo la instalacion de dependencias del frontend" -ForegroundColor Red
    Set-Location ".."
    Read-Host "Presiona Enter para salir"
    exit 1
}

Set-Location ".."

# Compilar backend
Write-Host "[6/6] Compilando backend..." -ForegroundColor Yellow
Set-Location "backend"
try {
    npm run build
    Write-Host "[OK] Backend compilado" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Fallo la compilacion del backend" -ForegroundColor Red
    Set-Location ".."
    Read-Host "Presiona Enter para salir"
    exit 1
}

Set-Location ".."

Write-Host "[COMPLETADO] Configuración completada!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    SIGUIENTE PASO: CONFIGURAR BD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre pgAdmin 4" -ForegroundColor Yellow
Write-Host "2. Conecta a tu servidor PostgreSQL" -ForegroundColor Yellow
Write-Host "3. Ejecuta estos comandos SQL:" -ForegroundColor Yellow
Write-Host "   CREATE DATABASE whaticketsaas;" -ForegroundColor White
Write-Host "   CREATE USER whaticket_user WITH PASSWORD 'mysql123456';" -ForegroundColor White
Write-Host "   GRANT ALL PRIVILEGES ON DATABASE whaticketsaas TO whaticket_user;" -ForegroundColor White
Write-Host ""
Write-Host "4. Ejecuta las migraciones:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   npm run db:migrate" -ForegroundColor White
Write-Host ""
Write-Host "5. Ejecuta los seeds:" -ForegroundColor Yellow
Write-Host "   npm run db:seed" -ForegroundColor White
Write-Host ""
Write-Host "6. Inicia el backend:" -ForegroundColor Yellow
Write-Host "   npm run dev:server" -ForegroundColor White
Write-Host ""
Write-Host "7. Inicia el frontend (nueva terminal):" -ForegroundColor Yellow
Write-Host "   cd frontend" -ForegroundColor White
Write-Host "   npm start" -ForegroundColor White
Write-Host ""
Write-Host "Credenciales por defecto:" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:3000" -ForegroundColor White
Write-Host "   Email: admin@admin.com" -ForegroundColor White
Write-Host "   Contraseña: 123456" -ForegroundColor White
Write-Host ""
Write-Host "Revisa CONFIGURACION_WINDOWS.md para más detalles" -ForegroundColor Cyan
Write-Host ""
Read-Host "Presiona Enter para continuar"
