
#!/usr/bin/bash

###############
export TERM=xterm
export SHELL=/bin/bash
export ORACLE_BASE=/oracle/app/oracle

MAIL=/usr/mail/${LOGNAME:?}
set +o noclobber
export EDITOR=vi
export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0.0/client

export PATH=$ORACLE_HOME/bin:/usr/bin/perl:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export NLS_LANG=American_America.AL32UTF8
export HIBERNATE_JAR_DIR=/oubihome/hibernate-3.3.2
export JAVA_HOME=/export/home/oubiadm/jdk1.6.0_32
export NLS_LANG=American_America.AL32UTF8
export DATABASE_HOME=$ORACLE_HOME
export ORACLE_CLIENT_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=/usr/lib/lwp:$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:/usr/bin/perl/:/usr/sbin:/usr/bin:/oracle/app/oracle/product/19.0.0.0/client
echo $PATH
echo "OV22"
###############

echo $ORACLE_HOME
echo $PATH


echo 'started from cron' > /home/ratan/BILLED/SCRIPTS/tt.log

bash /home/ratan/BILLED/SCRIPTS/billed_discom_ME.sh PUVNL &

sleep 200

echo 'started from cron' >> /home/ratan/BILLED/SCRIPTS/tt.log

bash /home/ratan/BILLED/SCRIPTS/billed_discom_ME.sh PVVNL &

sleep 200

echo 'started from cron' >> /home/ratan/BILLED/SCRIPTS/tt.log

bash /home/ratan/BILLED/SCRIPTS/billed_discom_ME.sh MVVNL &

sleep 200

echo 'started from cron' >> /home/ratan/BILLED/SCRIPTS/tt.log

bash /home/ratan/BILLED/SCRIPTS/billed_discom_ME.sh DVVNL &


