on run argv
	
	set recipientName to "nobody"
	set recipientAddress to item 3 of argv
	set theSubject to "telegram proxy"
	set theContent to "tg://proxy?server=" & item 1 of argv & "&port=443&secret=" & item 2 of argv
	
	tell application "Mail"
		
		##Create the message
		set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent, visible:false}
		
		##Set a recipient
		tell theMessage
			make new to recipient with properties {name:recipientName, address:recipientAddress}
			
			##Send the Message
			send
			
		end tell
		
		quit
		
	end tell
	
end run