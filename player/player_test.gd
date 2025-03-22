extends CharacterBody3D

@export var WALK_SPEED : float = 10
@export var RUN_SPEED : float = 16
@export var JUMP_VELOCITY : float = 10
@export var GRAVITY: float = -9.8

@export var mouse_sensitivity : float = 0.002

@onready var camera_3d: Camera3D = $Camera3D

#测试用
enum State{
	IDLE,
	WALK,
	RUNNING,
	JUMP,
	FALL,
	LANDING
}

var camera_angle : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		rotate_y(-event.relative.x * mouse_sensitivity)
	
		camera_angle = camera_angle - event.relative.y * mouse_sensitivity
		camera_angle = clamp(camera_angle, -PI/2, PI/2)
		camera_3d.rotation.x = camera_angle


func move(delta: float) -> void:
	var input_dir = Input.get_vector("move_backward", "move_forward", "move_left", "move_right")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED
	
	velocity.y = velocity.y + GRAVITY * delta
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		velocity.y = JUMP_VELOCITY
	
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		
	
func _physics_process(delta: float) -> void:
	move(delta)
	
	move_and_slide()







#func tick_physics(state: State, delta: float) -> void:
	#pass

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
#
#
#
##主要用来播动画
#func transition_state(from: State, to: State) -> void:
	#match to:
		#State.IDLE:
			#pass
		#State.WALK:
			#pass
		#State.RUNNING:
			#pass
		#State.JUMP:
			#pass
		#State.FALL:
			#pass
		#State.LANDING:
			#pass
