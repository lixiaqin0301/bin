package main

import (
	"bytes"
	"fmt"
	"os"
)

func main() {
	dir := "/www/txt"
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}
	err := os.Chdir(dir)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	for _, s := range []string{"", "k", "m"} {
		for i := 1; i < 1024; i++ {
			filesize := i
			switch s {
			case "k":
				filesize = i * 1024
			case "m":
				filesize = i * 1024 * 1024
			}
			if filesize > 100*1024*1024 {
				continue
			}
			filename := fmt.Sprintf("%d%s.txt", i, s)
			genFile(filename, filesize)
		}
	}
}

func genFile(filename string, filesize int) error {
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer f.Close()
	var buf bytes.Buffer
	for i := 0; ; i++ {
		for j := 0; j < 9; j++ {
			fmt.Fprintf(&buf, "%d ", i*10+j)
		}
		fmt.Fprintf(&buf, "%d\n", i*10+9)

		if len(buf.Bytes()) > filesize {
			break
		}
	}
	f.Write(buf.Bytes()[:filesize])
	return nil
}
