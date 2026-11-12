param([string]$Route='workspace',[string]$Mode='menu',[string]$Answer='')
$ErrorActionPreference='Stop'
function Read-Host { param($Prompt) return $script:Answer }
function Start-Process {
 param($FilePath,$ArgumentList,$WorkingDirectory,$WindowStyle)
 if ($FilePath -notlike '*Godot*') { throw 'Expected Godot launch' }
 if ($ArgumentList -notcontains 'res://scenes/world/world349.tscn') { throw 'Latest entry did not select world349' }
 Write-Output 'VERIFIED_LATEST_349_NO_PROCESS_STARTED'
}
$repoRoot=Split-Path -Parent $PSScriptRoot
$launcher=if($Route -eq 'repo'){Join-Path $PSScriptRoot 'launch-game.ps1'}else{Join-Path (Split-Path -Parent $repoRoot) 'tools\launch-game.ps1'}
& $launcher -Mode $Mode
