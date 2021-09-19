extends Node


signal error_risen(reply)

enum ERROR_STATES {NONE, ERROR, WARNING}

var _state: int = ERROR_STATES.NONE


func raise_error(error_message: String) -> void:
	if _state != ERROR_STATES.ERROR:
		_state = ERROR_STATES.ERROR
		emit_signal("error_risen", error_message + "   ---   To see how to use the bot, type '!remind help'")
	push_error(error_message)



func reset_state() -> void:
	_state = ERROR_STATES.NONE



func error_raised() -> bool:
	return _state == ERROR_STATES.ERROR 
