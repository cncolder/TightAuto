#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Colder

 Script Function:
	Run TightVNC Server.

#ce ----------------------------------------------------------------------------

#include <Constants.au3>

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1)
Opt("TrayIconDebug", 1)

; Read client ip address from config file.
$ipaddr = StringRegExpReplace(IniRead("config.ini", "client", "ip", "172.168.2.1"), '[^\d\.]', '')

; Default VNC port.
$vncport = 5500

; Default Growl port.
$growlport = 23052

; Run command hidden
Func RunCmd($cmd)
	RunWait(@ComSpec & " /c " & $cmd, "", @SW_HIDE)
EndFunc

; Handle tray mouse event. All click action map to exit.
Func HandleTrayEvent()
	TraySetState()
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "TrayClickEvent")
	TraySetOnEvent($TRAY_EVENT_PRIMARYUP, "TrayClickEvent")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "TrayClickEvent")
	TraySetOnEvent($TRAY_EVENT_SECONDARYDOWN, "TrayClickEvent")
	TraySetOnEvent($TRAY_EVENT_SECONDARYUP, "TrayClickEvent")
	TraySetOnEvent($TRAY_EVENT_SECONDARYDOUBLE, "TrayClickEvent")
EndFunc

Func TrayClickEvent()
    KillVNC()
	Exit
EndFunc

; Kill and wait exit vnc.
Func KillVNC()
	If ProcessExists("WinVNC.exe") Then
		FileDelete("netstat.txt")
		Run("WinVNC.exe -kill")
		ProcessWaitClose("WinVNC.exe", 5)
	EndIf
EndFunc

; Ping until client online.
Func WaitClientOnline()
	Do
		TrayTip("VNC", "检测网络...", 1, 1)
		Sleep(1000)
	Until Ping($ipaddr)
EndFunc

Func ShowLocalIpAddress()
	TrayTip("VNC", "本机IP: " & @IPAddress1 & " " & @IPAddress2, 30, 1)
EndFunc

Func RunVNC()
	; Disable firewall
	RunCmd("netsh firewall set opmode mode=disable")

	; Import setting
	RunCmd("reg import HKCU_Software_ORL_WinVNC3.reg")
	
	Run("WinVNC.exe -run")
	ProcessWait("WinVNC.exe")
EndFunc

Func IsGrowl()
	TCPStartup()
	
	$socket = TCPConnect($ipaddr, $growlport)
	
	If @error Then
		TCPCloseSocket($socket)
		TCPShutdown()
		
		Return False
	Else
		TCPCloseSocket($socket)
		TCPShutdown()
		
		Return True
	EndIf
EndFunc

Func GrowlNotify()
	;Local $notifications[1][1] = [["Notifcation"]]
	;Local $id=_GrowlRegister("AutoIt", $notifications, "http://www.autoitscript.com/autoit3/files/graphics/au3.ico")
	;_GrowlNotify($id, $notifications[0][0], "Simple notification", "Text of the simple notification")
	;_GrowlNotify($id, $notifications[0][0], "Notification with Click", "CLICK ME", "", "ID", "Context", "ContextType")
	;Sleep(10000); Enough time for user to click
	
	;RunCmd("regsvr32 /s GNTPCom.dll")
	
	;$growl = ObjGreate("GNTPCom.Growler")
	;$growl.UseUDP = True
	;$growl.InitWithAddress($ipaddr, "", "GNTPCom", ["notify"])
	;$growl.notify("vnc://" & @ComputerName & ":vnc@" & @IPAddress1)
	
	;$file = FileOpen("growlnotify.vbs", 2)

	;FileWriteLine($file, 'set g = CreateObject("GNTPCom.Growler")')
	;FileWriteLine($file, 'g.UseUDP = true')
	;FileWriteLine($file, 'g.InitWithAddress "' & $ipaddr & '", "", "GNTPCom", Array("notify")')
	;FileWriteLine($file, 'g.Notify "notify", "' & @ComputerName & '", "vnc://:vnc@' & @IPAddress1 & '", "", "vnc://:vnc@' & @IPAddress1 & '"')
	;FileWriteLine($file, 'set g = Nothing')
	
	;FileClose($file)
	
	;RunCmd("growlnotify.vbs")
	
	;FileDelete("growlnotify.vbs")
	
	;RunCmd("regsvr32 /su GNTPCom.dll")
	
	;Sleep(10000)
EndFunc

Func IsVNCViewer()
	TCPStartup()
	
	$socket = TCPConnect($ipaddr, $vncport)
	
	If @error Then
		TCPCloseSocket($socket)
		TCPShutdown()
		
		Return False
	Else
		TCPCloseSocket($socket)
		TCPShutdown()
		
		Return True
	EndIf
EndFunc

Func ConnectVNCViewer()
	Do
		Run("WinVNC.exe -connect " & $ipaddr)
		TrayTip("VNC", "正在连接...", 5, 1)
		Sleep(5000)
		
		RunCmd("netstat -n > netstat.txt")
	
		$result = FileRead("netstat.txt")
	
		$ip_regexp = StringReplace($ipaddr, ".", "\.") & ":5500"
		$vnc_regexp = 'TCP\s+.+' & $ip_regexp & '\s+ESTABLISHED'
		$connected = StringRegExp($result, $vnc_regexp)
	Until $connected
	
	TrayTip("VNC", "管理员现在可以操作您的计算机.", 10, 1)
	Sleep(10000)
EndFunc

Func NotifyOrConnectToClient()
	If IsGrowl() Then
		GrowlNotify()
	Else
		ConnectVNCViewer()
	EndIf
EndFunc

Func RunLoop()
	While 1
		Sleep(100)
	WEnd
EndFunc

Func Main()
	KillVNC()
	RunVNC()
	HandleTrayEvent()
	WaitClientOnline()
	NotifyOrConnectToClient()
	ShowLocalIpAddress()
	RunLoop()
	KillVNC()
EndFunc

Main()
