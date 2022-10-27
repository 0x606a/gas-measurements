// SPDX-License-Identifier: MIT
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;
 
import "forge-std/Test.sol";

import {Login2} from "src/OTA/Login2.sol";

contract OTATest is Test {

    Login2 public login2;

    function setUp() public {

        login2 = new Login2();

    }

            //
    // Login2 Tests
    //

    function testOta_rand() public {
        login2.rand(5, 100);
    }

    function testOta_rand_FUZZ(uint mi, uint ma) public {
        login2.rand(mi, ma);
    }

    function testOta_login_admin() public {
        login2.login_admin();
    }

}
