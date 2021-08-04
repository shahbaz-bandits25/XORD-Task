pragma solidity >=0.5.16;


interface IDB
{
    function getOwnerFee() external view returns(uint);
    
    function getPolkaLokrFee() external view returns(uint);
    
    function getRecepient() external view returns (address);


}