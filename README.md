MySQL_Binlog_Table_Filter
-----

####Created because mysqlbinlog can not filter table

###示例 / Example
	./myfiler.pl --tables hello,hi --enable-drop --enable-truncate --src src.sql

###参数
	--tables <tablenames>       筛选要导出的表名，使用英文逗号","分隔多个表名
    --enable-drop               允许DROP语句，可选，默认不允许
    --enable-truncate           允许TRUNCATE语句，可选，默认不允许
    --src <exported sql file>   从指定文件读取

###操作指南
1. 用mysqlbinlog将binlog文件导出成sql文件，使用-d操作符指定数据库。
2. 使用myfilter.pl处理导出的数据库文件，导出结果默认输出到标准输出，可以重定向到一个新的sql文件。
3. 导入处理后的sql文件

###Parameters
	--tables <tablenames>       export tables in tablenames, deliminate by ","
    --enable-drop               enable DROP, optional, default disabled
    --enable-truncate           enable TRUNCATE, optional, default disabled
    --src <exported sql file>   read from sql file

###How To
1. Export binlog file using mysqlbing with -d operator to export the exact database.
2. Use myfilter.pl to parse exported sql file. Result will be printed to stdout, you can redirect the export to a new sql file.
3. Import the parsed sql file into your database.


###Help
Any question please mail to njutczd+gmail.com