// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

import {AccessControlMethod} from "src/MSC/AccessControlMethod.sol";
import {Judge} from "src/MSC/Judge.sol";
import {Register} from "src/MSC/Register.sol";


contract MSCTest is Test {

    AccessControlMethod public accessControlMethod;
    Judge public judge;
    Register public register;


    address constant public USER_1 = address(1);
    address constant public USER_2 = address(2);
    address constant public USER_3 = address(3);
    address constant public USER_4 = address(4);


    address constant public ADMIN_1 = address(4);

    string constant public RES = "resource";

    address[] public addresses;
    bytes[] public someBytes;
    uint[] public score;

    function(bytes memory) external callback;

    function setUp() public {
        accessControlMethod = new AccessControlMethod(address(this));
        accessControlMethod.policyAdd("resource", "action", "xrw", 10, 5);

        judge = new Judge(1, 1);
        judge.misbehaviorJudge(address(1), address(1), "res", "action", "misbehavior", 1);

        register = new Register();
    }

    //
    // AccessControlMethod Tests
    //

    function testAccessControlMethod_stringToBytes32() public {
        accessControlMethod.stringToBytes32('abcd');
    }
    function testAccessControlMethod_stringToBytes32_FUZZ(string memory st) public {
        accessControlMethod.stringToBytes32(st);
    }
    
    function testAccessControlMethod_setJC() public {
        accessControlMethod.setJC(address(1));
    }
    function testAccessControlMethod_setJC_FUZZ(address sub) public {
        accessControlMethod.setJC(sub);
    }

    function testAccessControlMethod_policyAdd() public {
        accessControlMethod.policyAdd('abcd','read','allow',10,100);
    }
    function testAccessControlMethod_policyAdd_FUZZ(string memory res, string memory action, string memory per, uint min, uint thres) public {
        accessControlMethod.policyAdd(res,action,per,min,thres);
    }

    function testAccessControlMethod_getPolicy() public {
        accessControlMethod.getPolicy("resource","action");
    }

    function testAccessControlMethod_policyUpdate() public {
        accessControlMethod.policyUpdate("resource","action",'allow');
    }
    function testAccessControlMethod_policyUpdate_FUZZ(string memory nper) public {
        accessControlMethod.policyUpdate("resource","action",nper);
    }
    
    function testAccessControlMethod_minIntervalUpdate() public {
        accessControlMethod.minIntervalUpdate("resource","action",200);
    }
    function testAccessControlMethod_minIntervalUpdate_FUZZ(uint nmin) public {
        accessControlMethod.minIntervalUpdate("resource","action",nmin);
    }
    
    function testAccessControlMethod_thresholdUpdate() public {
        accessControlMethod.thresholdUpdate("resource","action",200);
    }
    function testAccessControlMethod_thresholdUpdate_FUZZ(uint nthres) public {
        accessControlMethod.thresholdUpdate("resource","action",nthres);
    }

    function testAccessControlMethod_policyDelete() public {
        accessControlMethod.policyDelete("resource","action");
    }

    function testAccessControlMethod_accessControl() public {
        accessControlMethod.accessControl("resource","action",20);
    }
    function testAccessControlMethod_accessControl_FUZZ(string memory res, string memory action, uint time) public {
        accessControlMethod.accessControl(res,action,time);
    }
    
    function testAccessControlMethod_getTimeofUnblock() public {
        accessControlMethod.getTimeofUnblock("resource");
    }
    function testAccessControlMethod_getTimeofUnblock_FUZZ(string memory RES) public {
        accessControlMethod.getTimeofUnblock(RES);
    }

    function testAccessControlMethod_deleteACC() public {
        accessControlMethod.deleteACC();
    }

    //
    // Judge Tests
    //

    function testJudge_misbehaviorJudge() public {
        judge.misbehaviorJudge(address(1),address(2),'abcd','read','bad',10);
    }
    function testJudge_misbehaviorJudge_FUZZ(address sub, address obj, string memory res, string memory act, string memory mis, uint time) public {
        judge.misbehaviorJudge(sub,obj,res,act,mis,time);
    }

    function testJudge_getLatestMisbehavior() public {
        judge.getLatestMisbehavior(address(1));
    }

    function testJudge_self_destruct() public {
        judge.self_destruct();
    }

    //
    // Register Tests
    //

    function testRegister_stringToBytes32() public {
        register.stringToBytes32('abcd');
    }
    function testRegister_stringToBytes32_FUZZ(string memory st) public {
        register.stringToBytes32(st);
    }

    function testRegister_methodRegister() public {
        register.methodRegister('abcd','efg',address(1),address(2),address(3),address(4),'0010');
    }
    function testRegister_methodRegister_FUZZ(string memory name, string memory scname, address sub, address obj, address creator, address scaddress, bytes memory abi1) public {
        register.methodRegister(name,scname,sub,obj,creator,scaddress,abi1);
    }

    function testRegister_methodScNameUpdate() public {
        register.methodScNameUpdate('abcd','efg');
    }
    function testRegister_methodScNameUpdate_FUZZ(string memory name, string memory scname) public {
        register.methodScNameUpdate(name,scname);
    }

    function testRegister_methodAcAddressUpdate() public {
        register.methodAcAddressUpdate('abcd',address(1));
    }
    function testRegister_methodAcAddressUpdate_FUZZ(string memory name, address scaddress) public {
        register.methodAcAddressUpdate(name,scaddress);
    }

    function testRegister_methodAbiUpdate() public {
        register.methodAbiUpdate('abcd','0010');
    }
    function testRegister_methodAbiUpdate_FUZZ(string memory name, bytes memory abi1) public {
        register.methodAbiUpdate(name,abi1);
    }

    function testRegister_methodNameUpdate() public {
        register.methodNameUpdate('abcd','efg');
    }
    function testRegister_methodNameUpdate_FUZZ(string memory oname, string memory nname) public {
        register.methodNameUpdate(oname,nname);
    }

    function testRegister_methodDelete() public {
        register.methodDelete('abcd');
    }
    function testRegister_methodDelete_FUZZ(string memory name) public {
        register.methodDelete(name);
    }

    function testRegister_getContractAddr() public {
        register.getContractAddr('abcd');
    }
    function testRegister_getContractAddr_FUZZ(string memory name) public {
        register.getContractAddr(name);
    }

    function testRegister_getContractAbi() public {
        register.getContractAbi('abcd');
    }
    function testRegister_getContractAbi_FUZZ(string memory name) public {
        register.getContractAbi(name);
    }

}
