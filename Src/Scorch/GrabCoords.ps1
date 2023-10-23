#
# Extract coordinates for Scorched Earth by Trap/Bonzai
#
# Read 8x8 blocks in PNG and saves coordinate sets.
# Removes duplicates.
#

$OutputFile = "C:\c64\Code\X2021\trap\Scorch\ScorchCoordinates.prg"

# Initialize array and write c64 binary header
$BinaryFileArray = @(0,0)

$SearchString = ""

[System.Collections.ArrayList]$BinaryFileArrayList = $BinaryFileArray

$InputFiles = get-childitem "C:\c64\Code\X2021\trap\Scorch\*.png"

foreach( $InputFile in $InputFiles) {
    write-output $InputFile.Name
    $BitMap = [System.Drawing.Bitmap]::FromFile((Get-Item $InputFile).fullname) 
    for($y=0; $y -lt 200; $y=$y+8) {
        for($x=0; $x -lt 320; $x=$x+8) {
            if($($BitMap.GetPixel($x,$y)).Name -ne "ff000000") {
                if(($y/8) -lt 6) {
                    write-output "$($x/8),$($y/8) out of bounds"
                } else {
                    write-output "$($x/8),$($y/8)"
                    if(!$SearchString.Contains("[$($x/8),$($y/8)]")) {
                        $BinaryFileArrayList.Add($x/8) | out-null
                        $BinaryFileArrayList.Add($y/8) | out-null
                    }
                }
                $SearchString = $SearchString + "[$($x/8),$($y/8)]"
            }
        }
    }
    $Bitmap.Dispose()
    $BinaryFileArrayList.Add(254) | out-null
    $BinaryFileArrayList.Add(254) | out-null

}
[io.file]::WriteAllBytes($OutputFile, $BinaryFileArrayList)

write-output "Done."