<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' song_save.asp
'--------------------------------------------------------------------------
' Procesa CREAR y EDITAR canciones (solo admin).
' - Valida con RequerirAdmin() en el SERVIDOR (no solo ocultar botones).
' - Usa ADODB.Command con CreateParameter (consulta parametrizada).
' - Recibe los datos por POST desde songs.asp.
' - Redirige de vuelta a songs.asp al terminar.
'==========================================================================
%>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "UTF-8"

'--- Validar que el usuario sea admin (validacin en servidor) ---
' Esto asegura que aunque un usuario normal llame directamente
' song_save.asp con POST, no podr ejecutar la accin.
RequerirAdmin()

'--- Tambin verificar sesin ---
RequerirSesion()

'--- Leer datos del formulario ---
Dim strAccion, strSongName, strSongPath, intSongId
strAccion   = Request.Form("accion")
strSongName = Trim(Request.Form("song_name"))
strSongPath = Trim(Request.Form("song_path"))
intSongId   = 0

If Request.Form("id_song") <> "" And IsNumeric(Request.Form("id_song")) Then
    intSongId = CInt(Request.Form("id_song"))
End If

'--- Validar que los datos no estn vacos ---
If strSongName = "" Or strSongPath = "" Or strAccion = "" Then
    Response.Redirect "songs.asp"
    Response.End
End If

'--- Conectar a la BD ---
Dim objConn, objCmd
Set objConn = AbrirConexion()

If Not (objConn Is Nothing) Then
    On Error Resume Next

    Set objCmd = Server.CreateObject("ADODB.Command")
    Set objCmd.ActiveConnection = objConn
    objCmd.CommandType = 1  ' adCmdText

    If strAccion = "crear" Then
        '---------------------------------------------------------------
        ' CREAR cancin: INSERT con parmetros
        '---------------------------------------------------------------
        objCmd.CommandText = _
            "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) " & _
            "VALUES (?, ?, 0)"

        ' Parmetro 1: SONG_NAME (varchar(50) -> adVarChar=200, Input=1, Size=50)
        Dim paramCreateName
        Set paramCreateName = objCmd.CreateParameter("SONG_NAME", 200, 1, 50, strSongName)
        objCmd.Parameters.Append paramCreateName

        ' Parmetro 2: SONG_PATH (varchar(255) -> adVarChar=200, Input=1, Size=255)
        Dim paramCreatePath
        Set paramCreatePath = objCmd.CreateParameter("SONG_PATH", 200, 1, 255, strSongPath)
        objCmd.Parameters.Append paramCreatePath

        objCmd.Execute

    ElseIf strAccion = "editar" Then
        '---------------------------------------------------------------
        ' EDITAR cancin: UPDATE con parmetros
        '---------------------------------------------------------------
        If intSongId > 0 Then
            objCmd.CommandText = _
                "UPDATE TBL_SONG " & _
                "SET SONG_NAME = ?, SONG_PATH = ? " & _
                "WHERE ID_SONG = ?"

            ' Parmetro 1: SONG_NAME
            Dim paramEditName
            Set paramEditName = objCmd.CreateParameter("SONG_NAME", 200, 1, 50, strSongName)
            objCmd.Parameters.Append paramEditName

            ' Parmetro 2: SONG_PATH
            Dim paramEditPath
            Set paramEditPath = objCmd.CreateParameter("SONG_PATH", 200, 1, 255, strSongPath)
            objCmd.Parameters.Append paramEditPath

            ' Parmetro 3: ID_SONG (int -> adInteger=3, Input=1, Size=4)
            Dim paramEditId
            Set paramEditId = objCmd.CreateParameter("ID_SONG", 3, 1, 4, intSongId)
            objCmd.Parameters.Append paramEditId

            objCmd.Execute
        End If
    End If

    If Err.Number <> 0 Then
        ' En caso de error, mostrar mensaje y no redirigir
        Response.Write "<div class='error-msg'>Error al guardar: " & Server.HTMLEncode(Err.Description) & "</div>"
    Else
        ' xito: redirigir a songs.asp
        Response.Redirect "songs.asp"
        Response.End
    End If

    Set objCmd = Nothing
    On Error GoTo 0

    CerrarConexion objConn
Else
    Response.Write "<div class='error-msg'>No se pudo conectar a la base de datos.</div>"
End If
%>
