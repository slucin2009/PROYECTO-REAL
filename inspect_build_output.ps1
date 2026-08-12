$in = 'C:\Users\usuario\Downloads\PROYECTO DE VERDAD\proyectodeverdadya\build_output.txt'
$out = 'C:\Users\usuario\AppData\Roaming\Code\copilot-terminal-output\build_output_utf8.txt'
$err = 'C:\Users\usuario\AppData\Roaming\Code\copilot-terminal-output\build_error_utf8.txt'
Get-Content -Path $in -Encoding Unicode | Set-Content -Path $out -Encoding UTF8
Get-Content -Path $out | Select-Object -First 20 | Set-Content -Path 'C:\Users\usuario\AppData\Roaming\Code\copilot-terminal-output\build_output_utf8_head.txt' -Encoding UTF8
Get-Content -Path $out | Select-Object -Last 120 | Set-Content -Path 'C:\Users\usuario\AppData\Roaming\Code\copilot-terminal-output\build_output_utf8_tail.txt' -Encoding UTF8
Select-String -Path $out -Pattern 'BUILD FAILED','FAILURE','ERROR','Exception','Could not resolve','AAR metadata','Failed to','cannot find','Unable to','error:' -SimpleMatch | Set-Content -Path $err -Encoding UTF8
"Done"