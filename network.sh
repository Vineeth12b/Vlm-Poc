Value=$1
#echo "$Value"
function generatefiles(){

echo "============================= step1: create crypto-config folder ==========================="

cryptogen generate --config=./crypto-config.yaml

mkdir channel-artifacts
echo "=========================== step2: create gensis file ======================"

export FABRIC_CFG_PATH=$PWD

configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

echo "============================= step3: create channel.tx ======================="

export CHANNEL_NAME=vlmchannel  && configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/vlmchannel.tx -channelID $CHANNEL_NAME


echo "======================================= step4 create anchoor.tx file ==========================="
echo "=========== for dealer org============="

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/dealerMSPanchors.tx -channelID $CHANNEL_NAME -asOrg dealerMSP

echo "============ for rta org============="

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/rtaMSPanchors.tx -channelID $CHANNEL_NAME -asOrg rtaMSP

}

function networkfiles(){

cd docker
echo "======================================== Two Orgs CA ====================================="
docker-compose -f docker-compose-ca.yaml up -d
sleep 5
echo "=============================================== Cli ======================================"
docker-compose -f docker-compose-cli.yaml up -d
sleep 5
echo "======================================== Peer's and Orderer's =================================="
docker-compose -f docker-compose-couchdb.yaml -f docker-compose-test-net.yaml up -d
sleep 5
echo "============================================== Display Runing containers=========================="
docker ps 


}

function dismantial(){
echo "================================== Delete crypto-config Folder ========================================"
rm -rf crypto-config
echo "======================================= Delete channel-artifacts Folder ===================================="
rm -rf channel-artifacts
echo "======================================= Remove all containers ===================================="
docker rm -f $(docker ps -qa)
echo " ============================================= Reomve all the Volumes =================================="
docker system  prune --volumes

}

function Createchannel(){
    cd ../scripts/
    ./channel.sh
}

function deployChaincode(){
    cd ./scripts/
    ./deployCC.sh
}


if  [ "$Value" == "up" ]; then
  generatefiles
  sleep 5
  networkfiles
elif [ "$Value" == "createchannel" ]; then
  
  generatefiles
  sleep 5
  networkfiles
  sleep 5
  Createchannel
elif [ "$Value" == "down" ]; then
  
  dismantial 
elif [ "$Value" == "deployCC" ]; then
  deployChaincode   
else
  echo "===============================Error Occured========================================="
fi