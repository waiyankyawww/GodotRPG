extends KinematicBody2D

export var ACCELERATION = 500
export var FRICTION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 115

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

#this will instantiate the AnimationPlayer node when the node is ready
#start lote lyk lo shi yin AnimationPlayer node ko instantiate lote lyk mhr "onready" ka
#same with fun _onready() 
onready var animationPlayer = $AnimationPlayer
#instantiating the AnimationTress
onready var animationTree = $AnimationTree
#instantiating the AnimationState from the AnimationTree
onready var animationState = animationTree.get("parameters/playback")
#instantiating the SwordHitBox
onready var swordHitbox = $Position2D/SwordHitBox
onready var hurtbox = $HurtBox

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

# updating relating with physics
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)

func move_state(delta):
		#getting the user input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#normalizing the vector Setting the same unit vector when move diagonally
	input_vector = input_vector.normalized()
	
	#if there is a user input set the destination to with the delta speed
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		#setting the animation with the animationTree
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL

# moving the player
func move():
	velocity = move_and_slide(velocity)

# roll state for the player
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

# called when the player pressed attack key
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

# called when the roll animation is finished in the Animation Player
func roll_animation_finished():
	state = MOVE

# called when the attack animation is finished in the Animation Player
func attack_animation_finished():
	state = MOVE

# called when the bat enter the player hurtbox
# connected with signal
func _on_HurtBox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
