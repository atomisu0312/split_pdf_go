package s3

import (
	"os"
	"syscall"
	"testing"

	"github.com/stretchr/testify/assert" //assertパッケージを追加
)

func TestSaveTargetFileInTmp(t *testing.T) {

	// envファイルを読み込んだ上で、環境変数に格納されたプロパティをもとにファイルをダウンロード
	SaveTargetFileInTmp("../.env")

	//ファイルの存在を確認
	filename := "./tmp/tmp.pdf"
	_, err := os.Stat(filename)

	if pathError, ok := err.(*os.PathError); ok {
		if pathError.Err == syscall.ENOTDIR {
			assert.False(t, true, "Path error: ENOTDIR")
		}
	}

	if os.IsNotExist(err) {

		assert.False(t, true, "File does not exist")
	}

	assert.True(t, true, "File exists")
}
