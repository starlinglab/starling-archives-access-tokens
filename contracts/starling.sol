// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract starling is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter  private _tokenIds;
    mapping(uint256=> string) public tokenIdtoCollection;
    mapping(uint256=> string) public tokenIdtoLITkey;
    mapping(uint256=> string) public tokenIdtoAccessCondition;
    mapping(uint256=> address) public tokenIdtoCreator;

    constructor() ERC721("StarlingTestAccessToken","SLACT"){

    }

    function generateCharacter(uint256 tokenId) public view returns  (string memory) {
        bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Starling Test Access Token",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Collection: ", getCollection(tokenId),'</text>',
        '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }
    function getCollection(uint256 tokenId) public view returns (string memory){
        return tokenIdtoCollection[tokenId];
    }
    function getAcessCondition(uint256 tokenId) public view returns (string memory){
        return tokenIdtoAccessCondition[tokenId];
    }
    function getLITKey(uint256 tokenId) public view returns (string memory){
        return tokenIdtoLITkey[tokenId];
    }
    function getTokenURI(uint256 tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Starling Access Token Test #', tokenId.toString(), '",',
                '"description": "Starling Lab Test NFT",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdtoCollection[newItemId] = "uninitialized";
        tokenIdtoLITkey[newItemId] = "";
        tokenIdtoAccessCondition[newItemId] = "";
        tokenIdtoCreator[newItemId] = msg.sender;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }
    function initializeLIT(uint256 tokenId, string memory CollectionName, string memory LitKey, string memory AccessCondition) public {
        require(_exists(tokenId), "Token not found");
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update token");
        tokenIdtoCollection[tokenId] = CollectionName;
        tokenIdtoLITkey[tokenId] = LitKey;
        tokenIdtoAccessCondition [tokenId] = AccessCondition;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}