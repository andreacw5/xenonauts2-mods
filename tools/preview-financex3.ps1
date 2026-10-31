param(
    [string]$OutFile = (Join-Path $PSScriptRoot '..\FinanceX3\preview.png'),
    [switch]$TitleOnly
)
# Finance x3 preview, matching the Better Base card: dark panelled background, big title.
# The published preview uses -TitleOnly; without it the card also lists the funding per region.
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

$amber = C '#f2b234'; $white = C '#e9edf0'; $grey = C '#8a9096'; $green = C '#3cc45a'

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
$g.DrawString('FUNDING MOD', $fBar, (B $amber), 202, 20)
$state = $g.Save()
$g.SetClip((New-Object Drawing.Rectangle 756, 24, 220, 14))
$g.FillRectangle((B (C '#16181b')), 756, 24, 220, 14)
for ($x = 740; $x -lt 990; $x += 22) {
    $pts = [Drawing.PointF[]]@((New-Object Drawing.PointF ($x + 14), 24), (New-Object Drawing.PointF ($x + 25), 24), (New-Object Drawing.PointF ($x + 11), 38), (New-Object Drawing.PointF $x, 38))
    $g.FillPolygon((B $amber), $pts)
}
$g.Restore($state)

if ($TitleOnly) {
    # Centred title and tagline, nothing else
    $fTitle = F 'Bahnschrift SemiBold Condensed' 230
    $title = 'FINANCE x3'
    $tw = $g.MeasureString($title, $fTitle).Width
    $tx = ($W - $tw) / 2
    $g.DrawString($title, $fTitle, (B (C '#000000' 170)), $tx + 9, 339)
    $g.DrawString($title, $fTitle, (B $white), $tx, 330)
    $g.FillRectangle((B $amber), ($W - 120) / 2, 612, 120, 6)
    $fTag = F 'Bahnschrift SemiBold SemiCondensed' 34
    $tag = 'TRIPLE FUNDING  ' + [char]0x00B7 + '  EVERY REGION  ' + [char]0x00B7 + '  RELATIONS STILL MATTER'
    $gw = $g.MeasureString($tag, $fTag).Width
    $g.DrawString($tag, $fTag, (B $amber), ($W - $gw) / 2, 642)
    $bmp.Save($OutFile, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    return
}

# Title with hard drop shadow
$fTitle = F 'Bahnschrift SemiBold Condensed' 190
$g.DrawString('FINANCE x3', $fTitle, (B (C '#000000' 170)), 44, 78)
$g.DrawString('FINANCE x3', $fTitle, (B $white), 36, 70)
$fTag = F 'Bahnschrift SemiBold SemiCondensed' 29
$g.DrawString('TRIPLE FUNDING  ' + [char]0x00B7 + '  EVERY REGION  ' + [char]0x00B7 + '  RELATIONS STILL MATTER', $fTag, (B $amber), 48, 266)

# Panel tab
$px = 48; $py = 330; $pw = 928; $ph = 640
$tab = [Drawing.PointF[]]@((New-Object Drawing.PointF 80, 330), (New-Object Drawing.PointF 88, 304), (New-Object Drawing.PointF 204, 304), (New-Object Drawing.PointF 212, 330))
$g.FillPolygon((B (C '#24282d')), $tab)
$g.DrawString('MONTHLY FUNDING', (F 'Bahnschrift SemiBold Condensed' 16), (B (C '#c9ced3')), 92, 309)

# Panel body with clipped bottom-right corner
$panel = [Drawing.PointF[]]@((New-Object Drawing.PointF $px, $py), (New-Object Drawing.PointF ($px + $pw), $py), (New-Object Drawing.PointF ($px + $pw), ($py + $ph - 22)), (New-Object Drawing.PointF ($px + $pw - 22), ($py + $ph)), (New-Object Drawing.PointF $px, ($py + $ph)))
$g.FillPolygon((B (C '#0c0d0f' 245)), $panel)

# Hatched header strip
$hdr = New-Object Drawing.Rectangle ($px + 1), ($py + 1), ($pw - 2), 58
$g.FillRectangle((New-Object Drawing.Drawing2D.HatchBrush ([Drawing.Drawing2D.HatchStyle]::WideUpwardDiagonal), (C '#22262b'), (C '#191c20')), $hdr)
$g.DrawLine((New-Object Drawing.Pen (C '#2c3036'), 1), $px, $py + 59, $px + $pw, $py + 59)
$g.DrawString('BASE FUNDING PER REGION', (F 'Bahnschrift SemiBold Condensed' 30), (B $amber), 76, $py + 12)
$g.DrawPolygon((New-Object Drawing.Pen (C '#3a3f45'), 2), $panel)

# Data rows
$fLabel = F 'Bahnschrift SemiBold Condensed' 34
$fSub = F 'Bahnschrift SemiCondensed' 18
$fOld = F 'Bahnschrift SemiCondensed' 30
$fNew = F 'Bahnschrift SemiBold Condensed' 84
$right = New-Object Drawing.StringFormat
$right.Alignment = 'Far'
$rows = @(
    @(('NORTH AMERICA ' + [char]0x00B7 + ' USSR'), 'PER REGION / MONTH', '$220K', '$660K', $white),
    @(('W. EUROPE ' + [char]0x00B7 + ' ASIA PACIFIC'), 'PER REGION / MONTH', '$160K', '$480K', $white),
    @(('AFRICA ' + [char]0x00B7 + ' LATIN AMERICA'), 'PER REGION / MONTH', '$110K', '$330K', $white),
    @('TOTAL', 'ALL SIX REGIONS / MONTH', '$980K', '$2.94M', $green)
)
$rowH = 145; $ry = $py + 60
$pDiv = New-Object Drawing.Pen (C '#22262b'), 1
for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $y = $ry + $i * $rowH
    if ($i -gt 0) { $g.DrawLine($pDiv, $px + 28, $y, $px + $pw - 28, $y) }
    $g.DrawString($row[0], $fLabel, (B $white), 76, $y + 42)
    $g.DrawString($row[1], $fSub, (B $grey), 78, $y + 84)

    $newW = $g.MeasureString($row[3], $fNew).Width
    $newX = 958 - $newW
    $g.DrawString($row[3], $fNew, (B $row[4]), $newX, $y + 22)

    # Arrow and struck-through old value, right-aligned before the new value
    $ax = $newX - 26
    $arrow = [Drawing.PointF[]]@((New-Object Drawing.PointF $ax, ($y + 70)), (New-Object Drawing.PointF ($ax + 9), ($y + 75)), (New-Object Drawing.PointF $ax, ($y + 80)))
    $g.FillPolygon((B $amber), $arrow)
    $oldW = $g.MeasureString($row[2], $fOld).Width
    $oldX = $ax - 22 - $oldW
    $g.DrawString($row[2], $fOld, (B $grey), $oldX, $y + 56)
    $g.DrawLine((New-Object Drawing.Pen $grey, 2), $oldX + 6, $y + 76, $oldX + $oldW - 6, $y + 76)
}

$bmp.Save($OutFile, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
