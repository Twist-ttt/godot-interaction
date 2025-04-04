extends SwitchableCharacter

@export var WALK_SPEED : float = 10
@export var RUN_SPEED : float = 16
@export var JUMP_VELOCITY : float = 10
@export var GRAVITY: float = 9.8
@export var ACCLE: float = 16

@export var mouse_sensitivity : float = 0.02
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

# 状态定义
enum State{
	IDLE,
	WALK,
	JUMP,
	RUNNING,
	FALL,
	LANDING
}

const GROUND_STATES :=[
	State.IDLE, State.WALK, State.RUNNING,
	State.LANDING
]

var head_angle : float
var look_rot : Vector2

func _ready() -> void:
	super._ready()  # 调用父类的_ready，确保角色被注册到管理器
	prompt_message = "玩家角色"
	# 初始化角色时不要自动激活，让管理器决定

func _physics_process(delta: float) -> void:
	# 只有当前角色处于激活状态时才处理输入和移动
	if is_active:
		# 如果使用StateMachine，则不需要在这里调用move
		# StateMachine会通过tick_physics调用相应的处理函数
		if !has_node("StateMachine"):
			move(delta)
		
		# 处理视角旋转
		var plat_rot = get_platform_angular_velocity()
		look_rot.y += rad_to_deg(plat_rot.y * delta)
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y

# 删除现有的_unhandled_input方法
# 改为重写_handle_character_input
func _handle_character_input(event: InputEvent) -> void:
	# 镜头控制
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * mouse_sensitivity)
		look_rot.x -= (event.relative.y * mouse_sensitivity)
		look_rot.x = clamp(look_rot.x, -80, 90)


# 重写激活函数
func activate() -> void:
	super.activate()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# 重写停用函数
func deactivate() -> void:
	super.deactivate()
	# 可以添加角色被停用时的行为，比如切换到AI控制等
	velocity = Vector3.ZERO  # 停止移动

# 移动处理函数（与原来的代码保持相同）
func move(delta: float) -> void:
	if Input.is_action_just_pressed("move_jump"):
		jump_request_timer.start()
	
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var speed = RUN_SPEED if Input.is_action_pressed("move_sprint") else WALK_SPEED
		velocity.x = lerp(velocity.x, direction.x * speed, ACCLE * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, ACCLE * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCLE * delta)
		velocity.z = lerp(velocity.z, 0.0, ACCLE * delta)
	
	move_and_slide()

# 状态机相关函数（保持不变）
func tick_physics(state: State, delta: float) -> void:
	if not is_active:
		return
		
	match state:
		State.IDLE:
			move(delta)
		State.WALK:
			move(delta)
		State.JUMP:
			move(delta)
		State.RUNNING:
			move(delta)
		State.FALL:
			move(delta)
		State.LANDING:
			move(delta)

func get_next_state(state: State) -> State:
	if not is_active:
		return state
		
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	
	if state in GROUND_STATES:
		if should_jump:
			return State.JUMP
		elif not is_on_floor():
			return State.FALL
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var is_still := input_dir.length_squared() < 0.0001 and is_zero_approx(velocity.x) and is_zero_approx(velocity.z)
	var is_running := Input.is_action_pressed("move_sprint") and input_dir.length_squared() > 0.0001
	
	match state:
		State.IDLE:
			if not is_still:
				return State.RUNNING if is_running else State.WALK
		
		State.WALK:
			if is_still:
				return State.IDLE
			elif is_running:
				return State.RUNNING
		
		State.JUMP:
			if velocity.y <= 0:
				return State.FALL
		
		State.RUNNING:
			if is_still:
				return State.IDLE
			elif not is_running:
				return State.WALK

		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.WALK
			
		State.LANDING:
			if not is_still:
				return State.WALK
			elif not animation_player.is_playing():
				return State.IDLE 
				
	return state

# 状态转换处理（保持不变，但添加is_active检查）
func transition_state(from: State, to: State) -> void:
	if not is_active:
		return
		
	print("[%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<START>",
		State.keys()[to],
	])
	
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		
		State.WALK:
			animation_player.play("walk")
		
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		
		State.RUNNING:
			animation_player.play("running")
			
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATES: # 只有从地面状态进入FALL时才启动coyote timer
				coyote_timer.start()
		
		State.LANDING:
			animation_player.play("landing")
