/**
 *Submitted for verification at BSCScan.com on 2021-06-27
 *
 *   Crypto Mint Cloud is a cross-chain investment ecosystem starting on the Ethereum BlockChain. Safe, legit, and profitable for everyone!
 *   The only official platform of the original Crypto Mint Cloud team! All other platforms with the same contract code are FAKE!
 *
 *   ┌────────────────────────────────────────────────────────────────┐
 *   │   Website: https://yieldgive.com                               │
 *   │                                                                │
 *   │   Telegram Live Support: @yieldgivers-support                  │
 *   │   Telegram Public Group: @yieldgivers                          │
 *   │                                                                │
 *   │   E-mail: support@yieldgive.com                                │
 *   └────────────────────────────────────────────────────────────────┘
 *
 *   [USAGE INSTRUCTION] *
 *   1) Connect Metamask browser extension, or mobile wallet apps like MetaMask
 *   2) Choose one of the investment plans, enter the USDC amount (100 USDC Matic minimum) using the "Stake" button
 *   3) Watch your earnings grow
 *   4) Reinvest and withdraw your earnings using the "Withdraw" or "Reinvest" buttons in your desired proportion
 *
 *   [INVESTMENT CONDITIONS] 🚀
 *   1) Minimum deposit: 100 BUSD, Maximum deposit: 100,000 USDC. Ther is no withdrawal limit.
 *   2) Total income is based on the performance of your plan (from .01% to 3.33% daily).
 *   3) ~Remove the Hold Bonus~
 *   4) Earnings every moment, withdraw any time for Plan #1.
 *   5) Earnings every moment, withdraw funds after the plan ends for Plans #2 - #4.
 *
 *   [AFFILIATE PROGRAM]  🚀
 *   3-level referral commission: Direct Commissions: 3% - 2nd Level: 2% - 3rd Level: 1%
 *
 *   [FUNDS DISTRIBUTION] *
 *   - 60% Main Platform Balance, participants payouts
 *   - 20% The Insurance Pool, the protections for withdrawals, where quarterly bonuses are paid from
 *   - 7% Advertising and promotion expenses
 *   - 7% Support, development, and administration
 *   - 6% Affiliate program bonuses
 *
 *     SPDX-License-Identifier: MIT
 */

pragma solidity >=0.7.6 <0.9.0;
import "hardhat/console.sol";

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract YieldGivers {
    using SafeMath for uint256;
    address public tokenAddress;
    uint public startTime;
    uint public total;
    uint public pool;
    uint public rankPool;
    uint public insurancePool;
    uint public insuranceTime;
    uint public rankTime;
    uint public maxInvestAmount;
    uint public minInvestAmount;
    uint public percentMultiplier;
    uint public planOneDays;
    uint public planTwoDays;
    uint public planThreeDays;
    uint public planFourDays;
    uint public planOneMultiplier;
    uint public planTwoMultiplier;
    uint public planThreeMultiplier;
    uint public planFourMultiplier;
    address payable public dev;
    address payable public ad;
    address payable public team;
    //address payable public owner = msg.sender;
    address public owner = msg.sender;
    uint dayTime = 1 days;
    uint increaseTime = 5 hours;
    uint initialTime = dayTime.mul(7);
    uint unit = 18;
    // uint[] pcts = [5,2,1];
    uint[] pcts = [3, 2, 1]; //second point done

    struct User {
        bool active;
        address referrer;
        uint recommendReward;
        uint investment;
        uint totalWithdraw;
        uint totalReward;
        uint checkpoint;
        uint subNum;
        uint subStake;
        address[] subordinates;
        Investment[] investments;
    }
    struct Investment {
        uint start;
        uint finish;
        uint value;
        uint totalReward;
        uint period;
        uint rate;
        //uint256 rate;
        uint typeNum;
        bool isReStake;
    }
    struct Invest {
        address addr;
        uint value;
        uint reward;
        uint time;
    }

    struct PoolMinMax {
        uint minInvestAmountPool;
        uint maxInvestAmountPool;
    }

    mapping(uint => uint256) public totalInvestmentByPool;
    mapping(uint => PoolMinMax) public pools;
    Invest[] public insurances;
    uint public insuranceIndex;
    uint public insuranceRewardIndex;

    uint[] rankPcts = [40, 30, 20, 10];
    mapping(uint => Invest[4]) rankMapArray;
    mapping(uint => mapping(address => uint)) public rankMap;
    mapping(uint => bool) public rankFlag;
    mapping(address => User) public userMap;

    event Stake(address indexed user, uint256 amount);
    event Retake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event WithdrawPrincipal(address indexed user, uint256 amount);
    event Insurance(address indexed user, uint256 amount);
    event Rank(address indexed user, uint256 amount);

    constructor(
        address _tokenAddress,
        address payable dev_,
        address payable ad_,
        address payable team_,
        uint256 startTime_,
        uint256 rankTime_
    ) {
        require(!isContract(dev_), "!devAddress");
        require(!isContract(ad_), "!adAddress");
        require(!isContract(team_), "!teamAddress");
        tokenAddress = _tokenAddress;
        dev = dev_;
        ad = ad_;
        team = team_;
        userMap[team].active = true;
        if (startTime_ == 0) startTime_ = block.timestamp;
        if (rankTime_ == 0) rankTime_ = block.timestamp;
        startTime = startTime_;
        rankTime = rankTime_;
    }

    function transfer(address recipient, uint amount) internal returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        return token.transfer(recipient, amount);
    }

    // Internal function to transfer ERC20 tokens from another address
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) internal returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        return token.transferFrom(sender, recipient, amount);
    }

    // Function to get the balance of this contract's ERC20 token
    function getTokenBalance() public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function getRankIndex() public view returns (uint index) {
        (, uint time) = block.timestamp.trySub(rankTime);
        index = time.div(dayTime);
        console.log("rank index in get rank index----------", index);
    }

    function getRatio() internal view returns (uint256) {
        uint256 ratio = pool / total;
        console.log("ratio in get ratio-------", ratio);
        return ratio;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getInfo()
        public
        view
        returns (uint, uint, uint, uint, uint, uint, uint)
    {
        return (
            startTime,
            total,
            pool,
            rankPool,
            insurancePool,
            insuranceTime,
            rankTime
        );
    }

    function getRanks(
        uint index
    )
        public
        view
        returns (
            address[4] memory addresses,
            uint[4] memory values,
            uint[4] memory rewards,
            uint[4] memory times
        )
    {
        Invest[4] memory invests = rankMapArray[index];
        for (uint i = 0; i < invests.length; i++) {
            addresses[i] = invests[i].addr;
            values[i] = invests[i].value;
            rewards[i] = invests[i].reward;
            times[i] = invests[i].time;
        }
    }

    function getInsurances(
        uint length
    )
        public
        view
        returns (
            address[] memory addresses,
            uint[] memory values,
            uint[] memory rewards,
            uint[] memory times
        )
    {
        uint index = 0;
        (, uint end) = insuranceIndex.trySub(length);
        length = insuranceIndex.sub(end);
        addresses = new address[](length);
        values = new uint[](length);
        rewards = new uint[](length);
        times = new uint[](length);
        for (uint i = insuranceIndex; i > end; i--) {
            addresses[index] = insurances[i - 1].addr;
            values[index] = insurances[i - 1].value;
            times[index] = insurances[i - 1].time;
            rewards[index] = insurances[i - 1].reward;
            index++;
        }
    }

    function getInvestments()
        public
        view
        returns (
            uint[] memory times,
            uint[] memory starts,
            uint[] memory values,
            uint[] memory totalRewards,
            uint[] memory rates,
            uint[] memory typeNums,
            bool[] memory isReStakes
        )
    {
        Investment[] memory investments = userMap[msg.sender].investments;
        times = new uint[](investments.length);
        starts = new uint[](investments.length);
        values = new uint[](investments.length);
        totalRewards = new uint[](investments.length);
        rates = new uint[](investments.length);
        typeNums = new uint[](investments.length);
        isReStakes = new bool[](investments.length);
        for (uint i = 0; i < investments.length; i++) {
            times[i] = investments[i].finish;
            starts[i] = investments[i].start;
            values[i] = investments[i].value;
            totalRewards[i] = investments[i].totalReward;
            rates[i] = investments[i].rate;
            typeNums[i] = investments[i].typeNum;
            isReStakes[i] = investments[i].isReStake;
        }
    }

    function getInvestmentsEx() public view returns (uint[] memory periods) {
        Investment[] memory investments = userMap[msg.sender].investments;
        periods = new uint[](investments.length);
        for (uint i = 0; i < investments.length; i++) {
            periods[i] = investments[i].period;
        }
    }

    function calcReward(
        uint income,
        uint rate,
        uint period
    ) public pure returns (uint reward) {
        reward = income.mul(rate).mul(period).div(1000);
        console.log("rewad in simple interest------", reward);
    }

    function calcRewardCompound(
        uint income,
        uint rate,
        uint period
    ) public pure returns (uint reward) {
        reward = income;
        console.log("income inside calculate function------", income);
        for (uint i = 0; i < 18; i++) {
            if (period > i) reward = reward.mul(rate).div(1000).add(reward);
            else reward = reward.mul(0).div(1000).add(reward);
        }
        reward = reward.sub(income);
        console.log("reward inside compound calculate function ------", reward);
    }

    function getPeriodAndRate(
        uint typeNum,
        uint income
    ) public view returns (uint256 period, uint rate, uint totalReward) {
        if (typeNum == 1) {
            period = planOneDays; /* 140 days & 1% ~ 2% Daily = 350.6% ~ 1,394.4% COMPOUND ROI recomended */
            console.log("1 period inside getperiodrate==========", period);
            rate = getIncreasePct(); //.add(planOneRate);
            console.log("1 rate inside getperiodrate============", rate);
            totalReward = calcRewardCompound(income, rate, period);
            console.log(
                "1 totalReward  inside getperiodrate--------",
                totalReward
            );
        } else if (typeNum == 2) {
            period = planTwoDays; // 100 days @ 1.3% ~ 2.3% Daily = 363.87% ~ 971.77% COMPOUND ROI recomended
            console.log("2 period inside getperiodrate==========", period);
            rate = getRatio().mul(10); //.add(getIncreasePct()).add(planTwoRate);
            console.log("2 rate inside getperiodrate============", rate);
            totalReward = calcRewardCompound(income, rate, period);
            console.log(
                "2 totalReward  inside getperiodrate--------",
                totalReward
            );
        } else if (typeNum == 3) {
            period = planThreeDays; // 150 days & 1.7% ~ 2.7 Daily = 255% ~ 405% SIMPLE ROI recomended
            console.log("3 period inside getperiodrate==========", period);
            rate = getRatio().mul(10); //.add(getIncreasePct()).add(planThreeRate);
            console.log("3 rate inside getperiodrate============", rate);
            totalReward = calcReward(income, rate, period);
            console.log(
                "3 totalReward  inside getperiodrate--------",
                totalReward
            );
        } else if (typeNum == 4) {
            period = planFourDays; // 90 days & 2.5% ~ 3.5 Daily = 225% ~ 315% SIMPLE ROI recomended
            console.log("4 period inside getperiodrate==========", period);
            rate = getRatio().mul(10); //.add(getIncreasePct()).add(planThreeRate);
            console.log("4 rate inside getperiodrate============", rate);
            totalReward = calcReward(income, rate, period);
            console.log(
                "4 totalReward  inside getperiodrate--------",
                totalReward
            );
        }
    }

    function setPoolInvestmentLimits(
        uint poolId,
        uint minInvestAmountPool,
        uint maxInvestAmountPool
    ) public onlyOwner {
        pools[poolId] = PoolMinMax(
            minInvestAmountPool * 10 ** 6,
            maxInvestAmountPool * 10 ** 6
        );
    }

    function setPlanOnePeriod(uint planOnePeriod) public onlyOwner {
        planOneDays = planOnePeriod;
    }

    function setPlanTwoPeriod(uint planTwoPeriod) public onlyOwner {
        planTwoDays = planTwoPeriod;
    }

    function setPlanThreePeriod(uint planThreePeriod) public onlyOwner {
        planThreeDays = planThreePeriod;
    }

    function setPlanFourPeriod(uint planFourPeriod) public onlyOwner {
        planFourDays = planFourPeriod;
    }

    function planOneRate(uint planOnePct) public onlyOwner {
        planOneMultiplier = planOnePct;
    }

    function planTwoRate(uint planTwoPct) public onlyOwner {
        planTwoMultiplier = planTwoPct;
    }

    function planThreeRate(uint planThreePct) public onlyOwner {
        planThreeMultiplier = planThreePct;
    }

    function planFourRate(uint planFourPct) public onlyOwner {
        planFourMultiplier = planFourPct;
    }

    function setPercentMultiplier(uint increasePct) public onlyOwner {
        percentMultiplier = increasePct;
    }

    function setMinInvestAmount(uint minInvAmnt) public onlyOwner {
        minInvestAmount = minInvAmnt * 10 ** 6;
    }

    function setMaxInvestAmount(uint maxInvAmnt) public onlyOwner {
        maxInvestAmount = maxInvAmnt * 10 ** 6;
    }

    function getIncreasePct() public view returns (uint increasePct) {
        (, uint time) = block.timestamp.trySub(startTime);
        console.log("time====", time);
        console.log("increase time-----", increaseTime);
        increasePct = time.div(increaseTime);
        console.log("increase pct=====", increasePct);
    }

    function getPlanOneRate() public view returns (uint planOnePct) {
        (, uint time) = block.timestamp.trySub(startTime);
        planOnePct = time.div(increaseTime);
        console.log("planOnePct-------", planOnePct);
    }

    function getPlanTwoRate() public view returns (uint planTwoPct) {
        (, uint time) = block.timestamp.trySub(startTime);
        planTwoPct = time.div(increaseTime);
    }

    function getPlanThreeRate() public view returns (uint planThreePct) {
        (, uint time) = block.timestamp.trySub(startTime);
        planThreePct = time.div(increaseTime);
    }

    function getPlanFourRate() public view returns (uint planFourPct) {
        (, uint time) = block.timestamp.trySub(startTime);
        planFourPct = time.div(increaseTime);
    }

    function stake(address referrer, uint typeNum, uint Amount) public payable {
        require(block.timestamp >= startTime, "Not start");
        require(
            Amount >= minInvestAmount,
            "Please invest more than the minimum amount"
        );
        require(
            Amount <= maxInvestAmount,
            "Please invest less than the maximum amount"
        );

        require(
            totalInvestmentByPool[typeNum].add(Amount) <=
                pools[typeNum].maxInvestAmountPool,
            "Exceeds pool investment limit"
        );
        require(
            transferFrom(msg.sender, address(this), Amount),
            "Token transfer failed"
        );
        totalInvestmentByPool[typeNum] = totalInvestmentByPool[typeNum].add(
            Amount
        );
        bindRelationship(referrer);
        addInvestment(typeNum, Amount, false);
        emit Stake(msg.sender, Amount);
    }

    function getPoolMinMax(uint typeNum) public view returns (uint, uint) {
        return (
            pools[typeNum].minInvestAmountPool,
            pools[typeNum].maxInvestAmountPool
        );
    }

    function updateReward(uint amount) private returns (uint) {
        uint income = getAmount();
        // console.log("income in update reward------", income);
        // console.log("pool updatereward--------", pool);
        User storage user = userMap[msg.sender];
        if (amount == 0 || amount > income) amount = income;
        if (amount > pool) amount = pool;
        require(amount > 0, "Error amount");
        user.totalReward = income.sub(amount);
        user.totalWithdraw = user.totalWithdraw.add(amount);
        user.checkpoint = block.timestamp;
        pool = pool.sub(amount);
        if (
            insuranceTime == 0 &&
            block.timestamp > startTime.add(dayTime.mul(2)) &&
            pool < 10 * 10 ** unit
        ) insuranceTime = block.timestamp.add(dayTime);
        // console.log("insurance time in update reward-------", insuranceTime);
        // console.log("amount in update reward------", amount);
        return amount;
    }

    function reStake(uint typeNum, uint amount) public {
        amount = updateReward(amount);

        require(
            transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        // console.log("amount in restake--------",amount);

        addInvestment(typeNum, amount, true);
        emit Retake(msg.sender, amount);
    }

    function withdraw(uint amount) public {
        amount = updateReward(amount);
        // console.log("amount in withdraw -----------",amount);
        //  console.log("insurance time in withdraw-------",insuranceTime);
        if (insuranceTime > 0 && insuranceTime < block.timestamp) {
            require(transfer(msg.sender, amount), "Token transfer failed");
        } else {
            // insurancePool = insurancePool.add(amount.mul(10).div(100));
            insurancePool = insurancePool.add(amount.mul(20).div(100));
            console.log("insurance pool in withdraw---------", insurancePool);
            require(
                transfer(msg.sender, amount.mul(80).div(100)),
                "Token transfer failed"
            );
            console.log("msg.sender-----", msg.sender);
            console.log("msg.sender amount-------", msg.sender.balance);
            console.log("transfer amount----------", amount.mul(80).div(100));
        }
        emit Withdraw(msg.sender, amount);
    }

    // Function to withdraw the principal amount
    function withdrawPrincipal(uint investmentIndex) public {
        User storage user = userMap[msg.sender];
        require(
            investmentIndex < user.investments.length,
            "Invalid investment index"
        );
        Investment storage investment = user.investments[investmentIndex];
        require(
            block.timestamp >= investment.finish,
            "Cannot withdraw principal before the investment period ends"
        );
        uint principalAmount = investment.value ;
        require(transfer(msg.sender, principalAmount), "Token transfer failed");
        user.investment = user.investment.sub(principalAmount);
        user.totalWithdraw = user.totalWithdraw.add(principalAmount);
        user.checkpoint = block.timestamp;
        total = total.sub(principalAmount);
        // pool = pool.sub(principalAmount);
        emit WithdrawPrincipal(msg.sender, principalAmount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdrawContractbalance() public onlyOwner {
        // owner.transfer(total);
        require(transfer(owner, getTokenBalance()), "Token transfer failed");
        emit Withdraw(owner, getTokenBalance());
    }

    function getAmount() public view returns (uint amount) {
        User memory user = userMap[msg.sender];
        amount = user.totalReward;
        // console.log("amount in getamount-----",amount);
        Investment memory investment;
        for (uint i = 0; i < user.investments.length; i++) {
            investment = user.investments[i];
            console.log("i in getamount--------", i);
            if (user.checkpoint > investment.finish) continue;
            if (investment.typeNum > 2) {
                if (block.timestamp < investment.finish) continue;
                amount = amount.add(investment.totalReward);
            } else {
                uint rate = investment.totalReward.div(
                    investment.period.mul(dayTime)
                );
                uint start = investment.start.max(user.checkpoint);
                uint end = investment.finish.min(block.timestamp);
                console.log("rate in getamount------", rate);
                console.log("start in getamount------", start);
                console.log("end in getamount------", end);
                if (start < end) {
                    amount = amount.add(end.sub(start).mul(rate));
                    console.log(
                        "amount in getamount if condition-----",
                        amount
                    );
                }
            }
        }
    }

    function addInvestment(uint typeNum, uint income, bool isReStake) private {
        User storage user = userMap[msg.sender];

        uint reIncome = income;
        if (isReStake) reIncome = income.mul(102).div(100);
        (uint period, uint rate, uint totalReward) = getPeriodAndRate(
            typeNum,
            reIncome
        );
        uint finish = dayTime.mul(period).add(block.timestamp);
        // uint finish = dayTime.add(0);
        // uint finish = (block.timestamp).add(355);
        // uint finish = dayTime.mul(period).add(1708853432);
        console.log("rate addInvestment--------", rate);
        // console.log("rate income--------", income);
        // console.log("totalReward addInvestment-----------", totalReward);
        // console.log("period addInvestment----------", period);
        // console.log("finish addInvestment---------", finish);
        if (period > 0) {
            // require(
            //     transfer(dev, income.mul(7).div(100)),
            //     "Token transfer to dev failed"
            // );
            // require(
            //     transfer(ad, income.mul(7).div(100)),
            //     "Token transfer to ad failed"
            // );
            if (block.timestamp > startTime.add(initialTime)) {
                pool = pool.add(income.mul(83).div(100));
                rankPool = rankPool.add(income.mul(3).div(100));
                // console.log("if pool-----", pool);
                // console.log("if rank pool-------", rankPool);
            } else {
                pool = pool.add(income.mul(84).div(100));
                rankPool = rankPool.add(income.mul(2).div(100));
                console.log("else pool-----", pool);
                console.log("else rank pool-------", rankPool);
            }
            total = total.add(income);
            console.log("total----", total);
            user.investment = user.investment.add(income);
            address referrer = user.referrer;
            uint index = getRankIndex();
            console.log("rank index-----", index);
            for (uint i = 0; i < 3; i++) {
                if (!userMap[referrer].active) break;
                console.log("index after==========", i);
                uint reward = income.mul(pcts[i]).div(100);
                console.log("reward inside invest=====", reward);
                userMap[referrer].recommendReward = userMap[referrer]
                    .recommendReward
                    .add(reward);
                userMap[referrer].totalReward = userMap[referrer]
                    .totalReward
                    .add(reward);
                userMap[referrer].subStake = userMap[referrer].subStake.add(
                    income
                );
                if (i == 0) {
                    rankMap[index][referrer] = rankMap[index][referrer].add(
                        income
                    );
                    ranking(referrer, rankMap[index][referrer]);
                }
                referrer = userMap[referrer].referrer;
                console.log("investment referrer-----------", referrer);
            }
            user.investments.push(
                Investment({
                    start: block.timestamp,
                    finish: finish,
                    value: reIncome,
                    totalReward: totalReward,
                    period: period,
                    rate: rate,
                    typeNum: typeNum,
                    isReStake: isReStake
                })
            );
            if (insuranceTime == 0 || insuranceTime > block.timestamp) {
                insurances.push(Invest(msg.sender, income, 0, block.timestamp));
                insuranceIndex++;
                insuranceRewardIndex = insuranceIndex;
            }
        }
    }

    function ranking(address addr, uint value) private {
        uint index = getRankIndex();
        Invest storage invest;
        address tempAddr;
        uint tempValue;
        address origAddr = addr;
        for (uint i = 0; i < rankMapArray[index].length; i++) {
            invest = rankMapArray[index][i];
            if (addr == invest.addr) {
                invest.value = value;
                return;
            } else if (value > invest.value) {
                tempAddr = invest.addr;
                tempValue = invest.value;
                invest.addr = addr;
                invest.value = value;
                if (origAddr == tempAddr) return;
                addr = tempAddr;
                value = tempValue;
            }
        }
    }

    function bindRelationship(address referrer) private {
        console.log("inside bind relationship---------");
        console.log("referrer----------", referrer);
        if (userMap[msg.sender].active) return;
        userMap[msg.sender].active = true;
        if (referrer == msg.sender || !userMap[referrer].active)
            referrer = team;
        userMap[msg.sender].referrer = referrer;
        userMap[referrer].subordinates.push(msg.sender);
        for (uint i = 0; i < 3; i++) {
            userMap[referrer].subNum++;
            referrer = userMap[referrer].referrer;
            if (!userMap[referrer].active) return;
        }
    }
}
library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}