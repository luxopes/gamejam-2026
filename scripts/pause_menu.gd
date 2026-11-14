extends CanvasLayer
## Pauza: Esc zastaví hru a ukáže menu (Resume / Quit to title), Esc znovu pokračuje.
## Uzel běží i při pauze (process_mode = Always), zbytek hry stojí.

const TITLE := "res://scenes/title.tscn"


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_set_paused(not get_tree().paused)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	visible = paused
	if paused:
		$Box/Resume.grab_focus()


func _on_resume_pressed() -> void:
	_set_paused(false)


func _on_title_pressed() -> void:
	_set_paused(false)
	get_tree().change_scene_to_file(TITLE)
