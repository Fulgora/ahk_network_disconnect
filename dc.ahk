#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

$F12:: ToggleNetwork()

ToggleNetwork()  {
    ;Disable WiFi
    wmi := ComObjGet("winmgmts:")
    for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter")
        if (InStr(adapter.name, "ethernet") or InStr(adapter.name, "wireless")) && (interfaceName := adapter.NetConnectionID) && status := adapter.NetConnectionStatus
            if (GetConnectionStatus(adapter, status) == 2) {
                ToggleAdapter(adapter, interfaceName, status)
            }               
    if (interfaceName = "" || status = "")  {
        MsgBox, Failed to get the interfaceName!
        return
    }
}

GetConnectionStatus(adapter, status) {
    if status not in 0,2   ; Disconnected = 0, Connected = 2
    {
        Loop  {
            Sleep, 10
            for adapter in wmi.ExecQuery("Select * from Win32_NetworkAdapter Where Index=" . adapter.Index)
            status := adapter.NetConnectionStatus
        } until status = 0 || status = 2 || (A_Index = 20 && failed := true)
        if failed  {
            MsgBox, Failed to get the status!
            return
        }
    }
    return status
}

ToggleAdapter(adapter, interfaceName, status) {
    Run, % (A_IsAdmin ? "" : "*RunAs ") . "netsh.exe interface set interface name="""
                                       . interfaceName . """ admin="
                                       . (status = 0 ? "en" : "dis") . "abled",, Hide
}
