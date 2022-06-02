<#
.SYNOPSIS
    Build the GitHub Wiki based on Runbooks/PowerShell scripts.
.DESCRIPTION
    Build the GitHub Wiki based on Runbooks/PowerShell scripts.
    Use the Get-Help -Full cmdlet on all scripts in the SourceFolder.
    Requires the Repository Wiki to be initialized first, with a Home.md file.

    Due to the nature of the GitHub Wiki, only flat filestructures are supported, 
    which means this script also only supports a flat filestructure for the script files.

    If a non-flat filstructure for scripts exists, you might want to prefix the script.md files with a folder name or similar
    to keep the structure visible.
.OUTPUTS
    A MARKDOWN formattet file named like the script, containing the output of the Get-Help cmdlet in a markdown codeblock.
.NOTES
    N/A
#>

# The repository root is in the folder $env:RepositoryName - The "ChildPath" is where the scripts to be included are found
$SourceFolder = Join-Path -Path $env:RepositoryName -ChildPath "src" -AdditionalChildPath "runbooks"

# Cleanup the existing Wiki, excluding the frontpage named "Home.md"
Remove-Item $(Join-Path -Path $env:RepositoryWikiName -ChildPath "\*.md") -Exclude "Home.md" -Recurse -Force

# If the Source folder exists and contains some files, then document those files
if ((Test-Path -Path $SourceFolder) -and ($Scripts = $(Get-ChildItem $SourceFolder))) {
    foreach ($Script in $Scripts) {
        # Define the Script input and DocumentedScript output file names
        $ScriptInput = $Script.FullName
        $DocumentedScriptOutput = Join-Path -Path $env:RepositoryWikiName -ChildPath $($Script.Name + ".md")

        # Get the script help content
        $Content = Get-Help $ScriptInput -Full

        # Convert the Get-Help object to a string by putting it through a file
        $Content | Out-File -file $DocumentedScriptOutput
        $Content = Get-Content -Path $DocumentedScriptOutput -Raw

        # Write the markdown file
        New-Item -ItemType file -Path $DocumentedScriptOutput -Force
        Add-Content -Path $DocumentedScriptOutput -Value "``````"
        # Remove the path from the scriptfile name - does not make sense as it will be from the build agent
        Add-Content -Path $DocumentedScriptOutput -Value $Content.Replace($Script.FullName, $Script.Name)
        Add-Content -Path $DocumentedScriptOutput -Value "``````"
   }
}
