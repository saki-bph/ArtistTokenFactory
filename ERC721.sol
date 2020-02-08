pragma solidity ^0.5.8;

import "./IERC721.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./ERC165.sol";

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    mapping(uint256 => address) private _tokenOwner;
    mapping(uint256 => address) private _approvalUsersList;
    mapping(address => uint256) private _numberOfOwnedToken;
    mapping(address => mapping(address => bool)) public _approvalUsersAllList;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "balance query for the zero address");
        return _numberOfOwnedToken[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "owner query for nonexistent token");
        return owner;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
    {
        safeDataTransferFrom(from, to, tokenId, "");
    }
    function safeDataTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, tokenId, _data);
    }
    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        transferFrom(from, to, tokenId);
        require(
            checkAndCallSafeTransfer(from, to, tokenId, data),
            "transfer to non ERC721Receiver implementer"
        );
    }

    function approve(address approved, uint256 tokenId) public payable {
        address owner = _tokenOwner[tokenId];
        require(approved != owner, "approval to current owner");
        require(
            owner == msg.sender || isApprovedForAll(owner, msg.sender),
            "approve caller is not owner nor approved for all"
        );
        _approvalUsersList[tokenId] = approved;
        emit Approval(owner, approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "approve to caller");
        _approvalUsersAllList[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        return _approvalUsersList[tokenId];
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        return _approvalUsersAllList[owner][operator];
    }
    function isApprovedOrOwner(address sender, uint256 tokenId)
        public
        view
        returns (bool)
    {
        address owner = _tokenOwner[tokenId];
        address approved = _approvalUsersList[tokenId];
        return (sender == owner ||
            sender == approved ||
            isApprovedForAll(owner, msg.sender));
    }
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);
        _numberOfOwnedToken[from] = _numberOfOwnedToken[from].sub(1);
        _numberOfOwnedToken[to] += 1;

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function _clearApproval(uint256 tokenId) private {
        if (_approvalUsersList[tokenId] != address(0)) {
            _approvalUsersList[tokenId] = address(0);
        }
    }
    function checkAndCallSafeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal returns (bool) {
        if (!address(to).isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(to).onERC721Received(
            msg.sender,
            from,
            tokenId,
            data
        );
        return (retval == _ERC721_RECEIVED);
    }
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint256 tokenId, bytes memory _data)
        internal
    {
        _mint(to, tokenId);
        require(
            checkAndCallSafeTransfer(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _tokenOwner[tokenId] = to;
        _numberOfOwnedToken[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }
}