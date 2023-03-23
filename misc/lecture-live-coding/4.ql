import python
import semmle.python.dataflow.new.DataFlow

from DataFlow::MethodCallNode execute, DataFlow::Node cursor
where
  execute.calls(cursor, "execute") and
  cursor.asExpr().(Name).getId() = "cursor" and
  execute.getArg(0).getALocalSource().asExpr().(Call).getFunc().(Attribute).getName() = "format"
select execute
