package main

import (
	"fmt"
	"k8s-storage-experiment/storage"
	"log"
	"net/http"
)

const dataPath = "/data/output.txt"

func writeHandler(w http.ResponseWriter, r *http.Request) {
	msg := r.URL.Query().Get("msg")
	if msg == "" {
		http.Error(w, "Missing msg parameter", http.StatusBadRequest)
		return
	}

	writer := storage.NewWriter(dataPath)
	err := writer.Write(msg)
	if err != nil {
		log.Printf("Failed to write to file: %v", err)
		http.Error(w, "Failed to write to storage", http.StatusInternalServerError)
		return
	}

	log.Printf("Successfully wrote message: %s", msg)
	fmt.Fprintf(w, "Written: %s\n", msg)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "OK\n")
}

func main() {
	http.HandleFunc("/write", writeHandler)
	http.HandleFunc("/health", healthHandler)

	log.Println("🚀 Server starting on :8080...")
	log.Println("📝 Endpoints:")
	log.Println("  GET /write?msg=<message> - Write message to persistent storage")
	log.Println("  GET /health - Health check")

	log.Fatal(http.ListenAndServe(":8080", nil))
}
