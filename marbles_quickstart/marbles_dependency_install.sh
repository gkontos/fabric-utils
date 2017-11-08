cwd=$(pwd)


echo "CLONING HYPERLEDGER GOLANG PROJECT"
mkdir -p $GOPATH/src/github.com/hyperledger
cd $GOPATH/src/github.com/hyperledger

git clone https://github.com/hyperledger/fabric.git
cd fabric
git checkout dfd1e94652891fd3100620c05e4d51f4f8fc41dc
echo "HYPERLEDGER CLONE COMPLETE"

cd $GOPATH/src/github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example022
echo "RUNNING HYPERLEDGER TEST BUILD"
go build --tags nopkcs11 ./
echo "TEST BUILD COMPLETE"

cd $cwd
echo "CLONING MARBLES PROJECT"
git clone https://github.com/IBM-Blockchain/marbles.git --depth 1
cd marbles
git checkout v4.0
echo "MARBLES CLONE COMPLETE"

echo "CLONING FABRIC SAMPLES / TEST NETWORK"
cd $cwd
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
echo "FABRIC SAMPLES CLONE COMPLETE"

echo "DOWNLOADING FABRIC DEPENDENCIES"
curl -sSL https://goo.gl/iX9dek -o setup_script.sh
sudo bash setup_script.sh
echo "DEPENDENCY DOWNLOAD COMPLETE"

echo "INSTALLING MARBLES PROJECT"
cd $cwd/marbles
npm install
echo "INSTALLATION COMPLETE"

echo "INSTALLING FABRIC TEST PROJECT"
cd $cwd/fabric-samples/fabcar
npm install
echo "FABRIC TEST PROJECT INSTALLED"

echo "to start up a network, run ./startFabric.sh"
echo "if you have run the example before, clean out any stopped docker containers"
echo "assuming you don't have any important docker containers, run: "
echo "docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"










