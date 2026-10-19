extends RefCounted
class_name TestRunner

const TESTS_DIR := "tests"
const TEST_FILE_PREFIX := "test_"
const GD_SUFFIX := ".gd"

var scripts: Array[Script] = []

var results: Array[SutTestResult] = []
var failures: int = 0
var runs: int = 0

func _init() -> void:
	_scan_dir("res://" + TESTS_DIR)

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
		has_failures = has_failures or run_script(script)
	
	return has_failures

func run_script(script: Script) -> bool:
	var inst := script.new() as TestCase
	if inst == null:
		push_error("Script '%s' do not inherits from TestCase" % script)

	var local_runs: int = 0
	var local_failures: int = 0
	var local_results: Array[SutTestResult] = []
	
	SutTestReport.report_running(script.resource_path)
	for method_data: Dictionary in inst.get_test_methods():
		local_runs += 1
		var result := _test(inst, script, method_data)
		local_results.append(result)
		results.append(result)
		
		if SutTestReport.report_result_if_failed(result):
			local_failures += 1

	runs += local_runs
	failures += local_failures

	if local_failures == 0:
		SutTestReport.report("[color=%s]Tests run: %d[/color], Failures: %d, Time elapsed: %.3fs [color=%s]-- in %s[/color]" % [
			SutTestOptions.get_singleton().success_color,
			local_runs,
			local_failures,
			0.0,
			SutTestOptions.get_singleton().dim_color,
			"get_script_classname(script)",
		])
	else:
		SutTestReport.report("Tests run: %d, [color=%s]Failures: %d[/color], Time elapsed: %.3fs [color=%s]-- in %s[/color]" % [
			local_runs,
			SutTestOptions.get_singleton().error_color,
			local_failures,
			0.0,
			SutTestOptions.get_singleton().dim_color,
			"get_script_classname(script)",
		])

	return local_failures == 0


func _test(inst: TestCase, script: Script, method_data: Dictionary) -> SutTestResult:
	inst.before_each()

	var start := Time.get_ticks_usec()

	inst.call(method_data.name)

	var result := SutTestResult.new()
	result.by = script
	#result.classname = get_script_classname(script)
	#result.long_classname = script.resource_path.trim_prefix("res://").trim_suffix(".gd").replace("/", ".")
	result.name = method_data.name
	result.duration_usec = (Time.get_ticks_usec() - start) / 1_000_000.0
	result.failures = inst._test_case_failures.duplicate()
	result.no_assertion = inst._test_case_assertion_count == 0
	#results.append(result)
#
	#var failed := inst._test_case_has_failed()
	#for message: String in inst._test_case_failures:
	#	SutTestReport.report_fail("[%s.%s] %s" % [get_script_classname(script), method_data.name, message])

	inst._test_case_clean_itself()
	return result


#func get_script_classname(script: Script) -> StringName:
#	var classname: StringName = script.get_global_name()
#	if classname.is_empty():
#		classname = script.resource_path.get_file().get_basename().to_pascal_case()
#	return classname
