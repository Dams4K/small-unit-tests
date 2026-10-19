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
	SutTestReport.report("%d test files found.\n" % scripts.size())

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
		var failed := run_script(script)
		has_failures = has_failures or failed
	
	return has_failures

func run_script(script: Script) -> bool:
	var inst := script.new() as TestCase
	if inst == null:
		push_error("Script '%s' do not inherits from TestCase" % script)
		return false

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
	SutTestReport.report_results(local_results)

	return local_failures == 0


func _test(inst: TestCase, script: Script, method_data: Dictionary) -> SutTestResult:
	inst.before_each()

	var start := Time.get_ticks_usec()

	inst.call(method_data.name)
	
	var result := SutTestResult.new()
	result.by = script
	result.name = method_data.name
	result.duration_usec = Time.get_ticks_usec() - start
	result.failures = inst._test_case_failures.duplicate()
	result.no_assertion = inst._test_case_assertion_count == 0

	inst._test_case_clean_itself()
	return result
