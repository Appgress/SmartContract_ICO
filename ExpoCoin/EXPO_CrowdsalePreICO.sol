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


/* token sales contract to PreICO customers in return for 
receiving tokens and transferring to primary accounts */
contract Crowdsale is Ownable{
	
	address public AppGress_adr;
	address public PreICO_adr;
	
	uint256 public startPreSale;
	uint256 public deadline;
	uint256 public January24;//25%
	uint256 public January28;//10%
	uint256 public February1;//5%
	uint256 public February5;//0%
	
	mapping(address => uint256) public balanceOf; //баланс по клієнтам
	uint256 public contractBalance;
	uint256 AppGressBalance;
	
	uint256 public price;
	uint256 public bonus;
	uint256 public min_buy_token;
	
	mapping(uint256 => address) db_client; //приватна бд
	mapping(address => bool) isClient; //перевірка чи це наш клієнт
	uint256 ID_client; 
	uint256 balanceClient;
	
	mapping(uint256 => address) db_vip;
	mapping(address => bool) isVIP;
	uint256 ID_vip;
	uint256 balanceVIP;
	
	uint256 public pr50;
	uint256 public pr25;
	uint256 public pr10;
	uint256 public pr5;
	uint256 public prApp;

	token public tokenReward;
	event TransferToken(address bayer, uint256 amount_to_client,uint256 amount_to_AppGress, uint256 date, uint256 eth, bool suc);
	event newStartRreICO(uint newStart);
	event newDate(uint new_date);
	event newMinBuyToken(uint newMin);
	event newPrice(uint newCost);
	event newAppGressAddr(address newAppGress);
	event newPreICOAddr(address newPreICO);
	event newTokenAddres(address newToken);
	event newDeadline(uint newFinish);
	event changeBalance(uint256 bef, uint256 to, address client1);
	
    function Crowdsale(
	uint256 _contractBalance,
	uint256 _price,
	address _AppGress_adr,
	address _PreICO_adr,
	address addressOfTokenUsedAsReward
    ) public{
		AppGress_adr = _AppGress_adr;
		PreICO_adr = _PreICO_adr;
		price = _price * 1 szabo;
		min_buy_token = price * 100;
		contractBalance = _contractBalance;
		
		startPreSale = now;
		January24 = 1516788000;//25%
	    January28 = 1517133600;//10%
	    February1 = 1517479200;//5%
	    February5 = 1517824800;//0%
		deadline = 1518256800;// 10 February
		
		ID_client = 0;
		ID_vip = 0;
		balanceClient = 0;
		balanceVIP = 0;
		AppGressBalance = 0;
		
		pr50 = 2;
	    pr25 = 4;
	    pr10 = 10;
	    pr5 = 20;
		prApp = 20;
		
		tokenReward = token(addressOfTokenUsedAsReward);
    }
	function change_balanceOf(uint256 _balanceOf, address _balanceOfAddress) public onlyOwner{
		changeBalance(balanceOf[_balanceOfAddress], _balanceOf, _balanceOfAddress);
        balanceOf[_balanceOfAddress] = _balanceOf;
    }
	function change_tokenReward(address _tokenReward) public onlyOwner{
		newTokenAddres(_tokenReward);
        tokenReward = token(_tokenReward);
    }
	
	function change_balanceClient(uint256 _balanceClient) public onlyOwner{
		changeBalance(balanceClient, _balanceClient, 0);
        balanceClient = _balanceClient;
    }
	function change_balanceVIP(uint256 _balanceVIP) public onlyOwner{
		changeBalance(balanceVIP, _balanceVIP, 0);
        balanceVIP = _balanceVIP;
    }
	function change_AppGressBalance(uint256 _AppGressBalance) public onlyOwner{
		changeBalance(AppGressBalance, _AppGressBalance, 0);
        AppGressBalance = _AppGressBalance;
    }
	function change_ContractBalance(uint256 _contractBalance) public onlyOwner{
		changeBalance(contractBalance, _contractBalance, 0);
        contractBalance = _contractBalance;
    }
	function change_January24(uint256 _January24) public onlyOwner{
		newDate(_January24);
        January24 = _January24;
    }
	function change_January28(uint256 _January28) public onlyOwner{ 
		newDate(_January28);
        January28 = _January28;
    }
	function change_February1(uint256 _February1) public onlyOwner{
		newDate(_February1);
        February1 = _February1;
    }
	function change_February5(uint256 _February5) public onlyOwner{
		newDate(_February5);
        February5 = _February5;
    }
    function change_start_RreICO(uint256 _startPreSale) public onlyOwner{
		newDate(_startPreSale);
        startPreSale = _startPreSale;
    }
    function change_min_buy_token(uint256 _min_buy_token) public onlyOwner{
		require (_min_buy_token != 0); 
		newMinBuyToken(_min_buy_token);
        min_buy_token = _min_buy_token * 1 szabo; //1 ether = 1000000 szabo
		
    }
    function change_price(uint256 _price) public onlyOwner{
		require (_price != 0); 
		newPrice(_price);
        price = _price * 1 szabo; //1 ether = 1000000 szabo
		min_buy_token = price*100; //1 ether = 1000000 szabo
    }
    function change_AppGress_addr(address _AppGress_adr) public onlyOwner{
		require (_AppGress_adr != 0x0); 
		newAppGressAddr(_AppGress_adr);
        AppGress_adr = _AppGress_adr;
    }
    function change_PreICO_addr(address _PreICO_adr) public onlyOwner{
		require (_PreICO_adr != 0x0); 
		newPreICOAddr(_PreICO_adr);
        PreICO_adr = _PreICO_adr;
    }
    function change_deadline(uint256 _deadline) public onlyOwner{
		newDeadline(_deadline);		
        deadline = _deadline;
    }
	
	function change_pr50(uint256 _pr50) public onlyOwner{	
        pr50 = _pr50;
    }
	function change_pr25(uint256 _pr25) public onlyOwner{	
        pr25 = _pr25;
    }
	function change_pr10(uint256 _pr10) public onlyOwner{	
        pr10 = _pr10;
    }
	function change_pr5(uint256 _pr5) public onlyOwner{	
        pr5 = _pr5;
    }
	function change_prApp(uint256 _prApp) public onlyOwner{	
        prApp = _prApp;
    }
	
	function bonusForBuyer(uint256 amount) public onlyOwner{

    	if(now <= January24){ 
		    bonus = amount/pr50;
		}
		if(now >= January24 && now <= January28){ 
            bonus = amount/pr25;
		}
        if(now >= January28 && now <= February1){
            bonus = amount/pr10;
		}      
        if(now >= February1 && now <= February5){
            bonus = amount/pr5;
		}
	}
	
	function addVIPClient(address client, uint256 amount)public onlyOwner{
		if(isVIP[client] != true){
			db_vip[ID_vip] = client;
			ID_vip += 1;
			isVIP[client] = true;
			balanceVIP += amount;
		}
		else{
			balanceVIP += amount;
		}
	}

	function addClient(address client, uint256 amount)public onlyOwner{
		
		bonusForBuyer(amount);
		AppGressBalance += (amount/20);
		
		if(isClient[client] != true){
			db_client[ID_client] = client;
			isClient[client] = true;
			ID_client +=1;
			balanceOf[client] += amount;
			balanceClient += amount;
			contractBalance -= amount; 
		}
		else{
			balanceOf[client] += amount;
			contractBalance -= amount;
			balanceClient += amount;
		}
		if(amount >= 10000 || balanceOf[client] >= 10000){
			addVIPClient(client, amount);
		}
	}

	function return_eth(address client, uint256 amount) public onlyOwner{
        client.transfer(amount * 1 wei);
		 TransferToken(client,  amount,0,now, amount, true);
    }
	
	function buyTokenForCash(address client, uint256 amount) public onlyOwner{
		
		if(contractBalance >= amount){
			addClient(client, amount);
			tokenReward.transfer(client, amount);
		}
	}
	
    function buyToken(address client, uint amount) payable public{
		
		uint256 walletTr;
		
		if (amount >= min_buy_token && contractBalance >= amount/price){
	        
			addClient(client, amount/price);
			
			bonusForBuyer(amount/price);
			balanceOf[client] += bonus;
			balanceClient += bonus;
			contractBalance -= bonus;
			if(isVIP[client] == true){
				balanceVIP += bonus;
			}
			
			tokenReward.transfer(client, (amount/price+bonus));
			
			walletTr = amount/prApp;
			AppGress_adr.transfer(walletTr);
			walletTr = amount - walletTr;
			PreICO_adr.transfer(walletTr);

		    TransferToken(client,  amount/price,((amount - bonus)/20) ,now, amount, true);
			
		}
		else{
			return_eth(msg.sender, msg.value);
			TransferToken(client,  amount/price,((amount - bonus)/20) ,now, amount, false);
		}
	}
    function () payable public{
	
		if (now >= startPreSale && now < deadline){
			buyToken (msg.sender, msg.value);
		}
		else{
			return_eth(msg.sender, msg.value);
		}
    }

    modifier afterDeadline() { 
        if (now >= deadline) _; 
    }

    function VIPPackageClient() public onlyOwner afterDeadline{
		uint256 i = ID_vip;
		address toSentVip;
		
			for (uint j = 1; j <= i; j++) {
				toSentVip = db_vip[j];

				if(balanceOf[toSentVip] >= 10000 && balanceOf[toSentVip] < 20000){
					tokenReward.transfer(toSentVip, balanceOf[toSentVip]/20);
					contractBalance -= balanceOf[toSentVip]/20;
				}
				
				if(balanceOf[toSentVip] >= 20000 && balanceOf[toSentVip] < 40000){ 
				    tokenReward.transfer(toSentVip, balanceOf[toSentVip]/10);
					contractBalance -= balanceOf[toSentVip]/10;
				}
				
				if(balanceOf[toSentVip] >= 50000 && balanceOf[toSentVip] < 100000){ 
				    tokenReward.transfer(toSentVip, balanceOf[toSentVip]*3/20);
					contractBalance -= balanceOf[toSentVip]*3/20;
				}
				
				if(balanceOf[toSentVip] >= 100000){ 
				    tokenReward.transfer(toSentVip, balanceOf[toSentVip]/5);
					contractBalance -= balanceOf[toSentVip]/5;
				}
        }
    }
    
}

