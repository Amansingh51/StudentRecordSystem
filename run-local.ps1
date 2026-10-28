$ErrorActionPreference = "Stop"

$project = $PSScriptRoot
$tools = Join-Path $env:LOCALAPPDATA "StudentRecordSystemTools"
$jdk = Join-Path $tools "jdk\jdk-17.0.20.1+1"
$maven = Join-Path $tools "maven\apache-maven-3.9.11\bin\mvn.cmd"
$tomcat = Join-Path $tools "tomcat\apache-tomcat-10.1.61"
$mysqlService = Get-Service -Name "MySQL80" -ErrorAction SilentlyContinue

if (!(Test-Path (Join-Path $jdk "bin\java.exe"))) {
    throw "JDK 17 was not found at $jdk."
}
if (!(Test-Path $maven)) {
    throw "Maven was not found at $maven."
}
if (!(Test-Path (Join-Path $tomcat "bin\startup.bat"))) {
    throw "Tomcat 10.1 was not found at $tomcat."
}
if ($mysqlService -and $mysqlService.Status -ne "Running") {
    throw "The MySQL80 service is not running. Start MySQL and try again."
}

$dbUser = Read-Host "MySQL username"
if ([string]::IsNullOrWhiteSpace($dbUser)) {
    throw "A MySQL username is required."
}

$securePassword = Read-Host "MySQL password (input is hidden)" -AsSecureString
$passwordPointer = [IntPtr]::Zero
try {
    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $env:DB_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
} finally {
    if ($passwordPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}

$env:DB_URL = "jdbc:mysql://localhost:3306/student_records?serverTimezone=UTC"
$env:DB_USER = $dbUser
$env:JAVA_HOME = $jdk
$env:CATALINA_HOME = $tomcat
$env:CATALINA_BASE = $tomcat
$env:Path = "$jdk\bin;$env:Path"

Push-Location $project
try {
    Write-Host "Building StudentRecordSystem..."
    & $maven clean package
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed with exit code $LASTEXITCODE."
    }

    $war = Join-Path $project "target\StudentRecordSystem.war"
    if (!(Test-Path $war)) {
        throw "Build finished but the WAR file was not created: $war"
    }

    $webapps = Join-Path $tomcat "webapps"
    $deployedWar = Join-Path $webapps "StudentRecordSystem.war"
    $deployedApp = Join-Path $webapps "StudentRecordSystem"
    if (Test-Path $deployedApp) {
        Remove-Item -LiteralPath $deployedApp -Recurse -Force
    }
    Copy-Item -LiteralPath $war -Destination $deployedWar -Force

    Write-Host "Restarting Tomcat with the database settings for this session..."
    & (Join-Path $tomcat "bin\shutdown.bat")
    Start-Sleep -Seconds 3
    & (Join-Path $tomcat "bin\startup.bat")

    $ready = $false
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Seconds 2
        try {
            $page = Invoke-WebRequest `
                -Uri "http://localhost:8080/StudentRecordSystem/" `
                -TimeoutSec 5
            if ($page.StatusCode -eq 200) {
                $ready = $true
                break
            }
        } catch {
            # Tomcat may still be starting.
        }
    }

    if (!$ready) {
        throw "Tomcat did not respond. Check the Tomcat logs under $tomcat\logs."
    }

    if ($page.Content.Contains("Could not connect to the database")) {
        Write-Warning "The app is running, but the database connection failed."
        Write-Warning "Check the MySQL username/password and run database.sql in MySQL Workbench."
    } else {
        Write-Host "Database page loaded successfully."
    }
    Write-Host "Open http://localhost:8080/StudentRecordSystem/"
} finally {
    Pop-Location
    Remove-Item Env:DB_PASSWORD -ErrorAction SilentlyContinue
}
