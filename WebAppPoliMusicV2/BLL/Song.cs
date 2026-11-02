using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }
        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }
        public DataTable GetSongById(int idSong)
        {
            return new DAL.Song(strConnectionString).GetSongById(idSong);
        }
        public DataTable SearchByName(string songName)
        {
            return new DAL.Song(strConnectionString).SearchByName(songName);
        }
        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }
        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }
        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }
        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }
    }
}
