package main

import (
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

type Response struct {
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp"`
}

func main() {
	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(Response{
			Message:   "My name is Vincent Roberson",
			Timestamp: time.Now().Unix(),
		})
	})

	log.Fatal(app.Listen(":3000"))
}
