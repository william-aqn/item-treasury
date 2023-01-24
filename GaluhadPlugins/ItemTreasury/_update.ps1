Write-Host "ItemTreasury updater and patcher by DCRM"
$PathRun = $PSCommandPath | Split-Path -Parent

Write-Host "Current location [$PathRun]"
Set-Location -Path $PathRun

Write-Host "Check files"
function CheckAndPatch {
    param($file, $pattern, $replace, $patch)

    $LuaPatch = select-string -Path $file -Pattern $pattern
    if ($LuaPatch) {
        Write-Host "$file already patched"
    }
    else {
        (Get-Content -Path $file) -replace $replace, $patch | Set-Content -Path $file
        Write-Host "$file patched"
    }
}

function download {
    param($from, $to)
    Write-Host "Start update $to"
    Invoke-WebRequest -URI $from -OutFile $to
}

CheckAndPatch `
    -file ".\Main.lua" `
    -pattern 'import \(PLUGINDIR\.\."\.BruteforceMod"\);' `
    -replace 'import \(PLUGINDIR\.\."\.Windows"\);' `
    -patch "import (PLUGINDIR..`".Windows`");`nimport (PLUGINDIR..`".BruteforceMod`");"

CheckAndPatch `
    -file ".\Main.lua" `
    -pattern 'LoadBruteforceMod\(\);' `
    -replace 'LoadSequence\(\);' `
    -patch "LoadSequence();`nLoadBruteforceMod();"

CheckAndPatch `
    -file ".\Windows\MainWin.lua" `
    -pattern 'local searchName = BriteforcePrepareSearchName\(searchString\);' `
    -replace 'local searchName = {};' `
    -patch "local searchName = BriteforcePrepareSearchName(searchString);"

CheckAndPatch `
    -file ".\Windows\MainWin.lua" `
    -pattern 'nameMatch = BruteforceSearch\(k, searchName, match\);' `
    -replace 'nameMatch = match;' `
    -patch "nameMatch = BruteforceSearch(k, searchName, match);"

CheckAndPatch `
    -file ".\Windows\MainWin.lua" `
    -pattern 'BruteforceTextOverride\(lblName, itemInfo, itemID\)' `
    -replace 'lblName:SetText\(itemInfo\[1\]\);' `
    -patch "BruteforceTextOverride(lblName, itemInfo, itemID)"

download `
    -from "https://github.com/william-aqn/item-treasury/raw/main/GaluhadPlugins/ItemTreasury/BruteforceMod.lua" `
    -to ".\BruteforceMod.lua"

download `
    -from "https://github.com/dt192/item-treasury-database/raw/patch/RuItems.lua" `
    -to ".\RuItems.lua"

download `
    -from "https://github.com/william-aqn/item-treasury/raw/main/GaluhadPlugins/ItemTreasury/StringsRu.lua" `
    -to ".\StringsRu.lua"

# download `
#     -from "https://github.com/william-aqn/item-treasury/raw/main/GaluhadPlugins/ItemTreasury/_update.ps1" `
#     -to ".\_update.ps1"