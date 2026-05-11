$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$iconsDir = Join-Path $root 'public\icons'
$shotsDir = Join-Path $root 'public\screenshots'
$faviconPath = Join-Path $root 'public\scoundrel\assets\favicon.png'

New-Item -ItemType Directory -Force -Path $iconsDir, $shotsDir | Out-Null

function New-ResizedPng {
  param(
    [string]$InputPath,
    [string]$OutputPath,
    [int]$Size
  )

  $src = [System.Drawing.Image]::FromFile($InputPath)
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $gfx = [System.Drawing.Graphics]::FromImage($bmp)
  $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $gfx.Clear([System.Drawing.Color]::Transparent)
  $gfx.DrawImage($src, 0, 0, $Size, $Size)
  $fs = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create)
  $bmp.Save($fs, [System.Drawing.Imaging.ImageFormat]::Png)
  $fs.Dispose()
  $gfx.Dispose()
  $bmp.Dispose()
  $src.Dispose()
}

function New-InstallScreenshot {
  param(
    [string]$OutputPath,
    [int]$Width,
    [int]$Height,
    [bool]$Wide
  )

  $bmp = New-Object System.Drawing.Bitmap $Width, $Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(12, 15, 26))

  $panel = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(26, 30, 48))
  $panel2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(38, 43, 70))
  $gold = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(214, 187, 125))
  $muted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(164, 170, 210))
  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $green = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(58, 208, 124))
  $line = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(74, 82, 126), 2)

  $title = [System.Drawing.Font]::new('Segoe UI', $(if ($Wide) { 28 } else { 24 }), [System.Drawing.FontStyle]::Bold)
  $small = [System.Drawing.Font]::new('Segoe UI', $(if ($Wide) { 12 } else { 10 }), [System.Drawing.FontStyle]::Bold)
  $body = [System.Drawing.Font]::new('Segoe UI', $(if ($Wide) { 16 } else { 14 }), [System.Drawing.FontStyle]::Bold)
  $copy = [System.Drawing.Font]::new('Segoe UI', $(if ($Wide) { 14 } else { 12 }))

  $margin = if ($Wide) { 32 } else { 24 }
  $hudHeight = if ($Wide) { 180 } else { 190 }
  $hudWidth = $Width - ($margin * 2)

  $g.FillRectangle($panel, $margin, $margin, $hudWidth, $hudHeight)
  $g.DrawRectangle($line, $margin, $margin, $hudWidth, $hudHeight)
  $g.DrawString('Scoundrel', $title, $white, $margin + 18, $margin + 14)

  $barX = $margin + 18
  $barY = $margin + 58
  $barWidth = $hudWidth - 36
  $g.DrawString('HEALTH', $small, $muted, $barX, $barY - 22)
  $g.FillRectangle($panel2, $barX, $barY, $barWidth, 24)
  $g.FillRectangle($green, $barX, $barY, [int]($barWidth * 0.78), 24)
  $g.DrawString('17 / 20', $small, $white, $barX + $barWidth - 70, $barY + 4)

  $stats = @(
    @('WEAPON', '9'),
    @('TURN', '3'),
    @('DECK', '34'),
    @('DISCARD', '2')
  )
  $statWidth = [int](($barWidth - 36) / 4)
  for ($i = 0; $i -lt $stats.Count; $i++) {
    $x = $barX + ($i * ($statWidth + 12))
    $y = $barY + 44
    $g.FillRectangle($panel2, $x, $y, $statWidth, 54)
    $g.DrawRectangle($line, $x, $y, $statWidth, 54)
    $g.DrawString($stats[$i][0], $small, $muted, $x + 10, $y + 8)
    $g.DrawString($stats[$i][1], $body, $(if ($i -eq 0) { $gold } else { $white }), $x + 10, $y + 26)
  }

  $cardData = @(
    @{ Color = [System.Drawing.Color]::FromArgb(170, 33, 33); Label = '5 CLUB' },
    @{ Color = [System.Drawing.Color]::FromArgb(36, 120, 214); Label = '8 DIAM' },
    @{ Color = [System.Drawing.Color]::FromArgb(170, 33, 33); Label = 'Q SPADE' },
    @{ Color = [System.Drawing.Color]::FromArgb(42, 140, 86); Label = '4 HEART' }
  )

  $gridTop = $margin + $hudHeight + $(if ($Wide) { 28 } else { 24 })
  if ($Wide) {
    $cardWidth = 250
    $cardHeight = 250
    $gap = 22
    $left = [int](($Width - (($cardWidth * 4) + ($gap * 3))) / 2)
  } else {
    $cardWidth = 220
    $cardHeight = 260
    $gap = 20
    $left = [int](($Width - (($cardWidth * 2) + $gap)) / 2)
  }

  for ($i = 0; $i -lt $cardData.Count; $i++) {
    if ($Wide) {
      $x = $left + (($cardWidth + $gap) * $i)
      $y = $gridTop
    } else {
      $x = $left + (($cardWidth + $gap) * ($i % 2))
      $y = $gridTop + (([math]::Floor($i / 2)) * ($cardHeight + $gap))
    }

    $cardPen = [System.Drawing.Pen]::new($cardData[$i].Color, 3)
    $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, $cardWidth, $cardHeight)
    $g.DrawRectangle($cardPen, $x, $y, $cardWidth, $cardHeight)
    $g.DrawString($cardData[$i].Label, $body, $white, $x + 18, $y + 18)
    $g.DrawEllipse($cardPen, $x + 40, $y + 60, $cardWidth - 80, $cardHeight - 120)
    $g.DrawLine($cardPen, $x + 30, $y + $cardHeight - 40, $x + $cardWidth - 30, $y + 40)
    $cardPen.Dispose()
  }

  $buttonY = if ($Wide) { $gridTop + $cardHeight + 28 } else { $gridTop + ($cardHeight * 2) + $gap + 28 }
  $buttonX = [int](($Width - 458) / 2)
  $avoidBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(118, 76, 18))

  $g.FillRectangle($panel2, $buttonX, $buttonY, 220, 54)
  $g.FillRectangle($avoidBrush, $buttonX + 238, $buttonY, 220, 54)
  $g.DrawRectangle($line, $buttonX, $buttonY, 220, 54)
  $g.DrawRectangle($line, $buttonX + 238, $buttonY, 220, 54)
  $g.DrawString('FACE SELECTED', $body, $muted, $buttonX + 22, $buttonY + 16)
  $g.DrawString('AVOID ROOM', $body, $gold, $buttonX + 286, $buttonY + 16)

  $logY = $buttonY + 82
  $logHeight = if ($Wide) { 86 } else { 108 }
  $g.DrawString('LOG', $small, $muted, $margin + 18, $logY)
  $g.FillRectangle($panel2, $margin + 18, $logY + 24, $Width - ($margin * 2) - 36, $logHeight)
  $g.DrawRectangle($line, $margin + 18, $logY + 24, $Width - ($margin * 2) - 36, $logHeight)
  $g.DrawString('New game started - good luck, scoundrel.', $copy, $muted, $margin + 34, $logY + 42)

  $fs = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create)
  $bmp.Save($fs, [System.Drawing.Imaging.ImageFormat]::Png)
  $fs.Dispose()

  $avoidBrush.Dispose()
  $title.Dispose()
  $small.Dispose()
  $body.Dispose()
  $copy.Dispose()
  $panel.Dispose()
  $panel2.Dispose()
  $gold.Dispose()
  $muted.Dispose()
  $white.Dispose()
  $green.Dispose()
  $line.Dispose()
  $g.Dispose()
  $bmp.Dispose()
}

New-ResizedPng -InputPath $faviconPath -OutputPath (Join-Path $iconsDir 'icon-192.png') -Size 192
New-ResizedPng -InputPath $faviconPath -OutputPath (Join-Path $iconsDir 'icon-512.png') -Size 512
New-InstallScreenshot -OutputPath (Join-Path $shotsDir 'scoundrel-mobile.png') -Width 540 -Height 1200 -Wide $false
New-InstallScreenshot -OutputPath (Join-Path $shotsDir 'scoundrel-desktop.png') -Width 1280 -Height 720 -Wide $true
