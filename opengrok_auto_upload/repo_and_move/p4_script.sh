CRM_BUILD_ID=$1
VERSION=`hostname`_`date +%Y%m%d`_`date +%H%M%S`
WRKSPACE_NAME=${USER}_${CRM_BUILD_ID}_${VERSION}
echo -n "P4CLIENT=${WRKSPACE_NAME}" > .p4config
P4EDITOR="cat" p4 client -t CRM_${CRM_BUILD_ID} ${WRKSPACE_NAME} | head -n -1  > /tmp/p4client_crm.txt
more /tmp/p4client_crm.txt | p4 client -i
p4 sync @${CRM_BUILD_ID},@${CRM_BUILD_ID}
