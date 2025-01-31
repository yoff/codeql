import java
import semmle.code.java.ConflictingAccess

from ClassAnnotatedAsThreadSafe c, FieldAccess a, FieldAccess b
where c.unsynchronised(a, b)
// select c, a, b
select c, a.getField()
