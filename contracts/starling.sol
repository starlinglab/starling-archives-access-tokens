// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract starling is ERC1155URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter  private _tokenIds;
    mapping(uint256=> string) public tokenIdtoArchiveURI;
    mapping(uint256=> string) public tokenIdtoArchiveDescription;
    mapping(uint256=> string) public tokenIdtoLITkey;
    mapping(uint256 => string) public tokenIdImageUri;
    mapping(uint256=> string) public tokenIdtoAccessCondition;
    mapping(uint256=> address) public tokenIdtoCreator;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => string) public tokenIdtoExternal_url;
    string public name = "Starling Test Access Tokens";

    constructor() ERC1155(""){
    }

    function getArchiveURI(uint256 tokenId) public view returns (string memory){
        return tokenIdtoArchiveURI[tokenId];        
    }
    function getArchiveDescription(uint256 tokenId) public view returns (string memory){
        return tokenIdtoArchiveDescription[tokenId];
    }
    function getAccessCondition(uint256 tokenId) public view returns (string memory){
        return tokenIdtoAccessCondition[tokenId];
    }
    function getLITKey(uint256 tokenId) public view returns (string memory){
        return tokenIdtoLITkey[tokenId];
    }
    //Minting
    event Minted(address owner, uint256 _tokenId);
    function mintAdditional(uint256 _tokenId,uint256 amount) public {
        require(tokenIdtoCreator[_tokenId] == msg.sender, "Only creator can mint more tokens");
        _mint(msg.sender,_tokenId,amount,"0x000");
        tokenSupply[_tokenId]+=amount;
    }
    function mint(uint256 amount) public {
        _tokenIds.increment();        
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender,newItemId,amount,"0x000");
        tokenSupply[newItemId]+=amount;

        tokenIdtoArchiveDescription[newItemId] = "uninitialized";
        tokenIdtoLITkey[newItemId] = "";
        tokenIdtoAccessCondition[newItemId] = "";
        tokenIdtoCreator[newItemId] = msg.sender;
        tokenIdtoExternal_url[newItemId] = "";
        tokenIdtoExternal_url[newItemId] = tokenIdtoExternal_url[1];
            
        //_setTokenURI(newItemId, getTokenURI(newItemId));
        emit Minted(msg.sender, newItemId);
    }
    function burnToken(address owner, uint256 _tokenId) public {
        require(tokenIdtoCreator[_tokenId] == msg.sender, "Only creator can burn a tokens");
        _burn(owner,_tokenId,1);
        tokenSupply[_tokenId]-=1;
    }
    //Sole boundish token
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual override {
        super._beforeTokenTransfer(operator, from, to,ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++) {
            require(tokenIdtoCreator[ids[i]] == address(0) || from == tokenIdtoCreator[ids[i]] || to == tokenIdtoCreator[ids[i]], "Tokens can only flow to/from creator");
        }
    }
    event MetadataUpdate(uint256 _tokenId);
    function initializeLIT(uint256 tokenId, string memory ArchiveDescription, string memory LitKey, string memory AccessCondition, string memory ArchiveURI, string memory ImageURI) public {
        //require(exists(tokenId), "Token not found");
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update token");
        tokenIdtoArchiveDescription[tokenId] = ArchiveDescription;
        tokenIdtoLITkey[tokenId] = LitKey;
        tokenIdtoAccessCondition [tokenId] = AccessCondition;
        tokenIdtoArchiveURI[tokenId] = ArchiveURI;
        tokenIdImageUri[tokenId] = ImageURI;
        emit MetadataUpdate(tokenId);
    }
    function setExternalUrl(uint256 tokenId, string memory url) public {
        //require(exists(tokenId), "Token not found");
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update externalURL");
        tokenIdtoExternal_url[tokenId]=url;
        emit MetadataUpdate(tokenId);
    }
    function tokenCount() public view returns (uint256) {
        return _tokenIds.current();
    }
    // Dynamic URI Stuff
    function generateImg(uint256 tokenId) private view returns  (string memory) {
        bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Starling Test Access Token",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Archive Description: ", getArchiveDescription(tokenId),'</text>',
        '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }
    function uri(uint256 tokenId) override public view returns (string memory) {
        return getTokenURI(tokenId);
    }
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI;
        bytes memory tempEmptyStringTest = bytes(tokenIdImageUri[tokenId]);
        if (tempEmptyStringTest.length == 0) {        
            dataURI = abi.encodePacked(
                '{',
                    '"name": "Starling Access Token for ', tokenIdtoArchiveDescription[tokenId] , '",',
                    '"description": "Token # ', tokenId.toString() , '",',
                    '"image_data": "', generateImg(tokenId), '",',
                    '"external_url": "', tokenIdtoExternal_url[tokenId], tokenId.toString() ,  '"',
                '}'
            );
        } else {
            dataURI = abi.encodePacked(
                '{',
                    '"name": "Starling Access Token for ', tokenIdtoArchiveDescription[tokenId] , '",',
                    '"description": "Token # ', tokenId.toString() , '",',
                    '"image": "',tokenIdImageUri[tokenId], '",',
                    '"external_url": "', tokenIdtoExternal_url[tokenId], tokenId.toString() ,  '"',
                '}'
            );
        }
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}