Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile("$PSScriptRoot\ref_frames\res1_08s.jpg")
$w = $img.Width
$h = $img.Height

function Crop-Image($x, $y, $cw, $ch, $outPath) {
    $rect = New-Object System.Drawing.Rectangle($x, $y, $cw, $ch)
    $cropped = $img.Clone($rect, $img.PixelFormat)
    $cropped.Save("$PSScriptRoot\$outPath", [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $cropped.Dispose()
}

Crop-Image 0 ([int]($h*0.1)) ([int]($w*0.45)) ([int]($h*0.65)) 'ref_frames/crop_lounge_08s.jpg'
Crop-Image ([int]($w*0.25)) ([int]($h*0.08)) ([int]($w*0.38)) ([int]($h*0.42)) 'ref_frames/crop_middle_08s.jpg'
Crop-Image ([int]($w*0.55)) ([int]($h*0.08)) ([int]($w*0.44)) ([int]($h*0.45)) 'ref_frames/crop_kitchen_08s.jpg'
Crop-Image ([int]($w*0.2)) ([int]($h*0.35)) ([int]($w*0.65)) ([int]($h*0.6)) 'ref_frames/crop_dining_08s.jpg'
$img.Dispose()
Write-Host 'Cropped images saved!'
