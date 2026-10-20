import { test } from "node:test";
import assert from "node:assert/strict";

const URL = process.env.ENDPOINT_URL ?? "http://localhost:80/";

test("returns minified JSON", async () => {
  const res = await fetch(URL);
  assert.equal(res.status, 200);
  const raw = await res.text();

  assert.equal(raw, JSON.stringify(JSON.parse(raw)));
});
