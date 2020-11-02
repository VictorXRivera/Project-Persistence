extends KinematicBody2D

#Jump 
export var fall_gravity_scale := 150.0
export var low_jump_gravity_scale := 100.0
export var jump_power := 750.0
var jump_released = false

#Physics
var velocity = Vector2()
var earth_gravity = 9.807 # m/s^2
export var gravity_scale := 100.0
var on_floor = false

#Left/Right movement
const ACCELERATION = 500
const MAX_SPEED = 500
const FRICTION = 500

var velocity_2 = Vector2.ZERO

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity_2 += input_vector * ACCELERATION * delta
		velocity_2 = velocity_2.clamped(MAX_SPEED * delta)
	else:
		velocity_2 = velocity_2.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_collide(velocity_2)
	
	if Input.is_action_just_released("ui_accept"):
		jump_released = true

	#Applying gravity to player
	velocity += Vector2.DOWN * earth_gravity * gravity_scale * delta

	#Jump Physics
	if velocity.y > 0: #Player is falling
		#Falling action is faster than jumping action | Like in mario
		#On falling we apply a second gravity to the player
		#We apply ((gravity_scale + fall_gravity_scale) * earth_gravity) gravity on the player
		velocity += Vector2.DOWN * earth_gravity * fall_gravity_scale * delta 

	elif velocity.y < 0 && jump_released: #Player is jumping 
		#Jump Height depends on how long you will hold key
		#If we release the jump before reaching the max height 
		#We apply ((gravity_scale + low_jump_gravity_scale) * earth_gravity) gravity on the player
		#It result on a lower jump
		velocity += Vector2.DOWN * earth_gravity * low_jump_gravity_scale * delta

	if on_floor:
		if Input.is_action_just_pressed("ui_accept"): 
			velocity = Vector2.UP * jump_power #Normal Jump action
			jump_released = false

	velocity = move_and_slide(velocity, Vector2.UP) 

	if is_on_floor(): on_floor = true
	else: on_floor = false
