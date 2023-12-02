pragma solidity ^0.8.0;

// Inheritance
import "./Owned.sol";

// https://docs.synthetix.io/contracts/source/contracts/rewardsdistributionrecipient
abstract contract RewardsDistributionRecipient is Owned {
    address public rewardsDistribution;

    constructor() {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    function notifyRewardAmount(uint256 reward) virtual external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}
