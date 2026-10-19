<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' index.asp
'--------------------------------------------------------------------------
' Pgina de inicio: simplemente redirige a login.asp o songs.asp
' segn si hay sesin o no.
'==========================================================================
%>
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "UTF-8"

If Session("Username") <> "" Then
    Response.Redirect "songs.asp"
Else
    Response.Redirect "login.asp"
End If
Response.End
%>
