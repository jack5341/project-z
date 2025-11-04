@tool

extends MultiMeshInstance3D

class_name RockSpawner

## Scatters random rock meshes across a rectangular area by creating
## one MultiMeshInstance3D per unique mesh and assigning random transforms.

@export var spawn_count: int = 100
@export var area_size: Vector2 = Vector2(100.0, 100.0)
@export var random_seed: int = 0

@export var rock_library: MeshLibrary
@export_file("*.glb", "*.gltf", "*.tscn", "*.scn") var rock_scene_path: String

@export var spawn_on_ready: bool = false
@export var regenerate: bool = false:
	set(value):
		if value:
			_respawn_internal()
		# Reset the toggle so it can be pressed again in the Inspector
		regenerate = false

func _ready() -> void:
	if spawn_on_ready:
		_respawn_internal()

## Removes previously spawned MultiMeshInstance3D children and spawns again.
func respawn() -> void:
	_respawn_internal()

func _respawn_internal() -> void:
	_clear_spawned_children()

	var mesh_instances: Array[MeshInstance3D] = _collect_rock_meshes()
	if mesh_instances.is_empty():
		push_warning("RockSpawner: No rock meshes found. Assign 'rock_library' or 'rock_scene_path'.")
		return

	# Seed RNG for reproducibility if desired
	var rng := RandomNumberGenerator.new()
	if random_seed != 0:
		rng.seed = int(random_seed)
	else:
		rng.randomize()

	# Assign each spawn to a random MeshInstance3D and record its transform
	# Group by mesh + transform hash to preserve different scales per MeshInstance3D
	var key_to_data: Dictionary = {}

	for i in spawn_count:
		var chosen_mi: MeshInstance3D = mesh_instances[rng.randi_range(0, mesh_instances.size() - 1)]
		var local_x := rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var local_z := rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var pos := Vector3(local_x, 0.0, local_z)

		# Get the MeshInstance3D's transform (includes scale, rotation from Sketchfab scene)
		var mi_transform: Transform3D = chosen_mi.transform
		# Preserve the basis (rotation + scale) but use random position
		var xf := Transform3D(mi_transform.basis, pos)
		
		# Create a unique key for this mesh + transform combination
		var mesh_rid: int = chosen_mi.mesh.get_rid().get_id()
		var transform_hash: int = hash(mi_transform.basis)
		var key := str(mesh_rid) + "_" + str(transform_hash)
		
		if not key_to_data.has(key):
			key_to_data[key] = {
				"mesh": chosen_mi.mesh,
				"basis": mi_transform.basis,
				"transforms": []
			}
		key_to_data[key]["transforms"].append(xf)

	# Build one MultiMeshInstance3D per unique mesh+transform combination
	for key in key_to_data.keys():
		var data: Dictionary = key_to_data[key]
		var transforms: Array = data["transforms"]
		if transforms.is_empty():
			continue

		var mm := MultiMesh.new()
		mm.mesh = data["mesh"]
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = false
		mm.use_custom_data = false
		mm.instance_count = transforms.size()

		for idx in transforms.size():
			mm.set_instance_transform(idx, transforms[idx])

		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		add_child(mmi)

## Remove only the spawned MultiMeshInstance3D children (not this node's own multimesh).
func _clear_spawned_children() -> void:
	# If this node already had its own MultiMesh assigned in the editor, keep it (acts as a container parent).
	for child in get_children():
		if child is MultiMeshInstance3D:
			remove_child(child)
			child.queue_free()

## Collects MeshInstance3D nodes from MeshLibrary or a scene file (GLB/GLTF/TSEN etc.).
func _collect_rock_meshes() -> Array[MeshInstance3D]:
	var mesh_instances: Array[MeshInstance3D] = []

	if rock_library:
		# For MeshLibrary, create temporary MeshInstance3D nodes with identity transforms
		var ids := rock_library.get_item_list()
		for id in ids:
			var m: Mesh = rock_library.get_item_mesh(id)
			if m:
				var temp_mi := MeshInstance3D.new()
				temp_mi.mesh = m
				temp_mi.transform = Transform3D.IDENTITY
				mesh_instances.append(temp_mi)

	if mesh_instances.is_empty() and rock_scene_path != "":
		var packed: PackedScene = load(rock_scene_path)
		if packed:
			var root := packed.instantiate()
			if root:
				# Collect MeshInstance3D nodes from the scene
				var stack: Array[Node] = [root]
				while not stack.is_empty():
					var n: Node = stack.pop_back()
					for c in n.get_children():
						stack.append(c)
					if n is MeshInstance3D:
						var mi: MeshInstance3D = n
						if mi.mesh:
							# Calculate transform relative to root (accumulate up the parent chain)
							var relative_transform := mi.transform
							var current := mi.get_parent()
							while current != null and current != root:
								relative_transform = current.transform * relative_transform
								current = current.get_parent()
							# Create a copy with the relative transform
							var mi_copy := MeshInstance3D.new()
							mi_copy.mesh = mi.mesh
							mi_copy.transform = relative_transform
							mesh_instances.append(mi_copy)
				root.queue_free()

	return mesh_instances
