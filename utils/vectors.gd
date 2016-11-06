extends Node

# Checks whether the given vector points towards a specific direction.
# The direction has to been specified as an degree value, with 0° pointing
# downwards and running clockwise (i.e. 90 would mean pointing to the left).
func points_towards(vector, angle):
	return abs(vector.angle() - deg2rad(angle)) < 0.0001