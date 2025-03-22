extends CharacterBody3D

#测试用
enum State{
	IDLE,
	WALK,
	RUNNING,
	FALL,
	LANDING
}

func _unhandled_input(event: InputEvent) -> void:
	pass

func tick_physics(state: State, delta: float) -> void:
	pass

func get_next_state(state: State) -> State:
	match state:
		State.IDLE:

		State.WALK:

		State.RUNNING:

		State.FALL:

		State.LANDING:



#主要用来播动画
func transition_state(from: State, to: State) -> void:
	match to:
		State.IDLE:

		State.WALK:

		State.RUNNING:

		State.FALL:

		State.LANDING:
