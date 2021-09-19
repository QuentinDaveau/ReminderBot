extends Node


var _success := false



func convert_args_to_delay(args: Array) -> int:
	var delay := 0
	var previous_arg: Globals.Argument = null
	
	for arg in args:
		if not _can_have_properties(arg) and arg.has_properties():
			ErrorHandler.raise_error("Argument { " + arg.name + " } has properties while it cannot !")
			break
		if previous_arg:
			if not _is_open(previous_arg):
				ErrorHandler.raise_error("Argument { " + arg.name + " } given after closing argument !")
				break
			if not _is_compatible_with_previous(arg, previous_arg):
				ErrorHandler.raise_error("Argument { " + arg.name + " } incompatible with previous argument { " + previous_arg.name + " } !")
				break
		else:
			if not arg.can_init:
				ErrorHandler.raise_error("First argument { " + arg.name + " } cannot initialize command chain !")
				break
		
		previous_arg = arg
		delay += $TimeConverter.extract_time_from_argument(arg)
	
	delay = $TimeConverter.remove_start_of_day(delay)
	if delay <= 0:
		ErrorHandler.raise_error("The given time has already passed !")
	return delay



func is_successful() -> bool:
	return _success



func _is_open(arg: Globals.Argument) -> bool:
	return arg.expected_next != Globals.EXPECTED_NEXT.NONE



func _is_compatible_with_previous(arg: Globals.Argument, prev_arg: Globals.Argument) -> bool:
	match prev_arg.expected_next:
		Globals.EXPECTED_NEXT.OPTIONAL:
			if arg.property_type == Globals.ARG_PROPERTY.HOUR or arg.property_type == Globals.ARG_PROPERTY.SELFDEFINED:
				return true
		Globals.EXPECTED_NEXT.TIME:
			if arg.property_type == Globals.ARG_PROPERTY.SELFDEFINED:
				return true
	return false



func _can_have_properties(arg: Globals.Argument) -> bool:
	return arg.property_type != Globals.ARG_PROPERTY.NONE
