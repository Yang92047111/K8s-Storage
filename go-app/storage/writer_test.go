package storage

import (
	"os"
	"testing"
)

func TestWriter_Write(t *testing.T) {
	testPath := "/tmp/writer-test.txt"
	testMsg := "test storage write"

	// Clean up
	defer os.Remove(testPath)

	writer := NewWriter(testPath)
	err := writer.Write(testMsg)
	if err != nil {
		t.Fatalf("Write failed: %v", err)
	}

	// Verify file was created and contains correct data
	data, err := os.ReadFile(testPath)
	if err != nil {
		t.Fatalf("Failed to read file: %v", err)
	}

	if string(data) != testMsg {
		t.Errorf("Expected %q, got %q", testMsg, string(data))
	}
}

func TestWriter_WriteToNonExistentDir(t *testing.T) {
	testPath := "/tmp/nonexistent/writer-test.txt"
	testMsg := "test message"

	writer := NewWriter(testPath)
	err := writer.Write(testMsg)

	// Should fail because directory doesn't exist
	if err == nil {
		t.Error("Expected error when writing to non-existent directory")
		os.Remove(testPath)
	}
}
