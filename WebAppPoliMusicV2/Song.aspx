<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>PoliMusic - Song List</title>
    <link href="css/site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function getRow(audio) {
            return audio.parentNode.parentNode;
        }

        // Plays one song at a time and adds one play the first time a song starts.
        function registerPlay(audio, idSong) {
            var players = document.getElementsByTagName("audio");
            for (var i = 0; i < players.length; i++) {
                if (players[i] !== audio) {
                    players[i].pause();
                }
            }
            getRow(audio).className = "playing";
            if (audio.getAttribute("data-counted")) {
                return;
            }
            audio.setAttribute("data-counted", "true");

            var request = new XMLHttpRequest();
            request.open("POST", "Song.aspx", true);
            request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            request.onload = function () {
                if (request.status === 200 && request.responseText === "1") {
                    var plays = getRow(audio).getElementsByClassName("plays")[0];
                    plays.innerHTML = (parseInt(plays.innerHTML, 10) || 0) + 1;
                }
            };
            request.send("playSongId=" + idSong);
        }

        function stopPlay(audio) {
            getRow(audio).className = "";
        }

        function markUnavailable(audio) {
            getRow(audio).className = "unavailable";
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="topbar">
            <h1 class="brand">Poli<span>Music</span></h1>
            <div class="user-info">
                <span class="welcome">Welcome</span>
                <asp:Label ID="lblUserName" runat="server" CssClass="user-name"></asp:Label>
                <asp:Image ID="imgUser" runat="server" AlternateText="User photo" />
                <asp:HyperLink ID="lnkLogout" runat="server" CssClass="logout" NavigateUrl="~/Logout.aspx">Logout</asp:HyperLink>
            </div>
        </div>

        <div class="content">
            <div class="toolbar">
                <h2>Song list</h2>
                <asp:Panel ID="pnlSearch" runat="server" CssClass="search" DefaultButton="btnSearch">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="input" placeholder="Search song by name..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn" OnClick="BtnSearch_Click" />
                    <asp:Button ID="btnShowAll" runat="server" Text="Show All" CssClass="btn btn-secondary" OnClick="BtnShowAll_Click" />
                </asp:Panel>
            </div>

            <div class="table-card">
                <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="False"
                    CssClass="songs" GridLines="None" EmptyDataText="No songs found."
                    AllowPaging="True" PageSize="10"
                    OnPageIndexChanging="GvSongs_PageIndexChanging">
                    <PagerStyle CssClass="pager" />
                    <EmptyDataRowStyle CssClass="empty" />
                    <Columns>
                        <asp:BoundField DataField="ID_SONG" HeaderText="ID Canci&oacute;n"
                            HeaderStyle-CssClass="col-id" ItemStyle-CssClass="col-id" />
                        <asp:BoundField DataField="SONG_NAME" HeaderText="Nombre"
                            ItemStyle-CssClass="col-name" />
                        <asp:BoundField DataField="SONG_PATH" HeaderText="Ruta"
                            HeaderStyle-CssClass="col-path" ItemStyle-CssClass="col-path" />
                        <asp:TemplateField HeaderText="Reproducciones"
                            HeaderStyle-CssClass="col-plays" ItemStyle-CssClass="col-plays">
                            <ItemTemplate>
                                <span class="plays"><%# Eval("PLAYS") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Reproducir"
                            HeaderStyle-CssClass="col-player" ItemStyle-CssClass="col-player">
                            <ItemTemplate>
                                <audio controls="controls" preload="metadata"
                                    aria-label="<%# Server.HtmlEncode(Eval("SONG_NAME").ToString()) %>"
                                    src="<%# GetSongUrl(Eval("SONG_PATH").ToString()) %>"
                                    onplay="registerPlay(this, <%# Eval("ID_SONG") %>);"
                                    onpause="stopPlay(this);"
                                    onended="this.removeAttribute('data-counted');"
                                    onerror="markUnavailable(this);"></audio>
                                <span class="unavailable-note">Archivo no disponible</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
