extends Node3D

@export var item_id:String

func _ready() -> void:
	var scene = load(Items.Database[item_id].scene)
	print("scene in collision ", scene, Items.Database[item_id].scene)
	var instance = scene.instantiate()
	print("instance ", instance)
	add_child(instance)


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	if body.has_method("on_item_picked_up"):
		body.on_item_picked_up("pickaxe")
		queue_free()
