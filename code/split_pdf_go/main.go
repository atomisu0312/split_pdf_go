package main

import (
	"flag"
	"fmt"
	"os"
	"split_pdf_go/s3"

	"github.com/pdfcpu/pdfcpu/pkg/api"
)

func main() {
	// s3にファイルをダウンロードする処理
	s3.SaveTargetFileInTmp("./.env")

	// 環境変数 START_PAGE を取得
	envValueStart, existsStart := os.LookupEnv("START_PAGE")

	if !existsStart {
		envValueStart = "1" // デフォルト値
	}

	// 環境変数 END_PAGE を取得
	envValueEnd, existsEnd := os.LookupEnv("END_PAGE")

	if !existsEnd {
		envValueEnd = "2" // デフォルト値
	}

	// アプリ引数＞環境変数＞デフォルト値の順で優先度を持たせる
	var splitnumStart = flag.String("start", envValueStart, "split start")
	var splitnumEnd = flag.String("end", envValueEnd, "split start")
	flag.Parse()

	// splitnumStart と splitnumEnd をハイフンで繋げた新しい文字列を作成
	splitRange := []string{fmt.Sprintf("%s-%s", *splitnumStart, *splitnumEnd)}

	// pdfの分割処理の実体
	api.TrimFile("./tmp/tmp.pdf", "output.pdf", splitRange, nil)

	// s3にファイルをアップロードする処理
	s3.UplodTargetFileInSpritRange("./.env", fmt.Sprintf("%s-%s", *splitnumStart, *splitnumEnd))
}
