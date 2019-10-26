# iOS-App-Signer-with-Even

废话不多说，本工具基于老牌签名工具**[ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)**，优化部分如下：
![ sign.png](https://github.com/even-cheng/even-appSigner/blob/master/%20sign.png)
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
6，增加本地ICON一键替换原包内的ICON功能，无需手动解压IPA包内的Assets.car，只需要选择一张1024*1024大小的PNG图标即可同步打包完成替换。
``` 

####如果Github下载太慢或者无法下载，我传了一份到码云：[签名文件](https://gitee.com/even_cheng/iOS-App-Signer-With-Even),[全网影视播放器](https://gitee.com/even_cheng/Miracle-Movie-Player)

####当然，如果你仅仅只是需要签名，那么选择你的包地址-选择你的开发者证书-选择描述文件-开始签名，就这么简单。[查看演示demo](https://www.jianshu.com/p/d66501d704c1)


