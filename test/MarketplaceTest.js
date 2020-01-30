var Marketplace = artifacts.require("./Marketplace.sol")

contract('Marketplace', async function(accounts) {
// displaying Ganache accounts. Metamask connects to Ganache.
  const originator = accounts[0]
  const alice = accounts[1]
  const admin = accounts[2]
  const owner = accounts[3]
  const shopper = accounts[4]

  beforeEach(async () => {
    instance = await Marketplace.new();
    await instance.addAdmin(admin, {from: originator});
    await instance.addOwner(owner, {from: admin});
    await instance.addStore('Shoe Store', 'Sells Shoes', {from: owner});
    await instance.addProduct(0,33,'Red Converse',10,200, {from: owner});

  })
    
    it('should add an admin into the admin array', async() => {

        await instance.addAdmin(alice, {from: originator});
        
        let adminArray = await instance.getAdminArray({from: originator});
        
        assert.equal(alice, adminArray[1], "Alice's address should equal first address in Admin array.");
    })

    it('should remove an admin from the admin array', async() => {

        await instance.addAdmin(alice, {from: originator});
        await instance.removeAdmin(alice, {from: originator});
        
        let adminArray = await instance.getAdminArray({from: originator});
        
        assert.notEqual(alice, adminArray[0], "Alice's address should not equal first address in Admin array.");
    })

    it('should verify a product', async() => {

        let tempProduct = await instance.viewProduct(0,33, {from: owner});
        tempPrice = tempProduct[1];
        tempQty = tempProduct[2];

        assert.equal(tempPrice, 10, "Product price should equal 10");
        assert.equal(tempQty, 200, "Product quantity should equal 200.")
    })

    it('should remove a product', async() => {

        await instance.removeProduct(0,33,{from: owner});
        
        let tempProduct = await instance.viewProduct(0,33, {from: owner});
        tempPrice = tempProduct[1];
        tempQty = tempProduct[2];

        assert.notEqual(tempPrice, 10, "Product price should not equal 10.");
        assert.notEqual(tempQty, 200, "Product qty should not equal 200.");
    })

    it('should buy a product', async() => {

        ownerPreBalance = await web3.eth.getBalance(owner) - 10;
        
        await instance.buyProduct(owner, 0, 33, 1, {from: shopper, value: 10});
       
        //check that balance has changed on contract
        contractBalance = await web3.eth.getBalance(instance.address);
        assert.equal(contractBalance, 10, "The balance of the contract account should equal the purchase price.");

        //check that balance has changed for owner
        ownerPostBalance = await web3.eth.getBalance(owner);
        assert.equal(ownerPostBalance, ownerPreBalance, "The balance of the internal owner account should equal the purchase price.");

        //check that quantity has decreased
        //newQuantity = instance.ownersToStores[owner][0].skuToProducts[33].qty;
        let tempProduct = await instance.viewProduct(0,33, {from: owner});
        tempQty = tempProduct[2];
        assert.equal(tempQty, 199, "The new quantity should equal 99.")
    })

    it('should use the imported library function to sum two numbers', async() => {

        result = await instance.getSum(2,3,{from: originator});

        assert.equal(result, 5, "The addTwoNumbers function should produce 5.");
    })
})