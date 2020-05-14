# ECSigner
***Thank for [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)and[App-Store-Connect](https://github.com/AvdLee/appstoreconnect-swift-sdk)，ECSigner have more functions：***
### Auto register devices, auto create(update) certificate and profile, auto download certificate and profile,also you can auto manage your developer account with App-Store-Connect-SDK in project：
![ sign.png](https://github.com/even-cheng/ECSigner/blob/master/autosign2.png)
![ sign.png](https://github.com/even-cheng/ECSigner/blob/master/aboutaotosign.png)
### resign with local certificate and profile：
![ sign.png](https://github.com/even-cheng/even-appSigner/blob/master/ecsign.png)
####new: auto insert dynamic lib in app
```
1，you can resign multi-file synchronization
```
```
2，Auto Distinguish certificate types（In-house，personal，wildcard*）
```
```
3，you can add a remote link with .ipa，we will auto resign until download done（optional）。
```
```
4，you can unzip and export the assets.car(optional)。
```
```
5，you can write a channel content with .txt file into bundle(optional)。
```
```
6，you can create a plist file for itms-service protocol when export ipa(optional)。
```
```
7，you can use your icon to explace the app's icon, and you won't lose any other assets image files(optional)。
``` 
### How to use:
```
1.go https://appstoreconnect.apple.com/access/api to reply a secret key, you can get your ISSUERID、PrivateKey and PrivateKeyID.
2.if you are first time register certificate，you need to get a CSR file from Keychain assistant（CertificateSigningRequest.certSigningRequest）
3.download the .zip file and unzip it 
4.drag the ECSigner.app into Applications
5.open ECSigner.app, input params in fields, done!
```


