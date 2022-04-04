extends Node

enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

var ignored_level_transition = null
var level_connection = null

var player_facing = DIRECTION.RIGHT
