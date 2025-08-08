# Instalación de Whaticket 10.9

Esta versión es liberada gracias al aporte de @LeandroReis2907, especialista en infraestructura TI en Brasil. Bajo ese concepto, mi aporte en contenido en español está alineado con los conceptos de @LeandroReis2907.

---

## 1. Acceso al servidor VPS

Adquiere un servidor VPS con sistema operativo **Ubuntu 20.04** o superior. En este caso, se recomienda el proveedor [Contabo](https://contabo.com).

Ejemplo de servidor:
```
Server: 62.xx4.2x0.x0
```

---

## 2. Configuración de dominios

Debes configurar dos subdominios en tu proveedor de dominios, como [GoDaddy](https://www.godaddy.com/) u otro de tu preferencia. Estos subdominios deben apuntar a tu servidor VPS:
```
app.subdominio.online
api.subdominio.online
```

---

## 3. Subir el código a GitHub

Para agilizar el proceso, puedes clonar el repositorio con el código fuente de Whaticket:
```
Repositorio: https://github.com/leopoldohuacasiv/waticketsaas.git
```

---

## 4. Iniciar instalación en Ubuntu

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

---

## 5. Ejecutar la instalación

Ejecuta el siguiente script para instalar Whaticket:
```bash
sudo apt update && sudo apt install -y git \
&& git clone https://github.com/weliton2k/instalador-whaticket-main-v.10.0.1.git \
&& sudo chmod -R 777 instalador-whaticket-main-v.10.0.1 \
&& cd instalador-whaticket-main-v.10.0.1 \
&& sudo ./install_primaria
```

### Datos requeridos durante la instalación:

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

> **Nota:** La instalación puede tardar entre **40 y 60 minutos** dependera de la velovidad del servidor VPS que contrate.

---

## 6. Acceder al sistema

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

### ¡Instalación completada con éxito! 🎉

## Dato Extra

Para lograr cambiar el idioma, necesitas recompilar el frontend y redirecciones el script es.js como principal así tendras una parte en español, el resto tienes que reducirlo manualmente desde código accediendo. Puedes acceder al grupo de whatsapp: [Sistemas con WhatsApp](https://chat.whatsapp.com/HR9PZZLqsRHAP8ZA8s0H5G) e intercambiar ideas, pero para mas detalles conversa con el Admin del grupo.
