/** Provides definitions related to XML parsing in the Woodstox StAX library. */
overlay[local?]
module;

import java
private import semmle.code.java.security.XmlParsers

/**
 * The class `com.ctc.wstx.stax.WstxInputFactory` or its abstract supertype
 * `org.codehaus.stax2.XMLInputFactory2`.
 */
private class WstxInputFactory extends RefType {
  WstxInputFactory() {
    this.hasQualifiedName("com.ctc.wstx.stax", "WstxInputFactory") or
    this.hasQualifiedName("org.codehaus.stax2", "XMLInputFactory2")
  }
}

/** A call to `WstxInputFactory.createXMLStreamReader`. */
private class WstxInputFactoryStreamReader extends XmlParserCall {
  WstxInputFactoryStreamReader() {
    exists(Method m |
      this.getMethod() = m and
      m.getDeclaringType() instanceof WstxInputFactory and
      m.hasName("createXMLStreamReader")
    )
  }

  override Expr getSink() {
    if this.getMethod().getParameterType(0) instanceof TypeString
    then result = this.getArgument(1)
    else result = this.getArgument(0)
  }

  override predicate isSafe() {
    SafeWstxInputFactoryFlow::flowsTo(DataFlow::exprNode(this.getQualifier()))
  }
}

/** A call to `WstxInputFactory.createXMLEventReader`. */
private class WstxInputFactoryEventReader extends XmlParserCall {
  WstxInputFactoryEventReader() {
    exists(Method m |
      this.getMethod() = m and
      m.getDeclaringType() instanceof WstxInputFactory and
      m.hasName("createXMLEventReader")
    )
  }

  override Expr getSink() {
    if this.getMethod().getParameterType(0) instanceof TypeString
    then result = this.getArgument(1)
    else result = this.getArgument(0)
  }

  override predicate isSafe() {
    SafeWstxInputFactoryFlow::flowsTo(DataFlow::exprNode(this.getQualifier()))
  }
}

/** A `ParserConfig` specific to `WstxInputFactory`. */
private class WstxInputFactoryConfig extends ParserConfig {
  WstxInputFactoryConfig() {
    exists(Method m |
      m = this.getMethod() and
      m.getDeclaringType() instanceof WstxInputFactory and
      m.hasName("setProperty")
    )
  }
}

/**
 * A safely configured `WstxInputFactory`.
 */
private class SafeWstxInputFactory extends VarAccess {
  SafeWstxInputFactory() {
    exists(Variable v |
      v = this.getVariable() and
      exists(WstxInputFactoryConfig config | config.getQualifier() = v.getAnAccess() |
        config.disables(configOptionIsSupportingExternalEntities())
      ) and
      exists(WstxInputFactoryConfig config | config.getQualifier() = v.getAnAccess() |
        config.disables(configOptionSupportDtd())
      )
    )
  }
}

private predicate safeWstxInputFactoryNode(DataFlow::Node src) {
  src.asExpr() instanceof SafeWstxInputFactory
}

private module SafeWstxInputFactoryFlow = DataFlow::SimpleGlobal<safeWstxInputFactoryNode/1>;
