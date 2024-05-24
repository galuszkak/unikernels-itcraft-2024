package main

import (
	"crypto/rand"
	"crypto/sha512"
	"encoding/hex"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Response struct {
	RandomString string `json:"random_string"`
	Sha512       string `json:"sha512"`
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()

	r.GET("/", func(c *gin.Context) {
		randomString := generateRandomString(1024)
		sha512 := calculateSHA512(randomString)

		response := Response{
			RandomString: randomString,
			Sha512:       sha512,
		}

		c.JSON(http.StatusOK, response)
	})

	r.Run() // listen and serve on 0.0.0.0:8080
}

func generateRandomString(length int) string {
	bytes := make([]byte, length)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}

func calculateSHA512(s string) string {
	hash := sha512.Sum512([]byte(s))
	return hex.EncodeToString(hash[:])
}
