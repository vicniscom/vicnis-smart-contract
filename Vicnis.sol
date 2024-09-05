// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Vicnis is ERC20, Ownable, ReentrancyGuard {
    address public constant RECEIVER = 0xDB15F9d1dFACA6C14E31AD59E714b41c3f137abc;
    mapping(address => bool) private _blacklist;

    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);

    constructor() ERC20("Vicnis", "VNT") Ownable(msg.sender) {
        _mint(RECEIVER, 300000000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function addBlacklist(address account) external onlyOwner {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    function removeBlacklist(address account) external onlyOwner {
        _blacklist[account] = false;
        emit Unblacklisted(account);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function _checkTransferConditions(address from, address to) private view {
        require(!isBlacklisted(from), "Vicnis: sender is blacklisted");
        require(!isBlacklisted(to), "Vicnis: recipient is blacklisted");
    }

    function transfer(
        address recipient,
        uint256 value
    ) public override nonReentrant returns (bool) {
        _checkTransferConditions(msg.sender, recipient);

        uint256 senderBalance = balanceOf(msg.sender);
        require(
            senderBalance >= value,
            "Vicnis: transfer amount exceeds balance"
        );

        return super.transfer(recipient, value);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 value
    ) public override nonReentrant returns (bool) {
        _checkTransferConditions(sender, recipient);

        uint256 senderBalance = balanceOf(sender);
        require(
            senderBalance >= value,
            "Vicnis: transfer amount exceeds balance"
        );

        uint256 currentAllowance = allowance(sender, msg.sender);
        require(
            currentAllowance >= value,
            "Vicnis: transfer amount exceeds allowance"
        );

        super.transferFrom(sender, recipient, value);

        _approve(sender, msg.sender, currentAllowance - value);

        return true;
    }
}