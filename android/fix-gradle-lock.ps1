# Script para liberar el bloqueo de Gradle 8.5
# IMPORTANTE: Cierra Android Studio y cualquier terminal con "flutter run" o Gradle antes de ejecutar.

$gradleDist = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-8.5-all"

Write-Host "Deteniendo daemons de Gradle..." -ForegroundColor Yellow
& "$PSScriptRoot\gradlew.bat" --stop 2>$null
Start-Sleep -Seconds 2

if (Test-Path $gradleDist) {
    Write-Host "Eliminando carpeta bloqueada: $gradleDist" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $gradleDist -ErrorAction SilentlyContinue
    if (Test-Path $gradleDist) {
        Write-Host ""
        Write-Host "NO se pudo eliminar. Cierra:" -ForegroundColor Red
        Write-Host "  - Android Studio" -ForegroundColor Red
        Write-Host "  - Cualquier terminal con 'flutter run' o Gradle" -ForegroundColor Red
        Write-Host "  - Reinicia el PC si sigue fallando" -ForegroundColor Red
        Write-Host ""
        Write-Host "Luego ejecuta de nuevo este script." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Listo. La proxima vez que ejecutes 'flutter run' se descargara Gradle 8.5 de nuevo." -ForegroundColor Green
} else {
    Write-Host "No habia carpeta bloqueada. Puedes ejecutar 'flutter run'." -ForegroundColor Green
}

Write-Host ""
Write-Host "Desde la raiz del proyecto ejecuta: flutter run" -ForegroundColor Cyan
