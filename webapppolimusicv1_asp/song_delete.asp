<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' song_delete.asp
'--------------------------------------------------------------------------
' Elimina una cancin de TBL_SONG (solo admin).
' - Valida con RequerirAdmin() en el SERVIDOR.
' - Usa ADODB.Command con CreateParameter (DELETE parametrizado).
' - Recibe el ID por GET (?id=...) o POST.
' - Redirige de vuelta a songs.asp al terminar.
'==========================================================================
%>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "UTF-8"

'--- Validar que el usuario sea admin (validacin en servidor) ---
' Aunque el botn de eliminar solo se muestra si EsAdmin(),
' esta validacin asegura que un usuario normal no pueda llamar
' directamente song_delete.asp?id=5 y borrar canciones.
RequerirAdmin()
RequerirSesion()

'--- Leer el ID de la cancin a eliminar ---
Dim intSongId
intSongId = 0

If Request.QueryString("id") <> "" And IsNumeric(Request.QueryString("id")) Then
    intSongId = CInt(Request.QueryString("id"))
ElseIf Request.Form("id") <> "" And IsNumeric(Request.Form("id")) Then
    intSongId = CInt(Request.Form("id"))
End If

If intSongId <= 0 Then
    Response.Redirect "songs.asp"
    Response.End
End If

'--- Conectar y ejecutar DELETE parametrizado ---
Dim objConn, objCmd
Set objConn = AbrirConexion()

If Not (objConn Is Nothing) Then
    On Error Resume Next

    Set objCmd = Server.CreateObject("ADODB.Command")
    Set objCmd.ActiveConnection = objConn
    objCmd.CommandType = 1  ' adCmdText

    ' Consulta DELETE con parmetro
    objCmd.CommandText = "DELETE FROM TBL_SONG WHERE ID_SONG = ?"

    ' Parmetro: ID_SONG (int -> adInteger=3, Input=1, Size=4)
    Dim paramDelId
    Set paramDelId = objCmd.CreateParameter("ID_SONG", 3, 1, 4, intSongId)
    objCmd.Parameters.Append paramDelId

    objCmd.Execute

    If Err.Number <> 0 Then
        Response.Write "<div class='error-msg'>Error al eliminar: " & Server.HTMLEncode(Err.Description) & "</div>"
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
