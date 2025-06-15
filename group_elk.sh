#!/bin/bash

set -ea
source elk_env

podman network create elastic

#Used to generate password for elasticsearch
ELASTIC_PASSWORD=$(pwgen -s 15 1)
sed -i '/^ELASTIC_PASSWORD=/d' elk_env
echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" >> elk_env

podman run --name es01 -d --env-file elk_env --net elastic -p 9200:9200 docker.elastic.co/elasticsearch/elasticsearch:9.0.1

ES01_IP=$(podman inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' es01)

#TESTING TO SEE VARIBLE WITH IP
#echo "Elasticsearch IP: $ES01_IP"

until curl -k -s -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD https://localhost:9200/ | grep -i "tagline"; do
  echo "Waiting for Elasticsearch to respond..."
  sleep 5
done

KIB01_TOKEN=$(podman exec es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)

#remove the previous varibale then replace in elk_env
sed -i '/^KIB01_TOKEN=/d' elk_env
echo "KIB01_TOKEN=$KIB01_TOKEN" >> elk_env

podman run -d --name kib01 --env-file elk_env --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:9.0.1

podman cp es01:/usr/share/elasticsearch/config/certs .
cp ./certs/http.p12 .
cp ./certs/http_ca.crt .
chmod +r http.p12
chmod +r http_ca.crt
touch logstash.conf

cat <<EOF > logstash.conf 
input {
  beats {
    port => 5044
  }

  tcp {
    port => 50000
    codec => "json"
#    ssl_enabled => true
#    ssl_certificate_authorities => "/usr/share/logstash/http_ca.crt"
  }
}

output {
  elasticsearch {
    hosts => ["https://$ES01_IP:9200/"]
    index => "logstash-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "\${ELASTIC_PASSWORD}"
    ssl_enabled => true
#    ssl_certificate => "/usr/share/logstash/http.p12"
    ssl_certificate_authorities => "/usr/share/logstash/http_ca.crt"
#    ssl_key => "/usr/share/logstash/http.p12"
#    ssl_verification_mode => "full"  
  }
}
EOF

#Testing to see if logstash is taking in the variable
#grep hosts logstash.conf

podman run -d --name logstash01 --env-file elk_env --net elastic -p 50000:50000 -v $(pwd)/http_ca.crt:/usr/share/logstash/http_ca.crt:Z -v $(pwd)/http_ca.crt:/usr/share/logstash/http.p12:Z -v $(pwd)/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:Z docker.elastic.co/logstash/logstash:9.0.1 

