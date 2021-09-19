extends Node

const BOT_PREFIX := "!remind"

var BOT: DiscordBot
var _last_message: Message

func _ready():
	ErrorHandler.connect("error_risen", self, "_on_error_risen")
	$TimerQueue.connect("send_message", self, "_send_remind_message")
	BOT = $DiscordBot
	BOT.connect("message_create", self, "_on_DiscordBot_message_create")
	BOT.TOKEN = ""
	BOT.login()




func _on_DiscordBot_bot_ready(bot: DiscordBot):
	print('Logged in as ' + bot.user.username + '#' + bot.user.discriminator)
	print('Listening on ' + str(bot.channels.size()) + ' channels and ' + str(bot.guilds.size()) + ' guilds.')
	bot.set_presence({
		"status": "ONLINE",
		"afk": false,
		"activity": {
			"type": "WATCHING",
			"Name": "For Godot"
			}
		})



func _on_DiscordBot_message_create(bot: DiscordBot, message: Message, channel: Dictionary) -> void:
	if message.author.bot:
		return
	
	if not message.content:
		return
	
	if not message.content.begins_with(BOT_PREFIX):
		return
	
	_last_message = message
	ErrorHandler.reset_state()
	_manage_content(bot, message)



func _on_error_risen(reply: String) -> void:
	if _last_message:
		var reply_with_message := reply + "\n\nReceived command: \"" + _last_message.content + "\""
		_reply_message(BOT, _last_message, reply_with_message)



func _manage_content(bot: DiscordBot, message: Message) -> void:
	# Cleaning content and separating actual message from tokens
	var raw_content := _trim_bot_prefix(message.content.to_lower())
	var splitted_content := raw_content.split(" to ", true, 1)
	
	var tokens := []
	var regex := RegEx.new()
	
	regex.compile("\\S+")
	
	for token in regex.search_all(splitted_content[0]):
		tokens.append(token.get_string().to_lower())
	
	if splitted_content.size() == 2:
		var delay_to_wait: int = $CommandExtracter.handle_command_and_get_delay(tokens)
		if ErrorHandler.error_raised():
			return
		$TimerQueue.add_to_queue(Globals.Reminder.new(message, delay_to_wait + OS.get_unix_time(), splitted_content[1], _get_remind_mode(message.content)))
		_send_success_reply_to_user(bot, message, delay_to_wait, splitted_content[1])
	elif tokens.has("help"):
		_send_help_reply(bot, message)
	else:
		ErrorHandler.raise_error("Missing either parameters or message for command: " + raw_content)
	_delete_message(bot, message)



func _delete_message(bot: DiscordBot, message: Message) -> void:
	bot.delete(message)



func _send_help_reply(bot: DiscordBot, message: Message) -> void:
	var reply := """
Remind format: ![remind/remindall/remindraw] [args] to [message to remind]

Examples:
!remind tomorrow morning to make a sandwich
!remindall in six hours 05m40sec to leave early
!remindraw next sunday at 14h to Hey guys, this is a delayed message !
!remind this afternoon to do something

Feel free to try different combinations to see what works !
"""
	
	_reply_message(bot, message, reply)



func _send_success_reply_to_user(bot: DiscordBot, message: Message, calcutated_delay: int, remind_message: String) -> void:
	var reply := "Understood! You will be reminded in [" + _convert_time_to_text(calcutated_delay) + "] to:\n" + remind_message
	_reply_message(bot, message, reply)



func _reply_message(bot: DiscordBot, message: Message, text: String) -> void:
	bot.send_dm(message.author.id, text)



func _send_remind_message(channel_id: String, message: String, user: String, remind_mode: int) -> void:
	var message_to_send := ""
	match remind_mode:
		Globals.REMIND_MODE.USER:
			BOT.send_dm(user, "Hey there <@!" + user + ">, remember to " + message)
		Globals.REMIND_MODE.EVERYONE:
			BOT.send(channel_id, "Hey there @everyone, remember to " + message)
		Globals.REMIND_MODE.RAW:
			BOT.send(channel_id, message)



func _get_remind_mode(command: String) -> int:
	if command.begins_with("!remindraw"):
		return Globals.REMIND_MODE.RAW
	if command.begins_with("!remindall"):
		return Globals.REMIND_MODE.EVERYONE
	return Globals.REMIND_MODE.USER



func _trim_bot_prefix(command: String) -> String:
	if command.begins_with("!remindraw"):
		return command.trim_prefix("!remindraw")
	if command.begins_with("!remindall"):
		return command.trim_prefix("!remindall")
	return command.trim_prefix("!remind")



func _convert_time_to_text(time: int) -> String:
	var answer := ""
	if time / 86400 > 0: answer += "%02d day " % [time / 86400]
	if time % 86400 / 3600 > 0: answer += "%02d hour " % [time % 86400 / 3600]
	if time % 3600 / 60 > 0: answer += "%02d min " % [time % 3600 / 60]
	if time % 60 > 0: answer += "%02d sec" % [time % 60]
	return answer.lstrip(" ").rstrip(" ")
