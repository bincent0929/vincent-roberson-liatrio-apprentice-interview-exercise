// Covers the "minified JSON" check that Liatrio's apprentice-action
// leaves unimplemented (it shows up there as a pending test).
// Runs with Node's built-in test runner; no dependencies needed.
import { test } from "node:test";
import assert from "node:assert/strict";

// CI publishes the container on port 80; override for local runs,
// e.g. ENDPOINT_URL=http://localhost:3000/ node --test tests/
const url: string = process.env.ENDPOINT_URL ?? "http://localhost:80/";

test("should return a minified JSON object", async () => {
    const res: Response = await fetch(url);
    assert.equal(res.status, 200);

    // read the raw body so nothing reformats it before we compare
    const raw: string = await res.text();
    const minified: string = JSON.stringify(JSON.parse(raw));
    assert.equal(raw, minified);
});
