pragma solidity >=0.4.21 <0.7.0;

import './LibraryDemo.sol';

contract Marketplace
{
    // a Product is a type that includes the price, desccription, and quantity
    struct Product
    {
        uint price;
        string description;
        uint qty;
    }

    struct Store
    {
        string name;
        string description;
        mapping (uint => Product) skuToProducts;
    }

    struct OwnerInfo
    {
        bool ownerOrNot;
        uint arrayIndex;
        uint balance;
    }

    struct AdminInfo
    {
        bool adminOrNot;
        uint arrayIndex;
    }

    // Address that originally deployed the contract and created the marketplace
    // Only address able to add and remove admins
    address private originatorAddress;
    bool private stopped = false;

    modifier stopInEmergency()
    {
        if (!stopped)
        _;
    }

    function toggleContractActive()
    public
    isOriginator
    {
        stopped = !stopped;
    }

    // If there weren't an array of admin addresses, it wouldn't be possible to determine
    // how many or who the admins were.
    address[] adminArray;

    // If there weren't an array of owner addresses, it wouldn't be possible to determine
    // how many or who the owners were.
    address[] ownerArray;

    // We use a mapping to determine the addresses of valid owners instead of iterating
    // through the array which could be expensive
    mapping (address => OwnerInfo) public ownerMapping;

    // We use a mapping to determine the addresses of valid admins instead of iterating
    // through the array which could be expensive
    mapping (address => AdminInfo) public adminMapping;

    mapping (address => Store[]) ownersToStores;

    modifier isOwner()
    {
        require (ownerMapping[msg.sender].ownerOrNot == true, 'Not an owner');
        _;
    }

    modifier isOriginator()
    {
        require (originatorAddress == msg.sender, 'Not the originator');
        _;
    }

    modifier isAdmin()
    {
        require (adminMapping[msg.sender].adminOrNot == true, 'Not an admin');
        _;
    }

    event storeCreated(address owner, string name, string description);
    event adminAdded(address newAdmin);
    event productBought(address storeOwner, uint store, uint sku, uint qty);
    // 1st mapping connects owner address with a mapping of unique IDs and corresponding
    // storefront mappings
    // 2nd mapping connects the unique ID of a storefront with a mapping of SKUs and
    // corresponding products (Product struct)
    // mapping (address => mapping (uint => mapping (uint => Product))) private stores;

    constructor ()
    public
    {
        originatorAddress = msg.sender;
    }

    function getSum(uint num1, uint num2)
    public
    pure
    returns (uint)
    {
        return LibraryDemo.addTwoNumbers(num1, num2);
    }

    function getOwnerArrayMapping(address _ownerAddress)
    public
    view
    isAdmin
    returns (bool ownerOrNot, uint arrayIndex)
    {
        ownerOrNot = ownerMapping[_ownerAddress].ownerOrNot;
        arrayIndex = ownerMapping[_ownerAddress].arrayIndex;
    }

    function getOwnerArray()
    public
    view
    isAdmin
    returns (address[] memory)
    {
        return ownerArray;
    }

    function getAdminArrayMapping(address _adminAddress)
    public
    view
    isOriginator
    returns (bool adminOrNot, uint arrayIndex)
    {
        adminOrNot = adminMapping[_adminAddress].adminOrNot;
        arrayIndex = adminMapping[_adminAddress].arrayIndex;
    }

    function getAdminArray()
    public
    view
    isOriginator
    returns (address[] memory)
    {
        return adminArray;
    }

    // function to add an address as true to the owners (store) mapping
    function addOwner (address _newOwnerAddress)
    public
    isAdmin
    {
        // Adding current length of 'ownerArray' array to 'ownerMapping' mapping (OwnerInfo struct)
        // I can use the length because that is what the index will be once added to the
        // 'owner' array. The index is required for the 'removeOwner' function.
        ownerMapping[_newOwnerAddress].arrayIndex = ownerArray.length;

        // Changing 'ownerMapping' mapping to true for this address
        ownerMapping[_newOwnerAddress].ownerOrNot = true;

        // Pushing new owner address onto 'ownerArray' array
        ownerArray.push(_newOwnerAddress);
    }

    function removeOwner (address _currentOwnerAddress)
    public
    isAdmin
    {
        ownerMapping[_currentOwnerAddress].ownerOrNot = false;

        ownerArray[ownerMapping[_currentOwnerAddress].arrayIndex] = ownerArray[ownerArray.length-1];
        delete ownerArray[ownerArray.length-1];
        ownerArray.pop();
    }

    function addAdmin (address _newAdminAddress)
    public
    isOriginator
    {
        // Adding current length of 'owner' array to 'owners' mapping (OwnerInfo struct)
        // I can use the length because that is what the index will be once added to the
        // 'owner' array. The index is required for the 'removeOwner' function.
        adminMapping[_newAdminAddress].arrayIndex = adminArray.length;

        // Changing 'adminMapping' mapping to true for this address
        adminMapping[_newAdminAddress].adminOrNot = true;

        // Pushing new admin address onto 'adminArray' array
        adminArray.push(_newAdminAddress);

        emit adminAdded(_newAdminAddress);

    }

    function removeAdmin (address _currentAdminAddress)
        public
        isOriginator
    {
        adminMapping[_currentAdminAddress].adminOrNot = false;

        adminArray[adminMapping[_currentAdminAddress].arrayIndex] = adminArray[adminArray.length-1];
        delete adminArray[adminArray.length-1];
        adminArray.pop();
    }


    function addStore (string memory _name, string memory _description)
    public
    isOwner
    {
        Store memory tempStore;

        tempStore.name = _name;
        tempStore.description = _description;

        ownersToStores[msg.sender].push(tempStore);

        emit storeCreated(msg.sender, _name, _description);
    }

    function removeStore (uint removeStoreIndex)
    public
    isOwner
    {

        if ((removeStoreIndex == 0) && (ownersToStores[msg.sender].length == 1))
        {
            delete ownersToStores[msg.sender][removeStoreIndex];
            ownersToStores[msg.sender].pop();
        }
        else
        {
            ownersToStores[msg.sender][removeStoreIndex] = ownersToStores[msg.sender][ownersToStores[msg.sender].length-1];
            delete ownersToStores[msg.sender][ownersToStores[msg.sender].length-1];
            ownersToStores[msg.sender].pop();
        }
    }

    function getStoreArrayLength()
    public
    view
    isAdmin
    returns (uint)
    {
        return ownersToStores[msg.sender].length;
    }

    function addProduct (uint _storeIndex, uint _sku, string memory _description, uint _price,uint _qty)
    public
    isOwner
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description = _description;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = _price;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty = _qty;
    }

    function viewProduct (uint _storeIndex, uint _sku)
    public
    view
    isOwner
    returns (string memory, uint, uint)
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        string memory tempDescription = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description;
        uint tempPrice = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price;
        uint tempQty = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty;

        return (tempDescription, tempPrice, tempQty);
    }

    function removeProduct (uint _storeIndex, uint _sku)
    public
    isOwner
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description = '';
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = 0;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty = 0;
    }

    function changeProductPrice (uint _storeIndex, uint _sku, uint _newPrice)
    public
    isOwner
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = _newPrice;
    }

    function buyProduct (address payable _storeOwner, uint _storeIndex, uint _sku, uint _qty)
    public
    payable
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        //require (msg.value >= ownersToStores[_storeOwner][_storeIndex].skuToProducts[_sku].price, 'not enough ether');

        ownersToStores[_storeOwner][_storeIndex].skuToProducts[_sku].qty -= _qty;
        ownerMapping[_storeOwner].balance += msg.value;

        emit productBought (_storeOwner, _storeIndex, _sku, _qty);
    }

    function viewOwnerContractBalance()
    public
    view
    isOwner
        returns (uint)
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value

        uint tempBalance = ownerMapping[msg.sender].balance;

        return tempBalance;
    }

    function withdrawContractBalance()
    public
    payable
    isOwner
    stopInEmergency
    {
        //ownersToStores[msg.sender] is equal to array of Storefronts
        // user provides _storeIndex to determine which store to add product
        // user provides _sku for key value of mapping and Product struct is the value
        uint tempBalance = ownerMapping[msg.sender].balance;
        ownerMapping[msg.sender].balance = 0;

        // shouldn't rely on gas cost of .transfer
        msg.sender.transfer(tempBalance);
    }

}