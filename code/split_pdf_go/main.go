package main

import (
	"flag"
	"fmt"
	"split_pdf_go/s3"

	"github.com/pdfcpu/pdfcpu/pkg/api"
	//"github.com/pdfcpu/pdfcpu/pkg/pdfcpu"
)

func main() {
	// s3にファイルをダウンロードする処理
	s3.SaveTargetFileInTmp("./.env")

	var splitnumStart = flag.String("start", "1", "split start")
	var splitnumEnd = flag.String("end", "2", "split start")

	flag.Parse()

	// splitnumStart と splitnumEnd をハイフンで繋げた新しい文字列を作成
	splitRange := []string{fmt.Sprintf("%s-%s", *splitnumStart, *splitnumEnd)}

	api.TrimFile("./tmp/tmp.pdf", "output.pdf", splitRange, nil)
}
