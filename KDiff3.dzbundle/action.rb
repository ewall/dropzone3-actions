# Dropzone Action Info
# Name: KDiff3
# Description: Drag 2 or 3 files or folders to diff them with KDiff3. Hold a modifier key (⌘, ⌥, ⌃, or ⇧) while dragging to merge the items.
# Creator: Eric W. Wallace
# URL: http://www.ewall.org/dev/dropzone
# Handles: Files
# Events: Clicked, Dragged
# KeyModifiers: Command, Option, Control, Shift
# OptionsNIB: ChooseApplication
# SkipConfig: Yes
# SkipValidation: Yes
# RunsSandboxed: Yes
# UniqueID: 1033
# Version: 1.0.1
# MinDropzoneVersion: 3.2.3

def findApp
	if !ENV['path'].nil? 
		if FileTest.file?(ENV['path']) && FileTest.executable?(ENV['path'])
			# we have a valid saved path
			app = ENV['path']
		else
            app = "#{ENV['path']}/Contents/MacOS/kdiff3" # actual executable inside the kdiff3.app package
			unless FileTest.file?(app) && FileTest.executable?(app)
				$dz.fail('Cannot find KDiff3 at given location; please choose the correct path in the User Action configuration.')
			end
			$dz.save_value('path', app) # update saved value
		end

	else
		# no configured path, try default location to start
		app = '/Applications/kdiff3.app/Contents/MacOS/kdiff3XXXXXXXX'

		unless FileTest.file?(app) && FileTest.executable?(app)
				# no saved path, so prompt for it
				output = $dz.cocoa_dialog('fileselect --title "Locate the KDiff3 App" --informative-text "Please browse to the KDiff3 app:" --with-directory /Applications --select-directories ‑‑with‑extensions .app')
				apppkg = output.strip
				$dz.fail("Cancelled") if apppkg == ''
                
				app = "#{apppkg}/Contents/MacOS/kdiff3" # actual exe inside the app package
				unless FileTest.file?(app) && FileTest.executable?(app)
					$dz.fail('Cannot find KDiff3 at given location; please choose the correct path in the User Action configuration.')
				end
				$dz.save_value('path', app) # save the new path
		end

	end
	return app
end

def dragged
	$dz.begin("Opening KDiff3...")

	if $items.size < 2
		$dz.fail "KDiff3 can compare 2 or 3 items, whether files or folders. Have you considered stashing the itmes in the Drop Bar, then dragging them onto the action as group?"
		exit
	elsif $items.size > 3
		$dz.finish "Sorry, but KDiff3 can only compare no more than 3 items (files or folders)."
	end

	if !ENV['KEY_MODIFIERS'].nil?
		$items.push('-m') # add flag to merge
	end

	result = system(findApp(), *$items)
    #$dz.fail("Error executing KDiff3") if result > 0 #skip error check due to Mavericks' "modalSession has been exited prematurely" bug on KDiff3 and other apps
	$dz.url(false)
end

def clicked
	$dz.begin("Opening KDiff3...")

	result = system(findApp())
    #$dz.fail("Error executing KDiff3") if result > 0  #skip error check due to Mavericks' "modalSession has been exited prematurely" bug on KDiff3 and other apps
	$dz.url(false)
end