pragma solidity >=0.4.21 <0.7.0;

/// @title A demo library for the purposes of showing how to use a library
/// @author Craig DuBose
/// @notice This contract is incomplete and is only intended to fulfil the bare requirements
/// @notice of the Consensys Developer Bootcamp course
/// @dev There is only a function to add two numbers for the purposes of demonstration

library LibraryDemo
{
    /// @dev  addTwoNumbers function is used to add two numbers
    /// @param  numberOne is any uint
    /// @param  numberTwo is any uint
    /// @return sum is an addition of numberOne and numberTwo

    function addTwoNumbers(uint numberOne, uint numberTwo)
    public
    pure
    returns (uint)
    {
        uint sum = numberOne + numberTwo;
        return sum;
    }
}
