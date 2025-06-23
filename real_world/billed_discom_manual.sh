#!/usr/bin/bash

####	CSV to generate BILLED Data in CSV.

####	Changes done on 15-DEC-2021 for Adding of Bill Create Date Time.
####	Field added	: BILL_CRE_DTTM

####	Changes done on 17-MAR-2021 for adding below fields.
####	Field added	: " MTR_NO_RECORDED ", " MTR_MAKE_RECORDED " , " MANUL_BILL_EXCEP"


####	Changes done on 11-MAR-2021 for adding below fields.
####	Field added	: "PREV_RDG_KWH","PREV_RDG_KVAH","PREV_RDG_DATE","CUR_RDG_KWH","CUR_RDG_KVAH","CUR_RDG_DATE","MTR_RDR_NAME","MTR_RDR_AGENCY","MF"'

echo ===================================================================

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

lv_starttime1=`date +%d%m%Y%H%M%S`

lv_Blogfile_nm=`date +%d%m%Y`

mydiscom=$1

if [ $mydiscom == 'PUVNL' ]
then
        mystr='purptapp/purptapp@PUMISPRD'
elif [ $mydiscom == 'PVVNL' ]
then
        mystr='pvrptapp/Pv#sjhdU65@PVMISPRD'
elif [ $mydiscom == 'MVVNL' ]
then
        mystr='mvrptapp/MrrajhmU19@MVMISPRD'
elif [ $mydiscom == 'DVVNL' ]
then
        mystr='dvrptapp/D1bdfhmK21@DVMISPRD'
else
    echo 'errrrrrrrrrrrrrrrrrrrrrrooooooooooorrrrrrrrrrrrrrrrrr'
fi

touch /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

echo 'BILLED : CSV SHELL EXECUTION STARTED' at $lv_starttime1 >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

#########################################################FUNCTION BLOCK START############################################

echo BILLED  : CSV function block started >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

function test_PP() {
 local nrwait_arg
 if [[ -z $1 ]] ; then
 nrwait_arg=2
 else
 nrwait_arg=$1
 fi
 while [[ $(jobs -p | wc -l) -ge $nrwait_arg ]] ; do
 sleep 1;
 done
 }

echo BILLED  : CSV function block end >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

#########################################################FUNCTION BLOCK END############################################


################################################VARIABLE SUBS START##################################################
echo  variable subs starts >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

lv_str='BILLED_'

lvdate=$(date +%d%m%Y)

lv_NRCPUS=48

lv_fold_bl=`date +%d%m%Y`

lvnorunmsg='No CSV made - PK_ACCT_TRXN_MASTER Batch not run today' 

mkdir /home/ratan/BILLED/DATA/$lv_fold_bl

# mkdir PUVNL

echo variable subs ends >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt
################################################VARIABLE SUBS END##################################################


################################################DIV LIST NEW STARTED##############################################

echo BILLED : 'Formation of DIV_LIST_new.txt starts' >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

echo $mystr 

# sqlplus -S purptapp/purptapp@PUMISPRD<<EOD > /home/ratan/BILLED/DATA/$lv_fold_bl/DIV_LIST_NEW.txt
sqlplus -S $mystr <<EOD > /home/ratan/BILLED/DATA/$lv_fold_bl/DIV_LIST_NEW_{$mydiscom}.txt
set head off
set trim on
set pagesize 0
set linesize 32767
set feedback off

select /*+ no_parallel */ distinct discom || '_' || div_sp_id 
from rptuser.tmp_hir 
where discom = '$mydiscom'
and div_Sp_id not like '%9'
order by discom || '_' || div_sp_id
;

EOD

echo BILLED : 'DIV_LIST_new.txt formed' >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

################################################DIV LIST NEW CREATION ENDS##############################################

################################# Batch Run check variable ############################### 

echo BILLED : BATCH RUN CHECK STARTED >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

lvcheckvar=`sqlplus -S $mystr <<EOD
set head off
set trim on
set pagesize 0
set linesize 32767
set feedback off

select to_char(batch_param_dt+1,'DDMMYYYY') DT 
from rptuser.batch_date_ctl 
where batch_name='BILLING';

EOD`


echo BILLED : 'PK_ACCT_TRXN_MASTER LAST RUN ON_'$lvcheckvar  >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt


############################Batch Run check varaible ends #################################

#############################Main block starts###########################################

echo "$lvcheckvar", "$lvdate" 

# if [ "$lvcheckvar" == "$lvdate" ]; 
if [ "$lvcheckvar" == "$lvcheckvar" ]; 

then 

echo BILLED : "Reached if" >>  /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt


for i in $(cat /home/ratan/BILLED/DATA/$lv_fold_bl/DIV_LIST_NEW_{$mydiscom}.txt)
do
echo BILLED PROCESS RUNNING FOR DIVISION $i >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt
#echo $lv_str
my_div=${i:(-9)}
# p_file_nm=$lv_str$i'_'$lvdate.csv
p_file_nm=$lv_str$i'_MAR2023.csv'

#################################################################################################################

# sqlplus -S purptapp/purptapp@PUMISPRD<<EOD > /home/ratan/BILLED/DATA/$lv_fold_bl/$p_file_nm &
sqlplus -S $mystr <<EOD > /home/ratan/BILLED/DATA/$lv_fold_bl/$p_file_nm &
set head off
set trim on
set pagesize 0
set linesize 32767
set feedback off


SELECT  /*+ no_parallel */ '"ACCT_ID","BOOK_NO","SCNO","NAME","ADDRESS","MOBILE_NO","TARIFF_TYPE","SANCTION_LOAD","SANCTION_LOAD_UOM","SUBSTATION","FEEDER","DT","POLE_NO","METER_SERIAL_NBR","METER_READ_REMARK","MR_SOURCE_CODE","BILL_BASIS","DUE_DATE","LAST_PAY_DATE","LAST_PAYMENT_AMOUNT","AMOUNT_PAYABLE","BILL_TYP","BILL_DATE","BILL_CRE_DTTM","BILLED_UNITS","BILL_ID","CA","BILL_INF_FLG","SBM_MACHINE_ID","DISCOM","ZONE_CODE","ZONE_NAME","CIRCLE_CODE","CIRCLE_NAME","DIV_CODE","DIV_NAME","SDO_CODE","SDO_NAME","SUPPLY_TYPE","PAYMENT_MODE","BANK_NAME","CHQ_NUMBER","LATITUDE","LONGITUDE","EXECPTION_CODE","EXCEPTION_DESCRIPTION","REFERENCE_ID","PREV_RDG_KWH","PREV_RDG_KVAH","PREV_RDG_DATE","CUR_RDG_KWH","CUR_RDG_KVAH","CUR_RDG_DATE","MTR_RDR_NAME","MTR_RDR_AGENCY","MTR_NO_RECORDED","MTR_MAKE_RECORDED","MANUL_BILL_EXCEP","MF"'
FROM DUAL;


EOD

################################################################################################################

# sqlplus -S purptapp/purptapp@PUMISPRD<<EOD >> /home/ratan/BILLED/DATA/$lv_fold_bl/$p_file_nm &
sqlplus -S $mystr <<EOD >> /home/ratan/BILLED/DATA/$lv_fold_bl/$p_file_nm &
set head off
set trim on
set pagesize 0
set linesize 32767
set feedback off

SELECT /*+ no_parallel */ 
'"' ||
ACCT_ID|| '","' ||
BOOK_NO|| '","' ||
SCNO|| '","' ||
--NAME|| '","' ||
--ADDRESS|| '","' ||
REGEXP_REPLACE(Name,'[",.]','') || '","' ||
REGEXP_REPLACE(Address,'[",.]','') || '","' ||
PHONE|| '","' ||
TARIFF_TYPE|| '","' ||
SANCTION_LOAD|| '","' ||
SANCTION_LOAD_UOM|| '","' ||
SUBSTATION|| '","' ||
FEEDER|| '","' ||
DT|| '","' ||
' '||POLE_NO||' ' || '","' ||
METER_SERIAL_NBR|| '","' ||
METER_READ_REMARK|| '","' ||
MR_SOURCE_CD|| '","' ||
BILL_BASIS|| '","' ||
DUE_DATE|| '","' ||
PAY_DATE|| '","' ||
AMOUNT_PAID|| '","' ||
AMOUNT_PAYABLE|| '","' ||
BILL_TYP|| '","' ||
BILL_DATE|| '","' ||
to_char(BILL_CRE_DTTM, 'DD-MON-YYYY HH:MM:SS PM') || '","' ||
BILLED_UNITS|| '","' ||
BILL_ID|| '","' ||
CA|| '","' ||
BILL_INF_FLG|| '","' ||
SBM_MACHINE_ID|| '","' ||
DISCOM|| '","' ||
ZONE_CODE|| '","' ||
ZONE_NAME|| '","' ||
CIRCLE_CODE|| '","' ||
CIRCLE_NAME|| '","' ||
DIV_CODE|| '","' ||
DIV_NAME|| '","' ||
SDO_CODE|| '","' ||
SDO_NAME|| '","' ||
SUPPLY_TYPE|| '","' ||
PAYMENT_MODE|| '","' ||
BANK_NAME|| '","' ||
CHECK_NUMBER|| '","' ||
LATITUDE|| '","' ||
LONGITUDE|| '","' ||
MTR_EXCEP_CD|| '","' ||
exp_desc|| '","' ||
REFERENCE_ID || '","' ||
PREV_RDG_KWH || '","' ||
PREV_RDG_KVAH || '","' ||
PREV_RDG_DATE || '","' ||
CUR_RDG_KWH|| '","' ||
CUR_RDG_KVAH|| '","' ||
CUR_RDG_DATE|| '","' ||
MTR_RDR_NAME|| '","' ||
MTR_RDR_AGENCY|| '","' ||
MTR_NO_RECORDED|| '","' ||
MTR_MAKE_RECORDED|| '","' ||
MANUL_BILL_EXCEP|| '","' ||
MF || '"'
FROM rptuser.CM_BILLED_nw
WHERE div_code = '$my_div'
;

EOD

test_PP $lv_NRCPUS

done  

wait

############################else condition #############################################

else 

echo $lvnorunmsg 

####################################################################################

fi

echo ended if statement >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

##################################gzip of files starts ####################################

sleep 250

lv_gzstarttime=$(date +%d%m%Y%H%M%S)
echo gzip of files started at $lv_gzstarttime >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

gzip /home/ratan/BILLED/DATA/$lv_fold_bl/BILLED*

lv_gzendtime=$(date +%d%m%Y%H%M%S)
echo gzip of files ended at $lv_gzendtime >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

##################################gzip of files ends ####################################

##################################movement of files start#####################################

# cd /home/ratan/BILLED/DATA/$lv_fold_bl/

# mkdir PUVNL 

# mv BILLED_PUVNL* ./PUVNL

##################################movement of files ended#####################################


echo BILLED ftp start >> /home/ratan/BILLED/LOGS/$lv_logfile_nm.txt

if [ $mydiscom = 'PUVNL' ]
then
#       mystr='purptapp/purptapp@PUMISPRD'
        cd /home/ratan/BILLED/DATA/$lv_fold_bl/
        mkdir /home/ratan/BILLED/DATA/$lv_fold_bl/PUVNL
        mv BILLED_PUVNL* ./PUVNL
	mkdir /data/puftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl
        cp -r /home/ratan/BILLED/DATA/$lv_fold_bl/PUVNL/*.* /data/puftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl/.
elif [ $mydiscom = 'PVVNL' ]
then
        mystr='pvrptapp/pvrptapp@PVMISPRD'
        cd /home/ratan/BILLED/DATA/$lv_fold_bl/
        mkdir /home/ratan/BILLED/DATA/$lv_fold_bl/PVVNL
        mv BILLED_PVVNL* ./PVVNL
        mkdir /data/pvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl
        cp -r /home/ratan/BILLED/DATA/$lv_fold_bl/PVVNL/*.* /data/pvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl/.
elif [ $mydiscom = 'MVVNL' ]
then
        mystr='mvrptapp/mvrptapp@MVMISPRD'
        cd /home/ratan/BILLED/DATA/$lv_fold_bl/
        mkdir /home/ratan/BILLED/DATA/$lv_fold_bl/MVVNL
        mv BILLED_MVVNL* ./MVVNL
        mkdir /data/mvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl
        cp -r /home/ratan/BILLED/DATA/$lv_fold_bl/MVVNL/*.* /data/mvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl/.
elif [ $mydiscom = 'DVVNL' ]
then
        mystr='dvrptapp/dvrptapp@DVMISPRD'
        cd /home/ratan/BILLED/DATA/$lv_fold_bl/
        mkdir /home/ratan/BILLED/DATA/$lv_fold_bl/DVVNL
        mv BILLED_DVVNL* ./DVVNL
        mkdir /data/dvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl
        cp -r /home/ratan/BILLED/DATA/$lv_fold_bl/DVVNL/*.* /data/dvftpreport/UNBILLED/CSV_BILLED/$lv_fold_bl/.
else
echo 'error'
fi

lv_gzstarttime=$(date +%d%m%Y%H%M%S)
echo FTP of files started at $lv_gzstarttime >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

# sh /oubidata4/extracts-oubiprod/BILLED/billed_ftp_dr.sh 

# mkdir /data/puftpreport/BILLED/CSV_BILLED/$lv_fold_bl
# mkdir /data/puftpreport/BILLED/CSV_BILLED/$lv_fold_bl/PUVNL
# cp -r /home/ratan/BILLED/DATA/$lv_fold_bl/PUVNL/*.* /data/puftpreport/BILLED/CSV_BILLED/$lv_fold_bl/PUVNL/.

lv_gzendtime=$(date +%d%m%Y%H%M%S)
echo FTP of files ended at $lv_gzendtime >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

echo 'BILLED CSV SHELL EXECUTION COMPLETED' >> /home/ratan/BILLED/LOGS/$lv_Blogfile_nm.txt

