var iSHA1 = artifacts.require("./iSHA1.sol");
var SHA1 = artifacts.require("./SHA1.sol");
var vectors = require('hash-test-vectors')

contract('SHA1', function(accounts) {
    var totalGas = 0;
    vectors.forEach(function(v, i) {
        it("sha1.sol against test vector " + i, async function() {
            var instance = iSHA1.at((await SHA1.deployed()).address);
            var input = "0x" + new Buffer(v.input, 'base64').toString('hex');
            assert.equal(await instance.sha1(input), "0x" + v.sha1, input);
            var gas = await instance.sha1.estimateGas(input);
            totalGas += gas;
            console.log("Cumulative gas: " + totalGas);
        });
    });
});
