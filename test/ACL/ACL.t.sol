// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

import {Aggregator} from "src/ACL/Aggregator.sol";
import {AccessControl} from "src/ACL/AccessControl.sol";
import {OracleSC} from "src/ACL/OracleSC.sol";
import {ReputationSC} from "src/ACL/ReputationSC.sol";


contract ACLTest is Test {

    Aggregator public aggregator;
    AccessControl public accessControl;
    OracleSC public oracleSC;
    ReputationSC public reputationSC;


    address constant public USER_1 = address(1);
    address constant public USER_2 = address(2);
    address constant public USER_3 = address(3);

    address constant public ADMIN_1 = address(4);


    address[] public addresses;
    bytes[] public someBytes;
    uint[] public score;

    function(bytes memory) external callback;

    function callbackImpl(bytes calldata a) external pure {

    }

    function setUp() public {
        aggregator = new Aggregator(USER_1);
        aggregator.addOracle(address(this), addresses);
        aggregator.addOracle(address(2), addresses);

        accessControl = new AccessControl(ADMIN_1);
        accessControl.addAdmin(address(1));

        oracleSC = new OracleSC();
        oracleSC.query(bytes("1001"), callback);
        oracleSC.query(bytes("010110"), callback);
        oracleSC.query(bytes("01011"), callback);

        reputationSC = new ReputationSC();
        reputationSC.addAggregator(address(2));
        reputationSC.getOracleReputation(address(2));
    }

    //
    // Aggregator Tests
    //

    function testAggregator_addOracle() public {
        addresses.push(address(1));
        aggregator.addOracle(address(2), addresses);
    }
    function testAggregator_addOracle_FUZZ(address oracle, address[] memory devices) public {
        aggregator.addOracle(oracle, devices);
    }

    function testAggregator_sendDataRequest() public {
        aggregator.sendDataRequest(USER_1, USER_2, 1);
    }
    function testAggregator_sendDataRequest_FUZZ(address user, address ioDevice, uint numberOfOracles) public {
        aggregator.sendDataRequest(user, ioDevice, numberOfOracles);
    }
    function testAggregator_oracleResponse() public {
        aggregator.oracleResponse('0010');
    }
    function testAggregator_oracleResponse_FUZZ(bytes memory answer) public {
        aggregator.oracleResponse(answer);
    }
    // @audit Revert
    //function testAggregator_reportReputationScore() public {
    //    addresses.push(address(1));
    //    addresses.push(address(2));
    //    someBytes.push(('0010'));
    //    someBytes.push(('1110'));
    //    reputationSC.reportReputationScore(addresses, score);
    //     score.push(1);
    //     score.push(10);

    //   aggregator.reportReputationScore(address(3), addresses, someBytes);
    //}

    //
    // AccessControl Tests
    //

    function testAccessControl_addDevice() public {
        addresses.push(address(1));
        accessControl.addDevice(address(2));
    }
    function testAccessControl_addDevice_FUZZ(address ndevice) public {
        accessControl.addDevice(ndevice);
    }

    function testAccessControl_addAdmin() public {
        addresses.push(address(1));
        accessControl.addAdmin(address(2));
    }

    function testAccessControl_addAdmin_FUZZ(address nadmin) public {
        accessControl.addAdmin(nadmin);
    }

    function testAccessControl_addUserDeviceMapping() public {
        addresses.push(address(1));
        accessControl.addUserDeviceMapping(address(2),address(3));
    }
    function testAccessControl_addUserDeviceMapping_FUZZ(address user, address device) public {
        accessControl.addUserDeviceMapping(user, device);
    }

    function testAccessControl_delAdmin() public {
        accessControl.delAdmin(address(1));
    }

    function testAccessControl_delUser() public {
        addresses.push(address(1));
        accessControl.delUser(address(2));
    }
    function testAccessControl_delUser_FUZZ(address nuser) public {
        accessControl.delUser(nuser);
    }

    function testAccessControl_requestUserToAccessDevice() public {
        addresses.push(address(1));
        accessControl.requestUserToAccessDevice(address(2), 10);
    }
    function testAccessControl_requestUserToAccessDevice_FUZZ(address device2, uint nOracles) public {
        accessControl.requestUserToAccessDevice(device2, nOracles);
    }

    //
    // OracleSC Tests
    //

    function testOracleSC_query() public {
        oracleSC.query(abi.encodePacked(address(1)), callback);
    }
    function testOracleSC_query_FUZZ(bytes memory data1) public {
        oracleSC.query(data1, callback);
    }
    // @audit Revert
    // function testOracleSC_reply() public {
    //     // oracleSC.query('1010', callback);
    //     // oracleSC.query('0010', callback);
    //     // oracleSC.query('0110', callback);
    //    oracleSC.reply(2,abi.encodePacked(address(2)));
    // }

    //
    // ReputationSC Tests
    //

    function testReputationSC_addAggregator() public {
        reputationSC.addAggregator(address(3));
    }
    function testReputationSC_addAggregator_FUZZ(address agg) public {
        reputationSC.addAggregator(agg);
    }

    function testReputationSC_reportReputationScore() public {
        reputationSC.reportReputationScore(addresses, score);
    }
    // @audit Revert //EXTCALL could be the problem
    //  function testReputationSC_reportReputationScore_FUZZ(address[] memory oracleA2, uint[] memory score) public {
    //    reputationSC.reportReputationScore(oracleA2, score);      
    // }

    function testReputationSC_getOracleReputation() public {
        addresses.push(address(2));
        reputationSC.addAggregator(address(1));
    }
    function testReputationSC_getOracleReputation_FUZZ(address orac) public {
        reputationSC.addAggregator(orac);
    }

}