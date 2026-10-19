extends RefCounted
class_name SutTestOptions

@export_storage var bbcode: bool = false
@export_storage var success_color: String = "#6cc38a"
@export_storage var error_color: String = "#e5747a"
@export_storage var warning_error: String = "#e0c068"
@export_storage var dim_color: String = "#8b8b8b"
@export_storage var junit: String = ""

static var instance: SutTestOptions

static func get_singleton() -> SutTestOptions:
	if instance == null:
		instance = SutTestOptions.new()
	return instance


func _init() -> void:
	for arg: String in OS.get_cmdline_user_args():
		interpret_option(arg).apply(self)


func interpret_option(arg: String) -> OptionValue:
	arg = arg.trim_prefix("--")
	if arg.contains("="):
		var name_value: PackedStringArray = arg.split("=")
		return OptionValue.new(name_value[0], name_value[1])
	
	var name = arg
	var current_value = get(name)
	if current_value is bool:
		return OptionValue.new(name, not current_value)
	return OptionValue.new(name, current_value)


func map_option(name: String, value: Variant) -> void:
	set(name, value)


func _options() -> Array[String]:
	return get_property_list() \
		.filter(_is_property_option) \
		.map(func(p): return p.name)

func _is_property_option(property: Dictionary) -> bool:
	return (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0 and (property.usage & PROPERTY_USAGE_STORAGE) != 0


class OptionValue:
	var name: String
	var value: Variant
	
	func _init(p_name: String, p_value: Variant) -> void:
		name = p_name
		value = p_value
	
	func apply(object: Object) -> void:
		if name in object:
			object.set(name, value)
		else:
			push_warning("attribut '%s' not found in '%s'" % [name, object])
