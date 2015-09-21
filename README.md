# XcodeGhostChecker
Xcode Ghost Checker.

![](https://github.com/qzs21/XcodeGhostChecker/raw/master/Snapshot/snapshot.png)

# Release
不想编译的就下载这个：[XcodeGhostChecker.zip](https://github.com/qzs21/XcodeGhostChecker/raw/master/Release/XcodeGhostChecker.zip)

# 解决的问题
自己开发的应用已经提交到`AppStore`了，我提交了很多个版本，要一个个去安装抓网络包才能检测我的应用有没有包含`XcodeGhost`代码。幸好我手头有上线前备份的`ipa`包，使用`XcodeGhostChecker`瞬间就能帮你检测所有`ipa`包！

# 功能
* 检测ipa包中是否包含`XcodeGhost`代码
* 批量处理，可以一次性处理多个文件或目录下的`*.ipa`文件

# 处理范围
* 自己编译出来的`ipa`包都可以；
* 归档提交到`AppStore`的包也可以；
* 从`AppStore`下载下来的包不可以检测！因为被加过壳，需要破解后才可以用本工具检测。

# 原理/检验
* [XcodeGhost](https://github.com/XcodeGhostSource/XcodeGhost)的源码已经开放出来，将它编译到自己的程序里；
* 使用[class-dump](https://github.com/nygard/class-dump)工具，输出程序的头文件，定位到中毒的程序会包含的头文件信息，采集这个头文件信息作为对比样本A；
* 再次使用[class-dump](https://github.com/nygard/class-dump)，输出需要检测的程序的头文件信息B；
* 查找B中是否包含样本A来判断`ipa`包是否包含`XcodeGhost`代码。
* 从第三方平台下载未加壳的 `网易云音乐` `联通客户端`，运行工具验证后证明工具有效！

# TODO
* 对`OS X`应用开发不是很熟悉，搞界面浪费了很多时间，要花点时间熟悉
* 优化界面上的显示，特别是等待指示器
* 可以优化解压，不需要解压所有文件
* 对加壳应用的检测方式需要优化（了解加壳后的二进制结构）