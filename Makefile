network:
	docker network create kafka || true

zookeeper: network
	docker kill zookeeper || true
	docker rm zookeeper || true
	docker run \
	--net=kafka \
	--name=zookeeper \
	-e ZOOKEEPER_CLIENT_PORT=2181 \
	confluentinc/cp-zookeeper:5.0.0

kafka: network
	docker kill kafka || true
	docker rm kafka || true
	docker run \
	--net=kafka \
	--name=kafka \
	-p 9092:9092 \
	-e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
	-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
	-e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
	confluentinc/cp-kafka:5.0.0

.PHONY: log
log:
	mkdir -p log

nginx: log
	docker run \
	--net=kafka \
	-p 8080:80 \
	-v $$(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf \
	-v $$(pwd)/log:/var/log/nginx \
	nginx:1.15.5	

filebeat: log
	docker run \
	--net=kafka \
	-v $$(pwd)/log:/var/log \
	-v $$(pwd)/filebeat.yaml:/usr/share/filebeat/filebeat.yml \
	docker.elastic.co/beats/filebeat:6.4.2

consume:
	docker run \
	--net=kafka \
	-e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
	-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
	-e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
	confluentinc/cp-kafka:5.0.0 \
	kafka-console-consumer --topic=filebeat --partition=0 --bootstrap-server=kafka:9092 --offset=earliest

