/**
 * @name Constant modification
 * @description Modifying a constant is a bad idea.
 * @kind problem
 * @problem.severity info
 * @precision high
 * @id rb/constant-modification
 * @tags performance
 */

import ruby
import codeql.ruby.ast.Expr
import codeql.ruby.ast.Constant
import codeql.ruby.ast.Variable
import codeql.ruby.ast.Call

predicate relevantModification(Expr e) {
  e instanceof ClassVariableWriteAccess
  or
  exists(e.(ConstantAssignment).getScopeExpr())
  or
  e.(SetterMethodCall).getReceiver() instanceof ClassVariableAccess
  or
  e instanceof SetterMethodCall
}

from Expr e
where relevantModification(e) and exists(e.getEnclosingCallable())
select e, "Bad monkey!"
