import python

from Call execute, Attribute attr
where
  execute.getFunc() = attr and
  attr.getName() = "execute" and
  attr.getObject().(Name).getId() = "cursor" and
  execute.getArg(0).(Call).getFunc().(Attribute).getName() = "format"
select execute
