class OBS
{
    __New(Path)
    {
        this.Path := Path
        this.OBS_sourceList := false

        If (FileExist(this.Path "\global.ini"))
        {
            ; IniRead, Profile, % this.Path "\global.ini", Basic, Profile
            IniRead, SceneCollectionFile, % this.Path "\global.ini", Basic, SceneCollectionFile
            this.getCurrentSceneCollection := SceneCollectionFile

            If (FileExist(this.Path "\basic\scenes\" this.getCurrentSceneCollection ".json"))
            {
                ContentFile := FileOpen(this.Path "\basic\scenes\" this.getCurrentSceneCollection ".json", "r", "UTF-8-RAW")
                this.ContentData := JSON.Load(ContentFile.Read())
                ContentFile.Close()
            }
        }
        return this
    }

    getScene_CollectionList()
    {
        If (FileExist(this.Path "\basic\scenes\"))
        {
            OBS_Scene_Collection :=

            Loop % this.Path "\basic\scenes\*.json"
            {
                OBS_Scene_Collection .= StrSplit(A_LoopFileName, ".").1 "|"
            }
            return OBS_Scene_Collection
        }
    }

    ;class Get extends OBS
    ;{
        getSourceList(Scene_Collection := "default", Param*)
        {
            If (IsObject(this.ContentData))
            {
                If (Scene_CollectionList = "default")
                    ContentData := this.ContentData
                else
                {
                    If (FileExist(this.Path "\basic\scenes\" Scene_Collection ".json"))
                    {
                        ContentFile := FileOpen(this.Path "\basic\scenes\" Scene_Collection ".json", "r", "UTF-8-RAW")
                        ContentData := JSON.Load(ContentFile.Read())
                        ContentFile.Close()
                    }
                }

                OBS_Sources :=

                Loop % Param.Count()
                {
                    iParam := A_Index
                    Loop % ContentData["sources"].Count()
                    {
                        If (Param[iParam] = "Text" OR Param[iParam] = "text_gdiplus")
                        {
                            If (ContentData["sources"][A_Index]["id"] = "text_gdiplus")
                                OBS_Sources .= ContentData["sources"][A_Index]["name"] "|"
                        }
                    }
                }
                return OBS_Sources
            }
        }
    ;}
}
