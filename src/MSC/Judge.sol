//source code: https://mdlval.blogspot.com/2018/02/implement-access-control-in-simple-iot.html, https://drive.google.com/file/d/1iJ-rT5ESfF6WeavlQxoPtroLcmhgotgV/view, https://drive.google.com/file/d/1J_ivEbentO9gq7gVmN9mNuA_K_cinPnl/view, https://drive.google.com/file/d/1ynjwUEFgfPMLaLxr72wVDcTeE8RDBJZL/view
//source paper: T. Sultana, A. Almogren, M. Akbar, M. Zuair, I. Ullah, and N. Javaid, “Data sharing system integrating access control mechanism using blockchain-based smart contracts for iot devices,” Applied Sciences, 2020
pragma solidity 0.6.0;

contract Judge{
    uint public base;
    uint public interval;
    address public owner;

    event isCalled(address _from, uint _time, uint _penalty);

    struct Misbehavior{
        address subject;        //subject who performed the misbehavior;
        address object;
        string res;
        string action;          //action (e.g., "read", "write", "execute") of the misbehavior
        string misbehavior;     //misbehavior
        uint time;              //time of the Misbehavior occured
        uint penalty;           //penalty (number of minitues blocked);
    }

    mapping (address => Misbehavior[]) public MisbehaviorList;

    constructor (uint _base, uint _interval) public{
        base = _base;
        interval = _interval;
        owner = msg.sender;
    }

    function misbehaviorJudge(address _subject, address _object, string memory _res, string memory _action, string memory _misbehavior, uint _time) public returns (uint penalty){
        //misbehaviorJudge(msb);
        uint length = MisbehaviorList[_subject].length + 1;
        uint n = length/interval;
        penalty = base**n;
        MisbehaviorList[_subject].push(Misbehavior(_subject, _object, _res, _action, _misbehavior, _time,penalty));
        emit isCalled(msg.sender,_time, penalty);
    }

    function getLatestMisbehavior(address _key) public view returns (address _subject, address _object, string memory _res, string memory _action, string memory _misbehavior, uint _time){
        uint latest = MisbehaviorList[_key].length - 1;
        //uint latest = 0;
        _subject = MisbehaviorList[_key][latest].subject;
        _object = MisbehaviorList[_key][latest].object;
        _res = MisbehaviorList[_key][latest].res;
        _action = MisbehaviorList[_key][latest].action;
        _misbehavior = MisbehaviorList[_key][latest].misbehavior;
        _time = MisbehaviorList[_key][latest].time;
    }

    function self_destruct() public{
        if(msg.sender == owner){
            selfdestruct(payable(address(this)));
        }
    }
 }
