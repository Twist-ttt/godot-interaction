extends SwitchableCharacter

@export var AI_WALK_SPEED : float = 5.0
@export var PLAYER_WALK_SPEED : float = 10.0
@export var JUMP_VELOCITY : float = 8.0
@export var GRAVITY: float = 9.8
@export var ACCLE: float = 10.0

# AI行为相关
@export var patrol_path: NodePath  # 可以指定一个Path节点作为巡逻路径
@export var patrol_wait_time: float = 3.0 # 到达巡逻点后等待的时间

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D

var patrol_points: Array = []
var patrol_index: int = 0
var patrol_timer: float = 0.0
var is_waiting: bool = false
var look_rot: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.02 # 玩家控制NPC时的视角灵敏度

# 状态机的枚举
enum NPCState {
	IDLE,
	WALK,
	PATROL
}

var current_npc_state: NPCState = NPCState.IDLE

func _ready() -> void:
	super._ready()  # 调用父类的_ready，确保角色被注册到管理器
	prompt_message = "NPC - " + name
	
	# 初始化巡逻路径
	initialize_patrol_path()

# 初始化巡逻路径
func initialize_patrol_path() -> void:
	patrol_points.clear()
	
	if not patrol_path.is_empty():
		var path_node = get_node_or_null(patrol_path)
		if path_node and path_node is Path3D:
			var path_curve = path_node.curve
			var point_count = 20 # 采样点数量，可以调整
			
			for i in range(point_count):
				var point_pos = path_curve.sample_baked(i * path_curve.get_baked_length() / (point_count - 1))
				patrol_points.append(Vector3(point_pos.x, global_position.y, point_pos.z))
	
	# 如果没有指定巡逻路径，创建一个简单的方形巡逻路径
	if patrol_points.size() == 0:
		var origin = global_position
		patrol_points.append(origin)
		patrol_points.append(origin + Vector3(5, 0, 0))
		patrol_points.append(origin + Vector3(5, 0, 5))
		patrol_points.append(origin + Vector3(0, 0, 5))

func _physics_process(delta: float) -> void:
	# 重力始终生效
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	if is_active:
		# 玩家控制模式
		player_controlled_move(delta)
	else:
		# AI控制模式
		ai_controlled_move(delta)
	
	move_and_slide()
	
	# 更新动画
	update_animation()
	
		# 只在角色被玩家控制时执行
	if is_active:
		# 这两行是可选的调试代码，帮助开发过程中查看旋转值
		# print("Head rotation: ", head.rotation_degrees)
		# print("Body rotation: ", rotation_degrees)
		
		# 这两行是关键修复，确保头部只能在X轴上旋转
		# 即使其他脚本或物理引擎尝试旋转头部，这些设置也会立即纠正它
		head.rotation.y = 0  # 防止头部左右旋转
		head.rotation.z = 0  # 防止头部倾斜

# 玩家控制的移动
func player_controlled_move(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * PLAYER_WALK_SPEED, ACCLE * delta)
		velocity.z = lerp(velocity.z, direction.z * PLAYER_WALK_SPEED, ACCLE * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, ACCLE * delta)
		velocity.z = lerp(velocity.z, 0.0, ACCLE * delta)
	
	# 跳跃
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 更清晰的视角控制
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y


# AI控制的移动
func ai_controlled_move(delta: float) -> void:
	match current_npc_state:
		NPCState.IDLE:
			# 空闲状态，不移动
			velocity.x = lerp(velocity.x, 0.0, ACCLE * delta)
			velocity.z = lerp(velocity.z, 0.0, ACCLE * delta)
			
			# 在空闲状态停留一段时间后切换到巡逻状态
			patrol_timer += delta
			if patrol_timer >= patrol_wait_time:
				patrol_timer = 0.0
				current_npc_state = NPCState.PATROL
		
		NPCState.PATROL:
			if patrol_points.size() > 0:
				var target = patrol_points[patrol_index]
				var path_vector = (target - global_position)
				path_vector.y = 0
				
				if path_vector.length() < 0.5:
					# 到达目标点，等待一段时间
					current_npc_state = NPCState.IDLE
					patrol_timer = 0.0
					
					# 移动到下一个巡逻点
					patrol_index = (patrol_index + 1) % patrol_points.size()
				else:
					# 向目标点移动
					var direction = path_vector.normalized()
					
					velocity.x = lerp(velocity.x, direction.x * AI_WALK_SPEED, ACCLE * delta)
					velocity.z = lerp(velocity.z, direction.z * AI_WALK_SPEED, ACCLE * delta)
					
					# 让NPC面向移动方向
					if direction != Vector3.ZERO:
						var target_pos = global_position + direction
						var new_transform = transform.looking_at(target_pos, Vector3.UP)
						
						# 平滑旋转
						rotation.y = lerp_angle(rotation.y, new_transform.basis.get_euler().y, 5 * delta)

# 更新角色动画
func update_animation() -> void:
	if not animation_player:
		return
		
	if not animation_player.has_animation("idle") or not animation_player.has_animation("walk"):
		return
	
	# 基于速度决定播放哪个动画
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor():
		if horizontal_speed > 0.5:
			if not animation_player.current_animation == "walk" or not animation_player.is_playing():
				animation_player.play("walk")
		else:
			if not animation_player.current_animation == "idle" or not animation_player.is_playing():
				animation_player.play("idle")
	else:
		# 如果有跳跃/下落动画可以在这里添加
		if velocity.y > 0 and animation_player.has_animation("jump"):
			animation_player.play("jump")
		elif velocity.y < 0 and animation_player.has_animation("fall"):
			animation_player.play("fall")

# 重写激活函数
func activate() -> void:
	super.activate()
	
	# 重置视角状态 - 这是关键修复
	look_rot = Vector2.ZERO
	
	# 设置头部和旋转到初始状态
	if head:
		head.rotation_degrees.x = 0
	rotation_degrees.y = 0
	
	# 玩家控制时停止AI行为
	current_npc_state = NPCState.IDLE
	
	# 设置摄像机和鼠标
	if camera_3d:
		camera_3d.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# 重写停用函数
func deactivate() -> void:
	super.deactivate()
	
	# 停用时重新启动AI行为
	current_npc_state = NPCState.IDLE
	patrol_timer = 0.0
	
	# 重置视角
	if head:
		head.rotation_degrees.x = 0

# 处理输入事件
func _handle_character_input(event: InputEvent) -> void:
	# 镜头控制
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * mouse_sensitivity)
		look_rot.x -= (event.relative.y * mouse_sensitivity)
		look_rot.x = clamp(look_rot.x, -80, 90)
		
		# 立即应用旋转，使操作更灵敏
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y
