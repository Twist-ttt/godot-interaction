# 状态机管理器，需挂载在需要进行状态管理对象的父节点(owner)下
# 依赖owner实现 transition_state、get_next_state 和 tick_physics 方法
class_name StateMachine
extends Node

# 记录当前状态持续时间（秒）
var state_time: float = 0.0

# 当前状态标识（枚举类型）
# 使用setter(也就是set())监听状态变化，默认-1表示未初始化状态
var current_state: int = -1:
	set(v):#当current_state的值将要变化时，v=新值，此时current_state还未更新
		# 状态变化时通知owner
		# transition_state处理状态切换时的清理和初始化工作
		owner.transition_state(current_state, v)
		# 更新当前状态，这里赋值不会重新执行set()
		current_state = v
		state_time = 0

# 初始化函数
func _ready() -> void:
	#godot优先处理子节点的ready函数，
	#最后再执行owner（父节点）的ready函数，
	#因此需要先等owner的ready函数执行完
	await owner.ready

	# 初始化初始状态
	current_state = 0

func _physics_process(delta: float) -> void:
	while true:
		var next := owner.get_next_state(current_state) as int

		#状态稳定时，退出循环
		if current_state == next:
			break

		current_state = next

	# 执行当前状态的物理逻辑处理
	owner.tick_physics(current_state, delta)
	state_time = state_time +delta
