//source: https://github.com/DecentralizedACLIoT/DecentralizedACL_IoT
//based on paper: H. Albreiki, L. Alqassem, K. Salah, M. H. U. Rehman, and D. Sevtinovic, “De- centralized access control for iot data using blockchain and trusted oracles,” Proceedings of IEEE International Conference on Industrial Internet, 2019
pragma solidity 0.6.0;

contract OracleSC {
    address oracleAddress; //Oracle Address
    struct Request {
        bytes data;
        function(bytes memory) external callback;
    }
    Request[] requests;
    event NewRequest(uint);
    modifier onlyBy(address account) {
        require(msg.sender == account); _;
    }
    constructor() public {
        oracleAddress = msg.sender;
    }
    function query(bytes memory data, function(bytes memory) external callback) public {
        requests.push(Request(data, callback));
        emit NewRequest(requests.length - 1);
    }
    // invoked by outside world
    function reply(uint requestID, bytes memory response) public onlyBy(oracleAddress) {
        requests[requestID].callback(response);
    }
}
