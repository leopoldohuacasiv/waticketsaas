<p align="center">
  <img src="https://watoolx.todosistemas.online/wp-content/uploads/2025/10/wticket-31.webp" alt="WhaticketSaaS Logo" width="70%"/>
</p>

# WhaticketSaaS - Sistema de Tickets con WhatsApp

Sistema de gestión de tickets y atención al cliente integrado con WhatsApp Business API.

---

## ⚠️ **AVISO IMPORTANTE - DIFERENCIACIÓN DE PROYECTOS**

| | **WhaticketSaaS** (este proyecto) | **WATOOLX** |
|---|-----------------------------------|-------------|
| **Alcance** | Versión **BÁSICA**, instalador sencillo | Arquitectura **empresarial DB-first** para negocios a escala |
| **Propósito** | Uso **académico**, enseñanza y exploración en el mundo de la programación | Producción comercial, operaciones empresariales |
| **Uso recomendado** | Aprendizaje, demostraciones, práctica, entornos de estudio | Negocios reales, clientes pagadores, venta de servicios |
| **NO utilizar para** | Comercializar, vender como producto, operaciones empresariales | — |

**En resumen:** Este instalador de WhaticketSaaS está pensado para quien quiere **aprender**, **experimentar** o **comprender** cómo funciona un sistema de tickets con WhatsApp. **No está diseñado para hacer negocios ni venderlo**. Para proyectos empresariales y escalables, consultar **[WATOOLX](https://github.com/leopoldohuacasiv/watoolx)**.

---

## 🚀 **INSTALACIÓN EN WINDOWS (DESARROLLO LOCAL)**

### 📋 **Requisitos Previos**
- **Node.js 20.x** o superior
- **PostgreSQL** (con pgAdmin)
- **Redis**
- **Laragon** (opcional, para entorno local)

### ⚡ **Instalación Automática**

#### **Opción 1: Script PowerShell (Recomendado)**
```powershell
powershell -ExecutionPolicy Bypass -File setup_windows.ps1
```

#### **Opción 2: Instalación Manual**
1. **Clonar repositorio:**
   ```bash
   git clone https://github.com/leopoldohuacasiv/waticketsaas.git
   cd waticketsaas
   ```

2. **Configurar base de datos PostgreSQL:**
   ```sql
   CREATE DATABASE whaticketsaas;
   CREATE USER whaticket_user WITH PASSWORD 'mysql123456';
   GRANT ALL PRIVILEGES ON DATABASE whaticketsaas TO whaticket_user;
   ```

3. **Instalar dependencias:**
   ```bash
   # Backend
   cd backend
   npm install
   npm run build
   npm run db:migrate
   npm run db:seed
   
   # Frontend
   cd ../frontend
   npm install
   ```

4. **Iniciar servicios:**
   ```bash
   # Terminal 1 - Backend
   cd backend
   npm run dev:server
   
   # Terminal 2 - Frontend
   cd frontend
   npm start
   ```

### 🔑 **Acceso al Sistema**
- **URL**: http://localhost:3000
- **Email**: admin@admin.com
- **Contraseña**: 123456

### 📚 **Documentación Detallada**
- **Guía completa**: `0001-Readmen-Install-Windows.md`
- **Actualización Baileys**: `0002-Actualización Api Baileys6.7.19.md`

---

## 🐧 **INSTALACIÓN EN UBUNTU (VPS) - PASO A PASO (RECOMENDADO)**

Instalador **básico** con script integrado (`install.sh`). Uso académico y demostración.

---

### **Paso 1: Obtener un VPS con Ubuntu**

- Contrata un VPS con **Ubuntu 22.04** (o superior).
- Anota la **IP** del servidor y las credenciales de acceso SSH.
- Conecta por SSH (ej: `ssh ubuntu@tu.ip.vps`).

---

### **Paso 2: Instalar dependencias del sistema**

En el VPS, ejecuta:

```bash
sudo apt update
sudo apt install -y nodejs npm postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx git
sudo npm install -g pm2
```

Verifica:
```bash
node -v    # Debe mostrar v20.x o superior
npm -v
redis-cli ping   # Debe responder PONG
nginx -v
pm2 -v
```

---

### **Paso 3: Clonar el proyecto en el VPS**

```bash
cd ~
git clone https://github.com/leopoldohuacasiv/waticketsaas.git
cd waticketsaas
```

Deberías ver la carpeta con `backend/`, `frontend/`, `install.sh`, etc.

---

### **Paso 4: Configurar dominios (antes de instalar)**

En tu proveedor de dominios (GoDaddy, Namecheap, etc.) crea **dos registros A** apuntando a la IP de tu VPS:

| Tipo | Nombre     | Valor (IP)   | Ejemplo                   |
|------|------------|--------------|---------------------------|
| A    | appapi     | IP_de_tu_VPS | appapi.tudominio.com      |
| A    | appchat    | IP_de_tu_VPS | appchat.tudominio.com     |

Espera unos minutos a que propaguen los DNS.

---

### **Paso 5: Ejecutar el instalador**

```bash
cd ~/waticketsaas
chmod +x install.sh
./install.sh
```

El script solo te pedirá **2 datos** (todo lo demás viene predeterminado):

| Pregunta | Ejemplo de respuesta |
|----------|------------------------|
| Subdominio API | `appapi.tudominio.com` |
| Subdominio Frontend | `appchat.tudominio.com` |

**Datos predeterminados:** Base de datos `whaticket`, usuario/contraseña `whaticket`, puertos 4010/3005, SSL automático con Certbot.

**Qué hace el instalador:**
- Crea la base de datos PostgreSQL
- Genera los archivos `.env` (backend y frontend)
- Instala dependencias, compila backend y frontend
- Ejecuta migraciones
- Configura PM2 (backend + frontend en segundo plano)
- Configura Nginx como proxy
- Configura SSL con Let's Encrypt automáticamente

---

### **Paso 6: Verificar que todo funciona**

```bash
pm2 list
```

Deben aparecer `waticketsaas-backend` y `waticketsaas-frontend` en estado **online**.

Visita en el navegador:
- **Frontend:** `https://appchat.tudominio.com`
- **API:** `https://appapi.tudominio.com`

---

### **Paso 7: Acceder al sistema**

- **URL:** `https://appchat.tudominio.com` (o el dominio que configuraste)
- **Email:** `admin@admin.com`
- **Contraseña:** `123456`

---

### **Comandos útiles después de instalar**

```bash
pm2 list           # Ver procesos
pm2 logs           # Ver logs en vivo
pm2 restart all    # Reiniciar backend y frontend
```

---

### **Documentación detallada**

Para instalación manual o solución de problemas: **`0003-Instalador para ubuntu linux.md`**

---

### **Opción alternativa: Instalador externo (instalador-whaticket)**

Si prefieres el instalador externo de terceros:

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/weliton2k/instalador-whaticket-main-v.10.0.1.git
cd instalador-whaticket-main-v.10.0.1
sudo chmod +x install_primaria
sudo ./install_primaria
```

Durante la instalación usa:
- **Repositorio:** `https://github.com/leopoldohuacasiv/waticketsaas.git`
- **Subdominio app:** `aplication.tudominio.com`
- **Subdominio API:** `api.tudominio.com`

---

## 🔧 **ACTUALIZACIONES IMPORTANTES**

### **Baileys API 6.7.19**
- ✅ **Actualizado** de versión 6.7.6 a 6.7.19
- ✅ **Corregido** error `makeInMemoryStore is not a function`
- ✅ **Mejorada** estabilidad de conexiones WhatsApp
- ✅ **Optimizado** rendimiento del sistema

### **Compatibilidad Windows**
- ✅ **Scripts PowerShell** para instalación automática
- ✅ **Corrección OpenSSL** para Node.js 20+
- ✅ **Configuración PostgreSQL** optimizada
- ✅ **Documentación completa** para desarrollo local

---

## 📁 **ESTRUCTURA DEL PROYECTO**

```
waticketsaas/
├── backend/                    # API Node.js + TypeScript
├── frontend/                   # React App
├── instalador/                 # Scripts Linux (producción)
├── 0001-Readmen-Install-Windows.md    # Guía Windows
├── 0002-Actualización Api Baileys6.7.19.md  # Actualización Baileys
├── 0003-Instalador para ubuntu linux.md     # Guía Ubuntu
├── setup_windows.ps1          # Script PowerShell (Windows)
├── install.sh                 # Instalador Ubuntu (Linux)
└── README.md                   # Este archivo
```

---

## 🎯 **CARACTERÍSTICAS PRINCIPALES**

- **💬 Integración WhatsApp** - Conexión directa con WhatsApp Business
- **🎫 Sistema de Tickets** - Gestión completa de conversaciones
- **👥 Multi-usuario** - Soporte para múltiples agentes
- **📊 Dashboard** - Métricas y estadísticas en tiempo real
- **🔔 Notificaciones** - Alertas instantáneas
- **📱 Responsive** - Compatible con dispositivos móviles
- **🌐 Multi-idioma** - Soporte para múltiples idiomas

---

## 🆘 **SOPORTE**

### **Problemas Comunes:**
- **Error OpenSSL**: Usar flag `--openssl-legacy-provider`
- **Error PostgreSQL**: Verificar permisos y conexión
- **Error Redis**: Asegurar que Redis esté corriendo
- **Error Baileys**: Verificar versión 6.7.19

### **Documentación Adicional:**
- **Windows**: Consultar `0001-Readmen-Install-Windows.md`
- **Ubuntu/Linux**: Consultar `0003-Instalador para ubuntu linux.md`
- **Baileys**: Consultar `0002-Actualización Api Baileys6.7.19.md`

---

## 📄 **LICENCIA**

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

---

## 🤝 **CONTRIBUCIONES**

💸 Donar vía PayPal
🪙 Binance USDT: leowin8@gmail.com (leopoldohuacasiv)
🔐 Wallet USDT: TExmTzFgUksfDvbzofcF6ereoMNFQW1zmF

---

### ¡Instalación completada con éxito! 🎉

**Proyecto de carácter educativo y exploratorio.** Para soluciones empresariales a escala, consultar WATOOLX. 
