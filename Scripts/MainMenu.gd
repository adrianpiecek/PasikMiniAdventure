extends Control

@onready var ContinueButton = $VBoxContainer/ContinueButton
@onready var newGameButton = $VBoxContainer/NewGameButton
@onready var QuitButton = $VBoxContainer/QuitButton

func _ready():
	update_continue_button()

func update_continue_button():
	var save_path = get_save_path()
	ContinueButton.disabled = not FileAccess.file_exists(save_path)

func get_save_path() -> String:
	var documents_dir = OS.get_user_data_dir()
	var save_folder = documents_dir.path_join("PasikAdventure2")
	
	if not DirAccess.dir_exists_absolute(save_folder):
		DirAccess.make_dir_recursive_absolute(save_folder)
	
	return save_folder.path_join("savegame.save")

func _on_new_game_button_pressed():
	# Tworzy nowy zapis
	var save_path = get_save_path()
	#print(save_path)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var save_data = {
		"unlocked_levels": 1 # Na starcie odblokowany tylko poziom 1
	}
	file.store_string(JSON.stringify(save_data))
	file.close()

	# Animacja przejścia i załadowanie wyboru poziomu
	Global.transition_diamond.play_transition(Callable(self, "_start_level_select"))

func _on_continue_button_pressed():
	Global.transition_diamond.play_transition(Callable(self, "_start_level_select"))

func _on_quit_button_pressed():
	get_tree().quit()

func _start_level_select():
	get_tree().change_scene_to_file("res://Scenes/Menu/level_select.tscn")
