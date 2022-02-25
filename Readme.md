Step1: To generate complete network, channel creation & joining execute below mentioned script from currect directory

chmod u+x ./network.sh
./network.sh createchannel

<<<<<<< HEAD
Step2: To deploy chaincode, execute below mentioned script 

./network.sh deployCC

Step3: To build connection profile, execute below mentioned script 

cd FabricClientApp/connection-Profile/    
./ccp-generate.sh

Step4: To start express server, execute below mentioned script 

cd ../
npm start

NOTE : To remove HLf stuff exceute below mentioned script
=======
Step2: To remove HLF stuff excute below mentioned script
>>>>>>> cf367c42a48fb1ac1f4d297cd9b06a0fed31b3a9

./network.sh down

RESOURCES - 
Postman API Collection - VLM IdealLabs.postman_collection.json