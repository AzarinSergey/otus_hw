IF((Test-Path -Path "./Wc.Impl.dll") -eq $false) {
    Write-Warning "File or directory does not exist."       
}
Else {
    $LockingProcess = CMD /C "openfiles /query /fo table | find /I ""Wc.Impl.dll"""
    Write-Host $LockingProcess
}