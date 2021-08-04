pragma solidity >=0.5.16;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./IDB.sol";

contract Database is Ownable , IDB
{
    uint private ownerFee;
    uint private polkaLokrFee;
    address private recepient;
    //uint private x;
    
    
    constructor()
    {
        ownerFee = 10 wei;
        polkaLokrFee = 20 wei;
        recepient = msg.sender;
    }
    
    
    function setOwnerFee(uint _ownerFee) public  onlyOwner
    {
        ownerFee = _ownerFee;
        //x = _ownerFee;
    }
    
    
    function getOwnerFee() external override view returns (uint)
    {
        return ownerFee;
    }
    
    
     function setPolkaLokrFee(uint _polkaFee) public  onlyOwner
    {
        polkaLokrFee = _polkaFee;
    }
    
    function getPolkaLokrFee() external override view returns (uint)
    {
        return polkaLokrFee;
    }
    
    
     function setRecepient(address _recepient) public  onlyOwner
    {
        recepient = _recepient;
    }
    
     function getRecepient() external override view returns (address)
    {
        return recepient;
    }
    
    
}