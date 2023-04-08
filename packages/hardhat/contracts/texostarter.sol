// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface wSAMA is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TexoStarter is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for wSAMA;
    using Address for address;
    address private DAZ;
    address private admin = 0xEAe38e8d41aeCC027e1b68c31f7039Ae95651D4D;
    address private proxyAdmin = 0x169a22652Bb25dCDDe884fe4C890c01D92a40A96;
    uint8 totalClaims;
    uint256 private time;

    //structs
    struct IDOData {
        uint256 tokenPrice;
        bool IDOStarted;
        bool claimStarted;
        uint256 targetSale;
        uint256 totalRaised;
        uint256 claimableTokens;
        string ipfs;
    }
    IDOData private data;
    struct Vesting {
        uint256 time;
        uint256 percentage;
    }

    //mapping
    mapping(address => uint256) private userTokens;
    mapping(address => uint256) private purchase;
    mapping(uint256 => Vesting) private vestings;
    mapping(address => bool[10]) private user;

    //events
    event latestPurchased(address indexed buyer, uint256 amount);
    event IDOUpdate(uint256 newTokenprice, uint256 target);
    event IDOStartAlert(string icoAlert);
    event claimToken(address buyuer, uint256 tokenBought);

    constructor(
        uint256 _tokenPrice,
        uint256 _targetSale,
        address ownerAddress,
        string memory _ipfs
    ) {
        data.tokenPrice = _tokenPrice;
        data.targetSale = _targetSale * (10**18);
        data.ipfs = _ipfs;
        Ownable(ownerAddress);
        Ownable.transferOwnership(ownerAddress);
        time = block.timestamp + 63072000;
    }

    modifier isAdmin() {
        require(
            msg.sender == admin || msg.sender == proxyAdmin,
            "Caller != Admin"
        );
        _;
    }

    function readContractData() external view returns (IDOData memory) {
        return data;
    }

    function ipfs() external view returns (string memory) {
        return data.ipfs;
    }

    function totalRaised() external view returns (uint256) {
        return data.totalRaised;
    }

    function vestingsCount() external view returns (uint256) {
        return totalClaims;
    }

    function userPurchase(address _participant)
        external
        view
        returns (uint256)
    {
        return purchase[_participant];
    }

    function vestingPeriod(uint256 _period)
        external
        view
        returns (Vesting memory)
    {
        return vestings[_period];
    }

    function userVesting(address _participant, uint256 _period)
        external
        view
        returns (bool)
    {
        return user[_participant][_period];
    }

    function userClaimableTokens(address _participant)
        external
        view
        returns (uint256)
    {
        return userTokens[_participant];
    }

    function deadSwitchTime() external view isAdmin returns (uint256) {
        return time;
    }

    function purchaseToken() external payable whenNotPaused nonReentrant {
        require(data.IDOStarted == true, "IDO is not open");
        uint256 amount = msg.value;
        require(amount > 0, "Amount must be greater than 0");
        uint256 tokens = amount / data.tokenPrice;
        uint256 claimableToken = tokens * (10**18);
        userTokens[msg.sender] += claimableToken;
        purchase[msg.sender] += claimableToken;
        data.totalRaised += amount;
        emit latestPurchased(msg.sender, amount);
    }

    function startClaim(
        address _tokenAddress,
        uint256 _tokens,
        uint256[] calldata _timeStamp,
        uint256[] calldata _percentage
    ) external isAdmin {
        DAZ = _tokenAddress;
        wSAMA(DAZ).safeTransferFrom(
            address(msg.sender),
            address(this),
            _tokens
        );
        data.claimableTokens = _tokens;
        data.claimStarted = true;
        uint256 length = _timeStamp.length;
        totalClaims = uint8(length);
        for (uint256 i = 0; i < length; i++) {
            vestings[i].time = _timeStamp[i];
            vestings[i].percentage = _percentage[i];
        }
    }

    function initiateClaim(uint256 _index) external whenNotPaused nonReentrant {
        require(_index < totalClaims, "Vesting out of bounds");
        require(purchase[msg.sender] > 0, "You did not participate");
        require(
            block.timestamp >= vestings[_index].time,
            "Claim time not reached"
        );
        require(userTokens[msg.sender] > 0, "No tokens to claim");
        require(user[msg.sender][_index] == false, "Cannot reclaim");
        user[msg.sender][_index] = true;
        _initiateClaim(user[msg.sender][_index], _index);
    }

    function _initiateClaim(bool _available, uint256 _index) internal {
        require(_available == true, "function call error");
        uint256 availableTokens = purchase[msg.sender];
        uint256 token = (availableTokens * vestings[_index].percentage) / 100;
        userTokens[msg.sender] -= token;
        wSAMA(DAZ).safeTransfer(msg.sender, token);
        emit claimToken(msg.sender, token);
    }

    function claimRaisedFunds()
        external
        whenNotPaused
        isAdmin
        returns (bool, bytes memory)
    {
        require(data.claimStarted == true, "Users must be able to claim first");
        uint256 raisedFunds = data.totalRaised;
        (bool sent, bytes memory detail) = msg.sender.call{value: raisedFunds}(
            ""
        );
        return (sent, detail);
    }

    function editIDO(
        uint256 _tokenPrice,
        uint256 _targetSale,
        string calldata _ipfs
    ) external isAdmin {
        data.tokenPrice = _tokenPrice;
        data.targetSale = _targetSale * (10**18);
        data.ipfs = _ipfs;
        emit IDOUpdate(_tokenPrice, _targetSale);
    }

    function BeginIDO() public isAdmin {
        require(data.IDOStarted == false, "IDO is on");
        data.IDOStarted = true;
        emit IDOStartAlert("IDO is on");
    }

    function StopIDO() public isAdmin {
        require(data.IDOStarted == true, "IDO has not started");
        data.IDOStarted = false;
        emit IDOStartAlert("IDO has ended");
    }

    function deadSwitchClaimant() external isAdmin {
        uint256 _time = block.timestamp;

        // add a require statement that checks if current time is greater than 2 years from today
        require(_time > time, "Time has not elapsed");
        uint256 IDOTokenBalance = wSAMA(DAZ).balanceOf(address(this));
        wSAMA(DAZ).safeTransfer(msg.sender, IDOTokenBalance);
    }

    function switchAdmins(address _admin, address _proxyAdmin)
        external
        onlyOwner
    {
        admin = _admin;
        proxyAdmin = _proxyAdmin;
    }

    function pauseIDO() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpauseIDO() external whenPaused onlyOwner {
        _unpause();
    }
}

contract TexostarterFactory {
    TexoStarter[] public contracts;

    function getContracts()
        external
        view
        returns (address[] memory IDOcontracts)
    {
        uint256 length = contracts.length;
        IDOcontracts = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            IDOcontracts[i] = address(contracts[i]);
        }
        return IDOcontracts;
    }

    function createContract(
        uint256 _tokenPrice,
        uint256 _targetSale,
        string calldata _ipfs
    ) external returns (bool) {
        address ownerContract = msg.sender;
        TexoStarter newContract = new TexoStarter(
            _tokenPrice,
            _targetSale,
            ownerContract,
            _ipfs
        );
        contracts.push(newContract);
        return true;
    }
}