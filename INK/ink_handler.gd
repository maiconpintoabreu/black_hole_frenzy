extends Control
class_name INK_Handler
signal change_path(knot:String)

@onready var _ink_player:InkPlayer = InkPlayer.new()
@onready var dialog_area: TextureRect = $DialogArea
@onready var dialog_text:RichTextLabel = $DialogArea/DialogText
@onready var dialog_timer: Timer = $DialogTimer
@onready var dialog_letters_timer:Timer = $DialogLettersTimer

@onready var dialog_skip: Button = $DialogArea/DialogSkip
@onready var dialog_next:Button = $DialogArea/DialogNext
const STORES_INK = preload("res://INK/story.json")
var current_broken_text:PackedStringArray
var current_text:String
var has_text_to_load:bool = false
var is_pending_choice:bool = false
var knot_visited:Array[String] = []
@onready var canvas_layer: CanvasLayer = $".."

func _ready()->void:
	add_child(_ink_player)
	clear_dialog()

	var resource:InkResource = InkResource.new()
	resource.json = JSON.stringify(STORES_INK.data)
	_ink_player.ink_file = resource
	_ink_player.loaded.connect(_story_loaded)
	_ink_player.create_story()
	change_path.connect(divert)

func load_json_file(file_path: String)->Resource:
	if FileAccess.file_exists(file_path):
		var file:FileAccess = FileAccess.open(file_path, FileAccess.READ)
		var raw_json:String = file.get_as_text()

		var test_json_conv:JSON = JSON.new()
		test_json_conv.parse(raw_json)

		var resource:InkResource = InkResource.new()
		resource.json = raw_json
		return resource
	else:
		print("ink file do not exists")
		return

func _process(_delta:float)->void:
	if is_pending_choice and (dialog_skip.visible or dialog_next.visible):
		dialog_skip.hide()
		dialog_next.hide()
	elif not dialog_skip.visible and not is_pending_choice and current_broken_text.size() > 0:
		dialog_skip.show()
		dialog_next.hide()
	elif not dialog_next.visible and not is_pending_choice and current_broken_text.size() == 0:
		dialog_skip.hide()
		dialog_next.show()

func _story_loaded(successfully:bool)->void:
	if not successfully: return
	_continue_story()

func divert(knot:String)->void:
	if not knot_visited.has(knot):
		_ink_player.choose_path(knot)
		print(str("changing path to: ",knot))
		_continue_story()
		knot_visited.push_back(knot)

func _continue_story()->void:
	if _ink_player.can_continue:
		dialog_letters_timer.start()
		var text:String = _ink_player.continue_story()
		clear_dialog()
		if text.is_empty(): 
			end_dialog()
			return
		dialog_area.show()
		if _ink_player.current_tags.size()>0:
			var current_speaker:String = ""
			var current_feeling:String = ""
			for current_tag:String in _ink_player.current_tags:
				if current_tag.contains("speaker: "):
					current_speaker = current_tag.replace("speaker: ","")
				if current_tag.contains("feeling: "):
					current_feeling = current_tag.replace("feeling: ","")

			var speaker:String = current_speaker
			if speaker == "Player": speaker = "Alexander Godoph"
			if not current_feeling.is_empty():
				speaker += str(" (",current_feeling,")")
			
		current_broken_text = text.split("")
		current_text = text
		has_text_to_load = true
	else:
		end_dialog()

func _select_choice(index:int)->void:
	_ink_player.choose_choice_index(index)
	is_pending_choice = false
	_continue_story()

func end_dialog()->void:
	dialog_letters_timer.stop()
	dialog_area.hide()
	canvas_layer.hide()
	
func clear_dialog()->void:
	is_pending_choice = false
	current_text = ""
	current_broken_text.clear()
	dialog_text.clear()
	dialog_timer.stop()


func _on_dialog_timer_timeout()->void:
	if _ink_player.has_choices and not is_pending_choice:
		is_pending_choice = true
		for choice:InkChoice in _ink_player.current_choices:
			dialog_text.append_text(make_bbcode(choice))
		return
	if not _ink_player.can_continue:
		end_dialog()
	else:
		_continue_story()


func _on_dialog_area_gui_input(event: InputEvent)->void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if current_broken_text.size() >= 0 and _ink_player.has_choices:
				return 
			if is_pending_choice: return
			if check_for_choices(): return
			_continue_story()

func make_bbcode(choice:InkChoice)->String:
	return str('[left][color=green]- [url=',choice.index,']',choice.text,'[/url][/color][/left]')
	
func check_for_choices()->bool:
	if _ink_player.has_choices:
		is_pending_choice = true
		for choice:InkChoice in _ink_player.current_choices:
			dialog_text.append_text(make_bbcode(choice))
	return is_pending_choice

func _on_dialog_letters_timer_timeout()->void:
	if not has_text_to_load: return
	if load_choices():
		return
	dialog_text.add_text(current_broken_text[0])
	current_broken_text.remove_at(0)
func load_choices()->bool:
	if current_broken_text.size() == 0:
		if not check_for_choices():
			dialog_timer.start()
		has_text_to_load = false
		return true
	return false

func _on_dialog_text_meta_clicked(meta:String)->void:
	_select_choice(int(meta))

func _on_dialog_skip_pressed()->void:
	if current_broken_text.size() > 0:
		dialog_text.text = current_text
		current_broken_text.clear()
		load_choices()
		print("Skipping the letter writing")
		dialog_letters_timer.stop()
		dialog_timer.stop()
		return 
	if _ink_player.has_choices:
		return
	if is_pending_choice: return
	if check_for_choices(): return
	_continue_story()

func _on_dialog_area_visibility_changed()->void:
	if not dialog_area:
		get_tree().paused = false
		return
	if not dialog_area.visible:
		get_tree().paused = false
	else:
		get_tree().paused = true
