from flask import Flask, request
from agents import Agent, Runner
from guardrails import GuardrailAgent

@app.route("/parameter-route")
def get_input():
    input = request.args.get("input")

    goodAgent = GuardrailAgent(  # GOOD: AGent created with guardrails automatically configured.
        config=Path("guardrails_config.json"),
        name="Assistant",
        instructions="This prompt is customized for " + input)

    badAgent = Agent(
        name="Assistant",
        instructions="This prompt is customized for " + input  # BAD: user input in agent instruction.
    )
