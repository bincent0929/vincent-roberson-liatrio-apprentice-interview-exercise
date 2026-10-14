// Covers the "minified JSON" check that Liatrio's apprentice-action
// Runs with Node's built-in test runner; no dependencies needed.
import { test } from "node:test";
import assert from "node:assert/strict";

// checks from data at the same endpoint as liatrio's tests
const url: string = process.env.ENDPOINT_URL ?? "http://localhost:80/";

// instead of using mocha, this uses node's assertion testing
test("should return a minified JSON object", async () => {
    const res: Response = await fetch(url);
    assert.equal(res.status, 200);

    // reads the raw body from the endpoint output
    const raw: string = await res.text();
    const minified: string = JSON.stringify(JSON.parse(raw));
    // checks to make sure that the locally minimized output
    // from the input is the same as the raw output we recieved
    assert.equal(raw, minified);
});
