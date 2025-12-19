class_name NumberFormat
extends RefCounted

const SUFFIXES = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc", "Vg"
]

static func format(value: float, decimals: int = 1) -> String:
	var abs_value := absf(value)
	var sign_str := "-" if value < 0 else ""

	if abs_value < 1000:
		return "%s%d" % [sign_str, int(abs_value)]

	var suffix_index := 0
	var display_value := abs_value

	while display_value >= 1000 and suffix_index < SUFFIXES.size() - 1:
		display_value /= 1000.0
		suffix_index += 1

	# Format with decimals, but trim trailing zeros
	var format_str := "%s%.*f%s" % [sign_str, decimals, display_value, SUFFIXES[suffix_index]]

	# Remove trailing zeros after decimal point
	if "." in format_str:
		format_str = format_str.rstrip("0").rstrip(".")

	return format_str

static func format_rate(value: float) -> String:
	if value == 0:
		return ""
	var prefix := "+" if value > 0 else ""
	return "%s%s/s" % [prefix, format(value)]
