extends Node



enum TIME_OPERAND {SECOND, MINUTE, HOUR, DAY, WEEK}


const OPERAND_SEC_MULT := [1, 60, 3600, 86400, 604800]


const OPERANDS_STRINGS := {
	TIME_OPERAND.SECOND: ["s", "sec", "second", "seconds"],
	TIME_OPERAND.MINUTE: ["m", "min", "minute", "minutes"],
	TIME_OPERAND.HOUR: ["h", "hr", "hour", "hours"],
	TIME_OPERAND.DAY: ["d", "day", "days"],
	TIME_OPERAND.WEEK: ["w", "week", "weeks"],
}


const TIME_STRING_EQUIVALENT := {
	"morning": 8,
	"noon": 12,
	"afternoon": 16,
	"evening": 19
}


const RELATIVE_DAY_EQUIVALENT := {
	"this": 0,
	"today": 0,
	"tomorrow": 24
}


const WEEKDAYS := {
	"sunday": 0,
	"monday": 1,
	"tuesday": 2,
	"wednesday": 3,
	"thursday": 4,
	"friday": 5,
	"saturday": 6,
}


onready var _numbers_name_converter = Globals.NumbersName.new()




func extract_time_from_argument(arg: Globals.Argument) -> int:
	var time_sec: int = 0
	match arg.property_type:
		Globals.ARG_PROPERTY.DAY:
			time_sec += _get_delay_from_day(arg.get_properties())
		Globals.ARG_PROPERTY.HOUR:
			time_sec += _get_delay_from_hour(arg.get_properties())
		Globals.ARG_PROPERTY.SELFDEFINED:
			time_sec += _get_delay_from_tod(arg.name)
		Globals.ARG_PROPERTY.DURATION:
			time_sec += _get_delay_from_hour(arg.get_properties())
			time_sec += _get_seconds_from_start_of_day()
		Globals.ARG_PROPERTY.NONE:
			time_sec += _get_delay_from_relative_day(arg.name)
	return time_sec



func remove_start_of_day(time: int) -> int:
	return time - _get_seconds_from_start_of_day()



func _get_delay_from_day(properties: Array) -> int:
	if properties.size() > 1:
		ErrorHandler.raise_error("Too many properties for day extraction !")
		return 0
	if not WEEKDAYS.has(properties[0].to_lower()):
		ErrorHandler.raise_error("Expected day name, got " + properties[0].to_lower())
		return 0
	var target_day: int = WEEKDAYS.get(properties[0])
	var current_day: int = OS.get_datetime().get("weekday")
	var days_time_to_wait: int = 0
	if current_day < target_day:
		days_time_to_wait = target_day - current_day
	else:
		days_time_to_wait = target_day + (7 - current_day)
	return days_time_to_wait * 86400



func _get_delay_from_tod(time_of_day: String) -> int:
	if not TIME_STRING_EQUIVALENT.has(time_of_day):
		ErrorHandler.raise_error("Unrecognized time of day: " + time_of_day)
	return TIME_STRING_EQUIVALENT.get(time_of_day) * 3600



func _get_delay_from_hour(properties: Array) -> int:
	# Clumping properties together for regex extraction
	var properties_string := ""
	for property in properties:
		if property == "and":
			continue
		properties_string += " " + property.to_lower()
	
	# Regex extraction
	var regex := RegEx.new()
	regex.compile("(?<text>[a-z-:]+)|(?<digits>\\d+)")
	
	# Evaluating extracted values
	var times := {}
	var preceding_value: String
	var previous_operand: int = -1
	
	for token in regex.search_all(properties_string):
		if token.names.has("digits"):
			preceding_value = token.get_string()
		elif token.names.has("text"):
			var converted_name = _numbers_name_converter.get_number(token.get_string())
			if converted_name != -1:
				preceding_value = String(converted_name)
				continue
			if not preceding_value:
				ErrorHandler.raise_error("Invalid time format or unrecognized value: " + token.get_string())
				return 0
			var time_operand = _match_time_operand(token.get_string())
			if times.has(time_operand):
				ErrorHandler.raise_error("Time operand repeated: " + token.get_string())
			times[time_operand] = _sanitize_time_value(int(preceding_value), time_operand)
			preceding_value = ""
			previous_operand = time_operand
	
	# If the last time operand is not given
	if preceding_value:
		if previous_operand > 0:
			times[previous_operand - 1] = _sanitize_time_value(int(preceding_value), previous_operand - 1)
	return _convert_dict_to_time(times)



func _get_delay_from_relative_day(relative_day: String) -> int:
	if not RELATIVE_DAY_EQUIVALENT.has(relative_day):
		ErrorHandler.raise_error("Unrecognized relative day: " + relative_day)
	return RELATIVE_DAY_EQUIVALENT.get(relative_day) * 3600



func _convert_dict_to_time(times_dict: Dictionary) -> int:
	var time_sec: int = 0
	for key in times_dict.keys():
		time_sec += times_dict[key] * OPERAND_SEC_MULT[key]
	return time_sec



func _get_seconds_from_start_of_day() -> int:
	var time: Dictionary = OS.get_datetime()
	return (time["hour"] * 3600) + (time["minute"] * 60) + time["second"]



func _match_time_operand(operand: String) -> int:
	if OPERANDS_STRINGS[TIME_OPERAND.SECOND].has(operand): 
		return TIME_OPERAND.SECOND
	if OPERANDS_STRINGS[TIME_OPERAND.MINUTE].has(operand): 
		return TIME_OPERAND.MINUTE
	if OPERANDS_STRINGS[TIME_OPERAND.HOUR].has(operand) or operand == ":": 
		return TIME_OPERAND.HOUR
	if OPERANDS_STRINGS[TIME_OPERAND.DAY].has(operand): 
		return TIME_OPERAND.DAY
	if OPERANDS_STRINGS[TIME_OPERAND.WEEK].has(operand): 
		return TIME_OPERAND.WEEK
	ErrorHandler.raise_error("No corresponding time operand found for : " + operand)
	return -1



func _sanitize_time_value(time_value: int, time_operand: int) -> int:
	match time_operand:
		TIME_OPERAND.SECOND, TIME_OPERAND.MINUTE:
			return int(clamp(time_value, 0, 59))
		TIME_OPERAND.HOUR:
			return int(clamp(time_value, 0, 23))
		TIME_OPERAND.DAY:
			return int(clamp(time_value, 0, 30))
	ErrorHandler.raise_error("No corresponding time operand found for : " + String(time_operand))
	return -1
