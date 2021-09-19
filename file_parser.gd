extends Node


const DELIMITER := "_&_"
const FILE_PATH := "reminders_queue.dat"


func add_entry_to_file(reminder: Globals.Reminder) -> void:
	var file := File.new()
	if not file.file_exists(FILE_PATH):
		file.open(FILE_PATH, File.WRITE)
		file.close()
	file.open(FILE_PATH, File.READ_WRITE)
	file.seek_end()
	file.store_line(_prepare_line(reminder))
	file.close()



func extract_file() -> Array:
	var file := File.new()
	if not file.file_exists(FILE_PATH):
		return []
	file.open(FILE_PATH, File.READ)
	var lines := []
	while not file.eof_reached():
		lines.append(_parse_line(file.get_line()))
	file.close()
	return lines



func remove_lines(lines_index: Array) -> void:
	var file := File.new()
	if not file.file_exists(FILE_PATH):
		return
	file.open(FILE_PATH, File.READ_WRITE)
	var lines := []
	var i: int = 0
	while not file.eof_reached():
		var line := file.get_line()
		i += 1
		if lines_index.has(i - 1):
			continue
		lines.append(line)
	file.close()
	file.open(FILE_PATH, File.WRITE)
	for line in lines:
		file.store_line(line)
	file.close()



func _prepare_line(reminder: Globals.Reminder) -> String:
	var line := ""
	line += reminder.channel_id + DELIMITER
	line += reminder.user_id + DELIMITER
	line += String(reminder.remind_time) + DELIMITER
	line += reminder.remind_message.replace(DELIMITER, "").c_escape() + DELIMITER
	line += String(reminder.remind_mode)
	return line



func _parse_line(line: String) -> Dictionary:
	var splitted_line := line.split(DELIMITER)
	if splitted_line.size() != 5:
		return {}
	return {
			"channel_id": splitted_line[0],
			"user_id": splitted_line[1],
			"time": splitted_line[2],
			"remind_message": splitted_line[3].c_unescape(),
			"remind_mode": splitted_line[4]
			}



