# Open the Microsoft Calculator app if it is not running, otherwise bring the app into focus
# Purpose: Remap the "calculator" key on keyboard so that only a single instance of the Calculator app is running.

$calc = Get-Process Calculator -ErrorAction SilentlyContinue

if ($calc)
{
    # Bring Calculator into focus
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.Interaction]::AppActivate($calc.ProcessName)

}
else
{
     Start-Process calc.exe
}
