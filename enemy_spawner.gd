extends Node2D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 5
@export var spawn_interval: float = 5.0
@export var spawn_radius: float = 300.0

var spawn_timer: float = 0.0
var current_enemies: int = 0


func _ready():
	for i in range(5):
		_spawn_enemy()


func _process(delta: float):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		if current_enemies < max_enemies:
			_spawn_enemy()


func _spawn_enemy():
	if enemy_scene == null:
		print("ERROR: enemy_scene belum diset!")
		return

	var enemy = enemy_scene.instantiate()
	var random_offset = Vector2(randf_range(-spawn_radius, spawn_radius), 0)
	enemy.global_position = global_position + random_offset

	enemy.tree_exited.connect(_on_enemy_died)
	current_enemies += 1

	get_parent().add_child(enemy)

	enemy.modulate.a = 0.0
	var tween = enemy.create_tween()
	tween.tween_property(enemy, "modulate:a", 1.0, 0.5)


func _on_enemy_died():
	current_enemies -= 1
