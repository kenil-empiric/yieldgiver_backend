/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
const { API_URL, PRIVATE_KEY,API_URL_arbitrum ,PRIVATE_KEY_arbitrum} = process.env;
module.exports = {
   solidity: "0.7.6",
   defaultNetwork: "sepolia",
   networks: {
      hardhat: {},
      sepolia: {
         url: API_URL,
         accounts: [`0x${PRIVATE_KEY}`]
      },
      arbitrum:{
         url: API_URL_arbitrum,
         accounts: [`0x${PRIVATE_KEY_arbitrum}`]
      }
   },
}