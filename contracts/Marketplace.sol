pragma solidity >=0.4.21 <0.7.0;

/// @title A marketplace for the sale of goods
/// @author Craig DuBose
/// @notice This contract is incomplete and is only intended to fulfil the bare requirements
/// @notice of the Consensys Developer Bootcamp course
/// @dev This contract is far from finished. Although a lot of the basics are in place, there are plenty more
/// @dev require statements needed to ensure that the functions only accept valid inputs. It is missing lots of
/// @dev events that would be needed to update the UI effectively. And frankly, I think that a lot of the state
/// @dev variables are unnecessary. I do use them to show functionality, but it's more likley that if I had more time
/// @dev I would ditch all state variables except for the originator address, owner address=>bool, and admin
/// @dev address=>bool. I need those to validate the isOriginator, isOwner, and isAdmin function modifiers.
/// @dev Everything else I would emit as an event and store those in data structures in the Javascript.
/// @dev Essentially, you should set this contract on fire and run away with all haste.

import './LibraryDemo.sol';

contract Marketplace
{
    /// @dev  Product is a struct that includes the price, description, and quantity

    struct Product
    {
        uint price;
        string description;
        uint qty;
    }

    /// @dev  Store is a struct that includes the name, description, and skuToProduct mapping

    struct Store
    {
        string name;
        string description;
        mapping (uint => Product) skuToProducts;
    }

    /// @dev  OwnerInfo is a struct that is used in the mapping (address => OwnerInfo) public ownerMapping.
    /// @dev  The ownerOrNot bool describes if that address is an owner, the arrayIndex uint describes it's position
    /// @dev  in the owner array, and the balance uint describes how much of the marketplace contract ether is owned.

    struct OwnerInfo
    {
        bool ownerOrNot;
        uint arrayIndex;
        uint balance;
    }

    /// @dev  AdminInfo is a struct that is used in the mapping (address => AdminInfo) public AdminMapping.
    /// @dev  The adminOrNot bool describes if that address is an admin. The arrayIndex uint describes it's position
    /// @dev  in the owner array which is needed when removing the address from the array.

    struct AdminInfo
    {
        bool adminOrNot;
        uint arrayIndex;
    }

    /// @dev  originatorAddress is the address that originally deployed the contract and created the marketplace
    /// @dev  It is the only address able to add and remove admins

    address private originatorAddress;

    /// @dev  The stopped bool is used in the stopInEmergency modifier. It starts as false and can be toggled by the
    /// @dev  originator using the toggleContractActive function. It is used in the stopInEmergency modifier which
    /// @dev  is only used on the withdrawContractBalance function.

    bool private stopped = false;

    /// @dev  adminArray is an array of admin addresses.

    address[] adminArray;

    /// @dev  ownerArray is an array of owner addresses.

    address[] ownerArray;

    /// @dev  ownerMapping is a mapping to determine the addresses of valid owners instead of iterating
    /// @dev  through the ownerArray

    mapping (address => OwnerInfo) public ownerMapping;

    /// @dev  adminMapping is a mapping to determine the addresses of valid admins instead of iterating
    /// @dev  through the adminArray

    mapping (address => AdminInfo) public adminMapping;

    /// @dev  ownersToStores is a mapping to associate the owner address with an array of Stores structs

    mapping (address => Store[]) ownersToStores;

    /// @dev  isOwner is used to restrict access on functions to only owners

    modifier isOwner()
    {
        require (ownerMapping[msg.sender].ownerOrNot == true, 'Not an owner');
        _;
    }

    /// @dev  isOriginator is used to restrict access on functions to only the originator

    modifier isOriginator()
    {
        require (originatorAddress == msg.sender, 'Not the originator');
        _;
    }

    /// @dev  isAdmin is used to restrict access on functions to only admins

    modifier isAdmin()
    {
        require (adminMapping[msg.sender].adminOrNot == true, 'Not an admin');
        _;
    }

    /// @dev  The stopInEmergency modifier is only used on the withdrawContractBalance function as a circuit breaker.

    modifier stopInEmergency()
    {
        if (!stopped)
        _;
    }

    /// @dev  storeCreated event is emitted when a store struct is created and is used to update the UI

    event storeCreated(address owner, string name, string description);

    /// @dev  admindAdded event is emitted when an admin is added and is used to update the UI

    event adminAdded(address newAdmin);

    /// @dev  productBought event is emitted when a product is purchased and is used to update the UI

    event productBought(address storeOwner, uint store, uint sku, uint qty);

    /// @dev  constructor function assigns the address of the original deployer of the function as the originator

    constructor ()
    public
    {
        originatorAddress = msg.sender;
    }

    /// @dev  getSum function is used to demonstrate the example library that I included to meet the project
    /// @dev  requirements. I suppose it's worth mentioning that the input isn't controlled so there is the
    /// @dev  opportunity for the user to overflow the result. This function is part of the Truffle tests.
    /// @param  _num1 is any uint
    /// @param  _num2 is any uint
    /// @return  a uint that is the sum of num1 and num2

    function getSum(uint _num1, uint _num2)
    public
    pure
    returns (uint)
    {
        return LibraryDemo.addTwoNumbers(_num1, _num2);
    }

    /// @dev  getOwnerArrayMapping function is used to test if the mapping was correctly written when an
    /// @dev  owner is added. This is only for development purposes.
    /// @param  _ownerAddress is the address of the owner for which you would like to check the ownerMapping
    /// @return  ownerOrNot is a bool of whether the address is an owner or not
    /// @return  arrayIndex is a uint that describes the index position of the owner address in the ownerArray

    function getOwnerArrayMapping(address _ownerAddress)
    public
    view
    isAdmin
    returns (bool ownerOrNot, uint arrayIndex)
    {
        ownerOrNot = ownerMapping[_ownerAddress].ownerOrNot;
        arrayIndex = ownerMapping[_ownerAddress].arrayIndex;

        return (ownerOrNot, arrayIndex);
    }

    /// @dev  getOwnerArray function is used to pass the ownerArray to the UI for display purposes.
    /// @return  ownerArray is an array of all of the owners in the contract account

    function getOwnerArray()
    public
    view
    isAdmin
    returns (address[] memory)
    {
        return ownerArray;
    }

    /// @dev  getAdminArrayMapping function is used to test if the mapping was correctly written when an
    /// @dev  admin is added. This is only for development purposes.
    /// @param  _adminAddress is the address of the owner for which you would like to check the adminMapping
    /// @return  adminOrNot is a bool of whether the address is an admin or not
    /// @return  arrayIndex is a uint that describes the index position of the admin address in the adminArray

    function getAdminArrayMapping(address _adminAddress)
    public
    view
    isOriginator
    returns (bool adminOrNot, uint arrayIndex)
    {
        adminOrNot = adminMapping[_adminAddress].adminOrNot;
        arrayIndex = adminMapping[_adminAddress].arrayIndex;
    }

    /// @dev  getAdminArray function is used to pass the adminArray to the UI for display purposes.
    /// @return  adminArray is an array of all of the admins in the contract account

    function getAdminArray()
    public
    view
    isOriginator
    returns (address[] memory)
    {
        return adminArray;
    }

    /// @dev  addOwner function is used to add an address to the ownerArray, set ownerMapping bool to true,
    /// @dev  and set ownerMapping index.
    /// @param  _newOwnerAddress is the address of the owner to add

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

    /// @dev  removeOwner function is used to remove an address from the ownerArray and set ownerMapping bool to false.
    /// @param  _currentOwnerAddress is the address of the owner to remove

    function removeOwner (address _currentOwnerAddress)
    public
    isAdmin
    {
        ownerMapping[_currentOwnerAddress].ownerOrNot = false;

        ownerArray[ownerMapping[_currentOwnerAddress].arrayIndex] = ownerArray[ownerArray.length-1];
        delete ownerArray[ownerArray.length-1];
        ownerArray.pop();
    }

    /// @dev  addAdmin function is used to add an address to the adminArray, set adminMapping bool to true,
    /// @dev  and set adminMapping index.
    /// @param  _newAdminAddress is the address of the admin to add

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

    /// @dev  removeAdmin function is used to remove an address from the adminArray and set adminMapping bool to false.
    /// @param  _currentAdminAddress is the address of the admin to remove

    function removeAdmin (address _currentAdminAddress)
        public
        isOriginator
    {
        adminMapping[_currentAdminAddress].adminOrNot = false;

        adminArray[adminMapping[_currentAdminAddress].arrayIndex] = adminArray[adminArray.length-1];
        delete adminArray[adminArray.length-1];
        adminArray.pop();
    }

    /// @dev  addStore function is used to add a store to the store array in the ownersToStores mapping.
    /// @dev  The storeCreated event is emitted to update the UI.
    /// @param  _name is name of the store
    /// @param  _description is a description of the store

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

    /// @dev  removeStore function is used to remove a store from the store array in the ownersToStores mapping.
    /// @dev  There should be a storeRemoved event, but I didn't have time. The transaction sender (owner) can only
    /// @dev  access their own store array. In fact, the admins can't remove stores. Now that I think
    /// @dev  about it, although the admins can remove owners, the stores of the removed owners will still exist in
    /// @dev  the ownersToStores mapping. I don't have time to address this.
    /// @param  _removeStoreIndex is the index of the store in the store array in the ownersToStores mapping.

    function removeStore (uint _removeStoreIndex)
    public
    isOwner
    {

        if ((_removeStoreIndex == 0) && (ownersToStores[msg.sender].length == 1))
        {
            delete ownersToStores[msg.sender][_removeStoreIndex];
            ownersToStores[msg.sender].pop();
        }
        else
        {
            ownersToStores[msg.sender][_removeStoreIndex] = ownersToStores[msg.sender][ownersToStores[msg.sender].length-1];
            delete ownersToStores[msg.sender][ownersToStores[msg.sender].length-1];
            ownersToStores[msg.sender].pop();
        }
    }

    /// @dev  getStoreArrayLength function is used to determine the length of the storeArray. I used this for development
    /// @dev  purposes to ensure stores were being created using the addStore function. It serves no purpose in the
    /// @dev  application.
    /// @return  ownersToStores[msg.sender].length is the length of the stores array for the transaction sender.

    function getStoreArrayLength()
    public
    view
    isAdmin
    returns (uint)
    {
        return ownersToStores[msg.sender].length;
    }

    /// @dev  addProduct function is used to add products objects to the skuToProduct mapping at a particular store to add the product
    /// @dev  index for a particular owner.
    /// @param  _storeIndex is the index for the stores array in the owenersToStores mapping to select a particular store
    /// @param  _sku is the uint key in the skuToProducts mapping that identifies a particular product object (sku = stock keeping unit)
    /// @param  _description is a description of the product
    /// @param  _price is the price of the product
    /// @param  _qty is the quantity of the product

    function addProduct (uint _storeIndex, uint _sku, string memory _description, uint _price,uint _qty)
    public
    isOwner
    {
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description = _description;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = _price;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty = _qty;
    }

    /// @dev  viewProduct function is used to view products objects in the skuToProduct mapping at a particular store
    /// @dev  index for a particular owner. I think that I used this only development purposes to ensure products were being added.
    /// @param  _storeIndex is the index for the stores array in the owenersToStores mapping to select a particular store
    /// @param  _sku is the uint key in the skuToProducts mapping that identifies a particular product object
    /// @return  tempDescription is the description of the product
    /// @return  tempPrice is the price of the product
    /// @return  tempQty is the quantity of the product

    function viewProduct (uint _storeIndex, uint _sku)
    public
    view
    isOwner
    returns (string memory, uint, uint)
    {
        string memory tempDescription = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description;
        uint tempPrice = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price;
        uint tempQty = ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty;

        return (tempDescription, tempPrice, tempQty);
    }

    /// @dev  removeProduct function is used to remove products objects in the skuToProduct mapping at a particular store
    /// @dev  index for a particular owner.
    /// @param  _storeIndex is the index for the stores array in the owenersToStores mapping to select a particular store
    /// @param  _sku is the uint key in the skuToProducts mapping that identifies a particular product object

    function removeProduct (uint _storeIndex, uint _sku)
    public
    isOwner
    {
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].description = '';
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = 0;
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].qty = 0;
    }

    /// @dev  changeProductPrice function is used to change the price of products objects in the skuToProduct mapping at a particular store
    /// @dev  index for a particular owner.
    /// @param  _storeIndex is the index for the stores array in the owenersToStores mapping to select a particular store
    /// @param  _sku is the uint key in the skuToProducts mapping that identifies a particular product object
    /// @param  _newPrice is the new price for the selected product object

    function changeProductPrice (uint _storeIndex, uint _sku, uint _newPrice)
    public
    isOwner
    {
        ownersToStores[msg.sender][_storeIndex].skuToProducts[_sku].price = _newPrice;
    }

    /// @dev  buyProduct function is used to purchase a product in the skuToProduct mapping at a particular store
    /// @dev  index for a particular owner.
    /// @param  _storeOwner is the address of the store owner
    /// @param  _storeIndex is the array index for the store of the storeOwner
    /// @param  _sku is the uint key in the skuToProducts mapping that identifies a particular product object
    /// @param  _qty is the quantity of the product to purchase

    function buyProduct (address payable _storeOwner, uint _storeIndex, uint _sku, uint _qty)
    public
    payable
    {
        require (msg.value >= ownersToStores[_storeOwner][_storeIndex].skuToProducts[_sku].price, 'not enough ether');

        ownersToStores[_storeOwner][_storeIndex].skuToProducts[_sku].qty -= _qty;
        ownerMapping[_storeOwner].balance += msg.value;

        emit productBought (_storeOwner, _storeIndex, _sku, _qty);
    }

    /// @dev  viewOwnerContractBalance function is used to view the internal balance of an owner (a.k.a. how much of the marketplace
    /// @dev  contract account balance belongs to them). This balance is stored in the ownerInfo struct which in turn is stored in the
    /// @dev  Owner mapping.
    /// @return  tempBalance is the internal marketplace contract account balance of the owner

    function viewOwnerContractBalance()
    public
    view
    isOwner
    returns (uint)
    {
        uint tempBalance = ownerMapping[msg.sender].balance;
        return tempBalance;
    }

    /// @dev  withdrawContractBalance function is used by an owner to withdraw all of their funds from the contract

    function withdrawContractBalance()
    public
    payable
    isOwner
    stopInEmergency
    {
        uint tempBalance = ownerMapping[msg.sender].balance;
        ownerMapping[msg.sender].balance = 0;
        msg.sender.transfer(tempBalance);
    }

    /// @dev  The toggleContractActive function toggles the stopped bool used in the stopInEmergency modifier. It can
    /// @dev  only be accessed by the originator.

    function toggleContractActive()
    public
    isOriginator
    {
        stopped = !stopped;
    }

}