var Marketplace = artifacts.require("Marketplace");
var LibraryDemo = artifacts.require("LibraryDemo");

module.exports = function(deployer) {
  deployer.deploy(LibraryDemo);
  deployer.link(LibraryDemo, Marketplace);
  deployer.deploy(Marketplace);
};

/* https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations#deployer-link-library-destinations-

Note that you will need to deploy and link any libraries your contracts depend on first before calling deploy. 
See the link function below for more details.

For more information, please see the LINK*truffle-contract*LINK documentation.

deployer.deploy(LibA);
deployer.link(LibA, B);
deployer.deploy(B);
*/


