/**
 * Provides default sources, sinks and sanitizers for detecting
 * "prompt injection"
 * vulnerabilities, as well as extension points for adding your own.
 */

import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.Concepts
private import semmle.python.dataflow.new.RemoteFlowSources
private import semmle.python.dataflow.new.BarrierGuards
private import semmle.python.frameworks.data.ModelsAsData
private import semmle.python.ApiGraphs

/**
 * Provides default sources, sinks and sanitizers for detecting
 * "prompt injection"
 * vulnerabilities, as well as extension points for adding your own.
 */
module PromptInjection {
  /**
   * A data flow source for "prompt injection" vulnerabilities.
   */
  abstract class Source extends DataFlow::Node { }

  /**
   * A data flow sink for "prompt injection" vulnerabilities.
   */
  abstract class Sink extends DataFlow::Node { }

  /**
   * A sanitizer for "prompt injection" vulnerabilities.
   */
  abstract class Sanitizer extends DataFlow::Node { }

  /**
   * An active threat-model source, considered as a flow source.
   */
  private class ActiveThreatModelSourceAsSource extends Source, ActiveThreatModelSource { }

  /**
   * A prompt to an AI model, considered as a flow sink.
   */
  class AIPromptAsSink extends Sink {
    AIPromptAsSink() { this = any(AIPrompt p).getAPrompt() }
  }

  private class SinkFromModel extends Sink {
    SinkFromModel() { this = ModelOutput::getASinkNode("prompt-injection").asSink() }
  }

  private class PromptContentSink extends Sink {
    PromptContentSink() {
      exists(API::Node openai, API::Node content |
        openai =
          API::moduleImport("openai")
              .getMember(["OpenAI", "AsyncOpenAI", "AzureOpenAI"])
              .getReturn() and
        content =
          [
            openai
                .getMember("responses")
                .getMember("create")
                .getKeywordParameter(["input", "instructions"]),
            openai
                .getMember("responses")
                .getMember("create")
                .getKeywordParameter(["input", "instructions"])
                .getASubscript()
                .getSubscript("content"),
            openai
                .getMember("realtime")
                .getMember("connect")
                .getReturn()
                .getMember("conversation")
                .getMember("item")
                .getMember("create")
                .getKeywordParameter("item")
                .getSubscript("content"),
            openai
                .getMember("chat")
                .getMember("completions")
                .getMember("create")
                .getKeywordParameter("messages")
                .getASubscript()
                .getSubscript("content")
          ]
      |
        // content
        if not exists(content.getASubscript())
        then this = content.asSink()
        else
          // content.text
          this = content.getASubscript().getSubscript("text").asSink()
      )
    }
  }

  /**
   * A comparison with a constant, considered as a sanitizer-guard.
   */
  class ConstCompareAsSanitizerGuard extends Sanitizer, ConstCompareBarrier { }
}
