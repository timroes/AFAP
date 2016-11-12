extends Node

func player_death(controller_id):
	Input.start_joy_vibration(controller_id, 0.8, 0.8, 0.2)
	
func player_headjumped(controller_id):
	Input.start_joy_vibration(controller_id, 0, 1.0, 0.08)