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


contract Bonus is Ownable{
    
    uint bonusToken;
    token public tokenReward;
    uint256 public amountBonusToken; 

    mapping (address => bool) public isDownloader;

    event Have_Bonus(address client, uint256 amount_token, uint256 date, bool ok);
    event Change_Bonus(address changer, uint256 from, uint256 to, uint256 date);
    event Back_Token(address changer, uint256 amount_token, uint256 date);
    event changeAddressToken(address changer,address to, uint256 date);
    event changeAmountBonusToken(address changer,uint256 from ,uint256 to, uint256 date);
    event changeDownloaderOpt(address downloader, string opt);

    function Bonus(
	address addressOfTokenUsedAsReward
    ) public {
		tokenReward = token(addressOfTokenUsedAsReward);
		bonusToken = 1;
		amountBonusToken = 0;
    }
    
    function changeTokenAddress(address new_address) public onlyOwner{
    	changeAddressToken(msg.sender, new_address, now);
    	tokenReward = token(new_address);
    }

    function changeAmountBonus(uint256 new_value) public onlyOwner{
    	changeAmountBonusToken(msg.sender, amountBonusToken, new_value, now);
    	amountBonusToken = new_value;
    }

    function canDownload(address downloader)public onlyOwner{
    	isDownloader[downloader] = false;
    	changeDownloaderOpt(downloader, "can download.");
    }

    function cantDownload(address downloader)public onlyOwner{
    	isDownloader[downloader] = true;
    	changeDownloaderOpt(downloader, "cant download.");
    }

    function kill() public onlyOwner{
    	selfdestruct(owner);
    }

    function changeBonus(uint256 amount) public onlyOwner{
    	Change_Bonus(msg.sender, bonusToken, amount, now);
    	bonusToken = amount;
    }

    function backTokenToBounty(address bounty_address, uint256 amount) public onlyOwner{
        tokenReward.transfer(bounty_address, amount);
        Back_Token(msg.sender, amount, now);
    }

    function transferBonus(address [] db_client) public onlyOwner{
        address sent_to;
    	for (uint256 i = 0; i < db_client.length; i++) {
    		sent_to = db_client[i];
    		if (isDownloader[sent_to] == false) {
    		    tokenReward.transfer(sent_to, bonusToken);
    		    isDownloader[sent_to] = true;
    		    amountBonusToken += bonusToken;
    		    Have_Bonus(sent_to, bonusToken, now, true);
    	    }
    	    else {
    	    	Have_Bonus(sent_to, bonusToken, now, false);
    	        } }
    }
}

