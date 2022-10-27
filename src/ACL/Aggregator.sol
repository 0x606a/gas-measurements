//source: https://github.com/DecentralizedACLIoT/DecentralizedACL_IoT
//based on paper: H. Albreiki, L. Alqassem, K. Salah, M. H. U. Rehman, and D. Sevtinovic, “De- centralized access control for iot data using blockchain and trusted oracles,” Proceedings of IEEE International Conference on Industrial Internet, 2019
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;
 
interface ReputationSC{
    function addAggregator(address aggregatorAddress) external ;
    function reportReputationScore(address[] calldata oracleAddress, uint[] calldata points) external returns (address winningOracleAddress);
    function selectWinningOracle(address[] calldata oracleAddress) external view returns (address winningOracleAddress);
    function getOracleReputation(address oracleAddress) external view returns (uint averageReputationScore);
 
}
 
interface OracleSC {
    function query(bytes calldata data, function(bytes memory) external callback) external ;
    function reply(uint requestID, bytes calldata response) external; }
 
contract Aggregator{
   
    //This is the address for contract oswer
    address public owner;
   
    //This variable will store the address for the ReputationSC
    address private reputationSCAddress;
   
    //This variable will store the number of responces received from oracles
    uint private numOfResponses;
   
    //This variable will store the number of oracles requested by the user
    uint private numOfRequestedOracles;
   
    //addresses array for the responding oracles
    address[] private respondingOracles;
   
    //bytes array for the responding oracles hashes
    bytes[] private hashes;
   
    //user address
    address private user;
   
    // This declares a state variable that stores list of IoTDevices addresses for crosponding oracle's address.
    mapping(address => address[]) private oraclesIoTDevices;
    address[] public oracleList;
   
    //constructor
    constructor(address addr) public {
        owner = msg.sender;
        reputationSCAddress = addr;
    }
   
    modifier onlyOwner() { // Modifier
        require(
            msg.sender == owner,
            "Only contract owner can call this."
        );
        _;
    }
   
    modifier onlyOracle{ // Modifier
        bool isOracle=false;
        for(uint256 i = 0; i < oracleList.length;i++){
            if(msg.sender==oracleList[i]){
                isOracle=true;
                break;
            }
        }
       
        require(
            isOracle==true,
            "Only Oracle can call this."
        );
        _;
    }
   
    //This function adds new oracle
    function addOracle(address oracleAddress, address[] memory devicesAddresses) public onlyOwner{
        oracleList.push(oracleAddress);
        oraclesIoTDevices[oracleAddress]=devicesAddresses;
    }
   
    //This function sends data request to oracles
    function sendDataRequest(address userAddr, address iotDeviceAddr, uint numOfOracles) public {
        numOfRequestedOracles = numOfOracles;
        user = userAddr;
        uint counter=0;
        for(uint256 i=0; i < oracleList.length;i++){
            for(uint256 k=0; k < oraclesIoTDevices[oracleList[i]].length;k++){
                if(iotDeviceAddr==oraclesIoTDevices[oracleList[i]][k]){
                    counter++;
                    OracleSC oracle = OracleSC(oracleList[i]);
                    oracle.query(abi.encodePacked(iotDeviceAddr), this.oracleResponse);
                    if(counter == numOfOracles)
                        break;
                }
               
            }
        }
    }
   
    //This function will be called by oracles only after getting the hash for the requested data
    function oracleResponse(bytes memory response) public onlyOracle {
        numOfResponses ++;
        respondingOracles.push(msg.sender);
        hashes.push(response);
        if (numOfResponses==numOfRequestedOracles){
            // änderung wegen Tests
            reportReputationScore(reputationSCAddress,respondingOracles, hashes);
            //numOfResponses=0;
            delete numOfResponses;
            //respondingOracles.length=0;
            delete respondingOracles;
            //hashes.length=0;
            delete hashes;
        }
    }
   
    event CorrectHashFound(bytes hashData, address[] trueOracles);
    event NotHashFound(bytes hashData, uint num);
    mapping (bytes => uint256) private Aggreement;//counting how many duplicated data hashes
    mapping (bytes => address []) DuplicateOracles; //mapping the oracles with duplicated data hashes
    address []  TrueOracles; //list of true oracles addresses
    //This function report reputation for oracles
    function reportReputationScore(address reputationSC, address[] memory oracleAddress, bytes[] memory dataHashes) public onlyOwner returns (address selectedOracle ){
            uint numOfMatches =numOfRequestedOracles/2;
            bytes memory correctHash;//the datahash with 51% agreemnt
            address[] memory oraclesList; //list of rewarded points for oracles
            uint[] memory points; //list of rewarded points for oracles

            for(uint256 i=0; i < dataHashes.length;i++){
                if(Aggreement[dataHashes[i]]!=0 ){
                    Aggreement[dataHashes[i]]++;
                    DuplicateOracles[dataHashes[i]].push(oracleAddress[i]);
                }else{
                    Aggreement[dataHashes[i]]=1;
                    DuplicateOracles[dataHashes[i]].push(oracleAddress[i]);
                }
            }
            for(uint i=0; i < dataHashes.length;i++){
                if(Aggreement[dataHashes[i]]>numOfMatches){
                    correctHash=dataHashes[i];
                //create an array of correct oracles
                for(uint256 j=0; j < DuplicateOracles[correctHash].length;j++){
                    TrueOracles.push(DuplicateOracles[correctHash][j]);
                }
                emit CorrectHashFound(correctHash, TrueOracles);
                break;
                    
                }
                else{
                   emit NotHashFound(dataHashes[i],numOfMatches);
                }
            }
            
            for(uint i=0; i < dataHashes.length;i++){
                for(uint j=0; j < TrueOracles.length;j++){
                    if(oracleAddress[i]==TrueOracles[i]){
                        
                    }
                    else{
                        //points[points.length]=0;
                        // oraclesList[oraclesList.length]=oracleAddress[i];
                    }
                }
            }
            ReputationSC reputation=ReputationSC(reputationSC);
            selectedOracle = reputation.reportReputationScore(oraclesList, points);
    }
   
}
