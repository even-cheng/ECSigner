# ECSigner
***ECSigner is based on [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)，we have more functions：***
###新增超级签名支持，一键注册设备并创建下载签名证书，完成本地签名：
![ sign.png](https://github.com/even-cheng/ECSigner/blob/master/signOnline.png)
###常规签名流程：
![ sign.png](https://github.com/even-cheng/even-appSigner/blob/master/sign.png)
```
新增：超级签名本地完成，不用进入后台直接注册设备秒签。
```
```
新增：多文件同步签名，无需等待。
```
```
1，增加证书类型区分（企业证书，个人证书，通配符），除了非通配符个人证书以外开放bundle_id,可以自由编辑。
```
```
2，优化带签名IPA文件类型，可以添加网络链接，工具会自动下载包，完成之后开始签名（可选）。
```
```
3，增加素材导出功能，可以选择包之后一键解析并导出Assets.car下的图标到指定文件夹（可选）。
```
```
4，增加渠道文件写入功能，打开之后会在包内自动写入一个channel.txt文件，并填充输入的内容，对于需要分包的APP来说使用率比较高（可选）。
```
```
5，增加自动导出分发plist文件功能，知道itms-service协议的童鞋应该比较了解，非APPstore分发必备（可选）。
```
```
6，增加本地ICON一键替换原包内的ICON功能，无需手动解压IPA包内的Assets.car，只需要选择一张1024*1024大小的PNG图标即可同步打包完成替换,并且不会丢失原项目其他素材（重点！，市面上其他工具只能生成替换applicationIcon,其他放在assets中的素材文件会丢失！）。
``` 


