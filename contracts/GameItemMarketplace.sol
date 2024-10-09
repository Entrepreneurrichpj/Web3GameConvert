// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameItemMarketplace is ERC1155, Ownable {
    // Structure to define a game item
    struct Item {
        uint256 itemId;
        string description;
        string imageURI;  // URI to the image for the item
        uint256 price;
        bool isForSale;
        address owner;
        uint256 supply;  // Total supply of the item
    }

    // Mapping from user address to an array of Item details
    mapping(address => Item[]) public items;

    Item[] public allItems;

    // Total number of unique item types created
    uint256 private _totalItems;

    // Event to emit when an item is listed
    event ItemListed(uint256 itemId, uint256 price);

    // Event to emit when an item is bought
    event ItemBought(uint256 itemId, address buyer, address seller, uint256 price, uint256 amount);

    // Constructor to initialize the base URI
    constructor() ERC1155("https://game-items.example/api/metadata/{id}.json") Ownable(msg.sender) {}

    // Function to mint a new item
    function mintItem(
        uint256 itemId,
        uint256 supply,
        string memory description,
        string memory imageURI,
        uint256 price,
        bool isForSale
    ) public onlyOwner {
        require(supply > 0, "Supply must be greater than zero");

        // Mint the item with a given supply to the caller's address
        _mint(msg.sender, itemId, supply, "");

        // Create a new item and store its details in the caller's item list
        Item memory item = Item({
            itemId: itemId,
            description: description,
            imageURI: imageURI,
            price: price,
            isForSale: isForSale,
            owner: msg.sender,
            supply: supply
        });
        items[msg.sender].push(item);
        allItems.push(item);

        _totalItems++; // Increment the total number of unique items
    }

    function toggleSale(uint256 itemId) public {
        Item[] storage userItems = items[msg.sender];
        for (uint256 i = 0; i < userItems.length; i++) {
            if (userItems[i].itemId == itemId) {
                userItems[i].isForSale = !userItems[i].isForSale; // Toggle sale status
                break;
            }
        }
    }

    // Function to get all items owned by the message sender
    function getItemsOwnedBySender() public view returns (
        uint256[] memory, string[] memory, string[] memory, uint256[] memory, bool[] memory, uint256[] memory
    ) {
        Item[] memory senderItems = items[msg.sender];
        uint256 itemCount = senderItems.length;

        // Allocate memory for the arrays to return item properties
        uint256[] memory itemIds = new uint256[](itemCount);
        string[] memory itemDescriptions = new string[](itemCount);
        string[] memory itemImageURIs = new string[](itemCount);
        uint256[] memory itemPrices = new uint256[](itemCount);
        bool[] memory itemIsForSale = new bool[](itemCount);
        uint256[] memory itemSupplies = new uint256[](itemCount);

        // Populate the arrays with item details
        for (uint256 i = 0; i < itemCount; i++) {
            Item memory currentItem = senderItems[i];
            itemIds[i] = currentItem.itemId;
            itemDescriptions[i] = currentItem.description;
            itemImageURIs[i] = currentItem.imageURI;
            itemPrices[i] = currentItem.price;
            itemIsForSale[i] = currentItem.isForSale;
            itemSupplies[i] = currentItem.supply;
        }

        return (itemIds, itemDescriptions, itemImageURIs, itemPrices, itemIsForSale, itemSupplies);
    }

    function getItemsOwnedByUser(address user) public view returns (
        uint256[] memory, string[] memory, string[] memory, uint256[] memory, bool[] memory, uint256[] memory
    ) {
        Item[] memory userItems = items[user];
        uint256 itemCount = userItems.length;

        // Allocate memory for the arrays to return item properties
        uint256[] memory itemIds = new uint256[](itemCount);
        string[] memory itemDescriptions = new string[](itemCount);
        string[] memory itemImageURIs = new string[](itemCount);
        uint256[] memory itemPrices = new uint256[](itemCount);
        bool[] memory itemIsForSale = new bool[](itemCount);
        uint256[] memory itemSupplies = new uint256[](itemCount);

        // Populate the arrays with item details
        for (uint256 i = 0; i < itemCount; i++) {
            Item memory currentItem = userItems[i];
            itemIds[i] = currentItem.itemId;
            itemDescriptions[i] = currentItem.description;
            itemImageURIs[i] = currentItem.imageURI;
            itemPrices[i] = currentItem.price;
            itemIsForSale[i] = currentItem.isForSale;
            itemSupplies[i] = currentItem.supply;
        }

        return (itemIds, itemDescriptions, itemImageURIs, itemPrices, itemIsForSale, itemSupplies);
    }

    // Function to get all items in the contract, regardless of ownership
    function getAllItems() public view returns (
        uint256[] memory, string[] memory, string[] memory, address[] memory
    ) {
        uint256 itemCount = _totalItems;

        uint256[] memory itemIds = new uint256[](itemCount);
        string[] memory itemDescriptions = new string[](itemCount);
        string[] memory itemImageURIs = new string[](itemCount);
        address[] memory itemOwners = new address[](itemCount);

        uint256 index = 0;
        // Iterate through all users and their items to get all items
        for (address user = address(0); user <= address(type(uint160).max); user = address(uint160(user) + 1)) {
            Item[] memory userItems = items[user];
            for (uint256 i = 0; i < userItems.length; i++) {
                itemIds[index] = userItems[i].itemId;
                itemDescriptions[index] = userItems[i].description;
                itemImageURIs[index] = userItems[i].imageURI;
                itemOwners[index] = user;
                index++;
            }
        }

        return (itemIds, itemDescriptions, itemImageURIs, itemOwners);
    }

    // Function to get the total number of unique items
    function totalItems() public view returns (uint256) {
        return _totalItems;
    }

    // Override function to support safe transfer
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}