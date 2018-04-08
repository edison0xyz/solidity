pragma solidity ^0.4.21;

contract Doggies {
    uint public totalDoggies = 100;
    uint public minAdoptionFee;

    uint private last_dogID = 0;
    address public owner;
    address public breeder;

    struct Dog {
        string name;
        string species;
        uint dogID;
        address owner;
    }

    mapping (uint => Dog) doggies;
    mapping (uint => address) owners;


    /* events declaration */

    event Breed(string _bark, address owner, string name);
    event OwnershipChanged(address prevOwner, address newOwner, uint id);
    event EtherReceived(address _from, uint value);
    event TransferSucceded(uint dogId, address _from, address _to, uint amountTransferred);
    event ApprovalApproved(uint dogid, address prevOwner, address newOwner);



    /* constructor function */
    function Doggies(uint _total, uint _minAdoptionFee) public {
        // initialise contract with the 33c address from remix
        owner = msg.sender;
        breeder = msg.sender;
        minAdoptionFee = _minAdoptionFee;
        totalDoggies = _total;
    }

    // require will throw if breeder != msg.sender, and refund remaining gas
    modifier isBreeder() {
        require(msg.sender == breeder);
        _;
    }

    function breed(string _name, string _species) isBreeder public {
        require(last_dogID + 1 <= totalDoggies);
        // create function
        doggies[last_dogID + 1].species = _species;
        doggies[last_dogID + 1].name = _name;

        /* Warning! this way of breeding might be insecure. If unique dogs are identified by
           a running sequence of IDs, it might lead to security issues. In actual
           cryptokitties - a popular ethereum app - implementation, they have a
           psuedo-random running sequence of "genes" to ensure uniqueness
        */

        // its insecure but i'm going to use it, anyway. #brevity
        doggies[last_dogID + 1].dogID = last_dogID + 1;
        doggies[last_dogID + 1].owner = owner;
        owners[last_dogID + 1] = owner;

        last_dogID++;  // increment count by one
        emit Breed(_name, owner, _species); // event emission
    }

    /* getter functions */
    function getDogById_owner(uint num) public view returns (address) {
        return doggies[num].owner;
    }
    function getDogById_species(uint num) public view returns (string) {
        return doggies[num].species;
    }

    function requestApproval(address prevOwner, address newOwner, uint dogId)
    private
    returns(bool)
    {
        /* note: in actual implementation, you MUST implement an approval
                 logic! Approval logic truncated to simplify tutorial */
        emit ApprovalApproved(dogId, prevOwner, newOwner);
        return true; // always return true for brevity
    }


    /* transfer_ownership: functions */
    function _transfer(address newOwner, address prevOwner, uint dogId) internal returns(bool){

        /* using bool response objects is a good practice for secure development
           by checking for boolean response, other functions can validate that transactions
           have been completed.
        */
        emit EtherReceived(msg.sender, msg.value);

        // new owner will pay prevowner a value >= minAdoptionFee
        require(msg.value >= minAdoptionFee);

        // Approval logic
        if(!requestApproval(prevOwner, newOwner, dogId)) {
            // no variables has been changed, so it is safe to return false if request is not approved
            return false;
        }

        //transfer throws and revert state when invocation is unsuccessful
        prevOwner.transfer(msg.value);
        emit TransferSucceded(dogId, newOwner, prevOwner, msg.value); //event
        /*
        // Another "safe" method - using `send`
        // when you choose to use send, you are responsible to handle failure code!

        if(prevOwner.send(msg.value)) {
            emit TransferSucceded(dogId, newOwner, prevOwner, msg.value);
        } else {
            // some failure mechanism
        }
        */

        //state changes
        doggies[dogId].owner = newOwner;
        owners[dogId] = newOwner;
        emit OwnershipChanged(newOwner, prevOwner,  dogId);

        // post-condition assertions to ensure correctness
        assert(owners[dogId] == doggies[dogId].owner);
        assert(doggies[dogId].owner == newOwner);
        return true;
    }

    function adopt(uint dogId) public payable returns(bool) {
        require(dogId <= last_dogID);

        return _transfer(msg.sender, doggies[dogId].owner, dogId);
    }
}
