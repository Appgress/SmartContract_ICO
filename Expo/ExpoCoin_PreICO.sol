
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint256 amount);
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
    uint256 public finishPreSale;

    uint256 public fundingGoal;
    uint256 public amountRaised;
    uint256 public deadline;
    uint256 public price;
    uint256 public day_price;
    uint256 public min_buy_token;
    token public tokenReward;

    mapping(address => uint256) public balanceOf;
    
    address [] public VIP_addr;
    uint256 counter;

    
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);
    event Bonus(address _to,uint256 how_many);
	event newStartRreICO(uint newStart);
	event newMinBuyToken(uint newMin);
	event newPrice(uint newCost);
	event newAppGressAddr(address newAppGress);
	event newPreICOAddr(address newPreICO);
	event newDeadline(uint newFinish);

    function Crowdsale(
        address _AppGress_adr,
        address _PreICO_adr,
        uint256 day_to_deadline,
        uint256 etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) {
        AppGress_adr = _AppGress_adr;
        PreICO_adr = _PreICO_adr;
        price = etherCostOfEachToken * 1 finney;
        deadline = now + day_to_deadline * 1440 * 1 minutes;   
        startPreSale = now;
        min_buy_token = price * 100;
        tokenReward = token(addressOfTokenUsedAsReward);
        counter = 1;
    }
    
	// Change the start date of token sales. Can only be performed by the owner
    function change_start_RreICO(uint256 _startPreSale) onlyOwner{
		require (now + _startPreSale >= now); 
		newStartRreICO(_startPreSale);
        startPreSale = now + _startPreSale * 1 minutes;
    }
    
	// Change the minimum token purchase amount. Can only be performed by the owner
    function change_min_buy_token(uint256 _min_buy_token) onlyOwner{
		require (_min_buy_token != 0); 
		newMinBuyToken(_min_buy_token);
        min_buy_token = _min_buy_token * 1 finney;
		
    }
	
    // Change the price for the token. Can only be performed by the owner
    function change_price(uint256 _price) onlyOwner{
		require (_min_buy_token != 0); 
		newPrice(_price);
        price = _price * 1 finney;
    }
    
	/* Change the address of the wallet AppGress.
	Can only be performed by the owner*/
    function change_AppGress_addr(address _AppGress_adr) onlyOwner{
		require (_AppGress_adr != 0x0); 
		newAppGressAddr(_AppGress_adr);
        AppGress_adr = _AppGress_adr;
    }
    
	/* Change the address of the wallet ShowMeBiz. 
	Can only be performed by the owner*/
    function change_PreICO_addr(address _PreICO_adr) onlyOwner{
		require (_PreICO_adr != 0x0); 
		newPreICOAddr(_PreICO_adr);
        PreICO_adr = _PreICO_adr;
    }
    
	// Change the date of the deadline. Can only be performed by the owner
    function change_deadline(uint256 _deadline) onlyOwner{
		require (now + _deadline >= now);
		newDeadline(_deadline);		
        deadline = _deadline;
    }
    
	// The modifier of verification has already ended the date of the ICO
    modifier afterDeadline() { 
        if (now >= deadline) _; 
    }
	
    /* The modifier of verification is it possible to 
	buy customer tokens at the moment*/
    modifier isSale() { 
        if (now < deadline) _; 

    }
    
	/* Calculation of the price depending on what is now the day: 
	1 - 4 day 50% discount, 
	5-8 days 25% discount, 
	9 - 12 days 10% discount, 
	13 - 16 days 5% discount */
    function dayPrice() public returns (uint) onlyOwner{
         if(now * 1 minutes - startPreSale <= 4 * 1440 * 1 minutes){
            day_price = price * 1/2;
            return day_price;
        }
        if(now * 1 minutes - startPreSale >= 5 * 1440 * 1 minutes && now * 1 minutes - startPreSale <= 8* 1440 * 1 minutes){
            day_price = price*3/4;
            return day_price;
        }
        
        if(now * 1 minutes - startPreSale >= 9* 1440 * 1 minutes && now * 1 minutes - startPreSale <= 12* 1440 * 1 minutes){
            day_price = price * 9/10;
            return day_price;
        }
        
        if(now * 1 minutes - startPreSale >= 13* 1440 * 1 minutes && now * 1 minutes - startPreSale <= 16* 1440 * 1 minutes){
            day_price = price * 95/100;
            return day_price;
        }
        
        if(now * 1 minutes - startPreSale > 16* 1440 * 1 minutes){
            day_price = price;
            return day_price;
        }
    }
    
	/* The function of distributing funds when purchasing 
	tokens by customers to accounts AppGress and ShowMeBiz 
	accounts is 10% to AppGress and 90% - to ShowMeBiz respectively */
    function sent_eth(uint256 amount_eth) public onlyOwner{
        uint256 AppGress_am;
        uint256 PreICO_am;
     
        AppGress_am = amount_eth*1/10; //10%
        PreICO_am = amount_eth*9/10; //90% 
        
        AppGress_adr.transfer(AppGress_am);
        PreICO_adr.transfer(PreICO_am);
    }
    
	//Refund function in case of unsuccessful purchase
    function return_eth(address _to, uint256 _amount) onlyOwner{
        _to.transfer(_amount);
    }
	
	//The function of transferring funds to company accounts and tokens to clients
    function buyToken(uint _amount, uint _dayPrice) onlyOwner {
		balanceOf[msg.sender] += _amount;
        //amountRaised += amount;
        tokenReward.transfer(msg.sender, _amount/_dayPrice);
        sent_eth(_amount);
        FundTransfer(msg.sender, _amount, true);
        
	}
	
	/*A function is called when the client sends an ETH
	to the contract account, and in return receives tokens*/
    function () payable isSale{
        
        day_price = dayPrice();
        min_buy_token = day_price * 100; //0.2 eth, 50 EXPC
        uint256 top_price = min_buy_token *100;
        uint256 amount = msg.value;
        bool success_buy = false;
        
        if (amount >= min_buy_token){
            if(amount >=  top_price){ //20 eth, 5000 EXPC
                buyToken(amount, day_price);        
				VIP_addr[counter] = msg.sender; 
				counter++; 
				success_buy = true;
            }
            
            else{
				buyToken(uint amount, uint day_price);
				success_buy = true;
            }
        }
        
        if(success_buy == false){
            msg.sender.transfer(amount);
        }
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
   
    /* VIP customers who have made a purchase for more than $ 10,000, 
	at the end of the ISO receive additional bonuses: 
	the distribution of tokens that were left respectively on clients */
    function given_tkn_toVIP() afterDeadline, onlyOwner{
        
        uint256 sum_balances_VIPclient = 0;
        uint256 tkn_procent_balance = 0;
        uint256 tkn_bonus;
        uint256 j = 1;
        
        while(counter >= j ){
            sum_balances_VIPclient += balanceOf[VIP_addr[j]];
            j++;
        }
        
        while(counter >= j){
            tkn_procent_balance = balanceOf[VIP_addr[j]] /sum_balances_VIPclient;
            tkn_bonus = tkn_procent_balance * balanceOf[this];
            //VIP_addr[j].transfer(tkn_bonus);
            _transfer(this, VIP_addr[j], tkn_bonus);
            Bonus(VIP_addr[j],tkn_bonus);
            j++;
            }
        }
}

