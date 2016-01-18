> 不作死就不会死， 不捣鼓就不会活 -- via 菲利克斯·肖恩莱特

什么是作死？作死就是不懂原理乱写代码，不懂环境乱配，不懂工具乱用，打掉一个 bug 再怀上一个 bug，伤元气瞎折腾。

什么是捣鼓？捣鼓和作死相反，在解决问题时力求寻因导果，既能解决问题，又能学到新知识拓展新视野。

在最近折腾 VPS 的时候，我就不断在作死，才捣鼓出了新乐趣，写下来和大家分享一下。

作为一个没有服务器端编程经验的小前端，为何要去折腾 VPS 呢？因为能学到很多东西啊，举几个栗子:

- 搭建个博客写点文章啊

- 既然搭建博客了，那要搞域名啊、CDN啊、加缓存啊、打补丁啊、流量分析啊、性能分析啊、写主题啊、优化访问速度啊、提高 SEO 啊

- 搭建个 VPN/shadowsock 配个代理锻炼锻炼身体又能科学上网啊，还可能省点钱啊

- 哎呀好多操作都是 Linux 还是纯命令行操作的，能学到不少 Linux 知识啊

- 女朋友不陪你折腾你还可以折腾 VPS 啊

# 从购买一个 VPS 开始

要过情人节，首先你得上淘宝买个不会漏气的女朋友。

同理，你想折腾 VPS 你得买个靠谱的服务器。

比如，你想访问速度快一些，可以选择购买腾讯云或阿里云提供的服务器；如果你想更自由一些，可以选择国外 Linode 或者 DigitalOcean 等提供的服务器。选择腾讯云可以使用[我们的推荐链接](http://www.qcloud.com/redirect.php?redirect=1001&cps_key=50b46969b6fa53f1334070ccf5a941d0), 选择 Linode 则可以使用[这个链接](https://www.linode.com/?r=e815823fd4ebad47aef51ae07250b626d30b7f40)。腾讯云最低配只需 65块，Linode最低配也只需要10美金，具体的配置和价格，可以自己去仔细对比下。

好了，有了充气娃娃，噢不，是服务器，我们就可以放心地上了。

使用 ssh 进行登录，假定服务提供商给你的 IP 是 11.22.33.44, 帐号是 root, 密码是 passwd：

```
$ ssh root@11.22.33.44
```

输入密码，第一次登录后建立公钥，我们就和成功上到了服务器。

接着要怎么玩呢？什么姿势舒服就怎么玩嘛。

好了，文章到此结束，我回家找女朋友了。

------------我是回家的分界线------------

快递还没到，我先上一下 VPS 玩一玩好了。

# 快速实战，试手 VPS 迁移

哎呀~ 想起不少人吐槽过我们团队的 [博客](http://www.alloyteam.com/) 打开速度太慢了，都超过了 12 秒，这怎么能忍？

没办法，忍辱负重，我只能趁女朋友还没到之前，快速优化一下（希望 12 秒内可以解决）。

嗯，先分析下博客为什么访问那么慢？

1. 服务器在国外，国内连接过去太远了！

2. 使用的是 Wordpress 程序，安装了不少冗余插件！

3. HTTP 请求数量太多了，就和女生上厕所一样，得排队才能完啊！

4. Google Analytics 等一些服务器已经被墙！

5. 用户上传图片太大，没有经过压缩处理！

好吧，那我们就先进行初步的优化。

# VPS 数据迁移

服务器搬家到国内，也就是 Linode 别人家搬回自己家腾讯云，得带上老老少少一家人：

- 网站代码

- Nginx 配置

- 数据库数据

嗯，学到的第一个 linux 终于派上了用场，将这些数据打包：

```
// tar 将文件进行打包
// -c 表示创建归档
// -z 表示使用 gzip 压缩
// -v 表示打包时显示进度
// -f 指定压缩后的文件名，如 all.tar.gz 
$ tar -czvf  all.tar.gz /path/to/sites  /path/to/nginx.conf /path/to/database
```
好了，数据量不小，打包后的文件非常大，问题就来了，选哪个交通工具呢？

- wget 或 curl 简单便携

- ftp          也是简单便携

- scp          加密传输

- rsync        增量传输 

- dropbox      中转传输 

wget 或 curl 和 ftp 下载的方式很简单。

scp 和 rsync下载的方式是加密传输，也常用于两个主机之间进行复制文件（需要先建立 ssh 连接）。

scp 使用加密进行传输，可以在两个主机中进行复制：

```
// 先登录 A 主机后，将 B 主机 11.22.33.44 上的 /home/data/ 复制到 A 主机下的 /home/data/
// -r 表示遍历复制目录下的所有文件
$ scp -r root@11.22.33.44:/home/data/ /home/data/ 
// 若为建立 ssh 连接，则输入后需要输入 A 主机的登录密码
```

rsync 传输也加密，但能将文件夹、文件等的权限等信息也保存下来，采用流式传输，同时是一种增量备份的算法在支持，效率较高：

```
// 先登录 A 主机后，将 B 主机 11.22.33.44 上的 /home/data/ 复制到 A 主机下的 /home/data/
// -a 表示使用归档模式，保持所有文件属性
// -v 表示显示传输进度
// -r 表示遍历复制目录下的所有文件
// -z 表示进行压缩处理
// -e 指定一些端口信息
$ rsync -avrz -e 'ssh -p 22' root@115.159.49.126:/home/data  /home/data/
```

嗯，小结一下：

- 对于单次传输来看，可以使用 wget/curl/ftp;

- 对于重要数据，可以使用 scp 来传输;

- 如果有日常备份的需要，可以使用 rsync 来传输（增量备份）;

然后，在这次搬家中，这些工具都没什么卵用，腾讯云和 Linode 就像情侣，终究输给了距离：国内外物理距离太远了，都只有几K/s的传输速度，说什么距离不是问题山盟海誓爱你加密都没用。

感情出现危机，自然就需要云备胎作为支持。

也就是使用 Dropbox 或百度云进行中转。

[Dropbox](https://www.dropbox.com/developers/apps) 服务器也在国外，果真是和 Linode 近水楼台先得月，传输速度高达 5M/s, 正当腾讯云准备好一切将一家老少迎接回家时，却又被判了死刑：Dropbox 再高再帅再快也在墙外啊，门不当户不对你们不可以结婚！这时候还有个 [bypy](https://github.com/houtianze/bypy) 的百度云第三方接口可以舒缓下情绪，可这个接口非官方支持，不确定是否可靠，不可作为长期的备份方案，我也无力再爱，所以也没再出轨。

这个故事告诉我们，生活就是如此无奈，我们活在别人界定的环境里，不让你玩你就是不能玩！

等到我们下一代出生时，他们已然不知道这世界上有谷歌、推特、脸书，只有我们知道我们自由的圈子越来越小。

扯远了，回到正题。

既然数据已经在了 Dropbox 中转区，数据搬迁也是一次性的，索性就停止了作死，使用 sftp 将压缩包下载到了本地，同样再使用 sftp 将数据上传到了新服务器上。

# VPS 环境搭建与恢复

接着的事情就简单了，新服务器上恢复环境。

- 安装好所需要的工具（如 Nginx/Mysql/PHP/Git 等)

```
$ apt-get install nginx mysql-server mysql-client php5-fpm
```

- 配置好所需要的用户和权限

添加用户：

```
// 添加新用户 laixiaolai
$ useradd laixiaolai
// 给新用户设置密码
$ passwd ***********
```

添加用户组：

```
$ groupadd handsomeboys
// 将 laixiaolai 加入这个用户组
$ usermod -G handsomeboys laixiaolai
```

设置一些目录的归属：

```
// 授予 laixiaolai 一个池塘
$ chown -R laixiaolai:handsomeboys /data/girlpool
```

有趣吧，在 linux VPS 下，自己掌控用户和权限的感觉，好像我这一匹野马拥有了一个草原呐~

- 恢复数据库备份

不同数据库自有不同的恢复指令，简单举 mysql 做个栗子：

```
// 将 dump_girls_db.sql 这个数据库备份，导入到本机 localhost 的 girls_db 数据库中
// -h 表示主机名
// -u 表示用户名，注意这里是 mysql 的用户名而不是 VPS 服务器的用户名
// -p 表示输入密码
$ mysql -hlocalhost -uroot -p girls_db < dump_girls_db.sql
```

- 启动所需要的服务

启动各种服务

```
// 启动各种程序
$ service nginx start
$ service php5-fpm start
$ service mysql
// 重启和关闭类似
// service nginx stop
```

作死点：注意新旧机子的系统差异，以及新旧软件的配置差异，比如 ubuntu 系统上装的是 php5-fpm 而在 cent 系统中可能就是 php-fpm，不同系统或者不同版本软件安装后，默认用户、权限可能也不一致。
所以，出了问题应该这么排查：

- 需要的依赖都装完了么

- 需要的软件都启动正常么，如 $ service nginx status 查看 Nginx 是否运行正常

- 启动程序的用户和用户组对么，如 $ chown -R userA:group1 /data/ 将 /data/ 的拥有权赋予 group1 用户组中的用户 userA 

- 程序对特定的目录或文件有足够的权限么，如 $ chmod 777 autobackup.sh 给这个 shell 执行权限

- 知道怎么看各种错误日志么，如 $ tail /var/log/nginx/nginx_error.log 查看 nginx 的错误日志

到了这里，一家老少都搬回了国内安顿好了，这时候就可以开启下一步了：改善他们的生活。

# 博客服务器简单优化

把玩博客只是把玩 VPS 的一个小部分，这里就简单介绍下基于 Wordpress 程序的博客优化过程：

- 删除冗余插件，这个没得说了，清理冗余的不靠谱的插件

- 批量压缩图片等静态资源文件，配合 gulp/grunt 插件使用即可，或使用 wordpress 插件

- 静态资源 CDN 化，迁移到腾讯云 CDN 上，减轻 HTTP 请求压缩，加快访问速度

- 开启数据库级别的缓存

- 开启 PHP 程序级别的缓存

- 使用 wp-super-cache 插件开启静态页面生成

经过简单处理后，博客访问速度大大提升了，当然，还可以继续优化下去。

常访问我们 [博客](http://www.alloyteam.com) 的朋友，这时候应该能感觉到访问速度有提升吧？欢迎关注我们团队的博文分享。

# VPS 数据要备份备份备份！

不怕一万就怕万一，有数据备份习惯的人总是不会吃亏，这和要有备胎是一样的道理。

需要备份的数据和之前说过要迁移的数据是差不多的，而备份和迁移的区别在于：

- 备份需要定期进行

- 备份可能需要保留多版本

- 备份存在多个物理机上最好（异地容灾）

- 备份有时候需要实时备份（增量传输）

- 及时删除冗余备份

- 备份应该切片，方便快速恢复

那么，可选的方式是怎样的呢？

- 完整物理机全盘备份，这个需要服务器提供商支持（Linode 支持，而国内云都暂不支持）

- 使用 ftp 定时备份，需要时可以手动进行（手动肯定不如自动）

- 使用 rsync 增量安全备份，可以设置多个物理机分时备份（异地容灾）

- 使用 Dropbox（Dropbox 官方 API 提供，但被墙）

- 使用 cron + git 的方式定时备份（自定义 cron 定时任务，加上 git 打标签进行版本管理）

最优方式是 rsync/cron+git 啦，rsync 不再赘述，介绍下 cron+git 方式吧。

# cron 自动执行定时任务

举个栗子，我想要备份一个文件 /data/sites/laiblog/content/data/ghost.db：

要使用 Git 将数据进行自动备份，先编写 /data/sites/laiblog/autobackup.sh 脚本

```
#!/bin/sh
# PATH=/opt/someApp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# 获取当前时间
DATE_ALL=`date +%Y-%m-%d_%H.%M.%S`
# 切换到 git 项目目录
cd /data/sites/laiblog/
# 备份这个 ghost.db 文件
# 注意要指定绝对路径，因为测试时你使用相对路径自然是能执行成功
# 但 cron 执行这个 shell 时，所在的目录和你测试时可能不一致，导致找不到路径
# 添加文件修改
git add /data/sites/laiblog/content/data/ghost.db
git commit -m "自动备份"
// 推送要远程仓库备份
git push
# 用时间戳打 tag 并推送到仓库，方便找到这个版本
# v$DATE_ALL 表示以时间为 tag
git tag -a v$DATE_ALL -m 'auto backup'
git push origin v$DATE_ALL:v$DATE_ALL
```

注意要设置这个文件为可执行模式：

```
$ chmod 755 /data/sites/laiblog/autobackup.sh
```

再使用 crontab 设置定时任务

```
// 编辑 crontab 任务
$ crontab -e
```

接着在打开的文件中添加：

```
# 格式是：m    h    dom   mon   dow   command
# 即     分钟 小时  日期  月份   周几   命令
# dom  是 day of month
# mon  是 month
# dow  是 day of week
# 如以下：每天凌晨 4 点 59 分执行 autobackup.sh 的脚本
# 2> 表示将错误输出到 crontab-autobackup.log 中，调试时有用
59 4 * * * /data/sites/laiblog/autobackup.sh 2> /data/sites/laiblog/crontab-autobackup.log
```

注意这个 autoback.sh 脚本使用 git push 时并没有输入帐号密码，是因为设置了全局使用 ssh 连接 git 仓库的方式。

# 免输入帐号密码使用 git pull/push

使用你的邮箱生成密钥/公钥：

```
$ ssh-keygen -t rsa -b 4096 -C "your_email@gmail.com"
```

生成后打开 ssh-agent:

```
$ eval "$(ssh-agent -s)"
```

将公钥添加到 ssh-agent 中：

```
ssh-add ~/.ssh/id_rsa
```

复制生成的公钥：

```
$ pbcopy < ~/.ssh/id_rsa.pub
```

将公钥添加到 git 仓库的（如 github 的添加地址为：https://github.com/settings/ssh）

修改远程仓库的 url 为 ssh 方式，如：

```
$ git remote set-url origin git@github.com:yourUserName/yourProjectRepo.git 
```

这么一来，就不用每次 git pull/push 都要输入帐号密码了。



# 使用 VPS 做梯子科学上网？

对于想`饭强`锻炼身体科学上网的方法，如果你买的是国外 VPS 比如 [Linode](https://www.linode.com/?r=e815823fd4ebad47aef51ae07250b626d30b7f40)，就可以这么干。

## 安装 pptpd 搭建 VPN

按 [这个教程](https://help.ubuntu.com/community/PPTPServer) 走就行了。

注意，在mac上配置 vpn，要把 Send all traffic over VPN connection 勾选上，否则无法正常使用。

设置 mac 在断线后自动重连可参考 [这段脚本](http://lifehacker.com/5932886/force-mac-os-x-to-automatically-reconnect-to-vpn)

买个 VPS 搭建个 VPN，其实就省去买 VPN 的钱啦~ 设置多个帐号密码，多用户共享也是爽歪歪~

## 安装 shadowsocks

除了使用 pptpd 搭建 VPN，还可以使用 shadowsocks 进行科学上网，更快更便捷，谁用谁知道！

首先在 VPS 上安装服务端：

```
$ sudo apt-get install python-pip
$ pip install shadowsocks
// 注意以下的 PORT 和 PASSWORD 自定义。
$ ssserver -p PORT -k PASSWORD -m rc4-md5 -d start 
```

如果你是用 mac 的话，安装客户端。

下载 http://shadowsocks.org/en/index.html

设置：

```
服务器地址为 VPS 的 id，
端口为上面设定的  PORT，
密码为上面设定的 PASSWORD，
加密方式为上面设定的  rc4-md5
```

然后就可以科学上网了。

以上设置了一个 PORT 和 PASSWARD 也就只是单用户上网，如果设置多用户的话，维护 /etc/shadowsocks.json：
```
{
    "server":"VPS服务器的IP",
    "local_address": "127.0.0.1",
    "local_port":1080,
    "port_password":{
         // 设置多个用户
         "9000":"PASSWORD9000",
         "9001":"PASSWORD9001",
         "9002":"PASSWORD9002",
         "9003":"PASSWORD9003",
         "9004":"PASSWORD9004"
    },
    "timeout":300,
    "method":"rc4-md5",
    "fast_open": false
}
```

额，最近 ss 的作者被约谈了，日后还能不能用也是未知也是难。。。

# VPS 折腾总结

- 不作死就不会死，Linux 中用户和权限相关的知识非常重要，这往往决定了程序是否能够正常运行以及服务器是否安全。

- 边折腾边学习，掌握问题背后的原因。

- 学习到很好有趣的命令，比如：

```
// 查看硬盘（剩余）空间
$ df -h 

// 查看文件夹占用空间
// -d 表示计算 1 层目录，利用这个我们可以从根目录开始执行这个指令，层层下去查看到底是哪里占用了太多空间以瘦身
$ du -h -d 1

// 查看特定文件并计算数量
// find ./ 表示在当前目录开始查找
// -name "*.png" 表示查找以 .png 为后缀的文件
// | 是 *nix 中流式传输的思想，意为将前面程序的输出结果，当作后续程序的输入源
// wc -l 表示计算数量，并将其列出
$ find ./ -name "*.png" | wc -l
```

