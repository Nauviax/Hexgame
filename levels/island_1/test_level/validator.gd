# Test Level Validator
static var descs = [
	"Test Level: All entities on green tiles must contain true. At least one on-green entity must exist."
]
static func validate(level_base):
	var greens = level_base.entities_on_tile(4)
	if greens.size() == 0:
		return false # Instantly invalid if empty
	for entity in greens:
		var iota = entity.get_iota()
		if not (iota is bool and iota):
			return false
	return true