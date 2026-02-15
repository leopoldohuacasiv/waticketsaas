# 🐧 Instalación - WhaticketSaaS en Ubuntu Linux (VPS)

**Documento**: Guía de instalación en Ubuntu (automática y manual)  
**Fecha**: Febrero 2026  
**Entorno validado**: Ubuntu 22.04 + Node.js 20.x + PostgreSQL + Redis + Nginx + PM2

> **Uso previsto:** Académico, demostración y exploración en programación. No diseñado para negocio o venta. Para soluciones empresariales a escala, ver WATOOLX (arquitectura DB-first).

---

## 🚀 Opción 1: Instalador automático (recomendado) para VPS

Para usuarios sin experiencia técnica. El script solo pide **2 subdominios**; todo lo demás viene predeterminado:

```bash
cd /ruta/a/waticketsaas
chmod +x install.sh
./install.sh
```

**Solo te pedirá:**
- Subdominio API (ej: api.tudominio.com)
- Subdominio Frontend (ej: aplication.tudominio.com)

**Predeterminado:** Base de datos `whaticket`, usuario/contraseña `whaticket`, puertos 4010/3005, SSL automático.

**Requisito previo:** tener instalado Node.js, PostgreSQL, Redis, Nginx y PM2. Si faltan, el script indicará cómo instalarlos.

---

## 📋 Índice

1. [Requisitos previos](#-requisitos-previos)
2. [Camino de instalación manual](#-camino-de-instalación-manual)
3. [Soluciones de raíz (propuestas)](#-soluciones-de-raíz-propuestas)
4. [Archivos de configuración de referencia](#-archivos-de-configuración-de-referencia)
5. [Problemas comunes y soluciones](#-problemas-comunes-y-soluciones)

---

## 🔧 Requisitos previos

| Componente | Versión | Verificación |
|------------|---------|--------------|
| Node.js | 20.x LTS | `node -v` |
| npm | 10+ | `npm -v` |
| PostgreSQL | 14+ | `psql --version` |
| Redis | 6+ | `redis-cli ping` → PONG |
| Nginx | 1.18+ | `nginx -v` |
| PM2 | Global | `npm i -g pm2` |
| Certbot | Para SSL | `certbot --version` |

### Instalación de dependencias del sistema

```bash
sudo apt update
sudo apt install -y nodejs npm postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx
sudo npm install -g pm2
```

---

## 🚀 Camino de instalación manual

### Fase 1: Preparación del proyecto

```bash
# Directorio base (ej: /home/ubuntu/waticketsaas)
cd /home/ubuntu/waticketsaas

# Verificar estructura
ls -la backend/
ls -la frontend/
```

---

### Fase 2: Base de datos PostgreSQL

```bash
sudo -u postgres psql
```

```sql
CREATE USER whaticket WITH PASSWORD 'whaticket';
CREATE DATABASE whaticket OWNER whaticket;
\c whaticket
GRANT ALL ON SCHEMA public TO whaticket;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO whaticket;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO whaticket;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO whaticket;
\q
```

---

### Fase 3: Redis

```bash
sudo systemctl start redis-server
sudo systemctl enable redis-server
redis-cli ping
# Debe responder: PONG
```

---

### Fase 4: Backend

#### 4.1 Permisos (evitar uso de sudo en npm)

```bash
# Si previamente usaste sudo, corregir permisos
sudo chown -R $USER:$USER /home/ubuntu/waticketsaas
```

#### 4.2 Instalación y compilación

```bash
cd /home/ubuntu/waticketsaas/backend
npm install
npm run build
```

**⚠️ No usar `sudo npm run build`** — causa `tsc: not found`.

#### 4.3 Archivo .env

```bash
cp .env.example .env
nano .env
```

Contenido para producción (ajustar dominios y credenciales):

```env
NODE_ENV=production
BACKEND_URL=https://api.tudominio.com
FRONTEND_URL=https://aplication.tudominio.com
PROXY_PORT=8080
PORT=4010

DB_DIALECT=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=whaticket
DB_PASS=whaticket
DB_NAME=whaticket

JWT_SECRET=generar-con-crypto-randomBytes
JWT_REFRESH_SECRET=generar-otro-diferente

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
```

Generar JWT secrets:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

#### 4.4 Migraciones

```bash
npm run db:migrate
```

#### 4.5 Seeds (opcional, puede fallar si ya existen datos)

```bash
npm run db:seed
# Si da "Validation error", la compañía puede existir. Verificar:
# sudo -u postgres psql -d whaticket -c "SELECT id, name FROM \"Companies\";"
# Si falta viewregister:
# sudo -u postgres psql -d whaticket -c "INSERT INTO \"Settings\" (\"key\", value, \"companyId\", \"createdAt\", \"updatedAt\") SELECT 'viewregister', 'disabled', id, NOW(), NOW() FROM \"Companies\" LIMIT 1 ON CONFLICT DO NOTHING;"
```

---

### Fase 5: Frontend

#### 5.1 Scripts package.json (Linux)

Los scripts actuales usan `set` (Windows). Para Linux, usar `export`:

```json
"scripts": {
  "start": "export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider' && react-scripts start",
  "build": "export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider' && react-scripts build",
  "builddev": "export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider' && react-scripts build",
  "test": "export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider' && react-scripts test",
  "eject": "export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider' && react-scripts eject"
}
```

O alternativamente: `NODE_OPTIONS='...' npm run build` (sin modificar package.json).

#### 5.2 Compilación

```bash
cd /home/ubuntu/waticketsaas/frontend
npm install
npm run build
```

**Si falla con `error:0308010C:digital envelope routines::unsupported`:**
```bash
export NODE_OPTIONS='--max-old-space-size=8192 --openssl-legacy-provider'
npm run build
```

#### 5.3 Archivo .env del frontend

```bash
cp .env.exemple .env
nano .env
```

**Contenido (sin espacios alrededor de `=`, URLs de producción):**

```env
REACT_APP_BACKEND_URL=https://api.tudominio.com
REACT_APP_FRONTEND_URL=https://aplication.tudominio.com
REACT_APP_SOCKET_URL=https://api.tudominio.com
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
```

**⚠️ Importante:** Las variables `REACT_APP_*` se compilan en el build. Tras cambiar `.env`, ejecutar `npm run build` nuevamente.

#### 5.4 server.js para producción

Editar `frontend/server.js` y configurar el puerto (ej: 3005 si 3000 está ocupado):

```javascript
const express = require("express");
const path = require("path");
const app = express();
app.use(express.static(path.join(__dirname, "build")));
app.get("/*", function (req, res) {
  res.sendFile(path.join(__dirname, "build", "index.html"));
});
app.listen(3005);
```

**⚠️ Evitar comentarios mal formados:** usar `//` o `/* */` correctamente. Un `/` suelto causa `SyntaxError: Invalid regular expression`.

---

### Fase 6: PM2

#### 6.1 ecosystem.config.js (en backend/)

Crear o editar `backend/ecosystem.config.js`:

```javascript
module.exports = [
  {
    script: 'dist/server.js',
    name: 'waticketsaas-backend',
    cwd: '/home/ubuntu/waticketsaas/backend',
    exec_mode: 'fork',
    cron_restart: '0 5 * * *',
    max_memory_restart: '769M',
    node_args: '--max-old-space-size=769',
    watch: false
  },
  {
    script: 'server.js',
    name: 'waticketsaas-frontend',
    cwd: '/home/ubuntu/waticketsaas/frontend',
    exec_mode: 'fork',
    max_memory_restart: '512M',
    watch: false
  }
];
```

**Ajustar `cwd`** según la ruta real del proyecto.

#### 6.2 Iniciar servicios

```bash
cd /home/ubuntu/waticketsaas/backend
pm2 start ecosystem.config.js
pm2 save
pm2 startup
# Ejecutar el comando sudo que muestre pm2
```

---

### Fase 7: Nginx

#### 7.1 Backend (API)

`/etc/nginx/sites-available/whaticket-backend`:

```nginx
server {
  listen 80;
  server_name api.tudominio.com;

  location / {
    proxy_pass http://127.0.0.1:4010;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_cache_bypass $http_upgrade;
  }
}
```

#### 7.2 Frontend

`/etc/nginx/sites-available/whaticket-frontend`:

```nginx
server {
  listen 80;
  server_name aplication.tudominio.com;

  location / {
    proxy_pass http://127.0.0.1:3005;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_cache_bypass $http_upgrade;
  }
}
```

#### 7.3 Activar y SSL

```bash
sudo ln -sf /etc/nginx/sites-available/whaticket-backend /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/whaticket-frontend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# SSL con Let's Encrypt
sudo certbot --nginx -d api.tudominio.com -d aplication.tudominio.com
sudo nginx -t
sudo systemctl reload nginx
```

**⚠️ api.tudominio.com debe tener SSL** — si el frontend usa HTTPS y llama a `https://api...`, el backend debe responder por HTTPS.

#### 7.4 Evitar configuraciones duplicadas

Si existen sitios antiguos (ej: `spaiid-backend`, `spaiid-frontend`) con los mismos `server_name`, se producen conflictos:

```bash
sudo rm /etc/nginx/sites-enabled/spaiid-backend 2>/dev/null
sudo rm /etc/nginx/sites-enabled/spaiid-frontend 2>/dev/null
```

---

### Fase 8: Verificación

```bash
# Backend
curl -I https://api.tudominio.com

# Frontend
curl -I https://aplication.tudominio.com

# API de registro
curl -s https://api.tudominio.com/settings/registration-status
```

---

## 🛠️ Soluciones de raíz (propuestas)

Para que futuras instalaciones en Linux no requieran estos ajustes manuales:

### 1. Scripts multiplataforma (frontend package.json)

Usar `cross-env` para que funcione en Windows y Linux:

```bash
npm install --save-dev cross-env
```

```json
"scripts": {
  "start": "cross-env NODE_OPTIONS=--max-old-space-size=8192 --openssl-legacy-provider react-scripts start",
  "build": "cross-env NODE_OPTIONS=--max-old-space-size=8192 --openssl-legacy-provider react-scripts build"
}
```

### 2. .env.exemple del frontend

Actualizar con valores reales y todas las variables:

```env
REACT_APP_BACKEND_URL=https://api.tudominio.com
REACT_APP_FRONTEND_URL=https://aplication.tudominio.com
REACT_APP_SOCKET_URL=https://api.tudominio.com
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
```

Sin espacios alrededor de `=`.

### 3. server.js del frontend

- Puerto configurable por variable de entorno: `app.listen(process.env.PORT || 3000);`
- Comentarios correctos: `//` o `/* */`

### 4. ecosystem.config.js

Incluir backend y frontend en un solo archivo, con rutas configurables o relativas al proyecto.

### 5. Documentación de instalación

Añadir al README o docs:
- Requisitos para Linux (Node 20+, OpenSSL, Redis, PostgreSQL)
- Pasos de Nginx y SSL
- Ejemplo de `.env` para producción

### 6. Seeds idempotentes

Ajustar seeds para que no fallen si la compañía o settings ya existen (ej: `ON CONFLICT`, comprobaciones previas).

---

## 📁 Archivos de configuración de referencia

### Backend .env (producción)
Ver Fase 4.3.

### Frontend .env (producción)
Ver Fase 5.3.

### ecosystem.config.js
Ver Fase 6.1.

### Nginx
Ver Fase 7.

---

## ⚠️ Problemas comunes y soluciones

| Problema | Causa | Solución |
|----------|-------|----------|
| `error:0308010C:digital envelope routines::unsupported` | Node 17+ con OpenSSL 3.0 vs Webpack 4 | `export NODE_OPTIONS='--openssl-legacy-provider'` antes de build |
| `set` no funciona en Linux | Sintaxis Windows en scripts | Usar `export` o `cross-env` |
| `tsc: not found` con sudo | PATH distinto con sudo | No usar sudo para npm; `chown` al usuario del proyecto |
| EACCES en node_modules | Carpeta con dueño root | `sudo chown -R $USER:$USER ./` |
| EADDRINUSE puerto ocupado | Puerto en uso | Cambiar PORT en .env o liberar puerto con `lsof -i :4000` |
| ECONNREFUSED Redis | Redis no corriendo | `sudo systemctl start redis-server` |
| server.js SyntaxError | Comentario mal escrito (`/` en lugar de `//`) | Usar `//` o `/* */` |
| Network Error en frontend | Frontend no alcanza API | Verificar REACT_APP_BACKEND_URL, HTTPS en API, CORS |
| conflicting server name nginx | Varios server con mismo dominio | Eliminar configs duplicadas en sites-enabled |
| api.tudominio.com muestra login | API sirviendo frontend | Revisar proxy_pass (4010 backend, 3005 frontend) |
| Validation error en seeds | Empresa/settings ya existen | Omitir seed o insertar manualmente lo que falte |

---

## ✅ Checklist final de instalación

- [ ] PostgreSQL instalado y base de datos creada
- [ ] Redis instalado y en ejecución
- [ ] Backend: .env creado y migraciones ejecutadas
- [ ] Frontend: .env con URLs correctas, build ejecutado
- [ ] PM2: ecosystem.config.js con backend y frontend
- [ ] Nginx: backend (api) → 4010, frontend (aplication) → 3005
- [ ] SSL: certbot para api y aplication
- [ ] Sin configuraciones duplicadas en sites-enabled
- [ ] pm2 save y pm2 startup configurados

---

**Documento generado a partir de instalación exitosa en Ubuntu VPS - Febrero 2026**
