// scripts/deploy.js
require("dotenv").config();
const { DEV_ADDRESS, AD_ADDRESS, TEAM_ADDRESS,TOKEN_ADDRESS } = process.env;
console.log("Dev Address------", DEV_ADDRESS);
console.log("Ad Address-----", AD_ADDRESS);
console.log("Team Address------", TEAM_ADDRESS);
console.log("TOKEN_ADDRESS------", TOKEN_ADDRESS);

async function main() {
  const YieldGivers = await ethers.getContractFactory("YieldGivers");

  // Set the start time and rank time (you can customize these values)
  const startTime = Math.floor(new Date().getTime() / 1000);
  const rankTime = Math.floor(new Date().getTime() / 1000);

  const yieldgivers = await YieldGivers.deploy(
    TOKEN_ADDRESS,
    DEV_ADDRESS,
    AD_ADDRESS,
    TEAM_ADDRESS,
    startTime,
    rankTime
  );
  await yieldgivers.deployed();
  console.log("YieldGivers deployed to:", yieldgivers.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// YieldGivers deployed to: 0x160753052298C0B88f7447cfEE7858A9db0DBfF3
