import ruby
import codeql.ruby.ast.Expr
import codeql.ruby.ast.Constant
import codeql.ruby.ast.Variable

predicate relevantModification(Expr e) {
  e instanceof ClassVariableWriteAccess
  or
  exists(e.(ConstantAssignment).getScopeExpr())
}

from Expr e
where relevantModification(e) and exists(e.getEnclosingCallable())
select e
