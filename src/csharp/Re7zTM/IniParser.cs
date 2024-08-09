using System.Runtime.InteropServices;
using System.Text;

namespace Re7zTM
{
    class IniParser
    {

        [DllImport("kernel32.dll", EntryPoint = "GetPrivateProfileString")]
        private static extern int GetPrivateString(string section, string key, string def, StringBuilder buffer, int size, string path);

        [DllImport("kernel32.dll", EntryPoint = "WritePrivateProfileString")]
        private static extern int WritePrivateString(string section, string key, string str, string path);

        private const int SIZE = 1024;
        private string path = null;
        public IniParser(string apath)
        {
            path = apath;
        }
        public IniParser() : this("") { }

        public string GetPrivateString(string Section, string Key)
        {
            StringBuilder buffer = new StringBuilder(SIZE);
            GetPrivateString(Section, Key, null, buffer, SIZE, path);
            return buffer.ToString();
        }
        public void WritePrivateString(string aSection, string aKey, string aValue)
        {
            WritePrivateString(aSection, aKey, aValue, path);
        }
    }
}
