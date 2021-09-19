extends Node


enum EXPECTED_NEXT {NONE, OPTIONAL, TIME}
enum ARG_PROPERTY {DATE, HOUR, DAY, DURATION, SELFDEFINED, NONE}
enum ARG_TYPE {SETTER, ADDER}
enum REMIND_MODE {RAW, USER, EVERYONE}


const ARGUMENTS := {
#	"the": {"expected": EXPECTED_NEXT.OPTIONAL, "property": ARG_PROPERTY.DATE, "type": ARG_TYPE.SETTER, "can_init": true}, // UNSUPPORTED FOR NOW
	"on": {"expected": EXPECTED_NEXT.OPTIONAL, "property": ARG_PROPERTY.DAY, "type": ARG_TYPE.SETTER, "can_init": true},
	"next": {"expected": EXPECTED_NEXT.OPTIONAL, "property": ARG_PROPERTY.DAY, "type": ARG_TYPE.SETTER, "can_init": true},
	"today": {"expected": EXPECTED_NEXT.OPTIONAL, "property": ARG_PROPERTY.NONE, "type": ARG_TYPE.SETTER, "can_init": true},
	"tomorrow": {"expected": EXPECTED_NEXT.OPTIONAL, "property": ARG_PROPERTY.NONE, "type": ARG_TYPE.SETTER, "can_init": true},
	"at": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.HOUR, "type": ARG_TYPE.SETTER, "can_init": true},
	"this": {"expected": EXPECTED_NEXT.TIME, "property": ARG_PROPERTY.NONE, "type": ARG_TYPE.SETTER, "can_init": true},
	"in": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.DURATION, "type": ARG_TYPE.ADDER, "can_init": true},
	"morning": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.SELFDEFINED, "type": ARG_TYPE.SETTER, "can_init": false},
	"noon": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.SELFDEFINED, "type": ARG_TYPE.SETTER, "can_init": false},
	"afternoon": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.SELFDEFINED, "type": ARG_TYPE.SETTER, "can_init": false},
	"evening": {"expected": EXPECTED_NEXT.NONE, "property": ARG_PROPERTY.SELFDEFINED, "type": ARG_TYPE.SETTER, "can_init": false}
}



class Argument:
	
	var name: String
	var expected_next: int
	var property_type: int
	var can_init: bool
	
	var _properties := []
	
	
	
	func _init(name: String) -> void:
		if not ARGUMENTS.has(name):
			ErrorHandler.raise_error("Incorrect argument name: " + name)
		
		self.name = name
		self.expected_next = ARGUMENTS.get(name).get("expected")
		self.property_type = ARGUMENTS.get(name).get("property")
		self.can_init = ARGUMENTS.get(name).get("can_init")
	
	
	
	func add_property(property: String) -> void:
		_properties.append(property)
	
	
	
	func get_properties() -> Array:
		return _properties
	
	
	
	func has_properties() -> bool:
		return _properties.size() > 0



# Simple container class
class Reminder:
	
	var user_id := ""
	var channel_id := ""
	var remind_time := 0
	var remind_message := ""
	var remind_mode := 0
	
	func _init(message: Message, delay: int, remind_message: String, remind_mode: int) -> void:
		self.user_id = message.author.id
		self.channel_id = message.channel_id
		self.remind_time = delay
		self.remind_message = remind_message
		self.remind_mode = remind_mode




class NumbersName:
	
	const numbers := {
		"zero": 0,
		"one": 1,
		"two": 2,
		"three": 3,
		"four": 4,
		"five": 5,
		"six": 6,
		"seven": 7,
		"eight": 8,
		"nine": 9,
		"ten": 10,
		"eleven": 11,
		"twelve": 12,
		"thirteen": 13,
		"fourteen": 14,
		"fifteen": 15,
		"sisteen": 16,
		"seventeen": 17,
		"eighteen": 18,
		"nineteen": 19,
		"twenty": 20,
		"thirty": 30,
		"fourty": 40,
		"fifty": 50,
		"sixty": 60,
		"seventy": 70,
		"eighty": 80,
		"ninety": 90
	}
	
	func get_number(number_name: String) -> int:
		number_name = number_name.to_lower()
		if numbers.has(number_name):
			return numbers.get(number_name)
		var regex := RegEx.new()
		regex.compile("([a-z]+)-([a-z]+)")
		var token := regex.search(number_name)
		if token and numbers.has(token.get_string(1)) and numbers.has(token.get_string(2)):
			return numbers.get(token.get_string(1)) + numbers.get(token.get_string(2))
		return -1


