Step1: To generate complete network, channel creation & joining execute below mentioned script from currect directory

chmod u+x ./network.sh


./network.sh createchannel


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


./network.sh down

RESOURCES - 
Postman API Collection - VLM IdealLabs.postman_collection.json
