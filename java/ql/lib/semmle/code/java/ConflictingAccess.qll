import java
import Concurrency

// Could be inlined
predicate exposed(FieldAccess a) {
  not a.getField().isVolatile() and
  not a.(VarWrite).getASource() = a.getField().getInitializer() and
  not locallySynchronizedOn(a, _, _) and
  not locallySynchronizedOnThis(a, _) and
  not locallySynchronizedOnClass(a, _) and
  not a.getEnclosingCallable() = a.getField().getDeclaringType().getAConstructor()
}

class ExposedFieldAccess extends FieldAccess {
  ExposedFieldAccess() { exposed(this) }
}

// for debug
predicate monitors_full(
  ExposedFieldAccess a, Variable lock, MethodCall lockCall, MethodCall unlockCall
) {
  lock.getType().hasName("Lock") and
  lockCall.getQualifier() = lock.getAnAccess() and
  not lockCall.getMethod().getName() = "unlock" and
  unlockCall.getQualifier() = lock.getAnAccess() and
  unlockCall.getMethod().getName() = "unlock" and
  dominates(lockCall.getControlFlowNode(), unlockCall.getControlFlowNode()) and
  dominates(lockCall.getControlFlowNode(), a.getControlFlowNode())
  // we do not require `a` to dominate `unlick` as the critical region may be exited before `a` is executed
}

// possible heuristic
predicate premonitors(ExposedFieldAccess a, Variable lock) {
  lock.getType().hasName("Lock") and
  exists(MethodCall lockCall |
    lockCall.getQualifier() = lock.getAnAccess() and
    not lockCall.getMethod().getName() = "unlock"
  |
    dominates(lockCall.getControlFlowNode(), a.getControlFlowNode())
  )
}

class ClaimedThreadSafeClass extends Class {
  ClaimedThreadSafeClass() { this.getAnAnnotation().getType().getName() = "ThreadSafe" }

  /**
   * Actions `a` and `b` are conflicting iff
   * they are field access operations on the same field and
   * at least one of them is a write.
   */
  predicate conflicting(ExposedFieldAccess a, ExposedFieldAccess b) {
    // We are only interested in two different operations
    not a = b and
    // on the same non-volatile field on this class
    a.getField() = b.getField() and
    a.getField() = this.getAField() and
    // where at least one is a write
    // wlog we assume that is `a`
    a.isVarWrite()
  }

  predicate unsynchronised(ExposedFieldAccess a, ExposedFieldAccess b) {
    this.conflicting(a, b) and
    not exists(Variable lock |
      this.monitors(a, lock) and
      this.monitors(b, lock)
    )
  }

  predicate monitors(ExposedFieldAccess a, Variable lock) {
    forall(Expr e | this.publicAccess(e, a) | this.monitors_locally(e, lock))
  }

  predicate providesAccess(Method m, Expr e, ExposedFieldAccess a) {
    m = this.getAMethod() and
    (
      a.getEnclosingCallable() = m and
      e = a
      or
      exists(MethodCall c | c.getEnclosingCallable() = m |
        this.providesAccess(c.getCallee(), _, a) and e = c
      )
    )
  }

  Method provicesPublicAccess(Expr e, ExposedFieldAccess a) {
    result.isPublic() and
    this.providesAccess(result, e, a)
  }

  predicate publicAccess(Expr e, ExposedFieldAccess a) {
    exists(Method m | m = this.provicesPublicAccess(e, a))
  }

  predicate relevantExpr(Expr e) { this.publicAccess(e, _) }

  ControlFlowNode toBeDominated(Expr e) {
    this.relevantExpr(e) and
    (
      exists(ExposedFieldAccess a | e = a |
        exists(Assignment asgn | asgn.getDest() = a | result = asgn.getControlFlowNode())
        or
        not exists(Assignment asgn | asgn.getDest() = a) and
        result = a.getControlFlowNode()
      )
      or
      not e instanceof ExposedFieldAccess and
      result = e.getControlFlowNode()
    )
  }

  predicate monitors_locally(Expr e, Variable lock) {
    this.relevantExpr(e) and
    lock.getType().hasName("Lock") and
    exists(MethodCall lockCall, MethodCall unlockCall |
      lockCall.getQualifier() = lock.getAnAccess() and
      not lockCall.getMethod().getName() = "unlock" and
      unlockCall.getQualifier() = lock.getAnAccess() and
      unlockCall.getMethod().getName() = "unlock"
    |
      dominates(lockCall.getControlFlowNode(), unlockCall.getControlFlowNode()) and
      dominates(lockCall.getControlFlowNode(), this.toBeDominated(e))
      // we do not require `a` to dominate `unlick` as the critical region may be exited before `a` is executed
    )
  }
}
