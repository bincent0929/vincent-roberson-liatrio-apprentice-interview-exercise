// Covers the "minified JSON" check that Liatrio's apprentice-action
// leaves unfinished. Uses only Node built-ins; no dependencies needed.
import { test } from "node:test";
import assert from "node:assert/strict";

// checks from data at the same endpoint as liatrio's tests
const URL = process.env.ENDPOINT_URL ?? "http://localhost:80/";

test("returns minified JSON", async () => {
  const res = await fetch(URL);
  // checks to make sure the status is good
  assert.equal(res.status, 200);
  // reads the raw body from the endpoint output
  const raw = await res.text();

  // re-serializing the parsed body gives the minified form;
  // it should match exactly what the endpoint sent
  assert.equal(raw, JSON.stringify(JSON.parse(raw)));
});
