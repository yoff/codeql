/**
 * @name Escaping
 * @kind problem
 * @problem.severity warning
 * @id java/escaping
 */

import java
import semmle.code.java.ConflictingAccess

from Field f
where
  f = any(ClassAnnotatedAsThreadSafe c).getAField() and
  not f.isFinal() and // final fields do not change
  not f.isPrivate() and
  // We believe that protected fields are also dangerous
  // Volatile fields cannot cause data races, but it is weird to allow changes.
  // For now, we ignore volatile fields, but there are likely bugs to be caught here.
  not f.isVolatile()
select f, "Potentially escaping field"
