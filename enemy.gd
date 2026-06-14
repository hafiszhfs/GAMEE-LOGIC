extends CharacterBody2D

const GRAVITY: float = 980.0
const MOVE_SPEED: float = 80.0
const CHASE_RANGE: float = 200.0
const XP_REWARD: int = 30

var player = null
var is_dead: bool = false


func _ready():
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if player != null:
		var distance = global_position.distance_to(player.global_position)
		if distance <= CHASE_RANGE:
			var direction = sign(player.global_position.x - global_position.x)
			velocity.x = direction * MOVE_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)

	move_and_slide()


func take_damage(amount: int):
	if is_dead:
		return
	_die()


func _die():
	is_dead = true
	velocity = Vector2.ZERO

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].get_node("PlayerStats").gain_xp(XP_REWARD)

	queue_free()
