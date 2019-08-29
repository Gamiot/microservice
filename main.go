package main

import (
	"log"
	"net/http"
	"time"
)

type timeHandler struct {
	format string
}

func (th *timeHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	tm := time.Now().Format(th.format)
	w.Write([]byte("The time is: " + tm))
}

func main() {
	mux := http.NewServeMux()

	th := &timeHandler{format: time.RFC1123}
	mux.Handle("/", th)

	log.Println("Listening...")
	err := http.ListenAndServe(":8000", mux)

	if err != nil {
		log.Fatalf("Could not start service %v", err)
	}

}
