# Helper used by API_GAPS auditing — captures the device screen, resizes it
# to a markdown-friendly height, and draws labelled red boxes around the UI
# elements that surface a missing/mock backend feature. Coordinates are given
# in *resized* pixel space so it's easy to eyeball them off the rendered PNG.

param(
    [Parameter(Mandatory=$true)] [string]$DeviceId,
    [Parameter(Mandatory=$true)] [string]$OutPath,
    [Parameter(Mandatory=$true)] [object[]]$Boxes,
    [int]$NewHeight = 1600
)

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$tmp = "$env:TEMP\screen_raw.png"

& $adb -s $DeviceId shell screencap -p /sdcard/_cap.png | Out-Null
& $adb -s $DeviceId pull /sdcard/_cap.png $tmp | Out-Null
& $adb -s $DeviceId shell rm /sdcard/_cap.png | Out-Null

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($tmp)
$newW = [int]($img.Width * ($NewHeight / $img.Height))
$bmp = New-Object System.Drawing.Bitmap $newW, $NewHeight
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode    = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.DrawImage($img, 0, 0, $newW, $NewHeight)

$pen   = New-Object System.Drawing.Pen([System.Drawing.Color]::Red, 4)
$font  = New-Object System.Drawing.Font('Microsoft JhengHei', 14, [System.Drawing.FontStyle]::Bold)
$bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 255, 255, 255))
$fgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Red)

foreach ($b in $Boxes) {
    $x = [int]$b.x
    $y = [int]$b.y
    $w = [int]$b.w
    $h = [int]$b.h
    $g.DrawRectangle($pen, $x, $y, $w, $h)
    if ($b.label) {
        $label = [string]$b.label
        $size = $g.MeasureString($label, $font)
        $lx = $x
        $ly = [Math]::Max($y - $size.Height - 4, 0)
        $g.FillRectangle($bgBrush, $lx, $ly, $size.Width + 6, $size.Height + 2)
        $g.DrawString($label, $font, $fgBrush, $lx + 3, $ly + 1)
    }
}

$bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $img.Dispose()
"$OutPath  ($newW x $NewHeight)"
