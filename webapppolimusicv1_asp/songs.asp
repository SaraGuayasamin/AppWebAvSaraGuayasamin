<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' songs.asp - Pgina principal de la tarea
'--------------------------------------------------------------------------
' Funcionalidades:
'   1. Verifica sesin (si no hay, redirige a login.asp).
'   2. Muestra mensaje de bienvenida con el nombre del usuario logueado.
'   3. Muestra el rol actual (Admin / Usuario normal).
'   4. Botn de cerrar sesin (logout.asp).
'   5. Tabla HTML con canciones de TBL_SONG recorriendo el Recordset.
'   6. Reproductor de audio HTML5 fijo en la parte inferior.
'   7. Botn Play por fila que carga la cancin en el reproductor.
'   8. Muestra qu cancin est sonando.
'   9. Incrementa PLAYS con fetch() a play_count.asp?id=...
'  10. CRUD SOLO para admin:
'       - Crear cancin (nombre + mp3 de lista desplegable de /songFiles).
'       - Editar cancin (nombre + archivo).
'       - Eliminar cancin (con confirmacin en JavaScript).
'      Las acciones las procesan song_save.asp y song_delete.asp.
'==========================================================================
%>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "UTF-8"

'--- Verificar sesin: si no hay login, ir a login.asp ---
RequerirSesion()

'--- Variables de sesin ---
Dim strUsername, intUserType
strUsername = CStr(Session("Username"))
intUserType = CInt(Session("UserType"))

'--- Determinar texto del rol ---
Dim strRolTexto
If EsAdmin() Then
    strRolTexto = "Administrador"
Else
    strRolTexto = "Usuario normal"
End If

'--- Conectar a la BD y obtener canciones ---
Dim objConn, objRS, objCmd
Dim strMensajeError
strMensajeError = ""

Set objConn = AbrirConexion()

If Not (objConn Is Nothing) Then
    On Error Resume Next

    Set objCmd = Server.CreateObject("ADODB.Command")
    Set objCmd.ActiveConnection = objConn
    objCmd.CommandText = _
        "SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS " & _
        "FROM TBL_SONG " & _
        "ORDER BY SONG_NAME ASC"
    objCmd.CommandType = 1  ' adCmdText

    Set objRS = objCmd.Execute

    If Err.Number <> 0 Then
        strMensajeError = "Error al cargar canciones: " & Err.Description
    End If

    On Error GoTo 0
End If

'--- Si es admin, leer archivos mp3 de /songFiles con FileSystemObject ---
Dim fso, carpeta, archivos, archivo
Dim arrMp3Files()
Dim intMp3Count
intMp3Count = 0

If EsAdmin() Then
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")

    ' Server.MapPath convierte ruta virtual a fsica
    Dim strCarpetaFisica
    strCarpetaFisica = Server.MapPath("songFiles")

    If fso.FolderExists(strCarpetaFisica) Then
        Set carpeta = fso.GetFolder(strCarpetaFisica)
        For Each archivo In carpeta.Files
            ' Filtrar solo .mp3 (comparacin sin importar maysculas)
            If LCase(Right(archivo.Name, 4)) = ".mp3" Then
                ReDim Preserve arrMp3Files(intMp3Count)
                arrMp3Files(intMp3Count) = archivo.Name
                intMp3Count = intMp3Count + 1
            End If
        Next
    End If

    Set fso = Nothing
    On Error GoTo 0
End If

'--- Leer parmetro de edicin (si viene de "Editar") ---
Dim intEditId
intEditId = 0
If Request.QueryString("edit") <> "" Then
    If IsNumeric(Request.QueryString("edit")) Then
        intEditId = CInt(Request.QueryString("edit"))
    End If
End If

'--- Si estamos editando, cargar los datos de esa cancin ---
Dim strEditName, strEditPath
strEditName = ""
strEditPath = ""

If intEditId > 0 And Not (objConn Is Nothing) Then
    On Error Resume Next
    Dim cmdEdit, rsEdit
    Set cmdEdit = Server.CreateObject("ADODB.Command")
    Set cmdEdit.ActiveConnection = objConn
    cmdEdit.CommandText = "SELECT SONG_NAME, SONG_PATH FROM TBL_SONG WHERE ID_SONG = ?"
    cmdEdit.CommandType = 1

    Dim paramEditId
    Set paramEditId = cmdEdit.CreateParameter("ID_SONG", 3, 1, 4, intEditId)  ' adInteger=3, adParamInput=1
    cmdEdit.Parameters.Append paramEditId

    Set rsEdit = cmdEdit.Execute
    If Not rsEdit.EOF Then
        strEditName = CStr(rsEdit("SONG_NAME").Value)
        strEditPath = CStr(rsEdit("SONG_PATH").Value)
    End If
    rsEdit.Close
    Set rsEdit = Nothing
    Set cmdEdit = Nothing
    On Error GoTo 0
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Song List</title>
    <link rel="stylesheet" href="css/site.css">
</head>
<body class="page-songs">

    <!-- =========================================================== -->
    <!-- HEADER / BARRA SUPERIOR                                      -->
    <!-- =========================================================== -->
    <header class="site-header">
        <div class="header-content">
            <div class="header-brand">
                <span class="brand-icon">&#9835;</span>
                <span class="brand-name">PoliMusic</span>
            </div>
            <div class="header-user">
                <div class="user-info">
                    <span class="user-greeting">Bienvenida, <strong><%= Server.HTMLEncode(strUsername) %></strong></span>
                    <span class="user-role badge badge-<% If EsAdmin() Then %>admin<% Else %>normal<% End If %>">
                        <%= strRolTexto %>
                    </span>
                </div>
                <a href="logout.asp" class="btn btn-outline btn-sm">Cerrar Sesin</a>
            </div>
        </div>
    </header>

    <!-- =========================================================== -->
    <!-- CONTENIDO PRINCIPAL                                          -->
    <!-- =========================================================== -->
    <main class="main-content">

        <!-- Ttulo del listado -->
        <div class="section-title">
            <h2>Song List</h2>
            <% If EsAdmin() Then %>
            <button type="button" class="btn btn-primary btn-sm" onclick="toggleForm('form-create')">
                <span class="btn-icon">+</span> Nueva Cancin
            </button>
            <% End If %>
        </div>

        <!-- Mensaje de error si lo hay -->
        <% If strMensajeError <> "" Then %>
        <div class="alert alert-error">
            <span class="alert-icon">&#9888;</span>
            <span><%= Server.HTMLEncode(strMensajeError) %></span>
        </div>
        <% End If %>

        <!-- ======================================================= -->
        <!-- FORMULARIO CREAR CANCIN (solo admin, inicialmente oculto) -->
        <!-- ======================================================= -->
        <% If EsAdmin() Then %>
        <div id="form-create" class="modal-form" style="display:none;">
            <div class="modal-form-card">
                <div class="modal-form-header">
                    <h3>Crear Nueva Cancin</h3>
                    <button type="button" class="btn-close" onclick="toggleForm('form-create')">&times;</button>
                </div>
                <form method="post" action="song_save.asp" class="song-form">
                    <input type="hidden" name="accion" value="crear">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="song-name-create">Nombre de la cancin</label>
                            <input type="text" id="song-name-create" name="song_name" required maxlength="50"
                                   placeholder="Ej: bensound-adventure">
                        </div>
                        <div class="form-group">
                            <label for="song-file-create">Archivo MP3</label>
                            <select id="song-file-create" name="song_path" required>
                                <option value="">-- Selecciona un archivo .mp3 --</option>
                                <% If intMp3Count > 0 Then %>
                                    <% Dim i %>
                                    <% For i = 0 To intMp3Count - 1 %>
                                        <option value="~/songFiles/<%= arrMp3Files(i) %>">
                                            <%= Server.HTMLEncode(arrMp3Files(i)) %>
                                        </option>
                                    <% Next %>
                                <% Else %>
                                    <option value="" disabled>No hay archivos .mp3 en /songFiles</option>
                                <% End If %>
                            </select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Guardar</button>
                        <button type="button" class="btn btn-secondary" onclick="toggleForm('form-create')">Cancelar</button>
                    </div>
                </form>
            </div>
        </div>
        <% End If %>

        <!-- ======================================================= -->
        <!-- FORMULARIO EDITAR CANCIN (solo admin, si ?edit=ID)       -->
        <!-- ======================================================= -->
        <% If EsAdmin() And intEditId > 0 Then %>
        <div id="form-edit" class="modal-form" style="display:block;">
            <div class="modal-form-card">
                <div class="modal-form-header">
                    <h3>Editar Cancin #<%= intEditId %></h3>
                    <a href="songs.asp" class="btn-close">&times;</a>
                </div>
                <form method="post" action="song_save.asp" class="song-form">
                    <input type="hidden" name="accion" value="editar">
                    <input type="hidden" name="id_song" value="<%= intEditId %>">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="song-name-edit">Nombre de la cancin</label>
                            <input type="text" id="song-name-edit" name="song_name" required maxlength="50"
                                   value="<%= Server.HTMLEncode(strEditName) %>">
                        </div>
                        <div class="form-group">
                            <label for="song-file-edit">Archivo MP3</label>
                            <select id="song-file-edit" name="song_path" required>
                                <option value="">-- Selecciona un archivo .mp3 --</option>
                                <% If intMp3Count > 0 Then %>
                                    <% Dim j %>
                                    <% For j = 0 To intMp3Count - 1 %>
                                        <option value="~/songFiles/<%= arrMp3Files(j) %>"
                                            <% If strEditPath = "~/songFiles/" & arrMp3Files(j) Then %>selected<% End If %>>
                                            <%= Server.HTMLEncode(arrMp3Files(j)) %>
                                        </option>
                                    <% Next %>
                                <% Else %>
                                    <option value="" disabled>No hay archivos .mp3 en /songFiles</option>
                                <% End If %>
                            </select>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Actualizar</button>
                        <a href="songs.asp" class="btn btn-secondary">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
        <% End If %>

        <!-- ======================================================= -->
        <!-- TABLA DE CANCIONES                                       -->
        <!-- ======================================================= -->
        <div class="table-card">
            <table class="songs-table" id="songsTable">
                <thead>
                    <tr>
                        <th class="col-id">ID</th>
                        <th class="col-name">Cancin</th>
                        <th class="col-play">Reproducir</th>
                        <th class="col-plays">Reproducciones</th>
                        <% If EsAdmin() Then %>
                        <th class="col-actions">Acciones</th>
                        <% End If %>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ' --- Recorrer el Recordset con Do While Not rs.EOF ---
                    If Not (objRS Is Nothing) Then
                        If Not objRS.EOF Then
                            Do While Not objRS.EOF
                                Dim intSongId, strSongName, strSongPath, intPlays
                                intSongId    = CInt(objRS("ID_SONG").Value)
                                strSongName  = CStr(objRS("SONG_NAME").Value)
                                strSongPath  = CStr(objRS("SONG_PATH").Value)
                                intPlays     = CInt(objRS("PLAYS").Value)

                                ' Convertir "~/songFiles/..." a "songFiles/..."
                                ' ASP clsico no entiende "~", hay que quitarlo
                                Dim strRelativePath
                                strRelativePath = Replace(strSongPath, "~/", "")
                    %>
                    <tr class="song-row" data-song-id="<%= intSongId %>" data-song-path="<%= strRelativePath %>">
                        <td class="col-id"><%= intSongId %></td>
                        <td class="col-name"><%= Server.HTMLEncode(strSongName) %></td>
                        <td class="col-play">
                            <button class="btn btn-play btn-sm"
                                    onclick="playSong(<%= intSongId %>, '<%= strRelativePath %>', '<%= Server.HTMLEncode(strSongName) %>')">
                                <span class="play-icon">&#9654;</span> Play
                            </button>
                        </td>
                        <td class="col-plays">
                            <span class="plays-count" id="plays-<%= intSongId %>"><%= intPlays %></span>
                        </td>
                        <% If EsAdmin() Then %>
                        <td class="col-actions">
                            <a href="songs.asp?edit=<%= intSongId %>" class="btn btn-warning btn-sm">Editar</a>
                            <button class="btn btn-danger btn-sm"
                                    onclick="confirmDelete(<%= intSongId %>, '<%= Server.HTMLEncode(strSongName) %>')">
                                Eliminar
                            </button>
                        </td>
                        <% End If %>
                    </tr>
                    <%
                                objRS.MoveNext
                            Loop
                        Else
                    %>
                    <tr>
                        <td colspan="<% If EsAdmin() Then %>5<% Else %>4<% End If %>" class="empty-row">
                            No hay canciones registradas.
                        </td>
                    </tr>
                    <%
                        End If
                    Else
                    %>
                    <tr>
                        <td colspan="<% If EsAdmin() Then %>5<% Else %>4<% End If %>" class="empty-row">
                            No se pudieron cargar las canciones.
                        </td>
                    </tr>
                    <%
                    End If
                    %>
                </tbody>
            </table>
        </div>

    </main>

    <!-- =========================================================== -->
    <!-- REPRODUCTOR DE AUDIO FIJO (HTML5 <audio>)                    -->
    <!-- =========================================================== -->
    <footer class="player-bar" id="playerBar">
        <div class="player-content">
            <div class="player-song-info">
                <span class="player-icon">&#9835;</span>
                <div class="player-text">
                    <span class="player-label">Reproduciendo:</span>
                    <span class="player-title" id="currentSongTitle">Selecciona una cancin</span>
                </div>
            </div>
            <audio id="audioPlayer" controls class="audio-player"></audio>
        </div>
    </footer>

    <!-- =========================================================== -->
    <!-- JAVASCRIPT                                                   -->
    <!-- =========================================================== -->
    <script src="js/app.js"></script>
</body>
</html>
<%
'--- Limpieza de objetos ADO ---
On Error Resume Next
If Not (objRS Is Nothing) Then
    If objRS.State = 1 Then objRS.Close
    Set objRS = Nothing
End If
Set objCmd = Nothing
CerrarConexion objConn
On Error GoTo 0
%>
