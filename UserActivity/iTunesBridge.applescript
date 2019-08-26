

script iTunesBridge
	
	property parent : class "NSObject"
	
	
	to whoami() -- () -> NSNumber (Bool)
		-- AppleScript will automatically launch apps before sending Apple events;
		-- if that is undesirable, check the app object's `running` property first
		set output to do shell script "whoami"
        return output
	end whoami

    to display() -- () -> NSNumber (Bool)
        set output to do shell script "ps aux"
        return output
    end whoami


	
end script
