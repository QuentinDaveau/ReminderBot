extends Node

signal send_message(channel, message, user, message_mode)



func _ready() -> void:
	$TimeChecker.connect("timeout", self, "_on_TimeChecker_timeout")



func add_to_queue(reminder: Globals.Reminder) -> void:
	$FileParser.add_entry_to_file(reminder)



func _on_TimeChecker_timeout() -> void:
	var lines_to_remove := []
	var entries: Array = $FileParser.extract_file()
	for i in range(entries.size()):
		if entries[i].empty():
			lines_to_remove.append(i)
			continue
		if int(entries[i]["time"]) < OS.get_unix_time():
			emit_signal("send_message", entries[i]["channel_id"], entries[i]["remind_message"], entries[i]["user_id"], int(entries[i]["remind_mode"]))
			lines_to_remove.append(i)
	if not lines_to_remove.empty():
		$FileParser.remove_lines(lines_to_remove)
