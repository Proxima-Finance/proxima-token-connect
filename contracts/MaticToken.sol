pragma solidity 0.5.2;

import {
    ERC20Pausable
} from "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import {
    ERC20Detailed
} from "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import {
Ownable
} from "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract ProximaToken is ERC20Pausable, ERC20Detailed, Ownable {
    string _name = "ProximaToken";
    string _symbol = "PXA";
    uint8 _decimals = 18;
    uint256 _totalSupply = 100000000 * (10**18); //100M tokens with 18 decimal precision

    uint256 private rewardAlloc;
    uint256 private airDropAlloc;
    uint256 private teamTokenAlloc;
    uint256 private communityDevAlloc;

    uint256 private constant rewardAllocPercent = 77;
    uint256 private constant airDropAllocPercent = 5;
    uint256 private constant teamTokenAllocPercent = 8;
    uint256 private constant communityDevAllocPercent = 10;
    uint256 private constant divConst = 100;

    address private rewardFundVault;
    address private airDropFundVault;
    address private teamTokenFundVault;
    address private communityDevFundVault; //owner has access to this fund, will be used for project communityDev & maintainance

    bool _onlyOnceSetVault = true;
    bool _onlyOnceDistributeToVault = true;
    bool _callAfterSet = false;

    modifier oneTimeDistribution() {
        require(
            _onlyOnceDistributeToVault == true,
            "distributeFundsToVaults can be called only once"
        );
        _;
    }

    modifier oneTimeSet() {
        require(_onlyOnceSetVault == true, "SetVault can be called only once");
        _;
    }

    modifier callAfterSet() {
        require(
            _callAfterSet == true,
            "distributeFundsToVaults can be called only after setting addresses"
        );
        _;
    }

    constructor() public ERC20Detailed(_name, _symbol, _decimals) {
        _mint(msg.sender, _totalSupply);
    }

    function setVaultAddresses(
        address _rewardFundVault,
        address _airDropFundVault,
        address _teamTokenFundVault,
        address _communityDevFundVault
    ) public oneTimeSet onlyOwner {
        rewardFundVault = _rewardFundVault;
        airDropFundVault = _airDropFundVault;
        teamTokenFundVault = _teamTokenFundVault;
        communityDevFundVault = _communityDevFundVault;
        _onlyOnceSetVault = false;
        _callAfterSet = true;
    }

    function distributeFundsToVaults()
        public
        oneTimeDistribution
        onlyOwner
        callAfterSet
    {
        rewardAlloc = calculateTokenShare(rewardAllocPercent);
        airDropAlloc = calculateTokenShare(airDropAllocPercent);
        teamTokenAlloc = calculateTokenShare(teamTokenAllocPercent);
        communityDevAlloc = calculateTokenShare(communityDevAllocPercent);

        require(
            transfer(rewardFundVault, rewardAlloc),
            "Err: token allocation reverted"
        );
        require(
            transfer(airDropFundVault, airDropAlloc),
            "Err: token allocation reverted"
        );
        require(
            transfer(teamTokenFundVault, teamTokenAlloc),
            "Err: token allocation reverted"
        );
        require(
            transfer(communityDevFundVault, communityDevAlloc),
            "Err: token allocation reverted"
        );

        _onlyOnceDistributeToVault = false;
        _callAfterSet = false;
    }

    function calculateTokenShare(uint256 _percentShare)
        internal
        view
        returns (uint256)
    {
        return ((_totalSupply.mul(_percentShare)).div(divConst));
    }

    function getVaultAddresses()
        public
        view
        returns (
            address rewardVaultAddress,
            address airdropVaultAddress,
            address teamVaultAddress,
            address communityDevVaultAddress
        )
    {
        return (
            rewardFundVault,
            airDropFundVault,
            teamTokenFundVault,
            communityDevFundVault
        );
    }

    function getOriginalAllocationOfVaults()
        public
        view
        returns (
            uint256 rewardFundAllocation,
            uint256 airdropFundAllocation,
            uint256 teamFundAllocation,
            uint256 communityDevFundAllocation
        )
    {
        return (rewardAlloc, airDropAlloc, teamTokenAlloc, communityDevAlloc);
    }

    function getCurrentHoldingOfVaults()
        public
        view
        returns (
            uint256 rewardFundHoldings,
            uint256 airdropFundHoldings,
            uint256 teamFundHoldings,
            uint256 communityDevFundHoldings
        )
    {
        return (
            balanceOf(rewardFundVault),
            balanceOf(airDropFundVault),
            balanceOf(teamTokenFundVault),
            balanceOf(communityDevFundVault)
        );
    }
}
