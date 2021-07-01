# Screenshot renaming script
PowerShell script I use to rename my screenshots to my preferred format: "<game's name> <yyyy.mm.dd> - <hh.mm.ss>.<png/jpg>"

I have a folder named "My screenshots" on my PC which contains a bunch of other folders with TONS screenshots in them, something like this:

     My screenshots---┐
                      ├--->Game1---> { screenshot1.png, ..., screenshotN.png }
                      |--->Game2---> { screenshot1.png, ..., screenshotN.png }
                      |--->.....---> { ... }
                      └--->GameN---> { screenshot1.png, ..., screenshotN.png }

I couldn't possibly rename them manually, so I wrote this script. To use it with your PC, change the $screenshotsFolder variable to your directory's location (don't forget the backslash at the end, it's MANDATORY), and it should work OK.
