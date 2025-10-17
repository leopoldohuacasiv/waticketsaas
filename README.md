# WhaticketSaaS - Sistema de Tickets con WhatsApp

Sistema completo de gestión de tickets y atención al cliente integrado con WhatsApp Business API.

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

## 🐧 **INSTALACIÓN EN UBUNTU (PRODUCCIÓN)**

### 1. Acceso al servidor VPS

Adquiere un servidor VPS con sistema operativo **Ubuntu 22** o superior. En este caso, se recomienda el proveedor [Contabo](https://contabo.com).

Ejemplo de servidor:
```
Server: 62.xx4.2x0.x0
```

### 2. Configuración de dominios

Debes configurar dos subdominios en tu proveedor de dominios, como [GoDaddy](https://www.godaddy.com/) u otro de tu preferencia. Estos subdominios deben apuntar a tu servidor VPS:
```
app.subdominio.online
api.subdominio.online
```

### 3. Subir el código a GitHub

Para agilizar el proceso, puedes clonar el repositorio con el código fuente de Whaticket:
```
Repositorio: https://github.com/leopoldohuacasiv/waticketsaas.git
```

### 4. Iniciar instalación en Ubuntu

1. Accede a tu servidor VPS.
2. Crea un usuario llamado `deploy` y otórgale permisos:
    ```bash
    sudo adduser deploy
    ```
    - Asigna una contraseña.
    - Presiona **Enter** en los campos adicionales.
3. Otorga permisos sudo al usuario:
    ```bash
    sudo usermod -aG sudo deploy
    ```
4. Cierra la sesión con:
    ```bash
    exit
    ```
5. Vuelve a ingresar como el usuario `deploy`:
    ```bash
    ssh deploy@tu.ip.vps
    ```

### 5. Ejecutar la instalación

Ejecuta el siguiente script para instalar Whaticket:
```bash
sudo apt update && sudo apt install -y git \
&& git clone https://github.com/weliton2k/instalador-whaticket-main-v.10.0.1.git \
&& sudo chmod -R 777 instalador-whaticket-main-v.10.0.1 \
&& cd instalador-whaticket-main-v.10.0.1 \
&& sudo ./install_primaria
```

#### Datos requeridos durante la instalación:

- **Tipo de instalación:** `0` (Instalación)
- **Nombre de la base de datos:** `tubasededatos`
- **Repositorio de GitHub:** `https://github.com/leopoldohuacasiv/waticketsaas.git`
- **Instancia/Empresa:** `ponunnombre`
- **Valor de QR:** `999`
- **Usuarios conectados:** `999`
- **Subdominio app:** `app.subdominio.com`
- **Subdominio API:** `api.subdominio.com`
- **Conexión 1:** `3000`
- **Conexión 2:** `4000`
- **Conexión 3:** `5000`

> **Nota:** La instalación puede tardar entre **15 y 20 minutos** dependera de la velovidad del servidor VPS que contrate.

### 6. Acceder al sistema

Una vez completada la instalación, ingresa a la plataforma en:
```
app.subdominio.com
```

Credenciales por defecto:
```
Usuario: admin@admin.com
Contraseña: 123456
```

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
├── setup_windows.ps1          # Script PowerShell
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
- **Baileys**: Consultar `0002-Actualización Api Baileys6.7.19.md`

---

## 📄 **LICENCIA**

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

---

## 🤝 **CONTRIBUCIONES**

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

### ¡Instalación completada con éxito! 🎉

**💚 Si este proyecto te ha sido útil y deseas apoyar su crecimiento, puedes contribuir con una donación voluntaria.**
**Tu apoyo me motiva a seguir mejorando y mantener la versión libre de Whaticket SaaS para toda la comunidad.**

## 💚 Formas de apoyo

- [💸 Donar vía PayPal](https://www.paypal.com/donate/?hosted_button_id=MAX4ME9FBH5NQ)  
- 🪙 **Binance USDT**: [leowin8@gmail.com](mailto:leowin8@gmail.com) *(leopoldohuacasiv)*  
- 🔐 **Wallet USDT**: `TExmTzFgUksfDvbzofcF6ereoMNFQW1zmF`

