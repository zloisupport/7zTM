using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Threading;
using System.Windows.Forms;
using Timer = System.Windows.Forms.Timer;

namespace Re7zTM
{

    enum ElementType
    {
        toolbar,
        filetype
    }
    public partial class Form1 : Form
    {
        ResourceHelperDll resourceHelperDll;

        public static Dictionary<int, string> Toolbars = new Dictionary<int, string>();

        public Dictionary<int, string> FileTypes = new Dictionary<int, string>();

        public Form1()
        {
            InitializeComponent();


            string currentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            string toolbarDir = Path.Combine(currentDir);
            string fileDir = Path.Combine(currentDir);
            if (!Directory.Exists(toolbarDir))
            {
                MessageBox.Show("");
            }
            else
            {
                GetDirectories(toolbarDir+"\\", ElementType.toolbar);
            }
            if (!Directory.Exists(fileDir))
            {
                MessageBox.Show("");
            }
            else
            {
                GetDirectories(fileDir + "\\", ElementType.filetype);
            }

            FindPath findPath = new FindPath();
            string path7z = findPath.Get7zPath();
            resourceHelperDll = new ResourceHelperDll(path7z);
        }

        private ElementType objType = ElementType.toolbar;
        private string selectedTheme = string.Empty;

        private void Form1_Load(object sender, EventArgs e)
        {
            SetListBoxItems(Toolbars);
            objType = ElementType.toolbar;
        }


        private void GetDirectories(string folder, ElementType objtype)
        {
            int i = 1;
            DirectoryInfo directoryInfo = new DirectoryInfo(folder + objtype);
            foreach (var item in directoryInfo.GetDirectories())
            {
                i++;
                if (objtype == ElementType.toolbar)
                    Toolbars.Add(i, item.Name.ToString());

                else if (objtype == ElementType.filetype)
                    FileTypes.Add(i, item.Name.ToString());
            }
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            var selectedObj = listBox1.Items[listBox1.SelectedIndex];
            string previewImg = objType + "\\" + selectedObj + "\\preview.jpg";

            if (File.Exists(previewImg))
            {
                pictureBox1.ImageLocation = previewImg;
            }

            selectedTheme = Convert.ToString(selectedObj);
            string selectedThemeIni = objType + "\\" + selectedObj + "\\theme.ini";
            if (File.Exists(selectedThemeIni))
            {
                IniParser iniParser = new IniParser(selectedThemeIni);
                txtBoxName.Text = iniParser.GetPrivateString("Theme", "name");
                txtBoxAuthor.Text = iniParser.GetPrivateString("Theme", "author");
                txtBoxLicense.Text = iniParser.GetPrivateString("Theme", "licence");
                txtBoxUrl.Text = iniParser.GetPrivateString("Theme", "website");
            }
        }

        private void radioButton2_CheckedChanged(object sender, EventArgs e)
        {
            clearTextBox();
            SetListBoxItems(FileTypes);
            objType = ElementType.filetype;
            pictureBox1.Image = Re7zTM.Properties.Resources.thumb;
        }

        private void clearTextBox()
        {
            txtBoxName.Text = string.Empty;
            txtBoxAuthor.Text = string.Empty;
            txtBoxLicense.Text = string.Empty;
            txtBoxUrl.Text = string.Empty;

        }

        private void radioButton1_CheckedChanged(object sender, EventArgs e)
        {
            clearTextBox();
            SetListBoxItems(Toolbars);
            objType = ElementType.toolbar;
            pictureBox1.Image = Re7zTM.Properties.Resources.thumb;
        }


        private void SetListBoxItems(Dictionary<int, string> type)
        {
            listBox1.Items.Clear();

            foreach (var item in type)
            {
                listBox1.Items.Add(item.Value);
            }
        }


        private void button1_Click(object sender, EventArgs e)
        {
            btnActivate.Enabled = false;
            if (objType == ElementType.toolbar)
                resourceHelperDll.ChangeBitmap(objType, selectedTheme);
            else if (objType == ElementType.filetype)
                resourceHelperDll.ReplaceIcon("ss", selectedTheme);
            btnActivate.Enabled = true;
        }



        private void button2_Click(object sender, EventArgs e)
        {
            Process process = new Process();
            process.StartInfo.FileName = "7zFM.exe";
            process.Start();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}
