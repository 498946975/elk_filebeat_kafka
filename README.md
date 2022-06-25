### 使用方式


> 重要提示：如果没有nfs，先创建nfs服务器

**1. 创建单独的 namespace**
```
# kubectl apply -f 01-createNS.yaml
```

**2. 生成开启 x-pack 时的 ssl 证书**
```
// 参考：https://github.com/elastic/helm-charts/blob/master/elasticsearch/examples/security/Makefile#L24-L35
# docker run --name es-certutil -i -w /tmp docker.elastic.co/elasticsearch/elasticsearch:7.14.0 /bin/sh -c  \
    "elasticsearch-certutil ca --out /tmp/es-ca.p12 --pass '' && \
    elasticsearch-certutil cert --name security-master --dns \
    security-master --ca /tmp/es-ca.p12 --pass '' --ca-pass '' --out /tmp/elastic-certificates.p12"
# docker cp es-certutil:/tmp/elastic-certificates.p12 ./
# kubectl -n kube-logging create secret generic elastic-certificates --from-file=./elastic-certificates.p12
```


**3. 部署 elasticsearch master 节点**
```
# kubectl -n kube-logging apply -f 02-es-master.yaml
```

**4. 部署 elasticsearch data 节点**
```
# kubectl -n kube-logging apply -f 03-es-data.yaml
```

**5. 部署 elasticsearch client/ingest 节点**
```
# kubectl -n kube-logging apply -f 04-es-client.yaml
```

**6. 暴露 elasticsearch service**
```
# kubectl -n kube-logging apply -f 05-es-service.yaml
```

**7. 设置 elasticsearch 的密码**
```
// 记得保存这些初始密码
# kubectl -n kube-logging exec -it $(kubectl -n kube-logging get pods | grep elasticsearch-client | sed -n 1p | awk '{print $1}') -- bin/elasticsearch-setup-passwords auto -b
Changed password for user apm_system
PASSWORD apm_system = BzqfdvFuQ7DiLFvOkPbQ

Changed password for user kibana
PASSWORD kibana = rqWbAZXyZ8uyHPq6eSlW

Changed password for user logstash_system
PASSWORD logstash_system = YlBu4REcwzibiGl4W1TV

Changed password for user beats_system
PASSWORD beats_system = Z6BF5dZm6vNikdtf32QG

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = qwNomHhWE2Fv60C7haSZ

Changed password for user elastic
PASSWORD elastic = c1vsGFAwF5NWbPL4WJPc
```

**8. 配置 kibana.yaml 连接 elasticsearch 的 secret**
```
// 使用上面生成的用户 elastic 的密码 c1vsGFAwF5NWbPL4WJPc（后续访问 elasticsearch 或者 登录 kibana 都是用这个用户和密码）
# kubectl -n kube-logging create secret generic elasticsearch-password --from-literal password=c1vsGFAwF5NWbPL4WJPc 
```

**9. 部署 kibana**
```
# kubectl -n kube-logging apply -f 06-kibana.yaml
```

**10. 部署 zookeeper**
```
# helm -n kube-logging install zookeeper -f 07-zk.yaml ./zookeeper
```

**11. 部署 kafka**
```
# helm -n kube-logging install kafka -f 08-kafka.yaml ./kafka
```

**12. 部署 filebeat**
```
# kubectl -n kube-logging apply -f 09-filebeat.yaml
```

**13. 部署 logstach**
```
# kubectl -n kube-logging apply -f 10-logstach.yaml
```

**14. 其他**

如果拉取不了 docker.elastic.co 的镜像，可以使用 https://hub.docker.com/u/awker 下的相关镜像
