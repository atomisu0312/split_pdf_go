package s3

import (
	"context"
	"io"
	"log"
	"os"
	"split_pdf_go/util"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go/aws"
)

type BucketBasics struct {
	S3Client *s3.Client
}

// 以下のサイトよりコードを引用
// https://docs.aws.amazon.com/ja_jp/code-library/latest/ug/go_2_s3_code_examples.html
// DownloadFile gets an object from a bucket and stores it in a local file.
func (basics BucketBasics) DownloadFile(bucketName string, objectKey string, fileName string) error {
	result, err := basics.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		log.Printf("Couldn't get object %v:%v. Here's why: %v\n", bucketName, objectKey, err)
		return err
	}
	defer result.Body.Close()
	file, err := os.Create(fileName)
	if err != nil {
		log.Printf("Couldn't create file %v. Here's why: %v\n", fileName, err)
		return err
	}
	defer file.Close()
	body, err := io.ReadAll(result.Body)
	if err != nil {
		log.Printf("Couldn't read object body from %v. Here's why: %v\n", objectKey, err)
	}
	_, err = file.Write(body)
	return err
}

func saveTargetFileInTmp(envPath string) {
	// tmpディレクトリがない場合は作成
	if _, err := os.Stat("tmp"); os.IsNotExist(err) {
		os.Mkdir("tmp", 0777)
	}

	err := util.LoadEnv(envPath)
	if err != nil {
		log.Fatalf("Failed to load .env file: %v", err)
	}

	// AWS SDKの設定をロード
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("ap-northeast-1"))
	if err != nil {
		log.Fatalf("Unable to load SDK config, %v", err)
	}

	// S3クライアントを作成
	s3Client := s3.NewFromConfig(cfg)

	// BucketBasicsのインスタンスを作成
	basics := BucketBasics{
		S3Client: s3Client,
	}

	basics.DownloadFile(os.Getenv("BACKET_NAME"), os.Getenv("FILE_NAME"), "./tmp/tmp.pdf")

}
