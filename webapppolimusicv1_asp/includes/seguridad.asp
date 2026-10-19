<%
'==========================================================================
' includes/seguridad.asp
'--------------------------------------------------------------------------
' Archivo de inclusin para control de acceso por sesiones.
'
' Incluir despus de conexion.asp:
'   <!--#include file="includes/conexion.asp"-->
'   <!--#include file="includes/seguridad.asp"-->
'==========================================================================

'---------------------------------------------------------------------------
' Subrutina: RequerirSesion
'   Verifica que exista una sesin iniciada.
'   Si Session("Username") est vaco, redirige a login.asp.
'   Se llama al inicio de cada pgina protegida.
'---------------------------------------------------------------------------
Sub RequerirSesion()
    If Session("Username") = "" Or IsNull(Session("Username")) Then
        Response.Redirect "login.asp"
        Response.End
    End If
End Sub

'---------------------------------------------------------------------------
' Funcin: EsAdmin
'   Devuelve True si el usuario logueado es administrador (USER_TYPE = 1).
'   Devuelve False si es usuario normal (USER_TYPE = 0) o no hay sesin.
'---------------------------------------------------------------------------
Function EsAdmin()
    If Session("UserType") = "1" Then
        EsAdmin = True
    Else
        EsAdmin = False
    End If
End Function

'---------------------------------------------------------------------------
' Subrutina: RequerirAdmin
'   Verifica que el usuario sea admin. Si no lo es, redirige a songs.asp.
'   Se usa en song_save.asp y song_delete.asp para validacin en servidor.
'   Esto asegura que aunque un usuario normal llame directamente la URL,
'   no podr ejecutar la accin CRUD.
'---------------------------------------------------------------------------
Sub RequerirAdmin()
    If Not EsAdmin() Then
        Response.Redirect "songs.asp"
        Response.End
    End If
End Sub
%>
