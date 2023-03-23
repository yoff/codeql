import python

from Call execute, Attribute attr
where
  execute.getFunc() = attr and
  attr.getName() = "execute" and
  attr.getObject().(Name).getId() = "cursor"
select execute
