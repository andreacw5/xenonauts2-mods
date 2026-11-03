param(
    [Parameter(Mandatory)][string]$OutFile,
    [Parameter(Mandatory)][string[]]$Title,
    [Parameter(Mandatory)][string]$Tagline,
    [string]$Kind = 'AIRCRAFT MOD'
)
# Title-only preview card in the style of the published Finance x3 preview (preview-financex3.ps1 -TitleOnly):
# dark panelled background, top bar with hazard stripes, big centred title, amber tagline.
# -Title takes one string per line; the font shrinks until the longest line fits.
$OutFile = [IO.Path]::GetFullPath($OutFile)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

function C([string]$hex, [int]$a = 255) { $c = [Drawing.ColorTranslator]::FromHtml($hex); [Drawing.Color]::FromArgb($a, $c) }
function F([string]$family, [float]$px) { New-Object Drawing.Font $family, $px, ([Drawing.FontStyle]::Regular), ([Drawing.GraphicsUnit]::Pixel) }
function B([Drawing.Color]$color) { [Drawing.SolidBrush]::new($color) }

$W = 1024; $H = 1024
$bmp = New-Object Drawing.Bitmap $W, $H
$g = [Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'

$amber = C '#f2b234'; $white = C '#e9edf0'; $grey = C '#8a9096'

# Background: vertical wall panels, lighter in the middle
$bgRect = New-Object Drawing.Rectangle 0, 0, $W, $H
$grad = New-Object Drawing.Drawing2D.LinearGradientBrush $bgRect, (C '#15181c'), (C '#15181c'), 0.0
$blend = New-Object Drawing.Drawing2D.ColorBlend 3
$blend.Colors = @((C '#16191d'), (C '#2a2f36'), (C '#16191d'))
$blend.Positions = @(0.0, 0.5, 1.0)
$grad.InterpolationColors = $blend
$g.FillRectangle($grad, $bgRect)
$pSeam = New-Object Drawing.Pen (C '#0e1013' 160), 3
for ($x = 0; $x -le $W; $x += 124) { $g.DrawLine($pSeam, $x, 0, $x, $H) }

# Top bar with hazard stripes
$g.FillRectangle((B (C '#0f1114')), 0, 0, $W, 62)
$g.DrawLine((New-Object Drawing.Pen (C '#3a3f45'), 2), 0, 62, $W, 62)
$fBar = F 'Bahnschrift SemiBold' 17
$g.DrawString('XENONAUTS 2   ' + [char]0x00B7, $fBar, (B $grey), 46, 20)
$g.DrawString($Kind, $fBar, (B $amber), 202, 20)
$state = $g.Save()
$g.SetClip((New-Object Drawing.Rectangle 756, 24, 220, 14))
$g.FillRectangle((B (C '#16181b')), 756, 24, 220, 14)
for ($x = 740; $x -lt 990; $x += 22) {
    $pts = [Drawing.PointF[]]@((New-Object Drawing.PointF ($x + 14), 24), (New-Object Drawing.PointF ($x + 25), 24), (New-Object Drawing.PointF ($x + 11), 38), (New-Object Drawing.PointF $x, 38))
    $g.FillPolygon((B $amber), $pts)
}
$g.Restore($state)

# Title: largest size up to 230 px whose longest line fits in 900 px
$size = 230
do {
    $fTitle = F 'Bahnschrift SemiBold Condensed' $size
    $widest = ($Title | ForEach-Object { $g.MeasureString($_, $fTitle).Width } | Measure-Object -Maximum).Maximum
    $size -= 5
} while ($widest -gt 900)
$lineH = $fTitle.Size * 0.92
$blockH = $lineH * $Title.Count
$ty = 470 - $blockH / 2 - $fTitle.Size * 0.12
foreach ($line in $Title) {
    $tw = $g.MeasureString($line, $fTitle).Width
    $tx = ($W - $tw) / 2
    $g.DrawString($line, $fTitle, (B (C '#000000' 170)), $tx + 9, $ty + 9)
    $g.DrawString($line, $fTitle, (B $white), $tx, $ty)
    $ty += $lineH
}

# Amber rule and tagline under the title
$ruleY = 470 + $blockH / 2 + 40
$g.FillRectangle((B $amber), ($W - 120) / 2, $ruleY, 120, 6)
$fTag = F 'Bahnschrift SemiBold SemiCondensed' 34
$gw = $g.MeasureString($Tagline, $fTag).Width
$g.DrawString($Tagline, $fTag, (B $amber), ($W - $gw) / 2, $ruleY + 30)

$bmp.Save($OutFile, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
