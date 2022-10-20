// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  // payable address can receive Ether
  address payable public owner;
  
  address stakerAddress = address(this);
  uint stakerBalance = address(this).balance;

  uint public deadLine = block.timestamp + 30 seconds;  

  bool openForWithdraw = false;

  uint256 public totalStaked;
  
  uint public constant threshold = 1 ether;

  mapping(address => uint256) public balances;

  event Stake(address indexed sender, uint256 amount);

  event Log(string debugMessage);
  
  constructor (address exampleExtetrnalContractAddress) payable {
      exampleExternalContract = ExampleExternalContract(exampleExtetrnalContractAddress);

      owner = payable(msg.sender);

  }

function execute() public {

      

  // After some `deadline` allow anyone to call an `execute()` function

   // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // staking period
  address myAddress = address(this);

  if (timeLeft() > deadLine && myAddress.balance < threshold ) {

     stake();

  }

  // success state
  if (timeLeft() < deadLine && myAddress.balance > threshold ) {

    exampleExternalContract.complete{value: address(this).balance}();

  }

  // withdraw state
  if (timeLeft() < deadLine && myAddress.balance < threshold ) {

    openForWithdraw = true;

  }

}

 
function stake() public payable {

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  (bool success,) = owner.call{value: msg.value}("");
  require(success, "Failed to collect money");

  console.log(
        "stake:: amount received for Staker contract Address: %s from Sender %s for the value: %s ether",
        stakerAddress,
        msg.sender,
        msg.value
    );
  
  // collect funds 
  balances[msg.sender] += msg.value;

  console.log(
        "stake::balances  %s ether",
        balances[msg.sender]
    );

  
  // total staked
  totalStaked += balances[msg.sender];

  stakerBalance += msg.value;

  console.log(
        "stake::Staker address balance is  %s ether",
        stakerBalance
    );

//payable(address(this)).balance = payable(msg.value);
  console.log(
        "stake::contract balance ::address  %s and %s ether",
        address(this),
        balance()
    );


  emit Stake(msg.sender, balances[msg.sender]);
  

}



function withdraw() public  {

  if (openForWithdraw) {
  
    // Add a `withdraw()` function to let users withdraw their balance
    uint256 staked = balances[msg.sender];


    if (totalStaked >= staked )
      totalStaked -=balances[msg.sender];

      balances[msg.sender] = 0;
      //require(totalStaked >= balance, "Underflow");

 
   payable(msg.sender).transfer(address(this).balance);
    //payable(address(this)).transfer(payable(msg.value));
    // payable(msg.sender).transfer(staked);
    //uint amount = balances[msg.sender];
    // payable(msg.sender).transfer(amount);
    //require(success, "Failed to send Ether");

    /* address payable _to = payable(msg.sender);
    (bool success, ) = _to.call{value: staked}("");
    require(success, "My Failed to send Ether");
 */
  } else {
      emit Log("Not open for withdraw");
  }

}



// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
function timeLeft() public view returns (uint) {

  if (block.timestamp >= deadLine) 
    return 0;

  uint timeleft = deadLine - block.timestamp;

  return timeleft;

}
 


 // Add the `receive()` special function that receives eth and calls stake()
receive() external payable {

  stake();

}

fallback() external payable {}

function balance() view public returns (uint256) {
  return payable(address(this)).balance;
}

}
