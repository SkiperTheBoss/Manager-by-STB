class CLI
{
	__New(sCmd, sDir="",codepage="")
	{
		DllCall("CreatePipe","Ptr*",hStdInRd,"Ptr*",hStdInWr,"Uint",0,"Uint",0)
		DllCall("CreatePipe","Ptr*",hStdOutRd,"Ptr*",hStdOutWr,"Uint",0,"Uint",0)
		DllCall("SetHandleInformation","Ptr",hStdInRd,"Uint",1,"Uint",1)
		DllCall("SetHandleInformation","Ptr",hStdOutWr,"Uint",1,"Uint",1)
		if (A_PtrSize=4)
		{
			VarSetCapacity(pi, 16, 0)
			sisize:=VarSetCapacity(si,68,0)
			NumPut(sisize, si,  0, "UInt"), NumPut(0x100, si, 44, "UInt"),NumPut(hStdInRd , si, 56, "Ptr"),NumPut(hStdOutWr, si, 60, "Ptr"),NumPut(hStdOutWr, si, 64, "Ptr")
		}
		else if (A_PtrSize=8)
		{
			VarSetCapacity(pi, 24, 0)
			sisize:=VarSetCapacity(si,96,0)
			NumPut(sisize, si,  0, "UInt"),NumPut(0x100, si, 60, "UInt"),NumPut(hStdInRd , si, 80, "Ptr"),NumPut(hStdOutWr, si, 88, "Ptr"), NumPut(hStdOutWr, si, 96, "Ptr")
		}
		if (DllCall("CreateProcess", "Uint", 0, "Ptr", &sCmd, "Uint", 0, "Uint", 0, "Int", True, "Uint", 0x08000000, "Uint", 0, "Ptr", sDir ? &sDir : 0, "Ptr", &si, "Ptr", &pi))
		{
			DllCall("CloseHandle","Ptr",NumGet(pi,0))
			DllCall("CloseHandle","Ptr",NumGet(pi,A_PtrSize))
			DllCall("CloseHandle","Ptr",hStdOutWr)
			DllCall("CloseHandle","Ptr",hStdInRd)
			pid:=NumGet(pi, A_PtrSize*2, "uint") ;DWORD dwProcessId NumGet(pi,A_PtrSize))
			; Create the object containing object_files and pipe_handlers
			this.codepage:=(codepage="")?A_FileEncoding:codepage
			this.fStdOutRd:=FileOpen(hStdOutRd, "h", this.codepage)
			;this.fStdInWr:=FileOpen(hStdInWr, "h", this.codepage) ; the write file objet needs to be open for each write
			this.hStdInWr:= hStdInWr, this.hStdOutRd:= hStdOutRd, this.pid:=pid
		}
	}
	__Delete()
	{
		;this.fStdInWr.Close()
		this.fStdOutRd.Close()
		this.close()
	}

	close()
	{
		hStdInWr:=this.hStdInWr
		hStdOutRd:=this.hStdOutRd
		DllCall("CloseHandle","Ptr",hStdInWr)
		DllCall("CloseHandle","Ptr",hStdOutRd)
	}

	write(sInput="")
	{
		If   sInput <>
			FileOpen(this.hStdInWr, "h", this.codepage).Write(sInput)
	}

	read(chars="")
	{
		if (this.fStdOutRd.AtEOF=0)
			return chars=""?this.fStdOutRd.Read():this.fStdOutRd.Read(chars)
	}

	readline()
	{
		if (this.fStdOutRd.AtEOF=0)
			return this.fStdOutRd.ReadLine(chars)
	}

	send_expect(s1="",e1="",s2="",e2="",s3="",e3="",s4="",e4="",s5="",e5="")
	{
		gout:=""
		loop, 5 {
			out:=""
			if (s%A_Index%<>"")
				this.write(s%A_Index% "`r`n")
			if ((expect:=e%A_Index%)<>"")  {
				loop, 10 { ;first expect aprox!!!
					out.=this.read()
					if  InStr(out,expect)
						break
					else
						sleep 25*A_Index ;25,50,75 ... to 250 ms
				}
			}
			gout.=out
		}
		return gout
	}
}
