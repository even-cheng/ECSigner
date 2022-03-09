## !!! 限时开放iOS版高级会员权限免费使用 >>> [前往下载](https://github.com/even-cheng/ECSigner/releases/tag/5.2.0)

本项目为iOS重签名软件(Mac版源码及iOS版)，本项目仅用作开发自测使用，请勿用作非法用途。
***Thank for [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)and[App-Store-Connect](https://github.com/AvdLee/appstoreconnect-swift-sdk)，ECSigner 基于以上开源项目二次开发，增加若干功能：***
### 支持本地签名。可以选择本地文件进行签名：
![ sign.png](https://github.com/even-cheng/even-appSigner/blob/master/ecsign.png)

#### Mac版支持以下操作：
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

### 使用方式: （介绍：[ECSigner For Mac](https://www.jianshu.com/p/3d2dcd8b8e07)）
```
1.将下载的 ECSigner.zip解压，并将APP拖入应用程序,双击打开
2.如果你是新账号，你需要打开钥匙串-证书助理，先请求一个证书并保存本地（CertificateSigningRequest.certSigningRequest）
3.选择需要签名的包和对应的证书文件，点击Start开始签名
4，选择保存位置，确定
5，等待进度条输出Done,XXX，完成签名
```


## ECSigner For iOS（介绍：[ECSigner For iOS](https://www.jianshu.com/p/745d01f8166b)）， 支持以下功能:
国内快速下载地址(有视频使用介绍)： https://gitee.com/even_cheng/ecsigner-ios
```
1，离线证书重签名
```
```
2，在线开发者账户创建证书超级签
```
```
3，修改原包信息
```
```
4，注入和移除动态库
```
```
5，时间锁加锁和后台同步管理（支持Leancloud服务器及自建服务器）
```
```
6，开发者证书，描述文件，ID，设备的管理和创建
```
```
7，获取设备UDID
```
```
8，下载管理
```
```
9，iCloud文件导入和分享
```
```
10，第三方应用分享导入和导出
```
```
11，应用内分享和安装包
```
```
12，应用信息查看
```
```
13，动态库深度扫描
```
```
14，实时证书状态检测等
```
```
15，重签注入激活码控制模块
```
```
16，应用内网络请求屏蔽模块（http+tcp）
```
```
17，应用有效时间控制控制模块
```



