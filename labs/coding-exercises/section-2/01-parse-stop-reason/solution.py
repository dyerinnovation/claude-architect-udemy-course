def next_action(response: dict) -> str:
    """
    Decide what the agent control loop should do next based on the API response.

    Canonical signal is the top-level stop_reason field, not content[0].type.
    """
    if response.get("stop_reason") == "tool_use":
        return "continue"
    return "done"
