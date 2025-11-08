extends Control

@onready var game_over_container: Control = $GameOver
@onready var restart_button: Button = $GameOver/CenterContainer/VBoxContainer/RestartButton

func _ready() -> void:
	add_to_group("ui")
	_hide_game_over()
	if is_instance_valid(restart_button) and not restart_button.is_connected("pressed", Callable(self, "_on_restart_pressed")):
		restart_button.pressed.connect(_on_restart_pressed)

func show_game_over() -> void:
	if is_instance_valid(game_over_container):
		game_over_container.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(restart_button):
		restart_button.grab_focus()
	print("Game Over shown!")

func _hide_game_over() -> void:
	if is_instance_valid(game_over_container):
		game_over_container.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
