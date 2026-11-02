<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebAppPoliMusicV2.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Login - PoliMusic</title>
    <link href="css/site.css" rel="stylesheet" type="text/css" />
</head>
<body class="login-page">
    <div class="login-card">
        <div class="login-brand">
            <h1 class="brand">Poli<span>Music</span></h1>
            <div class="equalizer" aria-hidden="true">
                <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
            </div>
            <p>Your songs, one click away.</p>
        </div>
        <form id="formLogin" runat="server" class="login-form">
            <h2>Login</h2>
            <div class="field">
                <label for="txtLogin">Username</label>
                <asp:TextBox ID="txtLogin" runat="server" CssClass="input" placeholder="Username"></asp:TextBox>
            </div>
            <div class="field">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" placeholder="Password"></asp:TextBox>
            </div>
            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn" OnClick="BtnLogin_Click" />
            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            <p class="login-enroll">
                <asp:LinkButton ID="LinkButtonNewUser" runat="server" OnClick="LinkButtonNewUser_Click">Enroll new user</asp:LinkButton>
            </p>
        </form>
    </div>
</body>
</html>
