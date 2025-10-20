Set WshShell = CreateObject("WScript.Shell")
' 获取VBS脚本所在目录
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
' 运行BAT文件，0表示隐藏窗口，True表示等待完成
WshShell.Run chr(34) & scriptDir & "\sync-to-cloud(silent task run and compare) .bat" & chr(34), 0, False
Set WshShell = Nothing