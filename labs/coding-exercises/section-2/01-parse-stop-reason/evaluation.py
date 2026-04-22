"""
Evaluation file for s2-01-parse-stop-reason.

On Udemy, the import below resolves to the student's learner file at test time.
Locally, to dogfood-test the solution, copy solution.py -> learner.py and run
    python -m unittest evaluation.py
"""

import unittest

from learner import next_action


class TestNextAction(unittest.TestCase):
    def test_tool_use_continues(self):
        self.assertEqual(
            next_action({"stop_reason": "tool_use"}),
            "continue",
        )

    def test_end_turn_done(self):
        self.assertEqual(
            next_action({"stop_reason": "end_turn"}),
            "done",
        )

    def test_max_tokens_done(self):
        self.assertEqual(
            next_action({"stop_reason": "max_tokens"}),
            "done",
        )

    def test_stop_sequence_done(self):
        self.assertEqual(
            next_action({"stop_reason": "stop_sequence"}),
            "done",
        )

    def test_missing_stop_reason_done(self):
        self.assertEqual(
            next_action({"content": []}),
            "done",
        )

    def test_full_response_shape_tool_use(self):
        response = {
            "id": "msg_01XFDU",
            "type": "message",
            "role": "assistant",
            "content": [{"type": "tool_use", "name": "get_weather", "input": {}}],
            "stop_reason": "tool_use",
            "usage": {"input_tokens": 42, "output_tokens": 12},
        }
        self.assertEqual(next_action(response), "continue")

    def test_full_response_shape_end_turn(self):
        response = {
            "id": "msg_01ABC",
            "type": "message",
            "role": "assistant",
            "content": [{"type": "text", "text": "Paris."}],
            "stop_reason": "end_turn",
            "usage": {"input_tokens": 10, "output_tokens": 3},
        }
        self.assertEqual(next_action(response), "done")

    def test_none_stop_reason_done(self):
        # stop_reason present but explicitly None (rare but possible)
        self.assertEqual(
            next_action({"stop_reason": None, "content": []}),
            "done",
        )


if __name__ == "__main__":
    unittest.main()
