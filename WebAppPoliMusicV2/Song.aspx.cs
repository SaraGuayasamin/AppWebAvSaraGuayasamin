using System;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Form["playSongId"] != null)
            {
                RegisterPlay(Request.Form["playSongId"]);
                return;
            }
            if (!Page.IsPostBack)
            {
                Entities.User user = (Entities.User)Session[Util.Constants.USER];
                if (user == null)
                {
                    Response.Redirect("Logout.aspx", true);
                }
                lblUserName.Text = user.UserName;
                imgUser.ImageUrl = user.Photo != string.Empty ? user.Photo : "~/userImages/default.jpg";
                LoadSongs();
            }
        }

        private void RegisterPlay(string strIdSong)
        {
            int idSong;
            int rows = 0;
            if (int.TryParse(strIdSong, out idSong))
            {
                rows = new BLL.Song(strConnString).IncrementPlays(idSong);
            }
            Response.Write(rows);
            Response.End();
        }

        protected string GetSongUrl(string songPath)
        {
            string url = songPath.StartsWith("~") ? ResolveUrl(songPath) : songPath;
            return Server.HtmlEncode(url);
        }

        private void LoadSongs()
        {
            string searchText = txtSearch.Text.Trim();
            DataTable dtSong = searchText != string.Empty
                ? new BLL.Song(strConnString).SearchByName(searchText)
                : new BLL.Song(strConnString).Read();
            gvSongs.DataSource = dtSong;
            gvSongs.DataBind();
        }

        protected void BtnSearch_Click(object sender, EventArgs e)
        {
            gvSongs.PageIndex = 0;
            LoadSongs();
        }

        protected void BtnShowAll_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            gvSongs.PageIndex = 0;
            LoadSongs();
        }

        protected void GvSongs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvSongs.PageIndex = e.NewPageIndex;
            LoadSongs();
        }
    }
}
