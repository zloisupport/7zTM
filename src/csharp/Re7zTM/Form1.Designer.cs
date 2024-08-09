namespace Re7zTM
{
    partial class Form1
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.grboxPreviw = new System.Windows.Forms.GroupBox();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.grbxTheme = new System.Windows.Forms.GroupBox();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.grbxInformation = new System.Windows.Forms.GroupBox();
            this.txtBoxUrl = new System.Windows.Forms.TextBox();
            this.txtBoxAuthor = new System.Windows.Forms.TextBox();
            this.txtBoxLicense = new System.Windows.Forms.TextBox();
            this.txtBoxName = new System.Windows.Forms.TextBox();
            this.lblThemeUrl = new System.Windows.Forms.Label();
            this.lblThemeAuthor = new System.Windows.Forms.Label();
            this.lblThemeName = new System.Windows.Forms.Label();
            this.lblLicense = new System.Windows.Forms.Label();
            this.btnActivate = new System.Windows.Forms.Button();
            this.btnRun7z = new System.Windows.Forms.Button();
            this.rbtnToolbar = new System.Windows.Forms.RadioButton();
            this.rbtnFileType = new System.Windows.Forms.RadioButton();
            this.btnExit = new System.Windows.Forms.Button();
            this.grboxPreviw.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.grbxTheme.SuspendLayout();
            this.grbxInformation.SuspendLayout();
            this.SuspendLayout();
            // 
            // grboxPreviw
            // 
            this.grboxPreviw.Controls.Add(this.pictureBox1);
            this.grboxPreviw.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grboxPreviw.Location = new System.Drawing.Point(12, 12);
            this.grboxPreviw.Name = "grboxPreviw";
            this.grboxPreviw.Size = new System.Drawing.Size(492, 334);
            this.grboxPreviw.TabIndex = 0;
            this.grboxPreviw.TabStop = false;
            this.grboxPreviw.Text = "Preview";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::Re7zTM.Properties.Resources.thumb;
            this.pictureBox1.Location = new System.Drawing.Point(6, 20);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(480, 291);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 0;
            this.pictureBox1.TabStop = false;
            // 
            // grbxTheme
            // 
            this.grbxTheme.Controls.Add(this.listBox1);
            this.grbxTheme.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grbxTheme.Location = new System.Drawing.Point(510, 12);
            this.grbxTheme.Name = "grbxTheme";
            this.grbxTheme.Size = new System.Drawing.Size(140, 288);
            this.grbxTheme.TabIndex = 1;
            this.grbxTheme.TabStop = false;
            this.grbxTheme.Text = "Themes";
            // 
            // listBox1
            // 
            this.listBox1.FormattingEnabled = true;
            this.listBox1.ItemHeight = 20;
            this.listBox1.Location = new System.Drawing.Point(7, 20);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(127, 264);
            this.listBox1.TabIndex = 0;
            this.listBox1.SelectedIndexChanged += new System.EventHandler(this.listBox1_SelectedIndexChanged);
            // 
            // grbxInformation
            // 
            this.grbxInformation.Controls.Add(this.txtBoxUrl);
            this.grbxInformation.Controls.Add(this.txtBoxAuthor);
            this.grbxInformation.Controls.Add(this.txtBoxLicense);
            this.grbxInformation.Controls.Add(this.txtBoxName);
            this.grbxInformation.Controls.Add(this.lblThemeUrl);
            this.grbxInformation.Controls.Add(this.lblThemeAuthor);
            this.grbxInformation.Controls.Add(this.lblThemeName);
            this.grbxInformation.Controls.Add(this.lblLicense);
            this.grbxInformation.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grbxInformation.Location = new System.Drawing.Point(12, 352);
            this.grbxInformation.Name = "grbxInformation";
            this.grbxInformation.Size = new System.Drawing.Size(492, 140);
            this.grbxInformation.TabIndex = 2;
            this.grbxInformation.TabStop = false;
            this.grbxInformation.Text = "Information";
            // 
            // txtBoxUrl
            // 
            this.txtBoxUrl.Location = new System.Drawing.Point(312, 98);
            this.txtBoxUrl.Name = "txtBoxUrl";
            this.txtBoxUrl.ReadOnly = true;
            this.txtBoxUrl.Size = new System.Drawing.Size(174, 26);
            this.txtBoxUrl.TabIndex = 7;
            // 
            // txtBoxAuthor
            // 
            this.txtBoxAuthor.Location = new System.Drawing.Point(29, 98);
            this.txtBoxAuthor.Name = "txtBoxAuthor";
            this.txtBoxAuthor.ReadOnly = true;
            this.txtBoxAuthor.Size = new System.Drawing.Size(152, 26);
            this.txtBoxAuthor.TabIndex = 6;
            // 
            // txtBoxLicense
            // 
            this.txtBoxLicense.Location = new System.Drawing.Point(312, 46);
            this.txtBoxLicense.Name = "txtBoxLicense";
            this.txtBoxLicense.ReadOnly = true;
            this.txtBoxLicense.Size = new System.Drawing.Size(174, 26);
            this.txtBoxLicense.TabIndex = 5;
            // 
            // txtBoxName
            // 
            this.txtBoxName.Location = new System.Drawing.Point(29, 46);
            this.txtBoxName.Name = "txtBoxName";
            this.txtBoxName.ReadOnly = true;
            this.txtBoxName.Size = new System.Drawing.Size(152, 26);
            this.txtBoxName.TabIndex = 4;
            // 
            // lblThemeUrl
            // 
            this.lblThemeUrl.AutoSize = true;
            this.lblThemeUrl.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblThemeUrl.Location = new System.Drawing.Point(308, 75);
            this.lblThemeUrl.Name = "lblThemeUrl";
            this.lblThemeUrl.Size = new System.Drawing.Size(33, 20);
            this.lblThemeUrl.TabIndex = 3;
            this.lblThemeUrl.Text = "Url:";
            // 
            // lblThemeAuthor
            // 
            this.lblThemeAuthor.AutoSize = true;
            this.lblThemeAuthor.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblThemeAuthor.Location = new System.Drawing.Point(26, 75);
            this.lblThemeAuthor.Name = "lblThemeAuthor";
            this.lblThemeAuthor.Size = new System.Drawing.Size(61, 20);
            this.lblThemeAuthor.TabIndex = 2;
            this.lblThemeAuthor.Text = "Author:";
            // 
            // lblThemeName
            // 
            this.lblThemeName.AutoSize = true;
            this.lblThemeName.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblThemeName.Location = new System.Drawing.Point(26, 23);
            this.lblThemeName.Name = "lblThemeName";
            this.lblThemeName.Size = new System.Drawing.Size(55, 20);
            this.lblThemeName.TabIndex = 1;
            this.lblThemeName.Text = "Name:";
            // 
            // lblLicense
            // 
            this.lblLicense.AutoSize = true;
            this.lblLicense.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblLicense.Location = new System.Drawing.Point(308, 23);
            this.lblLicense.Name = "lblLicense";
            this.lblLicense.Size = new System.Drawing.Size(68, 20);
            this.lblLicense.TabIndex = 0;
            this.lblLicense.Text = "License:";
            // 
            // btnActivate
            // 
            this.btnActivate.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnActivate.Location = new System.Drawing.Point(510, 359);
            this.btnActivate.Name = "btnActivate";
            this.btnActivate.Size = new System.Drawing.Size(140, 28);
            this.btnActivate.TabIndex = 3;
            this.btnActivate.Text = "Activate";
            this.btnActivate.UseVisualStyleBackColor = true;
            this.btnActivate.Click += new System.EventHandler(this.button1_Click);
            // 
            // btnRun7z
            // 
            this.btnRun7z.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRun7z.Location = new System.Drawing.Point(510, 398);
            this.btnRun7z.Name = "btnRun7z";
            this.btnRun7z.Size = new System.Drawing.Size(140, 30);
            this.btnRun7z.TabIndex = 4;
            this.btnRun7z.Text = "Run 7z";
            this.btnRun7z.UseVisualStyleBackColor = true;
            this.btnRun7z.Click += new System.EventHandler(this.button2_Click);
            // 
            // rbtnToolbar
            // 
            this.rbtnToolbar.AutoSize = true;
            this.rbtnToolbar.Checked = true;
            this.rbtnToolbar.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnToolbar.Location = new System.Drawing.Point(510, 306);
            this.rbtnToolbar.Name = "rbtnToolbar";
            this.rbtnToolbar.Size = new System.Drawing.Size(80, 24);
            this.rbtnToolbar.TabIndex = 7;
            this.rbtnToolbar.TabStop = true;
            this.rbtnToolbar.Text = "Toolbar";
            this.rbtnToolbar.UseVisualStyleBackColor = true;
            this.rbtnToolbar.CheckedChanged += new System.EventHandler(this.radioButton1_CheckedChanged);
            // 
            // rbtnFileType
            // 
            this.rbtnFileType.AutoSize = true;
            this.rbtnFileType.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnFileType.Location = new System.Drawing.Point(510, 329);
            this.rbtnFileType.Name = "rbtnFileType";
            this.rbtnFileType.Size = new System.Drawing.Size(82, 24);
            this.rbtnFileType.TabIndex = 8;
            this.rbtnFileType.Text = "Filetype";
            this.rbtnFileType.UseVisualStyleBackColor = true;
            this.rbtnFileType.CheckedChanged += new System.EventHandler(this.radioButton2_CheckedChanged);
            // 
            // btnExit
            // 
            this.btnExit.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnExit.Location = new System.Drawing.Point(510, 463);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(140, 29);
            this.btnExit.TabIndex = 9;
            this.btnExit.Text = "Exit";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(660, 504);
            this.Controls.Add(this.btnExit);
            this.Controls.Add(this.rbtnFileType);
            this.Controls.Add(this.rbtnToolbar);
            this.Controls.Add(this.btnRun7z);
            this.Controls.Add(this.btnActivate);
            this.Controls.Add(this.grbxInformation);
            this.Controls.Add(this.grbxTheme);
            this.Controls.Add(this.grboxPreviw);
            this.HelpButton = true;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.Text = "Re7TM";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.grboxPreviw.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.grbxTheme.ResumeLayout(false);
            this.grbxInformation.ResumeLayout(false);
            this.grbxInformation.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox grboxPreviw;
        private System.Windows.Forms.GroupBox grbxTheme;
        private System.Windows.Forms.GroupBox grbxInformation;
        private System.Windows.Forms.Button btnActivate;
        private System.Windows.Forms.Button btnRun7z;
        private System.Windows.Forms.RadioButton rbtnToolbar;
        private System.Windows.Forms.RadioButton rbtnFileType;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.ListBox listBox1;
        private System.Windows.Forms.TextBox txtBoxUrl;
        private System.Windows.Forms.TextBox txtBoxAuthor;
        private System.Windows.Forms.TextBox txtBoxLicense;
        private System.Windows.Forms.TextBox txtBoxName;
        private System.Windows.Forms.Label lblThemeUrl;
        private System.Windows.Forms.Label lblThemeAuthor;
        private System.Windows.Forms.Label lblThemeName;
        private System.Windows.Forms.Label lblLicense;
    }
}

