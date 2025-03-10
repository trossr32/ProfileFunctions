<#
.SYNOPSIS
Takes an array and breaks down into an array of arrays by a supplied batch size

.EXAMPLE
Invoke-BatchArray -Arr @(1,2,3,4,5,6,7,8,9) -BatchSize 5 | ForEach-Object { Write-Host $_ }
#>
function Invoke-BatchArray {
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Array to be batched.")]
		[object[]]$Arr,

		[Parameter(Mandatory = $false, HelpMessage = "Number of objects in each batch.")]
		[int]$BatchSize = 5
	)

	for ($i = 0; $i -lt $Arr.Count; $i += $BatchSize) {
		, ($Arr | Select-Object -Skip $i -First $BatchSize)
	}
}

<#
.SYNOPSIS
Gets the parent functions from a ps1 script file (where parents are any functions that have no indentation preceding their declaration, and functions are in the format Verb-Name)

.EXAMPLE
Get-ScriptFunctionNames -Path 'C:\Users\Rob\OneDrive\Documents\PowerShell\ProfileFunctions\CognitoFunctions.ps1'
#>
function Get-ScriptFunctionNames {
	param (
		[parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[AllowNull()]
		[System.String]$Path
	)

	Process {
		[System.Collections.Generic.List[String]]$funcNames = New-Object System.Collections.Generic.List[String]

		if (([System.String]::IsNullOrWhiteSpace($Path))) {
			return $funcNames
		}
        
		Select-String -Path "$Path" -Pattern "^[F|f]unction.*[A-Za-z0-9+]-[A-Za-z0-9+]" | 
		ForEach-Object {
			[System.Text.RegularExpressions.Regex] $regexp = New-Object Regex("(function)( +)([\w-]+)")
			[System.Text.RegularExpressions.Match] $match = $regexp.Match("$_")

			if ($match.Success)	{
				$funcNames.Add("$($match.Groups[3])")
			}   
		}
        
		return , $funcNames.ToArray()
	}
}

# basic greeting function, contents to be added to current function
function My-Greeting {
	Write-Host "Useful functions:"
	Write-Host ""

	$psPath = "C:\GitRepos\ProfileFunctions"
	$funcs = @();

	Get-ChildItem "$psPath\ProfileFunctions\*.ps1" |
	ForEach-Object {
		$funcs = $funcs + (Get-ScriptFunctionNames -Path "$psPath\ProfileFunctions\$($_.Name)")
	}

	$funcs = $funcs + (Get-ScriptFunctionNames -Path "$psPath\Microsoft.PowerShell_profile.ps1")

	Invoke-BatchArray -Arr ($funcs | Sort-Object) -BatchSize 4 | 
	ForEach-Object {
		$line = ''
			
		$_ | ForEach-Object {
			$line += $_.PadRight(40, ' ')
		}

		Write-Host($line)
	}

	Write-Host ""
}