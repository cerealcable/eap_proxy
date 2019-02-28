export PATH=/usr/local/bin:$PATH
alias debuild="debuild --preserve-envvar PATH"
mkdir /build
rsync -rtvpl /src/ /build
mkdir -p /src/out
cd /build
debuild -us -uc
cp ../vyatta-eap-proxy_* /src/out/
