export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../crypto-config/ordererOrganizations/vlm.com/orderers/orderer.vlm.com/msp/tlscacerts/tlsca.vlm.com-cert.pem
export PEER0_dealer_CA=${PWD}/../crypto-config/peerOrganizations/dealer.vlm.com/peers/peer0.dealer.vlm.com/tls/ca.crt
export PEER0_rta_CA=${PWD}/../crypto-config/peerOrganizations/rta.vlm.com/peers/peer0.rta.vlm.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config/

export CHANNEL_NAME=vlmchannel

export CC_RUNTIME_LANGUAGE="golang"
export VERSION="1"
export SEQUENCE="1"
export CC_SRC_PATH="${PWD}/../chaincode/go"
export CC_NAME="vlm"

setGlobalsForPeer0dealer(){
    export CORE_PEER_LOCALMSPID="dealerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_dealer_CA
    export CORE_PEER_MSPCONFIGPATH=./../crypto-config/peerOrganizations/dealer.vlm.com/users/Admin@dealer.vlm.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0rta(){
    
    export CORE_PEER_LOCALMSPID="rtaMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_rta_CA
    export CORE_PEER_MSPCONFIGPATH=./../crypto-config/peerOrganizations/rta.vlm.com/users/Admin@rta.vlm.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

presetup() {
    cd 
    echo Vendoring Go dependencies ...
    pushd $CC_SRC_PATH
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0dealer
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer0dealer
    # sleep 2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.dealer ===================== "

    # sleep 5

    setGlobalsForPeer0rta
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.rta ===================== "

}

queryInstalled() {
    setGlobalsForPeer0dealer
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    export PACKAGE_ID=$(sed -n "/$CC_NAME_$VERSION/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful  ===================== "
}

approveByDealer() {
    setGlobalsForPeer0dealer
    # set -x
    # Replace localhost with your orderer's vm IP address

    echo "Package ID" ${PACKAGE_ID}
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vlm.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --sequence ${SEQUENCE} --package-id ${PACKAGE_ID}\
        --init-required  
    # set +x

    echo "===================== chaincode approved by Dealer ===================== "

}

approveByRTA() {
    setGlobalsForPeer0rta
    # set -x
    # Replace localhost with your orderer's vm IP address
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vlm.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --sequence ${SEQUENCE} --package-id ${PACKAGE_ID}\
        --init-required  
    # set +x

    echo "===================== chaincode approved by RTA ===================== "

}

checkCommitReadyness() {
    setGlobalsForPeer0dealer
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${SEQUENCE} --output json --init-required
    echo "===================== checking commit readyness ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer0dealer
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.vlm.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_dealer_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_rta_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required
}

queryCommitted() {
    setGlobalsForPeer0dealer
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0dealer
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.vlm.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_dealer_CA \
         --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_rta_CA \
        --isInit -c '{"Args":[]}'

}

presetup
packageChaincode
installChaincode
queryInstalled
approveByDealer
checkCommitReadyness
approveByRTA
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
