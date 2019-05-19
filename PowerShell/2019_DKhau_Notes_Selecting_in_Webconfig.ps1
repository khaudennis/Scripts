<#
$path = "C:\Users\dkhau\Desktop\Test\Web.config"  
$select = Select-Xml -Path $path -XPath "//configuration/system.webServer/iisnode"


$xml = [xml](Get-Content $path)
$select = Select-Xml -Xml $xml -XPath "//configuration/system.webServer/iisnode"
#>

$path = "C:\Users\dkhau\Desktop\Test\Web.config"

if (Test-Path $path -PathType Leaf)
{    
    $config = [xml](Get-Content $path)
    #$select = Select-Xml -Xml $xml -XPath "//configuration/system.webServer/iisnode[@nodeProcessCommandLine]" | Select-Object -ExpandProperty Node
    $findNode = Select-Xml -Xml $config -XPath "//configuration/system.webServer/iisnode" | Select-Object –ExpandProperty Node

    if (([string]::IsNullOrEmpty($findNode.nodeProcessCommandLine)))
    {
        Write-Host "nodeProcessCommandLine not declared. Adding to Web.config..."

    }

    $findUrlRewrite = Select-Xml -Xml $config -XPath "//configuration/system.webServer/rules/rule/action[@url]" | Select-Object –ExpandProperty Node

    Write-Output $findUrlRewrite

    if (([string]::IsNullOrEmpty($findUrlRewrite.url)))
    {
        Write-Host "URL Rewrite not declared. Adding to Web.config..."

    }
}