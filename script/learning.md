# openssl

# refer: https://blog.csdn.net/gengxiaoming7/article/details/78505107


## 第一部分，公钥私钥
# 生成 rsa 私钥
openssl genrsa -out rsa_private.key 2048

# 生成RSA公钥
openssl rsa -in rsa_private.key -pubout -out rsa_public.key

#查看私钥明细
openssl rsa -in rsa_private.key -noout -text

#查看公钥明细
openssl rsa -pubin -in rsa_public.key -noout -text


## 第二部分，自签名证书

# 生成自签名证书，使用新的rsa私钥
openssl req -newkey rsa:2048 -nodes -keyout rsa_private.key -x509 -days 365 -out cert.crt
# req是证书请求的子命令，
# -newkey rsa:2048 -keyout private_key.pem 表示生成私钥(PKCS8格式)，
# -nodes 表示私钥不加密，若不带参数将提示输入密码；
#-x509表示输出证书，-days365 为有效期，此后根据提示输入证书拥有者信息；
# 若执行自动输入，可使用-subj选项：
openssl req -newkey rsa:2048 -nodes -keyout rsa_private.key -x509 -days 365 -out cert.crt -subj "/C=CN/ST=GD/L=SZ/O=vihoo/OU=dev/CN=vivo.com/emailAddress=yy@vivo.com"

# 使用 已有RSA 私钥生成自签名证书
openssl req -new -x509 -days 365 -key rsa_private.key -out cert.crt
# -new 指生成证书请求，
# 加上-x509 表示直接输出证书
# -key 指定私钥文件，其余选项与上述命令相同


## 第三部分，签发证书

# 使用RSA私钥，生成CSR签名请求
openssl req -new -key rsa_private.key -out server.csr -subj "/C=CN/ST=GD/L=SZ/O=vihoo/OU=dev/CN=vivo.com/emailAddress=yy@vivo.com"

# 查看CSR
openssl req -noout -text -in server.csr

# 使用 CA 证书及CA密钥 对请求签发证书进行签发，生成 x509证书
使用 CA 证书及CA密钥 对请求签发证书进行签发，生成 x509证书
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key  -CAcreateserial -out server.crt

# 查看证书
openssl x509 -in cert.crt -noout -text
