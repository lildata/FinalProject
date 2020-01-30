# FinalProject
 
This readme file will explain the nature of the project and how to set up the appropriate infrastructure to sucessfully run it. 
 
Nature of the project
This project is a marketplace that uses the Ethereum blockchain to store various states. There are four types of users of the marketplace:
originator, admin, owner, and shopper. The originator is address that originally deployed the contract and can add and remove admins. The
admins can add and remove owners. The owners can add/remove/view stores, add/remove products, change prices, and withdraw their
funds from the contract. Shoppers can see all of the stores, enter stores to see products therein, and purchase products. 

However, it is likely that I have been unable to create all the functionality described above. At this moment (28/01/2020), the dapp has
the ability to add to admin and owner arrays in the smart contract. It can also read those arrays and display the results in the UI. My
understanding is that, although far from complete, the application has provided sufficient functionality to meet the basic requirements
of the final project.

In order to run this application, you will need several additional programs. I have used the following:
 
Visual Studio Code
Truffle
Lite-Server
Metamask


The recommended installation method is a local NPM install for your project:
$ npm install lite-server --save-dev


$ truffle compile
$ truffle migrate
$ npm run dev
