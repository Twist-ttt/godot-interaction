extends CharacterBody3D
class_name SwitchableCharacter

# 角色描述信息，用于交互提示
@export var prompt_message: String = "切换角色"
# 是否为当前控制的角色
var is_active: bool = false

# 角色初始化
func _ready() -> void:
	# 添加"可交互"用户信号，与原有交互系统兼容
	add_user_signal("interact")
	
	# 将自己注册到角色管理器
	await get_tree().process_frame
	
	var manager = get_node_or_null("/root/CharacterManager")
	if manager:
		manager.register_character(self)
	else:
		# 如果场景中没有角色管理器，自动创建一个
		manager = CharacterManager.new()
		manager.name = "CharacterManager"
		get_tree().root.add_child(manager)
		manager.register_character(self)

# 处理输入事件 - 所有角色共享的基本输入处理
func _unhandled_input(event: InputEvent) -> void:
	# 只有当角色被激活时才处理输入
	if not is_active:
		return
		
	# 基础输入处理：ESC键退出游戏
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
			get_tree().quit()
	
	# 其他共享的输入处理可以添加在这里
	
	# 调用派生类可能实现的扩展输入处理
	_handle_character_input(event)

# 可由派生类重写的角色特定输入处理方法
func _handle_character_input(event: InputEvent) -> void:
	# 派生类可以重写此方法以添加特定的输入处理
	pass

# 激活角色（被控制）
func activate() -> void:
	is_active = true
	# 启用摄像机和输入处理
	enable_camera(true)
	print(name + " 已激活")

# 停用角色（不被控制）
func deactivate() -> void:
	is_active = false
	# 禁用摄像机和输入处理
	enable_camera(false)
	print(name + " 已停用")

# 控制摄像机的启用/禁用
func enable_camera(enabled: bool) -> void:
	if has_node("Head/Camera3D"):
		$Head/Camera3D.current = enabled

# 用于与角色交互，切换控制
func interact() -> void:
	# 发出交互信号，兼容原有系统
	emit_signal("interact")
	
	# 切换角色控制
	var manager = get_node_or_null("/root/CharacterManager")
	if manager:
		manager.switch_to_character(self)
