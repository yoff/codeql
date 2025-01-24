import java
import Concurrency

pragma[inline]
ControlFlowNode toBeDominated(Expr e) {
  exists(ExposedFieldAccess a | e = a |
    exists(Assignment asgn | asgn.getDest() = a | result = asgn.getControlFlowNode())
    or
    not exists(Assignment asgn | asgn.getDest() = a) and
    result = a.getControlFlowNode()
  )
  or
  not e instanceof ExposedFieldAccess and
  result = e.getControlFlowNode()
}

module Monitors {
  newtype Monitor =
    VariableMonitor(Variable v) { v.getType().hasName("Lock") or locallySynchronizedOn(_, _, v) } or
    InstanceMonitor(RefType thisType) { locallySynchronizedOnThis(_, thisType) } or
    ClassMonitor(RefType classType) { locallySynchronizedOnClass(_, classType) }

  predicate locallyMonitors(Expr e, Monitor m) {
    exists(Variable v | m = VariableMonitor(v) |
      locallyLockedOn(e, v)
      or
      locallySynchronizedOn(e, _, v)
    )
    or
    exists(RefType thisType | m = InstanceMonitor(thisType) |
      locallySynchronizedOnThis(e, thisType)
    )
    or
    exists(RefType classType | m = ClassMonitor(classType) |
      locallySynchronizedOnClass(e, classType)
    )
  }

  /** Holds if `e` is synchronized on the `Lock` `lock` by a locking call. */
  predicate locallyLockedOn(Expr e, Variable lock) {
    lock.getType().hasName("Lock") and
    exists(MethodCall lockCall, MethodCall unlockCall |
      lockCall.getQualifier() = lock.getAnAccess() and
      not lockCall.getMethod().getName() = "unlock" and
      unlockCall.getQualifier() = lock.getAnAccess() and
      unlockCall.getMethod().getName() = "unlock"
    |
      dominates(lockCall.getControlFlowNode(), unlockCall.getControlFlowNode()) and
      dominates(lockCall.getControlFlowNode(), toBeDominated(e))
      // we do not require `e` to dominate `unlock` as the critical region may be exited before `e` is executed
    )
  }
}

module Modification {
  import semmle.code.java.dataflow.FlowSummary

  predicate isModifying(FieldAccess a) {
    a.isVarWrite()
    or
    exists(Call c | c.(MethodCall).getQualifier() = a |
      not a.getType().hasName("Lock") and
      isModifyingCall(c)
    )
    or
    exists(ArrayAccess aa, Assignment asa | aa.getArray() = a | asa.getDest() = aa)
  }

  predicate isModifyingCall(Call c) {
    exists(SummarizedCallable sc, string output, string prefix | sc.getACall() = c |
      sc.propagatesFlow(_, output, _, _) and
      prefix = "Argument[this]" and
      output.prefix(prefix.length()) = prefix
    )
  }
}

Class claimedThreadSafe() { result.getAnAnnotation().getType().getName() = "ThreadSafe" }

// Could be inlined
predicate exposed(FieldAccess a) {
  a.getField() = claimedThreadSafe().getAField() and
  not a.getField().isVolatile() and
  not a.(VarWrite).getASource() = a.getField().getInitializer() and
  not a.getEnclosingCallable() = a.getField().getDeclaringType().getAConstructor()
}

class ExposedFieldAccess extends FieldAccess {
  ExposedFieldAccess() { exposed(this) }
}

class ClaimedThreadSafeClass extends Class {
  ClaimedThreadSafeClass() { this = claimedThreadSafe() }

  /**
   * Actions `a` and `b` are conflicting iff
   * they are field access operations on the same field and
   * at least one of them is a write.
   */
  predicate conflicting(ExposedFieldAccess a, ExposedFieldAccess b) {
    // We allow a = b, since they could be executed on different threads
    // We are looking for two operations
    // on the same non-volatile field
    a.getField() = b.getField() and
    // on this class
    a.getField() = this.getAField() and
    // where at least one is a write
    // wlog we assume that is `a`
    // We use a slightly more inclusive definition than simply `a.isVarWrite()`
    Modification::isModifying(a)
  }

  predicate unsynchronised(ExposedFieldAccess a, ExposedFieldAccess b) {
    this.conflicting(a, b) and
    not exists(Monitors::Monitor m |
      this.monitors(a, m) and
      this.monitors(b, m)
    )
  }

  predicate monitors(ExposedFieldAccess a, Monitors::Monitor m) {
    forall(Expr e | this.publicAccess(e, a) | Monitors::locallyMonitors(e, m))
  }

  predicate providesAccess(Method m, Expr e, ExposedFieldAccess a) {
    m = this.getAMethod() and
    (
      a.getEnclosingCallable() = m and
      e = a
      or
      exists(MethodCall c | c.getEnclosingCallable() = m |
        this.providesAccess(c.getCallee(), _, a) and
        e = c
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
}
