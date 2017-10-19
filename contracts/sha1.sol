pragma solidity ^0.4.17;

library BytesUtils {
    struct slice {
        uint len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function putBytes(slice memory dest, uint off, bytes src) internal view {
        uint ptr;
        assembly { ptr := add(add(src, 32), off) }
        memcpy(dest._ptr, ptr, src.length);
    }

    /*
     * @dev Returns a slice containing the entire byte string.
     * @param self The byte string to make a slice from.
     * @return A newly allocated slice
     */
    function toSlice(bytes self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(ptr, self.length);
    }

    /*
     * @dev Initializes a slice from a byte string.
     * @param self The slice to iInitialize.
     * @param data The byte string to initialize from.
     * @return The initialized slice.
     */
    function fromBytes(slice self, bytes data) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(data, 0x20)
        }
        self._ptr = ptr;
        self.len = data.length;
        return self;
    }

    /*
     * @dev Returns the 32-bit number at the specified index of self.
     * @param self The slice.
     * @param idx The index into the slice
     * @return The specified 32 bits of slice, interpreted as an integer.
     */
    function uint32At(slice self, uint idx) internal pure returns (uint32 ret) {
        var ptr = self._ptr;
        assembly {
            ret := and(mload(add(sub(ptr, 28), idx)), 0xFFFFFFFF)
        }
    }

    /*
     * @dev Writes a byte to the specified index of self.
     * @param self The slice.
     * @param idx The index into the slice.
     * @param data The byte to write.
     */
    function writeByte(slice self, uint idx, byte d) internal pure {
        var ptr = self._ptr + idx;
        assembly { mstore(ptr, d) }
    }

    function writeUInt64(slice self, uint idx, uint64 data) internal pure {
        var ptr = self._ptr + idx - 24;
        assembly { mstore(ptr, or(and(mload(ptr), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000), data)) }
    }
}

contract SHA1 {
    using BytesUtils for *;

    event Hash(bytes20 hash);

    function sha1(bytes message) public constant returns(bytes20 ret) {
        // Pad to 64 bits
        var padlen = ((message.length + 1) & 0xFFFFFFFFFFFFFFC0) + 64;
        // If there's still not enough space for length, add another 64 bytes
        if(padlen - message.length <= 8) padlen += 64;
        bytes memory paddedMessage = new bytes(padlen);

        BytesUtils.slice memory data;
        data.fromBytes(paddedMessage);

        data.putBytes(0, message);
        data.writeByte(message.length, 0x80);
        data.writeUInt64(paddedMessage.length - 8, 8 * uint64(message.length));

        uint h = 0x6745230100EFCDAB890098BADCFE001032547600C3D2E1F0;
        uint32[80] memory w;
        uint x;
        for(uint i = 0; i < paddedMessage.length; i += 64) {
            for(uint j = 0; j < 16; j++) {
                w[j] = data.uint32At(i + j * 4);
            }
            for(j = 16; j < 80; j++) {
                w[j] = (w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16]);
                w[j] = (w[j] << 1) | (w[j] >> 31);
            }

            x = h;
            uint f;
            uint k;
            for(j = 0; j < 80; j++) {
                // a = 160, b = 120, c = 80, d = 40, e = 0
                if(j <= 19) {
                    // f = d xor (b and (c xor d))
                    f = (x >> 40) ^ ((x >> 120) & ((x >> 80) ^ (x >> 40)));
                    k = 0x5A827999;
                } else if(j <= 39) {
                    // f = b xor c xor d
                    f = (x >> 120) ^ (x >> 80) ^ (x >> 40);
                    k = 0x6ED9EBA1;
                } else if(j <= 59) {
                    // f = (b and c) or (d and (b or c))
                    f = ((x >> 120) & (x >> 80)) | ((x >> 40) & ((x >> 120) | (x >> 80)));
                    k = 0x8F1BBCDC;
                } else {
                    // f = b xor c xor d
                    f = (x >> 120) ^ (x >> 80) ^ (x >> 40);
                    k = 0xCA62C1D6;
                }
                // temp = (a leftrotate 5) + f + e + k + w[i]
                var temp = ((((x >> 155) & 0xFFFFFFE0) | ((x >> 187) & 0x1F)) + f + uint32(x) + k + w[j]) & 0xFFFFFFFF;
                x = (x >> 40) | (temp << 160);
                x = (x & 0xFFFFFFFF00FFFFFFFF000000000000FFFFFFFF00FFFFFFFF) | ((((x >> 50) & 0xC0000000) | ((x >> 82) & 0x3FFFFFFF)) << 80);
            }

            h = (h + x) & 0xFFFFFFFF00FFFFFFFF00FFFFFFFF00FFFFFFFF00FFFFFFFF;
        }

        ret = bytes20(((h >> 32) & 0xFFFFFFFF00000000000000000000000000000000) | ((h >> 24) & 0xFFFFFFFF000000000000000000000000) | ((h >> 16) & 0xFFFFFFFF0000000000000000) | ((h >> 8) & 0xFFFFFFFF00000000) | (h & 0xFFFFFFFF));
        Hash(ret);
    }
}
