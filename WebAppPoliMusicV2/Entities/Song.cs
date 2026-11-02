using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    public class Song
    {
        public Song()
        {
        }
        public Song(int id, string songName, string songPath, int plays)
        {
            Id = id;
            SongName = songName;
            SongPath = songPath;
            Plays = plays;
        }
        public int Id { get; set; }
        public string SongName { get; set; }
        public string SongPath { get; set; }
        public int Plays { get; set; }
    }
}
