# Script to install glfwX (X stands for the version) under Windows
# Authors: Voltana <oss@derikmediagroup.xyz>
# License: MIT: http://creativecommons.org/publicdomain/zero/1.0/

# Adapted from VisPy

$GLFW_URL = "https://github.com/glfw/glfw/releases/download/"

# GLFW pre-compiled binaries download:
# ------------------------------------
# 
# Win32 -> https://github.com/glfw/glfw/releases/download/3.3/glfw-3.3.bin.WIN32.zip
#   x64 -> https://github.com/glfw/glfw/releases/download/3.3/glfw-3.3.bin.WIN64.zip
#
#

$MESA_GL_URL = "https://github.com/vispy/demo-data/raw/master/mesa/"

# Mesa DLLs found linked from:
#     http://qt-project.org/wiki/Cross-compiling-Mesa-for-Windows
# to:
#     http://sourceforge.net/projects/msys2/files/REPOS/MINGW/x86_64/mingw-w64-x86_64-mesa-10.2.4-1-any.pkg.tar.xz/download

function DownloadGLFW ($architecture, $projectPath) {
    [Net.ServicePointManager]::SecurityProtocol = 'Ssl3, Tls, Tls11, Tls12'
    $webclient = New-Object System.Net.WebClient
    # Download and retry up to 3 times in case of network transient errors.
    $url = $GLFW_URL + "3.3/glfw-3.3.bin.WIN" + $architecture + ".zip"
    $fileName = "glfw-3.3.bin.WIN" + $architecture + ".zip"
    # For later use, need to move file to the system directory to make it
    # globally accessible
    if ($architecture -eq "32") {
        $filepathDll = "${projectPath}\includes\Win${architecture}\glfw3.dll"
        $filepathLib = "${projectPath}\includes\Win${architecture}\glfw3.lib"
    } else {
        $filepathDll = "${projectPath}\includes\x${architecture}\glfw3.dll"
        $filepathLib = "${projectPath}\includes\x${architecture}\glfw3.lib"
    }
    $filepathTmp = "C:\Users\${env:UserName}\Downloads\${fileName}"
    $glfwBase = "C:\Users\${env:UserName}\Documents"
    $glfwHeader = "${glfwBase}\GLFW\glfw3.h"
    # takeown /F $filepath /A
    # icacls $filepath /grant "${env:ComputerName}\${env:UserName}:F"
    # Remove-item -LiteralPath $filepath
    Write-Host "Downloading" $url
    $retry_attempts = 2
    for($i=0; $i -lt $retry_attempts; $i++){
        try {
            $webclient.DownloadFile($url, $filepathTmp)
            break
        }
        Catch [Exception]{
            Start-Sleep 1
        }
    }
    if (Test-Path $filepathTmp) {
        Write-Host "File saved at" $filepathTmp
        # Unpack our zip-Archive
        Invoke-Expression "& `"7z`" x ${filepathTmp} -y -oC:\Users\${env:UserName}\Downloads"
        # Move files into the right destination (libraries)
        Move-Item -Path "C:\Users\${env:UserName}\Downloads\glfw-3.3.bin.WIN${architecture}\lib-vc2017\glfw3.dll" -Destination "${filepathDll}"
        Move-Item -Path "C:\Users\${env:UserName}\Downloads\glfw-3.3.bin.WIN${architecture}\lib-vc2017\glfw3.lib" -Destination "${filepathLib}"
        # Move folders into the right destination (headers)
        Move-Item -Path "C:\Users\${env:UserName}\Downloads\glfw-3.3.bin.WIN${architecture}\include\GLFW" -Destination "${glfwBase}"
        if (Test-Path $filepathDll) {
            if (Test-Path $filepathLib) {
                Write-Host "File moved to" $filepathDll
                Write-Host "File moved to" $filepathLib
                if (Test-Path $glfwHeader) {
                    Write-Host "Header folder moved to" $glfwBase
                    # Safe to clean out all unused archives & folders
                    # Remove temporary created files
                    Remove-item -LiteralPath $filepathTmp
                    # Remove-item -LiteralPath  "C:\Users\${env:UserName}\Downloads\glfw-3.3.bin.WIN${architecture}"
                }
            }
        }
    } else {
        # Retry once to get the error message if any at the last try
        $webclient.DownloadFile($url, $filepathTmp)
    }
}

function DownloadMesaOpenGL ($architecture) {
    [Net.ServicePointManager]::SecurityProtocol = 'Ssl3, Tls, Tls11, Tls12'
    $webclient = New-Object System.Net.WebClient
    # Download and retry up to 3 times in case of network transient errors.
    $url = $MESA_GL_URL + "opengl32_mingw_" + $architecture + ".dll"
    if ($architecture -eq "32") {
        $filepath = "C:\Windows\SysWOW64\opengl32.dll"
    } else {
        $filepath = "C:\Windows\system32\opengl32.dll"
    }
    takeown /F $filepath /A
    icacls $filepath /grant "${env:ComputerName}\${env:UserName}:F"
    Remove-item -LiteralPath $filepath
    Write-Host "Downloading" $url
    $retry_attempts = 2
    for($i=0; $i -lt $retry_attempts; $i++){
        try {
            $webclient.DownloadFile($url, $filepath)
            break
        }
        Catch [Exception]{
            Start-Sleep 1
        }
    }
    if (Test-Path $filepath) {
        Write-Host "File saved at" $filepath
    } else {
        # Retry once to get the error message if any at the last try
        $webclient.DownloadFile($url, $filepath)
    }
}


function main () {
    DownloadGLFW "64 C:\projects\scg3-v2019"
    DownloadMesaOpenGL "64"
}

main
