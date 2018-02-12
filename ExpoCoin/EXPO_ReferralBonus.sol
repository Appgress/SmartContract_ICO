pragma solidity ^0.4.16;

interface token {
    function  transfer(address receiver, uint256 amount) public;

}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract referralBonus is Ownable{
    
    token public tokenReward;
    uint256 public amountReferralToken; 

    event get_Token(address changer, uint256 amount_token, uint256 date);
    event sentReferralBonus(address to, uint256 amount_token, uint256 date,bool sucs);
    event changeAddressToken(address changer,address to, uint256 date);
    event changeAmountBonusToken(address changer,uint256 from ,uint256 to, uint256 date);
    event sentEth(address from, address to, uint256 amount);

    function referralBonus(
	address addressOfTokenUsedAsReward
    ) public {
		tokenReward = token(addressOfTokenUsedAsReward);
		amountReferralToken = 0;
    }
    
    function changeTokenAddress(address new_address) public onlyOwner{
    	changeAddressToken(msg.sender, new_address, now);
    	tokenReward = token(new_address);
    }

    function changeAmountBonus(uint256 new_value) public onlyOwner{
    	changeAmountBonusToken(msg.sender, amountReferralToken, new_value, now);
    	amountReferralToken = new_value;
    }

    function kill() public onlyOwner{
    	selfdestruct(owner);
    }


    function getTokenFromContract(address to, uint256 amount) public onlyOwner{
        tokenReward.transfer(to, amount);
        get_Token(msg.sender, amount, now);
    }

    function getEthFromContract(address _to, uint256 _amount) public onlyOwner{
        _to.transfer(_amount * 1 szabo);
        sentEth(this, _to, _amount);
    }

    function transferReferralBonus(address [] db_client, uint256 [] amount) public onlyOwner{
        address sent_to;
        uint256 am_tkn;
    	for (uint256 i = 0; i < db_client.length; i++) {
        sent_to = db_client[i];
        am_tkn = amount[i];
   	    tokenReward.transfer(sent_to, am_tkn);
  	    amountReferralToken += am_tkn;
    	  sentReferralBonus(sent_to, am_tkn, now, true);
    	  }
    }
}

