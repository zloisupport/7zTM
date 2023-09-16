#Region compile
	#pragma compile(Out, Re7zTM.exe)
    #pragma compile(Icon,7zTM.ico)
	#pragma compile(FileDescription," An easy to use 7-Zip toolbar- and filetype theme manager.")
	#pragma compile(ProductName, 7zTM)
	#pragma compile(ProductVersion, 2.2.0.0)
	#pragma compile(FileVersion, 2.2.0.0) ; 
	#pragma compile(LegalCopyright, "")
	#pragma compile(LegalTrademarks, '')
	#pragma compile(CompanyName, '')
#EndRegion
###
#Region options
	#NoTrayIcon
	#RequireAdmin
#EndRegion options
###
#Region incldues
	Global Const $fc_nooverwrite = 0
	Global Const $fc_overwrite = 1
	Global Const $ft_modified = 0
	Global Const $ft_created = 1
	Global Const $ft_accessed = 2
	Global Const $fo_read = 0
	Global Const $fo_append = 1
	Global Const $fo_overwrite = 2
	Global Const $fo_binary = 16
	Global Const $fo_unicode = 32
	Global Const $fo_utf16_le = 32
	Global Const $fo_utf16_be = 64
	Global Const $fo_utf8 = 128
	Global Const $eof = -1
	Global Const $fd_filemustexist = 1
	Global Const $fd_pathmustexist = 2
	Global Const $fd_multiselect = 4
	Global Const $fd_promptcreatenew = 8
	Global Const $fd_promptoverwrite = 16
	Global Const $create_new = 1
	Global Const $create_always = 2
	Global Const $open_existing = 3
	Global Const $open_always = 4
	Global Const $truncate_existing = 5
	Global Const $invalid_set_file_pointer = -1
	Global Const $file_begin = 0
	Global Const $file_current = 1
	Global Const $file_end = 2
	Global Const $file_attribute_readonly = 1
	Global Const $file_attribute_hidden = 2
	Global Const $file_attribute_system = 4
	Global Const $file_attribute_directory = 16
	Global Const $file_attribute_archive = 32
	Global Const $file_attribute_device = 64
	Global Const $file_attribute_normal = 128
	Global Const $file_attribute_temporary = 256
	Global Const $file_attribute_sparse_file = 512
	Global Const $file_attribute_reparse_point = 1024
	Global Const $file_attribute_compressed = 2048
	Global Const $file_attribute_offline = 4096
	Global Const $file_attribute_not_content_indexed = 8192
	Global Const $file_attribute_encrypted = 16384
	Global Const $file_share_read = 1
	Global Const $file_share_write = 2
	Global Const $file_share_delete = 4
	Global Const $generic_all = 268435456
	Global Const $generic_execute = 536870912
	Global Const $generic_write = 1073741824
	Global Const $generic_read = -2147483648

	Func _filecountlines($sfilepath)
		Local $hfile = FileOpen($sfilepath, $fo_read)
		If $hfile = -1 Then Return SetError(1, 0, 0)
		Local $sfilecontent = StringStripWS(FileRead($hfile), 2)
		FileClose($hfile)
		Local $atmp
		If StringInStr($sfilecontent, @LF) Then
			$atmp = StringSplit(StringStripCR($sfilecontent), @LF)
		ElseIf StringInStr($sfilecontent, @CR) Then
			$atmp = StringSplit($sfilecontent, @CR)
		Else
			If StringLen($sfilecontent) Then
				Return 1
			Else
				Return SetError(2, 0, 0)
			EndIf
		EndIf
		Return $atmp[0]
	EndFunc

	Func _filecreate($sfilepath)
		Local $hopenfile = FileOpen($sfilepath, $fo_overwrite)
		If $hopenfile = -1 Then Return SetError(1, 0, 0)
		Local $hwritefile = FileWrite($hopenfile, "")
		FileClose($hopenfile)
		If $hwritefile = -1 Then Return SetError(2, 0, 0)
		Return 1
	EndFunc

	Func _filelisttoarray($spath, $sfilter = "*", $iflag = 0)
		Local $hsearch, $sfile, $sfilelist, $sdelim = "|"
		$spath = StringRegExpReplace($spath, "[\\/]+\z", "") & "\"
		If NOT FileExists($spath) Then Return SetError(1, 1, "")
		If StringRegExp($sfilter, "[\\/:><\|]|(?s)\A\s*\z") Then Return SetError(2, 2, "")
		If NOT ($iflag = 0 OR $iflag = 1 OR $iflag = 2) Then Return SetError(3, 3, "")
		$hsearch = FileFindFirstFile($spath & $sfilter)
		If @error Then Return SetError(4, 4, "")
		While 1
			$sfile = FileFindNextFile($hsearch)
			If @error Then ExitLoop
			If ($iflag + @extended = 2) Then ContinueLoop
			$sfilelist &= $sdelim & $sfile
		WEnd
		FileClose($hsearch)
		If NOT $sfilelist Then Return SetError(4, 4, "")
		Return StringSplit(StringTrimLeft($sfilelist, 1), "|")
	EndFunc

	Func _fileprint($s_file, $i_show = @SW_HIDE)
		Local $a_ret = DllCall("shell32.dll", "int", "ShellExecuteW", "hwnd", 0, "wstr", "print", "wstr", $s_file, "wstr", "", "wstr", "", "int", $i_show)
		If @error Then Return SetError(@error, @extended, 0)
		If $a_ret[0] <= 32 Then Return SetError(10, $a_ret[0], 0)
		Return 1
	EndFunc

	Func _filereadtoarray($sfilepath, ByRef $aarray)
		Local $hfile = FileOpen($sfilepath, $fo_read)
		If $hfile = -1 Then Return SetError(1, 0, 0)
		Local $afile = FileRead($hfile, FileGetSize($sfilepath))
		If StringRight($afile, 1) = @LF Then $afile = StringTrimRight($afile, 1)
		If StringRight($afile, 1) = @CR Then $afile = StringTrimRight($afile, 1)
		FileClose($hfile)
		If StringInStr($afile, @LF) Then
			$aarray = StringSplit(StringStripCR($afile), @LF)
		ElseIf StringInStr($afile, @CR) Then
			$aarray = StringSplit($afile, @CR)
		Else
			If StringLen($afile) Then
				Dim $aarray[2] = [1, $afile]
			Else
				Return SetError(2, 0, 0)
			EndIf
		EndIf
		Return 1
	EndFunc

	Func _filewritefromarray($file, $a_array, $i_base = 0, $i_ubound = 0)
		If NOT IsArray($a_array) Then Return SetError(2, 0, 0)
		Local $last = UBound($a_array) - 1
		If $i_ubound < 1 OR $i_ubound > $last Then $i_ubound = $last
		If $i_base < 0 OR $i_base > $last Then $i_base = 0
		Local $hfile
		If IsString($file) Then
			$hfile = FileOpen($file, $fo_overwrite)
		Else
			$hfile = $file
		EndIf
		If $hfile = -1 Then Return SetError(1, 0, 0)
		Local $errorsav = 0
		For $x = $i_base To $i_ubound
			If FileWrite($hfile, $a_array[$x] & @CRLF) = 0 Then
				$errorsav = 3
				ExitLoop
			EndIf
		Next
		If IsString($file) Then FileClose($hfile)
		If $errorsav Then Return SetError($errorsav, 0, 0)
		Return 1
	EndFunc

	Func _filewritelog($slogpath, $slogmsg, $iflag = -1)
		Local $iopenmode = $fo_append
		Local $sdatenow = @YEAR & "-" & @MON & "-" & @MDAY
		Local $stimenow = @HOUR & ":" & @MIN & ":" & @SEC
		Local $smsg = $sdatenow & " " & $stimenow & " : " & $slogmsg
		If $iflag <> -1 Then
			$smsg &= @CRLF & FileRead($slogpath)
			$iopenmode = $fo_overwrite
		EndIf
		Local $hopenfile = FileOpen($slogpath, $iopenmode)
		If $hopenfile = -1 Then Return SetError(1, 0, 0)
		Local $iwritefile = FileWriteLine($hopenfile, $smsg)
		Local $iret = FileClose($hopenfile)
		If $iwritefile = -1 Then Return SetError(2, $iret, 0)
		Return $iret
	EndFunc

	Func _filewritetoline($sfile, $iline, $stext, $foverwrite = 0)
		If $iline <= 0 Then Return SetError(4, 0, 0)
		If NOT IsString($stext) Then Return SetError(6, 0, 0)
		If $foverwrite <> 0 AND $foverwrite <> 1 Then Return SetError(5, 0, 0)
		If NOT FileExists($sfile) Then Return SetError(2, 0, 0)
		Local $sread_file = FileRead($sfile)
		Local $asplit_file = StringSplit(StringStripCR($sread_file), @LF)
		If UBound($asplit_file) < $iline Then Return SetError(1, 0, 0)
		Local $hfile = FileOpen($sfile, $fo_overwrite)
		If $hfile = -1 Then Return SetError(3, 0, 0)
		$sread_file = ""
		For $i = 1 To $asplit_file[0]
			If $i = $iline Then
				If $foverwrite = 1 Then
					If $stext <> "" Then $sread_file &= $stext & @CRLF
				Else
					$sread_file &= $stext & @CRLF & $asplit_file[$i] & @CRLF
				EndIf
			ElseIf $i < $asplit_file[0] Then
				$sread_file &= $asplit_file[$i] & @CRLF
			ElseIf $i = $asplit_file[0] Then
				$sread_file &= $asplit_file[$i]
			EndIf
		Next
		FileWrite($hfile, $sread_file)
		FileClose($hfile)
		Return 1
	EndFunc

	Func _pathfull($srelativepath, $sbasepath = @WorkingDir)
		If NOT $srelativepath OR $srelativepath = "." Then Return $sbasepath
		Local $sfullpath = StringReplace($srelativepath, "/", "\")
		Local Const $sfullpathconst = $sfullpath
		Local $spath
		Local $brootonly = StringLeft($sfullpath, 1) = "\" AND StringMid($sfullpath, 2, 1) <> "\"
		For $i = 1 To 2
			$spath = StringLeft($sfullpath, 2)
			If $spath = "\\" Then
				$sfullpath = StringTrimLeft($sfullpath, 2)
				Local $nserverlen = StringInStr($sfullpath, "\") - 1
				$spath = "\\" & StringLeft($sfullpath, $nserverlen)
				$sfullpath = StringTrimLeft($sfullpath, $nserverlen)
				ExitLoop
			ElseIf StringRight($spath, 1) = ":" Then
				$sfullpath = StringTrimLeft($sfullpath, 2)
				ExitLoop
			Else
				$sfullpath = $sbasepath & "\" & $sfullpath
			EndIf
		Next
		If $i = 3 Then Return ""
		If StringLeft($sfullpath, 1) <> "\" Then
			If StringLeft($sfullpathconst, 2) = StringLeft($sbasepath, 2) Then
				$sfullpath = $sbasepath & "\" & $sfullpath
			Else
				$sfullpath = "\" & $sfullpath
			EndIf
		EndIf
		Local $atemp = StringSplit($sfullpath, "\")
		Local $apathparts[$atemp[0]], $j = 0
		For $i = 2 To $atemp[0]
			If $atemp[$i] = ".." Then
				If $j Then $j -= 1
			ElseIf NOT ($atemp[$i] = "" AND $i <> $atemp[0]) AND $atemp[$i] <> "." Then
				$apathparts[$j] = $atemp[$i]
				$j += 1
			EndIf
		Next
		$sfullpath = $spath
		If NOT $brootonly Then
			For $i = 0 To $j - 1
				$sfullpath &= "\" & $apathparts[$i]
			Next
		Else
			$sfullpath &= $sfullpathconst
			If StringInStr($sfullpath, "..") Then $sfullpath = _pathfull($sfullpath)
		EndIf
		While StringInStr($sfullpath, ".\")
			$sfullpath = StringReplace($sfullpath, ".\", "\")
		WEnd
		Return $sfullpath
	EndFunc

	Func _pathgetrelative($sfrom, $sto)
		If StringRight($sfrom, 1) <> "\" Then $sfrom &= "\"
		If StringRight($sto, 1) <> "\" Then $sto &= "\"
		If $sfrom = $sto Then Return SetError(1, 0, StringTrimRight($sto, 1))
		Local $asfrom = StringSplit($sfrom, "\")
		Local $asto = StringSplit($sto, "\")
		If $asfrom[1] <> $asto[1] Then Return SetError(2, 0, StringTrimRight($sto, 1))
		Local $i = 2
		Local $idiff = 1
		While 1
			If $asfrom[$i] <> $asto[$i] Then
				$idiff = $i
				ExitLoop
			EndIf
			$i += 1
		WEnd
		$i = 1
		Local $srelpath = ""
		For $j = 1 To $asto[0]
			If $i >= $idiff Then
				$srelpath &= "\" & $asto[$i]
			EndIf
			$i += 1
		Next
		$srelpath = StringTrimLeft($srelpath, 1)
		$i = 1
		For $j = 1 To $asfrom[0]
			If $i > $idiff Then
				$srelpath = "..\" & $srelpath
			EndIf
			$i += 1
		Next
		If StringRight($srelpath, 1) == "\" Then $srelpath = StringTrimRight($srelpath, 1)
		Return $srelpath
	EndFunc

	Func _pathmake($szdrive, $szdir, $szfname, $szext)
		If StringLen($szdrive) Then
			If NOT (StringLeft($szdrive, 2) = "\\") Then $szdrive = StringLeft($szdrive, 1) & ":"
		EndIf
		If StringLen($szdir) Then
			If NOT (StringRight($szdir, 1) = "\") AND NOT (StringRight($szdir, 1) = "/") Then $szdir = $szdir & "\"
		EndIf
		If StringLen($szext) Then
			If NOT (StringLeft($szext, 1) = ".") Then $szext = "." & $szext
		EndIf
		Return $szdrive & $szdir & $szfname & $szext
	EndFunc

	Func _pathsplit($szpath, ByRef $szdrive, ByRef $szdir, ByRef $szfname, ByRef $szext)
		Local $drive = ""
		Local $dir = ""
		Local $fname = ""
		Local $ext = ""
		Local $pos
		Local $array[5]
		$array[0] = $szpath
		If StringMid($szpath, 2, 1) = ":" Then
			$drive = StringLeft($szpath, 2)
			$szpath = StringTrimLeft($szpath, 2)
		ElseIf StringLeft($szpath, 2) = "\\" Then
			$szpath = StringTrimLeft($szpath, 2)
			$pos = StringInStr($szpath, "\")
			If $pos = 0 Then $pos = StringInStr($szpath, "/")
			If $pos = 0 Then
				$drive = "\\" & $szpath
				$szpath = ""
			Else
				$drive = "\\" & StringLeft($szpath, $pos - 1)
				$szpath = StringTrimLeft($szpath, $pos - 1)
			EndIf
		EndIf
		Local $nposforward = StringInStr($szpath, "/", 0, -1)
		Local $nposbackward = StringInStr($szpath, "\", 0, -1)
		If $nposforward >= $nposbackward Then
			$pos = $nposforward
		Else
			$pos = $nposbackward
		EndIf
		$dir = StringLeft($szpath, $pos)
		$fname = StringRight($szpath, StringLen($szpath) - $pos)
		If StringLen($dir) = 0 Then $fname = $szpath
		$pos = StringInStr($fname, ".", 0, -1)
		If $pos Then
			$ext = StringRight($fname, StringLen($fname) - ($pos - 1))
			$fname = StringLeft($fname, $pos - 1)
		EndIf
		$szdrive = $drive
		$szdir = $dir
		$szfname = $fname
		$szext = $ext
		$array[1] = $drive
		$array[2] = $dir
		$array[3] = $fname
		$array[4] = $ext
		Return $array
	EndFunc

	Func _replacestringinfile($szfilename, $szsearchstring, $szreplacestring, $fcaseness = 0, $foccurance = 1)
		Local $iretval = 0
		Local $ncount, $sendswith
		If StringInStr(FileGetAttrib($szfilename), "R") Then Return SetError(6, 0, -1)
		Local $hfile = FileOpen($szfilename, $fo_read)
		If $hfile = -1 Then Return SetError(1, 0, -1)
		Local $s_totfile = FileRead($hfile, FileGetSize($szfilename))
		If StringRight($s_totfile, 2) = @CRLF Then
			$sendswith = @CRLF
		ElseIf StringRight($s_totfile, 1) = @CR Then
			$sendswith = @CR
		ElseIf StringRight($s_totfile, 1) = @LF Then
			$sendswith = @LF
		Else
			$sendswith = ""
		EndIf
		Local $afilelines = StringSplit(StringStripCR($s_totfile), @LF)
		FileClose($hfile)
		Local $hwritehandle = FileOpen($szfilename, $fo_overwrite)
		If $hwritehandle = -1 Then Return SetError(2, 0, -1)
		For $ncount = 1 To $afilelines[0]
			If StringInStr($afilelines[$ncount], $szsearchstring, $fcaseness) Then
				$afilelines[$ncount] = StringReplace($afilelines[$ncount], $szsearchstring, $szreplacestring, 1 - $foccurance, $fcaseness)
				$iretval = $iretval + 1
				If $foccurance = 0 Then
					$iretval = 1
					ExitLoop
				EndIf
			EndIf
		Next
		For $ncount = 1 To $afilelines[0] - 1
			If FileWriteLine($hwritehandle, $afilelines[$ncount]) = 0 Then
				FileClose($hwritehandle)
				Return SetError(3, 0, -1)
			EndIf
		Next
		If $afilelines[$ncount] <> "" Then FileWrite($hwritehandle, $afilelines[$ncount] & $sendswith)
		FileClose($hwritehandle)
		Return $iretval
	EndFunc

	Func _tempfile($s_directoryname = @TempDir, $s_fileprefix = "~", $s_fileextension = ".tmp", $i_randomlength = 7)
		If NOT FileExists($s_directoryname) Then $s_directoryname = @TempDir
		If NOT FileExists($s_directoryname) Then $s_directoryname = @ScriptDir
		If StringRight($s_directoryname, 1) <> "\" Then $s_directoryname = $s_directoryname & "\"
		Local $s_tempname
		Do
			$s_tempname = ""
			While StringLen($s_tempname) < $i_randomlength
				$s_tempname = $s_tempname & Chr(Random(97, 122, 1))
			WEnd
			$s_tempname = $s_directoryname & $s_fileprefix & $s_tempname & $s_fileextension
		Until NOT FileExists($s_tempname)
		Return $s_tempname
	EndFunc

	Func _arrayadd(ByRef $avarray, $vvalue)
		If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, -1)
		Local $iubound = UBound($avarray)
		ReDim $avarray[$iubound + 1]
		$avarray[$iubound] = $vvalue
		Return $iubound
	EndFunc

	Func _arraybinarysearch(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
		If UBound($avarray, 0) <> 1 Then Return SetError(5, 0, -1)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(4, 0, -1)
		Local $imid = Int(($iend + $istart) / 2)
		If $avarray[$istart] > $vvalue OR $avarray[$iend] < $vvalue Then Return SetError(2, 0, -1)
		While $istart <= $imid AND $vvalue <> $avarray[$imid]
			If $vvalue < $avarray[$imid] Then
				$iend = $imid - 1
			Else
				$istart = $imid + 1
			EndIf
			$imid = Int(($iend + $istart) / 2)
		WEnd
		If $istart > $iend Then Return SetError(3, 0, -1)
		Return $imid
	EndFunc

	Func _arraycombinations(ByRef $avarray, $iset, $sdelim = "")
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
		Local $in = UBound($avarray)
		Local $ir = $iset
		Local $aidx[$ir]
		For $i = 0 To $ir - 1
			$aidx[$i] = $i
		Next
		Local $itotal = __array_combinations($in, $ir)
		Local $ileft = $itotal
		Local $aresult[$itotal + 1]
		$aresult[0] = $itotal
		Local $icount = 1
		While $ileft > 0
			__array_getnext($in, $ir, $ileft, $itotal, $aidx)
			For $i = 0 To $iset - 1
				$aresult[$icount] &= $avarray[$aidx[$i]] & $sdelim
			Next
			If $sdelim <> "" Then $aresult[$icount] = StringTrimRight($aresult[$icount], 1)
			$icount += 1
		WEnd
		Return $aresult
	EndFunc

	Func _arrayconcatenate(ByRef $avarraytarget, Const ByRef $avarraysource, $istart = 0)
		If NOT IsArray($avarraytarget) Then Return SetError(1, 0, 0)
		If NOT IsArray($avarraysource) Then Return SetError(2, 0, 0)
		If UBound($avarraytarget, 0) <> 1 Then
			If UBound($avarraysource, 0) <> 1 Then Return SetError(5, 0, 0)
			Return SetError(3, 0, 0)
		EndIf
		If UBound($avarraysource, 0) <> 1 Then Return SetError(4, 0, 0)
		Local $iuboundtarget = UBound($avarraytarget) - $istart, $iuboundsource = UBound($avarraysource)
		ReDim $avarraytarget[$iuboundtarget + $iuboundsource]
		For $i = $istart To $iuboundsource - 1
			$avarraytarget[$iuboundtarget + $i] = $avarraysource[$i]
		Next
		Return $iuboundtarget + $iuboundsource
	EndFunc

	Func _arraycreate($v_0, $v_1 = 0, $v_2 = 0, $v_3 = 0, $v_4 = 0, $v_5 = 0, $v_6 = 0, $v_7 = 0, $v_8 = 0, $v_9 = 0, $v_10 = 0, $v_11 = 0, $v_12 = 0, $v_13 = 0, $v_14 = 0, $v_15 = 0, $v_16 = 0, $v_17 = 0, $v_18 = 0, $v_19 = 0, $v_20 = 0)
		Local $av_array[21] = [$v_0, $v_1, $v_2, $v_3, $v_4, $v_5, $v_6, $v_7, $v_8, $v_9, $v_10, $v_11, $v_12, $v_13, $v_14, $v_15, $v_16, $v_17, $v_18, $v_19, $v_20]
		ReDim $av_array[@NumParams]
		Return $av_array
	EndFunc

	Func _arraydelete(ByRef $avarray, $ielement)
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		Local $iubound = UBound($avarray, 1) - 1
		If NOT $iubound Then
			$avarray = ""
			Return 0
		EndIf
		If $ielement < 0 Then $ielement = 0
		If $ielement > $iubound Then $ielement = $iubound
		Switch UBound($avarray, 0)
			Case 1
				For $i = $ielement To $iubound - 1
					$avarray[$i] = $avarray[$i + 1]
				Next
				ReDim $avarray[$iubound]
			Case 2
				Local $isubmax = UBound($avarray, 2) - 1
				For $i = $ielement To $iubound - 1
					For $j = 0 To $isubmax
						$avarray[$i][$j] = $avarray[$i + 1][$j]
					Next
				Next
				ReDim $avarray[$iubound][$isubmax + 1]
			Case Else
				Return SetError(3, 0, 0)
		EndSwitch
		Return $iubound
	EndFunc

	Func _arraydisplay(Const ByRef $avarray, $stitle = "Array: ListView Display", $iitemlimit = -1, $itranspose = 0, $sseparator = "", $sreplace = "|", $sheader = "")
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		Local $idimension = UBound($avarray, 0), $iubound = UBound($avarray, 1) - 1, $isubmax = UBound($avarray, 2) - 1
		If $idimension > 2 Then Return SetError(2, 0, 0)
		If $sseparator = "" Then $sseparator = Chr(124)
		If _arraysearch($avarray, $sseparator, 0, 0, 0, 1) <> -1 Then
			For $x = 1 To 255
				If $x >= 32 AND $x <= 127 Then ContinueLoop
				Local $sfind = _arraysearch($avarray, Chr($x), 0, 0, 0, 1)
				If $sfind = -1 Then
					$sseparator = Chr($x)
					ExitLoop
				EndIf
			Next
		EndIf
		Local $vtmp, $ibuffer = 64
		Local $icollimit = 250
		Local $ioneventmode = Opt("GUIOnEventMode", 0), $sdataseparatorchar = Opt("GUIDataSeparatorChar", $sseparator)
		If $isubmax < 0 Then $isubmax = 0
		If $itranspose Then
			$vtmp = $iubound
			$iubound = $isubmax
			$isubmax = $vtmp
		EndIf
		If $isubmax > $icollimit Then $isubmax = $icollimit
		If $iitemlimit < 1 Then $iitemlimit = $iubound
		If $iubound > $iitemlimit Then $iubound = $iitemlimit
		If $sheader = "" Then
			$sheader = "Row  "
			For $i = 0 To $isubmax
				$sheader &= $sseparator & "Col " & $i
			Next
		EndIf
		Local $avarraytext[$iubound + 1]
		For $i = 0 To $iubound
			$avarraytext[$i] = "[" & $i & "]"
			For $j = 0 To $isubmax
				If $idimension = 1 Then
					If $itranspose Then
						$vtmp = $avarray[$j]
					Else
						$vtmp = $avarray[$i]
					EndIf
				Else
					If $itranspose Then
						$vtmp = $avarray[$j][$i]
					Else
						$vtmp = $avarray[$i][$j]
					EndIf
				EndIf
				$vtmp = StringReplace($vtmp, $sseparator, $sreplace, 0, 1)
				$avarraytext[$i] &= $sseparator & $vtmp
				$vtmp = StringLen($vtmp)
				If $vtmp > $ibuffer Then $ibuffer = $vtmp
			Next
		Next
		$ibuffer += 1
		Local Const $_arrayconstant_gui_dockborders = 102
		Local Const $_arrayconstant_gui_dockbottom = 64
		Local Const $_arrayconstant_gui_dockheight = 512
		Local Const $_arrayconstant_gui_dockleft = 2
		Local Const $_arrayconstant_gui_dockright = 4
		Local Const $_arrayconstant_gui_event_close = -3
		Local Const $_arrayconstant_lvif_param = 4
		Local Const $_arrayconstant_lvif_text = 1
		Local Const $_arrayconstant_lvm_getcolumnwidth = (4096 + 29)
		Local Const $_arrayconstant_lvm_getitemcount = (4096 + 4)
		Local Const $_arrayconstant_lvm_getitemstate = (4096 + 44)
		Local Const $_arrayconstant_lvm_insertitemw = (4096 + 77)
		Local Const $_arrayconstant_lvm_setextendedlistviewstyle = (4096 + 54)
		Local Const $_arrayconstant_lvm_setitemw = (4096 + 76)
		Local Const $_arrayconstant_lvs_ex_fullrowselect = 32
		Local Const $_arrayconstant_lvs_ex_gridlines = 1
		Local Const $_arrayconstant_lvs_showselalways = 8
		Local Const $_arrayconstant_ws_ex_clientedge = 512
		Local Const $_arrayconstant_ws_maximizebox = 65536
		Local Const $_arrayconstant_ws_minimizebox = 131072
		Local Const $_arrayconstant_ws_sizebox = 262144
		Local Const $_arrayconstant_taglvitem = "int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns"
		Local $iaddmask = BitOR($_arrayconstant_lvif_text, $_arrayconstant_lvif_param)
		Local $tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]"), $pbuffer = DllStructGetPtr($tbuffer)
		Local $titem = DllStructCreate($_arrayconstant_taglvitem), $pitem = DllStructGetPtr($titem)
		DllStructSetData($titem, "Param", 0)
		DllStructSetData($titem, "Text", $pbuffer)
		DllStructSetData($titem, "TextMax", $ibuffer)
		Local $iwidth = 640, $iheight = 480
		Local $hgui = GUICreate($stitle, $iwidth, $iheight, Default, Default, BitOR($_arrayconstant_ws_sizebox, $_arrayconstant_ws_minimizebox, $_arrayconstant_ws_maximizebox))
		Local $aiguisize = WinGetClientSize($hgui)
		Local $hlistview = GUICtrlCreateListView($sheader, 0, 0, $aiguisize[0], $aiguisize[1] - 26, $_arrayconstant_lvs_showselalways)
		Local $hcopy = GUICtrlCreateButton("Copy Selected", 3, $aiguisize[1] - 23, $aiguisize[0] - 6, 20)
		GUICtrlSetResizing($hlistview, $_arrayconstant_gui_dockborders)
		GUICtrlSetResizing($hcopy, $_arrayconstant_gui_dockleft + $_arrayconstant_gui_dockright + $_arrayconstant_gui_dockbottom + $_arrayconstant_gui_dockheight)
		GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_lvs_ex_gridlines, $_arrayconstant_lvs_ex_gridlines)
		GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_lvs_ex_fullrowselect, $_arrayconstant_lvs_ex_fullrowselect)
		GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_ws_ex_clientedge, $_arrayconstant_ws_ex_clientedge)
		Local $aitem
		For $i = 0 To $iubound
			If GUICtrlCreateListViewItem($avarraytext[$i], $hlistview) = 0 Then
				$aitem = StringSplit($avarraytext[$i], $sseparator)
				DllStructSetData($tbuffer, "Text", $aitem[1])
				DllStructSetData($titem, "Item", $i)
				DllStructSetData($titem, "SubItem", 0)
				DllStructSetData($titem, "Mask", $iaddmask)
				GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_insertitemw, 0, $pitem)
				DllStructSetData($titem, "Mask", $_arrayconstant_lvif_text)
				For $j = 2 To $aitem[0]
					DllStructSetData($tbuffer, "Text", $aitem[$j])
					DllStructSetData($titem, "SubItem", $j - 1)
					GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setitemw, 0, $pitem)
				Next
			EndIf
		Next
		$iwidth = 0
		For $i = 0 To $isubmax + 1
			$iwidth += GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getcolumnwidth, $i, 0)
		Next
		If $iwidth < 250 Then $iwidth = 230
		$iwidth += 20
		WinMove($hgui, "", (@DesktopWidth - $iwidth) / 2, Default, $iwidth)
		GUISetState(@SW_SHOW, $hgui)
		While 1
			Switch GUIGetMsg()
				Case $_arrayconstant_gui_event_close
					ExitLoop
				Case $hcopy
					Local $sclip = ""
					Local $aicuritems[1] = [0]
					For $i = 0 To GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getitemcount, 0, 0)
						If GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getitemstate, $i, 2) Then
							$aicuritems[0] += 1
							ReDim $aicuritems[$aicuritems[0] + 1]
							$aicuritems[$aicuritems[0]] = $i
						EndIf
					Next
					If NOT $aicuritems[0] Then
						For $sitem In $avarraytext
							$sclip &= $sitem & @CRLF
						Next
					Else
						For $i = 1 To UBound($aicuritems) - 1
							$sclip &= $avarraytext[$aicuritems[$i]] & @CRLF
						Next
					EndIf
					ClipPut($sclip)
			EndSwitch
		WEnd
		GUIDelete($hgui)
		Opt("GUIOnEventMode", $ioneventmode)
		Opt("GUIDataSeparatorChar", $sdataseparatorchar)
		Return 1
	EndFunc

	Func _arrayfindall(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0, $icase = 0, $ipartial = 0, $isubitem = 0)
		$istart = _arraysearch($avarray, $vvalue, $istart, $iend, $icase, $ipartial, 1, $isubitem)
		If @error Then Return SetError(@error, 0, -1)
		Local $iindex = 0, $avresult[UBound($avarray)]
		Do
			$avresult[$iindex] = $istart
			$iindex += 1
			$istart = _arraysearch($avarray, $vvalue, $istart + 1, $iend, $icase, $ipartial, 1, $isubitem)
		Until @error
		ReDim $avresult[$iindex]
		Return $avresult
	EndFunc

	Func _arrayinsert(ByRef $avarray, $ielement, $vvalue = "")
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
		Local $iubound = UBound($avarray) + 1
		ReDim $avarray[$iubound]
		For $i = $iubound - 1 To $ielement + 1 Step -1
			$avarray[$i] = $avarray[$i - 1]
		Next
		$avarray[$ielement] = $vvalue
		Return $iubound
	EndFunc

	Func _arraymax(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
		Local $iresult = _arraymaxindex($avarray, $icompnumeric, $istart, $iend)
		If @error Then Return SetError(@error, 0, "")
		Return $avarray[$iresult]
	EndFunc

	Func _arraymaxindex(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
		If NOT IsArray($avarray) OR UBound($avarray, 0) <> 1 Then Return SetError(1, 0, -1)
		If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, -1)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(2, 0, -1)
		Local $imaxindex = $istart
		If $icompnumeric Then
			For $i = $istart To $iend
				If Number($avarray[$imaxindex]) < Number($avarray[$i]) Then $imaxindex = $i
			Next
		Else
			For $i = $istart To $iend
				If $avarray[$imaxindex] < $avarray[$i] Then $imaxindex = $i
			Next
		EndIf
		Return $imaxindex
	EndFunc

	Func _arraymin(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
		Local $iresult = _arrayminindex($avarray, $icompnumeric, $istart, $iend)
		If @error Then Return SetError(@error, 0, "")
		Return $avarray[$iresult]
	EndFunc

	Func _arrayminindex(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
		If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, -1)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(2, 0, -1)
		Local $iminindex = $istart
		If $icompnumeric Then
			For $i = $istart To $iend
				If Number($avarray[$iminindex]) > Number($avarray[$i]) Then $iminindex = $i
			Next
		Else
			For $i = $istart To $iend
				If $avarray[$iminindex] > $avarray[$i] Then $iminindex = $i
			Next
		EndIf
		Return $iminindex
	EndFunc

	Func _arraypermute(ByRef $avarray, $sdelim = "")
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
		Local $isize = UBound($avarray), $ifactorial = 1, $aidx[$isize], $aresult[1], $icount = 1
		For $i = 0 To $isize - 1
			$aidx[$i] = $i
		Next
		For $i = $isize To 1 Step -1
			$ifactorial *= $i
		Next
		ReDim $aresult[$ifactorial + 1]
		$aresult[0] = $ifactorial
		__array_exeterinternal($avarray, 0, $isize, $sdelim, $aidx, $aresult, $icount)
		Return $aresult
	EndFunc

	Func _arraypop(ByRef $avarray)
		If (NOT IsArray($avarray)) Then Return SetError(1, 0, "")
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, "")
		Local $iubound = UBound($avarray) - 1, $slastval = $avarray[$iubound]
		If NOT $iubound Then
			$avarray = ""
		Else
			ReDim $avarray[$iubound]
		EndIf
		Return $slastval
	EndFunc

	Func _arraypush(ByRef $avarray, $vvalue, $idirection = 0)
		If (NOT IsArray($avarray)) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, 0)
		Local $iubound = UBound($avarray) - 1
		If IsArray($vvalue) Then
			Local $iubounds = UBound($vvalue)
			If ($iubounds - 1) > $iubound Then Return SetError(2, 0, 0)
			If $idirection Then
				For $i = $iubound To $iubounds Step -1
					$avarray[$i] = $avarray[$i - $iubounds]
				Next
				For $i = 0 To $iubounds - 1
					$avarray[$i] = $vvalue[$i]
				Next
			Else
				For $i = 0 To $iubound - $iubounds
					$avarray[$i] = $avarray[$i + $iubounds]
				Next
				For $i = 0 To $iubounds - 1
					$avarray[$i + $iubound - $iubounds + 1] = $vvalue[$i]
				Next
			EndIf
		Else
			If $idirection Then
				For $i = $iubound To 1 Step -1
					$avarray[$i] = $avarray[$i - 1]
				Next
				$avarray[0] = $vvalue
			Else
				For $i = 0 To $iubound - 1
					$avarray[$i] = $avarray[$i + 1]
				Next
				$avarray[$iubound] = $vvalue
			EndIf
		EndIf
		Return 1
	EndFunc

	Func _arrayreverse(ByRef $avarray, $istart = 0, $iend = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, 0)
		Local $vtmp, $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(2, 0, 0)
		For $i = $istart To Int(($istart + $iend - 1) / 2)
			$vtmp = $avarray[$i]
			$avarray[$i] = $avarray[$iend]
			$avarray[$iend] = $vtmp
			$iend -= 1
		Next
		Return 1
	EndFunc

	Func _arraysearch(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0, $icase = 0, $ipartial = 0, $iforward = 1, $isubitem = -1)
		If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
		If UBound($avarray, 0) > 2 OR UBound($avarray, 0) < 1 Then Return SetError(2, 0, -1)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(4, 0, -1)
		Local $istep = 1
		If NOT $iforward Then
			Local $itmp = $istart
			$istart = $iend
			$iend = $itmp
			$istep = -1
		EndIf
		Switch UBound($avarray, 0)
			Case 1
				If NOT $ipartial Then
					If NOT $icase Then
						For $i = $istart To $iend Step $istep
							If $avarray[$i] = $vvalue Then Return $i
						Next
					Else
						For $i = $istart To $iend Step $istep
							If $avarray[$i] == $vvalue Then Return $i
						Next
					EndIf
				Else
					For $i = $istart To $iend Step $istep
						If StringInStr($avarray[$i], $vvalue, $icase) > 0 Then Return $i
					Next
				EndIf
			Case 2
				Local $iuboundsub = UBound($avarray, 2) - 1
				If $isubitem > $iuboundsub Then $isubitem = $iuboundsub
				If $isubitem < 0 Then
					$isubitem = 0
				Else
					$iuboundsub = $isubitem
				EndIf
				For $j = $isubitem To $iuboundsub
					If NOT $ipartial Then
						If NOT $icase Then
							For $i = $istart To $iend Step $istep
								If $avarray[$i][$j] = $vvalue Then Return $i
							Next
						Else
							For $i = $istart To $iend Step $istep
								If $avarray[$i][$j] == $vvalue Then Return $i
							Next
						EndIf
					Else
						For $i = $istart To $iend Step $istep
							If StringInStr($avarray[$i][$j], $vvalue, $icase) > 0 Then Return $i
						Next
					EndIf
				Next
			Case Else
				Return SetError(7, 0, -1)
		EndSwitch
		Return SetError(6, 0, -1)
	EndFunc

	Func _arraysort(ByRef $avarray, $idescending = 0, $istart = 0, $iend = 0, $isubitem = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(2, 0, 0)
		Switch UBound($avarray, 0)
			Case 1
				__arrayquicksort1d($avarray, $istart, $iend)
				If $idescending Then _arrayreverse($avarray, $istart, $iend)
			Case 2
				Local $isubmax = UBound($avarray, 2) - 1
				If $isubitem > $isubmax Then Return SetError(3, 0, 0)
				If $idescending Then
					$idescending = -1
				Else
					$idescending = 1
				EndIf
				__arrayquicksort2d($avarray, $idescending, $istart, $iend, $isubitem, $isubmax)
			Case Else
				Return SetError(4, 0, 0)
		EndSwitch
		Return 1
	EndFunc

	Func __arrayquicksort1d(ByRef $avarray, ByRef $istart, ByRef $iend)
		If $iend <= $istart Then Return 
		Local $vtmp
		If ($iend - $istart) < 15 Then
			Local $vcur
			For $i = $istart + 1 To $iend
				$vtmp = $avarray[$i]
				If IsNumber($vtmp) Then
					For $j = $i - 1 To $istart Step -1
						$vcur = $avarray[$j]
						If ($vtmp >= $vcur AND IsNumber($vcur)) OR (NOT IsNumber($vcur) AND StringCompare($vtmp, $vcur) >= 0) Then ExitLoop
						$avarray[$j + 1] = $vcur
					Next
				Else
					For $j = $i - 1 To $istart Step -1
						If (StringCompare($vtmp, $avarray[$j]) >= 0) Then ExitLoop
						$avarray[$j + 1] = $avarray[$j]
					Next
				EndIf
				$avarray[$j + 1] = $vtmp
			Next
			Return 
		EndIf
		Local $l = $istart, $r = $iend, $vpivot = $avarray[Int(($istart + $iend) / 2)], $fnum = IsNumber($vpivot)
		Do
			If $fnum Then
				While ($avarray[$l] < $vpivot AND IsNumber($avarray[$l])) OR (NOT IsNumber($avarray[$l]) AND StringCompare($avarray[$l], $vpivot) < 0)
					$l += 1
				WEnd
				While ($avarray[$r] > $vpivot AND IsNumber($avarray[$r])) OR (NOT IsNumber($avarray[$r]) AND StringCompare($avarray[$r], $vpivot) > 0)
					$r -= 1
				WEnd
			Else
				While (StringCompare($avarray[$l], $vpivot) < 0)
					$l += 1
				WEnd
				While (StringCompare($avarray[$r], $vpivot) > 0)
					$r -= 1
				WEnd
			EndIf
			If $l <= $r Then
				$vtmp = $avarray[$l]
				$avarray[$l] = $avarray[$r]
				$avarray[$r] = $vtmp
				$l += 1
				$r -= 1
			EndIf
		Until $l > $r
		__arrayquicksort1d($avarray, $istart, $r)
		__arrayquicksort1d($avarray, $l, $iend)
	EndFunc

	Func __arrayquicksort2d(ByRef $avarray, ByRef $istep, ByRef $istart, ByRef $iend, ByRef $isubitem, ByRef $isubmax)
		If $iend <= $istart Then Return 
		Local $vtmp, $l = $istart, $r = $iend, $vpivot = $avarray[Int(($istart + $iend) / 2)][$isubitem], $fnum = IsNumber($vpivot)
		Do
			If $fnum Then
				While ($istep * ($avarray[$l][$isubitem] - $vpivot) < 0 AND IsNumber($avarray[$l][$isubitem])) OR (NOT IsNumber($avarray[$l][$isubitem]) AND $istep * StringCompare($avarray[$l][$isubitem], $vpivot) < 0)
					$l += 1
				WEnd
				While ($istep * ($avarray[$r][$isubitem] - $vpivot) > 0 AND IsNumber($avarray[$r][$isubitem])) OR (NOT IsNumber($avarray[$r][$isubitem]) AND $istep * StringCompare($avarray[$r][$isubitem], $vpivot) > 0)
					$r -= 1
				WEnd
			Else
				While ($istep * StringCompare($avarray[$l][$isubitem], $vpivot) < 0)
					$l += 1
				WEnd
				While ($istep * StringCompare($avarray[$r][$isubitem], $vpivot) > 0)
					$r -= 1
				WEnd
			EndIf
			If $l <= $r Then
				For $i = 0 To $isubmax
					$vtmp = $avarray[$l][$i]
					$avarray[$l][$i] = $avarray[$r][$i]
					$avarray[$r][$i] = $vtmp
				Next
				$l += 1
				$r -= 1
			EndIf
		Until $l > $r
		__arrayquicksort2d($avarray, $istep, $istart, $r, $isubitem, $isubmax)
		__arrayquicksort2d($avarray, $istep, $l, $iend, $isubitem, $isubmax)
	EndFunc

	Func _arrayswap(ByRef $vitem1, ByRef $vitem2)
		Local $vtmp = $vitem1
		$vitem1 = $vitem2
		$vitem2 = $vtmp
	EndFunc

	Func _arraytoclip(Const ByRef $avarray, $istart = 0, $iend = 0)
		Local $sresult = _arraytostring($avarray, @CR, $istart, $iend)
		If @error Then Return SetError(@error, 0, 0)
		Return ClipPut($sresult)
	EndFunc

	Func _arraytostring(Const ByRef $avarray, $sdelim = "|", $istart = 0, $iend = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, "")
		If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, "")
		Local $sresult, $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(2, 0, "")
		For $i = $istart To $iend
			$sresult &= $avarray[$i] & $sdelim
		Next
		Return StringTrimRight($sresult, StringLen($sdelim))
	EndFunc

	Func _arraytrim(ByRef $avarray, $itrimnum, $idirection = 0, $istart = 0, $iend = 0)
		If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
		If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
		Local $iubound = UBound($avarray) - 1
		If $iend < 1 OR $iend > $iubound Then $iend = $iubound
		If $istart < 0 Then $istart = 0
		If $istart > $iend Then Return SetError(5, 0, 0)
		If $idirection Then
			For $i = $istart To $iend
				$avarray[$i] = StringTrimRight($avarray[$i], $itrimnum)
			Next
		Else
			For $i = $istart To $iend
				$avarray[$i] = StringTrimLeft($avarray[$i], $itrimnum)
			Next
		EndIf
		Return 1
	EndFunc

	Func _arrayunique($aarray, $idimension = 1, $ibase = 0, $icase = 0, $vdelim = "|")
		Local $iubounddim
		If $vdelim = "|" Then $vdelim = Chr(1)
		If NOT IsArray($aarray) Then Return SetError(1, 0, 0)
		If NOT $idimension > 0 Then
			Return SetError(3, 0, 0)
		Else
			$iubounddim = UBound($aarray, 1)
			If @error Then Return SetError(3, 0, 0)
			If $idimension > 1 Then
				Local $aarraytmp[1]
				For $i = 0 To $iubounddim - 1
					_arrayadd($aarraytmp, $aarray[$i][$idimension - 1])
				Next
				_arraydelete($aarraytmp, 0)
			Else
				If UBound($aarray, 0) = 1 Then
					Dim $aarraytmp[1]
					For $i = 0 To $iubounddim - 1
						_arrayadd($aarraytmp, $aarray[$i])
					Next
					_arraydelete($aarraytmp, 0)
				Else
					Dim $aarraytmp[1]
					For $i = 0 To $iubounddim - 1
						_arrayadd($aarraytmp, $aarray[$i][$idimension - 1])
					Next
					_arraydelete($aarraytmp, 0)
				EndIf
			EndIf
		EndIf
		Local $shold
		For $icc = $ibase To UBound($aarraytmp) - 1
			If NOT StringInStr($vdelim & $shold, $vdelim & $aarraytmp[$icc] & $vdelim, $icase) Then $shold &= $aarraytmp[$icc] & $vdelim
		Next
		If $shold Then
			$aarraytmp = StringSplit(StringTrimRight($shold, StringLen($vdelim)), $vdelim, 1)
			Return $aarraytmp
		EndIf
		Return SetError(2, 0, 0)
	EndFunc

	Func __array_exeterinternal(ByRef $avarray, $istart, $isize, $sdelim, ByRef $aidx, ByRef $aresult, ByRef $icount)
		If $istart == $isize - 1 Then
			For $i = 0 To $isize - 1
				$aresult[$icount] &= $avarray[$aidx[$i]] & $sdelim
			Next
			If $sdelim <> "" Then $aresult[$icount] = StringTrimRight($aresult[$icount], 1)
			$icount += 1
		Else
			Local $itemp
			For $i = $istart To $isize - 1
				$itemp = $aidx[$i]
				$aidx[$i] = $aidx[$istart]
				$aidx[$istart] = $itemp
				__array_exeterinternal($avarray, $istart + 1, $isize, $sdelim, $aidx, $aresult, $icount)
				$aidx[$istart] = $aidx[$i]
				$aidx[$i] = $itemp
			Next
		EndIf
	EndFunc

	Func __array_combinations($in, $ir)
		Local $i_total = 1
		For $i = $ir To 1 Step -1
			$i_total *= ($in / $i)
			$in -= 1
		Next
		Return $i_total
	EndFunc

	Func __array_getnext($in, $ir, ByRef $ileft, $itotal, ByRef $aidx)
		If $ileft == $itotal Then
			$ileft -= 1
			Return 
		EndIf
		Local $i = $ir - 1
		While $aidx[$i] == $in - $ir + $i
			$i -= 1
		WEnd
		$aidx[$i] += 1
		For $j = $i + 1 To $ir - 1
			$aidx[$j] = $aidx[$i] + $j - $i
		Next
		$ileft -= 1
	EndFunc

	Global Const $gmem_fixed = 0
	Global Const $gmem_moveable = 2
	Global Const $gmem_nocompact = 16
	Global Const $gmem_nodiscard = 32
	Global Const $gmem_zeroinit = 64
	Global Const $gmem_modify = 128
	Global Const $gmem_discardable = 256
	Global Const $gmem_not_banked = 4096
	Global Const $gmem_share = 8192
	Global Const $gmem_ddeshare = 8192
	Global Const $gmem_notify = 16384
	Global Const $gmem_lower = 4096
	Global Const $gmem_valid_flags = 32626
	Global Const $gmem_invalid_handle = 32768
	Global Const $gptr = $gmem_fixed + $gmem_zeroinit
	Global Const $ghnd = $gmem_moveable + $gmem_zeroinit
	Global Const $mem_commit = 4096
	Global Const $mem_reserve = 8192
	Global Const $mem_top_down = 1048576
	Global Const $mem_shared = 134217728
	Global Const $page_noaccess = 1
	Global Const $page_readonly = 2
	Global Const $page_readwrite = 4
	Global Const $page_execute = 16
	Global Const $page_execute_read = 32
	Global Const $page_execute_readwrite = 64
	Global Const $page_guard = 256
	Global Const $page_nocache = 512
	Global Const $mem_decommit = 16384
	Global Const $mem_release = 32768
	Global Const $tagpoint = "long X;long Y"
	Global Const $tagrect = "long Left;long Top;long Right;long Bottom"
	Global Const $tagsize = "long X;long Y"
	Global Const $tagmargins = "int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight"
	Global Const $tagfiletime = "dword Lo;dword Hi"
	Global Const $tagsystemtime = "word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds"
	Global Const $tagtime_zone_information = "long Bias;wchar StdName[32];word StdDate[8];long StdBias;wchar DayName[32];word DayDate[8];long DayBias"
	Global Const $tagnmhdr = "hwnd hWndFrom;uint_ptr IDFrom;INT Code"
	Global Const $tagcomboboxexitem = "uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;int SelectedImage;int OverlayImage;" & "int Indent;lparam Param"
	Global Const $tagnmcbedragbegin = $tagnmhdr & ";int ItemID;ptr szText"
	Global Const $tagnmcbeendedit = $tagnmhdr & ";bool fChanged;int NewSelection;ptr szText;int Why"
	Global Const $tagnmcomboboxex = $tagnmhdr & ";uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;" & "int SelectedImage;int OverlayImage;int Indent;lparam Param"
	Global Const $tagdtprange = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;" & "word MinSecond;word MinMSecond;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;" & "word MaxMinute;word MaxSecond;word MaxMSecond;bool MinValid;bool MaxValid"
	Global Const $tagnmdatetimechange = $tagnmhdr & ";dword Flag;" & $tagsystemtime
	Global Const $tagnmdatetimeformat = $tagnmhdr & ";ptr Format;" & $tagsystemtime & ";ptr pDisplay;wchar Display[64]"
	Global Const $tagnmdatetimeformatquery = $tagnmhdr & ";ptr Format;long SizeX;long SizeY"
	Global Const $tagnmdatetimekeydown = $tagnmhdr & ";int VirtKey;ptr Format;" & $tagsystemtime
	Global Const $tagnmdatetimestring = $tagnmhdr & ";ptr UserString;" & $tagsystemtime & ";dword Flags"
	Global Const $tageventlogrecord = "dword Length;dword Reserved;dword RecordNumber;dword TimeGenerated;dword TimeWritten;dword EventID;" & "word EventType;word NumStrings;word EventCategory;word ReservedFlags;dword ClosingRecordNumber;dword StringOffset;" & "dword UserSidLength;dword UserSidOffset;dword DataLength;dword DataOffset"
	Global Const $taggdipbitmapdata = "uint Width;uint Height;int Stride;int Format;ptr Scan0;uint_ptr Reserved"
	Global Const $taggdipencoderparam = "byte GUID[16];dword Count;dword Type;ptr Values"
	Global Const $taggdipencoderparams = "dword Count;byte Params[0]"
	Global Const $taggdiprectf = "float X;float Y;float Width;float Height"
	Global Const $taggdipstartupinput = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
	Global Const $taggdipstartupoutput = "ptr HookProc;ptr UnhookProc"
	Global Const $taggdipimagecodecinfo = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & "ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"
	Global Const $taggdippencoderparams = "dword Count;byte Params[0]"
	Global Const $taghditem = "uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State"
	Global Const $tagnmhddispinfo = $tagnmhdr & ";int Item;uint Mask;ptr Text;int TextMax;int Image;lparam lParam"
	Global Const $tagnmhdfilterbtnclick = $tagnmhdr & ";int Item;" & $tagrect
	Global Const $tagnmheader = $tagnmhdr & ";int Item;int Button;ptr pItem"
	Global Const $taggetipaddress = "byte Field4;byte Field3;byte Field2;byte Field1"
	Global Const $tagnmipaddress = $tagnmhdr & ";int Field;int Value"
	Global Const $taglvfindinfo = "uint Flags;ptr Text;lparam Param;" & $tagpoint & ";uint Direction"
	Global Const $taglvhittestinfo = $tagpoint & ";uint Flags;int Item;int SubItem"
	Global Const $taglvitem = "uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns"
	Global Const $tagnmlistview = $tagnmhdr & ";int Item;int SubItem;uint NewState;uint OldState;uint Changed;" & "long ActionX;long ActionY;lparam Param"
	Global Const $tagnmlvcustomdraw = $tagnmhdr & ";dword dwDrawStage;handle hdc;long Left;long Top;long Right;long Bottom;" & "dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam" & ";dword clrText;dword clrTextBk;int iSubItem;dword dwItemType;dword clrFace;int iIconEffect;" & "int iIconPhase;int iPartId;int iStateId;long TextLeft;long TextTop;long TextRight;long TextBottom;uint uAlign"
	Global Const $tagnmlvdispinfo = $tagnmhdr & ";" & $taglvitem
	Global Const $tagnmlvfinditem = $tagnmhdr & ";" & $taglvfindinfo
	Global Const $tagnmlvgetinfotip = $tagnmhdr & ";dword Flags;ptr Text;int TextMax;int Item;int SubItem;lparam lParam"
	Global Const $tagnmitemactivate = $tagnmhdr & ";int Index;int SubItem;uint NewState;uint OldState;uint Changed;" & $tagpoint & ";lparam lParam;uint KeyFlags"
	Global Const $tagnmlvkeydown = $tagnmhdr & ";align 1;word VKey;uint Flags"
	Global Const $tagnmlvscroll = $tagnmhdr & ";int DX;int DY"
	Global Const $tagmchittestinfo = "uint Size;" & $tagpoint & ";uint Hit;" & $tagsystemtime
	Global Const $tagmcmonthrange = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds;short Span"
	Global Const $tagmcrange = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds;short MinSet;short MaxSet"
	Global Const $tagmcselrange = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & "word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & "word MaxMSeconds"
	Global Const $tagnmdaystate = $tagnmhdr & ";" & $tagsystemtime & ";int DayState;ptr pDayState"
	Global Const $tagnmselchange = $tagnmhdr & ";word BegYear;word BegMonth;word BegDOW;word BegDay;" & "word BegHour;word BegMinute;word BegSecond;word BegMSeconds;word EndYear;word EndMonth;word EndDOW;" & "word EndDay;word EndHour;word EndMinute;word EndSecond;word EndMSeconds"
	Global Const $tagnmobjectnotify = $tagnmhdr & ";int Item;ptr piid;ptr pObject;long Result"
	Global Const $tagnmtckeydown = $tagnmhdr & ";word VKey;uint Flags"
	Global Const $tagtvitem = "uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & "int Children;lparam Param"
	Global Const $tagtvitemex = $tagtvitem & ";int Integral"
	Global Const $tagnmtreeview = $tagnmhdr & ";uint Action;uint OldMask;handle OldhItem;uint OldState;uint OldStateMask;" & "ptr OldText;int OldTextMax;int OldImage;int OldSelectedImage;int OldChildren;lparam OldParam;uint NewMask;handle NewhItem;" & "uint NewState;uint NewStateMask;ptr NewText;int NewTextMax;int NewImage;int NewSelectedImage;int NewChildren;" & "lparam NewParam;long PointX;long PointY"
	Global Const $tagnmtvcustomdraw = $tagnmhdr & ";dword DrawStage;handle HDC;long Left;long Top;long Right;long Bottom;" & "dword_ptr ItemSpec;uint ItemState;lparam ItemParam;dword ClrText;dword ClrTextBk;int Level"
	Global Const $tagnmtvdispinfo = $tagnmhdr & ";" & $tagtvitem
	Global Const $tagnmtvgetinfotip = $tagnmhdr & ";ptr Text;int TextMax;handle hItem;lparam lParam"
	Global Const $tagtvhittestinfo = $tagpoint & ";uint Flags;handle Item"
	Global Const $tagnmtvkeydown = $tagnmhdr & ";word VKey;uint Flags"
	Global Const $tagnmmouse = $tagnmhdr & ";dword_ptr ItemSpec;dword_ptr ItemData;" & $tagpoint & ";lparam HitInfo"
	Global Const $tagtoken_privileges = "dword Count;int64 LUID;dword Attributes"
	Global Const $tagimageinfo = "handle hBitmap;handle hMask;int Unused1;int Unused2;" & $tagrect
	Global Const $tagmenuinfo = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"
	Global Const $tagmenuiteminfo = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & "ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
	Global Const $tagrebarbandinfo = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader"
	Global Const $tagnmrebarautobreak = $tagnmhdr & ";uint uBand;uint wID;lparam lParam;uint uMsg;uint fStyleCurrent;bool fAutoBreak"
	Global Const $tagnmrbautosize = $tagnmhdr & ";bool fChanged;long TargetLeft;long TargetTop;long TargetRight;long TargetBottom;" & "long ActualLeft;long ActualTop;long ActualRight;long ActualBottom"
	Global Const $tagnmrebar = $tagnmhdr & ";dword dwMask;uint uBand;uint fStyle;uint wID;laram lParam"
	Global Const $tagnmrebarchevron = $tagnmhdr & ";uint uBand;uint wID;lparam lParam;" & $tagrect & ";lparam lParamNM"
	Global Const $tagnmrebarchildsize = $tagnmhdr & ";uint uBand;uint wID;long CLeft;long CTop;long CRight;long CBottom;" & "long BLeft;long BTop;long BRight;long BBottom"
	Global Const $tagcolorscheme = "dword Size;dword BtnHighlight;dword BtnShadow"
	Global Const $tagnmtoolbar = $tagnmhdr & ";int iItem;" & "int iBitmap;int idCommand;byte fsState;byte fsStyle;align;dword_ptr dwData;int_ptr iString" & ";int cchText;ptr pszText;" & $tagrect
	Global Const $tagnmtbhotitem = $tagnmhdr & ";int idOld;int idNew;dword dwFlags"
	Global Const $tagtbbutton = "int Bitmap;int Command;byte State;byte Style;align;dword_ptr Param;int_ptr String"
	Global Const $tagtbbuttoninfo = "uint Size;dword Mask;int Command;int Image;byte State;byte Style;word CX;dword_ptr Param;ptr Text;int TextMax"
	Global Const $tagnetresource = "dword Scope;dword Type;dword DisplayType;dword Usage;ptr LocalName;ptr RemoteName;ptr Comment;ptr Provider"
	Global Const $tagoverlapped = "ulong_ptr Internal;ulong_ptr InternalHigh;dword Offset;dword OffsetHigh;handle hEvent"
	Global Const $tagopenfilename = "dword StructSize;hwnd hwndOwner;handle hInstance;ptr lpstrFilter;ptr lpstrCustomFilter;" & "dword nMaxCustFilter;dword nFilterIndex;ptr lpstrFile;dword nMaxFile;ptr lpstrFileTitle;dword nMaxFileTitle;" & "ptr lpstrInitialDir;ptr lpstrTitle;dword Flags;word nFileOffset;word nFileExtension;ptr lpstrDefExt;lparam lCustData;" & "ptr lpfnHook;ptr lpTemplateName;ptr pvReserved;dword dwReserved;dword FlagsEx"
	Global Const $tagbitmapinfo = "dword Size;long Width;long Height;word Planes;word BitCount;dword Compression;dword SizeImage;" & "long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;dword RGBQuad"
	Global Const $tagblendfunction = "byte Op;byte Flags;byte Alpha;byte Format"
	Global Const $tagguid = "dword Data1;word Data2;word Data3;byte Data4[8]"
	Global Const $tagwindowplacement = "uint length; uint flags;uint showCmd;long ptMinPosition[2];long ptMaxPosition[2];long rcNormalPosition[4]"
	Global Const $tagwindowpos = "hwnd hWnd;hwnd InsertAfter;int X;int Y;int CX;int CY;uint Flags"
	Global Const $tagscrollinfo = "uint cbSize;uint fMask;int  nMin;int  nMax;uint nPage;int  nPos;int  nTrackPos"
	Global Const $tagscrollbarinfo = "dword cbSize;" & $tagrect & ";int dxyLineButton;int xyThumbTop;" & "int xyThumbBottom;int reserved;dword rgstate[6]"
	Global Const $taglogfont = "long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & "byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32]"
	Global Const $tagkbdllhookstruct = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
	Global Const $tagprocess_information = "handle hProcess;handle hThread;dword ProcessID;dword ThreadID"
	Global Const $tagstartupinfo = "dword Size;ptr Reserved1;ptr Desktop;ptr Title;dword X;dword Y;dword XSize;dword YSize;dword XCountChars;" & "dword YCountChars;dword FillAttribute;dword Flags;word ShowWindow;word Reserved2;ptr Reserved3;handle StdInput;" & "handle StdOutput;handle StdError"
	Global Const $tagsecurity_attributes = "dword Length;ptr Descriptor;bool InheritHandle"
	Global Const $tagwin32_find_data = "dword dwFileAttributes; dword ftCreationTime[2]; dword ftLastAccessTime[2]; dword ftLastWriteTime[2]; dword nFileSizeHigh; dword nFileSizeLow; dword dwReserved0; dword dwReserved1; wchar cFileName[260]; wchar cAlternateFileName[14]"
	Global Const $process_terminate = 1
	Global Const $process_create_thread = 2
	Global Const $process_set_sessionid = 4
	Global Const $process_vm_operation = 8
	Global Const $process_vm_read = 16
	Global Const $process_vm_write = 32
	Global Const $process_dup_handle = 64
	Global Const $process_create_process = 128
	Global Const $process_set_quota = 256
	Global Const $process_set_information = 512
	Global Const $process_query_information = 1024
	Global Const $process_suspend_resume = 2048
	Global Const $process_all_access = 2035711
	Global Const $error_no_token = 1008
	Global Const $se_assignprimarytoken_name = "SeAssignPrimaryTokenPrivilege"
	Global Const $se_audit_name = "SeAuditPrivilege"
	Global Const $se_backup_name = "SeBackupPrivilege"
	Global Const $se_change_notify_name = "SeChangeNotifyPrivilege"
	Global Const $se_create_global_name = "SeCreateGlobalPrivilege"
	Global Const $se_create_pagefile_name = "SeCreatePagefilePrivilege"
	Global Const $se_create_permanent_name = "SeCreatePermanentPrivilege"
	Global Const $se_create_token_name = "SeCreateTokenPrivilege"
	Global Const $se_debug_name = "SeDebugPrivilege"
	Global Const $se_enable_delegation_name = "SeEnableDelegationPrivilege"
	Global Const $se_impersonate_name = "SeImpersonatePrivilege"
	Global Const $se_inc_base_priority_name = "SeIncreaseBasePriorityPrivilege"
	Global Const $se_increase_quota_name = "SeIncreaseQuotaPrivilege"
	Global Const $se_load_driver_name = "SeLoadDriverPrivilege"
	Global Const $se_lock_memory_name = "SeLockMemoryPrivilege"
	Global Const $se_machine_account_name = "SeMachineAccountPrivilege"
	Global Const $se_manage_volume_name = "SeManageVolumePrivilege"
	Global Const $se_prof_single_process_name = "SeProfileSingleProcessPrivilege"
	Global Const $se_remote_shutdown_name = "SeRemoteShutdownPrivilege"
	Global Const $se_restore_name = "SeRestorePrivilege"
	Global Const $se_security_name = "SeSecurityPrivilege"
	Global Const $se_shutdown_name = "SeShutdownPrivilege"
	Global Const $se_sync_agent_name = "SeSyncAgentPrivilege"
	Global Const $se_system_environment_name = "SeSystemEnvironmentPrivilege"
	Global Const $se_system_profile_name = "SeSystemProfilePrivilege"
	Global Const $se_systemtime_name = "SeSystemtimePrivilege"
	Global Const $se_take_ownership_name = "SeTakeOwnershipPrivilege"
	Global Const $se_tcb_name = "SeTcbPrivilege"
	Global Const $se_unsolicited_input_name = "SeUnsolicitedInputPrivilege"
	Global Const $se_undock_name = "SeUndockPrivilege"
	Global Const $se_privilege_enabled_by_default = 1
	Global Const $se_privilege_enabled = 2
	Global Const $se_privilege_removed = 4
	Global Const $se_privilege_used_for_access = -2147483648
	Global Const $tokenuser = 1
	Global Const $tokengroups = 2
	Global Const $tokenprivileges = 3
	Global Const $tokenowner = 4
	Global Const $tokenprimarygroup = 5
	Global Const $tokendefaultdacl = 6
	Global Const $tokensource = 7
	Global Const $tokentype = 8
	Global Const $tokenimpersonationlevel = 9
	Global Const $tokenstatistics = 10
	Global Const $tokenrestrictedsids = 11
	Global Const $tokensessionid = 12
	Global Const $tokengroupsandprivileges = 13
	Global Const $tokensessionreference = 14
	Global Const $tokensandboxinert = 15
	Global Const $tokenauditpolicy = 16
	Global Const $tokenorigin = 17
	Global Const $tokenelevationtype = 18
	Global Const $tokenlinkedtoken = 19
	Global Const $tokenelevation = 20
	Global Const $tokenhasrestrictions = 21
	Global Const $tokenaccessinformation = 22
	Global Const $tokenvirtualizationallowed = 23
	Global Const $tokenvirtualizationenabled = 24
	Global Const $tokenintegritylevel = 25
	Global Const $tokenuiaccess = 26
	Global Const $tokenmandatorypolicy = 27
	Global Const $tokenlogonsid = 28
	Global Const $token_assign_primary = 1
	Global Const $token_duplicate = 2
	Global Const $token_impersonate = 4
	Global Const $token_query = 8
	Global Const $token_query_source = 16
	Global Const $token_adjust_privileges = 32
	Global Const $token_adjust_groups = 64
	Global Const $token_adjust_default = 128
	Global Const $token_adjust_sessionid = 256

	Func _winapi_getlasterror($curerr = @error, $curext = @extended)
		Local $aresult = DllCall("kernel32.dll", "dword", "GetLastError")
		Return SetError($curerr, $curext, $aresult[0])
	EndFunc

	Func _winapi_setlasterror($ierrcode, $curerr = @error, $curext = @extended)
		DllCall("kernel32.dll", "none", "SetLastError", "dword", $ierrcode)
		Return SetError($curerr, $curext)
	EndFunc

	Func _security__adjusttokenprivileges($htoken, $fdisableall, $pnewstate, $ibufferlen, $pprevstate = 0, $prequired = 0)
		Local $aresult = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $htoken, "bool", $fdisableall, "ptr", $pnewstate, "dword", $ibufferlen, "ptr", $pprevstate, "ptr", $prequired)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _security__getaccountsid($saccount, $ssystem = "")
		Local $aacct = _security__lookupaccountname($saccount, $ssystem)
		If @error Then Return SetError(@error, 0, 0)
		Return _security__stringsidtosid($aacct[0])
	EndFunc

	Func _security__getlengthsid($psid)
		If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, 0)
		Local $aresult = DllCall("advapi32.dll", "dword", "GetLengthSid", "ptr", $psid)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _security__gettokeninformation($htoken, $iclass)
		Local $aresult = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $htoken, "int", $iclass, "ptr", 0, "dword", 0, "dword*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $aresult[0] Then Return 0
		Local $tbuffer = DllStructCreate("byte[" & $aresult[5] & "]")
		Local $pbuffer = DllStructGetPtr($tbuffer)
		$aresult = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $htoken, "int", $iclass, "ptr", $pbuffer, "dword", $aresult[5], "dword*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $aresult[0] Then Return 0
		Return $tbuffer
	EndFunc

	Func _security__impersonateself($ilevel = 2)
		Local $aresult = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $ilevel)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _security__isvalidsid($psid)
		Local $aresult = DllCall("advapi32.dll", "bool", "IsValidSid", "ptr", $psid)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _security__lookupaccountname($saccount, $ssystem = "")
		Local $tdata = DllStructCreate("byte SID[256]")
		Local $psid = DllStructGetPtr($tdata, "SID")
		Local $aresult = DllCall("advapi32.dll", "bool", "LookupAccountNameW", "wstr", $ssystem, "wstr", $saccount, "ptr", $psid, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $aresult[0] Then Return 0
		Local $aacct[3]
		$aacct[0] = _security__sidtostringsid($psid)
		$aacct[1] = $aresult[5]
		$aacct[2] = $aresult[7]
		Return $aacct
	EndFunc

	Func _security__lookupaccountsid($vsid)
		Local $psid, $aacct[3]
		If IsString($vsid) Then
			Local $tsid = _security__stringsidtosid($vsid)
			$psid = DllStructGetPtr($tsid)
		Else
			$psid = $vsid
		EndIf
		If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, 0)
		Local $aresult = DllCall("advapi32.dll", "bool", "LookupAccountSidW", "ptr", 0, "ptr", $psid, "wstr", "", "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $aresult[0] Then Return 0
		Local $aacct[3]
		$aacct[0] = $aresult[3]
		$aacct[1] = $aresult[5]
		$aacct[2] = $aresult[7]
		Return $aacct
	EndFunc

	Func _security__lookupprivilegevalue($ssystem, $sname)
		Local $aresult = DllCall("advapi32.dll", "int", "LookupPrivilegeValueW", "wstr", $ssystem, "wstr", $sname, "int64*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetError(0, $aresult[0], $aresult[3])
	EndFunc

	Func _security__openprocesstoken($hprocess, $iaccess)
		Local $aresult = DllCall("advapi32.dll", "int", "OpenProcessToken", "handle", $hprocess, "dword", $iaccess, "ptr", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetError(0, $aresult[0], $aresult[3])
	EndFunc

	Func _security__openthreadtoken($iaccess, $hthread = 0, $fopenasself = False)
		If $hthread = 0 Then $hthread = DllCall("kernel32.dll", "handle", "GetCurrentThread")
		If @error Then Return SetError(@error, @extended, 0)
		Local $aresult = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hthread[0], "dword", $iaccess, "int", $fopenasself, "ptr*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetError(0, $aresult[0], $aresult[4])
	EndFunc

	Func _security__openthreadtokenex($iaccess, $hthread = 0, $fopenasself = False)
		Local $htoken = _security__openthreadtoken($iaccess, $hthread, $fopenasself)
		If $htoken = 0 Then
			If _winapi_getlasterror() <> $error_no_token Then Return SetError(-3, _winapi_getlasterror(), 0)
			If NOT _security__impersonateself() Then Return SetError(-1, _winapi_getlasterror(), 0)
			$htoken = _security__openthreadtoken($iaccess, $hthread, $fopenasself)
			If $htoken = 0 Then Return SetError(-2, _winapi_getlasterror(), 0)
		EndIf
		Return $htoken
	EndFunc

	Func _security__setprivilege($htoken, $sprivilege, $fenable)
		Local $iluid = _security__lookupprivilegevalue("", $sprivilege)
		If $iluid = 0 Then Return SetError(-1, 0, False)
		Local $tcurrstate = DllStructCreate($tagtoken_privileges)
		Local $pcurrstate = DllStructGetPtr($tcurrstate)
		Local $icurrstate = DllStructGetSize($tcurrstate)
		Local $tprevstate = DllStructCreate($tagtoken_privileges)
		Local $pprevstate = DllStructGetPtr($tprevstate)
		Local $iprevstate = DllStructGetSize($tprevstate)
		Local $trequired = DllStructCreate("int Data")
		Local $prequired = DllStructGetPtr($trequired)
		DllStructSetData($tcurrstate, "Count", 1)
		DllStructSetData($tcurrstate, "LUID", $iluid)
		If NOT _security__adjusttokenprivileges($htoken, False, $pcurrstate, $icurrstate, $pprevstate, $prequired) Then Return SetError(-2, @error, False)
		DllStructSetData($tprevstate, "Count", 1)
		DllStructSetData($tprevstate, "LUID", $iluid)
		Local $iattributes = DllStructGetData($tprevstate, "Attributes")
		If $fenable Then
			$iattributes = BitOR($iattributes, $se_privilege_enabled)
		Else
			$iattributes = BitAND($iattributes, BitNOT($se_privilege_enabled))
		EndIf
		DllStructSetData($tprevstate, "Attributes", $iattributes)
		If NOT _security__adjusttokenprivileges($htoken, False, $pprevstate, $iprevstate, $pcurrstate, $prequired) Then Return SetError(-3, @error, False)
		Return True
	EndFunc

	Func _security__sidtostringsid($psid)
		If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, "")
		Local $aresult = DllCall("advapi32.dll", "int", "ConvertSidToStringSidW", "ptr", $psid, "ptr*", 0)
		If @error Then Return SetError(@error, @extended, "")
		If NOT $aresult[0] Then Return ""
		Local $tbuffer = DllStructCreate("wchar Text[256]", $aresult[2])
		Local $ssid = DllStructGetData($tbuffer, "Text")
		DllCall("Kernel32.dll", "ptr", "LocalFree", "ptr", $aresult[2])
		Return $ssid
	EndFunc

	Func _security__sidtypestr($itype)
		Switch $itype
			Case 1
				Return "User"
			Case 2
				Return "Group"
			Case 3
				Return "Domain"
			Case 4
				Return "Alias"
			Case 5
				Return "Well Known Group"
			Case 6
				Return "Deleted Account"
			Case 7
				Return "Invalid"
			Case 8
				Return "Invalid"
			Case 9
				Return "Computer"
			Case Else
				Return "Unknown SID Type"
		EndSwitch
	EndFunc

	Func _security__stringsidtosid($ssid)
		Local $aresult = DllCall("advapi32.dll", "bool", "ConvertStringSidToSidW", "wstr", $ssid, "ptr*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $aresult[0] Then Return 0
		Local $isize = _security__getlengthsid($aresult[2])
		Local $tbuffer = DllStructCreate("byte Data[" & $isize & "]", $aresult[2])
		Local $tsid = DllStructCreate("byte Data[" & $isize & "]")
		DllStructSetData($tsid, "Data", DllStructGetData($tbuffer, "Data"))
		DllCall("kernel32.dll", "ptr", "LocalFree", "ptr", $aresult[2])
		Return $tsid
	EndFunc

	Global Const $tagmemmap = "handle hProc;ulong_ptr Size;ptr Mem"

	Func _memfree(ByRef $tmemmap)
		Local $pmemory = DllStructGetData($tmemmap, "Mem")
		Local $hprocess = DllStructGetData($tmemmap, "hProc")
		Local $bresult = _memvirtualfreeex($hprocess, $pmemory, 0, $mem_release)
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hprocess)
		If @error Then Return SetError(@error, @extended, False)
		Return $bresult
	EndFunc

	Func _memglobalalloc($ibytes, $iflags = 0)
		Local $aresult = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $iflags, "ulong_ptr", $ibytes)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _memglobalfree($hmem)
		Local $aresult = DllCall("kernel32.dll", "ptr", "GlobalFree", "handle", $hmem)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _memgloballock($hmem)
		Local $aresult = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $hmem)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _memglobalsize($hmem)
		Local $aresult = DllCall("kernel32.dll", "ulong_ptr", "GlobalSize", "handle", $hmem)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _memglobalunlock($hmem)
		Local $aresult = DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $hmem)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _meminit($hwnd, $isize, ByRef $tmemmap)
		Local $aresult = DllCall("User32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hwnd, "dword*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Local $iprocessid = $aresult[2]
		If $iprocessid = 0 Then Return SetError(1, 0, 0)
		Local $iaccess = BitOR($process_vm_operation, $process_vm_read, $process_vm_write)
		Local $hprocess = __mem_openprocess($iaccess, False, $iprocessid, True)
		Local $ialloc = BitOR($mem_reserve, $mem_commit)
		Local $pmemory = _memvirtualallocex($hprocess, 0, $isize, $ialloc, $page_readwrite)
		If $pmemory = 0 Then Return SetError(2, 0, 0)
		$tmemmap = DllStructCreate($tagmemmap)
		DllStructSetData($tmemmap, "hProc", $hprocess)
		DllStructSetData($tmemmap, "Size", $isize)
		DllStructSetData($tmemmap, "Mem", $pmemory)
		Return $pmemory
	EndFunc

	Func _memmovememory($psource, $pdest, $ilength)
		DllCall("kernel32.dll", "none", "RtlMoveMemory", "ptr", $pdest, "ptr", $psource, "ulong_ptr", $ilength)
		If @error Then Return SetError(@error, @extended)
	EndFunc

	Func _memread(ByRef $tmemmap, $psrce, $pdest, $isize)
		Local $aresult = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($tmemmap, "hProc"), "ptr", $psrce, "ptr", $pdest, "ulong_ptr", $isize, "ulong_ptr*", 0)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _memwrite(ByRef $tmemmap, $psrce, $pdest = 0, $isize = 0, $ssrce = "ptr")
		If $pdest = 0 Then $pdest = DllStructGetData($tmemmap, "Mem")
		If $isize = 0 Then $isize = DllStructGetData($tmemmap, "Size")
		Local $aresult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tmemmap, "hProc"), "ptr", $pdest, $ssrce, $psrce, "ulong_ptr", $isize, "ulong_ptr*", 0)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _memvirtualalloc($paddress, $isize, $iallocation, $iprotect)
		Local $aresult = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", $paddress, "ulong_ptr", $isize, "dword", $iallocation, "dword", $iprotect)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _memvirtualallocex($hprocess, $paddress, $isize, $iallocation, $iprotect)
		Local $aresult = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hprocess, "ptr", $paddress, "ulong_ptr", $isize, "dword", $iallocation, "dword", $iprotect)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _memvirtualfree($paddress, $isize, $ifreetype)
		Local $aresult = DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $paddress, "ulong_ptr", $isize, "dword", $ifreetype)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _memvirtualfreeex($hprocess, $paddress, $isize, $ifreetype)
		Local $aresult = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hprocess, "ptr", $paddress, "ulong_ptr", $isize, "dword", $ifreetype)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func __mem_openprocess($iaccess, $finherit, $iprocessid, $fdebugpriv = False)
		Local $aresult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iaccess, "bool", $finherit, "dword", $iprocessid)
		If @error Then Return SetError(@error, @extended, 0)
		If $aresult[0] Then Return $aresult[0]
		If NOT $fdebugpriv Then Return 0
		Local $htoken = _security__openthreadtokenex(BitOR($token_adjust_privileges, $token_query))
		If @error Then Return SetError(@error, @extended, 0)
		_security__setprivilege($htoken, "SeDebugPrivilege", True)
		Local $ierror = @error
		Local $ilasterror = @extended
		Local $iret = 0
		If NOT @error Then
			$aresult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iaccess, "bool", $finherit, "dword", $iprocessid)
			$ierror = @error
			$ilasterror = @extended
			If $aresult[0] Then $iret = $aresult[0]
			_security__setprivilege($htoken, "SeDebugPrivilege", False)
			If @error Then
				$ierror = @error
				$ilasterror = @extended
			EndIf
		EndIf
		DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $htoken)
		Return SetError($ierror, $ilasterror, $iret)
	EndFunc

	Func _sendmessage($hwnd, $imsg, $wparam = 0, $lparam = 0, $ireturn = 0, $wparamtype = "wparam", $lparamtype = "lparam", $sreturntype = "lresult")
		Local $aresult = DllCall("user32.dll", $sreturntype, "SendMessageW", "hwnd", $hwnd, "uint", $imsg, $wparamtype, $wparam, $lparamtype, $lparam)
		If @error Then Return SetError(@error, @extended, "")
		If $ireturn >= 0 AND $ireturn <= 4 Then Return $aresult[$ireturn]
		Return $aresult
	EndFunc

	Func _sendmessagea($hwnd, $imsg, $wparam = 0, $lparam = 0, $ireturn = 0, $wparamtype = "wparam", $lparamtype = "lparam", $sreturntype = "lresult")
		Local $aresult = DllCall("user32.dll", $sreturntype, "SendMessageA", "hwnd", $hwnd, "uint", $imsg, $wparamtype, $wparam, $lparamtype, $lparam)
		If @error Then Return SetError(@error, @extended, "")
		If $ireturn >= 0 AND $ireturn <= 4 Then Return $aresult[$ireturn]
		Return $aresult
	EndFunc

	Global $__gainprocess_winapi[64][2] = [[0, 0]]
	Global $__gawinlist_winapi[64][2] = [[0, 0]]
	Global Const $__winapiconstant_wm_setfont = 48
	Global Const $__winapiconstant_fw_normal = 400
	Global Const $__winapiconstant_default_charset = 1
	Global Const $__winapiconstant_out_default_precis = 0
	Global Const $__winapiconstant_clip_default_precis = 0
	Global Const $__winapiconstant_default_quality = 0
	Global Const $__winapiconstant_format_message_allocate_buffer = 256
	Global Const $__winapiconstant_format_message_from_system = 4096
	Global Const $__winapiconstant_logpixelsx = 88
	Global Const $__winapiconstant_logpixelsy = 90
	Global Const $hgdi_error = Ptr(-1)
	Global Const $invalid_handle_value = Ptr(-1)
	Global Const $clr_invalid = -1
	Global Const $__winapiconstant_flashw_caption = 1
	Global Const $__winapiconstant_flashw_tray = 2
	Global Const $__winapiconstant_flashw_timer = 4
	Global Const $__winapiconstant_flashw_timernofg = 12
	Global Const $__winapiconstant_gw_hwndnext = 2
	Global Const $__winapiconstant_gw_child = 5
	Global Const $__winapiconstant_di_mask = 1
	Global Const $__winapiconstant_di_image = 2
	Global Const $__winapiconstant_di_normal = 3
	Global Const $__winapiconstant_di_compat = 4
	Global Const $__winapiconstant_di_defaultsize = 8
	Global Const $__winapiconstant_di_nomirror = 16
	Global Const $__winapiconstant_display_device_attached_to_desktop = 1
	Global Const $__winapiconstant_display_device_primary_device = 4
	Global Const $__winapiconstant_display_device_mirroring_driver = 8
	Global Const $__winapiconstant_display_device_vga_compatible = 16
	Global Const $__winapiconstant_display_device_removable = 32
	Global Const $__winapiconstant_display_device_modespruned = 134217728
	Global Const $null_brush = 5
	Global Const $null_pen = 8
	Global Const $black_brush = 4
	Global Const $dkgray_brush = 3
	Global Const $dc_brush = 18
	Global Const $gray_brush = 2
	Global Const $hollow_brush = $null_brush
	Global Const $ltgray_brush = 1
	Global Const $white_brush = 0
	Global Const $black_pen = 7
	Global Const $dc_pen = 19
	Global Const $white_pen = 6
	Global Const $ansi_fixed_font = 11
	Global Const $ansi_var_font = 12
	Global Const $device_default_font = 14
	Global Const $default_gui_font = 17
	Global Const $oem_fixed_font = 10
	Global Const $system_font = 13
	Global Const $system_fixed_font = 16
	Global Const $default_palette = 15
	Global Const $mb_precomposed = 1
	Global Const $mb_composite = 2
	Global Const $mb_useglyphchars = 4
	Global Const $ulw_alpha = 2
	Global Const $ulw_colorkey = 1
	Global Const $ulw_opaque = 4
	Global Const $wh_callwndproc = 4
	Global Const $wh_callwndprocret = 12
	Global Const $wh_cbt = 5
	Global Const $wh_debug = 9
	Global Const $wh_foregroundidle = 11
	Global Const $wh_getmessage = 3
	Global Const $wh_journalplayback = 1
	Global Const $wh_journalrecord = 0
	Global Const $wh_keyboard = 2
	Global Const $wh_keyboard_ll = 13
	Global Const $wh_mouse = 7
	Global Const $wh_mouse_ll = 14
	Global Const $wh_msgfilter = -1
	Global Const $wh_shell = 10
	Global Const $wh_sysmsgfilter = 6
	Global Const $wpf_asyncwindowplacement = 4
	Global Const $wpf_restoretomaximized = 2
	Global Const $wpf_setminposition = 1
	Global Const $kf_extended = 256
	Global Const $kf_altdown = 8192
	Global Const $kf_up = 32768
	Global Const $llkhf_extended = BitShift($kf_extended, 8)
	Global Const $llkhf_injected = 16
	Global Const $llkhf_altdown = BitShift($kf_altdown, 8)
	Global Const $llkhf_up = BitShift($kf_up, 8)
	Global Const $ofn_allowmultiselect = 512
	Global Const $ofn_createprompt = 8192
	Global Const $ofn_dontaddtorecent = 33554432
	Global Const $ofn_enablehook = 32
	Global Const $ofn_enableincludenotify = 4194304
	Global Const $ofn_enablesizing = 8388608
	Global Const $ofn_enabletemplate = 64
	Global Const $ofn_enabletemplatehandle = 128
	Global Const $ofn_explorer = 524288
	Global Const $ofn_extensiondifferent = 1024
	Global Const $ofn_filemustexist = 4096
	Global Const $ofn_forceshowhidden = 268435456
	Global Const $ofn_hidereadonly = 4
	Global Const $ofn_longnames = 2097152
	Global Const $ofn_nochangedir = 8
	Global Const $ofn_nodereferencelinks = 1048576
	Global Const $ofn_nolongnames = 262144
	Global Const $ofn_nonetworkbutton = 131072
	Global Const $ofn_noreadonlyreturn = 32768
	Global Const $ofn_notestfilecreate = 65536
	Global Const $ofn_novalidate = 256
	Global Const $ofn_overwriteprompt = 2
	Global Const $ofn_pathmustexist = 2048
	Global Const $ofn_readonly = 1
	Global Const $ofn_shareaware = 16384
	Global Const $ofn_showhelp = 16
	Global Const $ofn_ex_noplacesbar = 1
	Global Const $tagcursorinfo = "dword Size;dword Flags;handle hCursor;" & $tagpoint
	Global Const $tagdisplay_device = "dword Size;wchar Name[32];wchar String[128];dword Flags;wchar ID[128];wchar Key[128]"
	Global Const $tagflashwinfo = "uint Size;hwnd hWnd;dword Flags;uint Count;dword TimeOut"
	Global Const $tagiconinfo = "bool Icon;dword XHotSpot;dword YHotSpot;handle hMask;handle hColor"
	Global Const $tagmemorystatusex = "dword Length;dword MemoryLoad;" & "uint64 TotalPhys;uint64 AvailPhys;uint64 TotalPageFile;uint64 AvailPageFile;" & "uint64 TotalVirtual;uint64 AvailVirtual;uint64 AvailExtendedVirtual"

	Func _winapi_attachconsole($iprocessid = -1)
		Local $aresult = DllCall("kernel32.dll", "bool", "AttachConsole", "dword", $iprocessid)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_attachthreadinput($iattach, $iattachto, $fattach)
		Local $aresult = DllCall("user32.dll", "bool", "AttachThreadInput", "dword", $iattach, "dword", $iattachto, "bool", $fattach)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_beep($ifreq = 500, $iduration = 1000)
		Local $aresult = DllCall("kernel32.dll", "bool", "Beep", "dword", $ifreq, "dword", $iduration)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_bitblt($hdestdc, $ixdest, $iydest, $iwidth, $iheight, $hsrcdc, $ixsrc, $iysrc, $irop)
		Local $aresult = DllCall("gdi32.dll", "bool", "BitBlt", "handle", $hdestdc, "int", $ixdest, "int", $iydest, "int", $iwidth, "int", $iheight, "handle", $hsrcdc, "int", $ixsrc, "int", $iysrc, "dword", $irop)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_callnexthookex($hhk, $icode, $wparam, $lparam)
		Local $aresult = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $hhk, "int", $icode, "wparam", $wparam, "lparam", $lparam)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_callwindowproc($lpprevwndfunc, $hwnd, $msg, $wparam, $lparam)
		Local $aresult = DllCall("user32.dll", "lresult", "CallWindowProc", "ptr", $lpprevwndfunc, "hwnd", $hwnd, "uint", $msg, "wparam", $wparam, "lparam", $lparam)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_clienttoscreen($hwnd, ByRef $tpoint)
		Local $ppoint = DllStructGetPtr($tpoint)
		DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hwnd, "ptr", $ppoint)
		Return SetError(@error, @extended, $tpoint)
	EndFunc

	Func _winapi_closehandle($hobject)
		Local $aresult = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hobject)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_combinergn($hrgndest, $hrgnsrc1, $hrgnsrc2, $icombinemode)
		Local $aresult = DllCall("gdi32.dll", "int", "CombineRgn", "handle", $hrgndest, "handle", $hrgnsrc1, "handle", $hrgnsrc2, "int", $icombinemode)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_commdlgextendederror()
		Local Const $cderr_dialogfailure = 65535
		Local Const $cderr_findresfailure = 6
		Local Const $cderr_initialization = 2
		Local Const $cderr_loadresfailure = 7
		Local Const $cderr_loadstrfailure = 5
		Local Const $cderr_lockresfailure = 8
		Local Const $cderr_memallocfailure = 9
		Local Const $cderr_memlockfailure = 10
		Local Const $cderr_nohinstance = 4
		Local Const $cderr_nohook = 11
		Local Const $cderr_notemplate = 3
		Local Const $cderr_registermsgfail = 12
		Local Const $cderr_structsize = 1
		Local Const $fnerr_buffertoosmall = 12291
		Local Const $fnerr_invalidfilename = 12290
		Local Const $fnerr_subclassfailure = 12289
		Local $aresult = DllCall("comdlg32.dll", "dword", "CommDlgExtendedError")
		If @error Then Return SetError(@error, @extended, 0)
		Switch $aresult[0]
			Case $cderr_dialogfailure
				Return SetError($aresult[0], 0, "The dialog box could not be created." & @LF & "The common dialog box function's call to the DialogBox function failed." & @LF & "For example, this error occurs if the common dialog box call specifies an invalid window handle.")
			Case $cderr_findresfailure
				Return SetError($aresult[0], 0, "The common dialog box function failed to find a specified resource.")
			Case $cderr_initialization
				Return SetError($aresult[0], 0, "The common dialog box function failed during initialization." & @LF & "This error often occurs when sufficient memory is not available.")
			Case $cderr_loadresfailure
				Return SetError($aresult[0], 0, "The common dialog box function failed to load a specified resource.")
			Case $cderr_loadstrfailure
				Return SetError($aresult[0], 0, "The common dialog box function failed to load a specified string.")
			Case $cderr_lockresfailure
				Return SetError($aresult[0], 0, "The common dialog box function failed to lock a specified resource.")
			Case $cderr_memallocfailure
				Return SetError($aresult[0], 0, "The common dialog box function was unable to allocate memory for internal structures.")
			Case $cderr_memlockfailure
				Return SetError($aresult[0], 0, "The common dialog box function was unable to lock the memory associated with a handle.")
			Case $cderr_nohinstance
				Return SetError($aresult[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding instance handle.")
			Case $cderr_nohook
				Return SetError($aresult[0], 0, "The ENABLEHOOK flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a pointer to a corresponding hook procedure.")
			Case $cderr_notemplate
				Return SetError($aresult[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding template.")
			Case $cderr_registermsgfail
				Return SetError($aresult[0], 0, "The RegisterWindowMessage function returned an error code when it was called by the common dialog box function.")
			Case $cderr_structsize
				Return SetError($aresult[0], 0, "The lStructSize member of the initialization structure for the corresponding common dialog box is invalid")
			Case $fnerr_buffertoosmall
				Return SetError($aresult[0], 0, "The buffer pointed to by the lpstrFile member of the OPENFILENAME structure is too small for the file name specified by the user." & @LF & "The first two bytes of the lpstrFile buffer contain an integer value specifying the size, in TCHARs, required to receive the full name.")
			Case $fnerr_invalidfilename
				Return SetError($aresult[0], 0, "A file name is invalid.")
			Case $fnerr_subclassfailure
				Return SetError($aresult[0], 0, "An attempt to subclass a list box failed because sufficient memory was not available.")
		EndSwitch
		Return Hex($aresult[0])
	EndFunc

	Func _winapi_copyicon($hicon)
		Local $aresult = DllCall("user32.dll", "handle", "CopyIcon", "handle", $hicon)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createbitmap($iwidth, $iheight, $iplanes = 1, $ibitsperpel = 1, $pbits = 0)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateBitmap", "int", $iwidth, "int", $iheight, "uint", $iplanes, "uint", $ibitsperpel, "ptr", $pbits)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createcompatiblebitmap($hdc, $iwidth, $iheight)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateCompatibleBitmap", "handle", $hdc, "int", $iwidth, "int", $iheight)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createcompatibledc($hdc)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $hdc)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createevent($pattributes = 0, $fmanualreset = True, $finitialstate = True, $sname = "")
		Local $snametype = "wstr"
		If $sname = "" Then
			$sname = 0
			$snametype = "ptr"
		EndIf
		Local $aresult = DllCall("kernel32.dll", "handle", "CreateEventW", "ptr", $pattributes, "bool", $fmanualreset, "bool", $finitialstate, $snametype, $sname)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createfile($sfilename, $icreation, $iaccess = 4, $ishare = 0, $iattributes = 0, $psecurity = 0)
		Local $ida = 0, $ism = 0, $icd = 0, $ifa = 0
		If BitAND($iaccess, 1) <> 0 Then $ida = BitOR($ida, $generic_execute)
		If BitAND($iaccess, 2) <> 0 Then $ida = BitOR($ida, $generic_read)
		If BitAND($iaccess, 4) <> 0 Then $ida = BitOR($ida, $generic_write)
		If BitAND($ishare, 1) <> 0 Then $ism = BitOR($ism, $file_share_delete)
		If BitAND($ishare, 2) <> 0 Then $ism = BitOR($ism, $file_share_read)
		If BitAND($ishare, 4) <> 0 Then $ism = BitOR($ism, $file_share_write)
		Switch $icreation
			Case 0
				$icd = $create_new
			Case 1
				$icd = $create_always
			Case 2
				$icd = $open_existing
			Case 3
				$icd = $open_always
			Case 4
				$icd = $truncate_existing
		EndSwitch
		If BitAND($iattributes, 1) <> 0 Then $ifa = BitOR($ifa, $file_attribute_archive)
		If BitAND($iattributes, 2) <> 0 Then $ifa = BitOR($ifa, $file_attribute_hidden)
		If BitAND($iattributes, 4) <> 0 Then $ifa = BitOR($ifa, $file_attribute_readonly)
		If BitAND($iattributes, 8) <> 0 Then $ifa = BitOR($ifa, $file_attribute_system)
		Local $aresult = DllCall("kernel32.dll", "handle", "CreateFileW", "wstr", $sfilename, "dword", $ida, "dword", $ism, "ptr", $psecurity, "dword", $icd, "dword", $ifa, "ptr", 0)
		If @error OR $aresult[0] = Ptr(-1) Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createfont($nheight, $nwidth, $nescape = 0, $norientn = 0, $fnweight = $__winapiconstant_fw_normal, $bitalic = False, $bunderline = False, $bstrikeout = False, $ncharset = $__winapiconstant_default_charset, $noutputprec = $__winapiconstant_out_default_precis, $nclipprec = $__winapiconstant_clip_default_precis, $nquality = $__winapiconstant_default_quality, $npitch = 0, $szface = "Arial")
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateFontW", "int", $nheight, "int", $nwidth, "int", $nescape, "int", $norientn, "int", $fnweight, "dword", $bitalic, "dword", $bunderline, "dword", $bstrikeout, "dword", $ncharset, "dword", $noutputprec, "dword", $nclipprec, "dword", $nquality, "dword", $npitch, "wstr", $szface)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createfontindirect($tlogfont)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateFontIndirectW", "ptr", DllStructGetPtr($tlogfont))
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createpen($ipenstyle, $iwidth, $ncolor)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreatePen", "int", $ipenstyle, "int", $iwidth, "dword", $ncolor)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createprocess($sappname, $scommand, $psecurity, $pthread, $finherit, $iflags, $penviron, $sdir, $pstartupinfo, $pprocess)
		Local $pcommand = 0
		Local $sappnametype = "wstr", $sdirtype = "wstr"
		If $sappname = "" Then
			$sappnametype = "ptr"
			$sappname = 0
		EndIf
		If $scommand <> "" Then
			Local $tcommand = DllStructCreate("wchar Text[" & 260 + 1 & "]")
			$pcommand = DllStructGetPtr($tcommand)
			DllStructSetData($tcommand, "Text", $scommand)
		EndIf
		If $sdir = "" Then
			$sdirtype = "ptr"
			$sdir = 0
		EndIf
		Local $aresult = DllCall("kernel32.dll", "bool", "CreateProcessW", $sappnametype, $sappname, "ptr", $pcommand, "ptr", $psecurity, "ptr", $pthread, "bool", $finherit, "dword", $iflags, "ptr", $penviron, $sdirtype, $sdir, "ptr", $pstartupinfo, "ptr", $pprocess)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_createrectrgn($ileftrect, $itoprect, $irightrect, $ibottomrect)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateRectRgn", "int", $ileftrect, "int", $itoprect, "int", $irightrect, "int", $ibottomrect)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createroundrectrgn($ileftrect, $itoprect, $irightrect, $ibottomrect, $iwidthellipse, $iheightellipse)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateRoundRectRgn", "int", $ileftrect, "int", $itoprect, "int", $irightrect, "int", $ibottomrect, "int", $iwidthellipse, "int", $iheightellipse)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createsolidbitmap($hwnd, $icolor, $iwidth, $iheight, $brgb = 1)
		Local $hdc = _winapi_getdc($hwnd)
		Local $hdestdc = _winapi_createcompatibledc($hdc)
		Local $hbitmap = _winapi_createcompatiblebitmap($hdc, $iwidth, $iheight)
		Local $hold = _winapi_selectobject($hdestdc, $hbitmap)
		Local $trect = DllStructCreate($tagrect)
		DllStructSetData($trect, 1, 0)
		DllStructSetData($trect, 2, 0)
		DllStructSetData($trect, 3, $iwidth)
		DllStructSetData($trect, 4, $iheight)
		If $brgb Then
			$icolor = BitOR(BitAND($icolor, 65280), BitShift(BitAND($icolor, 255), -16), BitShift(BitAND($icolor, 16711680), 16))
		EndIf
		Local $hbrush = _winapi_createsolidbrush($icolor)
		_winapi_fillrect($hdestdc, DllStructGetPtr($trect), $hbrush)
		If @error Then
			_winapi_deleteobject($hbitmap)
			$hbitmap = 0
		EndIf
		_winapi_deleteobject($hbrush)
		_winapi_releasedc($hwnd, $hdc)
		_winapi_selectobject($hdestdc, $hold)
		_winapi_deletedc($hdestdc)
		If NOT $hbitmap Then Return SetError(1, 0, 0)
		Return $hbitmap
	EndFunc

	Func _winapi_createsolidbrush($ncolor)
		Local $aresult = DllCall("gdi32.dll", "handle", "CreateSolidBrush", "dword", $ncolor)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_createwindowex($iexstyle, $sclass, $sname, $istyle, $ix, $iy, $iwidth, $iheight, $hparent, $hmenu = 0, $hinstance = 0, $pparam = 0)
		If $hinstance = 0 Then $hinstance = _winapi_getmodulehandle("")
		Local $aresult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iexstyle, "wstr", $sclass, "wstr", $sname, "dword", $istyle, "int", $ix, "int", $iy, "int", $iwidth, "int", $iheight, "hwnd", $hparent, "handle", $hmenu, "handle", $hinstance, "ptr", $pparam)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_defwindowproc($hwnd, $imsg, $iwparam, $ilparam)
		Local $aresult = DllCall("user32.dll", "lresult", "DefWindowProc", "hwnd", $hwnd, "uint", $imsg, "wparam", $iwparam, "lparam", $ilparam)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_deletedc($hdc)
		Local $aresult = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $hdc)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_deleteobject($hobject)
		Local $aresult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hobject)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_destroyicon($hicon)
		Local $aresult = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hicon)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_destroywindow($hwnd)
		Local $aresult = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_drawedge($hdc, $ptrrect, $nedgetype, $grfflags)
		Local $aresult = DllCall("user32.dll", "bool", "DrawEdge", "handle", $hdc, "ptr", $ptrrect, "uint", $nedgetype, "uint", $grfflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_drawframecontrol($hdc, $ptrrect, $ntype, $nstate)
		Local $aresult = DllCall("user32.dll", "bool", "DrawFrameControl", "handle", $hdc, "ptr", $ptrrect, "uint", $ntype, "uint", $nstate)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_drawicon($hdc, $ix, $iy, $hicon)
		Local $aresult = DllCall("user32.dll", "bool", "DrawIcon", "handle", $hdc, "int", $ix, "int", $iy, "handle", $hicon)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_drawiconex($hdc, $ix, $iy, $hicon, $iwidth = 0, $iheight = 0, $istep = 0, $hbrush = 0, $iflags = 3)
		Local $ioptions
		Switch $iflags
			Case 1
				$ioptions = $__winapiconstant_di_mask
			Case 2
				$ioptions = $__winapiconstant_di_image
			Case 3
				$ioptions = $__winapiconstant_di_normal
			Case 4
				$ioptions = $__winapiconstant_di_compat
			Case 5
				$ioptions = $__winapiconstant_di_defaultsize
			Case Else
				$ioptions = $__winapiconstant_di_nomirror
		EndSwitch
		Local $aresult = DllCall("user32.dll", "bool", "DrawIconEx", "handle", $hdc, "int", $ix, "int", $iy, "handle", $hicon, "int", $iwidth, "int", $iheight, "uint", $istep, "handle", $hbrush, "uint", $ioptions)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_drawline($hdc, $ix1, $iy1, $ix2, $iy2)
		_winapi_moveto($hdc, $ix1, $iy1)
		If @error Then Return SetError(@error, @extended, False)
		_winapi_lineto($hdc, $ix2, $iy2)
		If @error Then Return SetError(@error, @extended, False)
		Return True
	EndFunc

	Func _winapi_drawtext($hdc, $stext, ByRef $trect, $iflags)
		Local $aresult = DllCall("user32.dll", "int", "DrawTextW", "handle", $hdc, "wstr", $stext, "int", -1, "ptr", DllStructGetPtr($trect), "uint", $iflags)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_enablewindow($hwnd, $fenable = True)
		Local $aresult = DllCall("user32.dll", "bool", "EnableWindow", "hwnd", $hwnd, "bool", $fenable)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_enumdisplaydevices($sdevice, $idevnum)
		Local $pname = 0, $iflags = 0, $adevice[5]
		If $sdevice <> "" Then
			Local $tname = DllStructCreate("wchar Text[" & StringLen($sdevice) + 1 & "]")
			$pname = DllStructGetPtr($tname)
			DllStructSetData($tname, "Text", $sdevice)
		EndIf
		Local $tdevice = DllStructCreate($tagdisplay_device)
		Local $pdevice = DllStructGetPtr($tdevice)
		Local $idevice = DllStructGetSize($tdevice)
		DllStructSetData($tdevice, "Size", $idevice)
		DllCall("user32.dll", "bool", "EnumDisplayDevicesW", "ptr", $pname, "dword", $idevnum, "ptr", $pdevice, "dword", 1)
		If @error Then Return SetError(@error, @extended, 0)
		Local $in = DllStructGetData($tdevice, "Flags")
		If BitAND($in, $__winapiconstant_display_device_attached_to_desktop) <> 0 Then $iflags = BitOR($iflags, 1)
		If BitAND($in, $__winapiconstant_display_device_primary_device) <> 0 Then $iflags = BitOR($iflags, 2)
		If BitAND($in, $__winapiconstant_display_device_mirroring_driver) <> 0 Then $iflags = BitOR($iflags, 4)
		If BitAND($in, $__winapiconstant_display_device_vga_compatible) <> 0 Then $iflags = BitOR($iflags, 8)
		If BitAND($in, $__winapiconstant_display_device_removable) <> 0 Then $iflags = BitOR($iflags, 16)
		If BitAND($in, $__winapiconstant_display_device_modespruned) <> 0 Then $iflags = BitOR($iflags, 32)
		$adevice[0] = True
		$adevice[1] = DllStructGetData($tdevice, "Name")
		$adevice[2] = DllStructGetData($tdevice, "String")
		$adevice[3] = $iflags
		$adevice[4] = DllStructGetData($tdevice, "ID")
		Return $adevice
	EndFunc

	Func _winapi_enumwindows($fvisible = True, $hwnd = Default)
		__winapi_enumwindowsinit()
		If $hwnd = Default Then $hwnd = _winapi_getdesktopwindow()
		__winapi_enumwindowschild($hwnd, $fvisible)
		Return $__gawinlist_winapi
	EndFunc

	Func __winapi_enumwindowsadd($hwnd, $sclass = "")
		If $sclass = "" Then $sclass = _winapi_getclassname($hwnd)
		$__gawinlist_winapi[0][0] += 1
		Local $icount = $__gawinlist_winapi[0][0]
		If $icount >= $__gawinlist_winapi[0][1] Then
			ReDim $__gawinlist_winapi[$icount + 64][2]
			$__gawinlist_winapi[0][1] += 64
		EndIf
		$__gawinlist_winapi[$icount][0] = $hwnd
		$__gawinlist_winapi[$icount][1] = $sclass
	EndFunc

	Func __winapi_enumwindowschild($hwnd, $fvisible = True)
		$hwnd = _winapi_getwindow($hwnd, $__winapiconstant_gw_child)
		While $hwnd <> 0
			If (NOT $fvisible) OR _winapi_iswindowvisible($hwnd) Then
				__winapi_enumwindowschild($hwnd, $fvisible)
				__winapi_enumwindowsadd($hwnd)
			EndIf
			$hwnd = _winapi_getwindow($hwnd, $__winapiconstant_gw_hwndnext)
		WEnd
	EndFunc

	Func __winapi_enumwindowsinit()
		ReDim $__gawinlist_winapi[64][2]
		$__gawinlist_winapi[0][0] = 0
		$__gawinlist_winapi[0][1] = 64
	EndFunc

	Func _winapi_enumwindowspopup()
		__winapi_enumwindowsinit()
		Local $hwnd = _winapi_getwindow(_winapi_getdesktopwindow(), $__winapiconstant_gw_child)
		Local $sclass
		While $hwnd <> 0
			If _winapi_iswindowvisible($hwnd) Then
				$sclass = _winapi_getclassname($hwnd)
				If $sclass = "#32768" Then
					__winapi_enumwindowsadd($hwnd)
				ElseIf $sclass = "ToolbarWindow32" Then
					__winapi_enumwindowsadd($hwnd)
				ElseIf $sclass = "ToolTips_Class32" Then
					__winapi_enumwindowsadd($hwnd)
				ElseIf $sclass = "BaseBar" Then
					__winapi_enumwindowschild($hwnd)
				EndIf
			EndIf
			$hwnd = _winapi_getwindow($hwnd, $__winapiconstant_gw_hwndnext)
		WEnd
		Return $__gawinlist_winapi
	EndFunc

	Func _winapi_enumwindowstop()
		__winapi_enumwindowsinit()
		Local $hwnd = _winapi_getwindow(_winapi_getdesktopwindow(), $__winapiconstant_gw_child)
		While $hwnd <> 0
			If _winapi_iswindowvisible($hwnd) Then __winapi_enumwindowsadd($hwnd)
			$hwnd = _winapi_getwindow($hwnd, $__winapiconstant_gw_hwndnext)
		WEnd
		Return $__gawinlist_winapi
	EndFunc

	Func _winapi_expandenvironmentstrings($sstring)
		Local $aresult = DllCall("kernel32.dll", "dword", "ExpandEnvironmentStringsW", "wstr", $sstring, "wstr", "", "dword", 4096)
		If @error Then Return SetError(@error, @extended, "")
		Return $aresult[2]
	EndFunc

	Func _winapi_extracticonex($sfile, $iindex, $plarge, $psmall, $iicons)
		Local $aresult = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sfile, "int", $iindex, "handle", $plarge, "handle", $psmall, "uint", $iicons)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_fatalappexit($smessage)
		DllCall("kernel32.dll", "none", "FatalAppExitW", "uint", 0, "wstr", $smessage)
		If @error Then Return SetError(@error, @extended)
	EndFunc

	Func _winapi_fillrect($hdc, $ptrrect, $hbrush)
		Local $aresult
		If IsPtr($hbrush) Then
			$aresult = DllCall("user32.dll", "int", "FillRect", "handle", $hdc, "ptr", $ptrrect, "handle", $hbrush)
		Else
			$aresult = DllCall("user32.dll", "int", "FillRect", "handle", $hdc, "ptr", $ptrrect, "dword", $hbrush)
		EndIf
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_findexecutable($sfilename, $sdirectory = "")
		Local $aresult = DllCall("shell32.dll", "INT", "FindExecutableW", "wstr", $sfilename, "wstr", $sdirectory, "wstr", "")
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $aresult[3])
	EndFunc

	Func _winapi_findwindow($sclassname, $swindowname)
		Local $aresult = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $sclassname, "wstr", $swindowname)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_flashwindow($hwnd, $finvert = True)
		Local $aresult = DllCall("user32.dll", "bool", "FlashWindow", "hwnd", $hwnd, "bool", $finvert)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_flashwindowex($hwnd, $iflags = 3, $icount = 3, $itimeout = 0)
		Local $tflash = DllStructCreate($tagflashwinfo)
		Local $pflash = DllStructGetPtr($tflash)
		Local $iflash = DllStructGetSize($tflash)
		Local $imode = 0
		If BitAND($iflags, 1) <> 0 Then $imode = BitOR($imode, $__winapiconstant_flashw_caption)
		If BitAND($iflags, 2) <> 0 Then $imode = BitOR($imode, $__winapiconstant_flashw_tray)
		If BitAND($iflags, 4) <> 0 Then $imode = BitOR($imode, $__winapiconstant_flashw_timer)
		If BitAND($iflags, 8) <> 0 Then $imode = BitOR($imode, $__winapiconstant_flashw_timernofg)
		DllStructSetData($tflash, "Size", $iflash)
		DllStructSetData($tflash, "hWnd", $hwnd)
		DllStructSetData($tflash, "Flags", $imode)
		DllStructSetData($tflash, "Count", $icount)
		DllStructSetData($tflash, "Timeout", $itimeout)
		Local $aresult = DllCall("user32.dll", "bool", "FlashWindowEx", "ptr", $pflash)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_floattoint($nfloat)
		Local $tfloat = DllStructCreate("float")
		Local $tint = DllStructCreate("int", DllStructGetPtr($tfloat))
		DllStructSetData($tfloat, 1, $nfloat)
		Return DllStructGetData($tint, 1)
	EndFunc

	Func _winapi_flushfilebuffers($hfile)
		Local $aresult = DllCall("kernel32.dll", "bool", "FlushFileBuffers", "handle", $hfile)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_formatmessage($iflags, $psource, $imessageid, $ilanguageid, ByRef $pbuffer, $isize, $varguments)
		Local $sbuffertype = "ptr"
		If IsString($pbuffer) Then $sbuffertype = "wstr"
		Local $aresult = DllCall("Kernel32.dll", "dword", "FormatMessageW", "dword", $iflags, "ptr", $psource, "dword", $imessageid, "dword", $ilanguageid, $sbuffertype, $pbuffer, "dword", $isize, "ptr", $varguments)
		If @error Then Return SetError(@error, @extended, 0)
		If $sbuffertype = "wstr" Then $pbuffer = $aresult[5]
		Return $aresult[0]
	EndFunc

	Func _winapi_framerect($hdc, $ptrrect, $hbrush)
		Local $aresult = DllCall("user32.dll", "int", "FrameRect", "handle", $hdc, "ptr", $ptrrect, "handle", $hbrush)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_freelibrary($hmodule)
		Local $aresult = DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hmodule)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_getancestor($hwnd, $iflags = 1)
		Local $aresult = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $hwnd, "uint", $iflags)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getasynckeystate($ikey)
		Local $aresult = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", $ikey)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getbkmode($hdc)
		Local $aresult = DllCall("gdi32.dll", "int", "GetBkMode", "handle", $hdc)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getclassname($hwnd)
		If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
		Local $aresult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hwnd, "wstr", "", "int", 4096)
		If @error Then Return SetError(@error, @extended, False)
		Return SetExtended($aresult[0], $aresult[2])
	EndFunc

	Func _winapi_getclientheight($hwnd)
		Local $trect = _winapi_getclientrect($hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($trect, "Bottom") - DllStructGetData($trect, "Top")
	EndFunc

	Func _winapi_getclientwidth($hwnd)
		Local $trect = _winapi_getclientrect($hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($trect, "Right") - DllStructGetData($trect, "Left")
	EndFunc

	Func _winapi_getclientrect($hwnd)
		Local $trect = DllStructCreate($tagrect)
		DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hwnd, "ptr", DllStructGetPtr($trect))
		If @error Then Return SetError(@error, @extended, 0)
		Return $trect
	EndFunc

	Func _winapi_getcurrentprocess()
		Local $aresult = DllCall("kernel32.dll", "handle", "GetCurrentProcess")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getcurrentprocessid()
		Local $aresult = DllCall("kernel32.dll", "dword", "GetCurrentProcessId")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getcurrentthread()
		Local $aresult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getcurrentthreadid()
		Local $aresult = DllCall("kernel32.dll", "dword", "GetCurrentThreadId")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getcursorinfo()
		Local $tcursor = DllStructCreate($tagcursorinfo)
		Local $icursor = DllStructGetSize($tcursor)
		DllStructSetData($tcursor, "Size", $icursor)
		DllCall("user32.dll", "bool", "GetCursorInfo", "ptr", DllStructGetPtr($tcursor))
		If @error Then Return SetError(@error, @extended, 0)
		Local $acursor[5]
		$acursor[0] = True
		$acursor[1] = DllStructGetData($tcursor, "Flags") <> 0
		$acursor[2] = DllStructGetData($tcursor, "hCursor")
		$acursor[3] = DllStructGetData($tcursor, "X")
		$acursor[4] = DllStructGetData($tcursor, "Y")
		Return $acursor
	EndFunc

	Func _winapi_getdc($hwnd)
		Local $aresult = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getdesktopwindow()
		Local $aresult = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getdevicecaps($hdc, $iindex)
		Local $aresult = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hdc, "int", $iindex)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getdibits($hdc, $hbmp, $istartscan, $iscanlines, $pbits, $pbi, $iusage)
		Local $aresult = DllCall("gdi32.dll", "int", "GetDIBits", "handle", $hdc, "handle", $hbmp, "uint", $istartscan, "uint", $iscanlines, "ptr", $pbits, "ptr", $pbi, "uint", $iusage)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_getdlgctrlid($hwnd)
		Local $aresult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getdlgitem($hwnd, $iitemid)
		Local $aresult = DllCall("user32.dll", "hwnd", "GetDlgItem", "hwnd", $hwnd, "int", $iitemid)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getfocus()
		Local $aresult = DllCall("user32.dll", "hwnd", "GetFocus")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getforegroundwindow()
		Local $aresult = DllCall("user32.dll", "hwnd", "GetForegroundWindow")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getguiresources($iflag = 0, $hprocess = -1)
		If $hprocess = -1 Then $hprocess = _winapi_getcurrentprocess()
		Local $aresult = DllCall("user32.dll", "dword", "GetGuiResources", "handle", $hprocess, "dword", $iflag)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_geticoninfo($hicon)
		Local $tinfo = DllStructCreate($tagiconinfo)
		DllCall("user32.dll", "bool", "GetIconInfo", "handle", $hicon, "ptr", DllStructGetPtr($tinfo))
		If @error Then Return SetError(@error, @extended, 0)
		Local $aicon[6]
		$aicon[0] = True
		$aicon[1] = DllStructGetData($tinfo, "Icon") <> 0
		$aicon[2] = DllStructGetData($tinfo, "XHotSpot")
		$aicon[3] = DllStructGetData($tinfo, "YHotSpot")
		$aicon[4] = DllStructGetData($tinfo, "hMask")
		$aicon[5] = DllStructGetData($tinfo, "hColor")
		Return $aicon
	EndFunc

	Func _winapi_getfilesizeex($hfile)
		Local $aresult = DllCall("kernel32.dll", "bool", "GetFileSizeEx", "handle", $hfile, "int64*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[2]
	EndFunc

	Func _winapi_getlasterrormessage()
		Local $tbufferptr = DllStructCreate("ptr")
		Local $pbufferptr = DllStructGetPtr($tbufferptr)
		Local $ncount = _winapi_formatmessage(BitOR($__winapiconstant_format_message_allocate_buffer, $__winapiconstant_format_message_from_system), 0, _winapi_getlasterror(), 0, $pbufferptr, 0, 0)
		If @error Then Return SetError(@error, 0, "")
		Local $stext = ""
		Local $pbuffer = DllStructGetData($tbufferptr, 1)
		If $pbuffer Then
			If $ncount > 0 Then
				Local $tbuffer = DllStructCreate("wchar[" & ($ncount + 1) & "]", $pbuffer)
				$stext = DllStructGetData($tbuffer, 1)
			EndIf
			_winapi_localfree($pbuffer)
		EndIf
		Return $stext
	EndFunc

	Func _winapi_getlayeredwindowattributes($hwnd, ByRef $i_transcolor, ByRef $transparency, $ascolorref = False)
		$i_transcolor = -1
		$transparency = -1
		Local $aresult = DllCall("user32.dll", "bool", "GetLayeredWindowAttributes", "hwnd", $hwnd, "dword*", $i_transcolor, "byte*", $transparency, "dword*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		If NOT $ascolorref Then
			$aresult[2] = Hex(String($aresult[2]), 6)
			$aresult[2] = "0x" & StringMid($aresult[2], 5, 2) & StringMid($aresult[2], 3, 2) & StringMid($aresult[2], 1, 2)
		EndIf
		$i_transcolor = $aresult[2]
		$transparency = $aresult[3]
		Return $aresult[4]
	EndFunc

	Func _winapi_getmodulehandle($smodulename)
		Local $smodulenametype = "wstr"
		If $smodulename = "" Then
			$smodulename = 0
			$smodulenametype = "ptr"
		EndIf
		Local $aresult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $smodulenametype, $smodulename)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getmousepos($ftoclient = False, $hwnd = 0)
		Local $imode = Opt("MouseCoordMode", 1)
		Local $apos = MouseGetPos()
		Opt("MouseCoordMode", $imode)
		Local $tpoint = DllStructCreate($tagpoint)
		DllStructSetData($tpoint, "X", $apos[0])
		DllStructSetData($tpoint, "Y", $apos[1])
		If $ftoclient Then
			_winapi_screentoclient($hwnd, $tpoint)
			If @error Then Return SetError(@error, @extended, 0)
		EndIf
		Return $tpoint
	EndFunc

	Func _winapi_getmouseposx($ftoclient = False, $hwnd = 0)
		Local $tpoint = _winapi_getmousepos($ftoclient, $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($tpoint, "X")
	EndFunc

	Func _winapi_getmouseposy($ftoclient = False, $hwnd = 0)
		Local $tpoint = _winapi_getmousepos($ftoclient, $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($tpoint, "Y")
	EndFunc

	Func _winapi_getobject($hobject, $isize, $pobject)
		Local $aresult = DllCall("gdi32.dll", "int", "GetObject", "handle", $hobject, "int", $isize, "ptr", $pobject)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getopenfilename($stitle = "", $sfilter = "All files (*.*)", $sinitaldir = ".", $sdefaultfile = "", $sdefaultext = "", $ifilterindex = 1, $iflags = 0, $iflagsex = 0, $hwndowner = 0)
		Local $ipathlen = 4096
		Local $inulls = 0
		Local $tofn = DllStructCreate($tagopenfilename)
		Local $afiles[1] = [0]
		Local $iflag = $iflags
		Local $asflines = StringSplit($sfilter, "|")
		Local $asfilter[$asflines[0] * 2 + 1]
		Local $istart, $ifinal, $stfilter
		$asfilter[0] = $asflines[0] * 2
		For $i = 1 To $asflines[0]
			$istart = StringInStr($asflines[$i], "(", 0, 1)
			$ifinal = StringInStr($asflines[$i], ")", 0, -1)
			$asfilter[$i * 2 - 1] = StringStripWS(StringLeft($asflines[$i], $istart - 1), 3)
			$asfilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asflines[$i], $istart), StringLen($asflines[$i]) - $ifinal + 1), 3)
			$stfilter &= "wchar[" & StringLen($asfilter[$i * 2 - 1]) + 1 & "];wchar[" & StringLen($asfilter[$i * 2]) + 1 & "];"
		Next
		Local $ttitle = DllStructCreate("wchar Title[" & StringLen($stitle) + 1 & "]")
		Local $tinitialdir = DllStructCreate("wchar InitDir[" & StringLen($sinitaldir) + 1 & "]")
		Local $tfilter = DllStructCreate($stfilter & "wchar")
		Local $tpath = DllStructCreate("wchar Path[" & $ipathlen & "]")
		Local $textn = DllStructCreate("wchar Extension[" & StringLen($sdefaultext) + 1 & "]")
		For $i = 1 To $asfilter[0]
			DllStructSetData($tfilter, $i, $asfilter[$i])
		Next
		DllStructSetData($ttitle, "Title", $stitle)
		DllStructSetData($tinitialdir, "InitDir", $sinitaldir)
		DllStructSetData($tpath, "Path", $sdefaultfile)
		DllStructSetData($textn, "Extension", $sdefaultext)
		DllStructSetData($tofn, "StructSize", DllStructGetSize($tofn))
		DllStructSetData($tofn, "hwndOwner", $hwndowner)
		DllStructSetData($tofn, "lpstrFilter", DllStructGetPtr($tfilter))
		DllStructSetData($tofn, "nFilterIndex", $ifilterindex)
		DllStructSetData($tofn, "lpstrFile", DllStructGetPtr($tpath))
		DllStructSetData($tofn, "nMaxFile", $ipathlen)
		DllStructSetData($tofn, "lpstrInitialDir", DllStructGetPtr($tinitialdir))
		DllStructSetData($tofn, "lpstrTitle", DllStructGetPtr($ttitle))
		DllStructSetData($tofn, "Flags", $iflag)
		DllStructSetData($tofn, "lpstrDefExt", DllStructGetPtr($textn))
		DllStructSetData($tofn, "FlagsEx", $iflagsex)
		DllCall("comdlg32.dll", "bool", "GetOpenFileNameW", "ptr", DllStructGetPtr($tofn))
		If @error Then Return SetError(@error, @extended, $afiles)
		If BitAND($iflags, $ofn_allowmultiselect) = $ofn_allowmultiselect AND BitAND($iflags, $ofn_explorer) = $ofn_explorer Then
			For $x = 1 To $ipathlen
				If DllStructGetData($tpath, "Path", $x) = Chr(0) Then
					DllStructSetData($tpath, "Path", "|", $x)
					$inulls += 1
				Else
					$inulls = 0
				EndIf
				If $inulls = 2 Then ExitLoop
			Next
			DllStructSetData($tpath, "Path", Chr(0), $x - 1)
			$afiles = StringSplit(DllStructGetData($tpath, "Path"), "|")
			If $afiles[0] = 1 Then Return __winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
			Return StringSplit(DllStructGetData($tpath, "Path"), "|")
		ElseIf BitAND($iflags, $ofn_allowmultiselect) = $ofn_allowmultiselect Then
			$afiles = StringSplit(DllStructGetData($tpath, "Path"), " ")
			If $afiles[0] = 1 Then Return __winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
			Return StringSplit(StringReplace(DllStructGetData($tpath, "Path"), " ", "|"), "|")
		Else
			Return __winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
		EndIf
	EndFunc

	Func _winapi_getoverlappedresult($hfile, $poverlapped, ByRef $ibytes, $fwait = False)
		Local $aresult = DllCall("kernel32.dll", "bool", "GetOverlappedResult", "handle", $hfile, "ptr", $poverlapped, "dword*", 0, "bool", $fwait)
		If @error Then Return SetError(@error, @extended, False)
		$ibytes = $aresult[3]
		Return $aresult[0]
	EndFunc

	Func _winapi_getparent($hwnd)
		Local $aresult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getprocessaffinitymask($hprocess)
		Local $aresult = DllCall("kernel32.dll", "bool", "GetProcessAffinityMask", "handle", $hprocess, "dword_ptr*", 0, "dword_ptr*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Local $amask[3]
		$amask[0] = True
		$amask[1] = $aresult[2]
		$amask[2] = $aresult[3]
		Return $amask
	EndFunc

	Func _winapi_getsavefilename($stitle = "", $sfilter = "All files (*.*)", $sinitaldir = ".", $sdefaultfile = "", $sdefaultext = "", $ifilterindex = 1, $iflags = 0, $iflagsex = 0, $hwndowner = 0)
		Local $ipathlen = 4096
		Local $tofn = DllStructCreate($tagopenfilename)
		Local $afiles[1] = [0]
		Local $iflag = $iflags
		Local $asflines = StringSplit($sfilter, "|")
		Local $asfilter[$asflines[0] * 2 + 1]
		Local $istart, $ifinal, $stfilter
		$asfilter[0] = $asflines[0] * 2
		For $i = 1 To $asflines[0]
			$istart = StringInStr($asflines[$i], "(", 0, 1)
			$ifinal = StringInStr($asflines[$i], ")", 0, -1)
			$asfilter[$i * 2 - 1] = StringStripWS(StringLeft($asflines[$i], $istart - 1), 3)
			$asfilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asflines[$i], $istart), StringLen($asflines[$i]) - $ifinal + 1), 3)
			$stfilter &= "wchar[" & StringLen($asfilter[$i * 2 - 1]) + 1 & "];wchar[" & StringLen($asfilter[$i * 2]) + 1 & "];"
		Next
		Local $ttitle = DllStructCreate("wchar Title[" & StringLen($stitle) + 1 & "]")
		Local $tinitialdir = DllStructCreate("wchar InitDir[" & StringLen($sinitaldir) + 1 & "]")
		Local $tfilter = DllStructCreate($stfilter & "wchar")
		Local $tpath = DllStructCreate("wchar Path[" & $ipathlen & "]")
		Local $textn = DllStructCreate("wchar Extension[" & StringLen($sdefaultext) + 1 & "]")
		For $i = 1 To $asfilter[0]
			DllStructSetData($tfilter, $i, $asfilter[$i])
		Next
		DllStructSetData($ttitle, "Title", $stitle)
		DllStructSetData($tinitialdir, "InitDir", $sinitaldir)
		DllStructSetData($tpath, "Path", $sdefaultfile)
		DllStructSetData($textn, "Extension", $sdefaultext)
		DllStructSetData($tofn, "StructSize", DllStructGetSize($tofn))
		DllStructSetData($tofn, "hwndOwner", $hwndowner)
		DllStructSetData($tofn, "lpstrFilter", DllStructGetPtr($tfilter))
		DllStructSetData($tofn, "nFilterIndex", $ifilterindex)
		DllStructSetData($tofn, "lpstrFile", DllStructGetPtr($tpath))
		DllStructSetData($tofn, "nMaxFile", $ipathlen)
		DllStructSetData($tofn, "lpstrInitialDir", DllStructGetPtr($tinitialdir))
		DllStructSetData($tofn, "lpstrTitle", DllStructGetPtr($ttitle))
		DllStructSetData($tofn, "Flags", $iflag)
		DllStructSetData($tofn, "lpstrDefExt", DllStructGetPtr($textn))
		DllStructSetData($tofn, "FlagsEx", $iflagsex)
		DllCall("comdlg32.dll", "bool", "GetSaveFileNameW", "ptr", DllStructGetPtr($tofn))
		If @error Then Return SetError(@error, @extended, $afiles)
		Return __winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
	EndFunc

	Func _winapi_getstockobject($iobject)
		Local $aresult = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $iobject)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getstdhandle($istdhandle)
		If $istdhandle < 0 OR $istdhandle > 2 Then Return SetError(2, 0, -1)
		Local Const $ahandle[3] = [-10, -11, -12]
		Local $aresult = DllCall("kernel32.dll", "handle", "GetStdHandle", "dword", $ahandle[$istdhandle])
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_getsyscolor($iindex)
		Local $aresult = DllCall("user32.dll", "dword", "GetSysColor", "int", $iindex)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getsyscolorbrush($iindex)
		Local $aresult = DllCall("user32.dll", "handle", "GetSysColorBrush", "int", $iindex)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getsystemmetrics($iindex)
		Local $aresult = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $iindex)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_gettextextentpoint32($hdc, $stext)
		Local $tsize = DllStructCreate($tagsize)
		Local $isize = StringLen($stext)
		DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hdc, "wstr", $stext, "int", $isize, "ptr", DllStructGetPtr($tsize))
		If @error Then Return SetError(@error, @extended, 0)
		Return $tsize
	EndFunc

	Func _winapi_getwindow($hwnd, $icmd)
		Local $aresult = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $hwnd, "uint", $icmd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getwindowdc($hwnd)
		Local $aresult = DllCall("user32.dll", "handle", "GetWindowDC", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getwindowheight($hwnd)
		Local $trect = _winapi_getwindowrect($hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($trect, "Bottom") - DllStructGetData($trect, "Top")
	EndFunc

	Func _winapi_getwindowlong($hwnd, $iindex)
		Local $sfuncname = "GetWindowLongW"
		If @AutoItX64 Then $sfuncname = "GetWindowLongPtrW"
		Local $aresult = DllCall("user32.dll", "long_ptr", $sfuncname, "hwnd", $hwnd, "int", $iindex)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getwindowplacement($hwnd)
		Local $twindowplacement = DllStructCreate($tagwindowplacement)
		DllStructSetData($twindowplacement, "length", DllStructGetSize($twindowplacement))
		Local $pwindowplacement = DllStructGetPtr($twindowplacement)
		DllCall("user32.dll", "bool", "GetWindowPlacement", "hwnd", $hwnd, "ptr", $pwindowplacement)
		If @error Then Return SetError(@error, @extended, 0)
		Return $twindowplacement
	EndFunc

	Func _winapi_getwindowrect($hwnd)
		Local $trect = DllStructCreate($tagrect)
		DllCall("user32.dll", "bool", "GetWindowRect", "hwnd", $hwnd, "ptr", DllStructGetPtr($trect))
		If @error Then Return SetError(@error, @extended, 0)
		Return $trect
	EndFunc

	Func _winapi_getwindowrgn($hwnd, $hrgn)
		Local $aresult = DllCall("user32.dll", "int", "GetWindowRgn", "hwnd", $hwnd, "handle", $hrgn)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_getwindowtext($hwnd)
		Local $aresult = DllCall("user32.dll", "int", "GetWindowTextW", "hwnd", $hwnd, "wstr", "", "int", 4096)
		If @error Then Return SetError(@error, @extended, "")
		Return SetExtended($aresult[0], $aresult[2])
	EndFunc

	Func _winapi_getwindowthreadprocessid($hwnd, ByRef $ipid)
		Local $aresult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hwnd, "dword*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		$ipid = $aresult[2]
		Return $aresult[0]
	EndFunc

	Func _winapi_getwindowwidth($hwnd)
		Local $trect = _winapi_getwindowrect($hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return DllStructGetData($trect, "Right") - DllStructGetData($trect, "Left")
	EndFunc

	Func _winapi_getxyfrompoint(ByRef $tpoint, ByRef $ix, ByRef $iy)
		$ix = DllStructGetData($tpoint, "X")
		$iy = DllStructGetData($tpoint, "Y")
	EndFunc

	Func _winapi_globalmemorystatus()
		Local $tmem = DllStructCreate($tagmemorystatusex)
		Local $pmem = DllStructGetPtr($tmem)
		Local $imem = DllStructGetSize($tmem)
		DllStructSetData($tmem, 1, $imem)
		DllCall("kernel32.dll", "none", "GlobalMemoryStatusEx", "ptr", $pmem)
		If @error Then Return SetError(@error, @extended, 0)
		Local $amem[7]
		$amem[0] = DllStructGetData($tmem, 2)
		$amem[1] = DllStructGetData($tmem, 3)
		$amem[2] = DllStructGetData($tmem, 4)
		$amem[3] = DllStructGetData($tmem, 5)
		$amem[4] = DllStructGetData($tmem, 6)
		$amem[5] = DllStructGetData($tmem, 7)
		$amem[6] = DllStructGetData($tmem, 8)
		Return $amem
	EndFunc

	Func _winapi_guidfromstring($sguid)
		Local $tguid = DllStructCreate($tagguid)
		_winapi_guidfromstringex($sguid, DllStructGetPtr($tguid))
		If @error Then Return SetError(@error, @extended, 0)
		Return $tguid
	EndFunc

	Func _winapi_guidfromstringex($sguid, $pguid)
		Local $aresult = DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sguid, "ptr", $pguid)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_hiword($ilong)
		Return BitShift($ilong, 16)
	EndFunc

	Func _winapi_inprocess($hwnd, ByRef $hlastwnd)
		If $hwnd = $hlastwnd Then Return True
		For $ii = $__gainprocess_winapi[0][0] To 1 Step -1
			If $hwnd = $__gainprocess_winapi[$ii][0] Then
				If $__gainprocess_winapi[$ii][1] Then
					$hlastwnd = $hwnd
					Return True
				Else
					Return False
				EndIf
			EndIf
		Next
		Local $iprocessid
		_winapi_getwindowthreadprocessid($hwnd, $iprocessid)
		Local $icount = $__gainprocess_winapi[0][0] + 1
		If $icount >= 64 Then $icount = 1
		$__gainprocess_winapi[0][0] = $icount
		$__gainprocess_winapi[$icount][0] = $hwnd
		$__gainprocess_winapi[$icount][1] = ($iprocessid = @AutoItPID)
		Return $__gainprocess_winapi[$icount][1]
	EndFunc

	Func _winapi_inttofloat($iint)
		Local $tint = DllStructCreate("int")
		Local $tfloat = DllStructCreate("float", DllStructGetPtr($tint))
		DllStructSetData($tint, 1, $iint)
		Return DllStructGetData($tfloat, 1)
	EndFunc

	Func _winapi_isclassname($hwnd, $sclassname)
		Local $sseparator = Opt("GUIDataSeparatorChar")
		Local $aclassname = StringSplit($sclassname, $sseparator)
		If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
		Local $sclasscheck = _winapi_getclassname($hwnd)
		For $x = 1 To UBound($aclassname) - 1
			If StringUpper(StringMid($sclasscheck, 1, StringLen($aclassname[$x]))) = StringUpper($aclassname[$x]) Then Return True
		Next
		Return False
	EndFunc

	Func _winapi_iswindow($hwnd)
		Local $aresult = DllCall("user32.dll", "bool", "IsWindow", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_iswindowvisible($hwnd)
		Local $aresult = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_invalidaterect($hwnd, $trect = 0, $ferase = True)
		Local $prect = 0
		If IsDllStruct($trect) Then $prect = DllStructGetPtr($trect)
		Local $aresult = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hwnd, "ptr", $prect, "bool", $ferase)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_lineto($hdc, $ix, $iy)
		Local $aresult = DllCall("gdi32.dll", "bool", "LineTo", "handle", $hdc, "int", $ix, "int", $iy)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_loadbitmap($hinstance, $sbitmap)
		Local $sbitmaptype = "int"
		If IsString($sbitmap) Then $sbitmaptype = "wstr"
		Local $aresult = DllCall("user32.dll", "handle", "LoadBitmapW", "handle", $hinstance, $sbitmaptype, $sbitmap)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_loadimage($hinstance, $simage, $itype, $ixdesired, $iydesired, $iload)
		Local $aresult, $simagetype = "int"
		If IsString($simage) Then $simagetype = "wstr"
		$aresult = DllCall("user32.dll", "handle", "LoadImageW", "handle", $hinstance, $simagetype, $simage, "uint", $itype, "int", $ixdesired, "int", $iydesired, "uint", $iload)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_loadlibrary($sfilename)
		Local $aresult = DllCall("kernel32.dll", "handle", "LoadLibraryW", "wstr", $sfilename)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_loadlibraryex($sfilename, $iflags = 0)
		Local $aresult = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", $sfilename, "ptr", 0, "dword", $iflags)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_loadshell32icon($iiconid)
		Local $ticons = DllStructCreate("ptr Data")
		Local $picons = DllStructGetPtr($ticons)
		Local $iicons = _winapi_extracticonex("shell32.dll", $iiconid, 0, $picons, 1)
		If @error Then Return SetError(@error, @extended, 0)
		If $iicons <= 0 Then Return SetError(1, 0, 0)
		Return DllStructGetData($ticons, "Data")
	EndFunc

	Func _winapi_loadstring($hinstance, $istringid)
		Local $aresult = DllCall("user32.dll", "int", "LoadStringW", "handle", $hinstance, "uint", $istringid, "wstr", "", "int", 4096)
		If @error Then Return SetError(@error, @extended, "")
		Return SetExtended($aresult[0], $aresult[3])
	EndFunc

	Func _winapi_localfree($hmem)
		Local $aresult = DllCall("kernel32.dll", "handle", "LocalFree", "handle", $hmem)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_loword($ilong)
		Return BitAND($ilong, 65535)
	EndFunc

	Func _winapi_makelangid($lgidprimary, $lgidsub)
		Return BitOR(BitShift($lgidsub, -10), $lgidprimary)
	EndFunc

	Func _winapi_makelcid($lgid, $srtid)
		Return BitOR(BitShift($srtid, -16), $lgid)
	EndFunc

	Func _winapi_makelong($ilo, $ihi)
		Return BitOR(BitShift($ihi, -16), BitAND($ilo, 65535))
	EndFunc

	Func _winapi_makeqword($lodword, $hidword)
		Local $tint64 = DllStructCreate("uint64")
		Local $tdwords = DllStructCreate("dword;dword", DllStructGetPtr($tint64))
		DllStructSetData($tdwords, 1, $lodword)
		DllStructSetData($tdwords, 2, $hidword)
		Return DllStructGetData($tint64, 1)
	EndFunc

	Func _winapi_messagebeep($itype = 1)
		Local $isound
		Switch $itype
			Case 1
				$isound = 0
			Case 2
				$isound = 16
			Case 3
				$isound = 32
			Case 4
				$isound = 48
			Case 5
				$isound = 64
			Case Else
				$isound = -1
		EndSwitch
		Local $aresult = DllCall("user32.dll", "bool", "MessageBeep", "uint", $isound)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_msgbox($iflags, $stitle, $stext)
		BlockInput(0)
		MsgBox($iflags, $stitle, $stext & "      ")
	EndFunc

	Func _winapi_mouse_event($iflags, $ix = 0, $iy = 0, $idata = 0, $iextrainfo = 0)
		DllCall("user32.dll", "none", "mouse_event", "dword", $iflags, "dword", $ix, "dword", $iy, "dword", $idata, "ulong_ptr", $iextrainfo)
		If @error Then Return SetError(@error, @extended)
	EndFunc

	Func _winapi_moveto($hdc, $ix, $iy)
		Local $aresult = DllCall("gdi32.dll", "bool", "MoveToEx", "handle", $hdc, "int", $ix, "int", $iy, "ptr", 0)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_movewindow($hwnd, $ix, $iy, $iwidth, $iheight, $frepaint = True)
		Local $aresult = DllCall("user32.dll", "bool", "MoveWindow", "hwnd", $hwnd, "int", $ix, "int", $iy, "int", $iwidth, "int", $iheight, "bool", $frepaint)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_muldiv($inumber, $inumerator, $idenominator)
		Local $aresult = DllCall("kernel32.dll", "int", "MulDiv", "int", $inumber, "int", $inumerator, "int", $idenominator)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_multibytetowidechar($stext, $icodepage = 0, $iflags = 0, $bretstring = False)
		Local $stexttype = "ptr", $ptext = $stext
		If IsDllStruct($stext) Then
			$ptext = DllStructGetPtr($stext)
		Else
			If NOT IsPtr($stext) Then $stexttype = "STR"
		EndIf
		Local $aresult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $icodepage, "dword", $iflags, $stexttype, $ptext, "int", -1, "ptr", 0, "int", 0)
		If @error Then Return SetError(@error, @extended, 0)
		Local $iout = $aresult[0]
		Local $tout = DllStructCreate("wchar[" & $iout & "]")
		Local $pout = DllStructGetPtr($tout)
		$aresult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $icodepage, "dword", $iflags, $stexttype, $ptext, "int", -1, "ptr", $pout, "int", $iout)
		If @error Then Return SetError(@error, @extended, 0)
		If $bretstring Then Return DllStructGetData($tout, 1)
		Return $tout
	EndFunc

	Func _winapi_multibytetowidecharex($stext, $ptext, $icodepage = 0, $iflags = 0)
		Local $aresult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $icodepage, "dword", $iflags, "STR", $stext, "int", -1, "ptr", $ptext, "int", (StringLen($stext) + 1) * 2)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_openprocess($iaccess, $finherit, $iprocessid, $fdebugpriv = False)
		Local $aresult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iaccess, "bool", $finherit, "dword", $iprocessid)
		If @error Then Return SetError(@error, @extended, 0)
		If $aresult[0] Then Return $aresult[0]
		If NOT $fdebugpriv Then Return 0
		Local $htoken = _security__openthreadtokenex(BitOR($token_adjust_privileges, $token_query))
		If @error Then Return SetError(@error, @extended, 0)
		_security__setprivilege($htoken, "SeDebugPrivilege", True)
		Local $ierror = @error
		Local $ilasterror = @extended
		Local $iret = 0
		If NOT @error Then
			$aresult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iaccess, "bool", $finherit, "dword", $iprocessid)
			$ierror = @error
			$ilasterror = @extended
			If $aresult[0] Then $iret = $aresult[0]
			_security__setprivilege($htoken, "SeDebugPrivilege", False)
			If @error Then
				$ierror = @error
				$ilasterror = @extended
			EndIf
		EndIf
		_winapi_closehandle($htoken)
		Return SetError($ierror, $ilasterror, $iret)
	EndFunc

	Func __winapi_parsefiledialogpath($spath)
		Local $afiles[3]
		$afiles[0] = 2
		Local $stemp = StringMid($spath, 1, StringInStr($spath, "\", 0, -1) - 1)
		$afiles[1] = $stemp
		$afiles[2] = StringMid($spath, StringInStr($spath, "\", 0, -1) + 1)
		Return $afiles
	EndFunc

	Func _winapi_pathfindonpath(Const $szfile, $aextrapaths = "", Const $szpathdelimiter = @LF)
		Local $iextracount = 0
		If IsString($aextrapaths) Then
			If StringLen($aextrapaths) Then
				$aextrapaths = StringSplit($aextrapaths, $szpathdelimiter, 1 + 2)
				$iextracount = UBound($aextrapaths, 1)
			EndIf
		ElseIf IsArray($aextrapaths) Then
			$iextracount = UBound($aextrapaths)
		EndIf
		Local $tpaths, $tpathptrs
		If $iextracount Then
			Local $szstruct = ""
			For $path In $aextrapaths
				$szstruct &= "wchar[" & StringLen($path) + 1 & "];"
			Next
			$tpaths = DllStructCreate($szstruct)
			$tpathptrs = DllStructCreate("ptr[" & $iextracount + 1 & "]")
			For $i = 1 To $iextracount
				DllStructSetData($tpaths, $i, $aextrapaths[$i - 1])
				DllStructSetData($tpathptrs, 1, DllStructGetPtr($tpaths, $i), $i)
			Next
			DllStructSetData($tpathptrs, 1, Ptr(0), $iextracount + 1)
		EndIf
		Local $aresult = DllCall("shlwapi.dll", "bool", "PathFindOnPathW", "wstr", $szfile, "ptr", DllStructGetPtr($tpathptrs))
		If @error Then Return SetError(@error, @extended, False)
		If $aresult[0] = 0 Then Return SetError(1, 0, $szfile)
		Return $aresult[1]
	EndFunc

	Func _winapi_pointfromrect(ByRef $trect, $fcenter = True)
		Local $ix1 = DllStructGetData($trect, "Left")
		Local $iy1 = DllStructGetData($trect, "Top")
		Local $ix2 = DllStructGetData($trect, "Right")
		Local $iy2 = DllStructGetData($trect, "Bottom")
		If $fcenter Then
			$ix1 = $ix1 + (($ix2 - $ix1) / 2)
			$iy1 = $iy1 + (($iy2 - $iy1) / 2)
		EndIf
		Local $tpoint = DllStructCreate($tagpoint)
		DllStructSetData($tpoint, "X", $ix1)
		DllStructSetData($tpoint, "Y", $iy1)
		Return $tpoint
	EndFunc

	Func _winapi_postmessage($hwnd, $imsg, $iwparam, $ilparam)
		Local $aresult = DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hwnd, "uint", $imsg, "wparam", $iwparam, "lparam", $ilparam)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_primarylangid($lgid)
		Return BitAND($lgid, 1023)
	EndFunc

	Func _winapi_ptinrect(ByRef $trect, ByRef $tpoint)
		Local $ix = DllStructGetData($tpoint, "X")
		Local $iy = DllStructGetData($tpoint, "Y")
		Local $aresult = DllCall("user32.dll", "bool", "PtInRect", "ptr", DllStructGetPtr($trect), "long", $ix, "long", $iy)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_readfile($hfile, $pbuffer, $itoread, ByRef $iread, $poverlapped = 0)
		Local $aresult = DllCall("kernel32.dll", "bool", "ReadFile", "handle", $hfile, "ptr", $pbuffer, "dword", $itoread, "dword*", 0, "ptr", $poverlapped)
		If @error Then Return SetError(@error, @extended, False)
		$iread = $aresult[4]
		Return $aresult[0]
	EndFunc

	Func _winapi_readprocessmemory($hprocess, $pbaseaddress, $pbuffer, $isize, ByRef $iread)
		Local $aresult = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", $hprocess, "ptr", $pbaseaddress, "ptr", $pbuffer, "ulong_ptr", $isize, "ulong_ptr*", 0)
		If @error Then Return SetError(@error, @extended, False)
		$iread = $aresult[5]
		Return $aresult[0]
	EndFunc

	Func _winapi_rectisempty(ByRef $trect)
		Return (DllStructGetData($trect, "Left") = 0) AND (DllStructGetData($trect, "Top") = 0) AND (DllStructGetData($trect, "Right") = 0) AND (DllStructGetData($trect, "Bottom") = 0)
	EndFunc

	Func _winapi_redrawwindow($hwnd, $trect = 0, $hregion = 0, $iflags = 5)
		Local $prect = 0
		If $trect <> 0 Then $prect = DllStructGetPtr($trect)
		Local $aresult = DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hwnd, "ptr", $prect, "handle", $hregion, "uint", $iflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_registerwindowmessage($smessage)
		Local $aresult = DllCall("user32.dll", "uint", "RegisterWindowMessageW", "wstr", $smessage)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_releasecapture()
		Local $aresult = DllCall("user32.dll", "bool", "ReleaseCapture")
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_releasedc($hwnd, $hdc)
		Local $aresult = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hwnd, "handle", $hdc)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_screentoclient($hwnd, ByRef $tpoint)
		Local $aresult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hwnd, "ptr", DllStructGetPtr($tpoint))
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_selectobject($hdc, $hgdiobj)
		Local $aresult = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hdc, "handle", $hgdiobj)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setbkcolor($hdc, $icolor)
		Local $aresult = DllCall("gdi32.dll", "INT", "SetBkColor", "handle", $hdc, "dword", $icolor)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_setbkmode($hdc, $ibkmode)
		Local $aresult = DllCall("gdi32.dll", "int", "SetBkMode", "handle", $hdc, "int", $ibkmode)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setcapture($hwnd)
		Local $aresult = DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setcursor($hcursor)
		Local $aresult = DllCall("user32.dll", "handle", "SetCursor", "handle", $hcursor)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setdefaultprinter($sprinter)
		Local $aresult = DllCall("winspool.drv", "bool", "SetDefaultPrinterW", "wstr", $sprinter)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setdibits($hdc, $hbmp, $istartscan, $iscanlines, $pbits, $pbmi, $icoloruse = 0)
		Local $aresult = DllCall("gdi32.dll", "int", "SetDIBits", "handle", $hdc, "handle", $hbmp, "uint", $istartscan, "uint", $iscanlines, "ptr", $pbits, "ptr", $pbmi, "uint", $icoloruse)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setendoffile($hfile)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetEndOfFile", "handle", $hfile)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setevent($hevent)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetEvent", "handle", $hevent)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setfilepointer($hfile, $ipos, $imethod = 0)
		Local $aresult = DllCall("kernel32.dll", "INT", "SetFilePointer", "handle", $hfile, "long", $ipos, "ptr", 0, "long", $imethod)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_setfocus($hwnd)
		Local $aresult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setfont($hwnd, $hfont, $fredraw = True)
		_sendmessage($hwnd, $__winapiconstant_wm_setfont, $hfont, $fredraw, 0, "hwnd")
	EndFunc

	Func _winapi_sethandleinformation($hobject, $imask, $iflags)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetHandleInformation", "handle", $hobject, "dword", $imask, "dword", $iflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setlayeredwindowattributes($hwnd, $i_transcolor, $transparency = 255, $dwflags = 3, $iscolorref = False)
		If $dwflags = Default OR $dwflags = "" OR $dwflags < 0 Then $dwflags = 3
		If NOT $iscolorref Then
			$i_transcolor = Hex(String($i_transcolor), 6)
			$i_transcolor = Execute("0x00" & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
		EndIf
		Local $aresult = DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hwnd, "dword", $i_transcolor, "byte", $transparency, "dword", $dwflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setparent($hwndchild, $hwndparent)
		Local $aresult = DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $hwndchild, "hwnd", $hwndparent)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setprocessaffinitymask($hprocess, $imask)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetProcessAffinityMask", "handle", $hprocess, "ulong_ptr", $imask)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setsyscolors($velements, $vcolors)
		Local $isearray = IsArray($velements), $iscarray = IsArray($vcolors)
		Local $ielementnum
		If NOT $iscarray AND NOT $isearray Then
			$ielementnum = 1
		ElseIf $iscarray OR $isearray Then
			If NOT $iscarray OR NOT $isearray Then Return SetError(-1, -1, False)
			If UBound($velements) <> UBound($vcolors) Then Return SetError(-1, -1, False)
			$ielementnum = UBound($velements)
		EndIf
		Local $telements = DllStructCreate("int Element[" & $ielementnum & "]")
		Local $tcolors = DllStructCreate("dword NewColor[" & $ielementnum & "]")
		Local $pelements = DllStructGetPtr($telements)
		Local $pcolors = DllStructGetPtr($tcolors)
		If NOT $isearray Then
			DllStructSetData($telements, "Element", $velements, 1)
		Else
			For $x = 0 To $ielementnum - 1
				DllStructSetData($telements, "Element", $velements[$x], $x + 1)
			Next
		EndIf
		If NOT $iscarray Then
			DllStructSetData($tcolors, "NewColor", $vcolors, 1)
		Else
			For $x = 0 To $ielementnum - 1
				DllStructSetData($tcolors, "NewColor", $vcolors[$x], $x + 1)
			Next
		EndIf
		Local $aresult = DllCall("user32.dll", "bool", "SetSysColors", "int", $ielementnum, "ptr", $pelements, "ptr", $pcolors)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_settextcolor($hdc, $icolor)
		Local $aresult = DllCall("gdi32.dll", "INT", "SetTextColor", "handle", $hdc, "dword", $icolor)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowlong($hwnd, $iindex, $ivalue)
		_winapi_setlasterror(0)
		Local $sfuncname = "SetWindowLongW"
		If @AutoItX64 Then $sfuncname = "SetWindowLongPtrW"
		Local $aresult = DllCall("user32.dll", "long_ptr", $sfuncname, "hwnd", $hwnd, "int", $iindex, "long_ptr", $ivalue)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowplacement($hwnd, $pwindowplacement)
		Local $aresult = DllCall("user32.dll", "bool", "SetWindowPlacement", "hwnd", $hwnd, "ptr", $pwindowplacement)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowpos($hwnd, $hafter, $ix, $iy, $icx, $icy, $iflags)
		Local $aresult = DllCall("user32.dll", "bool", "SetWindowPos", "hwnd", $hwnd, "hwnd", $hafter, "int", $ix, "int", $iy, "int", $icx, "int", $icy, "uint", $iflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowrgn($hwnd, $hrgn, $bredraw = True)
		Local $aresult = DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $hwnd, "handle", $hrgn, "bool", $bredraw)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowshookex($idhook, $lpfn, $hmod, $dwthreadid = 0)
		Local $aresult = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $idhook, "ptr", $lpfn, "handle", $hmod, "dword", $dwthreadid)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_setwindowtext($hwnd, $stext)
		Local $aresult = DllCall("user32.dll", "bool", "SetWindowTextW", "hwnd", $hwnd, "wstr", $stext)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_showcursor($fshow)
		Local $aresult = DllCall("user32.dll", "int", "ShowCursor", "bool", $fshow)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_showerror($stext, $fexit = True)
		_winapi_msgbox(266256, "Error", $stext)
		If $fexit Then Exit
	EndFunc

	Func _winapi_showmsg($stext)
		_winapi_msgbox(64 + 4096, "Information", $stext)
	EndFunc

	Func _winapi_showwindow($hwnd, $icmdshow = 5)
		Local $aresult = DllCall("user32.dll", "bool", "ShowWindow", "hwnd", $hwnd, "int", $icmdshow)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_stringfromguid($pguid)
		Local $aresult = DllCall("ole32.dll", "int", "StringFromGUID2", "ptr", $pguid, "wstr", "", "int", 40)
		If @error Then Return SetError(@error, @extended, "")
		Return SetExtended($aresult[0], $aresult[2])
	EndFunc

	Func _winapi_sublangid($lgid)
		Return BitShift($lgid, 10)
	EndFunc

	Func _winapi_systemparametersinfo($iaction, $iparam = 0, $vparam = 0, $iwinini = 0)
		Local $aresult = DllCall("user32.dll", "bool", "SystemParametersInfoW", "uint", $iaction, "uint", $iparam, "ptr", $vparam, "uint", $iwinini)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_twipsperpixelx()
		Local $lngdc, $twipsperpixelx
		$lngdc = _winapi_getdc(0)
		$twipsperpixelx = 1440 / _winapi_getdevicecaps($lngdc, $__winapiconstant_logpixelsx)
		_winapi_releasedc(0, $lngdc)
		Return $twipsperpixelx
	EndFunc

	Func _winapi_twipsperpixely()
		Local $lngdc, $twipsperpixely
		$lngdc = _winapi_getdc(0)
		$twipsperpixely = 1440 / _winapi_getdevicecaps($lngdc, $__winapiconstant_logpixelsy)
		_winapi_releasedc(0, $lngdc)
		Return $twipsperpixely
	EndFunc

	Func _winapi_unhookwindowshookex($hhk)
		Local $aresult = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $hhk)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_updatelayeredwindow($hwnd, $hdcdest, $pptdest, $psize, $hdcsrce, $pptsrce, $irgb, $pblend, $iflags)
		Local $aresult = DllCall("user32.dll", "bool", "UpdateLayeredWindow", "hwnd", $hwnd, "handle", $hdcdest, "ptr", $pptdest, "ptr", $psize, "handle", $hdcsrce, "ptr", $pptsrce, "dword", $irgb, "ptr", $pblend, "dword", $iflags)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_updatewindow($hwnd)
		Local $aresult = DllCall("user32.dll", "bool", "UpdateWindow", "hwnd", $hwnd)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_waitforinputidle($hprocess, $itimeout = -1)
		Local $aresult = DllCall("user32.dll", "dword", "WaitForInputIdle", "handle", $hprocess, "dword", $itimeout)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_waitformultipleobjects($icount, $phandles, $fwaitall = False, $itimeout = -1)
		Local $aresult = DllCall("kernel32.dll", "INT", "WaitForMultipleObjects", "dword", $icount, "ptr", $phandles, "bool", $fwaitall, "dword", $itimeout)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_waitforsingleobject($hhandle, $itimeout = -1)
		Local $aresult = DllCall("kernel32.dll", "INT", "WaitForSingleObject", "handle", $hhandle, "dword", $itimeout)
		If @error Then Return SetError(@error, @extended, -1)
		Return $aresult[0]
	EndFunc

	Func _winapi_widechartomultibyte($punicode, $icodepage = 0, $bretstring = True)
		Local $sunicodetype = "ptr"
		If IsDllStruct($punicode) Then
			$punicode = DllStructGetPtr($punicode)
		Else
			If NOT IsPtr($punicode) Then $sunicodetype = "wstr"
		EndIf
		Local $aresult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $icodepage, "dword", 0, $sunicodetype, $punicode, "int", -1, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0)
		If @error Then Return SetError(@error, @extended, "")
		Local $tmultibyte = DllStructCreate("char[" & $aresult[0] & "]")
		Local $pmultibyte = DllStructGetPtr($tmultibyte)
		$aresult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $icodepage, "dword", 0, $sunicodetype, $punicode, "int", -1, "ptr", $pmultibyte, "int", $aresult[0], "ptr", 0, "ptr", 0)
		If @error Then Return SetError(@error, @extended, "")
		If $bretstring Then Return DllStructGetData($tmultibyte, 1)
		Return $tmultibyte
	EndFunc

	Func _winapi_windowfrompoint(ByRef $tpoint)
		Local $ix = DllStructGetData($tpoint, "X")
		Local $iy = DllStructGetData($tpoint, "Y")
		Local $aresult = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $ix, "long", $iy)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _winapi_writeconsole($hconsole, $stext)
		Local $aresult = DllCall("kernel32.dll", "bool", "WriteConsoleW", "handle", $hconsole, "wstr", $stext, "dword", StringLen($stext), "dword*", 0, "ptr", 0)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _winapi_writefile($hfile, $pbuffer, $itowrite, ByRef $iwritten, $poverlapped = 0)
		Local $aresult = DllCall("kernel32.dll", "bool", "WriteFile", "handle", $hfile, "ptr", $pbuffer, "dword", $itowrite, "dword*", 0, "ptr", $poverlapped)
		If @error Then Return SetError(@error, @extended, False)
		$iwritten = $aresult[4]
		Return $aresult[0]
	EndFunc

	Func _winapi_writeprocessmemory($hprocess, $pbaseaddress, $pbuffer, $isize, ByRef $iwritten, $sbuffer = "ptr")
		Local $aresult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", $hprocess, "ptr", $pbaseaddress, $sbuffer, $pbuffer, "ulong_ptr", $isize, "ulong_ptr*", 0)
		If @error Then Return SetError(@error, @extended, False)
		$iwritten = $aresult[5]
		Return $aresult[0]
	EndFunc

	Func _dateadd($stype, $ivaltoadd, $sdate)
		Local $astimepart[4]
		Local $asdatepart[4]
		Local $ijuliandate
		$stype = StringLeft($stype, 1)
		If StringInStr("D,M,Y,w,h,n,s", $stype) = 0 OR $stype = "" Then
			Return SetError(1, 0, 0)
		EndIf
		If NOT StringIsInt($ivaltoadd) Then
			Return SetError(2, 0, 0)
		EndIf
		If NOT _dateisvalid($sdate) Then
			Return SetError(3, 0, 0)
		EndIf
		_datetimesplit($sdate, $asdatepart, $astimepart)
		If $stype = "d" OR $stype = "w" Then
			If $stype = "w" Then $ivaltoadd = $ivaltoadd * 7
			$ijuliandate = _datetodayvalue($asdatepart[1], $asdatepart[2], $asdatepart[3]) + $ivaltoadd
			_dayvaluetodate($ijuliandate, $asdatepart[1], $asdatepart[2], $asdatepart[3])
		EndIf
		If $stype = "m" Then
			$asdatepart[2] = $asdatepart[2] + $ivaltoadd
			While $asdatepart[2] > 12
				$asdatepart[2] = $asdatepart[2] - 12
				$asdatepart[1] = $asdatepart[1] + 1
			WEnd
			While $asdatepart[2] < 1
				$asdatepart[2] = $asdatepart[2] + 12
				$asdatepart[1] = $asdatepart[1] - 1
			WEnd
		EndIf
		If $stype = "y" Then
			$asdatepart[1] = $asdatepart[1] + $ivaltoadd
		EndIf
		If $stype = "h" OR $stype = "n" OR $stype = "s" Then
			Local $itimeval = _timetoticks($astimepart[1], $astimepart[2], $astimepart[3]) / 1000
			If $stype = "h" Then $itimeval = $itimeval + $ivaltoadd * 3600
			If $stype = "n" Then $itimeval = $itimeval + $ivaltoadd * 60
			If $stype = "s" Then $itimeval = $itimeval + $ivaltoadd
			Local $day2add = Int($itimeval / (24 * 60 * 60))
			$itimeval = $itimeval - $day2add * 24 * 60 * 60
			If $itimeval < 0 Then
				$day2add = $day2add - 1
				$itimeval = $itimeval + 24 * 60 * 60
			EndIf
			$ijuliandate = _datetodayvalue($asdatepart[1], $asdatepart[2], $asdatepart[3]) + $day2add
			_dayvaluetodate($ijuliandate, $asdatepart[1], $asdatepart[2], $asdatepart[3])
			_tickstotime($itimeval * 1000, $astimepart[1], $astimepart[2], $astimepart[3])
		EndIf
		Local $inumdays = _daysinmonth($asdatepart[1])
		If $inumdays[$asdatepart[2]] < $asdatepart[3] Then $asdatepart[3] = $inumdays[$asdatepart[2]]
		$sdate = $asdatepart[1] & "/" & StringRight("0" & $asdatepart[2], 2) & "/" & StringRight("0" & $asdatepart[3], 2)
		If $astimepart[0] > 0 Then
			If $astimepart[0] > 2 Then
				$sdate = $sdate & " " & StringRight("0" & $astimepart[1], 2) & ":" & StringRight("0" & $astimepart[2], 2) & ":" & StringRight("0" & $astimepart[3], 2)
			Else
				$sdate = $sdate & " " & StringRight("0" & $astimepart[1], 2) & ":" & StringRight("0" & $astimepart[2], 2)
			EndIf
		EndIf
		Return ($sdate)
	EndFunc

	Func _datedayofweek($idaynum, $ishort = 0)
		Local Const $adayofweek[8] = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		Select 
			Case NOT StringIsInt($idaynum) OR NOT StringIsInt($ishort)
				Return SetError(1, 0, "")
			Case $idaynum < 1 OR $idaynum > 7
				Return SetError(1, 0, "")
			Case Else
				Select 
					Case $ishort = 0
						Return $adayofweek[$idaynum]
					Case $ishort = 1
						Return StringLeft($adayofweek[$idaynum], 3)
					Case Else
						Return SetError(1, 0, "")
				EndSelect
		EndSelect
	EndFunc

	Func _datedaysinmonth($iyear, $imonthnum)
		If __dateismonth($imonthnum) AND __dateisyear($iyear) Then
			Local $ainumdays = _daysinmonth($iyear)
			Return $ainumdays[$imonthnum]
		EndIf
		Return SetError(1, 0, 0)
	EndFunc

	Func _datediff($stype, $sstartdate, $senddate)
		$stype = StringLeft($stype, 1)
		If StringInStr("d,m,y,w,h,n,s", $stype) = 0 OR $stype = "" Then
			Return SetError(1, 0, 0)
		EndIf
		If NOT _dateisvalid($sstartdate) Then
			Return SetError(2, 0, 0)
		EndIf
		If NOT _dateisvalid($senddate) Then
			Return SetError(3, 0, 0)
		EndIf
		Local $asstartdatepart[4], $asstarttimepart[4], $asenddatepart[4], $asendtimepart[4]
		_datetimesplit($sstartdate, $asstartdatepart, $asstarttimepart)
		_datetimesplit($senddate, $asenddatepart, $asendtimepart)
		Local $adaysdiff = _datetodayvalue($asenddatepart[1], $asenddatepart[2], $asenddatepart[3]) - _datetodayvalue($asstartdatepart[1], $asstartdatepart[2], $asstartdatepart[3])
		Local $itimediff, $iyeardiff, $istarttimeinsecs, $iendtimeinsecs
		If $asstarttimepart[0] > 1 AND $asendtimepart[0] > 1 Then
			$istarttimeinsecs = $asstarttimepart[1] * 3600 + $asstarttimepart[2] * 60 + $asstarttimepart[3]
			$iendtimeinsecs = $asendtimepart[1] * 3600 + $asendtimepart[2] * 60 + $asendtimepart[3]
			$itimediff = $iendtimeinsecs - $istarttimeinsecs
			If $itimediff < 0 Then
				$adaysdiff = $adaysdiff - 1
				$itimediff = $itimediff + 24 * 60 * 60
			EndIf
		Else
			$itimediff = 0
		EndIf
		Select 
			Case $stype = "d"
				Return ($adaysdiff)
			Case $stype = "m"
				$iyeardiff = $asenddatepart[1] - $asstartdatepart[1]
				Local $imonthdiff = $asenddatepart[2] - $asstartdatepart[2] + $iyeardiff * 12
				If $asenddatepart[3] < $asstartdatepart[3] Then $imonthdiff = $imonthdiff - 1
				$istarttimeinsecs = $asstarttimepart[1] * 3600 + $asstarttimepart[2] * 60 + $asstarttimepart[3]
				$iendtimeinsecs = $asendtimepart[1] * 3600 + $asendtimepart[2] * 60 + $asendtimepart[3]
				$itimediff = $iendtimeinsecs - $istarttimeinsecs
				If $asenddatepart[3] = $asstartdatepart[3] AND $itimediff < 0 Then $imonthdiff = $imonthdiff - 1
				Return ($imonthdiff)
			Case $stype = "y"
				$iyeardiff = $asenddatepart[1] - $asstartdatepart[1]
				If $asenddatepart[2] < $asstartdatepart[2] Then $iyeardiff = $iyeardiff - 1
				If $asenddatepart[2] = $asstartdatepart[2] AND $asenddatepart[3] < $asstartdatepart[3] Then $iyeardiff = $iyeardiff - 1
				$istarttimeinsecs = $asstarttimepart[1] * 3600 + $asstarttimepart[2] * 60 + $asstarttimepart[3]
				$iendtimeinsecs = $asendtimepart[1] * 3600 + $asendtimepart[2] * 60 + $asendtimepart[3]
				$itimediff = $iendtimeinsecs - $istarttimeinsecs
				If $asenddatepart[2] = $asstartdatepart[2] AND $asenddatepart[3] = $asstartdatepart[3] AND $itimediff < 0 Then $iyeardiff = $iyeardiff - 1
				Return ($iyeardiff)
			Case $stype = "w"
				Return (Int($adaysdiff / 7))
			Case $stype = "h"
				Return ($adaysdiff * 24 + Int($itimediff / 3600))
			Case $stype = "n"
				Return ($adaysdiff * 24 * 60 + Int($itimediff / 60))
			Case $stype = "s"
				Return ($adaysdiff * 24 * 60 * 60 + $itimediff)
		EndSelect
	EndFunc

	Func _dateisleapyear($iyear)
		If StringIsInt($iyear) Then
			Select 
				Case Mod($iyear, 4) = 0 AND Mod($iyear, 100) <> 0
					Return 1
				Case Mod($iyear, 400) = 0
					Return 1
				Case Else
					Return 0
			EndSelect
		EndIf
		Return SetError(1, 0, 0)
	EndFunc

	Func __dateismonth($inumber)
		If StringIsInt($inumber) Then
			If $inumber >= 1 AND $inumber <= 12 Then
				Return 1
			Else
				Return 0
			EndIf
		EndIf
		Return 0
	EndFunc

	Func _dateisvalid($sdate)
		Local $asdatepart[4], $astimepart[4]
		Local $sdatetime = StringSplit($sdate, " T")
		If $sdatetime[0] > 0 Then $asdatepart = StringSplit($sdatetime[1], "/-.")
		If UBound($asdatepart) <> 4 Then Return (0)
		If $asdatepart[0] <> 3 Then Return (0)
		If NOT StringIsInt($asdatepart[1]) Then Return (0)
		If NOT StringIsInt($asdatepart[2]) Then Return (0)
		If NOT StringIsInt($asdatepart[3]) Then Return (0)
		$asdatepart[1] = Number($asdatepart[1])
		$asdatepart[2] = Number($asdatepart[2])
		$asdatepart[3] = Number($asdatepart[3])
		Local $inumdays = _daysinmonth($asdatepart[1])
		If $asdatepart[1] < 1000 OR $asdatepart[1] > 2999 Then Return (0)
		If $asdatepart[2] < 1 OR $asdatepart[2] > 12 Then Return (0)
		If $asdatepart[3] < 1 OR $asdatepart[3] > $inumdays[$asdatepart[2]] Then Return (0)
		If $sdatetime[0] > 1 Then
			$astimepart = StringSplit($sdatetime[2], ":")
			If UBound($astimepart) < 4 Then ReDim $astimepart[4]
		Else
			Dim $astimepart[4]
		EndIf
		If $astimepart[0] < 1 Then Return (1)
		If $astimepart[0] < 2 Then Return (0)
		If $astimepart[0] = 2 Then $astimepart[3] = "00"
		If NOT StringIsInt($astimepart[1]) Then Return (0)
		If NOT StringIsInt($astimepart[2]) Then Return (0)
		If NOT StringIsInt($astimepart[3]) Then Return (0)
		$astimepart[1] = Number($astimepart[1])
		$astimepart[2] = Number($astimepart[2])
		$astimepart[3] = Number($astimepart[3])
		If $astimepart[1] < 0 OR $astimepart[1] > 23 Then Return (0)
		If $astimepart[2] < 0 OR $astimepart[2] > 59 Then Return (0)
		If $astimepart[3] < 0 OR $astimepart[3] > 59 Then Return (0)
		Return 1
	EndFunc

	Func __dateisyear($inumber)
		If StringIsInt($inumber) Then
			If StringLen($inumber) = 4 Then
				Return 1
			Else
				Return 0
			EndIf
		EndIf
		Return 0
	EndFunc

	Func _datelastweekdaynum($iweekdaynum)
		Select 
			Case NOT StringIsInt($iweekdaynum)
				Return SetError(1, 0, 0)
			Case $iweekdaynum < 1 OR $iweekdaynum > 7
				Return SetError(1, 0, 0)
			Case Else
				Local $ilastweekdaynum
				If $iweekdaynum = 1 Then
					$ilastweekdaynum = 7
				Else
					$ilastweekdaynum = $iweekdaynum - 1
				EndIf
				Return $ilastweekdaynum
		EndSelect
	EndFunc

	Func _datelastmonthnum($imonthnum)
		Select 
			Case NOT StringIsInt($imonthnum)
				Return SetError(1, 0, 0)
			Case $imonthnum < 1 OR $imonthnum > 12
				Return SetError(1, 0, 0)
			Case Else
				Local $ilastmonthnum
				If $imonthnum = 1 Then
					$ilastmonthnum = 12
				Else
					$ilastmonthnum = $imonthnum - 1
				EndIf
				$ilastmonthnum = StringFormat("%02d", $ilastmonthnum)
				Return $ilastmonthnum
		EndSelect
	EndFunc

	Func _datelastmonthyear($imonthnum, $iyear)
		Select 
			Case NOT StringIsInt($imonthnum) OR NOT StringIsInt($iyear)
				Return SetError(1, 0, 0)
			Case $imonthnum < 1 OR $imonthnum > 12
				Return SetError(1, 0, 0)
			Case Else
				Local $ilastyear
				If $imonthnum = 1 Then
					$ilastyear = $iyear - 1
				Else
					$ilastyear = $iyear
				EndIf
				$ilastyear = StringFormat("%04d", $ilastyear)
				Return $ilastyear
		EndSelect
	EndFunc

	Func _datenextweekdaynum($iweekdaynum)
		Select 
			Case NOT StringIsInt($iweekdaynum)
				Return SetError(1, 0, 0)
			Case $iweekdaynum < 1 OR $iweekdaynum > 7
				Return SetError(1, 0, 0)
			Case Else
				Local $inextweekdaynum
				If $iweekdaynum = 7 Then
					$inextweekdaynum = 1
				Else
					$inextweekdaynum = $iweekdaynum + 1
				EndIf
				Return $inextweekdaynum
		EndSelect
	EndFunc

	Func _datenextmonthnum($imonthnum)
		Select 
			Case NOT StringIsInt($imonthnum)
				Return SetError(1, 0, 0)
			Case $imonthnum < 1 OR $imonthnum > 12
				Return SetError(1, 0, 0)
			Case Else
				Local $inextmonthnum
				If $imonthnum = 12 Then
					$inextmonthnum = 1
				Else
					$inextmonthnum = $imonthnum + 1
				EndIf
				$inextmonthnum = StringFormat("%02d", $inextmonthnum)
				Return $inextmonthnum
		EndSelect
	EndFunc

	Func _datenextmonthyear($imonthnum, $iyear)
		Select 
			Case NOT StringIsInt($imonthnum) OR NOT StringIsInt($iyear)
				Return SetError(1, 0, 0)
			Case $imonthnum < 1 OR $imonthnum > 12
				Return SetError(1, 0, 0)
			Case Else
				Local $inextyear
				If $imonthnum = 12 Then
					$inextyear = $iyear + 1
				Else
					$inextyear = $iyear
				EndIf
				$inextyear = StringFormat("%04d", $inextyear)
				Return $inextyear
		EndSelect
	EndFunc

	Func _datetimeformat($sdate, $stype)
		Local $asdatepart[4], $astimepart[4]
		Local $stempdate = "", $stemptime = ""
		Local $sam, $spm, $lngx
		If NOT _dateisvalid($sdate) Then
			Return SetError(1, 0, "")
		EndIf
		If $stype < 0 OR $stype > 5 OR NOT IsInt($stype) Then
			Return SetError(2, 0, "")
		EndIf
		_datetimesplit($sdate, $asdatepart, $astimepart)
		Switch $stype
			Case 0
				$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 31, "wstr", "", "int", 255)
				If NOT @error AND $lngx[0] <> 0 Then
					$stempdate = $lngx[3]
				Else
					$stempdate = "M/d/yyyy"
				EndIf
				If $astimepart[0] > 1 Then
					$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 4099, "wstr", "", "int", 255)
					If NOT @error AND $lngx[0] <> 0 Then
						$stemptime = $lngx[3]
					Else
						$stemptime = "h:mm:ss tt"
					EndIf
				EndIf
			Case 1
				$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 32, "wstr", "", "int", 255)
				If NOT @error AND $lngx[0] <> 0 Then
					$stempdate = $lngx[3]
				Else
					$stempdate = "dddd, MMMM dd, yyyy"
				EndIf
			Case 2
				$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 31, "wstr", "", "int", 255)
				If NOT @error AND $lngx[0] <> 0 Then
					$stempdate = $lngx[3]
				Else
					$stempdate = "M/d/yyyy"
				EndIf
			Case 3
				If $astimepart[0] > 1 Then
					$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 4099, "wstr", "", "int", 255)
					If NOT @error AND $lngx[0] <> 0 Then
						$stemptime = $lngx[3]
					Else
						$stemptime = "h:mm:ss tt"
					EndIf
				EndIf
			Case 4
				If $astimepart[0] > 1 Then
					$stemptime = "hh:mm"
				EndIf
			Case 5
				If $astimepart[0] > 1 Then
					$stemptime = "hh:mm:ss"
				EndIf
		EndSwitch
		If $stempdate <> "" Then
			$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 29, "wstr", "", "int", 255)
			If NOT @error AND $lngx[0] <> 0 Then
				$stempdate = StringReplace($stempdate, "/", $lngx[3])
			EndIf
			Local $iwday = _datetodayofweek($asdatepart[1], $asdatepart[2], $asdatepart[3])
			$asdatepart[3] = StringRight("0" & $asdatepart[3], 2)
			$asdatepart[2] = StringRight("0" & $asdatepart[2], 2)
			$stempdate = StringReplace($stempdate, "d", "@")
			$stempdate = StringReplace($stempdate, "m", "#")
			$stempdate = StringReplace($stempdate, "y", "&")
			$stempdate = StringReplace($stempdate, "@@@@", _datedayofweek($iwday, 0))
			$stempdate = StringReplace($stempdate, "@@@", _datedayofweek($iwday, 1))
			$stempdate = StringReplace($stempdate, "@@", $asdatepart[3])
			$stempdate = StringReplace($stempdate, "@", StringReplace(StringLeft($asdatepart[3], 1), "0", "") & StringRight($asdatepart[3], 1))
			$stempdate = StringReplace($stempdate, "####", _datetomonth($asdatepart[2], 0))
			$stempdate = StringReplace($stempdate, "###", _datetomonth($asdatepart[2], 1))
			$stempdate = StringReplace($stempdate, "##", $asdatepart[2])
			$stempdate = StringReplace($stempdate, "#", StringReplace(StringLeft($asdatepart[2], 1), "0", "") & StringRight($asdatepart[2], 1))
			$stempdate = StringReplace($stempdate, "&&&&", $asdatepart[1])
			$stempdate = StringReplace($stempdate, "&&", StringRight($asdatepart[1], 2))
		EndIf
		If $stemptime <> "" Then
			$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 40, "wstr", "", "int", 255)
			If NOT @error AND $lngx[0] <> 0 Then
				$sam = $lngx[3]
			Else
				$sam = "AM"
			EndIf
			$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 41, "wstr", "", "int", 255)
			If NOT @error AND $lngx[0] <> 0 Then
				$spm = $lngx[3]
			Else
				$spm = "PM"
			EndIf
			$lngx = DllCall("kernel32.dll", "int", "GetLocaleInfoW", "dword", 1024, "dword", 30, "wstr", "", "int", 255)
			If NOT @error AND $lngx[0] <> 0 Then
				$stemptime = StringReplace($stemptime, ":", $lngx[3])
			EndIf
			If StringInStr($stemptime, "tt") Then
				If $astimepart[1] < 12 Then
					$stemptime = StringReplace($stemptime, "tt", $sam)
					If $astimepart[1] = 0 Then $astimepart[1] = 12
				Else
					$stemptime = StringReplace($stemptime, "tt", $spm)
					If $astimepart[1] > 12 Then $astimepart[1] = $astimepart[1] - 12
				EndIf
			EndIf
			$astimepart[1] = StringRight("0" & $astimepart[1], 2)
			$astimepart[2] = StringRight("0" & $astimepart[2], 2)
			$astimepart[3] = StringRight("0" & $astimepart[3], 2)
			$stemptime = StringReplace($stemptime, "hh", StringFormat("%02d", $astimepart[1]))
			$stemptime = StringReplace($stemptime, "h", StringReplace(StringLeft($astimepart[1], 1), "0", "") & StringRight($astimepart[1], 1))
			$stemptime = StringReplace($stemptime, "mm", StringFormat("%02d", $astimepart[2]))
			$stemptime = StringReplace($stemptime, "ss", StringFormat("%02d", $astimepart[3]))
			$stempdate = StringStripWS($stempdate & " " & $stemptime, 3)
		EndIf
		Return $stempdate
	EndFunc

	Func _datetimesplit($sdate, ByRef $asdatepart, ByRef $itimepart)
		Local $sdatetime = StringSplit($sdate, " T")
		If $sdatetime[0] > 0 Then $asdatepart = StringSplit($sdatetime[1], "/-.")
		If $sdatetime[0] > 1 Then
			$itimepart = StringSplit($sdatetime[2], ":")
			If UBound($itimepart) < 4 Then ReDim $itimepart[4]
		Else
			Dim $itimepart[4]
		EndIf
		If UBound($asdatepart) < 4 Then ReDim $asdatepart[4]
		For $x = 1 To 3
			If StringIsInt($asdatepart[$x]) Then
				$asdatepart[$x] = Number($asdatepart[$x])
			Else
				$asdatepart[$x] = -1
			EndIf
			If StringIsInt($itimepart[$x]) Then
				$itimepart[$x] = Number($itimepart[$x])
			Else
				$itimepart[$x] = 0
			EndIf
		Next
		Return 1
	EndFunc

	Func _datetodayofweek($iyear, $imonth, $iday)
		If NOT _dateisvalid($iyear & "/" & $imonth & "/" & $iday) Then
			Return SetError(1, 0, "")
		EndIf
		Local $i_afactor = Int((14 - $imonth) / 12)
		Local $i_yfactor = $iyear - $i_afactor
		Local $i_mfactor = $imonth + (12 * $i_afactor) - 2
		Local $i_dfactor = Mod($iday + $i_yfactor + Int($i_yfactor / 4) - Int($i_yfactor / 100) + Int($i_yfactor / 400) + Int((31 * $i_mfactor) / 12), 7)
		Return ($i_dfactor + 1)
	EndFunc

	Func _datetodayofweekiso($iyear, $imonth, $iday)
		Local $idow = _datetodayofweek($iyear, $imonth, $iday)
		If @error Then
			Return SetError(1, 0, "")
		EndIf
		If $idow >= 2 Then Return $idow - 2
		Return 6
	EndFunc

	Func _datetodayvalue($iyear, $imonth, $iday)
		If NOT _dateisvalid(StringFormat("%04d/%02d/%02d", $iyear, $imonth, $iday)) Then
			Return SetError(1, 0, "")
		EndIf
		If $imonth < 3 Then
			$imonth = $imonth + 12
			$iyear = $iyear - 1
		EndIf
		Local $i_afactor = Int($iyear / 100)
		Local $i_bfactor = Int($i_afactor / 4)
		Local $i_cfactor = 2 - $i_afactor + $i_bfactor
		Local $i_efactor = Int(1461 * ($iyear + 4716) / 4)
		Local $i_ffactor = Int(153 * ($imonth + 1) / 5)
		Local $ijuliandate = $i_cfactor + $iday + $i_efactor + $i_ffactor - 1524.5
		Return ($ijuliandate)
	EndFunc

	Func _datetomonth($imonth, $ishort = 0)
		Local $amonthnumber[13] = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		Local $amonthnumberabbrev[13] = ["", "Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
		Select 
			Case NOT StringIsInt($imonth)
				Return SetError(1, 0, "")
			Case $imonth < 1 OR $imonth > 12
				Return SetError(1, 0, "")
			Case Else
				Select 
					Case $ishort = 0
						Return $amonthnumber[$imonth]
					Case $ishort = 1
						Return $amonthnumberabbrev[$imonth]
					Case Else
						Return SetError(1, 0, "")
				EndSelect
		EndSelect
	EndFunc

	Func _dayvaluetodate($ijuliandate, ByRef $iyear, ByRef $imonth, ByRef $iday)
		If $ijuliandate < 0 OR NOT IsNumber($ijuliandate) Then
			Return SetError(1, 0, 0)
		EndIf
		Local $i_zfactor = Int($ijuliandate + 0.5)
		Local $i_wfactor = Int(($i_zfactor - 1867216.25) / 36524.25)
		Local $i_xfactor = Int($i_wfactor / 4)
		Local $i_afactor = $i_zfactor + 1 + $i_wfactor - $i_xfactor
		Local $i_bfactor = $i_afactor + 1524
		Local $i_cfactor = Int(($i_bfactor - 122.1) / 365.25)
		Local $i_dfactor = Int(365.25 * $i_cfactor)
		Local $i_efactor = Int(($i_bfactor - $i_dfactor) / 30.6001)
		Local $i_ffactor = Int(30.6001 * $i_efactor)
		$iday = $i_bfactor - $i_dfactor - $i_ffactor
		If $i_efactor - 1 < 13 Then
			$imonth = $i_efactor - 1
		Else
			$imonth = $i_efactor - 13
		EndIf
		If $imonth < 3 Then
			$iyear = $i_cfactor - 4715
		Else
			$iyear = $i_cfactor - 4716
		EndIf
		$iyear = StringFormat("%04d", $iyear)
		$imonth = StringFormat("%02d", $imonth)
		$iday = StringFormat("%02d", $iday)
		Return $iyear & "/" & $imonth & "/" & $iday
	EndFunc

	Func _date_juliandayno($iyear, $imonth, $iday)
		Local $sfulldate = StringFormat("%04d/%02d/%02d", $iyear, $imonth, $iday)
		If NOT _dateisvalid($sfulldate) Then
			Return SetError(1, 0, "")
		EndIf
		Local $ijday = 0
		Local $aidaysinmonth = _daysinmonth($iyear)
		For $icntr = 1 To $imonth - 1
			$ijday = $ijday + $aidaysinmonth[$icntr]
		Next
		$ijday = ($iyear * 1000) + ($ijday + $iday)
		Return $ijday
	EndFunc

	Func _juliantodate($ijday, $ssep = "/")
		Local $iyear = Int($ijday / 1000)
		Local $idays = Mod($ijday, 1000)
		Local $imaxdays = 365
		If _dateisleapyear($iyear) Then $imaxdays = 366
		If $idays > $imaxdays Then
			Return SetError(1, 0, "")
		EndIf
		Local $aidaysinmonth = _daysinmonth($iyear)
		Local $imonth = 1
		While $idays > $aidaysinmonth[$imonth]
			$idays = $idays - $aidaysinmonth[$imonth]
			$imonth = $imonth + 1
		WEnd
		Return StringFormat("%04d%s%02d%s%02d", $iyear, $ssep, $imonth, $ssep, $idays)
	EndFunc

	Func _now()
		Return (_datetimeformat(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0))
	EndFunc

	Func _nowcalc()
		Return (@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
	EndFunc

	Func _nowcalcdate()
		Return (@YEAR & "/" & @MON & "/" & @MDAY)
	EndFunc

	Func _nowdate()
		Return (_datetimeformat(@YEAR & "/" & @MON & "/" & @MDAY, 0))
	EndFunc

	Func _nowtime($stype = 3)
		If $stype < 3 OR $stype > 5 Then $stype = 3
		Return (_datetimeformat(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, $stype))
	EndFunc

	Func _setdate($iday, $imonth = 0, $iyear = 0)
		If $iyear = 0 Then $iyear = @YEAR
		If $imonth = 0 Then $imonth = @MON
		If NOT _dateisvalid($iyear & "/" & $imonth & "/" & $iday) Then Return 1
		Local $tsystemtime = DllStructCreate($tagsystemtime)
		Local $lpsystemtime = DllStructGetPtr($tsystemtime)
		DllCall("kernel32.dll", "none", "GetLocalTime", "ptr", $lpsystemtime)
		If @error Then Return SetError(@error, @extended, 0)
		DllStructSetData($tsystemtime, 4, $iday)
		If $imonth > 0 Then DllStructSetData($tsystemtime, 2, $imonth)
		If $iyear > 0 Then DllStructSetData($tsystemtime, 1, $iyear)
		Local $iretval = _date_time_setlocaltime($lpsystemtime)
		If @error Then Return SetError(@error, @extended, 0)
		Return Int($iretval[0])
	EndFunc

	Func _settime($ihour, $iminute, $isecond = 0)
		If $ihour < 0 OR $ihour > 23 Then Return 1
		If $iminute < 0 OR $iminute > 59 Then Return 1
		If $isecond < 0 OR $isecond > 59 Then Return 1
		Local $tsystemtime = DllStructCreate($tagsystemtime)
		Local $lpsystemtime = DllStructGetPtr($tsystemtime)
		DllCall("kernel32.dll", "none", "GetLocalTime", "ptr", $lpsystemtime)
		If @error Then Return SetError(@error, @extended, 0)
		DllStructSetData($tsystemtime, 5, $ihour)
		DllStructSetData($tsystemtime, 6, $iminute)
		If $isecond > 0 Then DllStructSetData($tsystemtime, 7, $isecond)
		Local $iretval = _date_time_setlocaltime($lpsystemtime)
		If @error Then Return SetError(@error, @extended, 0)
		Return Int($iretval[0])
	EndFunc

	Func _tickstotime($iticks, ByRef $ihours, ByRef $imins, ByRef $isecs)
		If Number($iticks) > 0 Then
			$iticks = Int($iticks / 1000)
			$ihours = Int($iticks / 3600)
			$iticks = Mod($iticks, 3600)
			$imins = Int($iticks / 60)
			$isecs = Mod($iticks, 60)
			Return 1
		ElseIf Number($iticks) = 0 Then
			$ihours = 0
			$iticks = 0
			$imins = 0
			$isecs = 0
			Return 1
		Else
			Return SetError(1, 0, 0)
		EndIf
	EndFunc

	Func _timetoticks($ihours = @HOUR, $imins = @MIN, $isecs = @SEC)
		If StringIsInt($ihours) AND StringIsInt($imins) AND StringIsInt($isecs) Then
			Local $iticks = 1000 * ((3600 * $ihours) + (60 * $imins) + $isecs)
			Return $iticks
		Else
			Return SetError(1, 0, 0)
		EndIf
	EndFunc

	Func _weeknumberiso($iyear = @YEAR, $imonth = @MON, $iday = @MDAY)
		If $iday > 31 OR $iday < 1 Then
			Return SetError(1, 0, -1)
		ElseIf $imonth > 12 OR $imonth < 1 Then
			Return SetError(1, 0, -1)
		ElseIf $iyear < 1 OR $iyear > 2999 Then
			Return SetError(1, 0, -1)
		EndIf
		Local $idow = _datetodayofweekiso($iyear, $imonth, $iday)
		Local $idow0101 = _datetodayofweekiso($iyear, 1, 1)
		If ($imonth = 1 AND 3 < $idow0101 AND $idow0101 < 7 - ($iday - 1)) Then
			$idow = $idow0101 - 1
			$idow0101 = _datetodayofweekiso($iyear - 1, 1, 1)
			$imonth = 12
			$iday = 31
			$iyear = $iyear - 1
		ElseIf ($imonth = 12 AND 30 - ($iday - 1) < _datetodayofweekiso($iyear + 1, 1, 1) AND _datetodayofweekiso($iyear + 1, 1, 1) < 4) Then
			Return 1
		EndIf
		Return Int((_datetodayofweekiso($iyear, 1, 1) < 4) + 4 * ($imonth - 1) + (2 * ($imonth - 1) + ($iday - 1) + $idow0101 - $idow + 6) * 36 / 256)
	EndFunc

	Func _weeknumber($iyear = @YEAR, $imonth = @MON, $iday = @MDAY, $iweekstart = 1)
		If $iday > 31 OR $iday < 1 Then
			Return SetError(1, 0, -1)
		ElseIf $imonth > 12 OR $imonth < 1 Then
			Return SetError(1, 0, -1)
		ElseIf $iyear < 1 OR $iyear > 2999 Then
			Return SetError(1, 0, -1)
		ElseIf $iweekstart < 1 OR $iweekstart > 2 Then
			Return SetError(2, 0, -1)
		EndIf
		Local $istartweek1, $iendweek1
		Local $idow0101 = _datetodayofweekiso($iyear, 1, 1)
		Local $idate = $iyear & "/" & $imonth & "/" & $iday
		If $iweekstart = 1 Then
			If $idow0101 = 6 Then
				$istartweek1 = 0
			Else
				$istartweek1 = -1 * $idow0101 - 1
			EndIf
			$iendweek1 = $istartweek1 + 6
		Else
			$istartweek1 = $idow0101 * -1
			$iendweek1 = $istartweek1 + 6
		EndIf
		Local $istartweek1ny
		Local $iendweek1date = _dateadd("d", $iendweek1, $iyear & "/01/01")
		Local $idow0101ny = _datetodayofweekiso($iyear + 1, 1, 1)
		If $iweekstart = 1 Then
			If $idow0101ny = 6 Then
				$istartweek1ny = 0
			Else
				$istartweek1ny = -1 * $idow0101ny - 1
			EndIf
		Else
			$istartweek1ny = $idow0101ny * -1
		EndIf
		Local $istartweek1dateny = _dateadd("d", $istartweek1ny, $iyear + 1 & "/01/01")
		Local $icurrdatediff = _datediff("d", $iendweek1date, $idate) - 1
		Local $icurrdatediffny = _datediff("d", $istartweek1dateny, $idate)
		If $icurrdatediff >= 0 AND $icurrdatediffny < 0 Then Return 2 + Int($icurrdatediff / 7)
		If $icurrdatediff < 0 OR $icurrdatediffny >= 0 Then Return 1
	EndFunc

	Func _daysinmonth($iyear)
		Local $aidays[13] = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		If _dateisleapyear($iyear) Then $aidays[2] = 29
		Return $aidays
	EndFunc

	Func __date_time_clonesystemtime($psystemtime)
		Local $tsystemtime1 = DllStructCreate($tagsystemtime, $psystemtime)
		Local $tsystemtime2 = DllStructCreate($tagsystemtime)
		DllStructSetData($tsystemtime2, "Month", DllStructGetData($tsystemtime1, "Month"))
		DllStructSetData($tsystemtime2, "Day", DllStructGetData($tsystemtime1, "Day"))
		DllStructSetData($tsystemtime2, "Year", DllStructGetData($tsystemtime1, "Year"))
		DllStructSetData($tsystemtime2, "Hour", DllStructGetData($tsystemtime1, "Hour"))
		DllStructSetData($tsystemtime2, "Minute", DllStructGetData($tsystemtime1, "Minute"))
		DllStructSetData($tsystemtime2, "Second", DllStructGetData($tsystemtime1, "Second"))
		DllStructSetData($tsystemtime2, "MSeconds", DllStructGetData($tsystemtime1, "MSeconds"))
		DllStructSetData($tsystemtime2, "DOW", DllStructGetData($tsystemtime1, "DOW"))
		Return $tsystemtime2
	EndFunc

	Func _date_time_comparefiletime($pfiletime1, $pfiletime2)
		Local $aresult = DllCall("kernel32.dll", "long", "CompareFileTime", "ptr", $pfiletime1, "ptr", $pfiletime2)
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _date_time_dosdatetimetofiletime($ifatdate, $ifattime)
		Local $ttime = DllStructCreate($tagfiletime)
		Local $ptime = DllStructGetPtr($ttime)
		Local $aresult = DllCall("kernel32.dll", "bool", "DosDateTimeToFileTime", "word", $ifatdate, "word", $ifattime, "ptr", $ptime)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $ttime)
	EndFunc

	Func _date_time_dosdatetoarray($idosdate)
		Local $adate[3]
		$adate[0] = BitAND($idosdate, 31)
		$adate[1] = BitAND(BitShift($idosdate, 5), 15)
		$adate[2] = BitAND(BitShift($idosdate, 9), 63) + 1980
		Return $adate
	EndFunc

	Func _date_time_dosdatetimetoarray($idosdate, $idostime)
		Local $adate[6]
		$adate[0] = BitAND($idosdate, 31)
		$adate[1] = BitAND(BitShift($idosdate, 5), 15)
		$adate[2] = BitAND(BitShift($idosdate, 9), 63) + 1980
		$adate[5] = BitAND($idostime, 31) * 2
		$adate[4] = BitAND(BitShift($idostime, 5), 63)
		$adate[3] = BitAND(BitShift($idostime, 11), 31)
		Return $adate
	EndFunc

	Func _date_time_dosdatetimetostr($idosdate, $idostime)
		Local $adate = _date_time_dosdatetimetoarray($idosdate, $idostime)
		Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $adate[0], $adate[1], $adate[2], $adate[3], $adate[4], $adate[5])
	EndFunc

	Func _date_time_dosdatetostr($idosdate)
		Local $adate = _date_time_dosdatetoarray($idosdate)
		Return StringFormat("%02d/%02d/%04d", $adate[0], $adate[1], $adate[2])
	EndFunc

	Func _date_time_dostimetoarray($idostime)
		Local $atime[3]
		$atime[2] = BitAND($idostime, 31) * 2
		$atime[1] = BitAND(BitShift($idostime, 5), 63)
		$atime[0] = BitAND(BitShift($idostime, 11), 31)
		Return $atime
	EndFunc

	Func _date_time_dostimetostr($idostime)
		Local $atime = _date_time_dostimetoarray($idostime)
		Return StringFormat("%02d:%02d:%02d", $atime[0], $atime[1], $atime[2])
	EndFunc

	Func _date_time_encodefiletime($imonth, $iday, $iyear, $ihour = 0, $iminute = 0, $isecond = 0, $imseconds = 0)
		Local $tsystemtime = _date_time_encodesystemtime($imonth, $iday, $iyear, $ihour, $iminute, $isecond, $imseconds)
		Return _date_time_systemtimetofiletime(DllStructGetPtr($tsystemtime))
	EndFunc

	Func _date_time_encodesystemtime($imonth, $iday, $iyear, $ihour = 0, $iminute = 0, $isecond = 0, $imseconds = 0)
		Local $tsystemtime = DllStructCreate($tagsystemtime)
		DllStructSetData($tsystemtime, "Month", $imonth)
		DllStructSetData($tsystemtime, "Day", $iday)
		DllStructSetData($tsystemtime, "Year", $iyear)
		DllStructSetData($tsystemtime, "Hour", $ihour)
		DllStructSetData($tsystemtime, "Minute", $iminute)
		DllStructSetData($tsystemtime, "Second", $isecond)
		DllStructSetData($tsystemtime, "MSeconds", $imseconds)
		Return $tsystemtime
	EndFunc

	Func _date_time_filetimetoarray(ByRef $tfiletime)
		If ((DllStructGetData($tfiletime, 1) + DllStructGetData($tfiletime, 2)) = 0) Then Return SetError(1, 0, 0)
		Local $tsystemtime = _date_time_filetimetosystemtime(DllStructGetPtr($tfiletime))
		If @error Then Return SetError(@error, @extended, 0)
		Return _date_time_systemtimetoarray($tsystemtime)
	EndFunc

	Func _date_time_filetimetostr(ByRef $tfiletime, $bfmt = 0)
		Local $adate = _date_time_filetimetoarray($tfiletime)
		If @error Then Return SetError(@error, @extended, "")
		If $bfmt Then
			Return StringFormat("%04d/%02d/%02d %02d:%02d:%02d", $adate[2], $adate[1], $adate[0], $adate[3], $adate[4], $adate[5])
		Else
			Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $adate[0], $adate[1], $adate[2], $adate[3], $adate[4], $adate[5])
		EndIf
	EndFunc

	Func _date_time_filetimetodosdatetime($pfiletime)
		Local $adate[2]
		Local $aresult = DllCall("kernel32.dll", "bool", "FileTimeToDosDateTime", "ptr", $pfiletime, "word*", 0, "word*", 0)
		If @error Then Return SetError(@error, @extended, $adate)
		$adate[0] = $aresult[2]
		$adate[1] = $aresult[3]
		Return SetExtended($aresult[0], $adate)
	EndFunc

	Func _date_time_filetimetolocalfiletime($pfiletime)
		Local $tlocal = DllStructCreate($tagfiletime)
		Local $aresult = DllCall("kernel32.dll", "bool", "FileTimeToLocalFileTime", "ptr", $pfiletime, "ptr", DllStructGetPtr($tlocal))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tlocal)
	EndFunc

	Func _date_time_filetimetosystemtime($pfiletime)
		Local $tsysttime = DllStructCreate($tagsystemtime)
		Local $aresult = DllCall("kernel32.dll", "bool", "FileTimeToSystemTime", "ptr", $pfiletime, "ptr", DllStructGetPtr($tsysttime))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tsysttime)
	EndFunc

	Func _date_time_getfiletime($hfile)
		Local $adate[3]
		$adate[0] = DllStructCreate($tagfiletime)
		$adate[1] = DllStructCreate($tagfiletime)
		$adate[2] = DllStructCreate($tagfiletime)
		Local $pct = DllStructGetPtr($adate[0])
		Local $pla = DllStructGetPtr($adate[1])
		Local $plm = DllStructGetPtr($adate[2])
		Local $aresult = DllCall("Kernel32.dll", "bool", "GetFileTime", "handle", $hfile, "ptr", $pct, "ptr", $pla, "ptr", $plm)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $adate)
	EndFunc

	Func _date_time_getlocaltime()
		Local $tsysttime = DllStructCreate($tagsystemtime)
		DllCall("kernel32.dll", "none", "GetLocalTime", "ptr", DllStructGetPtr($tsysttime))
		If @error Then Return SetError(@error, @extended, 0)
		Return $tsysttime
	EndFunc

	Func _date_time_getsystemtime()
		Local $tsysttime = DllStructCreate($tagsystemtime)
		DllCall("kernel32.dll", "none", "GetSystemTime", "ptr", DllStructGetPtr($tsysttime))
		If @error Then Return SetError(@error, @extended, 0)
		Return $tsysttime
	EndFunc

	Func _date_time_getsystemtimeadjustment()
		Local $ainfo[3]
		Local $aresult = DllCall("kernel32.dll", "bool", "GetSystemTimeAdjustment", "dword*", 0, "dword*", 0, "bool*", 0)
		If @error Then Return SetError(@error, @extended, 0)
		$ainfo[0] = $aresult[1]
		$ainfo[1] = $aresult[2]
		$ainfo[2] = $aresult[3] <> 0
		Return SetExtended($aresult[0], $ainfo)
	EndFunc

	Func _date_time_getsystemtimeasfiletime()
		Local $tfiletime = DllStructCreate($tagfiletime)
		DllCall("kernel32.dll", "none", "GetSystemTimeAsFileTime", "ptr", DllStructGetPtr($tfiletime))
		If @error Then Return SetError(@error, @extended, 0)
		Return $tfiletime
	EndFunc

	Func _date_time_getsystemtimes()
		Local $ainfo[3]
		$ainfo[0] = DllStructCreate($tagfiletime)
		$ainfo[1] = DllStructCreate($tagfiletime)
		$ainfo[2] = DllStructCreate($tagfiletime)
		Local $pidle = DllStructGetPtr($ainfo[0])
		Local $pkernel = DllStructGetPtr($ainfo[1])
		Local $puser = DllStructGetPtr($ainfo[2])
		Local $aresult = DllCall("kernel32.dll", "bool", "GetSystemTimes", "ptr", $pidle, "ptr", $pkernel, "ptr", $puser)
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $ainfo)
	EndFunc

	Func _date_time_gettickcount()
		Local $aresult = DllCall("kernel32.dll", "dword", "GetTickCount")
		If @error Then Return SetError(@error, @extended, 0)
		Return $aresult[0]
	EndFunc

	Func _date_time_gettimezoneinformation()
		Local $ttimezone = DllStructCreate($tagtime_zone_information)
		Local $aresult = DllCall("kernel32.dll", "dword", "GetTimeZoneInformation", "ptr", DllStructGetPtr($ttimezone))
		If @error OR $aresult[0] = -1 Then Return SetError(@error, @extended, 0)
		Local $ainfo[8]
		$ainfo[0] = $aresult[0]
		$ainfo[1] = DllStructGetData($ttimezone, "Bias")
		$ainfo[2] = _winapi_widechartomultibyte(DllStructGetPtr($ttimezone, "StdName"))
		$ainfo[3] = __date_time_clonesystemtime(DllStructGetPtr($ttimezone, "StdDate"))
		$ainfo[4] = DllStructGetData($ttimezone, "StdBias")
		$ainfo[5] = _winapi_widechartomultibyte(DllStructGetPtr($ttimezone, "DayName"))
		$ainfo[6] = __date_time_clonesystemtime(DllStructGetPtr($ttimezone, "DayDate"))
		$ainfo[7] = DllStructGetData($ttimezone, "DayBias")
		Return $ainfo
	EndFunc

	Func _date_time_localfiletimetofiletime($plocaltime)
		Local $tfiletime = DllStructCreate($tagfiletime)
		Local $aresult = DllCall("kernel32.dll", "bool", "LocalFileTimeToFileTime", "ptr", $plocaltime, "ptr", DllStructGetPtr($tfiletime))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tfiletime)
	EndFunc

	Func _date_time_setfiletime($hfile, $pcreatetime, $plastaccess, $plastwrite)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetFileTime", "handle", $hfile, "ptr", $pcreatetime, "ptr", $plastaccess, "ptr", $plastwrite)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _date_time_setlocaltime($psystemtime)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetLocalTime", "ptr", $psystemtime)
		If @error OR NOT $aresult Then Return SetError(@error, @extended, False)
		$aresult = DllCall("kernel32.dll", "bool", "SetLocalTime", "ptr", $psystemtime)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _date_time_setsystemtime($psystemtime)
		Local $aresult = DllCall("kernel32.dll", "bool", "SetSystemTime", "ptr", $psystemtime)
		If @error Then Return SetError(@error, @extended, False)
		Return $aresult[0]
	EndFunc

	Func _date_time_setsystemtimeadjustment($iadjustment, $fdisabled)
		Local $htoken = _security__openthreadtokenex(BitOR($token_adjust_privileges, $token_query))
		If @error Then Return SetError(@error, @extended, False)
		_security__setprivilege($htoken, "SeSystemtimePrivilege", True)
		Local $ierror = @error
		Local $ilasterror = @extended
		Local $iret = False
		If NOT @error Then
			Local $aresult = DllCall("kernel32.dll", "bool", "SetSystemTimeAdjustment", "dword", $iadjustment, "bool", $fdisabled)
			If @error Then
				$ierror = @error
				$ilasterror = @extended
			ElseIf $aresult[0] Then
				$iret = True
			Else
				$ierror = 1
				$ilasterror = _winapi_getlasterror()
			EndIf
			_security__setprivilege($htoken, "SeSystemtimePrivilege", False)
			If @error Then $ierror = 2
		EndIf
		_winapi_closehandle($htoken)
		Return SetError($ierror, $ilasterror, $iret)
	EndFunc

	Func _date_time_settimezoneinformation($ibias, $sstdname, $tstddate, $istdbias, $sdayname, $tdaydate, $idaybias)
		Local $tstdname = _winapi_multibytetowidechar($sstdname)
		Local $tdayname = _winapi_multibytetowidechar($sdayname)
		Local $tzoneinfo = DllStructCreate($tagtime_zone_information)
		DllStructSetData($tzoneinfo, "Bias", $ibias)
		DllStructSetData($tzoneinfo, "StdName", DllStructGetData($tstdname, 1))
		_memmovememory(DllStructGetPtr($tstddate), DllStructGetPtr($tzoneinfo, "StdDate"), DllStructGetSize($tstddate))
		DllStructSetData($tzoneinfo, "StdBias", $istdbias)
		DllStructSetData($tzoneinfo, "DayName", DllStructGetData($tdayname, 1))
		_memmovememory(DllStructGetPtr($tdaydate), DllStructGetPtr($tzoneinfo, "DayDate"), DllStructGetSize($tdaydate))
		DllStructSetData($tzoneinfo, "DayBias", $idaybias)
		Local $htoken = _security__openthreadtokenex(BitOR($token_adjust_privileges, $token_query))
		If @error Then Return SetError(@error, @extended, False)
		_security__setprivilege($htoken, "SeSystemtimePrivilege", True)
		Local $ierror = @error
		Local $ilasterror = @extended
		Local $iret = False
		If NOT @error Then
			Local $aresult = DllCall("kernel32.dll", "bool", "SetTimeZoneInformation", "ptr", DllStructGetPtr($tzoneinfo))
			If @error Then
				$ierror = @error
				$ilasterror = @extended
			ElseIf $aresult[0] Then
				$ilasterror = 0
				$iret = True
			Else
				$ierror = 1
				$ilasterror = _winapi_getlasterror()
			EndIf
			_security__setprivilege($htoken, "SeSystemtimePrivilege", False)
			If @error Then $ierror = 2
		EndIf
		_winapi_closehandle($htoken)
		Return SetError($ierror, $ilasterror, $iret)
	EndFunc

	Func _date_time_systemtimetoarray(ByRef $tsystemtime)
		Local $ainfo[8]
		$ainfo[0] = DllStructGetData($tsystemtime, "Month")
		$ainfo[1] = DllStructGetData($tsystemtime, "Day")
		$ainfo[2] = DllStructGetData($tsystemtime, "Year")
		$ainfo[3] = DllStructGetData($tsystemtime, "Hour")
		$ainfo[4] = DllStructGetData($tsystemtime, "Minute")
		$ainfo[5] = DllStructGetData($tsystemtime, "Second")
		$ainfo[6] = DllStructGetData($tsystemtime, "MSeconds")
		$ainfo[7] = DllStructGetData($tsystemtime, "DOW")
		Return $ainfo
	EndFunc

	Func _date_time_systemtimetodatestr(ByRef $tsystemtime, $bfmt = 0)
		Local $ainfo = _date_time_systemtimetoarray($tsystemtime)
		If @error Then Return SetError(@error, @extended, "")
		If $bfmt Then
			Return StringFormat("%04d/%02d/%02d", $ainfo[2], $ainfo[0], $ainfo[1])
		Else
			Return StringFormat("%02d/%02d/%04d", $ainfo[0], $ainfo[1], $ainfo[2])
		EndIf
	EndFunc

	Func _date_time_systemtimetodatetimestr(ByRef $tsystemtime, $bfmt = 0)
		Local $ainfo = _date_time_systemtimetoarray($tsystemtime)
		If @error Then Return SetError(@error, @extended, "")
		If $bfmt Then
			Return StringFormat("%04d/%02d/%02d %02d:%02d:%02d", $ainfo[2], $ainfo[0], $ainfo[1], $ainfo[3], $ainfo[4], $ainfo[5])
		Else
			Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $ainfo[0], $ainfo[1], $ainfo[2], $ainfo[3], $ainfo[4], $ainfo[5])
		EndIf
	EndFunc

	Func _date_time_systemtimetofiletime($psystemtime)
		Local $tfiletime = DllStructCreate($tagfiletime)
		Local $aresult = DllCall("kernel32.dll", "bool", "SystemTimeToFileTime", "ptr", $psystemtime, "ptr", DllStructGetPtr($tfiletime))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tfiletime)
	EndFunc

	Func _date_time_systemtimetotimestr(ByRef $tsystemtime)
		Local $ainfo = _date_time_systemtimetoarray($tsystemtime)
		Return StringFormat("%02d:%02d:%02d", $ainfo[3], $ainfo[4], $ainfo[5])
	EndFunc

	Func _date_time_systemtimetotzspecificlocaltime($putc, $ptimezone = 0)
		Local $tlocaltime = DllStructCreate($tagsystemtime)
		Local $aresult = DllCall("kernel32.dll", "bool", "SystemTimeToTzSpecificLocalTime", "ptr", $ptimezone, "ptr", $putc, "ptr", DllStructGetPtr($tlocaltime))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tlocaltime)
	EndFunc

	Func _date_time_tzspecificlocaltimetosystemtime($plocaltime, $ptimezone = 0)
		Local $tutc = DllStructCreate($tagsystemtime)
		Local $aresult = DllCall("kernel32.dll", "ptr", "TzSpecificLocalTimeToSystemTime", "ptr", $ptimezone, "ptr", $plocaltime, "ptr", DllStructGetPtr($tutc))
		If @error Then Return SetError(@error, @extended, 0)
		Return SetExtended($aresult[0], $tutc)
	EndFunc

	Func _getip()
		Local $ip, $t_ip
		If InetGet("http://checkip.dyndns.org/?rnd1=" & Random(1, 65536) & "&rnd2=" & Random(1, 65536), @TempDir & "\~ip.tmp") Then
			$ip = FileRead(@TempDir & "\~ip.tmp", FileGetSize(@TempDir & "\~ip.tmp"))
			FileDelete(@TempDir & "\~ip.tmp")
			$ip = StringTrimLeft($ip, StringInStr($ip, ":") + 1)
			$ip = StringTrimRight($ip, StringLen($ip) - StringInStr($ip, "/") + 2)
			$t_ip = StringSplit($ip, ".")
			If $t_ip[0] = 4 AND StringIsDigit($t_ip[1]) AND StringIsDigit($t_ip[2]) AND StringIsDigit($t_ip[3]) AND StringIsDigit($t_ip[4]) Then
				Return $ip
			EndIf
		EndIf
		If InetGet("http://www.whatismyip.com/?rnd1=" & Random(1, 65536) & "&rnd2=" & Random(1, 65536), @TempDir & "\~ip.tmp") Then
			$ip = FileRead(@TempDir & "\~ip.tmp", FileGetSize(@TempDir & "\~ip.tmp"))
			FileDelete(@TempDir & "\~ip.tmp")
			$ip = StringTrimLeft($ip, StringInStr($ip, "Your ip is") + 10)
			$ip = StringLeft($ip, StringInStr($ip, " ") - 1)
			$ip = StringStripWS($ip, 8)
			$t_ip = StringSplit($ip, ".")
			If $t_ip[0] = 4 AND StringIsDigit($t_ip[1]) AND StringIsDigit($t_ip[2]) AND StringIsDigit($t_ip[3]) AND StringIsDigit($t_ip[4]) Then
				Return $ip
			EndIf
		EndIf
		Return SetError(1, 0, -1)
	EndFunc

	Func _inetexplorercapable($s_iestring)
		If StringLen($s_iestring) <= 0 Then Return SetError(1, 0, "")
		Local $s_iereturn
		Local $n_iechar
		For $i_iecount = 1 To StringLen($s_iestring)
			$n_iechar = "0x" & Hex(Asc(StringMid($s_iestring, $i_iecount, 1)), 2)
			If $n_iechar < 33 OR $n_iechar = 37 OR $n_iechar = 47 OR $n_iechar > 127 Then
				$s_iereturn = $s_iereturn & "%" & StringRight($n_iechar, 2)
			Else
				$s_iereturn = $s_iereturn & Chr($n_iechar)
			EndIf
		Next
		Return $s_iereturn
	EndFunc

	Func _inetgetsource($s_url, $bstring = True)
		Local $sstring = InetRead($s_url, 1)
		Local $nerror = @error, $nextended = @extended
		If $bstring Then $sstring = BinaryToString($sstring)
		Return SetError($nerror, $nextended, $sstring)
	EndFunc

	Func _inetmail($s_mailto, $s_mailsubject, $s_mailbody)
		Local $prev = Opt("ExpandEnvStrings", 1)
		Local $var = RegRead("HKCR\mailto\shell\open\command", "")
		Local $ret = Run(StringReplace($var, "%1", _inetexplorercapable("mailto:" & $s_mailto & "?subject=" & $s_mailsubject & "&body=" & $s_mailbody)))
		Local $nerror = @error, $nextended = @extended
		Opt("ExpandEnvStrings", $prev)
		Return SetError($nerror, $nextended, $ret)
	EndFunc

	Func _inetsmtpmail($s_smtpserver, $s_fromname, $s_fromaddress, $s_toaddress, $s_subject = "", $as_body = "", $s_helo = "", $s_first = " ", $b_trace = 0)
		If $s_smtpserver = "" OR $s_fromaddress = "" OR $s_toaddress = "" OR $s_fromname = "" OR StringLen($s_fromname) > 256 Then Return SetError(1, 0, 0)
		If $s_helo = "" Then $s_helo = @ComputerName
		If TCPStartup() = 0 Then Return SetError(2, 0, 0)
		Local $s_ipaddress, $i_count
		StringRegExp($s_smtpserver, "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
		If @extended Then
			$s_ipaddress = $s_smtpserver
		Else
			$s_ipaddress = TCPNameToIP($s_smtpserver)
		EndIf
		If $s_ipaddress = "" Then
			TCPShutdown()
			Return SetError(3, 0, 0)
		EndIf
		Local $v_socket = TCPConnect($s_ipaddress, 25)
		If $v_socket = -1 Then
			TCPShutdown()
			Return SetError(4, 0, 0)
		EndIf
		Local $s_send[6], $s_replycode[6]
		$s_send[0] = "HELO " & $s_helo & @CRLF
		If StringLeft($s_helo, 5) = "EHLO " Then $s_send[0] = $s_helo & @CRLF
		$s_replycode[0] = "250"
		$s_send[1] = "MAIL FROM: <" & $s_fromaddress & ">" & @CRLF
		$s_replycode[1] = "250"
		$s_send[2] = "RCPT TO: <" & $s_toaddress & ">" & @CRLF
		$s_replycode[2] = "250"
		$s_send[3] = "DATA" & @CRLF
		$s_replycode[3] = "354"
		Local $aresult = _date_time_gettimezoneinformation()
		Local $bias = -$aresult[1] / 60
		Local $biash = Int($bias)
		Local $biasm = 0
		If $biash <> $bias Then $biasm = Abs($bias - $biash) * 60
		$bias = StringFormat(" (%+.2d%.2d)", $biash, $biasm)
		$s_send[4] = "From:" & $s_fromname & "<" & $s_fromaddress & ">" & @CRLF & "To:" & "<" & $s_toaddress & ">" & @CRLF & "Subject:" & $s_subject & @CRLF & "Mime-Version: 1.0" & @CRLF & "Date: " & _datedayofweek(@WDAY, 1) & ", " & @MDAY & " " & _datetomonth(@MON, 1) & " " & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & $bias & @CRLF & "Content-Type: text/plain; charset=US-ASCII" & @CRLF & @CRLF
		$s_replycode[4] = ""
		$s_send[5] = @CRLF & "." & @CRLF
		$s_replycode[5] = "250"
		If __smtpsend($v_socket, $s_send[0], $s_replycode[0], $b_trace, "220", $s_first) Then Return SetError(50, 0, 0)
		For $i_count = 1 To UBound($s_send) - 2
			If __smtpsend($v_socket, $s_send[$i_count], $s_replycode[$i_count], $b_trace) Then Return SetError(50 + $i_count, 0, 0)
		Next
		For $i_count = 0 To UBound($as_body) - 1
			If StringLeft($as_body[$i_count], 1) = "." Then $as_body[$i_count] = "." & $as_body[$i_count]
			If __smtpsend($v_socket, $as_body[$i_count] & @CRLF, "", $b_trace) Then Return SetError(500 + $i_count, 0, 0)
		Next
		$i_count = UBound($s_send) - 1
		If __smtpsend($v_socket, $s_send[$i_count], $s_replycode[$i_count], $b_trace) Then Return SetError(5000, 0, 0)
		TCPCloseSocket($v_socket)
		TCPShutdown()
		Return 1
	EndFunc

	Func __smtptrace($str, $timeout = 0)
		Local $w_title = "SMTP trace"
		Local $s_smtptrace = ControlGetText($w_title, "", "Static1")
		$str = StringLeft(StringReplace($str, @CRLF, ""), 70)
		$s_smtptrace &= @HOUR & ":" & @MIN & ":" & @SEC & " " & $str & @LF
		If WinExists($w_title) Then
			ControlSetText($w_title, "", "Static1", $s_smtptrace)
		Else
			SplashTextOn($w_title, $s_smtptrace, 400, 500, 500, 100, 4 + 16, "", 8)
		EndIf
		If $timeout Then Sleep($timeout * 1000)
	EndFunc

	Func __smtpsend($v_socket, $s_send, $s_replycode, $b_trace, $s_intreply = "", $s_first = "")
		Local $s_receive, $i, $timer
		If $b_trace Then __smtptrace($s_send)
		If $s_intreply <> "" Then
			If $s_first <> -1 Then
				If TCPSend($v_socket, $s_first) = 0 Then
					TCPCloseSocket($v_socket)
					TCPShutdown()
					Return 1
				EndIf
			EndIf
			$s_receive = ""
			$timer = TimerInit()
			While StringLeft($s_receive, StringLen($s_intreply)) <> $s_intreply AND TimerDiff($timer) < 45000
				$s_receive = TCPRecv($v_socket, 1000)
				If $b_trace AND $s_receive <> "" Then __smtptrace("intermediate->" & $s_receive)
			WEnd
		EndIf
		If TCPSend($v_socket, $s_send) = 0 Then
			TCPCloseSocket($v_socket)
			TCPShutdown()
			Return 1
		EndIf
		$timer = TimerInit()
		$s_receive = ""
		While $s_receive = "" AND TimerDiff($timer) < 45000
			$i += 1
			$s_receive = TCPRecv($v_socket, 1000)
			If $s_replycode = "" Then ExitLoop
		WEnd
		If $s_replycode <> "" Then
			If $b_trace Then __smtptrace($i & " <- " & $s_receive)
			If StringLeft($s_receive, StringLen($s_replycode)) <> $s_replycode Then
				TCPCloseSocket($v_socket)
				TCPShutdown()
				If $b_trace Then __smtptrace("<-> " & $s_replycode, 5)
				Return 2
			EndIf
		EndIf
		Return 0
	EndFunc

	Func _tcpiptoname($sip, $ioption = Default, $hdll_ws2_32 = Default)
		Local $inaddr_none = -1, $af_inet = 2, $sseparator = @CR
		If $ioption = Default Then $ioption = 0
		If $hdll_ws2_32 = Default Then $hdll_ws2_32 = "ws2_32.dll"
		Local $vadllcall = DllCall($hdll_ws2_32, "ulong", "inet_addr", "STR", $sip)
		If @error Then Return SetError(1, 0, "")
		Local $vbinip = $vadllcall[0]
		If $vbinip = $inaddr_none Then Return SetError(2, 0, "")
		$vadllcall = DllCall($hdll_ws2_32, "ptr", "gethostbyaddr", "ptr*", $vbinip, "int", 4, "int", $af_inet)
		If @error Then Return SetError(3, 0, "")
		Local $vptrhostent = $vadllcall[0]
		If $vptrhostent = 0 Then
			$vadllcall = DllCall($hdll_ws2_32, "int", "WSAGetLastError")
			If @error Then Return SetError(5, 0, "")
			Return SetError(4, $vadllcall[0], "")
		EndIf
		Local $vhostent = DllStructCreate("ptr;ptr;short;short;ptr", $vptrhostent)
		Local $shostnames = __tcpiptoname_szstringread(DllStructGetData($vhostent, 1))
		If @error Then Return SetError(6, 0, $shostnames)
		If $ioption = 1 Then
			Local $vh_aliases
			$shostnames &= $sseparator
			For $i = 0 To 63
				$vh_aliases = DllStructCreate("ptr", DllStructGetData($vhostent, 2) + ($i * 4))
				If DllStructGetData($vh_aliases, 1) = 0 Then ExitLoop
				$shostnames &= __tcpiptoname_szstringread(DllStructGetData($vh_aliases, 1))
				If @error Then
					SetError(7)
					ExitLoop
				EndIf
			Next
			Return StringSplit(StringStripWS($shostnames, 2), @CR)
		Else
			Return $shostnames
		EndIf
	EndFunc

	Func __tcpiptoname_szstringread($iszptr, $ilen = -1)
		Local $astrlen, $vszstring
		If $iszptr < 1 Then Return ""
		If $ilen < 0 Then
			$astrlen = DllCall("msvcrt.dll", "ulong_ptr:cdecl", "strlen", "ptr", $iszptr)
			If @error Then Return SetError(1, 0, "")
			$ilen = $astrlen[0] + 1
		EndIf
		$vszstring = DllStructCreate("char[" & $ilen & "]", $iszptr)
		If @error Then Return SetError(2, 0, "")
		Return SetExtended($ilen, DllStructGetData($vszstring, 1))
	EndFunc

	Global Const $gui_event_close = -3
	Global Const $gui_event_minimize = -4
	Global Const $gui_event_restore = -5
	Global Const $gui_event_maximize = -6
	Global Const $gui_event_primarydown = -7
	Global Const $gui_event_primaryup = -8
	Global Const $gui_event_secondarydown = -9
	Global Const $gui_event_secondaryup = -10
	Global Const $gui_event_mousemove = -11
	Global Const $gui_event_resized = -12
	Global Const $gui_event_dropped = -13
	Global Const $gui_rundefmsg = "GUI_RUNDEFMSG"
	Global Const $gui_avistop = 0
	Global Const $gui_avistart = 1
	Global Const $gui_aviclose = 2
	Global Const $gui_checked = 1
	Global Const $gui_indeterminate = 2
	Global Const $gui_unchecked = 4
	Global Const $gui_dropaccepted = 8
	Global Const $gui_nodropaccepted = 4096
	Global Const $gui_acceptfiles = $gui_dropaccepted
	Global Const $gui_show = 16
	Global Const $gui_hide = 32
	Global Const $gui_enable = 64
	Global Const $gui_disable = 128
	Global Const $gui_focus = 256
	Global Const $gui_nofocus = 8192
	Global Const $gui_defbutton = 512
	Global Const $gui_expand = 1024
	Global Const $gui_ontop = 2048
	Global Const $gui_fontitalic = 2
	Global Const $gui_fontunder = 4
	Global Const $gui_fontstrike = 8
	Global Const $gui_dockauto = 1
	Global Const $gui_dockleft = 2
	Global Const $gui_dockright = 4
	Global Const $gui_dockhcenter = 8
	Global Const $gui_docktop = 32
	Global Const $gui_dockbottom = 64
	Global Const $gui_dockvcenter = 128
	Global Const $gui_dockwidth = 256
	Global Const $gui_dockheight = 512
	Global Const $gui_docksize = 768
	Global Const $gui_dockmenubar = 544
	Global Const $gui_dockstatebar = 576
	Global Const $gui_dockall = 802
	Global Const $gui_dockborders = 102
	Global Const $gui_gr_close = 1
	Global Const $gui_gr_line = 2
	Global Const $gui_gr_bezier = 4
	Global Const $gui_gr_move = 6
	Global Const $gui_gr_color = 8
	Global Const $gui_gr_rect = 10
	Global Const $gui_gr_ellipse = 12
	Global Const $gui_gr_pie = 14
	Global Const $gui_gr_dot = 16
	Global Const $gui_gr_pixel = 18
	Global Const $gui_gr_hint = 20
	Global Const $gui_gr_refresh = 22
	Global Const $gui_gr_pensize = 24
	Global Const $gui_gr_nobkcolor = -2
	Global Const $gui_bkcolor_default = -1
	Global Const $gui_bkcolor_transparent = -2
	Global Const $gui_bkcolor_lv_alternate = -33554432
	Global Const $gui_ws_ex_parentdrag = 1048576
	Global Const $ss_left = 0
	Global Const $ss_center = 1
	Global Const $ss_right = 2
	Global Const $ss_icon = 3
	Global Const $ss_blackrect = 4
	Global Const $ss_grayrect = 5
	Global Const $ss_whiterect = 6
	Global Const $ss_blackframe = 7
	Global Const $ss_grayframe = 8
	Global Const $ss_whiteframe = 9
	Global Const $ss_simple = 11
	Global Const $ss_leftnowordwrap = 12
	Global Const $ss_bitmap = 14
	Global Const $ss_etchedhorz = 16
	Global Const $ss_etchedvert = 17
	Global Const $ss_etchedframe = 18
	Global Const $ss_noprefix = 128
	Global Const $ss_notify = 256
	Global Const $ss_centerimage = 512
	Global Const $ss_rightjust = 1024
	Global Const $ss_sunken = 4096
	Global Const $gui_ss_default_label = 0
	Global Const $gui_ss_default_graphic = 0
	Global Const $gui_ss_default_icon = $ss_notify
	Global Const $gui_ss_default_pic = $ss_notify
	Global Const $ws_tiled = 0
	Global Const $ws_overlapped = 0
	Global Const $ws_maximizebox = 65536
	Global Const $ws_minimizebox = 131072
	Global Const $ws_tabstop = 65536
	Global Const $ws_group = 131072
	Global Const $ws_sizebox = 262144
	Global Const $ws_thickframe = 262144
	Global Const $ws_sysmenu = 524288
	Global Const $ws_hscroll = 1048576
	Global Const $ws_vscroll = 2097152
	Global Const $ws_dlgframe = 4194304
	Global Const $ws_border = 8388608
	Global Const $ws_caption = 12582912
	Global Const $ws_overlappedwindow = 13565952
	Global Const $ws_tiledwindow = 13565952
	Global Const $ws_maximize = 16777216
	Global Const $ws_clipchildren = 33554432
	Global Const $ws_clipsiblings = 67108864
	Global Const $ws_disabled = 134217728
	Global Const $ws_visible = 268435456
	Global Const $ws_minimize = 536870912
	Global Const $ws_child = 1073741824
	Global Const $ws_popup = -2147483648
	Global Const $ws_popupwindow = -2138570752
	Global Const $ds_modalframe = 128
	Global Const $ds_setforeground = 512
	Global Const $ds_contexthelp = 8192
	Global Const $ws_ex_acceptfiles = 16
	Global Const $ws_ex_mdichild = 64
	Global Const $ws_ex_appwindow = 262144
	Global Const $ws_ex_composited = 33554432
	Global Const $ws_ex_clientedge = 512
	Global Const $ws_ex_contexthelp = 1024
	Global Const $ws_ex_dlgmodalframe = 1
	Global Const $ws_ex_leftscrollbar = 16384
	Global Const $ws_ex_overlappedwindow = 768
	Global Const $ws_ex_right = 4096
	Global Const $ws_ex_staticedge = 131072
	Global Const $ws_ex_toolwindow = 128
	Global Const $ws_ex_topmost = 8
	Global Const $ws_ex_transparent = 32
	Global Const $ws_ex_windowedge = 256
	Global Const $ws_ex_layered = 524288
	Global Const $ws_ex_controlparent = 65536
	Global Const $ws_ex_layoutrtl = 4194304
	Global Const $ws_ex_rtlreading = 8192
	Global Const $wm_gettextlength = 14
	Global Const $wm_gettext = 13
	Global Const $wm_size = 5
	Global Const $wm_sizing = 532
	Global Const $wm_user = 1024
	Global Const $wm_create = 1
	Global Const $wm_destroy = 2
	Global Const $wm_move = 3
	Global Const $wm_activate = 6
	Global Const $wm_setfocus = 7
	Global Const $wm_killfocus = 8
	Global Const $wm_enable = 10
	Global Const $wm_setredraw = 11
	Global Const $wm_settext = 12
	Global Const $wm_paint = 15
	Global Const $wm_close = 16
	Global Const $wm_quit = 18
	Global Const $wm_erasebkgnd = 20
	Global Const $wm_syscolorchange = 21
	Global Const $wm_showwindow = 24
	Global Const $wm_wininichange = 26
	Global Const $wm_devmodechange = 27
	Global Const $wm_activateapp = 28
	Global Const $wm_fontchange = 29
	Global Const $wm_timechange = 30
	Global Const $wm_cancelmode = 31
	Global Const $wm_setcursor = 32
	Global Const $wm_mouseactivate = 33
	Global Const $wm_childactivate = 34
	Global Const $wm_queuesync = 35
	Global Const $wm_getminmaxinfo = 36
	Global Const $wm_painticon = 38
	Global Const $wm_iconerasebkgnd = 39
	Global Const $wm_nextdlgctl = 40
	Global Const $wm_spoolerstatus = 42
	Global Const $wm_drawitem = 43
	Global Const $wm_measureitem = 44
	Global Const $wm_deleteitem = 45
	Global Const $wm_vkeytoitem = 46
	Global Const $wm_chartoitem = 47
	Global Const $wm_setfont = 48
	Global Const $wm_getfont = 49
	Global Const $wm_sethotkey = 50
	Global Const $wm_gethotkey = 51
	Global Const $wm_querydragicon = 55
	Global Const $wm_compareitem = 57
	Global Const $wm_getobject = 61
	Global Const $wm_compacting = 65
	Global Const $wm_commnotify = 68
	Global Const $wm_windowposchanging = 70
	Global Const $wm_windowposchanged = 71
	Global Const $wm_power = 72
	Global Const $wm_notify = 78
	Global Const $wm_copydata = 74
	Global Const $wm_canceljournal = 75
	Global Const $wm_inputlangchangerequest = 80
	Global Const $wm_inputlangchange = 81
	Global Const $wm_tcard = 82
	Global Const $wm_help = 83
	Global Const $wm_userchanged = 84
	Global Const $wm_notifyformat = 85
	Global Const $wm_cut = 768
	Global Const $wm_copy = 769
	Global Const $wm_paste = 770
	Global Const $wm_clear = 771
	Global Const $wm_undo = 772
	Global Const $wm_contextmenu = 123
	Global Const $wm_stylechanging = 124
	Global Const $wm_stylechanged = 125
	Global Const $wm_displaychange = 126
	Global Const $wm_geticon = 127
	Global Const $wm_seticon = 128
	Global Const $wm_nccreate = 129
	Global Const $wm_ncdestroy = 130
	Global Const $wm_nccalcsize = 131
	Global Const $wm_nchittest = 132
	Global Const $wm_ncpaint = 133
	Global Const $wm_ncactivate = 134
	Global Const $wm_getdlgcode = 135
	Global Const $wm_syncpaint = 136
	Global Const $wm_ncmousemove = 160
	Global Const $wm_nclbuttondown = 161
	Global Const $wm_nclbuttonup = 162
	Global Const $wm_nclbuttondblclk = 163
	Global Const $wm_ncrbuttondown = 164
	Global Const $wm_ncrbuttonup = 165
	Global Const $wm_ncrbuttondblclk = 166
	Global Const $wm_ncmbuttondown = 167
	Global Const $wm_ncmbuttonup = 168
	Global Const $wm_ncmbuttondblclk = 169
	Global Const $wm_keydown = 256
	Global Const $wm_keyup = 257
	Global Const $wm_char = 258
	Global Const $wm_deadchar = 259
	Global Const $wm_syskeydown = 260
	Global Const $wm_syskeyup = 261
	Global Const $wm_syschar = 262
	Global Const $wm_sysdeadchar = 263
	Global Const $wm_initdialog = 272
	Global Const $wm_command = 273
	Global Const $wm_syscommand = 274
	Global Const $wm_timer = 275
	Global Const $wm_hscroll = 276
	Global Const $wm_vscroll = 277
	Global Const $wm_initmenu = 278
	Global Const $wm_initmenupopup = 279
	Global Const $wm_menuselect = 287
	Global Const $wm_menuchar = 288
	Global Const $wm_enteridle = 289
	Global Const $wm_menurbuttonup = 290
	Global Const $wm_menudrag = 291
	Global Const $wm_menugetobject = 292
	Global Const $wm_uninitmenupopup = 293
	Global Const $wm_menucommand = 294
	Global Const $wm_changeuistate = 295
	Global Const $wm_updateuistate = 296
	Global Const $wm_queryuistate = 297
	Global Const $wm_ctlcolormsgbox = 306
	Global Const $wm_ctlcoloredit = 307
	Global Const $wm_ctlcolorlistbox = 308
	Global Const $wm_ctlcolorbtn = 309
	Global Const $wm_ctlcolordlg = 310
	Global Const $wm_ctlcolorscrollbar = 311
	Global Const $wm_ctlcolorstatic = 312
	Global Const $wm_ctlcolor = 25
	Global Const $mn_gethmenu = 481
	Global Const $nm_first = 0
	Global Const $nm_outofmemory = $nm_first - 1
	Global Const $nm_click = $nm_first - 2
	Global Const $nm_dblclk = $nm_first - 3
	Global Const $nm_return = $nm_first - 4
	Global Const $nm_rclick = $nm_first - 5
	Global Const $nm_rdblclk = $nm_first - 6
	Global Const $nm_setfocus = $nm_first - 7
	Global Const $nm_killfocus = $nm_first - 8
	Global Const $nm_customdraw = $nm_first - 12
	Global Const $nm_hover = $nm_first - 13
	Global Const $nm_nchittest = $nm_first - 14
	Global Const $nm_keydown = $nm_first - 15
	Global Const $nm_releasedcapture = $nm_first - 16
	Global Const $nm_setcursor = $nm_first - 17
	Global Const $nm_char = $nm_first - 18
	Global Const $nm_tooltipscreated = $nm_first - 19
	Global Const $nm_ldown = $nm_first - 20
	Global Const $nm_rdown = $nm_first - 21
	Global Const $nm_themechanged = $nm_first - 22
	Global Const $wm_mousemove = 512
	Global Const $wm_lbuttondown = 513
	Global Const $wm_lbuttonup = 514
	Global Const $wm_lbuttondblclk = 515
	Global Const $wm_rbuttondown = 516
	Global Const $wm_rbuttonup = 517
	Global Const $wm_rbuttondblck = 518
	Global Const $wm_mbuttondown = 519
	Global Const $wm_mbuttonup = 520
	Global Const $wm_mbuttondblck = 521
	Global Const $wm_mousewheel = 522
	Global Const $wm_xbuttondown = 523
	Global Const $wm_xbuttonup = 524
	Global Const $wm_xbuttondblclk = 525
	Global Const $wm_mousehwheel = 526
	Global Const $ps_solid = 0
	Global Const $ps_dash = 1
	Global Const $ps_dot = 2
	Global Const $ps_dashdot = 3
	Global Const $ps_dashdotdot = 4
	Global Const $ps_null = 5
	Global Const $ps_insideframe = 6
	Global Const $lwa_alpha = 2
	Global Const $lwa_colorkey = 1
	Global Const $rgn_and = 1
	Global Const $rgn_or = 2
	Global Const $rgn_xor = 3
	Global Const $rgn_diff = 4
	Global Const $rgn_copy = 5
	Global Const $errorregion = 0
	Global Const $nullregion = 1
	Global Const $simpleregion = 2
	Global Const $complexregion = 3
	Global Const $transparent = 1
	Global Const $opaque = 2
	Global Const $ccm_first = 8192
	Global Const $ccm_getunicodeformat = ($ccm_first + 6)
	Global Const $ccm_setunicodeformat = ($ccm_first + 5)
	Global Const $ccm_setbkcolor = $ccm_first + 1
	Global Const $ccm_setcolorscheme = $ccm_first + 2
	Global Const $ccm_getcolorscheme = $ccm_first + 3
	Global Const $ccm_getdroptarget = $ccm_first + 4
	Global Const $ccm_setwindowtheme = $ccm_first + 11
	Global Const $ga_parent = 1
	Global Const $ga_root = 2
	Global Const $ga_rootowner = 3
	Global Const $sm_cxscreen = 0
	Global Const $sm_cyscreen = 1
	Global Const $sm_cxvscroll = 2
	Global Const $sm_cyhscroll = 3
	Global Const $sm_cycaption = 4
	Global Const $sm_cxborder = 5
	Global Const $sm_cyborder = 6
	Global Const $sm_cxdlgframe = 7
	Global Const $sm_cydlgframe = 8
	Global Const $sm_cyvthumb = 9
	Global Const $sm_cxhthumb = 10
	Global Const $sm_cxicon = 11
	Global Const $sm_cyicon = 12
	Global Const $sm_cxcursor = 13
	Global Const $sm_cycursor = 14
	Global Const $sm_cymenu = 15
	Global Const $sm_cxfullscreen = 16
	Global Const $sm_cyfullscreen = 17
	Global Const $sm_cykanjiwindow = 18
	Global Const $sm_mousepresent = 19
	Global Const $sm_cyvscroll = 20
	Global Const $sm_cxhscroll = 21
	Global Const $sm_debug = 22
	Global Const $sm_swapbutton = 23
	Global Const $sm_reserved1 = 24
	Global Const $sm_reserved2 = 25
	Global Const $sm_reserved3 = 26
	Global Const $sm_reserved4 = 27
	Global Const $sm_cxmin = 28
	Global Const $sm_cymin = 29
	Global Const $sm_cxsize = 30
	Global Const $sm_cysize = 31
	Global Const $sm_cxframe = 32
	Global Const $sm_cyframe = 33
	Global Const $sm_cxmintrack = 34
	Global Const $sm_cymintrack = 35
	Global Const $sm_cxdoubleclk = 36
	Global Const $sm_cydoubleclk = 37
	Global Const $sm_cxiconspacing = 38
	Global Const $sm_cyiconspacing = 39
	Global Const $sm_menudropalignment = 40
	Global Const $sm_penwindows = 41
	Global Const $sm_dbcsenabled = 42
	Global Const $sm_cmousebuttons = 43
	Global Const $sm_secure = 44
	Global Const $sm_cxedge = 45
	Global Const $sm_cyedge = 46
	Global Const $sm_cxminspacing = 47
	Global Const $sm_cyminspacing = 48
	Global Const $sm_cxsmicon = 49
	Global Const $sm_cysmicon = 50
	Global Const $sm_cysmcaption = 51
	Global Const $sm_cxsmsize = 52
	Global Const $sm_cysmsize = 53
	Global Const $sm_cxmenusize = 54
	Global Const $sm_cymenusize = 55
	Global Const $sm_arrange = 56
	Global Const $sm_cxminimized = 57
	Global Const $sm_cyminimized = 58
	Global Const $sm_cxmaxtrack = 59
	Global Const $sm_cymaxtrack = 60
	Global Const $sm_cxmaximized = 61
	Global Const $sm_cymaximized = 62
	Global Const $sm_network = 63
	Global Const $sm_cleanboot = 67
	Global Const $sm_cxdrag = 68
	Global Const $sm_cydrag = 69
	Global Const $sm_showsounds = 70
	Global Const $sm_cxmenucheck = 71
	Global Const $sm_cymenucheck = 72
	Global Const $sm_slowmachine = 73
	Global Const $sm_mideastenabled = 74
	Global Const $sm_mousewheelpresent = 75
	Global Const $sm_xvirtualscreen = 76
	Global Const $sm_yvirtualscreen = 77
	Global Const $sm_cxvirtualscreen = 78
	Global Const $sm_cyvirtualscreen = 79
	Global Const $sm_cmonitors = 80
	Global Const $sm_samedisplayformat = 81
	Global Const $sm_immenabled = 82
	Global Const $sm_cxfocusborder = 83
	Global Const $sm_cyfocusborder = 84
	Global Const $sm_tabletpc = 86
	Global Const $sm_mediacenter = 87
	Global Const $sm_starter = 88
	Global Const $sm_serverr2 = 89
	Global Const $sm_cmetrics = 90
	Global Const $sm_remotesession = 4096
	Global Const $sm_shuttingdown = 8192
	Global Const $sm_remotecontrol = 8193
	Global Const $sm_caretblinkingenabled = 8194
	Global Const $blackness = 66
	Global Const $captureblt = 1073741824
	Global Const $dstinvert = 5570569
	Global Const $mergecopy = 12583114
	Global Const $mergepaint = 12255782
	Global Const $nomirrorbitmap = -2147483648
	Global Const $notsrccopy = 3342344
	Global Const $notsrcerase = 1114278
	Global Const $patcopy = 15728673
	Global Const $patinvert = 5898313
	Global Const $patpaint = 16452105
	Global Const $srcand = 8913094
	Global Const $srccopy = 13369376
	Global Const $srcerase = 4457256
	Global Const $srcinvert = 6684742
	Global Const $srcpaint = 15597702
	Global Const $whiteness = 16711778
	Global Const $dt_bottom = 8
	Global Const $dt_calcrect = 1024
	Global Const $dt_center = 1
	Global Const $dt_editcontrol = 8192
	Global Const $dt_end_ellipsis = 32768
	Global Const $dt_expandtabs = 64
	Global Const $dt_externalleading = 512
	Global Const $dt_hideprefix = 1048576
	Global Const $dt_internal = 4096
	Global Const $dt_left = 0
	Global Const $dt_modifystring = 65536
	Global Const $dt_noclip = 256
	Global Const $dt_nofullwidthcharbreak = 524288
	Global Const $dt_noprefix = 2048
	Global Const $dt_path_ellipsis = 16384
	Global Const $dt_prefixonly = 2097152
	Global Const $dt_right = 2
	Global Const $dt_rtlreading = 131072
	Global Const $dt_singleline = 32
	Global Const $dt_tabstop = 128
	Global Const $dt_top = 0
	Global Const $dt_vcenter = 4
	Global Const $dt_wordbreak = 16
	Global Const $dt_word_ellipsis = 262144
	Global Const $rdw_erase = 4
	Global Const $rdw_frame = 1024
	Global Const $rdw_internalpaint = 2
	Global Const $rdw_invalidate = 1
	Global Const $rdw_noerase = 32
	Global Const $rdw_noframe = 2048
	Global Const $rdw_nointernalpaint = 16
	Global Const $rdw_validate = 8
	Global Const $rdw_erasenow = 512
	Global Const $rdw_updatenow = 256
	Global Const $rdw_allchildren = 128
	Global Const $rdw_nochildren = 64
	Global Const $wm_renderformat = 773
	Global Const $wm_renderallformats = 774
	Global Const $wm_destroyclipboard = 775
	Global Const $wm_drawclipboard = 776
	Global Const $wm_paintclipboard = 777
	Global Const $wm_vscrollclipboard = 778
	Global Const $wm_sizeclipboard = 779
	Global Const $wm_askcbformatname = 780
	Global Const $wm_changecbchain = 781
	Global Const $wm_hscrollclipboard = 782
	Global Const $hterror = -2
	Global Const $httransparent = -1
	Global Const $htnowhere = 0
	Global Const $htclient = 1
	Global Const $htcaption = 2
	Global Const $htsysmenu = 3
	Global Const $htgrowbox = 4
	Global Const $htsize = $htgrowbox
	Global Const $htmenu = 5
	Global Const $hthscroll = 6
	Global Const $htvscroll = 7
	Global Const $htminbutton = 8
	Global Const $htmaxbutton = 9
	Global Const $htleft = 10
	Global Const $htright = 11
	Global Const $httop = 12
	Global Const $httopleft = 13
	Global Const $httopright = 14
	Global Const $htbottom = 15
	Global Const $htbottomleft = 16
	Global Const $htbottomright = 17
	Global Const $htborder = 18
	Global Const $htreduce = $htminbutton
	Global Const $htzoom = $htmaxbutton
	Global Const $htsizefirst = $htleft
	Global Const $htsizelast = $htbottomright
	Global Const $htobject = 19
	Global Const $htclose = 20
	Global Const $hthelp = 21
	Global Const $color_scrollbar = 0
	Global Const $color_background = 1
	Global Const $color_activecaption = 2
	Global Const $color_inactivecaption = 3
	Global Const $color_menu = 4
	Global Const $color_window = 5
	Global Const $color_windowframe = 6
	Global Const $color_menutext = 7
	Global Const $color_windowtext = 8
	Global Const $color_captiontext = 9
	Global Const $color_activeborder = 10
	Global Const $color_inactiveborder = 11
	Global Const $color_appworkspace = 12
	Global Const $color_highlight = 13
	Global Const $color_highlighttext = 14
	Global Const $color_btnface = 15
	Global Const $color_btnshadow = 16
	Global Const $color_graytext = 17
	Global Const $color_btntext = 18
	Global Const $color_inactivecaptiontext = 19
	Global Const $color_btnhighlight = 20
	Global Const $color_3ddkshadow = 21
	Global Const $color_3dlight = 22
	Global Const $color_infotext = 23
	Global Const $color_infobk = 24
	Global Const $color_hotlight = 26
	Global Const $color_gradientactivecaption = 27
	Global Const $color_gradientinactivecaption = 28
	Global Const $color_menuhilight = 29
	Global Const $color_menubar = 30
	Global Const $color_desktop = 1
	Global Const $color_3dface = 15
	Global Const $color_3dshadow = 16
	Global Const $color_3dhighlight = 20
	Global Const $color_3dhilight = 20
	Global Const $color_btnhilight = 20
	Global Const $hinst_commctrl = -1
	Global Const $idb_std_small_color = 0
	Global Const $idb_std_large_color = 1
	Global Const $idb_view_small_color = 4
	Global Const $idb_view_large_color = 5
	Global Const $idb_hist_small_color = 8
	Global Const $idb_hist_large_color = 9
	Global Const $startf_forceofffeedback = 128
	Global Const $startf_forceonfeedback = 64
	Global Const $startf_runfullscreen = 32
	Global Const $startf_usecountchars = 8
	Global Const $startf_usefillattribute = 16
	Global Const $startf_usehotkey = 512
	Global Const $startf_useposition = 4
	Global Const $startf_useshowwindow = 1
	Global Const $startf_usesize = 2
	Global Const $startf_usestdhandles = 256
	Global Const $cdds_prepaint = 1
	Global Const $cdds_postpaint = 2
	Global Const $cdds_preerase = 3
	Global Const $cdds_posterase = 4
	Global Const $cdds_item = 65536
	Global Const $cdds_itemprepaint = 65537
	Global Const $cdds_itempostpaint = 65538
	Global Const $cdds_itempreerase = 65539
	Global Const $cdds_itemposterase = 65540
	Global Const $cdds_subitem = 131072
	Global Const $cdis_selected = 1
	Global Const $cdis_grayed = 2
	Global Const $cdis_disabled = 4
	Global Const $cdis_checked = 8
	Global Const $cdis_focus = 16
	Global Const $cdis_default = 32
	Global Const $cdis_hot = 64
	Global Const $cdis_marked = 128
	Global Const $cdis_indeterminate = 256
	Global Const $cdis_showkeyboardcues = 512
	Global Const $cdis_nearhot = 1024
	Global Const $cdis_othersidehot = 2048
	Global Const $cdis_drophilited = 4096
	Global Const $cdrf_dodefault = 0
	Global Const $cdrf_newfont = 2
	Global Const $cdrf_skipdefault = 4
	Global Const $cdrf_notifypostpaint = 16
	Global Const $cdrf_notifyitemdraw = 32
	Global Const $cdrf_notifysubitemdraw = 32
	Global Const $cdrf_notifyposterase = 64
	Global Const $cdrf_doerase = 8
	Global Const $cdrf_skippostpaint = 256
	Global Const $gui_ss_default_gui = BitOR($ws_minimizebox, $ws_caption, $ws_popup, $ws_sysmenu)
	Global Const $bs_groupbox = 7
	Global Const $bs_bottom = 2048
	Global Const $bs_center = 768
	Global Const $bs_defpushbutton = 1
	Global Const $bs_left = 256
	Global Const $bs_multiline = 8192
	Global Const $bs_pushbox = 10
	Global Const $bs_pushlike = 4096
	Global Const $bs_right = 512
	Global Const $bs_rightbutton = 32
	Global Const $bs_top = 1024
	Global Const $bs_vcenter = 3072
	Global Const $bs_flat = 32768
	Global Const $bs_icon = 64
	Global Const $bs_bitmap = 128
	Global Const $bs_notify = 16384
	Global Const $bs_splitbutton = 12
	Global Const $bs_defsplitbutton = 13
	Global Const $bs_commandlink = 14
	Global Const $bs_defcommandlink = 15
	Global Const $bcsif_glyph = 1
	Global Const $bcsif_image = 2
	Global Const $bcsif_style = 4
	Global Const $bcsif_size = 8
	Global Const $bcss_nosplit = 1
	Global Const $bcss_stretch = 2
	Global Const $bcss_alignleft = 4
	Global Const $bcss_image = 8
	Global Const $button_imagelist_align_left = 0
	Global Const $button_imagelist_align_right = 1
	Global Const $button_imagelist_align_top = 2
	Global Const $button_imagelist_align_bottom = 3
	Global Const $button_imagelist_align_center = 4
	Global Const $bs_3state = 5
	Global Const $bs_auto3state = 6
	Global Const $bs_autocheckbox = 3
	Global Const $bs_checkbox = 2
	Global Const $bs_radiobutton = 4
	Global Const $bs_autoradiobutton = 9
	Global Const $bs_ownerdraw = 11
	Global Const $gui_ss_default_button = 0
	Global Const $gui_ss_default_checkbox = 0
	Global Const $gui_ss_default_group = 0
	Global Const $gui_ss_default_radio = 0
	Global Const $bcm_first = 5632
	Global Const $bcm_getidealsize = ($bcm_first + 1)
	Global Const $bcm_getimagelist = ($bcm_first + 3)
	Global Const $bcm_getnote = ($bcm_first + 10)
	Global Const $bcm_getnotelength = ($bcm_first + 11)
	Global Const $bcm_getsplitinfo = ($bcm_first + 8)
	Global Const $bcm_gettextmargin = ($bcm_first + 5)
	Global Const $bcm_setdropdownstate = ($bcm_first + 6)
	Global Const $bcm_setimagelist = ($bcm_first + 2)
	Global Const $bcm_setnote = ($bcm_first + 9)
	Global Const $bcm_setshield = ($bcm_first + 12)
	Global Const $bcm_setsplitinfo = ($bcm_first + 7)
	Global Const $bcm_settextmargin = ($bcm_first + 4)
	Global Const $bm_click = 245
	Global Const $bm_getcheck = 240
	Global Const $bm_getimage = 246
	Global Const $bm_getstate = 242
	Global Const $bm_setcheck = 241
	Global Const $bm_setdontclick = 248
	Global Const $bm_setimage = 247
	Global Const $bm_setstate = 243
	Global Const $bm_setstyle = 244
	Global Const $bcn_first = -1250
	Global Const $bcn_dropdown = ($bcn_first + 2)
	Global Const $bcn_hotitemchange = ($bcn_first + 1)
	Global Const $bn_clicked = 0
	Global Const $bn_paint = 1
	Global Const $bn_hilite = 2
	Global Const $bn_unhilite = 3
	Global Const $bn_disable = 4
	Global Const $bn_doubleclicked = 5
	Global Const $bn_setfocus = 6
	Global Const $bn_killfocus = 7
	Global Const $bn_pushed = $bn_hilite
	Global Const $bn_unpushed = $bn_unhilite
	Global Const $bn_dblclk = $bn_doubleclicked
	Global Const $bst_checked = 1
	Global Const $bst_indeterminate = 2
	Global Const $bst_unchecked = 0
	Global Const $bst_focus = 8
	Global Const $bst_pushed = 4
	Global Const $bst_dontclick = 128
	Global Const $lbs_notify = 1
	Global Const $lbs_sort = 2
	Global Const $lbs_noredraw = 4
	Global Const $lbs_multiplesel = 8
	Global Const $lbs_ownerdrawfixed = 16
	Global Const $lbs_ownerdrawvariable = 32
	Global Const $lbs_hasstrings = 64
	Global Const $lbs_usetabstops = 128
	Global Const $lbs_nointegralheight = 256
	Global Const $lbs_multicolumn = 512
	Global Const $lbs_wantkeyboardinput = 1024
	Global Const $lbs_extendedsel = 2048
	Global Const $lbs_disablenoscroll = 4096
	Global Const $lbs_nodata = 8192
	Global Const $lbs_nosel = 16384
	Global Const $lbs_combobox = 32768
	Global Const $lbs_standard = 3
	Global Const $lb_err = -1
	Global Const $lb_errattribute = -3
	Global Const $lb_errrequired = -4
	Global Const $lb_errspace = -2
	Global Const $lb_addstring = 384
	Global Const $lb_insertstring = 385
	Global Const $lb_deletestring = 386
	Global Const $lb_selitemrangeex = 387
	Global Const $lb_resetcontent = 388
	Global Const $lb_setsel = 389
	Global Const $lb_setcursel = 390
	Global Const $lb_getsel = 391
	Global Const $lb_getcursel = 392
	Global Const $lb_gettext = 393
	Global Const $lb_gettextlen = 394
	Global Const $lb_getcount = 395
	Global Const $lb_selectstring = 396
	Global Const $lb_dir = 397
	Global Const $lb_gettopindex = 398
	Global Const $lb_findstring = 399
	Global Const $lb_getselcount = 400
	Global Const $lb_getselitems = 401
	Global Const $lb_settabstops = 402
	Global Const $lb_gethorizontalextent = 403
	Global Const $lb_sethorizontalextent = 404
	Global Const $lb_setcolumnwidth = 405
	Global Const $lb_addfile = 406
	Global Const $lb_settopindex = 407
	Global Const $lb_getitemrect = 408
	Global Const $lb_getitemdata = 409
	Global Const $lb_setitemdata = 410
	Global Const $lb_selitemrange = 411
	Global Const $lb_setanchorindex = 412
	Global Const $lb_getanchorindex = 413
	Global Const $lb_setcaretindex = 414
	Global Const $lb_getcaretindex = 415
	Global Const $lb_setitemheight = 416
	Global Const $lb_getitemheight = 417
	Global Const $lb_findstringexact = 418
	Global Const $lb_setlocale = 421
	Global Const $lb_getlocale = 422
	Global Const $lb_setcount = 423
	Global Const $lb_initstorage = 424
	Global Const $lb_itemfrompoint = 425
	Global Const $lb_multipleaddstring = 433
	Global Const $lb_getlistboxinfo = 434
	Global Const $lbn_errspace = -2
	Global Const $lbn_selchange = 1
	Global Const $lbn_dblclk = 2
	Global Const $lbn_selcancel = 3
	Global Const $lbn_setfocus = 4
	Global Const $lbn_killfocus = 5
	Global Const $__listboxconstant_ws_border = 8388608
	Global Const $__listboxconstant_ws_vscroll = 2097152
	Global Const $gui_ss_default_list = BitOR($lbs_sort, $__listboxconstant_ws_border, $__listboxconstant_ws_vscroll, $lbs_notify)
	Global Const $cb_err = -1
	Global Const $cb_errattribute = -3
	Global Const $cb_errrequired = -4
	Global Const $cb_errspace = -2
	Global Const $cb_okay = 0
	Global Const $state_system_invisible = 32768
	Global Const $state_system_pressed = 8
	Global Const $cbs_autohscroll = 64
	Global Const $cbs_disablenoscroll = 2048
	Global Const $cbs_dropdown = 2
	Global Const $cbs_dropdownlist = 3										
	Global Const $cbs_hasstrings = 512
	Global Const $cbs_lowercase = 16384
	Global Const $cbs_nointegralheight = 1024
	Global Const $cbs_oemconvert = 128
	Global Const $cbs_ownerdrawfixed = 16
	Global Const $cbs_ownerdrawvariable = 32
	Global Const $cbs_simple = 1
	Global Const $cbs_sort = 256
	Global Const $cbs_uppercase = 8192
	Global Const $cbm_first = 5888
	Global Const $cb_addstring = 323
	Global Const $cb_deletestring = 324
	Global Const $cb_dir = 325
	Global Const $cb_findstring = 332
	Global Const $cb_findstringexact = 344
	Global Const $cb_getcomboboxinfo = 356
	Global Const $cb_getcount = 326
	Global Const $cb_getcuebanner = ($cbm_first + 4)
	Global Const $cb_getcursel = 327
	Global Const $cb_getdroppedcontrolrect = 338
	Global Const $cb_getdroppedstate = 343
	Global Const $cb_getdroppedwidth = 351
	Global Const $cb_geteditsel = 320
	Global Const $cb_getextendedui = 342
	Global Const $cb_gethorizontalextent = 349
	Global Const $cb_getitemdata = 336
	Global Const $cb_getitemheight = 340
	Global Const $cb_getlbtext = 328
	Global Const $cb_getlbtextlen = 329
	Global Const $cb_getlocale = 346
	Global Const $cb_getminvisible = 5890
	Global Const $cb_gettopindex = 347
	Global Const $cb_initstorage = 353
	Global Const $cb_limittext = 321
	Global Const $cb_resetcontent = 331
	Global Const $cb_insertstring = 330
	Global Const $cb_selectstring = 333
	Global Const $cb_setcuebanner = ($cbm_first + 3)
	Global Const $cb_setcursel = 334
	Global Const $cb_setdroppedwidth = 352
	Global Const $cb_seteditsel = 322
	Global Const $cb_setextendedui = 341
	Global Const $cb_sethorizontalextent = 350
	Global Const $cb_setitemdata = 337
	Global Const $cb_setitemheight = 339
	Global Const $cb_setlocale = 345
	Global Const $cb_setminvisible = 5889
	Global Const $cb_settopindex = 348
	Global Const $cb_showdropdown = 335
	Global Const $cbn_closeup = 8
	Global Const $cbn_dblclk = 2
	Global Const $cbn_dropdown = 7
	Global Const $cbn_editchange = 5
	Global Const $cbn_editupdate = 6
	Global Const $cbn_errspace = (-1)
	Global Const $cbn_killfocus = 4
	Global Const $cbn_selchange = 1
	Global Const $cbn_selendcancel = 10
	Global Const $cbn_selendok = 9
	Global Const $cbn_setfocus = 3
	Global Const $cbes_ex_casesensitive = 16
	Global Const $cbes_ex_noeditimage = 1
	Global Const $cbes_ex_noeditimageindent = 2
	Global Const $cbes_ex_nosizelimit = 8
	Global Const $cbes_ex_pathwordbreakproc = 4
	Global Const $__comboboxconstant_wm_user = 1024
	Global Const $cbem_deleteitem = $cb_deletestring
	Global Const $cbem_getcombocontrol = ($__comboboxconstant_wm_user + 6)
	Global Const $cbem_geteditcontrol = ($__comboboxconstant_wm_user + 7)
	Global Const $cbem_getexstyle = ($__comboboxconstant_wm_user + 9)
	Global Const $cbem_getextendedstyle = ($__comboboxconstant_wm_user + 9)
	Global Const $cbem_getimagelist = ($__comboboxconstant_wm_user + 3)
	Global Const $cbem_getitema = ($__comboboxconstant_wm_user + 4)
	Global Const $cbem_getitemw = ($__comboboxconstant_wm_user + 13)
	Global Const $cbem_getunicodeformat = 8192 + 6
	Global Const $cbem_haseditchanged = ($__comboboxconstant_wm_user + 10)
	Global Const $cbem_insertitema = ($__comboboxconstant_wm_user + 1)
	Global Const $cbem_insertitemw = ($__comboboxconstant_wm_user + 11)
	Global Const $cbem_setexstyle = ($__comboboxconstant_wm_user + 8)
	Global Const $cbem_setextendedstyle = ($__comboboxconstant_wm_user + 14)
	Global Const $cbem_setimagelist = ($__comboboxconstant_wm_user + 2)
	Global Const $cbem_setitema = ($__comboboxconstant_wm_user + 5)
	Global Const $cbem_setitemw = ($__comboboxconstant_wm_user + 12)
	Global Const $cbem_setunicodeformat = 8192 + 5
	Global Const $cbem_setwindowtheme = 8192 + 11
	Global Const $cben_first = (-800)
	Global Const $cben_last = (-830)
	Global Const $cben_beginedit = ($cben_first - 4)
	Global Const $cben_deleteitem = ($cben_first - 2)
	Global Const $cben_dragbegina = ($cben_first - 8)
	Global Const $cben_dragbeginw = ($cben_first - 9)
	Global Const $cben_endedita = ($cben_first - 5)
	Global Const $cben_endeditw = ($cben_first - 6)
	Global Const $cben_getdispinfo = ($cben_first - 0)
	Global Const $cben_getdispinfoa = ($cben_first - 0)
	Global Const $cben_getdispinfow = ($cben_first - 7)
	Global Const $cben_insertitem = ($cben_first - 1)
	Global Const $cbeif_di_setitem = 268435456
	Global Const $cbeif_image = 2
	Global Const $cbeif_indent = 16
	Global Const $cbeif_lparam = 32
	Global Const $cbeif_overlay = 8
	Global Const $cbeif_selectedimage = 4
	Global Const $cbeif_text = 1
	Global Const $__comboboxconstant_ws_vscroll = 2097152
	Global Const $gui_ss_default_combo = BitOR($cbs_dropdown, $cbs_autohscroll, $__comboboxconstant_ws_vscroll)
	Global Const $es_left = 0
	Global Const $es_center = 1
	Global Const $es_right = 2
	Global Const $es_multiline = 4
	Global Const $es_uppercase = 8
	Global Const $es_lowercase = 16
	Global Const $es_password = 32
	Global Const $es_autovscroll = 64
	Global Const $es_autohscroll = 128
	Global Const $es_nohidesel = 256
	Global Const $es_oemconvert = 1024
	Global Const $es_readonly = 2048
	Global Const $es_wantreturn = 4096
	Global Const $es_number = 8192
	Global Const $ec_err = -1
	Global Const $ecm_first = 5376
	Global Const $em_canundo = 198
	Global Const $em_charfrompos = 215
	Global Const $em_emptyundobuffer = 205
	Global Const $em_fmtlines = 200
	Global Const $em_getcuebanner = ($ecm_first + 2)
	Global Const $em_getfirstvisibleline = 206
	Global Const $em_gethandle = 189
	Global Const $em_getimestatus = 217
	Global Const $em_getlimittext = 213
	Global Const $em_getline = 196
	Global Const $em_getlinecount = 186
	Global Const $em_getmargins = 212
	Global Const $em_getmodify = 184
	Global Const $em_getpasswordchar = 210
	Global Const $em_getrect = 178
	Global Const $em_getsel = 176
	Global Const $em_getthumb = 190
	Global Const $em_getwordbreakproc = 209
	Global Const $em_hideballoontip = ($ecm_first + 4)
	Global Const $em_limittext = 197
	Global Const $em_linefromchar = 201
	Global Const $em_lineindex = 187
	Global Const $em_linelength = 193
	Global Const $em_linescroll = 182
	Global Const $em_posfromchar = 214
	Global Const $em_replacesel = 194
	Global Const $em_scroll = 181
	Global Const $em_scrollcaret = 183
	Global Const $em_setcuebanner = ($ecm_first + 1)
	Global Const $em_sethandle = 188
	Global Const $em_setimestatus = 216
	Global Const $em_setlimittext = $em_limittext
	Global Const $em_setmargins = 211
	Global Const $em_setmodify = 185
	Global Const $em_setpasswordchar = 204
	Global Const $em_setreadonly = 207
	Global Const $em_setrect = 179
	Global Const $em_setrectnp = 180
	Global Const $em_setsel = 177
	Global Const $em_settabstops = 203
	Global Const $em_setwordbreakproc = 208
	Global Const $em_showballoontip = ($ecm_first + 3)
	Global Const $em_undo = 199
	Global Const $ec_leftmargin = 1
	Global Const $ec_rightmargin = 2
	Global Const $ec_usefontinfo = 65535
	Global Const $emsis_compositionstring = 1
	Global Const $eimes_getcompstratonce = 1
	Global Const $eimes_cancelcompstrinfocus = 2
	Global Const $eimes_completecompstrkillfocus = 4
	Global Const $en_align_ltr_ec = 1792
	Global Const $en_align_rtl_ec = 1793
	Global Const $en_change = 768
	Global Const $en_errspace = 1280
	Global Const $en_hscroll = 1537
	Global Const $en_killfocus = 512
	Global Const $en_maxtext = 1281
	Global Const $en_setfocus = 256
	Global Const $en_update = 1024
	Global Const $en_vscroll = 1538
	Global Const $tti_none = 0
	Global Const $tti_info = 1
	Global Const $tti_warning = 2
	Global Const $tti_error = 3
	Global Const $tti_info_large = 4
	Global Const $tti_warning_large = 5
	Global Const $tti_error_large = 6
	Global Const $__editconstant_ws_vscroll = 2097152
	Global Const $__editconstant_ws_hscroll = 1048576
	Global Const $gui_ss_default_edit = BitOR($es_wantreturn, $__editconstant_ws_vscroll, $__editconstant_ws_hscroll, $es_autovscroll, $es_autohscroll)
	Global Const $gui_ss_default_input = BitOR($es_left, $es_autohscroll)
	Global Const $iniFilePath = @ScriptDir & "/7zTM.ini"
    Global $iFileExists = FileExists($iniFilePath)


	Func _processgetname($i_pid)
		If NOT ProcessExists($i_pid) Then Return SetError(1, 0, "")
		If NOT @error Then
			Local $a_processes = ProcessList()
			For $i = 1 To $a_processes[0][0]
				If $a_processes[$i][1] = $i_pid Then Return $a_processes[$i][0]
			Next
		EndIf
		Return SetError(1, 0, "")
	EndFunc

	Func _processgetpriority($vprocess)
		Local $ierror, $iextended, $ireturn = -1
		Local $i_pid = ProcessExists($vprocess)
		If NOT $i_pid Then Return SetError(1, 0, -1)
		Local $hdll = DllOpen("kernel32.dll")
		Do
			Local $aprocesshandle = DllCall($hdll, "handle", "OpenProcess", "dword", $process_query_information, "bool", False, "dword", $i_pid)
			If @error Then
				$ierror = @error
				$iextended = @extended
				ExitLoop
			EndIf
			If NOT $aprocesshandle[0] Then ExitLoop
			Local $apriority = DllCall($hdll, "dword", "GetPriorityClass", "handle", $aprocesshandle[0])
			If @error Then
				$ierror = @error
				$iextended = @extended
			EndIf
			DllCall($hdll, "bool", "CloseHandle", "handle", $aprocesshandle[0])
			If $ierror Then ExitLoop
			Switch $apriority[0]
				Case 64
					$ireturn = 0
				Case 16384
					$ireturn = 1
				Case 32
					$ireturn = 2
				Case 32768
					$ireturn = 3
				Case 128
					$ireturn = 4
				Case 256
					$ireturn = 5
				Case Else
					$ierror = 1
					$iextended = $apriority[0]
					$ireturn = -1
			EndSwitch
		Until True
		DllClose($hdll)
		Return SetError($ierror, $iextended, $ireturn)
	EndFunc

	Func _rundos($scommand)
		Local $nresult = RunWait(@ComSpec & " /C " & $scommand, "", @SW_HIDE)
		Return SetError(@error, @extended, $nresult)
	EndFunc

	Dim $lang[10][50]
	$lang[0][1] = "Ihre Windows Version wird nicht vom 7-Zip Theme Manager unterstützt. Die Nutzung kann zu unvorhersehbaren Fehlern führen!     "
	$lang[0][2] = "Ihr 7-Zip Verzeichnis konnte nicht gefunden werden, bitte wählen Sie es selbst aus.    "
	$lang[0][3] = "Bitte das 7-Zip Verzeichnis auswählen...    "
	$lang[0][4] = "Das folgende Verzeichnis wurde als 7-Zip Verzeichnis erkannt:    "
	$lang[0][5] = "Ist das richtig?    "
	$lang[0][6] = 'Die benötigte Datei "7z.dll" konnte in dem von Ihnen angegebenen Verzeichnis nicht gefunden werden.   ' & @LF & "Bitte stellen Sie sicher, dass die Datei existiert und das angegebene Verzeichnis korrekt ist.   " & @LF & @LF & "Das Programm wird nun beendet.   "
	$lang[0][7] = 'Die benötigte Datei "7zFM.exe" konnte in dem von Ihnen angegebenen Verzeichnis nicht gefunden werden.   ' & @LF & "Bitte stellen Sie sicher, dass die Datei existiert und das angegebene Verzeichnis korrekt ist.   " & @LF & @LF & "Das Programm wird nun beendet.   "
	$lang[0][8] = "Es wird mindestens 7-Zip 4.65 benötigt. Ihre Version ist leider älter, bitte aktualisieren Sie diese.    " & @LF & @LF & "Das Programm wird nun beendet.   "
	$lang[0][9] = 'Das Toolbar Theme "'
	$lang[0][10] = 'Das Filetype Theme "'
	$lang[0][11] = '" kann nicht geladen werden,    ' & @LF & 'da es unvollständig ist oder die Datei "theme.ini" fehlt.    '
	$lang[0][12] = "Keine Toolbar Themes gefunden.    "
	$lang[0][13] = "Keine Filetype Themes gefunden.    "
	$lang[0][14] = "Theme aktivieren"
	$lang[0][15] = "Programm / Themes Update"
	$lang[0][16] = "SFX Icon ändern"
	$lang[0][17] = "Beenden"
	$lang[0][18] = "Kein Vorschaubild vorhanden."
	$lang[0][19] = "Informationen"
	$lang[0][20] = "Name"
	$lang[0][21] = "Autor"
	$lang[0][22] = "Lizenz"
	$lang[0][23] = "Website"
	$lang[0][24] = "Eine neue Version ist verfügbar. Möchten Sie die Downloadseite besuchen?    "
	$lang[0][25] = "Keine neue Version gefunden.    "
	$lang[0][26] = 'Weder "7z.sfx" noch "7zCon.sfx" konnte gefunden werden.    ' & @LF & "Bitte besuchen Sie die 7-Zip Theme Manager Website und nehmen Sie Kontakt zum Autor auf.    "
	$lang[0][27] = "7-Zip scheint momentan geöffnet zu sein. Bitte schließen Sie 7-Zip.    "
	$lang[0][28] = "Patche Dateien ...    "
	$lang[0][29] = "Fertig ...    "
	$lang[0][30] = "Theme-Aktivierung erfolgreich.    "
	$lang[0][31] = "Theme-Aktivierung fehlgeschlagen.    "
	$lang[0][32] = "Start 7z"
	$lang[0][33] = "Status: "
	$lang[1][1] = "Your windows version isn´t supported by 7-Zip Theme Manager. The usage may cause unpredictable errors!    "
	$lang[1][2] = "Your 7-Zip directory couldn´t be found, please select it yourself.    "
	$lang[1][3] = "Please select your 7-Zip directory...    "
	$lang[1][4] = "The following directory was identified as your 7-Zip directory:    "
	$lang[1][5] = "Is that correct?    "
	$lang[1][6] = 'The required file "7z.dll" couldn´t be found in the specified directory.   ' & @LF & "Please make sure that the file exists and the specified directory is correct.   " & @LF & @LF & "The program will now quit.   "
	$lang[1][7] = 'The required file "7zFM.exe" couldn´t be found in the specified directory.   ' & @LF & "Please make sure that the file exists and the specified directory is correct.   " & @LF & @LF & "The program will now quit.   "
	$lang[1][8] = "At least 7-Zip 4.65 is required. Unfortunately your version is older. Please update it.    " & @LF & @LF & "The program will now quit.   "
	$lang[1][9] = 'The Toolbar Theme "'
	$lang[1][10] = 'The Filetype Theme "'
	$lang[1][11] = """ can't be loaded because    " & @LF & "it's incomplete or the file ""theme.ini"" is missing.    "
	$lang[1][12] = "No Toolbar Themes found.    "
	$lang[1][13] = "No Filetype Themes found.    "
	$lang[1][14] = "Activate theme"
	$lang[1][15] = "Update program / themes"
	$lang[1][16] = "Change SFX Icon"
	$lang[1][17] = "Close"
	$lang[1][18] = "No preview image available."
	$lang[1][19] = "Information"
	$lang[1][20] = "Name"
	$lang[1][21] = "Author"
	$lang[1][22] = "Licence"
	$lang[1][23] = "Website"
	$lang[1][24] = "A new version is available. Would you like to visit the download page?    "
	$lang[1][25] = "No new version found.     "
	$lang[1][26] = 'Neither "7z.sfx" nor "7zCon.sfx" could be found.    ' & @LF & "Please visit the 7-Zip Theme Manager website and contact the author.    "
	$lang[1][27] = "It seems that 7-Zip is running. Please close down 7-Zip.    "
	$lang[1][28] = "Patching files ...    "
	$lang[1][29] = "Done ...    "
	$lang[1][30] = "Theme activation done.    "
	$lang[1][31] = "Theme activation failed.    "
	$lang[1][32] = "Start 7z"
	$lang[1][33] = "Status: "
	$lang[2][1] = "La sua versione di Windows non è supportata dal 7-Zip Theme Manager.    " & @LF & "L'uso puo causare gravi errori!    "
	$lang[2][2] = "La cartella di 7-Zip non è stata trovata, si prega di selezionarla.    "
	$lang[2][3] = "Si prega di selezionare la cartella di 7-Zip...    "
	$lang[2][4] = "La seguente cartella è stata identificata come cartella di 7-Zip:    "
	$lang[2][5] = "È corretto?"
	$lang[2][6] = 'Il file "7z.dll" non esiste nella cartella specificata.   ' & @LF & "Assicuri che il file è presente e che la cartella specificata è corretta.   " & @LF & @LF & "Il programma ora si chiude.   "
	$lang[2][7] = 'Il file "7zFM.exe" non esiste nella cartella specificata.   ' & @LF & "Assicuri che il file è presente e che la cartella specificata è corretta.   " & @LF & @LF & "Il programma ora si chiude.   "
	$lang[2][8] = "Si richiede almeno 7-Zip 4.65. La sua versione non é attuale, si prega di aggiornarla.    " & @LF & @LF & "Il programma ora si chiude.   "
	$lang[2][9] = 'Il Toolbar Theme "'
	$lang[2][10] = 'Il Filetype Theme "'
	$lang[2][11] = '" non può essere caricato,    ' & @LF & 'perché è incompleto o manca il file "theme.ini".    '
	$lang[2][12] = "Nessun Toolbar Theme trovato.    "
	$lang[2][13] = "Nessun Filetype Theme trovato.    "
	$lang[2][14] = "Attiva il Theme"
	$lang[2][15] = "Aggiorna programma/Themes"
	$lang[2][16] = "Cambia icona SFX"
	$lang[2][17] = "Chiudi"
	$lang[2][18] = "Nessuna anteprima disponibile."
	$lang[2][19] = "Informazioni"
	$lang[2][20] = "Nome"
	$lang[2][21] = "Autore"
	$lang[2][22] = "Licenza"
	$lang[2][23] = "Sito web"
	$lang[2][24] = "Una versione aggiornata è disponibile. Vuole visitare il sito del download?    "
	$lang[2][25] = "Nessuna nuova versione trovata.    "
	$lang[2][26] = 'Né "7z.sfx" e né "7zCon.sfx" sono stati trovati.    ' & @LF & "Si prega di visitare il sito web di 7-Zip Theme Manager e di contattare l'autore.    "
	$lang[2][27] = "7-Zip sembra d'essere in uso. Si prega di chiudere 7-Zip.    "
	$lang[2][28] = "Modifica dei file ...    "
	$lang[2][29] = "Completato ...    "
	$lang[2][30] = "Il Theme è stato attivato.    "
	$lang[2][31] = "L'attivazione del Theme è fallito.    "
	$lang[2][32] = "Start 7z"
	$lang[2][33] = "Status: "
	$lang[3][1] = "Ваша версия Windows не поддерживается 7-Zip Theme Manager.    " & @LF & "Использование может привести к серьезным ошибкам!    "
	$lang[3][2] = "Папка 7-Zip не найдена, пожалуйста, выберите её.    "
	$lang[3][3] = "Пожалуйста, выберите папку 7-Zip...    "
	$lang[3][4] = "Следующая директория была определена как ваша директория 7-Zip:   "
	$lang[3][5] = "Верно?"
	$lang[3][6] = 'Файл "7z.dll" отсутствует в указанной папке.   ' & @LF & "Убедитесь, что файл присутствует и указанная папка верна.   " & @LF & @LF & "Программа теперь будет закрыта.   "
	$lang[3][7] = 'Файл "7zFM.exe" отсутствует в указанной папке.   ' & @LF & "Убедитесь, что файл присутствует и указанная папка верна.   " & @LF & @LF & "Программа теперь будет закрыта.   "
	$lang[3][8] = "Требуется как минимум 7-Zip 4.65. Ваша версия устарела, пожалуйста, обновите её.    " & @LF & @LF & "Программа теперь будет закрыта.   "
	$lang[3][9] = 'Тема панели'
	$lang[3][10] = 'Тема типов файлов'
	$lang[3][11] = '" не может быть загружена,    ' & @LF & 'потому что она неполная или отсутствует файл "theme.ini".    '
	$lang[3][12] = "Темы для панели не найдены.    "
	$lang[3][13] = "Темы для типов файлов не найдены.    "
	$lang[3][14] = "Активировать тему"
	$lang[3][15] = "Обновить программу/темы"
	$lang[3][16] = "Изменить значок SFX"
	$lang[3][17] = "Закрыть"
	$lang[3][18] = "Предварительный просмотр недоступен."
	$lang[3][19] = "Информация"
	$lang[3][20] = "Название"
	$lang[3][21] = "Автор"
	$lang[3][22] = "Лицензия"
	$lang[3][23] = "Веб-сайт"
	$lang[3][24] = "Доступна обновленная версия. Хотите посетить сайт загрузки?    "
	$lang[3][25] = "Новая версия не найдена.    "
	$lang[3][26] = 'Не найдены файлы "7z.sfx" и "7zCon.sfx".' & @LF & "Пожалуйста, посетите веб-сайт 7-Zip Theme Manager и свяжитесь с автором.    "
	$lang[3][27] = "Похоже, 7-Zip уже используется. Пожалуйста, закройте 7-Zip.    "
	$lang[3][28] = "Идет изменение файлов...    "
	$lang[3][29] = "Завершено...    "
	$lang[3][30] = "Тема активирована.    "
	$lang[3][31] = "Ошибка активации темы.    "
	$lang[3][32] = "Запустить 7z    "
	$lang[3][33] = "Статус: "

#EndRegion incldues
###
#Region language

	If $iFileExists Then
		Dim $ls = IniRead($iniFilePath, "Re7zTM", "Language", "1")
	Else
		Dim $window_ls = GUICreate("Re7zTM  Startup", 267, 79, -1, -1, -1, $ws_ex_topmost)
		Dim $button_ls_ok = GUICtrlCreateButton("OK", 168, 38, 81, 25, 0)
		Dim $combo_ls_languagelist = GUICtrlCreateCombo("English", 8, 40, 145, 25, $cbs_dropdownlist)
		GUICtrlSetData($combo_ls_languagelist, "German|Italian|Russian")
		GUICtrlCreateLabel("Please select your language...", 8, 8, 146, 17)
		GUISetState(@SW_SHOW)
		Dim $var_ls_msg
		While 1
			$var_ls_msg = GUIGetMsg()
			If $var_ls_msg <> 0 Then
				Switch $var_ls_msg
					Case $button_ls_ok
						Switch GUICtrlRead($combo_ls_languagelist)
							Case "German"
								Dim $ls = 0
								IniWrite($iniFilePath, "Re7zTM ", "Language", "0")
								GUIDelete($window_ls)
								ExitLoop
							Case "English"
								Dim $ls = 1
								IniWrite("Re7zTM .ini", "Re7zTM ", "Language", "1")
								GUIDelete($window_ls)
								ExitLoop
							Case "Italian"
								Dim $ls = 2
								IniWrite($iniFilePath, "Re7zTM ", "Language", "2")
								GUIDelete($window_ls)
								ExitLoop
							Case "Russian"
								Dim $ls = 3
								IniWrite($iniFilePath, "Re7zTM ", "Language", "3")
								GUIDelete($window_ls)
								ExitLoop
						EndSwitch
					Case $gui_event_close
						Exit
				EndSwitch
			EndIf
		WEnd
	EndIf


#EndRegion Language
###
#Region compatibility_os
	Dim $var_compatibility_os = 0
	Switch @OSVersion
		Case "WIN_XP"
			$var_compatibility_os = 1
		Case "WIN_2003"
			$var_compatibility_os = 1
		Case "WIN_VISTA"
			$var_compatibility_os = 2
		Case "WIN_2008"
			$var_compatibility_os = 2
		Case "WIN_7"
			$var_compatibility_os = 2
		Case "WIN_10"
			$var_compatibility_os = 2
		Case "WIN_11"
			$var_compatibility_os = 2
	EndSwitch
	If $var_compatibility_os = 0 Then MsgBox(262144 + 48, "Re7zTM  Startup", $lang[$ls][1])
#EndRegion compatibility_os
###
#Region search
	If $iFileExists Then
		Dim $var_file_7zfm = IniRead($iniFilePath, "7Z", "7zfm", "")
		Dim $var_path_7z = IniRead($iniFilePath, "7Z", "Path", "") 
		Dim $var_file_7zdll = IniRead($iniFilePath, "7Z", "7zdll","")
		Dim $var_file_7zconsfx = IniRead($iniFilePath, "7Z", "7zCon","")
		Dim $var_file_7zsfx = IniRead($iniFilePath, "7Z", "7zsfx","")

		;~ TODO Come up with a better solution than this
		if $var_path_7z == 0 Or Not FileExists($var_path_7z) Then
			$var_search_temp = FileSelectFolder($lang[$ls][3], "", 2)
			If FileExists($var_search_temp & "\7z.dll") AND FileExists($var_search_temp & "\7zFM.exe") Then
				Dim $var_path_7z = $var_search_temp
				Dim $var_file_7zdll = $var_path_7z & "\7z.dll"
				Dim $var_file_7zfm = $var_path_7z & "\7zFM.exe"
				Dim $var_file_7zconsfx = $var_path_7z & "\7zCon.sfx"
				IniWrite($iniFilePath, "7Z", "7zfm", $var_file_7zfm)
				IniWrite($iniFilePath, "7Z", "7zdll", $var_file_7zdll)
				IniWrite($iniFilePath, "7Z", "Path", $var_path_7z )
				IniWrite($iniFilePath, "7Z", "7zCon", $var_file_7zconsfx )
			Else
				Select 
					Case $var_search_temp = ""
						Exit
					Case NOT FileExists($var_search_temp & "\7z.dll")
						MsgBox(262144 + 16, "Re7zTM  Startup", $lang[$ls][6])
						Exit
					Case NOT FileExists($var_search_temp & "\7zFM.exe")
						MsgBox(262144 + 16, "Re7zTM  Startup", $lang[$ls][7])
						Exit
				EndSelect
			EndIf
		Endif

	Else
		Dim $var_search = 0
		If FileExists(RegRead("HKEY_CURRENT_USER\SOFTWARE\7-zip", "Path") & "\7z.dll") AND FileExists(RegRead("HKEY_CURRENT_USER\SOFTWARE\7-zip", "Path") & "\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = RegRead("HKEY_CURRENT_USER\SOFTWARE\7-zip", "Path")
			$var_search = 1
		EndIf
		If FileExists(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\7-zip", "Path") & "\7z.dll") AND FileExists(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\7-zip", "Path") & "\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\7-zip", "Path")
			$var_search = 1
		EndIf
		If FileExists(EnvGet("ProgramFiles") & "\7-Zip\7z.dll") AND FileExists(EnvGet("ProgramFiles") & "\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = EnvGet("ProgramFiles") & "\7-Zip"
			$var_search = 1
		EndIf
		If FileExists(EnvGet("ProgramFiles(x86)") & "\7-Zip\7z.dll") AND FileExists(EnvGet("ProgramFiles(x86)") & "\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = EnvGet("ProgramFiles(x86)") & "\7-Zip"
			$var_search = 1
		EndIf
		If FileExists(EnvGet("SystemDrive") & "\Programme\7-Zip\7z.dll") AND FileExists(EnvGet("SystemDrive") & "\Programme\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = EnvGet("SystemDrive") & "\Programme\7-Zip"
			$var_search = 1
		EndIf
		If FileExists(EnvGet("SystemDrive") & "\Program Files\7-Zip\7z.dll") AND FileExists(EnvGet("SystemDrive") & "\Program Files\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = EnvGet("SystemDrive") & "\Program Files\7-Zip"
			$var_search = 1
		EndIf
		If FileExists(EnvGet("SystemDrive") & "\Program Files (x86)\7-Zip\7z.dll") AND FileExists(EnvGet("SystemDrive") & "\Program Files (x86)\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = EnvGet("SystemDrive") & "\Program Files (x86)\7-Zip"
			$var_search = 1
		EndIf
		If FileExists("C:\Programme\7-Zip\7z.dll") AND FileExists("C:\Programme\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = "C:\Programme\7-Zip"
			$var_search = 1
		EndIf
		If FileExists("C:\Program Files\7-Zip\7z.dll") AND FileExists("C:\Program Files\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = "C:\Program Files\7-Zip"
			$var_search = 1
		EndIf
		If FileExists("C:\Program Files (x86)\7-Zip\7z.dll") AND FileExists("C:\Program Files (x86)\7-Zip\7zFM.exe") AND $var_search = 0 Then
			Dim $var_path_7z = "C:\Program Files (x86)\7-Zip"
			$var_search = 1
		EndIf
		If $var_search = 1 Then
			Dim $var_file_7zdll = $var_path_7z & "\7z.dll"
			Dim $var_file_7zfm = $var_path_7z & "\7zFM.exe"
			Dim $var_file_7zsfx = $var_path_7z & "\7z.sfx"
			Dim $var_file_7zconsfx = $var_path_7z & "\7zCon.sfx"
			IniWrite($iniFilePath, "7Z", "7zfm", $var_file_7zfm)
			IniWrite($iniFilePath, "7Z", "7zdll", $var_file_7zdll)
			IniWrite($iniFilePath, "7Z", "Path", $var_path_7z )
			IniWrite($iniFilePath, "7Z", "7zCon", $var_file_7zconsfx )
		EndIf


		Dim $var_search_ok = 0
		Dim $var_search_temp = 0
		
		If $var_search = 0 Then
			MsgBox(262144 + 48, "Re7zTM  Startup", $lang[$ls][2])
		Else
			$var_search_ok = MsgBox(262144 + 32 + 4, "Re7zTM  Startup", $lang[$ls][4] & @LF & @LF & $var_path_7z & @LF & @LF & $lang[$ls][5])
		EndIf

		If $var_search = 0 OR $var_search_ok <> 6 Then
			$var_search_temp = FileSelectFolder($lang[$ls][3], "", 2)
			If FileExists($var_search_temp & "\7z.dll") AND FileExists($var_search_temp & "\7zFM.exe") Then
				Dim $var_path_7z = $var_search_temp
				Dim $var_file_7zdll = $var_path_7z & "\7z.dll"
				Dim $var_file_7zfm = $var_path_7z & "\7zFM.exe"
				IniWrite($iniFilePath, "7Z", "7zfm", $var_file_7zfm)
				IniWrite($iniFilePath, "7Z", "7zdll", $var_file_7zdll)
				IniWrite($iniFilePath, "7Z", "Path", $var_path_7z )
				IniWrite($iniFilePath, "7Z", "7zCon", $var_file_7zconsfx )
			Else
				Select 
					Case $var_search_temp = ""
						Exit
					Case NOT FileExists($var_search_temp & "\7z.dll")
						MsgBox(262144 + 16, "Re7zTM  Startup", $lang[$ls][6])
						Exit
					Case NOT FileExists($var_search_temp & "\7zFM.exe")
						MsgBox(262144 + 16, "Re7zTM  Startup", $lang[$ls][7])
						Exit
				EndSelect
			EndIf
		EndIf
	EndIf
#EndRegion search
###
#Region compatibility_7z
	Dim $var_compatibility_7z = 0
	Dim $var_compatibility_sfx = 0
	Dim $var_compatibility_7z_version[4]
	$var_compatibility_7z_version = StringSplit(FileGetVersion($var_file_7zdll), ".")
	If $var_compatibility_7z_version[1] = 4 AND $var_compatibility_7z_version[2] >= 65 Then $var_compatibility_7z = 1
	If $var_compatibility_7z_version[1] >= 9 Then $var_compatibility_7z = 2
	If $var_compatibility_7z_version[1] = 9 AND $var_compatibility_7z_version[2] >= 6 Then $var_compatibility_sfx = 1
	If $var_compatibility_7z = 0 Then
		MsgBox(262144 + 16, "Re7zTM  Startup", $var_compatibility_7z)
		MsgBox(262144 + 16, "Re7zTM  Startup", $lang[$ls][8])
		Exit
	EndIf
#EndRegion compatibility_7z
###
#Region themeloader
	Dim $var_themeloader_error
	Dim $var_themeloader_counter
	Dim $array_themeloader_toolbar[200]
	Dim $array_themeloader_filetype[200]
	Dim $var_maingui_themelist_toolbar
	Dim $var_maingui_themelist_filetype
	SetError(0)
	$array_themeloader_toolbar = _filelisttoarray(@ScriptDir & "\toolbar\", "*", 2)
	If @error = 0 AND $array_themeloader_toolbar[0] <> 0 Then
		$var_themeloader_counter = 1
		While $var_themeloader_counter <= $array_themeloader_toolbar[0]
			$var_themeloader_error = 0
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\theme.ini") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Add.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Copy.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Delete.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Extract.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Info.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Move.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\24x24\Test.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Add.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Copy.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Delete.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Extract.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Info.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Move.bmp") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\toolbar\" & $array_themeloader_toolbar[$var_themeloader_counter] & "\48x36\Test.bmp") Then $var_themeloader_error = 1
			Switch ($var_themeloader_error)
				Case 0
					$var_maingui_themelist_toolbar = $var_maingui_themelist_toolbar & $array_themeloader_toolbar[$var_themeloader_counter] & "|"
				Case 1
					MsgBox(262144 + 48, "Re7zTM  Startup", $lang[$ls][9] & $array_themeloader_toolbar[$var_themeloader_counter] & $lang[$ls][11])
			EndSwitch
			$var_themeloader_counter += 1
		WEnd
	Else
		MsgBox(262144 + 64, "Re7zTM  Startup", $lang[$ls][12])
	EndIf
	SetError(0)
	$array_themeloader_filetype = _filelisttoarray(@ScriptDir & "\filetype\", "*", 2)
	If @error = 0 AND $array_themeloader_filetype[0] <> 0 Then
		$var_themeloader_counter = 1
		While $var_themeloader_counter <= $array_themeloader_filetype[0]
			$var_themeloader_error = 0
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\theme.ini") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\7z.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\zip.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\bz2.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\rar.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\arj.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\z.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\lha.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\cab.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\iso.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\001.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\rpm.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\deb.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\cpio.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\tar.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\gz.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\wim.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\lzh.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\dmg.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\hfs.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\xar.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\fat.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\ntfs.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\vhd.ico") Then $var_themeloader_error = 1
			If NOT FileExists(@ScriptDir & "\filetype\" & $array_themeloader_filetype[$var_themeloader_counter] & "\xz.ico") Then $var_themeloader_error = 1
			Switch ($var_themeloader_error)
				Case 0
					$var_maingui_themelist_filetype = $var_maingui_themelist_filetype & $array_themeloader_filetype[$var_themeloader_counter] & "|"
				Case 1
					MsgBox(262144 + 48, "Re7zTM  Startup", $lang[$ls][10] & $array_themeloader_filetype[$var_themeloader_counter] & $lang[$ls][11])
			EndSwitch
			$var_themeloader_counter += 1
		WEnd
	Else
		MsgBox(262144 + 64, "Re7zTM  Startup", $lang[$ls][13])
	EndIf
#EndRegion themeloader
###
#Region maingui_build
	Dim $var_maingui_preview_active = 0
	$window_maingui = GUICreate("Re7-Zip Theme Manager 2.2", 613, 440, -1, -1)
	$radio_maingui_toolbar = GUICtrlCreateRadio($lang[$ls][9], 3, 3, 145, 25)
	$radio_maingui_filetype = GUICtrlCreateRadio($lang[$ls][10], 3, 25, 150, 25)
	$list_maingui_themes = GUICtrlCreateList("", 8, 52, 145, 251, BitOR($lbs_sort, $ws_vscroll))
	$button_maingui_activate = GUICtrlCreateButton($lang[$ls][14], 8, 316, 147, 22)
	$button_maingui_sfx = GUICtrlCreateButton($lang[$ls][16], 8, 341, 147, 22)
	$button_maingui_run_7z = GUICtrlCreateButton($lang[$ls][32], 8, 366, 147, 22)
	$button_maingui_close = GUICtrlCreateButton($lang[$ls][17], 8, 391, 147, 22)
	;~ $button_maingui_update = GUICtrlCreateButton($lang[$ls][32], 8, 417, 147, 22)
	$img_maingui_preview = GUICtrlCreatePic("", 168, 24, 430, 280, $ws_border)
	$label_maingui_no_preview = GUICtrlCreateLabel($lang[$ls][18], 168, 24, 432, 282, BitOR($ss_center, $ss_centerimage, $ws_border))
	;~ GUICtrlCreateLabel(, 128, 5, 300, 18, $ss_right)
	$about = GUICtrlCreateLabel("Maik ""KillerCookie"" Keller and Marco ""MAD'S evilution""", 168, 424, 268, 17)
	$static_status = GUICtrlCreateLabel($lang[$ls][33], 168, 6, 63, 17)
	$status = GUICtrlCreateLabel("", 240, 8, 312, 16)
	GUICtrlSetFont(-1, 8, 400, 0, "Arial")
	GUICtrlCreateLabel("www.7zTM.de.vu", 510, 5, 90, 18, $ss_right)
	GUICtrlSetFont(-1, 8, 800, 0, "Arial")
	GUICtrlCreateGroup($lang[$ls][19], 168, 312, 433, 105)
	GUICtrlCreateLabel($lang[$ls][20], 176, 330, 45, 16)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	GUICtrlCreateLabel($lang[$ls][21], 176, 373, 56, 16)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	GUICtrlCreateLabel($lang[$ls][22], 400, 330, 56, 16)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	GUICtrlCreateLabel($lang[$ls][23], 400, 373, 56, 16)
	GUICtrlSetFont(-1, 7, 400, 0, "Arial")
	$input_maingui_info_name = GUICtrlCreateInput("", 176, 346, 193, 21, BitOR($es_autohscroll, $es_readonly))
	$input_maingui_info_author = GUICtrlCreateInput("", 176, 389, 193, 21, BitOR($es_autohscroll, $es_readonly))
	$input_maingui_info_licence = GUICtrlCreateInput("", 400, 346, 193, 21, BitOR($es_autohscroll, $es_readonly))
	$input_maingui_info_website = GUICtrlCreateInput("", 400, 389, 193, 21, BitOR($es_autohscroll, $es_readonly))
	GUICtrlSetState($radio_maingui_toolbar, $gui_checked)
	GUICtrlSetData($list_maingui_themes, $var_maingui_themelist_toolbar)
	;~ If fn_update("check") = 1 Then GUICtrlSetBkColor($button_maingui_update, 65407)
	GUISetState(@SW_SHOW)
#EndRegion maingui_build
###
#Region maingui_handle
	Dim $var_maingui_msg
	Dim $var_maingui_temp
	While 1
		$var_maingui_msg = GUIGetMsg()
		If $var_maingui_msg <> 0 Then
			Switch $var_maingui_msg
				Case $var_maingui_msg = $radio_maingui_toolbar
					If GUICtrlRead($radio_maingui_toolbar) = 1 Then
						GUICtrlSetData($list_maingui_themes, "")
						GUICtrlSetData($list_maingui_themes, $var_maingui_themelist_toolbar)
						fn_clear_info()
					EndIf
				Case $var_maingui_msg = $radio_maingui_filetype
					If GUICtrlRead($radio_maingui_filetype) = 1 Then
						GUICtrlSetData($list_maingui_themes, "")
						GUICtrlSetData($list_maingui_themes, $var_maingui_themelist_filetype)
						fn_clear_info()
					EndIf
				Case $var_maingui_msg = $list_maingui_themes
					If GUICtrlRead($list_maingui_themes) <> "" Then
						fn_get_theme_info(GUICtrlRead($list_maingui_themes), GUICtrlRead($radio_maingui_toolbar))
					EndIf
				;~ Case $var_maingui_msg = $button_maingui_update
				;~ 	If fn_update("check") = 1 Then
				;~ 		Dim $var_maingui_update_answer
				;~ 		$var_maingui_update_answer = MsgBox(262144 + 32 + 4, "7-Zip Theme Manager", $lang[$ls][24], 0, $window_maingui)
				;~ 		If $var_maingui_update_answer = 6 Then fn_update("do")
				;~ 	Else
				;~ 		MsgBox(262144 + 64, "7-Zip Theme Manager", $lang[$ls][25], 0, $window_maingui)
				;~ 	EndIf
				Case $var_maingui_msg = $button_maingui_activate
					If GUICtrlRead($list_maingui_themes) <> "" Then
						fn_patcher(GUICtrlRead($list_maingui_themes), GUICtrlRead($radio_maingui_toolbar))
					EndIf
				Case $var_maingui_msg = $button_maingui_sfx
					If FileExists($var_file_7zsfx) OR FileExists($var_file_7zconsfx) Then
						$var_maingui_temp = 0
						$var_maingui_temp = FileOpenDialog("Re7-Zip Theme Manager", "", "Icons (*.ico)")
						If StringInStr($var_maingui_temp, ".ico") <> 0 Then fn_patcher($var_maingui_temp, 9)
					Else
						MsgBox(262144 + 16, "Re7-Zip Theme Manager", $lang[$ls][26], 0, $window_maingui)
					EndIf
				Case $var_maingui_msg = $button_maingui_close
					Exit
				Case $var_maingui_msg = $gui_event_close
					Exit
				Case $var_maingui_msg = $button_maingui_run_7z
					if FileExists($var_file_7zfm) Then Run($var_file_7zfm, "", @SW_SHOW) 
			EndSwitch
		EndIf
	WEnd
#EndRegion maingui_handle
###
#Region functions

	Func fn_update($action)
		Switch $action
			Case "check"
				Local $var_update = 0
				Local $array_version_online[10]
				Local $array_version_offline[10]
				If Ping("85.13.130.76") <> 0 Then
					$array_version_online = StringSplit(_inetgetsource("http://killercookie-server.media-xshell.com/7zTM/update.txt"), ".")
					If $array_version_online[1] <> 0 Then
						$array_version_offline = StringSplit(FileGetVersion(@ScriptDir & "\" & @ScriptName), ".")
						If $array_version_online[1] > $array_version_offline[1] Then $var_update = 1
						If $array_version_online[1] = $array_version_offline[1] AND $array_version_online[2] > $array_version_offline[2] Then $var_update = 1
					EndIf
				EndIf
				Return $var_update
			Case "do"
				Switch $ls
					Case 0
						ShellExecute("http://killercookie-server.media-xshell.com/7zTM/index.php?cat=00_German&page=02_Download")
					Case 1
						ShellExecute("http://killercookie-server.media-xshell.com/7zTM/index.php?cat=01_English&page=02_Download")
					Case 2
						ShellExecute("http://killercookie-server.media-xshell.com/7zTM/index.php?cat=02_Italian&page=03_Download")
				EndSwitch
		EndSwitch
	EndFunc

	Func fn_get_theme_info($theme, $type)
		Switch $type
			Case 1
				$type = "\toolbar\"
			Case 4
				$type = "\filetype\"
		EndSwitch
		Local $preview_available
		GUICtrlSetData($input_maingui_info_name, IniRead(@ScriptDir & $type & $theme & "\theme.ini", "Theme", "name", "Unknown"))
		GUICtrlSetData($input_maingui_info_author, IniRead(@ScriptDir & $type & $theme & "\theme.ini", "Theme", "author", "Unknown"))
		GUICtrlSetData($input_maingui_info_licence, IniRead(@ScriptDir & $type & $theme & "\theme.ini", "Theme", "licence", "Unknown"))
		GUICtrlSetData($input_maingui_info_website, IniRead(@ScriptDir & $type & $theme & "\theme.ini", "Theme", "website", "Unknown"))
		GUICtrlSetData($status ,  "") 
		$preview_available = FileExists(@ScriptDir & $type & $theme & "\preview.jpg")
		Select 
			Case $preview_available = 1 AND $var_maingui_preview_active = 1
				GUICtrlSetImage($img_maingui_preview, "")
				GUICtrlSetImage($img_maingui_preview, @ScriptDir & $type & $theme & "\preview.jpg")
			Case $preview_available = 1 AND $var_maingui_preview_active = 0
				GUICtrlDelete($label_maingui_no_preview)
				GUICtrlSetImage($img_maingui_preview, "")
				GUICtrlSetImage($img_maingui_preview, @ScriptDir & $type & $theme & "\preview.jpg")
				$var_maingui_preview_active = 1
			Case $preview_available = 0 AND $var_maingui_preview_active = 1
				GUICtrlSetImage($img_maingui_preview, "")
				$label_maingui_no_preview = GUICtrlCreateLabel($lang[$ls][18], 168, 24, 432, 282, BitOR($ss_center, $ss_centerimage, $ws_border))
				$var_maingui_preview_active = 0
		EndSelect
	EndFunc

	Func fn_clear_info()
		GUICtrlSetData($input_maingui_info_name, "")
		GUICtrlSetData($input_maingui_info_author, "")
		GUICtrlSetData($input_maingui_info_licence, "")
		GUICtrlSetData($input_maingui_info_website, "")
		If $var_maingui_preview_active = 1 Then
			GUICtrlSetImage($img_maingui_preview, "")
			$label_maingui_no_preview = GUICtrlCreateLabel($lang[$ls][18], 168, 24, 432, 282, BitOR($ss_center, $ss_centerimage, $ws_border))
			$var_maingui_preview_active = 0
		EndIf
	EndFunc

	Func fn_patcher($theme, $type)
		Local $answer = 1
		If ProcessExists("7zFM.exe") Then
			Do
				$answer = 0
				$answer = MsgBox(262144 + 48 + 5, "Re7-Zip Theme Manager", $lang[$ls][27], 0, $window_maingui)
				If $answer = 0 OR $answer = 2 Then ExitLoop
				If NOT ProcessExists("7zFM.exe") Then $answer = 1
			Until NOT ProcessExists("7zFM.exe")
		EndIf
		If $answer = 1 Then
			FileInstall("C:\Resourcer.exe", @ScriptDir & "\Resourcer.exe")
			Switch $type
				Case 4
					ProgressOn("Re7-Zip Theme Manager", "", $lang[$ls][28])
					Local $var_progress_value = 0
					Local $var_progress_step = 0
					Switch $var_compatibility_7z
						Case 1
							$var_progress_step = Round(90 / 19, 1)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:"""0"" -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:"""0"" -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\7z.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:1 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:1 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\zip.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:2 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:2 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\bz2.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:3 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:3 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\rar.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:4 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:4 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\arj.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:5 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:5 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\z.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:6 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:6 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\lha.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:7 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:7 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\cab.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:8 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:8 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\iso.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:9 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:9 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\001.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:10 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:10 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\rpm.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:11 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:11 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\deb.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:12 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:12 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\cpio.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:13 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:13 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\tar.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:14 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:14 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\gz.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:15 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:15 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\wim.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:16 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:16 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\lzh.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:17 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:17 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\dmg.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:18 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:18 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\hfs.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:19 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:19 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\xar.ico"')
						Case 2
							$var_progress_step = Round(90 / 23, 1)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:"""0"" -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:"""0"" -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\7z.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:1 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:1 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\zip.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:2 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:2 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\bz2.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:3 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:3 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\rar.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:4 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:4 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\arj.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:5 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:5 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\z.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:6 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:6 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\lha.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:7 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:7 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\cab.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:8 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:8 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\iso.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:9 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:9 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\001.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:10 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:10 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\rpm.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:11 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:11 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\deb.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:12 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:12 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\cpio.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:13 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:13 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\tar.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:14 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:14 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\gz.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:15 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:15 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\wim.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:16 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:16 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\lzh.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:17 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:17 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\dmg.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:18 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:18 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\hfs.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:19 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:19 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\xar.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:20 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:20 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\vhd.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:21 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:21 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\fat.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:22 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:22 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\ntfs.ico"')
							fn_progress_add($var_progress_value, $var_progress_step)
							RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zdll & '" -type:icondir -name:23 -lang:1033')
							RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zdll & '" -type:icondir -name:23 -lang:1033 -file:"' & @ScriptDir & "\filetype\" & $theme & '\xz.ico"')
					EndSwitch
					ProgressSet(90)
					Switch $var_compatibility_os
						Case 1
							fn_rebuild_iconcache_old()
						Case 2
							fn_rebuild_iconcache_new()
					EndSwitch
					ProgressSet(100, $lang[$ls][29], "")
					Sleep(2000)
					ProgressOff()
				Case 1
					ProgressOn("Re7-Zip Theme Manager", "", $lang[$ls][28])
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:100 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Add.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:101 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Extract.bmp"')
					ProgressSet(17)
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:102 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Test.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:103 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Copy.bmp"')
					ProgressSet(34)
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:104 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Move.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:105 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Delete.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:106 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\48x36\Info.bmp"')
					ProgressSet(51)
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:150 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Add.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:151 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Extract.bmp"')
					ProgressSet(68)
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:152 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Test.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:153 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Copy.bmp"')
					ProgressSet(85)
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:154 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Move.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:155 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Delete.bmp"')
					RunWait(@ScriptDir & '\Resourcer.exe -op:upd -src:"' & $var_file_7zfm & '" -type:bitmap -name:156 -lang:1033 -file:"' & @ScriptDir & "\toolbar\" & $theme & '\24x24\Info.bmp"')
					ProgressSet(100, $lang[$ls][29], "")
					Sleep(1000)
					ProgressOff()
				Case 9
					ProgressOn("Re7-Zip Theme Manager", "", $lang[$ls][28])
					If FileExists($var_file_7zsfx) Then
						Switch $var_compatibility_sfx
							Case 0
								RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zsfx & '" -type:icondir -name:159 -lang:1033')
								RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zsfx & '" -type:icondir -name:159 -lang:1033 -file:"' & $theme & '"')
							Case 1
								RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zsfx & '" -type:icondir -name:1 -lang:1033')
								RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zsfx & '" -type:icondir -name:1 -lang:1033 -file:"' & $theme & '"')
						EndSwitch
					EndIf
					ProgressSet(50)
					If FileExists($var_file_7zconsfx) Then
						RunWait(@ScriptDir & '\Resourcer.exe -op:del -src:"' & $var_file_7zconsfx & '" -type:icondir -name:101 -lang:1033')
						RunWait(@ScriptDir & '\Resourcer.exe -op:add -src:"' & $var_file_7zconsfx & '" -type:icondir -name:101 -lang:1033 -file:"' & $theme & '"')
					EndIf
					ProgressSet(100, $lang[$ls][29], "")
					Sleep(1000)
					ProgressOff()
			EndSwitch
			
			GUICtrlSetData($status ,  $lang[$ls][30]) 
			GUICtrlSetColor($status, 0xDB7301)
			GUICtrlSetFont($status, 10, 400, 0, "Tahoma")
		Else
			MsgBox(262144 + 48, "Re7-Zip Theme Manager", $lang[$ls][31], 0, $window_maingui)
		EndIf
	EndFunc

	Func fn_progress_add(ByRef $value, $step)
		$value = $value + $step
		ProgressSet($value)
	EndFunc

	Func fn_rebuild_iconcache_new()
		Local $shcne_assocchanged = 134217728
		Local $shcnf_idlist = 0
		DllCall("shell32.dll", "none", "SHChangeNotify", "long", $shcne_assocchanged, "int", $shcnf_idlist, "ptr", 0, "ptr", 0)
	EndFunc

	Func fn_rebuild_iconcache_old()
		Local $reg_key = "HKCU\Control Panel\Desktop\WindowMetrics"
		Local $reg_value = "Shell Icon Size"
		Local $reg_result
		$reg_result = RegRead($reg_key, $reg_value)
		RegWrite($reg_key, $reg_value, "REG_SZ", $reg_result + 1)
		fn_rebuild_iconcache_old_broadcast()
		RegWrite($reg_key, $reg_value, "REG_SZ", $reg_result)
		fn_rebuild_iconcache_old_broadcast()
	EndFunc

	Func fn_rebuild_iconcache_old_broadcast()
		Local $hwnd_broadcast = 65535
		Local $wm_settingchange = 26
		Local $spi_setnonclientmetrics = 42
		Local $smto_abortifhung = 2
		DllCall("user32.dll", "lresult", "SendMessageTimeout", "hwnd", $hwnd_broadcast, "uint", $wm_settingchange, "wparam", $spi_setnonclientmetrics, "lparam", 0, "uint", $smto_abortifhung, "uint", 10000, "dword*", "success")
	EndFunc

#EndRegion functions
###
