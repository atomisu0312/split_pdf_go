package main

import (
	"flag"
	"fmt"
	"split_pdf_go/s3"

	"github.com/pdfcpu/pdfcpu/pkg/api"
)

func main() {
	// s3にファイルをダウンロードする処理
	s3.SaveTargetFileInTmp("./.env")

	// アプリ引数を取得し、パースする処理
	var splitnumStart = flag.String("start", "1", "split start")
	var splitnumEnd = flag.String("end", "2", "split start")
	flag.Parse()

	// splitnumStart と splitnumEnd をハイフンで繋げた新しい文字列を作成
	splitRange := []string{fmt.Sprintf("%s-%s", *splitnumStart, *splitnumEnd)}

	// pdfの分割処理の実体
	api.TrimFile("./tmp/tmp.pdf", "output.pdf", splitRange, nil)

	// s3にファイルをアップロードする処理
	s3.UplodTargetFileInSpritRange("./.env", fmt.Sprintf("%s-%s", *splitnumStart, *splitnumEnd))
}
