# SSL Certificate Directory

วางไฟล์ SSL certificate และ private key ไว้ในโฟลเดอร์นี้:

- `cert.pem` - SSL certificate file
- `key.pem` - Private key file

สำหรับการทดสอบ คุณสามารถสร้าง self-signed certificate ได้ด้วยคำสั่ง:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout key.pem -out cert.pem \
    -subj "/C=TH/ST=Bangkok/L=Bangkok/O=Organization/OU=OrgUnit/CN=localhost"
```

หรือสำหรับ production ใช้ Let's Encrypt:

```bash
certbot certonly --webroot -w /var/www/html -d your-domain.com
```
