 /*
    Project: Degen Token (ERC-20): Unlocking the Future of Gaming
    
    Project Specifications:

    1. Minting new tokens: The platform should be able to create new tokens 
    and distribute them to players as rewards. Only the owner can mint tokens.

    2. Transferring tokens: Players should be able to transfer their tokens 
    to others.

    3. Redeeming tokens: Players should be able to redeem their tokens for 
    items in the in-game store.

    4. Checking token balance: Players should be able to check their token 
    balance at any time.

    5. Burning tokens: Anyone should be able to burn tokens, that they own, 
    that are no longer needed.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.9.0/token/ERC20/extensions/ERC20Burnable.sol";

contract DegenToken is ERC20, Ownable {
    // Data structure for the ingame items that consists name, stats, price, and total supply
    struct IngameItem {
        string name;
        string stats;
        uint256 price;
        uint256 totalSupply;
    }

    // Array that consists the struct IngameItem
    IngameItem[] public gameItems;

    // A constructor that is executed once compiled and deployed
    constructor() ERC20("Degen", "DGN") {
        createGameItem("Blue Dagger", "Agility", 120, 40);
        createGameItem("Long Sword", "Attack Damage", 100, 30); 
        createGameItem("Gold Breastplate", "Defense", 300, 50);  
        createGameItem("Boots of Hermes", "Speed Boost", 1000, 35);   
    }


    /*
        The functions below consists minting,, transferring,
        redeeming, checking balance, and burning of tokens
    */

    // Mints token only accessible to the owner
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Transfers DGN tokens from sender to receiver
    function transferTokens(address _receiver, uint256 _value) external {
        require(_receiver != address(0), "Invalid address, not found");
        require(balanceOf(msg.sender) >= _value, "Insufficient balance for transferring tokens");
        _transfer(msg.sender, _receiver, _value);
    }

    // An event listening to RedeemAttempt once called from redeemTokens function
    event RedeemAttempt(address indexed sender, uint256 itemIndex, uint256 balance);

    // A redeem token function 
    function redeemTokens(uint256 _itemIndex) external payable {
        emit RedeemAttempt(msg.sender, _itemIndex, balanceOf(msg.sender));
        require(_itemIndex < gameItems.length, "Invalid item index, not found");
        IngameItem storage item = gameItems[_itemIndex];
        require(item.totalSupply > 0, "The item is out of stock");
        uint256 itemPrice = item.price;

        _burn(msg.sender, itemPrice);
        item.totalSupply--; // Reduce the total supply of the redeemed item
    }

    // Checks balance of account inputted on the address _account 
    function checkBalance(address _account) external view returns (uint256) {
        return balanceOf(_account);
    }

    // Burns tokens accessible by any address or user
    function burnTokens(uint256 _value) external {
        require(balanceOf(msg.sender) >= _value, "Invalid value for burning tokens");
        _burn(msg.sender, _value);
    }


    /*
        Functions below include creating a game item,
        getting the ingame item count, getting the item
        details, and getting the list of all items
    */

    // Creates a game item by pushing it into the struct
    function createGameItem(string memory _name, string memory _stats, uint256 _price, uint256 _initialSupply) internal onlyOwner {
        gameItems.push(IngameItem(_name, _stats, _price, _initialSupply));
    }

    // Acquires the ingame item count and returns the value
    function getIngameItemCount() external view returns (uint256) {
        return gameItems.length;
    }

    // Lists the game item based on the index stored 
    function getGameItems(uint256 _itemIndex) external view returns (string memory name, string memory stats, uint256 price, uint256 totalSupply) {
        require(_itemIndex < gameItems.length, "Invalid item index, not found");
        IngameItem storage item = gameItems[_itemIndex];
        return (item.name, item.stats, item.price, item.totalSupply);
    }

    // Lists all the game items from the struct
    function listGameItems() external view returns (IngameItem[] memory) {
        require(gameItems.length > 0, "There are currently no game items");
        return gameItems;
    }
}
