class_name InteractionComponent
extends Node


var parent
func _ready() -> void:
	parent = get_parent()
	

func _process(delta: float) -> void:
	pass
	

func in_range() -> void:
	print(parent)

func not_in_range() -> void:
	print("not in range")
	
func on_interact() -> void:
	print(parent.name)

func connect_parent() -> void:
	parent.add_user_signal("focused")
	parent.add_user_signal("unfocused")
	parent.add_user_signal("interacted")
	parent.connect("focused", Callable(self, "in_range"))
	parent.connect("unfocused", Callable(self, "not_in_range"))
	parent.connect("interacted", Callable(self, "on_interact"))
