I explain why I chose to use a few different design patterns.

Modifiers (isOriginator, isAdmin, isOwner, stopInEmergency)
    I used these modifiers to create an access control system that ensured that only certain types of users could access certain functions. For example, only owners (isOwner) could create stores and add products to their stoes. Only admins (isAdmin) could add/remove owners. Only the originator (isOriginator) could toggle the circuit breaker function to prevent anyeone from withdrawing funds from the contract.


Require statement in buyProducts
    require (msg.value >= ownersToStores[_storeOwner][_storeIndex].skuToProducts[_sku].price, 'not enough ether');

    I used this require statement to ensure that the ether transmitted in the transaction to buy a product was sufficient to purchase the product. 

Owner and Admin Address Mappings
    I used mappings of the owner and admin addresses so that I didn't have to iterate through an array to use the modifiers listed above.
