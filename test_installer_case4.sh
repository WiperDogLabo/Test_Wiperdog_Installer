#!/bin/bash
#
##############################################################################
# This test case use to test Wiperdog Installer for installing with -ni option
# the remain options will be supplied by expect tool automatically.
# ############################################################################
	if [[ "$1" == "" ]]; then
	   echo "Incorrect parameter !"
	   echo "Usage: /bin/sh test_installer.sh /<path-to-wiperdog-installer-jar-file>"   
	   exit 1
	fi
	echo "*************************************************************************"
	echo "* TEST WIPERDOG INSTALLER "
	echo "**************************************************************************"

	# ========= CASE 4 - with -ni option and no other option =========
	echo  ">>>>> CASE 1: Test installer with  no option <<<<<"
        installerJar="$1"
        javaCommand="$JAVA_HOME/bin/java"
        if [ "$JAVA_HOME" == "" ]; then
            unset javaCommand
            javaCommand=`which java`
            if [ "$javaCommand" == "" ]; then
              echo "Java not found, no JAVA_HOME was set and none java command found on PATH variable, cannot execute"
              exit 1
            fi
        fi

        baseNameCmd=`which basename`
        if [ "$baseNameCmd" == "" ];then
            echo "Command basename not found, cannot perform test"
            exit 1
        fi

        jarFileName=`$baseNameCmd $installerJar`
        curDir=`pwd`
        wiperDogDirName=`$baseNameCmd $installerJar -unix.jar`
        wiperdogPath="$curDir/$wiperDogDirName"

	# Default value, the same as default value in the installer
	# in this test case, these definition is use only for compare the result.
        nettyPort=13111
        jobDir="\${felix.home}/var/job"
        triggerDir="\${felix.home}/var/job"
        jobClassDir="\${felix.home}/var/job"
        jobInstDir="\${felix.home}/var/job"
        mongoDb="127.0.0.1"
        mongoPort=27017
        mongoDbName="wiperdog"
        mongoDbUserPasswd=
        installAsService="yes"
        confirmInput="y"
        policyEmail="testmail@gmail.com"
        mongoDbUser=

expect <<- DONE	
	puts "============== ENVIRONMENT ================="
	puts  "Wiperdog Path: $wiperdogPath"
	puts  "Installer jar: $installerJar"
	puts  "Installer jar file name: $jarFileName"
	puts  "Current directory: $curDir"
	puts  "============================================"

	# Remove old file
	catch { exec rm -rf $wiperdogPath } errorCode
	catch { exec rm -f ./WiperdogInstaller.log } errorCode
        
	spawn $javaCommand -jar $installerJar -ni
	
	#Confirm getting input parameter for pre-configure
	expect "Getting input parameters for pre-configured wiperdog*"
	send " \r"
	exec sleep 1	
DONE
#After installation complete, check the following configuration
echo 
echo 
echo "==================== Check result ========================="
configFileName="$wiperdogPath/etc/monitorjobfw.cfg"
sysPropFileName="$wiperdogPath/etc/system.properties"
echo $configFileName
echo $sysPropFileName
ret="true"

#Check log file
if [ -s $curDir/WiperdogInstaller.log ]; then
	echo "Installer log PASSED"
else
	echo "Checking installer log FAILURE"
	ret="false"
fi
#Check install folder
if [ -s $configFileName ] && [ -s $sysPropFileName ] ;then
	echo "Check installer content PASSED"
else
	echo "Check installer content FAILURE"
	ret="false"
fi
# check nettyPort
nettyPortVal=`/bin/cat $sysPropFileName | /bin/grep netty.port=| /usr/bin/cut -d'=' -f 2` 	
 if [ "$nettyPortVal" == "$nettyPort" ]; then
   echo "Netty port setting PASSED"
 else 
	echo "Checking netty port FAILURE"
	ret="false"
 fi	 
jobDirVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.directory.job= |/usr/bin/cut -d'=' -f 2` 
if [ "$jobDirVal" == "$jobDir" ]; then
	echo "Job directory setting  PASSED"
 else
   echo "Case 1 failure, job directory FAILURE"
   echo "$jobDirVal <> monitorjobfw.directory.job=$jobDir"
   ret="false"
 fi

triggerDirVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.directory.trigger= | /usr/bin/cut -d'=' -f 2` 
 if [ "$triggerDirVal" == "$triggerDir" ]; then
   echo "Trigger directory setting  PASSED"
 else
   echo "Case 1 failure, trigger directory FAILURE"
   echo "$triggerDirVal <> monitorjobfw.directory.trigger=$triggerDir" 
   ret="false"
 fi
 
 jobClassDirVal=`/bin/cat $configFileName | /bin/grep torjobfw.directory.jobcls= | /usr/bin/cut -d'=' -f 2` 
 if [ "$jobClassDirVal" == "$jobClassDir" ]; then
   echo "Jobclass directory setting  PASSED"
 else
   echo "Case 1 failure, job class directory FAILURE"
   echo "$jobClassDirVal <> monitorjobfw.directory.jobcls=$jobClassDir"
   ret="false"
 fi
jobInstDirVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.directory.instances= | /usr/bin/cut -d'=' -f 2`
 if [ "$jobInstDirVal" == "$jobInstDir" ]; then
   echo "Job instance directory setting  PASSED"
 else
   echo "Case 1 failure, job instance directory FAILURE"
   echo "$jobInstDirVal <> monitorjobfw.directory.instances=$jobInstDir"
   ret="false"
 fi
mongoDbVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mongodb.host= | /usr/bin/cut -d'=' -f 2`
 if [ "$mongoDbVal" == "$mongoDb" ];then
   echo "Mongo DB  setting  PASSED"
 else
   echo "Case 1 failure, Mongo DB setting FAILURE"
   echo "$mongoDbVal <> monitorjobfw.mongodb.host=$mongoDb"
   ret="false"
 fi

	
mongoPortVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mongodb.port= | /usr/bin/cut -d'=' -f 2`
 if [ "$mongoPortVal" == "$mongoPort" ];then
   echo "Mongo DB Port  setting  PASSED"
 else
   echo "Case 1 failure, Mongo DB Port setting FAILURE"
   echo "$mongoPortVal <> monitorjobfw.mongodb.port=$mongoPort"
   ret="false"
 fi
mongoDbNameVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mongodb.dbName= | /usr/bin/cut -d'=' -f 2`
 if [ "$mongoDbNameVal" == "$mongoDbName" ]; then
   echo "Mongo DB Name  setting  PASSED"
 else
   echo "Case 1 failure, Mongo DB Name setting FAILURE"
   echo "$mongoDbNameVal <> monitorjobfw.mongodb.dbName=$mongoDbName"
   ret="false"
 fi
mongoDbUserPasswdVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mongodb.pass= | /usr/bin/cut -d'=' -f 2`
 if [ "$mongoDbUserPasswdVal" == "$mongoDbUserPasswd" ]; then
   echo "Mongo DB User Password  setting  PASSED"
 else
   echo "Case 1 failure, Mongo DB User Password setting FAILURE"
   echo "$mongoDbUserPasswdVal <> monitorjobfw.mongodb.pass=$mongoDbUserPasswd"
   ret="false"
 fi
policyEmailVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mail.toMail= |/usr/bin/cut -d'=' -f 2`
 if [ "$policyEmailVal" == "$policyEmail" ];then
   echo "Policy Email  setting  PASSED"
 else
   echo "Case 1 failure, policy email setting FAILURE"
   echo "$policyEmailVal <> monitorjobfw.mail.toMail=$policyEmail"
   ret="false"
 fi
mongoDbUserVal=`/bin/cat $configFileName | /bin/grep monitorjobfw.mongodb.user= | /usr/bin/cut -d'=' -f 2` 
 if [ "$mongoDbUserVal" == "$mongoDbUser" ]; then
   echo "Mongo DB User Password  setting  PASSED"
 else
   echo "Case 1 failure, Mongo DB User Password setting FAILURE"
   echo "$mongoDbUserVal <> monitorjobfw.mongodb.user=$mongoDbUser"
   ret="false"
 fi
echo "FINAL CHECKING RESULT PASS: $ret"
echo "================== End check result ======================="
# Check more 

