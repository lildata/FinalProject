pragma solidity >=0.4.21 <0.7.0;

library LibraryDemo
{
    function addTwoNumbers(uint numberOne, uint numberTwo)
    public
    pure
    returns (uint)
    {
        uint sum = numberOne + numberTwo;
        return sum;
    }
}