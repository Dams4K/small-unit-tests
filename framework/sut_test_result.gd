extends RefCounted
class_name SutTestResult

var by: Script
var name: StringName
var duration_usec: float = 0.0
var failures: Array[String] = []
var no_assertion := false

func get_duration_seconds() -> float:
	return duration_usec / 1_000_000.0

func failed() -> bool:
	return failures.size() > 0


func get_classname() -> String:
	var classname: StringName = by.get_global_name()
	if classname.is_empty():
		classname = by.resource_path.get_file().get_basename().to_pascal_case()
	return classname

func get_long_classname() -> String:
	return by.resource_path.trim_suffix(".gd").trim_prefix(TestRunner.TESTS_DIR)
