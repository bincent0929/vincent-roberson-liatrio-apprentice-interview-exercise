package main

import (
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

type Response struct {
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp"`
	Test      string `json:"test"`
}

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		// This returns as a minified JSON object
		return c.JSON(Response{
			Message: "My name is Vincent Roberson",
			// needs to be Milli to conform with
			// the testing precision
			Timestamp: time.Now().UnixMilli(),
			Test:      "This will be deployed",
		})
	})

	log.Fatal(app.Listen(":3000"))
}
