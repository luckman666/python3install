#!/bin/bash
#Description:python 3.9.0安装脚本

#变量
source_url="https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz"
source_pkg="Python-3.9.0.tgz"
source_doc="Python-3.9.0"

cpu_count=`egrep "flags" /proc/cpuinfo |wc -l`

#程序
check () {
  [ "$USER" != "root" ]&&echo "need be root so that"&&exit 1
  [ ! -x /usr/bin/wget ]&&echo "not found command: wget"&&exit 1 
}


install_python () {
check
#1、download python source package
if ! (wget $source_url &>/dev/null) ;then
   echo "$source_pkg download fail"
   exit 1
fi
#2、Decompression source package
if [ -f $source_pkg ];then
    tar xf $source_pkg
else
    echo "not found package: $source_pkg"
    exit 1
fi

#3、python install pre
if ! (yum -y install gcc-* openssl-* libffi-devel  curses-devel lm_sensors sqlite-devel &>/dev/null);then
    echo "yum install software package fail"
    exit 1
fi



#4、configure python install env
if [ -d $source_doc ];then
    
 
   #5、python configure
   cd $source_doc
   
   sed -i.bak '212s/#//' Modules/Setup.dist
   sed -i '213s/#//' Modules/Setup.dist
   sed -i '214s/#//' Modules/Setup.dist
   
   echo "python configure...please waiting"
   if ./configure --enable-optimizations --with-openssl=/usr/bin/openssl &>/dev/null ;then
 
           #6、python make 
           echo "python make...please waiting"
           if make -j $cpu_count &>/dev/null ;then
          
                #7、python install
                echo "python install...please waiting"
                if make install & > /dev/null;then
                    echo "$source_doc install success"
                else
                    echo "python make install fail"
                    exit 1
                fi
            else
                echo "python make fail"
                exit 1
            fi
    else
         echo "python configure fail"
         exit 1
    fi
else
   echo "not found $source_doc"
   exit 1
fi


post_install

}

 
#Post-installation settings
post_install () {
#update pip tool
pip3 install --upgrade pip

}


#函数调用

install_python && rm -rf $source_doc