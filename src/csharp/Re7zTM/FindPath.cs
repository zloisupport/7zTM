using Microsoft.Win32;

namespace Re7zTM
{
    internal class FindPath
    {

        public string Get7zPath()
        {

            if (!string.IsNullOrEmpty(Get7zipRegPathHCU()))
            {
                return Get7zipRegPathHCU();
            }
            else if(!string.IsNullOrEmpty(Get7zipRegPathHLM())){
                return Get7zipRegPathHLM();
            }

            return string.Empty;
        }



        private string Get7zipRegPathHCU()
        {
            RegistryKey key = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\7-zip");
            if (key != null)
            {
                var value = key.GetValue("Path");
                if (value != null)
                {
                    return value.ToString();
                }
            }
            key.Close();
            return string.Empty;
        }

        private string Get7zipRegPathHLM()
        {
            RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\7-zip");
            if (key != null)
            {
                var value = key.GetValue("Path");
                if (value != null)
                {
                    return value.ToString();
                }
            }
            key.Close();
            return string.Empty;
        }

    }
}
