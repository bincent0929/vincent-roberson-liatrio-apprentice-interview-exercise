## !!! The program is tested to work as described !!!
## !!! ROUGH DRAFT: Still need to review !!!

### Go Program description

Found in `./go_http_endpoint/`

Sets up a Go HTTP endpoint that responds with JSON.

The most important parts are the `app.Get("/", func(c *fiber.Ctx) error` and `app.Listen(":3000")`.

`app.Get("/", func(c *fiber.Ctx) error`:
`func(c *fiber.Ctx) error` defines the function that will respond to someone accessing the endpoint when they do a `Get` request. `c *fiber.Ctx` is the most important part here. It is the Fiber context object that you can use to send information to the requester. In this case, it is being used to send JSON data to the requester. If `c.JSON(...)` does end up returning an error, the Fiber handler would return a `500` error to the requester.

`app.Listen(":3000")`:
This is what actually ends up starting the endpoint for access to requesters on the network. It can be accessed at `http://127.0.01:3000` in your browser or through using `curl http://127.0.01:3000` once the program has been run.

### Running the program
To efficiently reproduce the developer environment, you will want to use **VSCode** with the **DevContainers** extension downloaded.

Once your environment is set up, to download the packages and run the program to start the endpoint on your computer locally, execute:
```sh
go run .
```

Then you can access the endpoint at `http://127.0.01:3000` in your browser or run `curl http://127.0.01:3000`.

### Running Docker Image For The Go HTTP Endpoint Program

To build the docker image for the Go HTTP endpoint program run in the root directory of the repository:
```sh
docker build -f go_http_endpoint/http_endpoint.dockerfile -t http-endpoint:test go_http_endpoint
```

That creates and image called `http-endpoint` with its version set to `test`.

Then to run the container:
```sh
docker run -p 3000:3000 http-endpoint:test
```

This runs the test image in a container and opens up port 3000 (for your device to access; or otherwise depending on your firewall) on both the container and your local machine hosting the container for you to access.
