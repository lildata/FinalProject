pragma solidity >=0.4.21 <0.7.0;

import "./Owner.sol";

contract Admin
{
    // If there weren't an array of admin addresses, it wouldn't be possible to determine
    // how many or who the admins were.
    address[] adminArray;

    // We use a mapping to determine the addresses of valid admins instead of iterating
    // through the array which could be expensive
    mapping (address => bool) adminMapping;

    modifier isAdmin()
    {
        require (adminMapping[msg.sender] == true, 'Not an admin');
        _;
    }

    // function to add an address as true to the owners (store) mapping
    function addOwner (address _newOwnerAddress)
        public
        isAdmin
    {
        // Adding current length of 'owner' array to 'owners' mapping (OwnerInfo struct)
        // I can use the length because that is what the index will be once added to the
        // 'owner' array. The index is required for the 'removeOwner' function.
        owners[_newOwnerAddress].arrayIndex = owner.length;

        // Changing 'owners' mapping to true for this address
        owners[_newOwnerAddress].ownerOrNot = true;

        // Pushing new owner address onto 'owner' array
        owner.push(_newOwnerAddress);
    }

    function removeOwner (address _currentOwnerAddress)
        public
        isAdmin
    {
        owners[_currentOwnerAddress].ownerOrNot = false;

        owner[owners[_currentOwnerAddress].arrayIndex] = owner[owner.length-1];
        delete owner[owner.length-1];
        owner.length--;
    }
}