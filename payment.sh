component=payment
rabbitmq_app_password=$1
if [ -z "${rabbitmq_app_password}" ]; then
  echo Input Rabbitmq app user password missing
  exit 1
fi
source common.sh

func_python