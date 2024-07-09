/**
* @type import('hardhat/config').HardhatUserConfig
*/

require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan"); 
require('dotenv').config();

const { API_URL, PRIVATE_KEY,API_URL_arbitrum ,API_URL_arbitrum_mainnet,PRIVATE_KEY_arbitrum_mainnet,PRIVATE_KEY_arbitrum} = process.env;
module.exports = {
   solidity: "0.7.6",
   defaultNetwork: "sepolia",
   networks: {
      hardhat: {},
      sepolia: {
         url: API_URL,
         accounts: [`0x${PRIVATE_KEY}`]
      },
      arbitrumOnetestnet:{
         url: API_URL_arbitrum,
         accounts: [`0x${PRIVATE_KEY_arbitrum}`]
      },
      arbitrumOne:{
         url: API_URL_arbitrum_mainnet,
         accounts: [`0x${PRIVATE_KEY_arbitrum_mainnet}`]
      }
   },
   etherscan: {
      apiKey: {
         arbitrumOne: "EZ5ZV46AF3BZCNEGH8S989K8GU4AGYS38E", // Your Arbiscan API key for Arbitrum Sepolia
      },
    },
}