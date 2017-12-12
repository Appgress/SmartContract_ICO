pragma solidity ^0.4.16;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }  // token interface for approval

/* standard ERC20 token contract for minimum fikts
work with token */

contract TokenERC20 is Ownable{  

    string public name; // token name
    string public symbol; // symbol token
    uint8 public decimals = 0; // number of values after the point

    uint256 public totalSupply; // total number of tokens issued

	/* an array of all addresses that purchased tokens, and accordingly
balance of owner data. Must be public and public */
    mapping (address => uint256) public balanceOf; 
	
	/* an array of all addresses that purchased tokens, and accordingly
permissions to conduct a currency transaction. Must be public and public */
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

	/* event of destruction of tokens */
    event Burn(address indexed from, uint256 value);

	address public Fund; // address of the fund for bonuses to clients
    address public PreICO_EXPC; // the address of the tokens that customers can buy
 
    uint public amount_Fund = 45000000;
    uint public amount_PreICO = 2100000;
   
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address _Fund,
        address _PreICO_EXPC
    ) public {
        totalSupply = initialSupply;
        name = tokenName;                                   
        symbol = tokenSymbol;    
        
        Fund = _Fund;
        PreICO_EXPC = _PreICO_EXPC;
 
        balanceOf[msg.sender] = totalSupply;        
        
		// transfer tokens to the address of the fund and PreICO 
        _transfer(msg.sender,Fund,amount_Fund); 
        _transfer(msg.sender,PreICO_EXPC,amount_PreICO);
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
    //* standard token transfer function 
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    // translate tokens from the address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    // standard operation confirmation function by the owner
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
	
    /* standard function of confirmation and execution 
	of a certain block of operation */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* removal of tokens from the address of the owner of the contract, 
	in case of changing the contract address. 
	Can only be performed by the contract holder */
    function burn(uint256 _value) public returns (bool success) onlyOwner{
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        Burn(msg.sender, _value);
        return true;
    }
    
	/* removing tokens from the address, in the case of changing 
	the address of the owner, or blocking an account. 
	Can only be used by the contract owner */
    function burnFrom(address _from, uint256 _value) public returns (bool success) onlyOwner{
        require(balanceOf[_from] >= _value);               
        require(_value <= allowance[_from][msg.sender]);   
        balanceOf[_from] -= _value;                        
        allowance[_from][msg.sender] -= _value;            
        totalSupply -= _value;                             
        Burn(_from, _value);
        return true;
    }
}


contract ShowMeBiz is Ownable, TokenERC20 {

    /* array of account addresses that are frozen for
	further checking frozen accounts */
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
	
	/* list of events occurring in the contract */
	event ChangeName(string _befor, string _to);
	event ChangeSymbol(string _befor, string _to);
	event ChangePreICO_tknAddr(address _befor, address _to);
	event ChangeFund_tknAddr(address _befor, address _to);
	event changeReleaseAccountTo(address _befor, address _to);
	
    function ShowMeBiz(uint256 initialSupply,  string tokenName, 
	string tokenSymbol, address _Fund,address _PreICO_EXPC) 
    TokenERC20(initialSupply, tokenName, tokenSymbol, _Fund, _PreICO_EXPC) public {
    }
    
	/* name token change function. Must cause only owner */
    function change_name(string _name) public returns (bool) onlyOwner{
		require (_name != "");   
	    ChangeName(name,_name);
        name = _name;
        return true;
    }
    
	/* symbol token change function. Must cause only owner */
    function change_symbol(string _symbol) public returns (bool) onlyOwner{
		 require (_symbol != ""); 
	    change_symbol(symbol,_symbol);
        symbol=  _symbol;
        return true;
    }
	
	/* function for changing the address on which the PreICO tokens are stored.
	When changing The address is also the transfer of all the tokens of 
	the old address to the new one. 
	The function can only be called by the owner */
	function change_PreICO_tokenAddr(address _PreICO) public returns (bool) onlyOwner{
		require (_PreICO != 0x0);                              
        require(!frozenAccount[_PreICO]);                     
        balanceOf[_PreICO] = balanceOf[_PreICO_EXPC];
        balanceOf[_PreICO_EXPC] = 0;
		change_Fund_tokenAddr(_PreICO_EXPC, _PreICO);
	    _PreICO_EXPC = _PreICO;
        return true;
    }
	
	/* the function of changing the address on which the stock codes are stored.
	When changing The address is also the transfer of all the tokens of 
	the old address to the new one. 
	The function can only be called by the owner */
	function change_Fund_tokenAddr(address _FundTKN) public returns (bool) onlyOwner{
		require (_FundTKN != 0x0);                              
        require(!frozenAccount[_FundTKN]);                     
        balanceOf[_FundTKN] = balanceOf[_Fund];
        balanceOf[_Fund] = 0;
		change_Fund_tokenAddr(_Fund, _FundTKN);
	    _PreICO_EXPC = _PreICO;
        return true;
    }
	
	 /* function is used to change the owner of the token contract, 
	 in case of change addresses. Can only be used by the owner with 
	 a new address */
    function changeReleaseAccount(address _owner, address _newowner) public returns (bool) onlyOwner{
        require (_newowner != 0x0);                              
        require(!frozenAccount[_newowner]);                     
        require(!frozenAccount[_owner]); 
        balanceOf[_newowner] = balanceOf[_owner];
        balanceOf[_owner] = 0;
		changeReleaseAccountTo(_owner, _newowner);
        return true;
	}
	
    /* function used to transfer tokens (not ether)
	free (not buying). Is a public contract function */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                              
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        Transfer(_from, _to, _value);
    }

	/* issue new tokens, if additional tokens are required.
	Can only be performed by the contract holder */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    /* freezing an account that will no longer be able to buy 
	and return tokens */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

}
