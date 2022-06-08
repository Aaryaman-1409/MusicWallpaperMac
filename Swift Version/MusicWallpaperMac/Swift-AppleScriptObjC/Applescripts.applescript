

script AppleScripts
	
	property parent : class "NSObject"
	
	to _isRunning() -- () -> NSNumber (Bool)
		-- AppleScript will automatically launch apps before sending Apple events;
		-- if that is undesirable, check the app object's `running` property first
        return running of application id "com.apple.Music"
	end _isRunning

	to _trackInfo() -- () -> NSString
		tell application id "com.apple.Music"
			try
				return album of current track
			on error number -1728 -- current track is not available
				return missing value -- nil
			end try
		end tell
	end trackInfo


    to _trackArtwork() -- ()
        tell application "Music"
            try
                set asdata to (get data of artwork 1 of current track)
                return my dataFromASData:asdata
            on error number -1728 -- current track is not available
                return missing value -- nil
            end try
        end tell
    end trackArtwork

    to setDesktop: theString
    set penis to theString as text
        tell application "System Events"
            set picture of current desktop to penis
        end tell
    end setDesktop2

-- converts applescript data to nsdata

on dataFromASData:asData
    return (current application's NSArray's arrayWithObject:asData)'s firstObject()'s |data|()
end dataFromASData:


end script
