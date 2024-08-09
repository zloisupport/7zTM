using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;
using static Re7zTM.Form1;

namespace Re7zTM
{
    internal class ResourceHelperDll
    {
        public string _path7z { get; set; }

        public ResourceHelperDll(string path7z)
        {
            _path7z = path7z;
        }




        const uint RT_GROUP_ICON = 14;
        const uint RT_ICON = 3;
        public bool status = false;
        private delegate void LongRunningAction();
        /*      
                private DeviceIndependentBitmap _bitmap;
                private Gdi32.BITMAPFILEHEADER _header;
        */
        const uint RT_BITMAP = 2;

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        protected static extern IntPtr BeginUpdateResourceW(string pFileName, bool bDeleteExistingResources);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        protected static extern bool UpdateResourceW(IntPtr hUpdate, IntPtr lpType, IntPtr lpName, ushort wLanguage, byte[] lpData, UInt32 cbData);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        protected static extern bool EndUpdateResourceW(IntPtr hUpdate, bool fDiscard);

        private bool CheckFileWriteAccess(string file)
        {
            try
            {
                using (FileStream fs = File.Open(file, FileMode.Open, FileAccess.Write))
                {
                    return true;
                }
            }
            catch
            {
                MessageBox.Show("Access denied!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }

        public void ChangeBitmap()
        {

            string exePath = Path.Combine(_path7z, "7zFM.exe");
            if (!CheckFileWriteAccess(exePath)) return;
            string newBitmapPath = "100.bmp";

            if (!File.Exists(exePath))
            {
                Console.WriteLine("EXE file not found.");
                return;
            }

            if (!File.Exists(newBitmapPath))
            {
                Console.WriteLine("Bitmap file not found.");
                return;
            }


            BitmapFile bitmapFile = new BitmapFile(newBitmapPath);
            byte[] bitmapData = bitmapFile.Data;

            IntPtr hUpdate = BeginUpdateResourceW(exePath, false);
            if (hUpdate == IntPtr.Zero)
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            if (!UpdateResourceW(hUpdate, new IntPtr(RT_BITMAP), new IntPtr(150), 1033, bitmapData, (uint)bitmapData.Length))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            if (!EndUpdateResourceW(hUpdate, false))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }
        }

        private void ModifyBmpFile(int index, string bmp)
        {

            string exePath = Path.Combine(_path7z, "7zFM.exe");
            if (!CheckFileWriteAccess(exePath)) return;
            string newBitmapPath = bmp;

            if (!File.Exists(exePath))
            {
                Console.WriteLine("EXE file not found.");
                return;
            }

            if (!File.Exists(newBitmapPath))
            {
                Console.WriteLine("Bitmap file not found.");
                return;
            }


            BitmapFile bitmapFile = new BitmapFile(newBitmapPath);
            byte[] bitmapData = bitmapFile.Data;



            IntPtr hUpdate = BeginUpdateResourceW(exePath, false);
            if (hUpdate == IntPtr.Zero)
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            if (!UpdateResourceW(hUpdate, new IntPtr(RT_BITMAP), new IntPtr(index), 1033, bitmapData, (uint)bitmapData.Length))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            if (!EndUpdateResourceW(hUpdate, false))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }
        }




        public void ChangeBitmap(ElementType type, string theme, OperationCompletedHandler callback)
        {
            status = false;
            string exePath = Path.Combine(_path7z, "7zFM.exe");
            if (!CheckFileWriteAccess(exePath)) return;

            string[] bmps = { "Add.bmp", "Extract.bmp", "Test.bmp", "Copy.bmp", "Move.bmp", "Delete.bmp", "Info.bmp" };
            string[] resolutions = { "24x24", "48x36" };
            var currentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

            var themeDir = Path.Combine(currentDir, type.ToString(), theme);

            ConcurrentQueue<(int, string)> queue = new ConcurrentQueue<(int, string)>();



            int index = 100;
            foreach (var item in bmps)
            {
                string bmpPath = Path.Combine(themeDir, "48x36", item);
                Console.WriteLine($"{index}\n {bmpPath}");

                // ModifyBmpFile(index, bmpPath);
                queue.Enqueue((index, bmpPath));
                index++;
            }
            index = 150;
            foreach (var item in bmps)
            {
                string bmpPath = Path.Combine(themeDir, "24x24", item);
                // ModifyBmpFile(index, bmpPath);

                queue.Enqueue((index, bmpPath));
                index++;
            }
            Task.Run(() => ProcessQueue(queue, callback));

        }


        private void ProcessQueue(ConcurrentQueue<(int, string)> queue, OperationCompletedHandler callback)
        {
            while (queue.TryDequeue(out var item))
            {
                ModifyBmpFile(item.Item1, item.Item2);
            }
            callback?.Invoke();
        }



        private void ProcessQueue(ConcurrentQueue<(int, string, string)> queue, OperationCompletedHandler callback)
        {
            while (queue.TryDequeue(out var item))
            {
                ModifyIconDll(item.Item1, item.Item2, item.Item3);
            }
            callback?.Invoke();
        }


        private static void Callback(IAsyncResult ar)
        {
            LongRunningAction del = (LongRunningAction)ar.AsyncState;
            del.EndInvoke(ar);

        }

        public void ReplaceIcon(string exePath, string theme, OperationCompletedHandler callback)
        {
            status = false;
            exePath = Path.Combine(_path7z, "7z.dll");
            if (!CheckFileWriteAccess(exePath)) return;
            var currentDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

            var themeDir = Path.Combine(currentDir, ElementType.filetype.ToString(), theme);
            ConcurrentQueue<(int, string, string)> queue = new ConcurrentQueue<(int, string, string)>();


            Dictionary<int, string> icons = new Dictionary<int, string>() {
                {0 ,"7z.ico"},
                {1 ,"zip.ico"},
                {2 ,"bz2.ico"},
                {3 ,"rar.ico"},
                {4 ,"arj.ico"},
                {5 ,"z.ico"},
                {6 ,"lha.ico"},
                {7 ,"cab.ico"},
                {8 ,"iso.ico"},
                {9 ,"001.ico"},
                {10 ,"rpm.ico"},
                {11 ,"deb.ico"},
                {12 ,"cpio.ico"},
                {13 ,"tar.ico"},
                {14 ,"gz.ico"},
                {15 ,"wim.ico"},
                {16 ,"lzh.ico"},
                {17 ,"dmg.ico"},
                {18 ,"hfs.ico"},
                {19 ,"xar.ico"},
                {20 ,"vhd.ico"},
                {21 ,"fat.ico"},
                {22 ,"ntfs.ico"},
                {23 ,"xz.ico"}
            };
            foreach (var item in icons)
            {
                var iconFile = Path.Combine(themeDir, item.Value);
                if (File.Exists(iconFile))
                {
                    queue.Enqueue((item.Key, iconFile, exePath));
                    //ModifyIconDll(item.Key, iconFile, exePath);
                }
            }
            Task.Run(() => ProcessQueue(queue, callback));
        }

        static void ModifyIconDll(int index, string iconFile, string exePath)
        {
            byte[] iconData = File.ReadAllBytes(iconFile);
            IntPtr hUpdate = BeginUpdateResourceW(exePath, false);
            if (hUpdate == IntPtr.Zero)
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            // Split the .ico file into individual icons and their headers
            int iconDirSize = Marshal.SizeOf(typeof(IconDir));
            int iconDirEntrySize = Marshal.SizeOf(typeof(IconDirEntry));
            IconDir iconDir;
            IconDirEntry[] iconDirEntries;
            SplitIconFile(iconData, out iconDir, out iconDirEntries);

            // Update the RT_GROUP_ICON resource
            byte[] groupIconData = BuildGroupIconResource(iconDir, iconDirEntries);
            if (!UpdateResourceW(hUpdate, new IntPtr(RT_GROUP_ICON), new IntPtr(index), 1033, groupIconData, (uint)groupIconData.Length))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }

            // Update the RT_ICON resources
            for (int i = 0; i < iconDirEntries.Length; i++)
            {
                byte[] iconImageData = GetIconImageData(iconData, iconDirEntries[i]);
                if (!UpdateResourceW(hUpdate, new IntPtr(RT_ICON), new IntPtr(index + 1), 1033, iconImageData, (uint)iconImageData.Length))
                {
                    throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
                }
            }

            if (!EndUpdateResourceW(hUpdate, false))
            {
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            }
        }

        static void SplitIconFile(byte[] iconData, out IconDir iconDir, out IconDirEntry[] iconDirEntries)
        {
            GCHandle handle = GCHandle.Alloc(iconData, GCHandleType.Pinned);
            try
            {
                IntPtr ptr = handle.AddrOfPinnedObject();

                iconDir = (IconDir)Marshal.PtrToStructure(ptr, typeof(IconDir));
                iconDirEntries = new IconDirEntry[iconDir.Count];
                for (int i = 0; i < iconDir.Count; i++)
                {
                    IntPtr entryPtr = new IntPtr(ptr.ToInt64() + Marshal.SizeOf(typeof(IconDir)) + i * Marshal.SizeOf(typeof(IconDirEntry)));
                    iconDirEntries[i] = (IconDirEntry)Marshal.PtrToStructure(entryPtr, typeof(IconDirEntry));
                }
            }
            finally
            {
                handle.Free();
            }
        }

        static byte[] BuildGroupIconResource(IconDir iconDir, IconDirEntry[] iconDirEntries)
        {
            int size = Marshal.SizeOf(typeof(IconDir)) + Marshal.SizeOf(typeof(GroupIconDirEntry)) * iconDir.Count;
            byte[] data = new byte[size];

            GCHandle handle = GCHandle.Alloc(data, GCHandleType.Pinned);
            try
            {
                IntPtr ptr = handle.AddrOfPinnedObject();

                Marshal.StructureToPtr(iconDir, ptr, false);
                ptr = new IntPtr(ptr.ToInt64() + Marshal.SizeOf(typeof(IconDir)));

                for (int i = 0; i < iconDir.Count; i++)
                {
                    GroupIconDirEntry entry = new GroupIconDirEntry
                    {
                        Width = iconDirEntries[i].Width,
                        Height = iconDirEntries[i].Height,
                        ColorCount = iconDirEntries[i].ColorCount,
                        Reserved = iconDirEntries[i].Reserved,
                        Planes = iconDirEntries[i].Planes,
                        BitCount = iconDirEntries[i].BitCount,
                        BytesInRes = iconDirEntries[i].BytesInRes,
                        ID = (ushort)(i + 1)
                    };
                    Marshal.StructureToPtr(entry, ptr, false);
                    ptr = new IntPtr(ptr.ToInt64() + Marshal.SizeOf(typeof(GroupIconDirEntry)));
                }
            }
            finally
            {
                handle.Free();
            }

            return data;
        }

        static byte[] GetIconImageData(byte[] iconData, IconDirEntry entry)
        {
            byte[] data = new byte[entry.BytesInRes];
            Array.Copy(iconData, entry.ImageOffset, data, 0, entry.BytesInRes);
            return data;
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        struct IconDir
        {
            public ushort Reserved;
            public ushort Type;
            public ushort Count;
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        struct IconDirEntry
        {
            public byte Width;
            public byte Height;
            public byte ColorCount;
            public byte Reserved;
            public ushort Planes;
            public ushort BitCount;
            public uint BytesInRes;
            public uint ImageOffset;
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        struct GroupIconDirEntry
        {
            public byte Width;
            public byte Height;
            public byte ColorCount;
            public byte Reserved;
            public ushort Planes;
            public ushort BitCount;
            public uint BytesInRes;
            public ushort ID;
        }

    }

    class BitmapFile
    {
        private byte[] _data;
        private Gdi32.BITMAPFILEHEADER _header;
        private DeviceIndependentBitmap _bitmap;

        public BitmapFile(string filePath)
        {
            byte[] array = File.ReadAllBytes(filePath);
            IntPtr intPtr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(Gdi32.BITMAPFILEHEADER)));
            try
            {
                Marshal.Copy(array, 0, intPtr, Marshal.SizeOf(typeof(Gdi32.BITMAPFILEHEADER)));
                _header = (Gdi32.BITMAPFILEHEADER)Marshal.PtrToStructure(intPtr, typeof(Gdi32.BITMAPFILEHEADER));
            }
            finally
            {
                Marshal.FreeHGlobal(intPtr);
            }

            int num = array.Length - Marshal.SizeOf(typeof(Gdi32.BITMAPFILEHEADER));
            byte[] array2 = new byte[num];
            Buffer.BlockCopy(array, Marshal.SizeOf(typeof(Gdi32.BITMAPFILEHEADER)), array2, 0, num);
            _bitmap = new DeviceIndependentBitmap(array2);
            _data = array2;
        }

        public byte[] Data => _data;
    }

    public static class Gdi32
    {
        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        public struct BITMAPFILEHEADER
        {
            public ushort bfType;
            public uint bfSize;
            public ushort bfReserved1;
            public ushort bfReserved2;
            public uint bfOffBits;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct BITMAPINFOHEADER
        {
            public uint biSize;
            public int biWidth;
            public int biHeight;
            public ushort biPlanes;
            public ushort biBitCount;
            public uint biCompression;
            public uint biSizeImage;
            public int biXPelsPerMeter;
            public int biYPelsPerMeter;
            public uint biClrUsed;
            public uint biClrImportant;
        }
    }

    class DeviceIndependentBitmap
    {
        public byte[] Data { get; }

        public DeviceIndependentBitmap(byte[] data)
        {
            Data = data;
        }
    }



}
