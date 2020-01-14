docker build \
--build-arg ARG_DEVPI_SERVER_VERSION=5.3.1 \
--build-arg ARG_DEVPI_WEB_VERSION=4.0.1 \
--build-arg ARG_DEVPI_CLIENT_VERSION=5.1.1 \
-t idu/devpi:4.5.0 .

# devpi搭建缓存代理服务器 https://blog.csdn.net/u013381011/article/details/77609103
# devpi 快速入门: 上传， 测试， 推送发行版 https://segmentfault.com/a/1190000000664196

# 设置 devpi 服务器管理员密码
DEVPI_PASSWORD = 123
 
mkdir -p /data/idu/devpi
mkdir /data/idu/devpi/wheelhouse

sudo adduser devpi
sudo chown -R devpi:devpi /data/idu/devpi
sudo chmod -R 777 /data/idu/devpi

docker run -d --name devpi \
  --publish 3141:3141 \
  --volume /data/idu/devpi/wheelhouse:/wheelhouse \
  --volume /data/idu/devpi:/data \
  --env=DEVPI_PASSWORD=$DEVPI_PASSWORD \
  --restart always \
  idu/devpi:4.5.0

# 进入容器
docker exec -it -u root devpi bash

devpi --version
devpi index root/pypi

# 本地下载所需的wheel包
pip freeze > /wheelhouse/requirements.txt
pip wheel --wheel-dir=/wheelhouse -r /wheelhouse/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 登陆并上传
devpi use http://127.0.0.1:3141/root/public --set-cfg
devpi login root
devpi upload --from-dir /wheelhouse

# 本地安装所需的wheel包
pip install --index http://127.0.0.1:3141/root/public/+simple/ --trusted-host 127.0.0.1 -r /wheelhouse/requirements.txt
