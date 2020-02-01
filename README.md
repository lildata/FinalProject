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
Lite-Server (As it's listed in dependencies in the package.JSON file, it shoud install automatically when you use 'npm install' later on)
Metamask
NPM
Ganache

Once, you have downloaded the project files from https://github.com/cjd9s/FinalProject, open a terminal and ensure that you are in the project folder. Before I can use the Truffle scripts, I always have to enter the following 'Set-ExecutionPolicy Bypass -Scope Process' to allow me to run the scripts. I don't know if this is necessary for you.

Type 'npm install' to install all of the dependencies listed in package.JSON.

Now, you should have everything that you need in place. So, start Ganache to create the private, local blockchain. Ensure that the port is set to 7545.

Next, open Chrome/Firefox and sign in to Metamask. You will need to connect to 127.0.0.1 port 7545.

Now type 'truffle compile' at the command line to compile the contracts. 

Then type 'truffle migrate' to migrate the contracts to the Ganache blockchain.

Now type 'truffle test' to run the tests.

Finally, type 'npm run dev' to start the application. This should automatically open a browser window with the appliation.
