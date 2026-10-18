extends RefCounted
class_name TestRunner

const TESTS_DIR := "res://tests"
const TEST_FILE_PREFIX := "test_"
const GD_SUFFIX := ".gd"

var scripts: Array[Script] = []

var total_failed: int = 0
var total_tested: int = 0

func _init() -> void:
	_scan_dir(TESTS_DIR)

func _scan_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			var file_path: String = path.path_join(file_name)
			if dir.current_is_dir():
				_scan_dir(file_path)
			elif file_name.ends_with(GD_SUFFIX) and file_name.begins_with(TEST_FILE_PREFIX):
				var script := load(file_path) as Script
				if script != null and _inherits_test_case(script):
					scripts.append(script)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path.")


func _inherits_test_case(script: Script) -> bool:
	var current := script.get_base_script()
	while current != null:
		if current == TestCase:
			return true
		current = current.get_base_script()
	return false


## Return true if there is any failures
func run_all() -> bool:
	var has_failures := false
	for script: Script in scripts:
		var inst := script.new() as TestCase
		if inst == null:
			continue
		
		for method_data: Dictionary in inst.get_test_methods():
			total_tested += 1
			if _test(inst, script, method_data):
				has_failures = true
				total_failed += 1
	
	return has_failures


func _test(inst: TestCase, script: Script, method_data: Dictionary) -> bool:
	inst.call(method_data.name)
	var failed := inst._test_case_has_failed()
	
	for message: String in inst._test_case_get_failures():
		var classname: StringName = script.get_global_name()
		if classname.is_empty():
			classname = script.resource_path.get_file().get_basename().to_pascal_case()
		
		printerr("[%s.%s] %s" % [classname, method_data.name, message])
	
	inst._test_case_clean_itself()
	return failed
