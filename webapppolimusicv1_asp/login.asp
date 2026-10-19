<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' login.asp
'--------------------------------------------------------------------------
' Pgina de inicio de sesin.
' - Muestra formulario de usuario y contrasea.
' - Valida contra TBL_USER con consulta PARAMETRIZADA (ADODB.Command).
' - Si es correcto: guarda Session("Username"), Session("UserType"),
'   Session("UserId") y redirige a songs.asp.
' - Si es incorrecto: muestra mensaje de error en la misma pgina.
'==========================================================================
%>
<!--#include file="includes/conexion.asp"-->
<%
Response.Charset = "UTF-8"

Dim strMensaje
strMensaje = ""

'--- Si ya hay sesin, ir directo a songs.asp ---
If Session("Username") <> "" Then
    Response.Redirect "songs.asp"
    Response.End
End If

'--- Procesar el formulario cuando se enva por POST ---
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

    Dim strUsername, strPassword
    strUsername = Trim(Request.Form("username"))
    strPassword = Trim(Request.Form("password"))

    '--- Validar que no estn vacos ---
    If strUsername = "" Or strPassword = "" Then
        strMensaje = "Por favor ingresa usuario y contrasea."
    Else
        '--- Consulta parametrizada con ADODB.Command ---
        Dim objConn, objCmd, objRS
        Dim blnLoginOK

        Set objConn = AbrirConexion()
        blnLoginOK = False

        If Not (objConn Is Nothing) Then
            On Error Resume Next

            Set objCmd = Server.CreateObject("ADODB.Command")
            Set objCmd.ActiveConnection = objConn

            ' Consulta con parmetros (?) - evita SQL Injection
            objCmd.CommandText = _
                "SELECT ID_USER, USERNAME, PASSWORD, USER_TYPE " & _
                "FROM TBL_USER " & _
                "WHERE USERNAME = ? AND PASSWORD = ?"
            objCmd.CommandType = 1  ' adCmdText

            ' Parmetro 1: USERNAME (varchar(50) -> adVarChar = 200)
            Dim paramUser
            Set paramUser = objCmd.CreateParameter("USERNAME", 200, 1, 50, strUsername)
            objCmd.Parameters.Append paramUser

            ' Parmetro 2: PASSWORD (varchar(50) -> adVarChar = 200)
            Dim paramPass
            Set paramPass = objCmd.CreateParameter("PASSWORD", 200, 1, 50, strPassword)
            objCmd.Parameters.Append paramPass

            ' Ejecutar y obtener Recordset
            Set objRS = objCmd.Execute

            If Err.Number <> 0 Then
                strMensaje = "Error al consultar la base de datos: " & Server.HTMLEncode(Err.Description)
            ElseIf Not objRS.EOF Then
                '--- Login correcto ---
                blnLoginOK = True

                ' Guardar datos en sesin
                Session("UserId")   = CInt(objRS("ID_USER").Value)
                Session("Username") = CStr(objRS("USERNAME").Value)
                Session("UserType") = CInt(objRS("USER_TYPE").Value)

                ' Cerrar recordset
                objRS.Close
                Set objRS = Nothing
                Set objCmd = Nothing

                CerrarConexion objConn

                ' Redirigir a songs.asp
                Response.Redirect "songs.asp"
                Response.End
            Else
                strMensaje = "Usuario o contrasea incorrectos."
            End If

            ' Limpieza
            On Error Resume Next
            If Not (objRS Is Nothing) Then
                If objRS.State = 1 Then objRS.Close
                Set objRS = Nothing
            End If
            Set objCmd = Nothing
            On Error GoTo 0

            CerrarConexion objConn
        Else
            strMensaje = "No se pudo conectar a la base de datos."
        End If
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PoliMusic - Login</title>
    <link rel="stylesheet" href="css/site.css">
</head>
<body class="page-login">

    <div class="login-container">
        <div class="login-card">

            <!-- Logo / Ttulo -->
            <div class="login-header">
                <div class="login-icon">&#9835;</div>
                <h1>PoliMusic</h1>
                <p class="login-subtitle">Inicia sesin para continuar</p>
            </div>

            <!-- Mensaje de error -->
            <% If strMensaje <> "" Then %>
            <div class="alert alert-error">
                <span class="alert-icon">&#9888;</span>
                <span><%= Server.HTMLEncode(strMensaje) %></span>
            </div>
            <% End If %>

            <!-- Formulario -->
            <form method="post" action="login.asp" class="login-form">
                <div class="form-group">
                    <label for="username">Usuario</label>
                    <input type="text"
                           id="username"
                           name="username"
                           placeholder="Ingresa tu usuario"
                           required
                           autocomplete="username"
                           value="">
                </div>

                <div class="form-group">
                    <label for="password">Contrasea</label>
                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="Ingresa tu contrasea"
                           required
                           autocomplete="current-password">
                </div>

                <button type="submit" class="btn btn-primary btn-full">
                    Iniciar Sesin
                </button>
            </form>

            <!-- Credenciales de prueba -->
            <div class="login-hint">
                <p><strong>Usuarios de prueba:</strong></p>
                <p><code>userAdmin</code> / <code>12345678</code> &mdash; Administrador</p>
                <p><code>userNormal</code> / <code>12345678</code> &mdash; Usuario normal</p>
            </div>

        </div>
    </div>

</body>
</html>
