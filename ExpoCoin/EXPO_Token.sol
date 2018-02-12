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

    //address Fund; // address of the fund for bonuses to clients
    //address PreICO_EXPC; // the address of the tokens that customers can buy
    address public distribution_to_community_adr;
    address public reserved_founding_adr;
    address public founders_and_team_adr;
    address public advisors_adr;
    address public bounty_adr;
 
    uint public distribution_to_community = 210000000;
    uint public reserved_founding = 45000000;
    uint public founders_and_team = 27000000;
    uint public advisors = 9000000;
    uint public bounty = 9000000;
   
    function TokenERC20(
    string tokenName, string tokenSymbol,
    address _reserved_founding_adr, address _founders_and_team_adr,
    address _advisors_adr, address _bounty_adr
    ) public {
        distribution_to_community_adr = msg.sender;
        reserved_founding_adr = _reserved_founding_adr;
        founders_and_team_adr = _founders_and_team_adr;
        advisors_adr = _advisors_adr;
        bounty_adr = _bounty_adr;
        
        balanceOf[distribution_to_community_adr] += distribution_to_community; 
        balanceOf[reserved_founding_adr] += reserved_founding; 
        balanceOf[founders_and_team_adr] += founders_and_team; 
        balanceOf[advisors_adr] += advisors; 
        balanceOf[bounty_adr] += bounty; 
        
        totalSupply = 300000000;
        name = tokenName;                                   
        symbol = tokenSymbol;    
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
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        Burn(msg.sender, _value);
        return true;
    }
    
    /* removing tokens from the address, in the case of changing 
    the address of the owner, or blocking an account. 
    Can only be used by the contract owner */
    function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) {
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
    
    event Change_distribution_to_community_adr(address _befor, address _to);
    event Change_reserved_founding_adr(address _befor, address _to);
    event Change_founders_and_team_adr(address _befor, address _to);
    event Change_advisors_adr(address _befor, address _to);
    event Change_bounty_adr(address _befor, address _to);
    
    event changeReleaseAccountTo(address _befor, address _to);
    
    function ShowMeBiz(string tokenName, string tokenSymbol,
    address _reserved_founding_adr, address _founders_and_team_adr,
    address _advisors_adr, address _bounty_adr) 
    TokenERC20(tokenName, tokenSymbol,
    _reserved_founding_adr, _founders_and_team_adr,
     _advisors_adr, _bounty_adr) public {
    }
    
    /* name token change function. Must cause only owner */
    function change_name(string _name) public onlyOwner returns (bool) {
        ChangeName(name,_name);
        name = _name;
        return true;
    }
    
    /* symbol token change function. Must cause only owner */
    function change_symbol(string _symbol) public onlyOwner returns (bool) {
        ChangeSymbol(symbol,_symbol);
        symbol=  _symbol;
        return true;
    }
    
        /* function for changing the address on which the distribution to community adr tokens are stored.
    When changing The address is also the transfer of all the tokens of 
    the old address to the new one. 
    The function can only be called by the owner */
    function changeDistributionToCommunityAdr(address _distribution_to_community_adr) public onlyOwner returns (bool) {
        require (_distribution_to_community_adr != 0x0);                              
        require(!frozenAccount[_distribution_to_community_adr]);                     
        balanceOf[_distribution_to_community_adr] = balanceOf[distribution_to_community_adr];
        balanceOf[distribution_to_community_adr] = 0;
        Change_distribution_to_community_adr(distribution_to_community_adr, _distribution_to_community_adr);
        distribution_to_community_adr = _distribution_to_community_adr;
        return true;
    }
    
    /* function for changing the address on which the reserved founding adr tokens are stored.
    When changing The address is also the transfer of all the tokens of 
    the old address to the new one. 
    The function can only be called by the owner */
    function changeReservedFoundingAdr(address _reserved_founding_adr) public onlyOwner returns (bool) {
        require (_reserved_founding_adr != 0x0);                              
        require(!frozenAccount[_reserved_founding_adr]);                     
        balanceOf[_reserved_founding_adr] = balanceOf[reserved_founding_adr];
        balanceOf[reserved_founding_adr] = 0;
        Change_reserved_founding_adr(reserved_founding_adr, _reserved_founding_adr);
        reserved_founding_adr = _reserved_founding_adr;
        return true;
    }
    
    /* function for changing the address on which the founders and team adr tokens are stored.
    When changing The address is also the transfer of all the tokens of 
    the old address to the new one. 
    The function can only be called by the owner */
    function changeFoundersAndTeamAdr(address _founders_and_team_adr) public onlyOwner returns (bool) {
        require (_founders_and_team_adr != 0x0);                              
        require(!frozenAccount[_founders_and_team_adr]);                     
        balanceOf[_founders_and_team_adr] = balanceOf[founders_and_team_adr];
        balanceOf[founders_and_team_adr] = 0;
        Change_founders_and_team_adr(founders_and_team_adr, _founders_and_team_adr);
        founders_and_team_adr = _founders_and_team_adr;
        return true;
    }
    
    /* function for changing the address on which the advisors adr tokens are stored.
    When changing The address is also the transfer of all the tokens of 
    the old address to the new one. 
    The function can only be called by the owner */
    function changeAdvisorsAdr(address _advisors_adr) public onlyOwner returns (bool) {
        require (_advisors_adr != 0x0);                              
        require(!frozenAccount[_advisors_adr]);                     
        balanceOf[_advisors_adr] = balanceOf[advisors_adr];
        balanceOf[advisors_adr] = 0;
        Change_advisors_adr(advisors_adr, _advisors_adr);
        advisors_adr = _advisors_adr;
        return true;
    }
    
        /* the function of changing the address on which the stock codes are stored.
    When changing The address is also the transfer of all the tokens of 
    the old address to the new one. 
    The function can only be called by the owner */
    function changeBountyAdr(address _bounty_adr) public onlyOwner returns (bool) {
        require (_bounty_adr != 0x0);                              
        require(!frozenAccount[_bounty_adr]);                     
        balanceOf[_bounty_adr] = balanceOf[bounty_adr];
        balanceOf[bounty_adr] = 0;
        Change_bounty_adr(bounty_adr, _bounty_adr);
        bounty_adr = _bounty_adr;
        return true;
    }
        
     /* function is used to change the owner of the token contract, 
     in case of change addresses. Can only be used by the owner with 
     a new address */
    function changeReleaseAccount(address _owner, address _newowner)public onlyOwner returns (bool) {
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
