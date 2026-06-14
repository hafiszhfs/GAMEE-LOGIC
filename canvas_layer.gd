extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var hp_label: Label = $HPLabel
@onready var level_label: Label = $LevelLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var levelup_label: Label = $LevelUpEffect

var player_stats: PlayerStats

func _ready():
	levelup_label.visible = false
	await get_tree().process_frame
	_connect_to_player()

func _connect_to_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_stats = player.get_node("PlayerStats")
		player_stats.connect("hp_changed", _on_hp_changed)
		player_stats.connect("xp_changed", _on_xp_changed)
		player_stats.connect("level_up", _on_level_up)
		
		# Inisialisasi tampilan awal
		_on_hp_changed(player_stats.current_hp, player_stats.max_hp)
		_on_xp_changed(player_stats.current_xp, player_stats.xp_to_next_level)
		_on_level_up(player_stats.level)
	else:
		print("ERROR: Player tidak ditemukan! Pastikan player ada di group 'player'")

func _on_hp_changed(current: int, maximum: int):
	health_bar.max_value = maximum
	health_bar.value = current
	hp_label.text = "%d / %d" % [current, maximum]
	
	if current < maximum * 0.3:
		health_bar.modulate = Color.RED
	elif current < maximum * 0.6:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.GREEN

func _on_xp_changed(current: int, needed: int):
	xp_bar.max_value = needed
	xp_bar.value = current

func _on_level_up(new_level: int):
	level_label.text = "LV %d" % new_level
	_show_levelup_effect()

func _show_levelup_effect():
	levelup_label.text = "LEVEL UP!"
	levelup_label.visible = true
	levelup_label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(levelup_label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(func(): levelup_label.visible = false)
	
