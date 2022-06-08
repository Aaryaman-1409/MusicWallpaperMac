set appName to "Music"

if application appName is running then
	tell application "Music"
		try
			if player state is not stopped then
				set alb to (get album of current track)
				set imgData to (get data of artwork 1 of current track)
				return {imgData, alb}
			else
				return
			end if
		on error
			return
		end try
	end tell
else
	return 1
end if