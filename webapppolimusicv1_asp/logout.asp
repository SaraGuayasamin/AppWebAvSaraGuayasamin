<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
'==========================================================================
' logout.asp
'--------------------------------------------------------------------------
' Cierra la sesin del usuario y redirige al login.
'
' Session.Abandon:
'   - Elimina todos los datos almacenados en la sesin actual.
'   - El SessionID se descarta (IIS genera uno nuevo en la prxima visita).
'   - Es la forma correcta de "cerrar sesin" en ASP clsico.
'==========================================================================

'--- Limpiar variables de sesin explcitamente ---
Session.Contents.RemoveAll()

'--- Abandonar la sesin completamente ---
Session.Abandon()

'--- Redirigir al login ---
Response.Redirect "login.asp"
Response.End
%>
