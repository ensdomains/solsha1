pragma solidity >0.4.18;

import "./../../contracts/SHA1.sol";

contract SHA1Test {
    function sha1(bytes memory message) public pure returns(bytes20 ret) {
      return SHA1.sha1(message);
    }
}
