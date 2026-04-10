import python

string lazy(Import imp) { if imp.isLazy() then result = "lazy" else result = "normal" }

from Import imp
where imp.getLocation().getFile().getShortName() = "test.py"
select imp.getLocation().getStartLine(), imp.toString(), lazy(imp)
