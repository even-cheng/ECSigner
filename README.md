本项目为Mac端iOS重签名软件，用作项目自测使用，请勿用作非法用途。
***Thank for [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)and[App-Store-Connect](https://github.com/AvdLee/appstoreconnect-swift-sdk)，ECSigner 基于以上开源项目二次开发，增加若干功能：***
### 支持本地签名。可以选择本地文件进行签名：
![ sign.png](https://github.com/even-cheng/even-appSigner/blob/master/ecsign.png)

####支持以下操作：
```
1，支持多文件同时签名
```
```
2，支持自动区分企业证书、个人证书
```
```
3，支持远程下载IPA，完成后自动开始签名。
```
```
4，支持导出包内素材文件（assets.car），并解析出对应素材。
```
```
5，支持生成文本文件并写入内容（分包），然后注入包内。
```
```
6，支持签名完成导出.plist文件，用于itms-service分发。
```
```
7，支持一键替换原包icon。
``` 

### 使用方式:
```
1.将下载的 ECSigner.zip解压，并将APP拖入应用程序,双击打开
2.如果你是新账号，你需要打开钥匙串-证书助理，先请求一个证书并保存本地（CertificateSigningRequest.certSigningRequest）
3.选择需要签名的包和对应的证书文件，点击Start开始签名
4，选择保存位置，确定
5，等待进度条输出Done,XXX，完成签名
```


