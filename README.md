# autobackup
自动备份脚本,支持将网站和数据库打包为zip压缩包并上传自FTP,支持增加密码,打包前执行自定义脚本,支持同时或分别备份数据库和网站文件.

脚本修改自LNMP备份脚本,新增功能:
1)打包更换为zip. 
2)新增压缩包密码. 
3)新增打包前执行命令. 
4)新增备份整个数据库. 
5)支持同时或分别备份数据库和网站文件

预装环境: apt-get install -y lftp zip unzip
备份区分文件和数据库,可以分开备份.  备份数据库:./backup.sh 1  备份文件:./backup.sh 2 全都备份:./backup.sh 9 

######~备份文件存放目录~######
Backup_Home="/home/backup/"

######~需要备份的目录,支持多个,举例:("/home/web1" "/home/web2") ~######
Backup_Dir=("/home/wwwroot/www.xxx.com" "/home/wwwroot/www.xxx2.com")

######~ 备份目录前要执行的命令,比如清理缓存 ~######
Backup_Dir_Shell="cd /home/wwwroot/www.xxx.com/Runtime && rm -rf Html Cache Temp Logs && cd /home/wwwroot/www.xxx2.com/Runtime && rm -rf Html Cache Temp Logs"

######~需要备份的数据库名,支持多个,举例:("db1" "db2") 默认备份整个数据库~######
Backup_Database=("--all-databases")

######~设置压缩包密码~######
ZIP_PassWord='zippass'

######~数据库的配置信息~######
MySQL_Dump="/usr/local/mysql/bin/mysqldump"

MYSQL_UserName='root'
MYSQL_PassWord='pass'

######~是否启用FTP远程备份~######
Enable_FTP=0
######~设置FTP配置信息~######
FTP_Host='192.168.1.1'
FTP_Username='ftpuser'
FTP_Password='ftppass'
FTP_Dir="/"
