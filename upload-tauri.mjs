import { S3Storage } from 'coze-coding-dev-sdk';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const storage = new S3Storage({
  endpointUrl: process.env.COZE_BUCKET_ENDPOINT_URL,
  accessKey: '',
  secretKey: '',
  bucketName: process.env.COZE_BUCKET_NAME,
  region: 'cn-beijing',
});

async function main() {
  const filePath = resolve('./tauri-login-app.tar.gz');
  const fileContent = readFileSync(filePath);
  
  console.log('正在上传 Tauri 项目...');
  
  const key = await storage.uploadFile({
    fileContent,
    fileName: 'tauri-login-app.tar.gz',
    contentType: 'application/gzip',
  });
  
  console.log('上传成功！Key:', key);
  
  // 生成 7 天有效期的下载链接
  const downloadUrl = await storage.generatePresignedUrl({
    key,
    expireTime: 7 * 24 * 60 * 60,
  });
  
  console.log('\n========================================');
  console.log('Tauri 登录应用源码下载链接（7天有效）：');
  console.log(downloadUrl);
  console.log('========================================\n');
}

main().catch(console.error);
