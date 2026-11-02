$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
$project231 = Split-Path -Parent $PSScriptRoot
$asset231 = Join-Path $project231 'assets/fat_cat231'
$old231 = [System.Drawing.Bitmap]::FromFile((Join-Path $project231 'assets/fat_cat220/roll_sheet.png'))
$new231 = [System.Drawing.Bitmap]::FromFile((Join-Path $asset231 'roll-keyposes.png'))
$rest231 = [System.Drawing.Bitmap]::FromFile((Join-Path $asset231 'rest-pose.png'))
$frameDir231 = Join-Path $asset231 'review_frames'
New-Item -ItemType Directory -Force $frameDir231 | Out-Null
function Crop231($bitmap231, $x231, $y231, $width231, $height231) {
    $rectangle231 = [System.Drawing.Rectangle]::new($x231,$y231,$width231,$height231)
    return $bitmap231.Clone($rectangle231,$bitmap231.PixelFormat)
}
function Card231($bitmap231) {
    # Review packaging only. Fit the opaque subject; preserve its aspect ratio.
    $left231=$bitmap231.Width; $top231=$bitmap231.Height; $right231=0; $bottom231=0
    for ($iy231=0;$iy231 -lt $bitmap231.Height;$iy231++) {
        for ($ix231=0;$ix231 -lt $bitmap231.Width;$ix231++) {
            if ($bitmap231.GetPixel($ix231,$iy231).A -ge 250) {
                $left231=[Math]::Min($left231,$ix231); $top231=[Math]::Min($top231,$iy231)
                $right231=[Math]::Max($right231,$ix231); $bottom231=[Math]::Max($bottom231,$iy231)
            }
        }
    }
    $bounds231=[System.Drawing.Rectangle]::new($left231,$top231,$right231-$left231+1,$bottom231-$top231+1)
    $scale231=[Math]::Min(450.0/$bounds231.Width,370.0/$bounds231.Height)
    $width231=[int][Math]::Round($bounds231.Width*$scale231)
    $height231=[int][Math]::Round($bounds231.Height*$scale231)
    $card231=[System.Drawing.Bitmap]::new(512,512)
    $graphics231=[System.Drawing.Graphics]::FromImage($card231)
    $graphics231.Clear([System.Drawing.Color]::FromArgb(255,37,32,48))
    $graphics231.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics231.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $target231=[System.Drawing.Rectangle]::new([int]((512-$width231)/2),440-$height231,$width231,$height231)
    $graphics231.DrawImage($bitmap231,$target231,$bounds231,[System.Drawing.GraphicsUnit]::Pixel)
    $pen231=[System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255,80,68,91),1)
    $graphics231.DrawLine($pen231,24,442,488,442)
    $pen231.Dispose();$graphics231.Dispose()
    return $card231
}
$poses231=@(
    (Crop231 $old231 0 0 512 512),
    (Crop231 $old231 512 0 512 512),
    (Crop231 $new231 0 0 724 724),
    (Crop231 $new231 724 0 724 724),
    (Crop231 $new231 1448 0 724 724),
    (Crop231 $old231 1024 512 512 512)
)
$labels231=@('OLD 1','OLD 2','NEW SIDE','NEW BACK','NEW RISE','OLD 6')
$strip231=[System.Drawing.Bitmap]::new(512*6,512)
$stripGraphics231=[System.Drawing.Graphics]::FromImage($strip231)
$font231=[System.Drawing.Font]::new('Arial',18)
$encoder231=[System.Windows.Media.Imaging.GifBitmapEncoder]::new()
for($index231=0;$index231 -lt $poses231.Count;$index231++) {
    $card231=Card231 $poses231[$index231]
    $graphics231=[System.Drawing.Graphics]::FromImage($card231)
    $graphics231.DrawString($labels231[$index231],$font231,[System.Drawing.Brushes]::White,24,20)
    $graphics231.Dispose()
    $path231=Join-Path $frameDir231 ('frame-{0}.png' -f $index231)
    $card231.Save($path231,[System.Drawing.Imaging.ImageFormat]::Png)
    $stripGraphics231.DrawImage($card231,[System.Drawing.Rectangle]::new($index231*512,0,512,512),[System.Drawing.Rectangle]::new(0,0,512,512),[System.Drawing.GraphicsUnit]::Pixel)
    $decoder231=[System.Windows.Media.Imaging.BitmapDecoder]::Create([Uri]::new($path231),[System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $metadata231=[System.Windows.Media.Imaging.BitmapMetadata]::new('gif')
    $metadata231.SetQuery('/grctlext/Delay',[UInt16]16)
    $metadata231.SetQuery('/grctlext/Disposal',[Byte]2)
    if($index231 -eq 0) {
        $metadata231.SetQuery('/appext/Application',[System.Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0'))
        $metadata231.SetQuery('/appext/Data',[Byte[]]@(3,1,0,0,0))
    }
    $gifFrame231=[System.Windows.Media.Imaging.BitmapFrame]::Create($decoder231.Frames[0],$null,$metadata231,$null)
    $encoder231.Frames.Add($gifFrame231)
    $card231.Dispose();$poses231[$index231].Dispose()
}
$stream231=[System.IO.File]::Create((Join-Path $asset231 'review-loop.gif'))
$encoder231.Save($stream231);$stream231.Dispose()
# WPF may drop the per-frame GIF metadata when converting PNG BitmapFrames.
# Set the encoded control blocks explicitly; this only changes playback timing.
$gifPath231=Join-Path $asset231 'review-loop.gif'
$gifBytes231=[System.IO.File]::ReadAllBytes($gifPath231)
$delayCount231=0
for($offset231=0;$offset231 -lt $gifBytes231.Length-7;$offset231++) {
    if($gifBytes231[$offset231] -eq 0x21 -and $gifBytes231[$offset231+1] -eq 0xF9 -and $gifBytes231[$offset231+2] -eq 4 -and $gifBytes231[$offset231+7] -eq 0) {
        $gifBytes231[$offset231+4]=16;$gifBytes231[$offset231+5]=0;$delayCount231++
    }
}
if($delayCount231 -ne 6){throw "Unexpected GIF control block count: $delayCount231"}
if(-not [System.Text.Encoding]::ASCII.GetString($gifBytes231).Contains('NETSCAPE2.0')) {
    $paletteEnd231=13
    if(($gifBytes231[10] -band 128) -ne 0){$paletteEnd231+=3*[Math]::Pow(2,($gifBytes231[10] -band 7)+1)}
    $extension231=[Byte[]](@(0x21,0xFF,0x0B)+[System.Text.Encoding]::ASCII.GetBytes('NETSCAPE2.0')+@(3,1,0,0,0))
    $loopBytes231=[Byte[]]::new($gifBytes231.Length+$extension231.Length)
    [Array]::Copy($gifBytes231,0,$loopBytes231,0,$paletteEnd231)
    [Array]::Copy($extension231,0,$loopBytes231,$paletteEnd231,$extension231.Length)
    [Array]::Copy($gifBytes231,$paletteEnd231,$loopBytes231,$paletteEnd231+$extension231.Length,$gifBytes231.Length-$paletteEnd231)
    $gifBytes231=$loopBytes231
}
[System.IO.File]::WriteAllBytes($gifPath231,$gifBytes231)
$stripGraphics231.Dispose()
$strip231.Save((Join-Path $asset231 'continuity-review.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$restCard231=Card231 $rest231
$restCard231.Save((Join-Path $asset231 'rest-review.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$restCard231.Dispose();$font231.Dispose();$strip231.Dispose();$old231.Dispose();$new231.Dispose();$rest231.Dispose()
Write-Output 'CAT231_REVIEW_SAVED frames=6 equal_delay_ms=160'
