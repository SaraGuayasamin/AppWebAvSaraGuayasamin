# PoliMusic ASP Classic - Gua de Configuracin

## Tabla de Contenidos
1. [Estructura de Carpetas](#1-estructura-de-carpetas)
2. [Instalacin de MSOLEDBSQL](#2-instalacin-de-msoledbsql)
3. [Configuracin de IIS](#3-configuracin-de-iis)
4. [Verificacin del Puerto 14333](#4-verificacin-del-puerto-14333)
5. [Sesiones y Validacin de Roles](#5-sesiones-y-validacin-de-roles)
6. [Cmo Probar la Aplicacin](#6-cmo-probar-la-aplicacin)

---

## 1. Estructura de Carpetas

```
webapppolimusicv1_asp/
|-- index.asp              (redirige a login o songs segn sesin)
|-- login.asp              (formulario de inicio de sesin)
|-- songs.asp              (pgina principal: listado + reproductor + CRUD)
|-- song_save.asp          (procesa crear/editar cancin - solo admin)
|-- song_delete.asp        (procesa eliminar cancin - solo admin)
|-- play_count.asp         (incrementa PLAYS via fetch)
|-- logout.asp             (cierra sesin)
|-- includes/
|   |-- conexion.asp       (funciones AbrirConexion / CerrarConexion)
|   `-- seguridad.asp      (RequerirSesion / EsAdmin / RequerirAdmin)
|-- css/
|   `-- site.css           (estilos - paleta "Sunset Vinyl")
|-- js/
|   `-- app.js             (reproductor, fetch, toggle, confirm)
`-- songFiles/             (carpeta con archivos .mp3)
```

---

## 2. Instalacin de MSOLEDBSQL

### Qu es MSOLEDBSQL?
Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL) es el proveedor moderno
para conectar aplicaciones ADO clsicas a SQL Server. Soporta:
- Autenticacin con usuario/contrasea
- TrustServerCertificate (para certificados auto-firmados en Docker)

### Dnde descargarlo
Descarga desde Microsoft:
https://learn.microsoft.com/sql/connect/oledb/download-oledb-driver-for-sql-server

### 32 bits vs 64 bits

| Configuracin del App Pool                    | Versin de MSOLEDBSQL |
|-----------------------------------------------|----------------------|
| "Habilitar aplicaciones de 32 bits" = True    | x86 (32-bit)         |
| "Habilitar aplicaciones de 32 bits" = False   | x64 (64-bit)         |

**Por defecto** en Windows 64-bit, el App Pool corre en 64 bits.
Descarga e instala la versin **x64**.

Si tu SQL Server corre en Docker en un contenedor Linux, el puerto 14333
debe estar accesible desde el host. Verifica con telnet (seccin 4).

### Cmo verificar qu versin tienes instalada
Abre el Editor del Registro (regedit) y busca:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSOLEDBSQL
```
Si existe la clave, el driver est instalado.

---

## 3. Configuracin de IIS

### Paso 1: Habilitar ASP en Windows

1. Abre **Panel de Control > Programas > Activar o desactivar caractersticas de Windows**
2. Navega a:
   ```
   Internet Information Services
   `-- Servicios World Wide Web
       `-- Caractersticas de desarrollo de aplicaciones
           `-- ASP  [marca esta casilla]
   ```
3. Tambin marca:
   - "Documentos predeterminados" (para que index.asp funcione)
   - "Examen de directorios" (opcional, para depurar)
4. Click **OK** y espera a que Windows instale las caractersticas

### Paso 2: Abrir el Administrador de IIS

1. Presiona **Win + R**, escribe `inetmgr` y presiona Enter
2. O: Panel de Control > Herramientas administrativas > Administrador de Internet Information Services (IIS)

### Paso 3: Crear el sitio o aplicacin

**Opcin A: Como aplicacin dentro del Default Web Site (recomendado)**

1. En el panel izquierdo, expande el servidor > **Sitios** > **Default Web Site**
2. Click derecho > **Agregar aplicacin...**
3. Alias: `polimusic`
4. Grupo de aplicaciones: selecciona uno existente o crea uno nuevo
5. Ruta de acceso fsica: `C:\Users\Usuario\Documents\web avanzadas\taller_dos\AppWebAvSaraGuayasamin\webapppolimusicv1_asp`
6. Click **OK**
7. Accede en: `http://localhost/polimusic/`

**Opcin B: Como sitio web independiente**

1. Click derecho en **Sitios** > **Agregar sitio web...**
2. Nombre del sitio: `PoliMusic`
3. Ruta de acceso fsica: la carpeta del proyecto
4. Puerto: 8080 (o el que prefieras)
5. Click **OK**
6. Accede en: `http://localhost:8080/`

### Paso 4: Configurar el Application Pool (32 vs 64 bits)

1. En IIS Manager, click en **Grupos de aplicaciones** en el panel izquierdo
2. Selecciona el pool que usa tu sitio
3. Click derecho > **Configuracin avanzada...**
4. Busca **Habilitar aplicaciones de 32 bits**:
   - `False` = 64-bit (necesitas MSOLEDBSQL x64)
   - `True` = 32-bit (necesitas MSOLEDBSQL x86)
5. Por defecto: `False` (64-bit)

### Paso 5: Permisos de la carpeta

El usuario `IIS_IUSRS` necesita permisos de lectura y escritura en la carpeta del sitio:

1. Click derecho en la carpeta del proyecto > **Propiedades** > **Seguridad**
2. Click **Editar...** > **Agregar...**
3. Escribe `IIS_IUSRS` y click **Comprobar nombres** > **OK**
4. Marca **Lectura** y **Escritura**
5. Click **OK** en todos los dilogos

### Paso 6: Habilitar mensajes de error ASP en el navegador (para depurar)

Por defecto, IIS oculta los errores ASP y muestra un mensaje genrico 500.

Para ver los errores:

1. En IIS Manager, selecciona tu sitio/aplicacin
2. Doble click en **Pginas de errores**
3. En el panel derecho, click **Modificar configuracin de caractersticas...**
4. Selecciona **Mensajes de error detallados** (no personalizacin)
5. Click **OK**

**IMPORTANTE:** No pongas `<httpErrors>` ni `<asp>` en el `web.config` del sitio porque esas secciones estn bloqueadas en `applicationHost.config` y causarn error 500.19 / "Error en nueva aplicacin". El `web.config` del proyecto solo debe tener `<defaultDocument>`.

Para habilitar errores detallados de ASP, configura directamente en IIS Manager:

1. En IIS Manager, selecciona tu sitio/aplicacin
2. Doble click en **ASP**
3. Expande **Comportamiento de la depuracin**
4. Pon **Enviar errores al explorador** = `True`
5. Click en **Aplicar** en el panel derecho

El `web.config` del proyecto ya incluye solo el documento por defecto:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <defaultDocument>
      <files>
        <clear />
        <add value="index.asp" />
        <add value="login.asp" />
      </files>
    </defaultDocument>
  </system.webServer>
</configuration>
```

> Nota: Este web.config es para IIS, no es de ASP.NET. Solo configura
> el documento por defecto. Tu cdigo sigue siendo 100% ASP clsico.

### Paso 7: Publicar desde Visual Studio 2022

1. Abre VS 2022 > **Archivo > Abrir > Sitio web...**
2. Selecciona la carpeta `webapppolimusicv1_asp`
3. VS reconocer los archivos .asp como contenido
4. Para publicar: **Compilar > Publicar sitio web** (o simplemente copia los archivos a IIS)
5. Como es ASP clsico, no hay compilacin: los archivos .asp se interpretan en tiempo real

---

## 4. Verificacin del Puerto 14333

### Con telnet (recomendado)

```cmd
telnet localhost 14333
```

- Si la pantalla se pone en negro (o parpadea): **puerto abierto** (SQL Server responde)
- Si dice "Conexin fallida": **puerto cerrado** o SQL Server no est corriendo

### Con PowerShell

```powershell
Test-NetConnection -ComputerName localhost -Port 14333
```

Resultado esperado: `TcpTestSucceeded : True`

### Si SQL Server no est corriendo en Docker

```cmd
docker ps
```

Verifica que el contenedor de SQL Server est corriendo y que haga port mapping de 14333.

Para iniciarlo:
```cmd
docker start <nombre-del-contenedor>
```

---

## 5. Sesiones y Validacin de Roles en ASP Clsico

### Cmo funcionan las sesiones

En ASP clsico, las sesiones funcionan con **cookies** y memoria del servidor:

1. **Primera visita**: IIS asigna un `SessionID` nico al navegador.
   - Se enva como cookie: `ASPSESSIONIDXXXXXXX=valor`
   - Se almacena en memoria del proceso w3wp.exe

2. **Login (login.asp)**:
   - Al validar el usuario contra TBL_USER, guardamos:
     ```vbscript
     Session("UserId")   = rs("ID_USER")
     Session("Username") = rs("USERNAME")
     Session("UserType") = rs("USER_TYPE")
     ```
   - Estas variables viven en el servidor, asociadas al SessionID

3. **Pginas protegidas (songs.asp, etc.)**:
   - Al inicio de la pgina, verificamos:
     ```vbscript
     If Session("Username") = "" Then
         Response.Redirect "login.asp"
     End If
     ```
   - Si la sesin expir (timeout por defecto: 20 min), las variables
     se pierden y el usuario es redirigido al login

4. **Logout (logout.asp)**:
   - `Session.Abandon` destruye la sesin y libera la memoria
   - En la prxima visita, IIS genera un SessionID nuevo

### Validacin de roles

El campo `USER_TYPE` de TBL_USER se guarda en `Session("UserType")`:
- `1` = Administrador
- `0` = Usuario normal

La funcin `EsAdmin()` en `includes/seguridad.asp`:

```vbscript
Function EsAdmin()
    If Session("UserType") = "1" Then
        EsAdmin = True
    Else
        EsAdmin = False
    End If
End Function
```

### Doble validacin (importante)

1. **En el cliente (HTML/JS)**: No mostrar botones de CRUD si no es admin.
   - Esto mejora la experiencia de usuario pero NO es seguro.

2. **En el servidor (VBScript)**: Validar con `RequerirAdmin()` en
   `song_save.asp` y `song_delete.asp`.
   - Esto es lo que realmente protege: aunque un usuario normal llame
     directamente `song_save.asp` con un POST, la validacin lo bloquea.
   - **Nunca confies solo en ocultar botones en HTML.**

---

## 6. Cmo Probar la Aplicacin

### Escenario 1: Login como Administrador

1. Abre `http://localhost/polimusic/` (o el puerto que configuraste)
2. Debes ser redirigido a `login.asp`
3. Ingresa:
   - Usuario: `userAdmin`
   - Contrasea: `12345678`
4. Click **Iniciar Sesin**
5. Debes ver:
   - "Bienvenida, **userAdmin**"
   - Badge dorado: "**Administrador**"
   - Tabla "Song List" con todas las canciones
   - Botn **Nueva Cancin** (solo visible para admin)
   - Columna **Acciones** con botones Editar y Eliminar en cada fila
   - Reproductor fijo abajo
6. Click **Play** en una cancin:
   - El reproductor carga el mp3 y suena
   - La fila se resalta
   - El contador de reproducciones aumenta
7. Click **Nueva Cancin**:
   - Se abre el formulario
   - Lista desplegable de archivos .mp3 en /songFiles
8. Click **Editar** en una cancin:
   - Se abre el formulario con los datos cargados
9. Click **Eliminar**:
   - Aparece dilogo de confirmacin
   - Al confirmar, se elimina la cancin y redirige a songs.asp
10. Click **Cerrar Sesin**:
    - Te lleva a logout.asp y de vuelta a login.asp

### Escenario 2: Login como Usuario Normal

1. En `login.asp`, ingresa:
   - Usuario: `userNormal`
   - Contrasea: `12345678`
2. Debes ver:
   - "Bienvenida, **userNormal**"
   - Badge turquesa: "**Usuario normal**"
   - Tabla "Song List" con todas las canciones
   - **NO** hay botn "Nueva Cancin"
   - **NO** hay columna "Acciones" (ni Editar ni Eliminar)
   - Botn **Play** funcional
   - Reproductor fijo abajo funcional
3. Intenta acceder directamente a `song_save.asp`:
   - Escribe `http://localhost/polimusic/song_save.asp` en el navegador
   - Debes ser redirigido a `songs.asp` (no se ejecuta la accin)
4. Intenta acceder directamente a `song_delete.asp?id=1`:
   - Debes ser redirigido a `songs.asp`

### Escenario 3: Sin sesin

1. Cierra sesin
2. Intenta acceder a `songs.asp` directamente
3. Debes ser redirigido a `login.asp`

---

## Paleta de Colores "Sunset Vinyl"

| Nombre              | Hex       | Uso                          |
|---------------------|-----------|------------------------------|
| Azul noche profundo | `#0F0E1A` | Fondo principal              |
| Azul noche cartes   | `#1A1830` | Tarjetas, header, player     |
| Gris-azul alt       | `#252238` | Inputs, selects              |
| Coral atardecer     | `#E8556B` | Primario (botones, acentos)  |
| Coral hover         | `#FF6B7E` | Hover de primario            |
| Turquesa noche      | `#4A9DBA` | Secundario (badge normal)    |
| mbar dorado vinilo | `#F5B945` | Acento (nombres, contador)   |
| Texto claro         | `#F0EEF6` | Texto principal              |
| Texto difuminado    | `#9B98AE` | Etiquetas, subttulos        |
| Borde oscuro        | `#2D2B40` | Bordes de tarjetas, tabla    |
