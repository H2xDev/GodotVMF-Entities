@tool
class_name filter_multi
extends filter_entity

const FILTERS_FIELDS = [
	"Filter01",
	"Filter02",
	"Filter03",
	"Filter04",
	"Filter05"
];

func is_passed(node: Node3D) -> bool:
	var is_or = entity.get("filtertype", 0) == 1;
	var filters_count = 0;
	var passed_count = 0;

	for field in FILTERS_FIELDS:
		var filter = get_target(entity.get(field, ""));
		if not filter:  continue;

		filters_count += 1;

		if filter.is_passed(node) == is_or:
			passed_count += 1;

	if is_or:
		return passed_count > 0;
	else:
		return passed_count == filters_count;

