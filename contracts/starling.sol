// SPDX-License-Identifier: MIT
// npx hardhat run --network localhost scripts\deploy.js
// npx hardhat run --network mumbai scripts\deploy.js
// npx hardhat verify --network mumbai 0xf318c7b0507a34828c1ae862152892d13620D466
//
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
    mapping(uint256 => string) public tokenIdtoArchiveName;
    mapping(uint256 => string) public tokenIdtoArchiveDescription;
    mapping(uint256 => string) public tokenIdtoArchiveURI;
    mapping(uint256 => string) public tokenIdImageUri;
    mapping(uint256 => string) public tokenIdtoCollection;
    mapping(uint256 => string) public tokenIdtoOrganization;
    mapping(uint256 => string) public tokenIdtoExternalUrl;
    mapping(uint256 => string) public tokenIdtoLITAccessCondition;
    mapping(uint256 => string) public tokenIdtoLITkey;
    mapping(uint256 => address) public tokenIdtoCreator;
    mapping(uint256 => uint256) public tokenSupply;

    string public name = "Access Token (BETA)";
    string public contract_version = "1";
    constructor() ERC1155(""){
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
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender,newTokenId,amount,"0x000");
        tokenSupply[newTokenId]+=amount;

        tokenIdtoArchiveName[newTokenId] = "[Empty]";
        tokenIdtoArchiveDescription[newTokenId] = "";
        tokenIdtoArchiveURI[newTokenId] = "";
        tokenIdImageUri[newTokenId] = "";
        tokenIdtoCollection[newTokenId] = "";
        tokenIdtoOrganization[newTokenId] = "empty";
        tokenIdtoExternalUrl[newTokenId] = "";
        tokenIdtoExternalUrl[newTokenId] = tokenIdtoExternalUrl[1];
        tokenIdtoLITAccessCondition[newTokenId] = "";
        tokenIdtoLITkey[newTokenId] = "";
        tokenIdtoCreator[newTokenId] = msg.sender;
            
        //_setTokenURI(newItemId, getTokenURI(newItemId));
        emit Minted(msg.sender, newTokenId);
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

    //Metadata
    event MetadataUpdate(uint256 _tokenId);
    function updateLIT(uint256 tokenId, string memory litKey, string memory litAccessCondition) public {
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update token");
        tokenIdtoLITkey[tokenId] = litKey;
        tokenIdtoLITAccessCondition [tokenId] = litAccessCondition;
    }
    function updateToken(uint256 tokenId, string memory archiveName, string memory archiveDescription, string memory archiveURI, string memory imageURI, string memory organization, string memory collection) public {
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update token");
        tokenIdtoArchiveName[tokenId] = archiveName;
        tokenIdtoArchiveDescription[tokenId] = archiveDescription;
        tokenIdtoArchiveURI[tokenId] = archiveURI;
        tokenIdImageUri[tokenId] = imageURI;
        tokenIdtoOrganization[tokenId] = organization;
        tokenIdtoCollection[tokenId] = collection;
        emit MetadataUpdate(tokenId);
    }
    function setExternalUrl(uint256 tokenId, string memory url) public {
        //require(exists(tokenId), "Token not found");
        require(tokenIdtoCreator[tokenId] == msg.sender, "Only creator can update externalURL");
        tokenIdtoExternalUrl[tokenId]=url;
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
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',tokenIdtoArchiveName[tokenId],'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', tokenIdtoArchiveDescription[tokenId],'</text>',
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

        string memory img_entry = "";
        if (tempEmptyStringTest.length == 0) {        
            img_entry = string.concat('"image_data": "', generateImg(tokenId), '",');
        } else {
            img_entry = string.concat('"image": "',tokenIdImageUri[tokenId], '",');
        }

        string memory attributes = "";

        attributes=string.concat(attributes,
            '{"trait_type": "collection","value":"', tokenIdtoCollection[tokenId],'"},',
            '{"trait_type": "organization","value":"', tokenIdtoOrganization[tokenId],'"},',
            '{"trait_type": "archive_uri", "value":"', tokenIdtoArchiveURI[tokenId],'"}'
            );


        dataURI = abi.encodePacked(
            '{',
                '"name": "', tokenIdtoArchiveName[tokenId] , '",',
                '"description": "', 
                    tokenIdtoArchiveDescription[tokenId], 
                    '\\n\\nAccess token # ', tokenId.toString()  , '  ',
                    '[View](', tokenIdtoExternalUrl[tokenId], tokenId.toString() , ')',
                '",',
                img_entry,
                '"external_url": "', tokenIdtoExternalUrl[tokenId], tokenId.toString() , '",',
                '"attributes": [' ,attributes,
                ']',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}