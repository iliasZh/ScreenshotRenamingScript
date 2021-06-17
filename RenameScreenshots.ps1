function Get-FormattedDate([string]$filename, [bool]$log)
{
	$fileInfo = Get-Item $filename				# get file item by name		
	$fileDate = $fileInfo.LastWriteTime			# get last write time of the file		
	$dateStr = $fileDate.ToString()				# convert to string to construct the new name		
	if ($log) { Write-Host "`n$filename last write time is $dateStr" }
	$dateAndTime = $dateStr.Substring(6,4) + "." + $dateStr.Substring(3,2) + "." + $dateStr.Substring(0,2) + " - " + $dateStr.Substring(11).Replace(":",".")
	Return $dateAndTime
}

function Rename-IfNotEqual([string]$oldname, [string]$newname, [bool]$log, [ref]$renamedCounter, [ref]$untouchedCounter)
{
	if ($oldname -cne $newname)		# case sensitive not equal
	{
		Rename-Item -Path $oldname -NewName $newname
		if ($log) { Write-Host "renamed file $oldname, new name: $newname`n" }
		$renamedCounter.Value = $renamedCounter.Value + 1
	}
	else
	{
		if ($log) { Write-Host "$oldname - name already correct`n" }
		$untouchedCounter.Value = $untouchedCounter.Value + 1
	}
}

function Read-YesNoQuestion([string]$prompt, [ref]$flag, [bool]$flip)
{
	do
	{
		$ans = Read-Host -Prompt ($prompt + " [y/n]?")
		if ($ans -ieq "y") { $flag.Value = ($true -xor $flip) }
		elseif ($ans -ieq "n") { $flag.Value = ($false -xor $flip) }
		else { Write-Host "Type a correct option!" }
	} while (($ans -ine "y") -and ($ans -ine "n"))
}

function Write-Borderline
{
	Write-Host "------------------------------------------------------------------------------------------------------"
}
#------------------------------------------FUNCTIONS-END------------------------------------------#
#------------------------------------------FUNCTIONS-END------------------------------------------#

Write-Host "File renaming script"
Write-Host "Renames all specified screenshots to `"GameName yyyy.mm.dd - hh.mm.ss.extension`" (last write date and time)`n"

$enableLogs = $true
Read-YesNoQuestion "`nEnable logs?" ([ref]$enableLogs) -flip $false

$screenshotsFolder = "D:\Images\My screenshots\"
Write-Host "`n`nFolder search path: $screenshotsFolder"
$extensions = ".png",".jpg"
Write-Host "`nFiles with the following extensions can be renamed: $extensions"

Set-Location $screenshotsFolder

$folders = Get-ChildItem -Directory -Name
Write-Host "`nFound subfolders:"
$counter = 1
ForEach ($folder in $folders)
{
	Write-Host "[$counter] $folder"
	$counter = $counter + 1  
}

$prompt = "`nEnter the folder numbers of folders you want to choose (enter comma separated values, example - `"1,2,3`")"
$indices = (Read-Host -Prompt $prompt).Split(",").ToInt32($null) | Sort-Object

Write-Host "`nYou chose to rename screenshots in following folders:"
ForEach ($index in $indices)
{
	Write-Host ("[$index] " + $folders[$index - 1])
}

$renameAll = $false		# permission flag
$prompt = "`nAsk confirmation for each folder?`n(BE CAREFUL: if you choose NOT to ask, all files will be renamed INSTANTLY!)"
Read-YesNoQuestion $prompt -flag ([ref]$renameAll) -flip $true 

ForEach ($folderIndex in $indices)
{
	Write-Host "`n`n"
	Write-Borderline
	
	$folder = $folders[$folderIndex - 1] 
	$renameAllInFolder = $renameAll		# permission flag
	if (-not ($renameAll))
	{
		$continueFlag = $false
		do
		{
			$prompt = "Rename all files in $folder folder? [y] - yes, [a] - ask for each extension, [n] - cancel"
			$ans = Read-Host -Prompt $prompt
			switch ($ans) 
			{
				"y" { $renameAllInFolder = $true }
				"a" { $renameAllInFolder = $false }
				"n" { $continueFlag = $true }
				Default { Write-Host "Type a correct option!" }
			}
		} while (($ans -ine "y") -and ($ans -ine "a") -and ($ans -ine "n"))

		if ($continueFlag)
		{
			Write-Host "Renaming in $folder folder canceled!"
			Write-Borderline
			continue	# go to the next iteration immediately
		}
	}

	Write-Host "Renaming files in $folder folder:"

	ForEach ($extension in $extensions)
	{
		$renameCurrExtension = $renameAllInFolder		# permission flag

		if ($renameAllInFolder -eq $false)
		{
			Read-YesNoQuestion "Rename all $extension files?" -flag ([ref]$renameCurrExtension) -flip $false
		}

		$renamedCounter = 0
		$untouchedCounter = 0

		if (($renameCurrExtension) -or ($renameAllInFolder) -or ($renameAll))
		{
			Write-Host "`nSearching for $extension files..."
			Set-Location $screenshotsFolder	
			$nameList = Get-ChildItem $folder -Name -Include *$extension

			if ($nameList.Length -eq 0) { Write-Host "No $extension files found" }
			else
			{
				Write-Host (($nameList.Length).ToString() + " $extension files found")
				Write-Host "Renaming..."
				Set-Location ($screenshotsFolder + $folder)
				ForEach ($filename in $nameList)
				{
					$dateAndTime = Get-FormattedDate $filename $enableLogs
					$newFilename = $folder + " " + $dateAndTime + $extension
					Rename-IfNotEqual $filename $newFilename $enableLogs ([ref]$renamedCounter) ([ref]$untouchedCounter) 
				}
			}
		}
		if ($renamedCounter + $untouchedCounter -ne 0)
		{
			Write-Host "$renamedCounter $extension files renamed, $untouchedCounter files left untouched"
		}
	}
	Write-Host "`nRenaming in $folder folder done!"
	Write-Borderline
}
Write-Host "`n`n`nALL DONE!`n"
Write-Host "Press ENTER to quit"
pause