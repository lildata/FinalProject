pragma solidity >=0.4.21 <0.7.0;

import "./Admin.sol";

contract Owner
{
    // If there weren't an array of owner addresses, it wouldn't be possible to determine
    // how many or who the owners were.
    address[] ownerArray;

    struct OwnerInfo
    {
        bool ownerOrNot;
        uint arrayIndex;
    }

    // We use a mapping to determine the addresses of valid owners instead of iterating
    // through the array which could be expensive
    mapping (address => ownerInfo) owners;


    modifier isOwner()
    {
        require (owners[msg.sender].ownerOrNot == true, 'Not an owner');
        _;
    }

    function createStorefront (string memory _name, string memory _description)
        public
        isOwner
    {
        Storefront memory tempStore;

        tempStore.name = _name;
        tempStore.description = _description;
        tempStore.storeOwner = msg.sender;

        stores.push(tempStore);
    }

    function removeStorefront (string _name)
    public
    {

    }

    function ownerViewStorefronts ()
    public
    view
    {
        for (uint i = 0; i < ownerToStores.length; i++) // loop for iterating through owner array
        {
            ownerToStores[msg.sender][i].name;
            ownerToStores[msg.sender][i].description;
             // loop for iterating through storefront array for
                                        // message sender owner
                                    // = Storefront[]
        }
    }
}