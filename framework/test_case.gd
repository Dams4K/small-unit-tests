@abstract
extends RefCounted
class_name TestCase

const _test_case_TEST_METHOD_PREFIX := "test_"

var _test_case_failures: Array[String] = []
var _test_case_assertion_count := 0

func _new_assert_called() -> void:
	_test_case_assertion_count += 1

#region SETUP
func before_each() -> void:
	pass
#endregion

#region ASSERTS
func assert_eq(actual: Variant, expected: Variant, msg := "") -> void:
	_new_assert_called()
	if actual != expected:
		_test_case_failures.append("%s expected '%s', got '%s'" % [msg, expected, actual])


func assert_true(actual: bool, msg := "") -> void:
	_new_assert_called()
	if not actual:
		_test_case_failures.append("%s expected true, got '%s'" % [msg, actual])


func assert_false(actual: bool, msg := "") -> void:
	_new_assert_called()
	if actual:
		_test_case_failures.append("%s expected false, got '%s'" % [msg, actual])
#endregion

#region HELPERS
func get_test_methods() -> Array[Dictionary]:
	return get_method_list().filter(_is_method_a_test)

func _is_method_a_test(data: Dictionary) -> bool:
	return data.get("name", "").begins_with(_test_case_TEST_METHOD_PREFIX) and data.get("args", []).is_empty()


func _test_case_clean_itself() -> void:
	_test_case_failures.clear()
	_test_case_assertion_count = 0

func _test_case_has_failed() -> bool:
	return not _test_case_failures.is_empty()

func _test_case_get_failures() -> Array[String]:
	return _test_case_failures
#endregion
