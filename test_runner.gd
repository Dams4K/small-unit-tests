extends RefCounted
class_name TestRunner

const TESTS_DIR := "res://tests"
const TEST_FILE_PREFIX := "test_"
const GD_SUFFIX := ".gd"

var scripts: Array[Script] = []

var failures: int = 0
var runs: int = 0

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

		var local_runs: int = 0
		var local_failures: int = 0
		TestReport.report("[color=%s]Running %s[/color]" % [TestReport.C_DIM, script.resource_path])
		for method_data: Dictionary in inst.get_test_methods():
			local_runs += 1
			if _test(inst, script, method_data):
				has_failures = true
				local_failures += 1

		runs += local_runs
		failures += local_failures

		if local_failures == 0:
			TestReport.report("[color=%s]Test run: %d[/color], Failures: %d [color=%s]-- in %s[/color]" % [TestReport.C_PASS, local_runs, local_failures, TestReport.C_DIM, get_script_classname(script)])
		else:
			TestReport.report("Test run: %d, [color=%s]Failures: %d[/color] [color=%s]-- in %s[/color]" % [local_runs, TestReport.C_FAIL, local_failures, TestReport.C_DIM, get_script_classname(script)])

	return has_failures


func _test(inst: TestCase, script: Script, method_data: Dictionary) -> bool:
	inst.before_each()
	inst.call(method_data.name)
	var failed := inst._test_case_has_failed()

	for message: String in inst._test_case_get_failures():
		TestReport.report_fail("[%s.%s] %s" % [get_script_classname(script), method_data.name, message])

	inst._test_case_clean_itself()
	return failed

func get_script_classname(script: Script) -> StringName:
	var classname: StringName = script.get_global_name()
	if classname.is_empty():
		classname = script.resource_path.get_file().get_basename().to_pascal_case()
	return classname
