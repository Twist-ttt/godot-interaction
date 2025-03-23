extends CharacterBody3D


@export var WALK_SPEED : float = 10
@export var RUN_SPEED : float = 16
@export var JUMP_VELOCITY : float = 10
@export var GRAVITY: float = 9.8
@export var ACCLE: float = 16

@export var mouse_sensitivity : float = 0.02
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D


#测试用
enum State{
	IDLE,
	WALK,
	RUNNING,
	JUMP,
	FALL,
	LANDING
}

var head_angle : float
var look_rot : Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else :
		if Input.is_action_just_pressed("move_jump"):
			print("1")
			velocity.y = JUMP_VELOCITY
			
			
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * WALK_SPEED, ACCLE * delta)
		velocity.z = lerp(velocity.z, direction.z * WALK_SPEED, ACCLE * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCLE * delta)
		velocity.z = lerp(velocity.z, 0.0, ACCLE * delta)
	
	move_and_slide()
	
	var plat_rot = get_platform_angular_velocity()
	look_rot.y += rad_to_deg(plat_rot.y * delta)
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y


func _unhandled_input(event: InputEvent) -> void:


	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

	#镜头控制		
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * mouse_sensitivity)
		look_rot.x -= (event.relative.y * mouse_sensitivity)
		look_rot.x = clamp(look_rot.x, -80, 90)


	
func _physics_process(delta: float) -> void:
	move(delta)
	
	var plat_rot = get_platform_angular_velocity()
	look_rot.y += rad_to_deg(plat_rot.y * delta)
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y
	
	











#func tick_physics(state: State, delta: float) -> void:
	#match state:
		#State.IDLE:
			#move(delta)
		#State.WALK:
#
		#State.RUNNING:
#
		#State.JUMP:
#
		#State.FALL:
#
		#State.LANDING:
#
#func get_next_state(state: State) -> State:
	#match state:
		#State.IDLE:
#
		#State.WALK:
#
		#State.RUNNING:
#
		#State.JUMP:
#
		#State.FALL:
#
		#State.LANDING:
##
##
##
###主要用来播动画
##func transition_state(from: State, to: State) -> void:
	##match to:
		##State.IDLE:
			##pass
		##State.WALK:
			##pass
		##State.RUNNING:
			##pass
		##State.JUMP:
			##pass
		##State.FALL:
			##pass
		##State.LANDING:
			##pass
