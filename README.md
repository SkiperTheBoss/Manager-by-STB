# Manager-by-STB
A Tool which i created for [ParsecSoda](http://https://github.com/FlavioFS/ParsecSoda "ParsecSoda") that automate a lot of things.

**Infomation**
* The Project Name is not really choosen yet.
* Contact me if you want to make the README more beautiful. Discord: SkiperTheBoss#1337
* [Roadmap](https://trello.com/b/2skmBgus/manager-by-stb "Roadmap")
* MORE DETAILS SOON

------------

**Description**

The Tool is made for the Software [ParsecSoda](http://https://github.com/FlavioFS/ParsecSoda "ParsecSoda") by [FlavioFS](https://github.com/FlavioFS "FlavioFS") which will do a lot of tasks automatically by it self. It basically wrote this Script to Host some Games on [Parsec](https://parsec.app/ "Parsec") and when someone try to close the Game it automatically will restart, so you can use it even if you are away from the Keyboard.

------------

**Features**
* Automatically start OBS Studio
* Automatically open OBS Studio preview Projector
* Blocking Input to not close the OBS Projector with ESC, ALT+F4 or Rightclick
* Change the Game Name (Work in Progress)
* Hide Cursor (Work in Progress)
* Automatically start Window (which could be the Software/Game)
* Automatically attach the Window to the OBS Projector
* Automatically focus the Window
* Blocking Input ALT+F4
* Change the Style and ExStyle of the Window (using for example to make Window borderless)
* Switching from Fullscreen to Window Mode (Work in Progress)
* Restrict the Mouse to the Window Area
* Change the Size of the Window
* Move the Window to your configureated Position

------------

**Requirements**
* To run Script you need [AutoHotkey](https://www.autohotkey.com/ "AutoHotkey") unless you using the Execute under [Releases](https://github.com/SkiperTheBoss/Manager-by-STB/releases "Releases") when available.
* [OBS Studio](http://https://obsproject.com/ "OBS Studio")
* [OPTIONAL] [OBS-Websocket](https://obsproject.com/forum/resources/obs-websocket-remote-control-obs-studio-from-websockets.466/ "OBS-Websocket") a Plugin for OBS Studio.
* [OPTIONAL] [OBSCommand](https://obsproject.com/forum/resources/command-line-tool-for-obs-websocket-plugin-windows.615/ "OBSCommand") to communicate with [OBS-Websocket](https://obsproject.com/forum/resources/obs-websocket-remote-control-obs-studio-from-websockets.466/ "OBS-Websocket").

------------

**SET-UP**
Before you start -> make sure you got the **settings.json** and **window.json** and remove the // Comments. Also make sure the Paths are matching with your System.

------------

**settings.json** 
More in Details will be added. To use the Code below remove the // Comments.

```hjson
{
    "Debug":{
		// Enable Debug
        "Enabled":0,
		// Window of the last Session
        "LastWindow":{
            "ID":0,
            "IsAttach":0
        }
    },
    "General":{
		// Tool stays always on Top
        "AlwaysOnTop":"0",
		// Borders around the Window (works only on Debug Mode)
        "Borders":"1",
        "Debug":"0",
		// Last selected Window
        "LastSelect":"Gang Beasts",
        "LastTitle":"Starter",
		// Has no impact yet
        "Resize":"0",
        "SelectMode":2,
        "SystemCursor":{
			// Hide Cursor
            "Enabled":"0",
			// After 5 seconds
            "Time":5000
        }
    },
    "HotKeys":{
        "Auto_Focus":"Insert",
        "ClipCursor":"Home",
        "Hide_Cursor":"PgUp"
    },
    "OBS":{
        "Auto_Start":"1",
        "AutoStart":"0",
        "Execute":"obs64.exe",
        "Parameters":"--minimize-to-tray --multi",
		// Path to OBS Folder where the Execute is located
        "Path":"C:\\Program Files\\obs-studio\\bin\\64bit",
        "Plugins":{
            "OBSCommand":{
                "Execute":"OBSCommand.exe",
				// Local IP for Websocket
                "IP":"127.0.0.1",
                "Password":"123456789",
				// Path to OBSCommand where the Excute is located
                "Path":"C:\\Program Files\\obs-studio\\bin\\64bit\\OBSCommand",
                "Port":"4444",
                "Set":{
                    "Title":{
                        "Enabled":"1",
                        "scene_collection":"Parsec__Fullscreen",
                        "sourceName":"Game_Name"
                    }
                }
            }
        },
        "Prevent":{
            "Keys":1,
            "Rightclick":1
        },
        "Projector":{
            "Auto_Start":"1",
            "Enabled":"1",
            "Mode":"Fullscreen",
            "Monitor":0,
            "Type":"Preview"
        }
    },
    "Window":{
        "Auto_Attach":"1",
        "Auto_Focus":"0",
        "Auto_Start":"1",
        "Block_Keys":"1",
        "ClipCursor":"0",
        "Display_Mode":"1",
        "ExStyle":"1",
        "Move":"1",
        "Set":{
            "Parent":{
                "Enabled":"1"
            },
            "Pos":{
                "Enabled":"1",
                "X":6,
                "Y":90
            },
            "Size":{
                "Enabled":"1",
                "Height":900,
                "Width":1600
            },
            "Style":{
                "Enabled":"1",
                "Table":[
                    "-0x800000",
                    "-0x80000000",
                    "-0xC00000"
                ]
            }
        },
        "Size":"1",
        "Style":"1"
    }
}
```

**window.json** 
More in Details will be added. To use the Code below remove the // Comments.

```hjson
{
    "Gang Beasts":{
		// Path to the Game Folder
        "Path":..\Steam\\steamapps\\common\\Gang Beasts",
		// Execute of the Game
        "Execute":"Gang Beasts.exe",
		// Start in Window Mode
        "Parameters":"-windowed",
		// It is recommended and for some Games required to start over Steam. In this case add the AppID which you can find when you visit the Steam Store
        "Steam":{
            "AppID":"285900"
        },
		// https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles
        "Style":{
            "WS_BORDER":0,
            "WS_CLIPSIBLINGS":1,
            "WS_DLGFRAME":0,
            "WS_SYSMENU":1,
            "WS_VISIBLE":1,
            "WS_MINIMIZEBOX":1,
            "WS_OVERLAPPED":1
        },
		// https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
        "ExStyle":{
            "WS_EX_WINDOWEDGE":1,
            "WS_EX_LEFT":1,
            "WS_EX_LTRREADING":1,
            "WS_EX_RIGHTSCROLLBAR":1
        }
    }
}
```

------------

**Image**

![Manager-by-STB](https://github.com/SkiperTheBoss/Manager-by-STB/blob/main/image/Manager-by-STB.png "Manager-by-STB")

**Visual Paradigm**

[![Visual Paradigm](https://github.com/SkiperTheBoss/Manager-by-STB/blob/main/image/Manager-by-STB-Diagram.png "Visual Paradigm")](https://online.visual-paradigm.com/ "Visual Paradigm")
