@abstract
extends Object
class_name SutTestReport

static func report(text: String) -> void:
	if SutTestOptions.get_singleton().bbcode:
		print(text)
	else:
		print_rich(text)

static func report_success(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().success_color, text])

static func report_fail(text: String) -> void:
	report("[color=%s]%s[/color]" % [SutTestOptions.get_singleton().error_color, text])


static func report_running(path: String) -> void:
	SutTestReport.report("[color=%s]Running %s[/color]" % [SutTestOptions.get_singleton().dim_color, path])


static func report_results(results: Array[SutTestResult]) -> void:
	var total_time := 0.0
	var total_runs: int = 0
	var total_failures: int = 0
	var classname := "<unknown>"
	for result: SutTestResult in results:
		total_time += result.duration_usec
		total_runs += 1
		if result.failed():
			total_failures += 1
		classname = result.get_classname()
	
	total_time /= 1_000_000

	var is_success = total_failures == 0

	var run_text = "Tests run: %d" % total_runs
	var failure_text = "Failures: %d" % total_failures

	if is_success:
		run_text = "[color=%s]%s[/color]" % [SutTestOptions.get_singleton().success_color, run_text]
	else:
		failure_text = "[color=%s]%s[/color]" % [SutTestOptions.get_singleton().error_color, failure_text]

	SutTestReport.report("%s, %s, Time elapsed: %.3fs [color=%s]-- in %s[/color]" % [
		run_text,
		failure_text,
		total_time,
		SutTestOptions.get_singleton().dim_color,
		classname
	])


static func report_result_if_failed(result: SutTestResult) -> bool:
	if result == null:
		return false
	
	var failed = result.failed()
	for message: String in result.failures:
		SutTestReport.report_fail("[%s.%s] %s" % [result.get_classname(), result.name, _escape(message)])
	return failed


static func _escape(text: String) -> String:
	return text.replace("[", "[lb]")
