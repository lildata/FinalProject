App = {   // could be called anything. in a browser environment, window obejct. Everything the web app can access
          // will be added to the window environment alongside all the other objects.
  web3Provider: null, // this app object has a property called web3Provider
  contracts: {}, // this app object has a property called contracts

  Product: function(description, price, quantity){
    this.description = description;
    this.price = price;
    this.quantity = quantity;
  },
  
  Store: function(owner, name, description, product) {
    this.owner = owner;
    this.name = name;
    this.description = description;
    this.product = product;
  },

  stores: [],

  initWeb3: async function() { //initWeb3 is the name of the function
    // Modern dapp browsers...
    if (window.ethereum) //window is a keyword in browser environment
      // because javascript is run in a browser, it has access to everything in the browser
 
      // end of 2018. Metamask used to inject into every page which was a security concern (could log that 
      // address)
    {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable(); //Metamask will ask if you want to grant access
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      //local run Ethereum node or could be Ganache
    }

    const options = {
      transactionConfirmationBlocks: 1
    }

    web3 = new Web3(App.web3Provider,null,options);

    web3.eth.transactionConfirmationBlocks = 1;

    return App.initContract();
  },

  // make sure metamask connect to ganache blockchain and contract deployed on ganache blockchain

  initContract: function() {

    // So, async ensures that the function returns a promise, and wraps non-promises in it.
    // Essentially, a promise is a returned object to which you attach callbacks, instead 
    // of passing callbacks into a function.

    $.getJSON('Marketplace.json', function(data) { // anonymous async function returns a promise
      // Get the necessary contract artifact file and instantiate it with truffle-contract

      // get network Id from the web3 object. asking Metamask. web3 conntected to metamask.

      /*.then(response => response.blob())
      .then(myBlob => {
      let objectURL = URL.createObjectURL(myBlob);*/
      web3.eth.net.getId().then(networkId => {
      var MarketplaceArtifact = data;

      // return address where contract is deployed
      const deployedNetworkAddress = MarketplaceArtifact.networks[networkId].address;
      App.contracts.Marketplace = new web3.eth.Contract(MarketplaceArtifact.abi, deployedNetworkAddress);

      // Set the provider for our contract
      App.contracts.Marketplace.setProvider(App.web3Provider);
    
      });
    });

    return App.bindEvents()
  },

  // The on() method attaches one or more event handlers for the selected elements and child elements.
  // $(selector).on(event,childSelector,data,function,map)
  bindEvents: function() {
    
    $(document).on('click', '#newAdminAddressSubmit', App.handleAddAdmin);
    $(document).on('click', '#viewAdminArray', App.viewAdminArray);
    $(document).on('click', '#viewAdminMappingSubmit', App.checkAdminMapping);
    $(document).on('click', '#removeAdminSubmit', App.removeAdmin);

    $(document).on('click', '#newOwnerAddressSubmit', App.AddOwner);
    $(document).on('click', '#viewOwnerArray', App.viewOwnerArray);
    $(document).on('click', '#viewOwnerMappingSubmit', App.checkOwnerMapping);
    $(document).on('click', '#removeOwnerSubmit', App.removeOwner);

    $(document).on('click', '#addStoreSubmit', App.addStorefront);
    $(document).on('click', '#viewOwnerArrayLength', App.checkStoreArrayLength);
    $(document).on('click', '#removeStoreSubmit', App.removeStore);

    $(document).on('click', '#addProductSubmit', App.addProduct);
    $(document).on('click', '#viewProductSubmit', App.viewProduct);

    $(document).on('click', '#changeProductPriceSubmit', App.changeProductPrice);

    $(document).on('click', '#buyProductSubmit', App.buyProduct);

    $(document).on('click', '#viewContractBalance', App.viewContractBalance);

    $(document).on('click', '#viewOwnerAddressBalance', App.viewOwnerAddressBalance);
    $(document).on('click', '#viewOwnerContractBalance', App.viewOwnerContractBalance);

    $(document).on('click', '#withdrawBalance', App.withdrawContractBalance);

    $(document).on('click', '#subscribeEvent', App.updateApp);

    $(document).on('click', '#storeButtons', App.populateUI);
  },

  clearStoreColumn: function(){
    

    let element = document.getElementById("stores-column");

    var list = document.getElementById("stores-column").hasChildNodes();  

    if (list) {
      element.removeChild(element.childNodes[0]);
    }

  },

  clearCenterColumn: function(){
    

    let element = document.getElementById("data-column");
    console.log(document);

    var list = document.getElementById("data-column").hasChildNodes();  

    console.log(list);

    if (list) {
      element.removeChild(element.childNodes[0]);
    }

  },

  makeOL: function (array) {
    // Create the list element:
    var list = document.createElement('ol');
    list.setAttribute('id', 'OL');

    for (var i = 0; i < array.length; i++) {
        // Create the list item:
        var item = document.createElement('li');

        // Set its contents:
        item.appendChild(document.createTextNode(array[i]));

        // Add it to the list:
        list.appendChild(item);
    }
    console.log(document);
    // Finally, return the constructed list:
    return list;
  },

  viewOwnerContractBalance: async function(event) {

    let account = await web3.eth.getAccounts();

    let result = App.contracts.Marketplace.methods.viewOwnerContractBalance().call({from: account[0]});
    console.log(result);
    return result;
  },

  withdrawContractBalance: async function(event) {

    let account = await web3.eth.getAccounts();

    let tempBalance = await web3.eth.getBalance(App.contracts.Marketplace.options.address);
    
    let newBalance = 0;

    let contractAddress = App.contracts.Marketplace.options.address;

    let result = App.contracts.Marketplace.methods.withdrawContractBalance().send({from: account[0]});
    console.log(result);
  },

  viewOwnerAddressBalance: async function(event) {

    let account = await web3.eth.getAccounts();

    balance = await web3.eth.getBalance(account[0]);
    console.log(balance);
  },

  viewContractBalance: async function(event) {

    let account = await web3.eth.getAccounts();

    balance = await web3.eth.getBalance(App.contracts.Marketplace.options.address);
    console.log(balance);
  },

  buyProduct: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var buyProductOwnerAddress = document.getElementById("buyProductOwnerAddressValue").value;
    var buyProductStore = document.getElementById("buyProductStoreNumberValue").value;
    var buyProductSku = document.getElementById("buyProductSkuValue").value;
    var buyProductQty = document.getElementById("buyProductQtyValue").value;
    var buyProductPrice = document.getElementById("buyProductPriceValue").value;
    
    let result = App.contracts.Marketplace.methods.buyProduct(buyProductOwnerAddress, buyProductStore, buyProductSku, buyProductQty).send({from: account[0], value: buyProductPrice});

    console.log(App.contracts.Marketplace.options.address);
    console.log(result);
    return result;
  },



  changeProductPrice: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var changedProductStore = document.getElementById("changeProductPriceStoreValue").value;
    var changedProductSku = document.getElementById("changeProductPriceSkuValue").value;
    var changedProductPrice = document.getElementById("changeProductPriceValue").value;
    await App.contracts.Marketplace.methods.changeProductPrice(changedProductStore, changedProductSku, changedProductPrice).send({from: account[0]});

  },



  removeStore: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var removedStore = document.getElementById("removeStoreIndexValue").value;
    console.log(removedStore);
    await App.contracts.Marketplace.methods.removeStore(removedStore).send({from: account[0]});
  },

  viewProduct: async function(event) {

    let account = await web3.eth.getAccounts();

    var inputStoreIndex = document.getElementById("viewProductStoreValue").value;
    var inputProductSku = document.getElementById("viewProductSkuValue").value;
    result = App.contracts.Marketplace.methods.viewProduct(inputStoreIndex,inputProductSku).call({from: account[0]});
    console.log(result);
  },

  addProduct: async function(event) {

    let account = await web3.eth.getAccounts();

    var inputStoreIndex = document.getElementById("newProductStoreValue").value;
    var inputProductSku = document.getElementById("newProductSkuValue").value;
    var inputProductDescription = document.getElementById("newProductDescriptionValue").value;
    var inputProductPrice = document.getElementById("newProductPriceValue").value;
    var inputProductQuantity = document.getElementById("newProductQuantityValue").value;

    result = App.contracts.Marketplace.methods.addProduct(inputStoreIndex,inputProductSku,inputProductDescription,inputProductPrice,inputProductQuantity).send({from: account[0]});
    console.log(result);


  },

  checkStoreArrayLength: async function(event)
  {
    let account = await web3.eth.getAccounts();
    let result = await App.contracts.Marketplace.methods.getStoreArrayLength().call({from: account[0]});
    console.log(result);
  },

  removeOwner: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var removedOwner = document.getElementById("removeOwnerValue").value;
    console.log(removedOwner);
    await App.contracts.Marketplace.methods.removeOwner(removedOwner).send({from: account[0]});
  },

  checkOwnerMapping: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var viewOwnerMapping = document.getElementById("viewOwnerMappingValue").value;

    console.log(account);
    let result = App.contracts.Marketplace.methods.getOwnerArrayMapping(viewOwnerMapping).call({from: account[0]});
    console.log(result);
  },

  viewOwnerArray: async function(event)
  {
    App.clearCenterColumn();
    let account = await web3.eth.getAccounts();
    let result = await App.contracts.Marketplace.methods.getOwnerArray().call({from: account[0]});
    console.log(result);
    document.getElementById('data-column').appendChild(App.makeOL(result));

  },

  AddOwner: async function(event) {

    let account = await web3.eth.getAccounts();

    var inputVal = document.getElementById("newOwnerAddressValue").value;

    let result = App.contracts.Marketplace.methods.addOwner(inputVal).send({from: account[0]}, function(error, transactionHash){

      console.log(transactionHash)
    });
    console.log(1);
  },


  checkAdminMapping: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var viewAdminMapping = document.getElementById("viewAdminMappingValue").value;

    console.log(account);
    let result = await App.contracts.Marketplace.methods.getAdminArrayMapping(viewAdminMapping).call({from: account[0]});
    console.log(result);
  },

  removeAdmin: async function(event)
  {
    let account = await web3.eth.getAccounts();
    var removedAdmin = document.getElementById("removeAdminValue").value;
    console.log(removedAdmin);
    await App.contracts.Marketplace.methods.removeAdmin(removedAdmin).send({from: account[0]});
  },

  viewAdminArray: async function(event)
  {
    App.clearCenterColumn();
    let account = await web3.eth.getAccounts();
    let result = await App.contracts.Marketplace.methods.getAdminArray().call({from: account[0]});
    console.log(result);
    document.getElementById('data-column').appendChild(App.makeOL(result));

  },

  displayStores: async function()
  {
    App.clearStoresColumn();
    let account = await web3.eth.getAccounts();
    let ownerArray = await App.contracts.Marketplace.methods.getOwnerArray().call({from: account[0]});

  },

  updateApp: async function(event) {

    // The on() method attaches one or more event handlers for the selected elements and child elements.
    // $(selector).on(event,childSelector,data,function,map)
    App.contracts.Marketplace.events.storeCreated({
      fromBlock: 0
    }, async function(error, event){ 
      console.log(event.returnValues[0]);
      console.log(event.returnValues[1]);
      console.log(event.returnValues[2]);
      
      //tempProduct = new App.Product("",0,0);
     // tempProductArray = [];

      //tempStore = new App.Store(event.returnValues[0],event.returnValues[1],event.returnValues[2], tempProductArray);

     // App.stores.push(tempStore);
     // console.log(App.stores[0].name);

    })
    .on('data', async function(event){
      
      tempProductArray = [];

      tempStore = new App.Store(event.returnValues[0],event.returnValues[1],event.returnValues[2], tempProductArray);

      App.stores.push(tempStore);
    })
    .on('error', function(error, receipt){});
  },

  populateUI: function(){

    App.clearStoreColumn();
    console.log(App.stores[0].name);

    var list = document.createElement('p');
    list.setAttribute('id', 'StoreButtonElement');

    for (let i=0; i<App.stores.length; i++) 
    {
      var storeButton = document.createElement('button');
      storeButton.innerHTML = App.stores[i].name;
      list.appendChild(storeButton);
    }
    console.log(App.stores[0].name);
    
    document.getElementById('stores-column').appendChild(list);
  },

  

  makeOL: function (array) {
    // Create the list element:
    var list = document.createElement('ol');
    list.setAttribute('id', 'OL');

    for (var i = 0; i < array.length; i++) {
        // Create the list item:
        var item = document.createElement('li');

        // Set its contents:
        item.appendChild(document.createTextNode(array[i]));

        // Add it to the list:
        list.appendChild(item);
    }
    console.log(document);
    // Finally, return the constructed list:
    return list;
  },


  handleAddAdmin: async function(event) {

    let account = await web3.eth.getAccounts();

    console.log(333);
    var inputVal = document.getElementById("newAdminAddressValue").value;

    //inputVal = '0x9901210173964e8B658d387BAe6f919Ce24873aD';

    console.log(inputVal);
    //0123456789abcdef0123456789abcdef0123456789
    App.contracts.Marketplace.methods.addAdmin(inputVal).send({from: account[0]});
    console.log(account[0]);
    //let getAdminArray = App.contracts.Marketplace.methods.getAdminArray().call({from: account[0]});
    //console.log(getAdminArray);

    //let newAddress = '0x'+inputVal;

    //let getAdminMapping = App.contracts.Marketplace.methods.getAdminArrayMappingIndex(newAddress).call({from: account[0]});

  },

  addStorefront: async function(event) {
    event.preventDefault();

    let account = await web3.eth.getAccounts();
    
    var addedStoreName = document.getElementById("newStoreNameValue").value;
    var addedStoreDescription = document.getElementById("newStoreDescriptionValue").value;
    
    App.contracts.Marketplace.methods.addStore(addedStoreName, addedStoreDescription).send({from: account[0]});
  }



// everytime event is triggered, call callback function. event is input to callback function
// will emit object and all information is in the object
// need to inspect object to understand how to pull out relevant data
// will change fucntion body to update the UI
// need to call createStorefront function
 // marketplaceInstance.storeCreated().on('data', event => console.log(event))

 // },
};
/* $(function() { ... });
is just jQuery short-hand for

$(document).ready(function() { ... });
*/
$(function() {

  $(window).load(function() {
    App.initWeb3();
  });
});