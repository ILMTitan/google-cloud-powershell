Param([string]$Configuration)

if (-not $Configuration) {
    $Configuration = "Release"
}

$testDllNames = ,"Google.PowerShell.Tests.dll"

$testDlls = ls -r -include $testDllNames | ? FullName -Like *\bin\$Configuration\*

$testContainerArgs = $testDlls.FullName -join " "

if ($env:APPVEYOR) {
    $testArgs = "$testContainerArgs --result=myresults.xml;format=AppVeyor"
} else {
    $testArgs = $testContainerArgs
}

$testFilters = ($testDlls.BaseName | % { "-[$_]*"}) -join " "

$filter = $testFilters, "+[Google.PowerShell*]*" -join " "

Write-Verbose "OpenCover.Console.exe -register:user -target:nunit3-console.exe -targetargs:$testArgs -output:codecoverage.xml `
    -filter:$filter -returntargetcode"

OpenCover.Console.exe -register:user -target:nunit3-console.exe -targetargs:$testArgs -output:codecoverage.xml `
    -filter:$filter -returntargetcode

if ($LASTEXITCODE) {
    throw "Test failed with code $LASTEXITCODE"
}
Write-Host "Finished code coverage."
