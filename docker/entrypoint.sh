mkdir /build
rsync -rtvpl /src/ /build
mkdir -p /src/out
cd /build
debuild -us -uc
cp ../vyatta-eap-proxy_* /src/out/
