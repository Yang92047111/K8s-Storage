package storage

import (
	"os"
)

type Writer struct {
	FilePath string
}

func NewWriter(filePath string) *Writer {
	return &Writer{FilePath: filePath}
}

func (w *Writer) Write(msg string) error {
	return os.WriteFile(w.FilePath, []byte(msg), 0644)
}
