FileSHA1(sFile="", cSz=4) { ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
	cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 09-Oct-2012
	hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
	IfLess,hFil,1, Return,hFil
	hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
	DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
	VarSetCapacity( SHA_CTX,136,0 ),  DllCall( "advapi32\A_SHAInit", UInt,&SHA_CTX )
	Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
		DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
		, DllCall( "advapi32\A_SHAUpdate", UInt,&SHA_CTX, UInt,&Buffer, UInt,bytesRead )
	DllCall( "advapi32\A_SHAFinal", UInt,&SHA_CTX, UInt,&SHA_CTX + 116 )
	DllCall( "CloseHandle", UInt,hFil )
	Loop % StrLen( Hex:="123456789ABCDEF0" ) + 4
		N := NumGet( SHA_CTX,115+A_Index,"Char"), SHA1 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
	Return SHA1, DllCall( "FreeLibrary", UInt,hMod )
}