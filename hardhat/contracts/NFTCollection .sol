// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract NFTCollection is ERC721Enumerable, Ownable {

    string _baseTokenURI;
    uint256 public _price = 0.01 ether;
    bool public _paused;
    uint256 public  maxTokenIds = 20;
    uint256 public tokenIds;
    IWhitelist whitelist;
    bool public presaleStarted;
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Sale currently paused");
        _;
    }

    constructor(string memory baseURI, address WhitelistContract) ERC721("Vagner NFT", "VAG") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(WhitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }


    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds , "All nft has been minted");
        require(msg.value >= _price, "Not enough ether sent");
        tokenIds ++;
        _safeMint(msg.sender, tokenIds);
    }


    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds ++;
        _safeMint(msg.sender, tokenIds);
    }


    function _basURI() internal view virtual returns(string memory) {
        return _baseTokenURI;
    }

    
    function setPause(bool val) public onlyOwner {
        _paused = val;
    }

    
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool success, ) = _owner.call{value:amount}("");
        require(success, "Transaction not succefull");
    }

    
    receive () external payable {

    }

    fallback () external payable {

    }


    
}
