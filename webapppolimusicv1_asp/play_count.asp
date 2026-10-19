<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' play_count.asp
'--------------------------------------------------------------------------
' Incrementa el contador PLAYS de una cancin.
' - Es llamada va JavaScript fetch() desde songs.asp cuando el usuario
'   presiona el botn Play de una cancin.
' - Recibe el ID por QueryString (?id=...).
' - Retorna JSON con el nuevo conteo para que el JS actualice la tabla
'   sin recargar la pgina.
'==========================================================================
%>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "UTF-8"
Response.ContentType = "application/json"

'--- Verificar que haya sesin (no requiere admin, solo sesin) ---
RequerirSesion()

'--- Leer ID de la cancin ---
Dim intSongId
intSongId = 0

If Request.QueryString("id") <> "" And IsNumeric(Request.QueryString("id")) Then
    intSongId = CInt(Request.QueryString("id"))
End If

If intSongId <= 0 Then
    Response.Write "{""status"":""error"",""message"":""ID invlido""}"
    Response.End
End If

'--- Conectar y ejecutar UPDATE parametrizado ---
Dim objConn, objCmd
Set objConn = AbrirConexion()

If Not (objConn Is Nothing) Then
    On Error Resume Next

    Set objCmd = Server.CreateObject("ADODB.Command")
    Set objCmd.ActiveConnection = objConn
    objCmd.CommandType = 1  ' adCmdText

    ' Incrementar PLAYS en 1
    objCmd.CommandText = "UPDATE TBL_SONG SET PLAYS = PLAYS + 1 WHERE ID_SONG = ?"

    ' Parmetro: ID_SONG (int -> adInteger=3, Input=1, Size=4)
    Dim paramId
    Set paramId = objCmd.CreateParameter("ID_SONG", 3, 1, 4, intSongId)
    objCmd.Parameters.Append paramId

    objCmd.Execute

    If Err.Number = 0 Then
        ' Leer el nuevo valor de PLAYS para devolverlo en el JSON
        Dim rsCount, cmdCount
        Set cmdCount = Server.CreateObject("ADODB.Command")
        Set cmdCount.ActiveConnection = objConn
        cmdCount.CommandType = 1
        cmdCount.CommandText = "SELECT PLAYS FROM TBL_SONG WHERE ID_SONG = ?"

        Dim paramCountId
        Set paramCountId = cmdCount.CreateParameter("ID_SONG", 3, 1, 4, intSongId)
        cmdCount.Parameters.Append paramCountId

        Set rsCount = cmdCount.Execute

        Dim intNewPlays
        If Not rsCount.EOF Then
            intNewPlays = CInt(rsCount("PLAYS").Value)
        Else
            intNewPlays = 0
        End If

        rsCount.Close
        Set rsCount = Nothing
        Set cmdCount = Nothing

        ' Retornar JSON con el nuevo conteo
        Response.Write "{""status"":""ok"",""plays"":" & intNewPlays & "}"
    Else
        Response.Write "{""status"":""error"",""message"":""" & Replace(Err.Description, """", "\""") & """}"
    End If

    Set objCmd = Nothing
    On Error GoTo 0

    CerrarConexion objConn
Else
    Response.Write "{""status"":""error"",""message"":""Sin conexin a BD""}"
End If
%>
