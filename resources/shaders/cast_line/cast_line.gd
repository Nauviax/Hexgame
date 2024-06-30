extends Line2D

@export var line_material: Material

# Create a copy of material and set it to the new Line2D.
func prep_line() -> void:
	line_material = line_material.duplicate()
	set_material(line_material)
