# 设置控制台编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 启用日志
$VerbosePreference = "Continue"

# 导入必要的程序并初始化窗口
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class KeyboardHelper {
        [DllImport("user32.dll")]
        public static extern short GetKeyState(int nVirtKey);
    }
"@

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

# 调用按键库
. .\key.ps1

# 全局变量
$script:isBinding = $false
$script:currentBindingButton = $null

# 按键绑定控件UI参数
$script:bindingControlHeight = 28
$script:bindingControlWidth = 110
$script:bindingControlHorizontalSpacing = 5
$script:bindingControlVerticalSpacing = 5

$currentDirectory = Get-Location
$sourceFile = Join-Path -Path $currentDirectory -ChildPath "resource.zip"
if (-Not (Test-Path -Path $sourceFile)) {
    throw "当前目录下未找到 resource.zip 文件"
}

$process = Get-Process -Name "完美世界竞技平台" -ErrorAction Stop
$processPath = ($process | Select-Object -First 1).Path
$directory = Split-Path $processPath -Parent

$targetFile = Join-Path -Path $directory -ChildPath "plugin\resource\resource.zip"
$targetDirectory = Split-Path $targetFile -Parent
if (-Not (Test-Path -Path $targetDirectory)) {
    New-Item -Path $targetDirectory -ItemType Directory -Force
}

Copy-Item -Path $sourceFile -Destination $targetFile -Force
if (-Not (Test-Path -Path $targetFile)) {
    throw "文件复制失败: $targetFile"
}

$zipFilePath2 = ".\resource.zip"
$destinationFolder2 = "..\..\resource"
if (-not (Test-Path $destinationFolder2)) {
    New-Item -Path $destinationFolder2 -ItemType Directory
}

Expand-Archive -Path $zipFilePath2 -DestinationPath $destinationFolder2 -Force

Write-Verbose "Installation completed"
# 最终提示
$finalMessage = "安装完成，请重开游戏后测试。`n`n"
if ($feedbackMessage) {
    $finalMessage += "附属：`n$feedbackMessage"
}

$result = [System.Windows.Forms.MessageBox]::Show($finalMessage, "安装完成", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)