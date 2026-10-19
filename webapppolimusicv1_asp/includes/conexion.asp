<%
'==========================================================================
' includes/conexion.asp
'--------------------------------------------------------------------------
' Archivo de inclusin (include) que centraliza la conexin a SQL Server.
' Se reutiliza en todas las pginas .asp con:
'   <!--#include file="includes/conexion.asp"-->
'
' Proveedor: Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL)
'   - Es el driver moderno recomendado por Microsoft para ADO clsico.
'   - Soporta TrustServerCertificate=yes (necesario si el certificado
'     TLS de SQL Server es auto-firmado, como ocurre en Docker).
'   - Requiere instalar "Microsoft Command Line Utilities for SQL Server"
'     (que incluye MSOLEDBSQL). Descarga:
'     https://learn.microsoft.com/sql/connect/oledb/download-oledb-driver-for-sql-server
'
' Diferencia 32 vs 64 bits:
'   - Si el Application Pool de IIS tiene "Habilitar aplicaciones de 32 bits"
'     = True, el proceso worker (w3wp.exe) corre en 32 bits y necesita
'     la versin 32-bit de MSOLEDBSQL.
'   - Si est en False (64 bits), necesita la versin 64-bit.
'   - Por defecto en Windows 64-bit, el pool corre en 64 bits, as que
'     instala la versin x64 del driver.
'==========================================================================

'--- Cadena de conexin global ---
' Se declara aqu para que todas las funciones la vean.
Dim CONN_STRING
   CONN_STRING = _
       "Provider=MSOLEDBSQL;" & _
       "Data Source=localhost,14333;" & _
       "Initial Catalog=BDD_PoliMusic;" & _
       "User ID=sa;" & _
       "Password=Politecnica1;" & _
       "Trust Server Certificate=True;"
'---------------------------------------------------------------------------
' Funcin: AbrirConexion
'   Crea y abre un objeto ADODB.Connection.
'   Retorna el objeto connection ya abierto (Listo para usar).
'   En caso de error, muestra mensaje amigable y retorna Nothing.
'---------------------------------------------------------------------------
Function AbrirConexion()
    Dim objConn
    On Error Resume Next

    Set objConn = Server.CreateObject("ADODB.Connection")
    If Err.Number <> 0 Then
        Response.Write "<div class=""error-msg"">"
        Response.Write "<strong>Error:</strong> No se pudo crear el objeto Connection."
        Response.Write "<br>Detalles: " & Server.HTMLEncode(Err.Description)
        Response.Write "</div>"
        On Error GoTo 0
        Set AbrirConexion = Nothing
        Exit Function
    End If

    ' TimeOut de conexin: 15 segundos
    objConn.ConnectionTimeout = 15
    ' TimeOut de comando: 30 segundos
    objConn.CommandTimeout = 30

    objConn.Open CONN_STRING
    If Err.Number <> 0 Then
        Response.Write "<div class=""error-msg"">"
        Response.Write "<strong>Error de conexin a la base de datos:</strong>"
        Response.Write "<br>No se pudo conectar a SQL Server en localhost,14333."
        Response.Write "<br>Verifica que Docker est corriendo y el puerto sea correcto."
        Response.Write "<br>Detalles: " & Server.HTMLEncode(Err.Description)
        Response.Write "</div>"
        On Error GoTo 0
        Set AbrirConexion = Nothing
        Exit Function
    End If

    On Error GoTo 0
    Set AbrirConexion = objConn
End Function

'---------------------------------------------------------------------------
' Subrutina: CerrarConexion
'   Cierra y libera un objeto ADODB.Connection.
'   Recibe el objeto por referencia.
'---------------------------------------------------------------------------
Sub CerrarConexion(ByRef objConn)
    On Error Resume Next
    If Not (objConn Is Nothing) Then
        If objConn.State = 1 Then  ' 1 = adStateOpen
            objConn.Close
        End If
        Set objConn = Nothing
    End If
    On Error GoTo 0
End Sub
%>
