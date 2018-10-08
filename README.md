# Nginx Logs to Kafka Sample

Run following commands:

```bash
make zookeeper
```

```bash
make kafka
```

```bash
make nginx
```

```bash
make filebeat
```

```bash
make consume
```

```bash
curl http://127.0.0.1:8080/hello?from=console
```
