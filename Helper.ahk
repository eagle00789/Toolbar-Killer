#NoTrayIcon
if 0 < 3
{
exitapp
}
StringReplace, 1, 1, ",, All
WinWait, %1%, 
IfWinNotActive, %1%, , WinActivate, %1%, 
WinWaitActive, %1%, 
MouseClick, left,  %2%,  %3%
