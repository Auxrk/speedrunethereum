pragma solidity 0.8.20;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    // События
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    // Покупка токенов
    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 amountToBuy = msg.value * tokensPerEth;

        require(yourToken.balanceOf(address(this)) >= amountToBuy, "ERC20InsufficientBalance");
        yourToken.transfer(msg.sender, amountToBuy);

        emit BuyTokens(msg.sender, msg.value, amountToBuy);
    }

    // Продажа токенов
    function sellTokens(uint256 amount) external {
        require(amount > 0, "Specify token amount to sell");

        uint256 ethAmount = amount / tokensPerEth;
        require(address(this).balance >= ethAmount, "Vendor has insufficient ETH");

        // Перевод токенов с пользователя на контракт
        bool sent = yourToken.transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");

        // Отправка ETH пользователю
        payable(msg.sender).transfer(ethAmount);

        emit SellTokens(msg.sender, amount, ethAmount);
    }

    // Вывод ETH владельцем
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner()).transfer(balance);
    }
}
