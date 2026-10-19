## PoliMusic - Web App ASP Classic

Proyecto universitario de Aplicaciones Web Avanzadas.
Reproductor de musica con CRUD de canciones, sesiones y roles de usuario.

### Estructura de carpetas

webapppolimusicv1_asp/
  |-- index.asp              (redirige a login o songs segun sesion)
  |-- login.asp             (formulario de inicio de sesion)
  |-- songs.asp             (pagina principal: listado + reproductor + CRUD)
  |-- song_save.asp         (procesa crear/editar cancion - solo admin)
  |-- song_delete.asp       (procesa eliminar cancion - solo admin)
  |-- play_count.asp        (incrementa PLAYS via fetch)
  |-- logout.asp            (cierra sesion)
  |-- includes/
  |   |-- conexion.asp      (funciones AbrirConexion / CerrarConexion)
  |   `-- seguridad.asp     (RequerirSesion / EsAdmin / RequerirAdmin)
  |-- css/
  |   `-- site.css          (estilos - paleta "Sunset Vinyl")
  |-- js/
  |   `-- app.js            (reproductor, fetch, toggle, confirm)
  `-- songFiles/            (carpeta con archivos .mp3)
