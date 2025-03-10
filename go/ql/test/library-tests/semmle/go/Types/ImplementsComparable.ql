import go
import utils.test.InlineExpectationsTest

module ImplementsComparableTest implements TestSig {
  string getARelevantTag() { result = "implementsComparable" }

  predicate hasActualResult(Location location, string element, string tag, string value) {
    // file = "interface.go" and
    tag = "implementsComparable" and
    exists(TypeSpec ts |
      ts.getName().matches("testComparable%") and
      ts.getATypeParameterDecl().getTypeConstraint().implementsComparable()
    |
      ts.getLocation() = location and
      element = ts.getName() and
      value = ""
    )
  }
}

import MakeTest<ImplementsComparableTest>
