BASEDIR=$(dirname $0)
CERTDIR='/var/lib/tomcat7/webapps/source/https'
source ${BASEDIR}/venv/bin/activate
cd ${BASEDIR}/opengrok_api
gunicorn --certfile=${CERTDIR}/certificate.pem --keyfile=${CERTDIR}/https.key --bind 0.0.0.0:9999 opengrok_api.wsgi --daemon --reload
#gunicorn --bind 0.0.0.0:9999 opengrok_api.wsgi --daemon --reload
