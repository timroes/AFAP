extends Node

func player_death(controller_id):
	Input.start_joy_vibration(controller_id, 0.8, 0.8, 0.2)