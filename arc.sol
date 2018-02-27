pragma solidity ^0.4.6;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
*/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
*/


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

}

/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
*/

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20Basic.sol
*/

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public valueTotalSupply;
    function totalSupply() constant returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
*/

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/BasicToken.sol
*/

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is Ownable,ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}


/**
* https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/StandardToken.sol
*/

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}



/**
* Allows a standard token to be upgraded by rerouting calls to the new contract
*/

contract UpgradedStandardToken is StandardToken{
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function transferByLegacy(address from, address to, uint256 value) returns(bool);
    function transferFromByLegacy(address sender, address from, address spender, uint256 value) returns(bool);
    function approveByLegacy(address from, address spender, uint256 value) returns(bool);
}

/**
 * @title - ARCCoin Token Contract - arccy.org
 * @author - James Russell - arccy.org
 * Defines an oracle that checks the maximum that should be in Circulation
 * to allow for minting and burning. This needs to be created as a seperate contract, prior to the creation of the
 * ARCCoin contract and the adress passed to the ARCCoin contract on creation.
 */
contract ARCCoinCirculation is usingOraclize,Ownable{

    uint256 public maximumCirculation;
    event updatedCirculation(string result);
    event newOraclizeQuery(string description);

    function () payable{}

    function ARCCoinCirculation() payable{
        updateCirculation();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        maximumCirculation = parseInt(result,18);
        updatedCirculation(result);
    }

    function updateCirculation() payable public onlyOwner{
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("OF");//abbreviated message oraclize fails due to lack of funds
        } else {
            newOraclizeQuery("OS");//oraclize success
            oraclize_query("URL", "json(https://www.arccy.org/maximint.json).totalARC");
        }
    }

}

/**
* @title - ARCCoin Token Contract - arccy.org
* @author - James Russell - arccy.org
**/

contract ARCCoin is StandardToken,Pausable{

    using SafeMath for uint;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    address public upgradedAddress;
    bool public deprecated;

    ARCCoinCirculation ARCCheck;

    // stores the list of frozen accounts
    mapping (address => bool) frozenAccounts;

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    // This notifies clients about frozen target accounts
    event FrozenFunds(address target, bool frozen);
    // Called when contract is deprecated
    event Deprecate(address newAddress);

    /**
    * Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) {
            throw;
        }
        _;
    }

    /**
     * Constructor function
     *
     * Initializes contract with initial supply of 0
     */
    function ARCCoin(address circulationCheck) public {

        //Set the name
        name = "ARCCoin";
        //Set the symbol
        symbol = "ARCC";
        //Set the deprecated state
        deprecated = false;
        //Initiate the totalSuppy and balancce for the creator
        valueTotalSupply = 0;
        balances[msg.sender] = valueTotalSupply;
        //connect to the circulation check contract
        ARCCheck = ARCCoinCirculation(circulationCheck);

    }


    /**
    * Forward ERC20 methods to upgraded contract if this one is deprecated
    */
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool){

        require(!frozenAccounts[msg.sender]);

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint _value) whenNotPaused public returns(bool){

        require(!frozenAccounts[msg.sender]);

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        } else {
            return super.transferFrom(_from, _to, _value);
        }

    }

    function balanceOf(address who) constant returns (uint){

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }

    }

    function approve(address _spender, uint _value) onlyPayloadSize(2 * 32) public returns(bool){

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }

    }

    function allowance(address _owner, address _spender) constant public returns(uint256){

        if (deprecated) {
            return StandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }

    }

    function totalSupply() constant returns (uint256){

        if (deprecated) {
            return StandardToken(upgradedAddress).totalSupply();
        } else {
            return valueTotalSupply;
        }

    }

    /**
    * Non standard ERC20 functions
    */

    /** @notice Create `mintAmount` tokens and send it to `target`
    * @param target Address to receive the tokens
    * @param mintAmount the amount of tokens it will receive
    */
    function mintARC(address target, uint256 mintAmount) onlyPayloadSize(2 * 32) onlyOwner whenNotPaused public {

        //Do not run if the contract has been deprecated
        require(!deprecated);

        //check that the oracle set maximum circulation is greater than the current
        //circulation, meaning that the valueTotalSupply should be increased.

        require(ARCCheck.maximumCirculation() >= valueTotalSupply.add(mintAmount));
        balances[target] = balances[target].add(mintAmount);
        valueTotalSupply = valueTotalSupply.add(mintAmount);

        Transfer(0, this, mintAmount);
        Transfer(this, target, mintAmount);

    }

    /**
    * Burn functions taken from https://www.ethereum.org/token
    */

    /**
     * Destroy tokens, tokens required to be burned will be transferred to the
     * main wallet before being burnt. This operation will be facilitated through arccy.org
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of ARCC to burn
     */
    function burn(uint256 _value) onlyPayloadSize(32) public onlyOwner whenNotPaused
    returns (bool success) {

        //Do not run if the contract has been deprecated
        require(!deprecated);

        //check that the oracle set maximum circulation is less than the current
        //circulation, meaning that the valueTotalSupply should be reduced.
        require(ARCCheck.maximumCirculation() < valueTotalSupply);
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender
        valueTotalSupply = valueTotalSupply.sub(_value);                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
    * gives the ability to freeze an account
    */
    function freezeAccount(address target, bool freeze) onlyPayloadSize(32 + 1) onlyOwner {

        frozenAccounts[target] = freeze;
        FrozenFunds(target, freeze);

    }

    /**
    * retuns the state of an account frozen/unfrozen
    */
    function frozenAccount(address target) onlyPayloadSize(32) public returns (bool frozen){

        return frozenAccounts[target];

    }

    /**
    * deprecate current contract
    */
    function deprecate(address _upgradedAddress) onlyOwner {

        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);

    }

}
