# Project Memory - PoliMusic ASP Classic

## Project Overview
- **Type**: University assignment for "Aplicaciones Web Avanzadas"
- **Technology**: ASP Classic (VBScript + ADO, IIS), SQL Server 2025 in Docker
- **Student**: Sara Guayasamin
- **Folder**: webapppolimusicv1_asp within AppWebAvSaraGuayasamin GitHub repo

## Database
- Server: localhost,14333 (Docker)
- Database: BDD_PoliMusic
- User: sa / Password: Politecnica1
- Provider: MSOLEDBSQL with Trust Server Certificate=True
- Connection string format: Provider=MSOLEDBSQL;Data Source=localhost,14333;Initial Catalog=BDD_PoliMusic;User ID=sa;Password=Politecnica1;Trust Server Certificate=True;
- Tables: TBL_USER (userAdmin/userNormal, both with password 12345678), TBL_SONG
- USER_TYPE: 0=normal, 1=admin; passwords in plaintext

## Design
- Color palette: "Sunset Vinyl" - dark background (#0F0E1A), coral (#E8556B), amber (#F5B945), turquoise (#4A9DBA)

## Technical Conventions
- All .asp files: <%@ Language="VBScript" CodePage="65001" %> + Option Explicit
- Response.Charset = "UTF-8" for proper accents
- ADODB.Command + CreateParameter for all user-input queries (SQL injection prevention)
- Server.HTMLEncode when displaying database content
- On Error Resume Next + Err.Number checking
- Always close Recordsets and Connections
- SONG_PATH stores "~/songFiles/..." which must be Replace'd to "songFiles/..." for ASP (no ~ support)
