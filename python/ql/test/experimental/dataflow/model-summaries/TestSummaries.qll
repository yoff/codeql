private import python
private import semmle.python.dataflow.new.FlowSummary
private import semmle.python.frameworks.data.ModelsAsData
private import semmle.python.ApiGraphs

private class StepsFromModel extends ModelInput::SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "foo;Member[MS_identity];Argument[0];ReturnValue;value",
        "foo;Member[MS_apply_lambda];Argument[1];Argument[0].Parameter[0];value",
        "foo;Member[MS_apply_lambda];Argument[0].ReturnValue;ReturnValue;value",
        "foo;Member[MS_reversed];Argument[0].ListElement;ReturnValue.ListElement;value",
        "foo;Member[MS_list_map];Argument[1].ListElement;Argument[0].Parameter[0];value",
        "foo;Member[MS_list_map];Argument[0].ReturnValue;ReturnValue.ListElement;value",
        "foo;Member[MS_append_to_list];Argument[0].ListElement;ReturnValue.ListElement;value",
        "foo;Member[MS_append_to_list];Argument[1];ReturnValue.ListElement;value",
        "json;Member[MS_loads];Argument[0];ReturnValue;taint"
      ]
  }
}
