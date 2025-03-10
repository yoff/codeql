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
import codeql.ruby.ast.Operation

predicate accessesFieldOfConstant(MethodCall c) {
  c.getReceiver() instanceof ConstantAccess
  or
  accessesFieldOfConstant(c.getReceiver())
}

predicate setsFieldOfConstant(MethodCall c) {
  accessesFieldOfConstant(c) and
  (
    c instanceof SetterMethodCall or
    c instanceof LShiftExpr
  )
}

from Expr e
where
  setsFieldOfConstant(e) and
  exists(e.getEnclosingCallable()) and
  not e.getLocation().getFile().getAbsolutePath().matches("%test%")
select e, "Bad monkey!"
