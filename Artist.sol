pragma solidity ^0.5.8;
import "./ERC721.sol";
contract Artist is ERC721 {
    mapping(uint256 => ArtWork) artworks;
    address public artist;

    constructor() public {
        artist = msg.sender;
        _safeMint(msg.sender, 0);
    }
    modifier onlyArtist() {
        require(msg.sender == artist);
        _;
    }
    function createArtwork(uint256 hashIPFS, string memory Name)
        public
        onlyArtist
        returns (ArtWork)
    {
        ArtWork artContract = new ArtWork(hashIPFS, Name);
        artworks[hashIPFS] = artContract;
        return artContract;
    }

    function sellArtwork(uint256 hashIPFS, address receiver) public onlyArtist {
        ArtWork artwork = artworks[hashIPFS];
        artwork.safeTransferFrom(address(this), receiver, hashIPFS);
        artwork.setOwner(receiver);
    }

    function checkArtwork(uint256 hashIPFS) public view returns (bool) {
        if (artworks[hashIPFS] == ArtWork(0x0)) {
            return true;
        }
        return false;
    }
}
contract ArtWork is ERC721 {
    address artist;
    string name;
    uint256 hashIPFS;
    address owner;

    constructor(uint256 ipfsHash, string memory artName) public {
        artist = msg.sender;
        name = artName;
        hashIPFS = ipfsHash;
        owner = msg.sender;
        _mint(owner, ipfsHash);
    }

    function setOwner(address newOwner) public {
        if (owner == msg.sender) {
            owner = newOwner;
        }
    }
}
