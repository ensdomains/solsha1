var SHA1 = artifacts.require("./SHA1.sol");
var vectors = require('hash-test-vectors')

contract('SHA1', function(accounts) {
    vectors.forEach(function(v, i) {
        it("sha1.sol against test vector " + i, async function() {
            var instance = await SHA1.deployed();
            var input = "0x" + new Buffer(v.input, 'base64').toString('hex');
            assert.equal(await instance.sha1(input), "0x" + v.sha1, input);
        });
    });
});
