# Covers the "minified JSON" check that Liatrio's apprentice-action
# leaves unfinished. Uses only the standard library; no dependencies needed.
import json
import os
import unittest
import urllib.request

# checks from data at the same endpoint as liatrio's tests
URL = os.environ.get("ENDPOINT_URL", "http://localhost:80/")


class TestMinified(unittest.TestCase):
    def test_returns_minified_json(self):
        with urllib.request.urlopen(URL) as res:
            # checks to make sure the status is good
            self.assertEqual(res.status, 200)
            # reads the raw body from the endpoint output
            raw = res.read().decode("utf-8")

        # locally minifies the raw output
        minified = json.dumps(json.loads(raw), separators=(",", ":"), ensure_ascii=False)
        # checks to make sure that the locally minimized output
        # from the input is the same as the raw output we received
        self.assertEqual(raw, minified)


if __name__ == "__main__":
    unittest.main()
