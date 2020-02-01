I explain what measures I took to ensure that my contracts are not susceptible to common attacks.

Re-entrancy attack defense on withdraw contract
If you can’t remove the external call, the next simplest way to prevent this attack is to do the internal work before making the external function call. So, in the Withdraw Contract Balance function I set the state variable tracking the owner's internal contract balance to zero before using .transfer to send funds to avoid reentrancy attacks.

Integer Overflow and Underflow
I actually didn't do anything to prevent this because I ran out of time. However, given time, I would have added a require statment to the buyProduct and removeProduct function prevent the quantity from going below 0 and above the upper limit for uint256.

Circuit Breaker
Although not a direct counter measure to a common attack, the circuit breaker that I added to turn off the withdrawContractBalance function allows me to prevent value withdrawal while I figure out a way to fix the exploitation.