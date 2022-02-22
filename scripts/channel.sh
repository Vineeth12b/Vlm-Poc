export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../crypto-config/ordererOrganizations/vlm.com/orderers/orderer.vlm.com/msp/tlscacerts/tlsca.vlm.com-cert.pem
export PEER0_dealer_CA=${PWD}/../crypto-config/peerOrganizations/dealer.vlm.com/peers/peer0.dealer.vlm.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config/
export PEER0_rta_CA=${PWD}/../crypto-config/peerOrganizations/rta.vlm.com/peers/peer0.rta.vlm.com/tls/ca.crt

export CHANNEL_NAME=vlmchannel

setGlobalsForPeer0dealer(){
    export CORE_PEER_LOCALMSPID="dealerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_dealer_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../crypto-config/peerOrganizations/dealer.vlm.com/users/Admin@dealer.vlm.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}


setGlobalsForPeer0rta(){
    #export RTA_PEER_LOCALMSPID="rtaMSP"
    export CORE_PEER_LOCALMSPID="rtaMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_rta_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../crypto-config/peerOrganizations/rta.vlm.com/users/Admin@rta.vlm.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

createChannel(){
    # rm -rf ./channel-artifacts/*
     setGlobalsForPeer0dealer
    
    # Replace localhost with your orderer's vm IP address
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.vlm.com \
    -f ./../channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./../channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# createChannel

joinChannel(){
    setGlobalsForPeer0dealer
    peer channel join -b ./../channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0rta
    peer channel join -b ./../channel-artifacts/$CHANNEL_NAME.block
    
}

# joinChannel

updateAnchorPeers(){
    setGlobalsForPeer0dealer
    # Replace localhost with your orderer's vm IP address
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.vlm.com -c $CHANNEL_NAME -f ./../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0rta
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.vlm.com -c $CHANNEL_NAME -f ./../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# updateAnchorPeers

# removeOldCrypto

createChannel
joinChannel
updateAnchorPeers