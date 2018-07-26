#!/bin/bash
#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
#export AWS_DEFAULT_REGION=us-west-2

#aws s3 cp s3://${bucket_name}/${index_name} ${index_name}

#for pkg in $pkgs
#do
#aws s3 cp s3://${bucket_name}/$pkg .
#done

#yum -y localinstall $pkgs

#cp ${index_name} /var/www/html
echo "Randy-Onica-Website" > /var/www/html/index.html

service apache restart
