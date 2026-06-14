# PlayerStats.gd
# Attach ke Node "PlayerStats" sebagai child dari Player

extends Node

class_name PlayerStats

signal level_up(new_level)
signal xp_changed(current_xp, xp_needed)
signal hp_changed(current_hp, max_hp)
signal player_died

# === LEVEL & XP ===
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100  # XP yang dibutuhkan untuk naik level

# === HP ===
var max_hp: int = 100
var current_hp: int = 100

# === STATS PER LEVEL ===
var base_damage: int = 10
var defense: int = 5


func _ready():
	current_hp = max_hp


# ─── XP & LEVELING ────────────────────────────────────────────────────────────

func gain_xp(amount: int):
	current_xp += amount
	emit_signal("xp_changed", current_xp, xp_to_next_level)
	
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		_level_up()


func _level_up():
	level += 1
	xp_to_next_level = int(xp_to_next_level * 1.5)  # Semakin banyak XP dibutuhkan tiap level
	
	# Naikin stats tiap level
	max_hp += 20
	current_hp = max_hp  # Heal full saat naik level
	base_damage += 5
	defense += 2
	
	emit_signal("level_up", level)
	emit_signal("hp_changed", current_hp, max_hp)
	print("Level Up! Sekarang Level ", level)


func get_level() -> int:
	return level


# ─── HP & DAMAGE ──────────────────────────────────────────────────────────────

func take_damage(raw_damage: int):
	var actual_damage = max(1, raw_damage - defense)  # Minimal 1 damage
	current_hp -= actual_damage
	current_hp = clamp(current_hp, 0, max_hp)
	
	emit_signal("hp_changed", current_hp, max_hp)
	
	if current_hp <= 0:
		emit_signal("player_died")


func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("hp_changed", current_hp, max_hp)


func is_alive() -> bool:
	return current_hp > 0
