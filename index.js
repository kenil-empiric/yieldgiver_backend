const express = require("express");
const cors = require("cors");
const { config } = require("dotenv");
const isOwner = require("./Middleware/isOwner");
const ethers = require("ethers");
const stakeABI = require("./ABI/YieldGivers.json");
const Erc20Abi= require("./ABI/Erc20abi.json")
const app = express();
app.use(cors());
app.use(express.json());
config();

console.log("hello here");
console.log("etehrs", ethers);

const {
  API_URL,
  PRIVATE_KEY,
  API_URL_arbitrum,
  PRIVATE_KEY_arbitrum,
  CONTRACT_ADDRESS,
  PRIVATE_KEY2,
  PORT,
  TOKEN_ADDRESS
} = process.env;

const abi = stakeABI.abi;
const Erc20abi= Erc20Abi.abi;

console.log("API------", API_URL_arbitrum);
console.log("Private key ----", PRIVATE_KEY_arbitrum);
// console.log("Private key2 -----", PRIVATE_KEY2);
console.log("Stack contract Address------", CONTRACT_ADDRESS);
console.log("Port--------", PORT);

const provider = new ethers.providers.JsonRpcProvider(API_URL_arbitrum);
// const provider = new ethers.providers.JsonRpcProvider(API_URL); // sepolia

const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, provider);
// const signer = new ethers.Wallet(PRIVATE_KEY, provider); //sepolia
const signer = new ethers.Wallet(PRIVATE_KEY_arbitrum, provider);

const signcontract = new ethers.Contract(CONTRACT_ADDRESS, abi, signer);

app.post("/setMaxInvestAmount", isOwner, async function (req, res) {
  try {
    const { amount } = req.body;
    const maxAmount = await signcontract.setMaxInvestAmount(amount);
    await maxAmount.wait();
    res.status(200).json({
      message: "Set Maximum Amount successfully",
      transactionHash: maxAmount.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/getMaxInvestAmount", async function (req, res) {
  try {
    const maxamount = await contract.maxInvestAmount();
    console.log(maxamount.toString());
    // const maxAmountValue = maxamount.toNumber();
    // console.log(maxAmountValue);
    res.status(200).json({ maxamount: maxamount.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/setMinInvestAmount", isOwner, async function (req, res) {
  try {
    const { amount } = req.body;
    const minAmount = await signcontract.setMinInvestAmount(amount);
    await minAmount.wait();
    res.status(200).json({
      message: "Set Minimum Amount successfully",
      transactionHash: minAmount.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/getMinInvestAmount", async function (req, res) {
  try {
    const minamount = await contract.minInvestAmount();
    // const minAmountValue = minamount.toNumber();
    console.log(minamount.toString());

    res.status(200).json({ minamount: minamount.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

// set and get plan one rate
app.post("/setPlanOneRate", isOwner, async function (req, res) {
  try {
    const { rate } = req.body;
    const planOne = await signcontract.planOneRate(rate);
    await planOne.wait();
    res.status(200).json({
      message: "Set Plan One rate successfully",
      transactionHash: planOne.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planOneMultiplier", async function (req, res) {
  try {
    const planOneMul = await contract.planOneMultiplier();
    const planOneMulNumber = planOneMul.toNumber();

    res.status(200).json({ planOneMul: planOneMulNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

// set and get plan two rate
app.post("/setPlanTwoRate", isOwner, async function (req, res) {
  try {
    const { rate } = req.body;
    const planTwo = await signcontract.planTwoRate(rate);
    await planTwo.wait();
    res.status(200).json({
      message: "Set Plan Two rate successfully",
      transactionHash: planTwo.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planTwoMultiplier", async function (req, res) {
  try {
    const planTwoMul = await contract.planTwoMultiplier();
    const planTwoMulNumber = planTwoMul.toNumber();

    res.status(200).json({ planTwoMul: planTwoMulNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

// set and get plan 3 rate
app.post("/setPlanThreeRate", isOwner, async function (req, res) {
  try {
    const { rate } = req.body;
    const planThree = await signcontract.planThreeRate(rate);
    await planThree.wait();
    res.status(200).json({
      message: "Set Plan Three rate successfully",
      transactionHash: planThree.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planThreeMultiplier", async function (req, res) {
  try {
    const planThreeMul = await contract.planThreeMultiplier();
    const planThreeMulNumber = planThreeMul.toNumber();

    res.status(200).json({ planThreeMul: planThreeMulNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

// DaysApi
app.post("/setPlanOneDays", isOwner, async function (req, res) {
  try {
    const { Days } = req.body;
    const planOne = await signcontract.setPlanOnePeriod(Days);
    await planOne.wait();
    res.status(200).json({
      message: "Set Plan One for Days successfully",
      transactionHash: planOne.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planOneDays", async function (req, res) {
  try {
    const planOneDay = await contract.planOneDays();
    const planOneDayNumber = planOneDay.toNumber();
    console.log("----------planOneDayNumber", planOneDayNumber);
    res.status(200).json({ planOneDay: planOneDayNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/setPlanTwoDays", isOwner, async function (req, res) {
  try {
    const { Days } = req.body;
    const planTwo = await signcontract.setPlanTwoPeriod(Days);
    await planTwo.wait();
    res.status(200).json({
      message: "Set Plan Two for Days successfully",
      transactionHash: planTwo.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planTwoDays", async function (req, res) {
  try {
    const planTwoDay = await contract.planTwoDays();
    const planTwoDayNumber = planTwoDay.toNumber();
    res.status(200).json({ planTwoDay: planTwoDayNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/setPlanThreeDays", isOwner, async function (req, res) {
  try {
    const { Days } = req.body;
    const planThree = await signcontract.setPlanThreePeriod(Days);
    await planThree.wait();
    res.status(200).json({
      message: "Set Plan Three for Days successfully",
      transactionHash: planThree.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/planThreeDays", async function (req, res) {
  try {
    const planTwoDay = await contract.planThreeDays();
    const planTwoDayNumber = planTwoDay.toNumber();
    res.status(200).json({ planThreeDay: planTwoDayNumber });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/stake", async function (req, res) {
  try {
    const { reffer_add, plan_number, stake_amount } = req.body;
    if (reffer_add && plan_number && stake_amount) {
      const options = { value: ethers.utils.parseEther("1.0") };

      const Stake = await signcontract.stake(reffer_add, plan_number, options);
      await Stake.wait();
      res.status(200).json({
        message: "Amount has been staked",
        transactionHash: Stake.hash,
      });
    } else {
      res.status(500).json({ message: "All fileds are require" });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.post("/setTotalInvestAmount", isOwner, async function (req, res) {
  try {
    const { plan_num, amount } = req.body;
    console.log("data", plan_num, amount);
    const totalAmount = await signcontract.setPoolInvestmentLimits(
      plan_num,
      0,
      amount
    );
    await totalAmount.wait();
    res.status(200).json({
      message: "Set Total Investment Amount successfully",
      transactionHash: totalAmount.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error });
  }
});

app.get("/getTotalInvesment/pool/:id", async function (req, res) {
  try {
    const { id } = req.params;
    const planOneAmount = await contract.getPoolMinMax(id);
    console.log(planOneAmount[1]);
    console.log(
      "planOneAmount.................",
      Number(planOneAmount[1].toString()) / 10 ** 6
    );
    res.status(200).json({ planTwoMul:  Number(planOneAmount[1].toString()) / 10 ** 6 });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.get("/getTotalContractBalance", async function (req, res) {
  try {
    const planOneAmount = await contract.getTokenBalance();
    console.log(planOneAmount.toNumber());
    console.log("planOneAmount.................", planOneAmount / 10 ** 6);
    res
      .status(200)
      .json({ contractbalance: planOneAmount.toNumber() / 10 ** 6 });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.get("/WithdrawContractBalance", isOwner, async function (req, res) {
  try {
    const planOneAmount = await signcontract.withdrawContractbalance();
    res.status(200).json({
      message: "Contract Balance Withdraw successfully",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/getallinfo", async function (req, res) {
  try {
    const { number } = req.body;
    console.log("number",number);
    const Allinfo = await contract.getPoolAllInfo(number);
    console.log(Allinfo);
    res.status(200).json({
      message: "Success",
      Allinfo:Allinfo,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/Withdrawearning", async function (req, res) {
  try {
    const { number } = req.body;
    console.log("number",number);
    const Allinfo = await contract.withdraw(number);
    console.log(Allinfo);
    res.status(200).json({
      message: "Success",
      Allinfo: Allinfo,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.post("/SetCooldownPeriod", async function (req, res) {
  try {
    const { durationInMinutes } = req.body; // Assuming the duration is provided in minutes
    console.log("Setting cooldown period with duration:", durationInMinutes);
 
    // Call the smart contract method to set cooldown period
    const tx = await signcontract.setCoolDownPeriod(durationInMinutes);

    console.log("Transaction hash:", tx.transactionHash);

    res.status(200).json({
      message: "Cooldown period set successfully",
      transactionHash: tx.transactionHash,
    });
  } catch (error) {
    console.error("Error setting cooldown period:", error);
    res.status(500).json({ message: "Failed to set cooldown period", error: error.message });
  }
});

app.post("/SetMaxInvestmentLimit", async function (req, res) {
  try {
    const { maxInvestmentLimit } = req.body; // Assuming max investment limit is provided in request body
    console.log("Setting max investment limit:", maxInvestmentLimit);

    // Call the smart contract method to set max investment limit
    const tx = await signcontract.setMaxInvestmentLimit(maxInvestmentLimit);

    // Wait for the transaction to be mined
    await tx.wait();

    console.log("Transaction hash:", tx.hash);

    res.status(200).json({
      message: "Max investment limit set successfully",
      transactionHash: tx.hash,
    });
  } catch (error) {
    console.error("Error setting max investment limit:", error);
    res.status(500).json({ message: "Failed to set max investment limit", error: error.message });
  }
});


app.post("/admindeposittoken", async function (req, res) {
  try {
    const { amount } = req.body;
    console.log(amount);
    // Load token contract ABI
    const tokenContract = new ethers.Contract(TOKEN_ADDRESS, Erc20abi, signer);
    console.log(tokenContract);
    // Approve spending tokens
    const approveTx = await tokenContract.approve(TOKEN_ADDRESS, amount);
    await approveTx.wait();

    // Send tokens
    const tx = await tokenContract.transfer(CONTRACT_ADDRESS, amount);
    await tx.wait();

    res.status(200).json({
      message: "Token deposit successful",
      transactionHash: tx.hash,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message });
  }
});

app.get("/totalinvstor", async function (req, res) {
  try {
    const Totalinv = await contract.userCount();
    console.log(Totalinv.toNumber());
    res.status(200).json({
      message: "successful",
      Totalinvstor:Totalinv.toNumber()
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});

app.get("/totalinvestamount", async function (req, res) {
  try {
    const TotalinvAmount = await contract.totalStakedAmount();
    console.log(TotalinvAmount.toNumber());
    console.log("planOneAmount.................", TotalinvAmount / 10 ** 6);
    res.status(200).json({
      message: "successful",
      TotalinvstorAmount:TotalinvAmount.toNumber()/ 10 ** 6
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mesasage: error });
  }
});



app.listen(PORT);
