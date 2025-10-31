// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

// Simplified ValidatorAnnounce for Kasplex
contract ValidatorAnnounce {
    address public immutable mailbox;
    
    // validator => storage locations
    mapping(address => string[]) public storageLocations;
    // prevent replay attacks
    mapping(bytes32 => bool) public replayProtection;
    
    event ValidatorAnnouncement(address indexed validator, string storageLocation);
    
    constructor(address _mailbox) {
        mailbox = _mailbox;
    }
    
    function announce(
        address _validator,
        string calldata _storageLocation,
        bytes calldata _signature
    ) external returns (bool) {
        // Prevent replay
        bytes32 replayId = keccak256(abi.encodePacked(_validator, _storageLocation));
        require(!replayProtection[replayId], "replay");
        replayProtection[replayId] = true;
        
        // Verify signature
        bytes32 digest = getAnnouncementDigest(_storageLocation);
        bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest));
        address signer = recoverSigner(ethSignedHash, _signature);
        require(signer == _validator, "!signature");
        
        // Store announcement
        storageLocations[_validator].push(_storageLocation);
        emit ValidatorAnnouncement(_validator, _storageLocation);
        
        return true;
    }
    
    function getAnnouncementDigest(string calldata _storageLocation) public view returns (bytes32) {
        uint32 domain = uint32(block.chainid);
        return keccak256(
            abi.encodePacked(
                domain,
                mailbox,
                "HYPERLANE_ANNOUNCEMENT",
                _storageLocation
            )
        );
    }
    
    function getAnnouncedStorageLocations(address[] calldata _validators) 
        external 
        view 
        returns (string[][] memory) 
    {
        string[][] memory result = new string[][](_validators.length);
        for (uint256 i = 0; i < _validators.length; i++) {
            result[i] = storageLocations[_validators[i]];
        }
        return result;
    }
    
    function recoverSigner(bytes32 _hash, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        
        if (v < 27) {
            v += 27;
        }
        
        require(v == 27 || v == 28, "invalid signature v value");
        
        return ecrecover(_hash, v, r, s);
    }
}
