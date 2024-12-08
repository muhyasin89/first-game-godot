@tool
extends Resource
class_name StatSheet

signal stat_change

@export var health:int
@export var attack:int
@export var magic_attack:int
@export var defense:int
@export var magic_defence:int

func set_health(amount: int):
	health = clamp(amount, 0,255)
	
func get_health() -> int:
	return health
