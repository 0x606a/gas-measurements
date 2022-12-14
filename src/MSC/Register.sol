//source code: https://mdlval.blogspot.com/2018/02/implement-access-control-in-simple-iot.html, https://drive.google.com/file/d/1iJ-rT5ESfF6WeavlQxoPtroLcmhgotgV/view, https://drive.google.com/file/d/1J_ivEbentO9gq7gVmN9mNuA_K_cinPnl/view, https://drive.google.com/file/d/1ynjwUEFgfPMLaLxr72wVDcTeE8RDBJZL/view
//source paper: T. Sultana, A. Almogren, M. Akbar, M. Zuair, I. Ullah, and N. Javaid, “Data sharing system integrating access control mechanism using blockchain-based smart contracts for iot devices,” Applied Sciences, 2020
pragma solidity 0.6.0;

contract Register{
    struct Method{ 
        string scName;              //contract name
        address subject;            //the subject of the corresponding subject-object pair of the ACC; for the JC, this filed is left blank;
        address object;             //the subject of the corresponding subject-object pair of the ACC; for the JC, this filed is left blank;
        address creator;            //the peer (account) who created and deployed this contract;
        address scAddress;          //the address of the contract;
        bytes abi;                  //the Abi’s provided by the contract.
    }

    /*As solidity cannot allow dynamically-sized value as the Key, we use the fixed-szie byte32 type as the keytype*/
    mapping (bytes32=> Method) public lookupTable;

    /*convert strings to byte32*/
    function stringToBytes32(string memory _str) public view returns (bytes32){
        bytes memory tempBytes = bytes(_str);
        bytes32 convertedBytes;
        if(0 == tempBytes.length){
            return 0x0;
        }
        assembly {
            convertedBytes := mload(add(_str, 32))
        }
        return convertedBytes;
    }

    /*register an access control contract (ACC)*/
    function methodRegister(string memory _methodName, string memory _scname, address _subject, address _object, address _creator, address _scAddress, bytes memory _abi) public {
        //no duplicate check
        bytes32 newKey = stringToBytes32(_methodName);
        lookupTable[newKey].scName = _scname;
        lookupTable[newKey].subject = _subject;
        lookupTable[newKey].object = _object;
        lookupTable[newKey].creator = _creator;
        lookupTable[newKey].scAddress = _scAddress;
        lookupTable[newKey].abi = _abi;
    }

    /*update the ACC information (i.e., scname, scAddress, abi) of an exisiting method specified by the _methodName*/
    function methodScNameUpdate(string memory _methodName, string memory _scName) public{
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].scName = _scName;
    }

    function methodAcAddressUpdate(string memory _methodName, address _scAddress) public{
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].scAddress = _scAddress;
    }

    function methodAbiUpdate(string memory _methodName, bytes memory _abi) public{
        bytes32 key = stringToBytes32(_methodName);
        lookupTable[key].abi = _abi;
    }

    /*update the name (_oldname) of an exisiting method with a new name (_newname) */
    function methodNameUpdate(string memory _oldName, string memory _newName) public{
        bytes32 oldKey = stringToBytes32(_oldName);
        bytes32 newKey = stringToBytes32(_newName);
        lookupTable[newKey].scName = lookupTable[oldKey].scName;
        lookupTable[newKey].subject = lookupTable[oldKey].subject;
        lookupTable[newKey].object = lookupTable[oldKey].object;
        lookupTable[newKey].creator = lookupTable[oldKey].creator; 
        lookupTable[newKey].scAddress = lookupTable[oldKey].scAddress;
        lookupTable[newKey].abi = lookupTable[oldKey].abi;
        delete lookupTable[oldKey];
    }

    function methodDelete(string memory _name) public{
        delete lookupTable[stringToBytes32(_name)];
    }

    function getContractAddr(string memory _methodName) public view returns (address _scAddress){
        bytes32 key = stringToBytes32(_methodName);
        _scAddress = lookupTable[key].scAddress;
    }

    function getContractAbi(string memory _methodName) public view returns (bytes memory _abi){
        bytes32 key = stringToBytes32(_methodName);
        _abi = lookupTable[key].abi;
    }
}