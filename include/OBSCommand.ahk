; Wrapper for OBSCommand
; https://github.com/Palakis/obs-websocket/blob/4.x-current/docs/generated/protocol.md

/*
; Test and Example
#Include <JSON>

OBSCommand := new OBSCommand("C:\Program Files\obs-studio\bin\64bit\OBSCommand\OBSCommand.exe", "127.0.0.1", "4444", "123456789")
Random, Test, 100000, 999999
OBSCommand.ChangeText("MyText", Test)
ExitApp
*/

class OBSCommand
{
    __New(Path := "OBSCommand.exe", IP := "127.0.0.1", Port := "4444", Password := "", Options := "hide", WorkingDir := "")
    {
        If (FileExist(Path))
        {
            this.Path := Path
            this.IP := IP
            this.Port := Port
            this.Password := Password
            this.Options := Options
            this.WorkingDir := (WorkingDir ? WorkingDir : A_WorkingDir)
        }
        else
        {
            MsgBox, 16, Error, No OBSCommand.exe found
        }
    }

    ; https://www.autohotkey.com/docs/commands/Run.htm
    Run(Parameters)
    {
        Execute := QM(this.Path) A_Space QM("/server=" this.IP ":" this.Port) A_Space QM("/password=" this.Password) A_Space Parameters
        Run, % Execute, % this.WorkingDir, % this.Options, PID
        return PID
    }

    ; https://obsproject.com/forum/resources/command-line-tool-for-obs-websocket-plugin-windows.615/
    Show(parameters*)
    {
        Command := ""
        for index, parm in parameters
        {
            Command .= QM("/showsource=" parm) (A_Index != parameters.Count() ? A_Space : "")
        }
        return this.Run(Command)
    }

    ; https://obsproject.com/forum/resources/command-line-tool-for-obs-websocket-plugin-windows.615/
    Hide(parameters*)
    {
        Command := ""
        for index, parm in parameters
        {
            Command .= QM("/hidesource=" parm) (A_Index != parameters.Count() ? A_Space : "")
        }
        return this.Run(Command)
    }

    ; https://obsproject.com/forum/resources/command-line-tool-for-obs-websocket-plugin-windows.615/
    Command(parameters*)
    {
        Command := ""
        for index, parm in parameters
        {
            Command .= QM("/command=" parm) A_Space (A_Index != parameters.Count() ? A_Space : "")
        }
        return this.Run(Command)
    }

    ; https://obsproject.com/forum/resources/command-line-tool-for-obs-websocket-plugin-windows.615/
    SendJSON(Command, Object)
    {
        ; Replace Quotation Mark with Apostrophe
    	Str := StrReplace(JSON.Dump(Object), """", "'")
        ; Quotation Mark the whole Command
    	return this.Run(QM("/sendjson=" Command "=" Str))
    }

    ; https://github.com/Palakis/obs-websocket/blob/4.x-current/docs/generated/protocol.md#OpenProjector
    OpenProjector(type := "", monitor := "", geometry := "", name := "")
    {
        return this.Command("OpenProjector,type=" type ",monitor=" monitor ",geometry=" geometry ",name=" name "")
    }

    ; Not really functional -> /sendjson works
    ChangeText(sourceName, Text, alt := 1)
    {
        return this.SetSourceSettings(sourceName, Object("text", "" Text ""),, alt)
    }

    ; https://github.com/Palakis/obs-websocket/blob/4.x-current/docs/generated/protocol.md#setsourcesettings
    SetSourceSettings(sourceName, sourceSettings, sourceType := "", alt := 1)
    {
        If (sourceName AND sourceSettings AND alt == 1)
        {
            source := Object("sourceName", sourceName, "sourceSettings", sourceSettings)
            If (sourceType)
                source["sourceType"] := sourceType
            return this.SendJSON("SetSourceSettings", source)
        }
        else If (sourceName AND sourceSettings AND alt == 2)
        {
            return this.Command("SetSourceSettings,sourceName=" sourceName (sourceType ? ",sourceType=" sourceType : "" ) ",sourceSettings=text=" sourceSettings["text"] "")
        }
    }
}

QM(Str)
{
    ; Quotation Mark the String
    return """" Str """"
}
