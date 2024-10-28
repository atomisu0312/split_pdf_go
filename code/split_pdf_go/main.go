package main

import (
	"flag"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	//"github.com/pdfcpu/pdfcpu/pkg/pdfcpu"
)

func main() {
	var pdfname = flag.String("n", "test.pdf", "file name")
	var dirname = flag.String("d", "output.pdf", "out put dir")
	var splitnum = flag.String("s", "1-2", "split span")

	flag.Parse()

	splitRange := []string{*splitnum}

	api.TrimFile(*pdfname, *dirname, splitRange, nil)
}
