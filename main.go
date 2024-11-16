package main

import (
	"fmt"
	"net/http"
)

func main() {

	fmt.Println("Hello World!")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello World!"))

	})

	http.ListenAndServe(":8080", nil)
}
