import java
import semmle.code.java.ConflictingAccess

from ClaimedThreadSafeClass c, FieldAccess a, FieldAccess b
where c.unsynchronised(a, b)
select c, a, b
