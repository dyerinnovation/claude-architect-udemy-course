def next_action(response: dict) -> str:
    """
    Decide what the agent control loop should do next based on the API response.

    Args:
        response: the dict returned by anthropic.Anthropic().messages.create()

    Returns:
        "continue" if Claude wants a tool call (stop_reason == "tool_use"),
        "done" otherwise (including when stop_reason is missing).
    """
    # TODO: implement
    pass
