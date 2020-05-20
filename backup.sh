#!/bin/bash
#脚本修改自LNMP备份脚本,新增功能:1)打包更换为zip. 2)新增压缩包密码. 3)新增打包前执行命令. 4)新增备份整个数据库. 5)支持同时或分别备份数据库和网站文件
#预装环境: apt-get install -y lftp zip unzip
#备份区分文件和数据库,可以分开备份.  备份数据库:./backup.sh 1  备份文件:./backup.sh 2 全都备份:./backup.sh 9 

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

######~备份文件默认文件名 基本无需修改 7day 是删除超过7天的备份 ~######
TodayWWWBackup=www-*-$(date +"%Y%m%d").zip
TodayDBBackup=alldb-$(date +"%Y%m%d").zip
OldWWWBackup=www-*-$(date -d -7day +"%Y%m%d").zip
OldDBBackup=alldb-$(date -d -7day +"%Y%m%d").zip

Backup_Dir()
{
    Backup_Path=$1
    Dir_Name=`echo ${Backup_Path##*/}`
	zip -9 -q -rP ${ZIP_PassWord} ${Backup_Home}www-${Dir_Name}-$(date +"%Y%m%d").zip ${Backup_Path}
}
Backup_Sql()
{
    ${MySQL_Dump} -u$MYSQL_UserName -p$MYSQL_PassWord $1 | gzip -9 - > ${Backup_Home}db-$1-$(date +"%Y%m%d").sql.gz
}

if [ ! -f ${MySQL_Dump} ]; then  
    echo "mysqldump command not found.please check your setting."
    exit 1
fi

if [ ! -d ${Backup_Home} ]; then  
    mkdir -p ${Backup_Home}
fi

if [ ${Enable_FTP} = 0 ]; then
    type lftp >/dev/null 2>&1 || { echo >&2 "lftp command not found. Install: centos:yum install lftp,debian/ubuntu:apt-get install lftp."; }
fi

if [ $1 == 2 -o $1 == 9 ]; then
	echo "Backup website files..."
	eval $Backup_Dir_Shell
	for dd in ${Backup_Dir[@]};do
		Backup_Dir ${dd}
	done
fi
if [ $1 == 1 -o $1 == 9 ]; then
	echo "Backup Databases..."
	for db in ${Backup_Database[@]};do
		Backup_Sql ${db}
	done
	echo "zip -9 -q -rP ${ZIP_PassWord} ${Backup_Home}${TodayDBBackup} ${Backup_Home}db-*-$(date +"%Y%m%d").sql.gz"
	rm -f ${Backup_Home}db-*-$(date +"%Y%m%d").sql.gz
fi
echo "Delete old backup files..."
rm -f ${Backup_Home}${OldWWWBackup}
rm -f ${Backup_Home}${OldDBBackup}

if [ ${Enable_FTP} = 0 ]; then
    echo "Uploading backup files to ftp..."
    cd ${Backup_Home}
    lftp ${FTP_Host} -u ${FTP_Username},${FTP_Password} << EOF
cd ${FTP_Dir}
mrm ${OldWWWBackup}
mrm ${OldDBBackup}
mput ${TodayWWWBackup}
mput ${TodayDBBackup}
bye
EOF

echo "complete."
fi
