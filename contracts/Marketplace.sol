pragma solidity >=0.4.21 <0.7.0;

import "./Admin.sol";
import "./Owner.sol";

contract Marketplace
{
    // Address that originally deployed the contract and created the marketplace
    // Only address able to add and remove admins
    address originator;





    // a Product is a type that includes the price, desccription, and quantity
    struct Product
    {
        uint price;
        string description;
        uint qty;
    }

    struct Storefront
    {
        string name;
        string description;
        Product[] products;
    }

    mapping (address => Storefront[]) ownersToStores;



    modifier isOriginator()
    {
        require (originator == msg.sender, 'Not the originator');
        _;
    }

    // 1st mapping connects owner address with a mapping of unique IDs and corresponding
    // storefront mappings
    // 2nd mapping connects the unique ID of a storefront with a mapping of SKUs and
    // corresponding products (Product struct)
    
    // mapping (address => mapping (uint => mapping (uint => Product))) private stores;



    constructor ()
    public
    {
        originator = msg.sender;
    }



    function addAdmin (address _newAdminAddress)
        public
        isOriginator
    {
        admins[_newAdminAddress] = true;
    }

    function removeAdmin (address _currentAdminAddress)
        public
        isOriginator
    {
        admins[_currentAdminAddress] = false;
    }
}