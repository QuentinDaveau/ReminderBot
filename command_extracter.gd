extends Node


func handle_command_and_get_delay(tokens: Array) -> int:
	var args := _extract_args(_sanitize_tokens(tokens))
	var delay: int = $CommandParser.convert_args_to_delay(args)
	return delay



func _sanitize_tokens(tokens: Array) -> Array:
	for i in range(0, tokens.size()):
		if not tokens[i] is String:
			ErrorHandler.raise_error("Token " + tokens[i] + " is not a string !")
			continue
		tokens[i] = tokens[i].to_lower()
	return tokens



func _extract_args(tokens: Array) -> Array:
	var extracted_args := []

	for i in range(0, tokens.size()):
		if i == 0 and not _is_arg(tokens[i]):
			ErrorHandler.raise_error("First token { " + tokens[i] + " } isn't a command !")
			return []
		if _is_arg(tokens[i]):
			extracted_args.append(Globals.Argument.new(tokens[i]))
		else:
			if extracted_args.size() > 0:
				extracted_args[-1].add_property(tokens[i])
			else:
				ErrorHandler.raise_error("Tried to add property to nonexistent command !")
	
	return extracted_args



func _is_arg(token: String) -> bool:
	return Globals.ARGUMENTS.keys().has(token)



