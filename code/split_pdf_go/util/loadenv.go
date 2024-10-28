package util

import "github.com/joho/godotenv"

// .envを呼び出します。
func LoadEnv(path string) error {
	// ここで.envファイル全体を読み込みます。
	// この読み込み処理がないと、個々の環境変数が取得出来ません。
	// 読み込めなかったら err にエラーが入ります。
	err := godotenv.Load(path)

	// もし err がnilではないなら、"読み込み出来ませんでした"が出力されます。
	if err != nil {
		//fmt.Printf("読み込み出来ませんでした: %v", err)
		return err
	}
	return err
}
