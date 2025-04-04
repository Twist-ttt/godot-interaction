extends Node
class_name CharacterManager

# 单例模式，方便全局访问
static var instance: CharacterManager

# 保存所有可切换的角色
var switchable_characters: Array[CharacterBody3D] = []
# 当前控制的角色
var current_character: CharacterBody3D

# 在游戏开始时初始化
func _ready() -> void:
	instance = self
	
	# 等待一帧确保所有角色已经加载
	await get_tree().process_frame
	
	# 初始化当前角色为第一个注册的角色（通常是玩家）
	if switchable_characters.size() > 0:
		switch_to_character(switchable_characters[0])

# 注册可切换的角色
func register_character(character: CharacterBody3D) -> void:
	if not switchable_characters.has(character):
		switchable_characters.append(character)
		print("已注册角色: ", character.name)

# 切换到指定的角色
func switch_to_character(new_character: CharacterBody3D) -> void:
	if not switchable_characters.has(new_character):
		print("无法切换到未注册的角色")
		return
		
	# 如果有当前角色，停用它
	if current_character:
		if current_character.has_method("deactivate"):
			current_character.deactivate()
		print("停用角色: ", current_character.name)
	
	# 激活新角色
	current_character = new_character
	if current_character.has_method("activate"):
		current_character.activate()
	print("激活角色: ", current_character.name)
