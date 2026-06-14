# Player.gd
# Attach ke CharacterBody2D
# Node tree:
#   CharacterBody2D (Player)
#   ├── AnimatedSprite2D
#   ├── CollisionShape2D
#   ├── AttackHitbox (Area2D)
#   │   └── CollisionShape2D
#   └── PlayerStats (Node)

extends CharacterBody2D

# ─── REFERENSI NODE ───────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats = $PlayerStats
@onready var attack_hitbox: Area2D = $AttackHitbox

# ─── KONSTANTA GERAK ──────────────────────────────────────────────────────────
const SPEED: float = 200.0
const JUMP_VELOCITY: float = -450.0
const GRAVITY: float = 980.0

# ─── ATTACK ───────────────────────────────────────────────────────────────────
var is_attacking: bool = false
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0
var attack_duration: float = 0.2   # Lama hitbox aktif

# ─── STATE ────────────────────────────────────────────────────────────────────
var can_move: bool = true
var is_dead: bool = false


func _ready():
	attack_hitbox.monitoring = false
	stats.connect("player_died", _on_player_died)
	stats.connect("level_up", _on_level_up)


func _physics_process(delta: float):
	if is_dead:
		return
	
	_apply_gravity(delta)
	
	if can_move:
		_handle_movement()
		_handle_jump()
	
	_handle_attack(delta)
	_update_animation()
	
	move_and_slide()


# ─── GRAVITY ──────────────────────────────────────────────────────────────────

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta


# ─── MOVEMENT ─────────────────────────────────────────────────────────────────

func _handle_movement():
	var direction = Input.get_axis("mundur", "maju")  # ← →
	
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0  # Flip sprite ke kiri
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)  # Smooth stop


# ─── JUMP ─────────────────────────────────────────────────────────────────────

func _handle_jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():  # Space / Enter
		velocity.y = JUMP_VELOCITY


# ─── ATTACK ───────────────────────────────────────────────────────────────────

func _handle_attack(delta: float):
	# Countdown cooldown
	if attack_timer > 0:
		attack_timer -= delta
	
	# Nonaktifkan hitbox setelah durasi selesai
	if is_attacking and attack_timer <= (attack_cooldown - attack_duration):
		attack_hitbox.monitoring = false
		is_attacking = false
	
	# Input serangan
	if Input.is_action_just_pressed("attack") and attack_timer <= 0:
		_perform_attack()


func _perform_attack():
	is_attacking = true
	attack_timer = attack_cooldown
	attack_hitbox.monitoring = true
	
	# Posisikan hitbox sesuai arah hadap
	var offset_x = 40 if not sprite.flip_h else -40
	attack_hitbox.position.x = offset_x
	
	# Cek apakah ada musuh kena hitbox
	await get_tree().process_frame  # Tunggu 1 frame agar hitbox aktif dulu
	
	var bodies = attack_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"):
			body.take_damage(stats.base_damage)


# ─── ANIMASI ──────────────────────────────────────────────────────────────────

func _update_animation():
	if is_attacking:
		sprite.play("nyerang")
	elif not is_on_floor():
		sprite.play("lompat")
	elif abs(velocity.x) > 10:
		sprite.play("jalan")
	else:
		sprite.play("diem")


# ─── TERIMA DAMAGE (dipanggil dari musuh) ─────────────────────────────────────

func take_damage(amount: int):
	if is_dead:
		return
	stats.take_damage(amount)


# ─── EVENT DARI STATS ─────────────────────────────────────────────────────────

func _on_player_died():
	is_dead = true
	can_move = false
	sprite.play("death")
	print("Player mati!")
	# Tambahkan logika game over di sini


func _on_level_up(new_level: int):
	print("LEVEL UP ke Level ", new_level, "!")
	# Bisa tambahkan efek visual di sini
