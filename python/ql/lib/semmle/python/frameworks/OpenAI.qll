/**
 * Provides classes modeling security-relevant aspects of the `openAI`Agents SDK package.
 * See https://github.com/openai/openai-agents-python.
 */

private import python
private import semmle.python.ApiGraphs

/**
 * Provides models for Agent (instances of the `openai.OpenAI` class).
 *
 * See https://github.com/openai/openai-python.
 */
module OpenAI {
  /** Gets a reference to the `openai.OpenAI` class. */
  API::Node classRef() {
    result =
      API::moduleImport("openai").getMember(["OpenAI", "AsyncOpenAI", "AzureOpenAI"]).getReturn()
  }

  /** Gets a reference to a potential property of `openai.OpenAI` called instructions which refers to the system prompt. */
  API::Node getContentNode() {
    exists(API::Node content |
      content =
        classRef()
            .getMember("responses")
            .getMember("create")
            .getKeywordParameter(["input", "instructions"]) or
      content =
        classRef()
            .getMember("responses")
            .getMember("create")
            .getKeywordParameter(["input", "instructions"])
            .getASubscript()
            .getSubscript("content") or
      content =
        classRef()
            .getMember("realtime")
            .getMember("connect")
            .getReturn()
            .getMember("conversation")
            .getMember("item")
            .getMember("create")
            .getKeywordParameter("item")
            .getSubscript("content") or
      content =
        classRef()
            .getMember("chat")
            .getMember("completions")
            .getMember("create")
            .getKeywordParameter("messages")
            .getASubscript()
            .getSubscript("content")
    |
      // content
      if not exists(content.getASubscript())
      then result = content
      else
        // content.text
        result = content.getASubscript().getSubscript("text")
    )
  }
}
