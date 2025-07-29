extends Control

const SAVE_PATH = "user://savegame.save"

var unlocked_levels = 1
var level_paths = [
	"res://Scenes/levels/level_1.tscn",
	"res://Scenes/levels/level_2.tscn"
]

@onready var grid = $MarginContainer/GridContainer

func _ready():
	_load_save()
	_setup_level_buttons()

func _load_save():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data and data.has("unlocked_levels"):
			unlocked_levels = int(data["unlocked_levels"])
		file.close()

func _setup_level_buttons():
	for i in range(level_paths.size()):
		var button = TextureButton.new()
		#"res://Assets/Sprites/Menu/Levels/"
		var level_num = i + 1
		button.texture_normal = load("res://Assets/Sprites/Menu/Levels/%d.png" % level_num)  # twoje numerki
		
		if level_num > unlocked_levels:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 1)  # przyciemniamy zablokowane

		button.connect("pressed", Callable(self, "_on_level_pressed").bind(i))
		grid.add_child(button)

func _on_level_pressed(level_index):
	Global.transition_diamond.play_transition(Callable(self, "_start_level").bind(level_paths[level_index]))

func _start_level(level_path):
	get_tree().change_scene_to_file(level_path)
