# PowerShell 내장 HttpListener 기반 초경량 로컬 웹 서버
$port = 8080
$prefix = "http://localhost:$port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host " [토익 & 비즈니스 영어 단어 학습 앱 PWA 로컬 서버]" -ForegroundColor Cyan
    Write-Host " 서버 주소: $prefix" -ForegroundColor Yellow
    Write-Host " 브라우저가 자동으로 실행됩니다. (종료: Ctrl + C)" -ForegroundColor Gray
    Write-Host "==========================================================" -ForegroundColor Green

    # 기본 브라우저 실행
    Start-Process $prefix

    $baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (!$baseDir) { $baseDir = Get-Location }

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/" -or $urlPath -eq "") {
            $urlPath = "/index.html"
        }

        $localPath = Join-Path $baseDir ($urlPath.TrimStart('/').Replace('/', '\'))

        if (Test-Path $localPath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
            $mime = "application/octet-stream"
            switch ($ext) {
                ".html" { $mime = "text/html; charset=utf-8" }
                ".css"  { $mime = "text/css; charset=utf-8" }
                ".js"   { $mime = "application/javascript; charset=utf-8" }
                ".json" { $mime = "application/json; charset=utf-8" }
                ".png"  { $mime = "image/png" }
                ".svg"  { $mime = "image/svg+xml" }
                ".csv"  { $mime = "text/csv; charset=utf-8" }
            }

            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $msg.Length
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }
        $response.Close()
    }
}
catch {
    Write-Host "서버 실행 오류: $_" -ForegroundColor Red
}
finally {
    $listener.Stop()
}
