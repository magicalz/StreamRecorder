# Stream Recorder  
这是一个视频直播的推流/录制工具，支持youtube/twitch/twitcasting/bilibili等主流直播平台  
本项目源于[live-stream-recorder](https://github.com/printempw/live-stream-recorder)，在此基础上进行了大量魔改，主要是增加了自动运行、自动备份、自动清理等功能，以及使用配置文件大幅简化了使用方法，可以做到无人值守的自动推流与录制

### 如何配置本工具
+ 配置文件
  + global.config  
  全局配置文件，用于配置推流地址，视频保存目录等  
  具体参数说明:  
  
  > StreamOrRecord  
  可选: stream/record/both，此参数决定是推流还是录制，或者二者兼顾  
  > Savefolder  
  此参数是视频录制保存的根目录  
  > Logfolder  
  Log文件保存的目录  
  > Screenlogfolder  
  Screen Log文件保存的目录，和/etc/screenrc里的screen log路径一致，也可以设置成和Logfolder一样的值    
  > Autobackup  
  可选: on/off，此参数是自动备份开关，选择on则视频录制后会自动备份到指定网盘并删除本地文件  
  > Backupmethod  
  可选: rclone/baidu/both，此参数决定备份方式，可以是rclone或者BaiduPCS-Go，备份到onedrive或者度盘  
  > Saveformat  
  可选: ts/mp4，此参数是视频录制的文件格式  
  > Rcloneremotename  
  此参数是rclone的remote name，在配置rclone的时候remote name相当于网盘的别名  
  > Servername  
  此参数是rclone备份时上传到网盘的目录名称，多个服务器同时运行本工具，需要以不同的服务器名字作为区分  
  > Rtmpurl  
  此参数是推流地址，如rtmp://live.mobcrush.net/stream/115ed1677062e51c7339ebe7f1142a0f66db42cb86a5d27  
  > Twitchkey  
  此参数是Twitch平台的api key，可以在Twitch官网申请，用于Twitch开播检测，如果不监控Twitch频道则可以忽略  
  
  + name.config  
  频道配置文件，用于配置单个频道的具体地址以及推流和备份方式等，可以建立多个  
  具体参数说明:  
  > Interval  
  此参数是开播检测的时间间隔，默认30，即30秒  
  > LoopOrOnce  
  此参数决定程序是一直运行还是单次运行  
  > Backupmethod  
  同global.config，如果在此设置则会覆盖global.config里的值，用于单独设置某个频道的备份方式  
  > StreamOrRecord  
  同global.config，如果在此设置则会覆盖global.config里的值，用于单独设置某个频道是推流还是录制  
  > Rtmpurl  
  同global.config，如果在此设置则会覆盖global.config里的值，用于单独设置某个频道的推流地址  
  > Youtube  
  youtube频道的地址，需要注意的是只需要填写频道ID，如UC1opHUrw8rvnsadT-iGp7Cg  
  > Bilibili  
  bilibili频道的地址，只需要填写频道ID，如14917277  
  > Twitch  
  twitch频道的地址，只需要填写频道ID，如rin_co_co  
  > Twitcast  
  twitcasting频道的地址，只需要填写频道ID，如c:rin_co  
  
### 如何运行本工具    
  ./autorun.sh，程序启动脚本，只需运行一次，会自动遍历配置文件夹里的各个频道并开始推流和录制，每个频道会新建一个screen进程方便随时监控  
  ./autobackup.sh，备份脚本，如果在全局设置里设置为on，则视频录制以后会自动上传到指定网盘并删除本地文件，也可以手动运行  
  ./autoclean.sh，清理脚本，每次备份后会自动调用，也可以手动运行  
  ./closescreen.sh，手动运行，运行后会列出当前活动的screen子进程，输入screen名称关闭指定子进程或者输入all关闭所有子进程  
  ./cleanlog.sh，手动运行，用于清理24小时以上的日志文件和空白文件  
  
### screen log的保存目录  
  screen log是程序运行时screen输出的日志文件，编辑/etc/screenrc，添加以下内容  
  logfile /var/log/screen/screenlog_%t.log  
  新建screen log目录  
  mkdir /var/log/screen  
  chmod 777 /var/log/screen  
  在程序的log目录下建立screen log目录的软链接  
  ln -s /var/log/screen /home/recorder/StreamRecorder/log/screen  

### Twitcasting频道的录制  
  Twitcasting需要livedl的支持，下载并放到StreamRecorder根目录即可  
  wget https://github.com/yayugu/livedl/releases/download/20181215.36/livedl  
  chmod +x livedl  
### 开机自启   
  vi /etc/rc.local  
  添加以下内容，recorder是运行程序的用户名，如果不指定则默认以root用户运行  
  su - recorder -c "/home/recorder/StreamRecorder/autorun.sh  
  
  
  
  
  
