package main

import (
	"k8s-storage-experiment/storage"
	"os"
	"testing"
)

func TestStorageWriter(t *testing.T) {
	testMsg := "hello world"
	testPath := "/tmp/test-output.txt"

	// Clean up any existing test file
	defer os.Remove(testPath)

	writer := storage.NewWriter(testPath)
	err := writer.Write(testMsg)
	if err != nil {
		t.Fatalf("write failed: %v", err)
	}

	data, err := os.ReadFile(testPath)
	if err != nil {
		t.Fatalf("read failed: %v", err)
	}

	if string(data) != testMsg {
		t.Errorf("expected %s, got %s", testMsg, string(data))
	}
}

func TestWriteHandlerLogic(t *testing.T) {
	testMsg := "test message"
	testPath := "/tmp/handler-test.txt"

	// Clean up any existing test file
	defer os.Remove(testPath)

	// Simulate the handler logic
	err := os.WriteFile(testPath, []byte(testMsg), 0644)
	if err != nil {
		t.Fatalf("write failed: %v", err)
	}

	data, err := os.ReadFile(testPath)
	if err != nil {
		t.Fatalf("read failed: %v", err)
	}

	if string(data) != testMsg {
		t.Errorf("expected %s, got %s", testMsg, string(data))
	}
}
