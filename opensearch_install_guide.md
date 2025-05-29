# OpenSearch Installation Guide สำหรับ Langflow

## Prerequisites
- Docker Desktop ติดตั้งแล้วและทำงานได้
- Command Prompt หรือ PowerShell (Windows)
- Ram อย่างน้อย 4GB

## ขั้นตอนการติดตั้ง

### 1. เตรียม Docker Network
```cmd
docker network create opensearch-net
```

### 2. หยุดและลบ Container เก่า (ถ้ามี)
```cmd
docker stop opensearch-single-node
docker rm opensearch-single-node
```

### 3. ลบ Volume เก่าที่อาจมีปัญหา
```cmd
docker volume rm opensearch-data
```

### 4. รัน OpenSearch 2.19.1
```cmd
docker run -e OPENSEARCH_JAVA_OPTS="-Xms512m -Xmx512m" -e discovery.type="single-node" -e DISABLE_SECURITY_PLUGIN="true" -e bootstrap.memory_lock="true" -e cluster.name="opensearch-cluster" -e node.name="os01" -e DISABLE_INSTALL_DEMO_CONFIG="true" --ulimit nofile="65536:65536" --ulimit memlock="-1:-1" --net opensearch-net --restart=no -v opensearch-data-v2:/usr/share/opensearch/data -p 9200:9200 --name=opensearch-single-node opensearchproject/opensearch:2.19.1
```

### 5. รอให้ OpenSearch เริ่มต้น
รอประมาณ 30-60 วินาที แล้วทดสอบ:

```cmd
curl http://localhost:9200
```

หรือเปิดใน Browser: `http://localhost:9200`

### 6. ตรวจสอบสถานะ
```cmd
curl http://localhost:9200/_cluster/health
curl http://localhost:9200/_cat/plugins?v
```

## การตั้งค่า Hybrid Search

### 7. สร้าง Hybrid Search Pipeline
```cmd
curl -XPUT "http://localhost:9200/_search/pipeline/hybrid-search-pipeline" -H "Content-Type: application/json" -d "{\"description\": \"Pipeline for hybrid search\",\"phase_results_processors\": [{\"normalization-processor\": {\"normalization\": {\"technique\": \"min_max\"},\"combination\": {\"technique\": \"harmonic_mean\",\"parameters\": {\"weights\": [0.3,0.7]}}}}]}"
```

### 8. สร้าง Index Template
```cmd
curl -X PUT "http://localhost:9200/_index_template/langflow-template" -H "Content-Type: application/json" -d "{\"index_patterns\": [\"documents*\"], \"priority\": 1, \"template\": {\"settings\": {\"index\": {\"knn\": true, \"knn.algo_param.ef_search\": 100, \"number_of_shards\": 1, \"number_of_replicas\": 0}}, \"mappings\": {\"properties\": {\"vector\": {\"type\": \"knn_vector\", \"dimension\": 1536, \"method\": {\"name\": \"hnsw\", \"engine\": \"nmslib\", \"space_type\": \"cosinesimil\", \"parameters\": {\"ef_construction\": 128, \"m\": 16}}}, \"text\": {\"type\": \"text\"}, \"metadata\": {\"type\": \"object\"}}}}}"
```

## การตั้งค่าใน Langflow

### OpenSearch Component Settings:
- **Host**: `localhost:9200`
- **Index Name**: `documents`
- **Vector Field**: `vector`
- **Text Field**: `text`
- **Metadata Field**: `metadata`
- **Engine**: `nmslib`
- **Method**: `hnsw`
- **Space Type**: `cosinesimil`

## การทดสอบ

### ทดสอบการเชื่อมต่อ:
```cmd
curl -X GET "http://localhost:9200"
```

### ทดสอบ Pipeline:
```cmd
curl -X GET "http://localhost:9200/_search/pipeline/hybrid-search-pipeline"
```

### ทดสอบ Template:
```cmd
curl -X GET "http://localhost:9200/_index_template/langflow-template"
```

## Troubleshooting

### ถ้า Container ไม่เริ่มต้น:
1. ตรวจสอบว่า Docker Desktop ทำงานอยู่
2. เปิด Docker Desktop และรอให้เริ่มต้นเสร็จ
3. ลองรันคำสั่งใหม่

### ถ้าเจอ Error เรื่อง Memory:
เปลี่ยน RAM จาก 512m เป็น 1g:
```cmd
docker run -e OPENSEARCH_JAVA_OPTS="-Xms1g -Xmx1g" ...
```

### ถ้าเจอ Error เรื่อง Port:
ตรวจสอบว่า port 9200 ไม่ถูกใช้งานโดยโปรแกรมอื่น

## คำสั่งที่มีประโยชน์

### ดู Container ที่ทำงานอยู่:
```cmd
docker ps
```

### ดู Logs:
```cmd
docker logs opensearch-single-node
```

### หยุด Container:
```cmd
docker stop opensearch-single-node
```

### เริ่ม Container ใหม่:
```cmd
docker start opensearch-single-node
```

---

**หมายเหตุ**: OpenSearch 2.19.1 รองรับ `nmslib` engine ที่ Langflow ใช้ ซึ่งใหม่กว่า OpenSearch 3.0.0 จะไม่รองรับ nmslib และอาจทำให้เกิด error ได้