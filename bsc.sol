pragma solidity >=0.5.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IERC20BurnNMintable.sol";
import "./IDB.sol";

//import "./Database.sol";


    

contract BSCBridge  {
    using SafeMath for uint256;
    

    bool public whiteListOn;

    address public OWNER;
    address public signWallet1;
    address public signWallet2;

    // key: transit_id
    mapping(bytes32 => bool) public executedMap;
    mapping(address => bool) public isWhiteList;

    event Payback(address indexed sender,address indexed from, address indexed token, uint256 amount, uint256 destinationChainID, bytes32 migrationId);
    event Withdraw(bytes32 transitId, address indexed to, address indexed token, uint256 amount, uint256 fee);
    event SignerChanged(address indexed oldSigner1, address  newSigner1,address indexed oldSigner2, address  newSigner2);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    constructor(address _signer1,address _signer2) {
        require(_signer1 != address(0) || _signer2 != address(0), "INVALID_ADDRESS");
        signWallet1 = _signer1;
        signWallet2 = _signer2;
        OWNER = msg.sender;
        whiteListOn = true;
    }
    
    function toggleWhiteListOnly() external {
        require(msg.sender == OWNER, "Sender not Owner");
        whiteListOn = !whiteListOn;

    }

    function toggleWhiteListAddress(address[] calldata _addresses) external {
        require(msg.sender == OWNER, "Sender not Owner");
        require(_addresses.length<=200,"Addresses length exceeded");
        for (uint256 i = 0; i < _addresses.length; i++) {
            isWhiteList[_addresses[i]] = !isWhiteList[_addresses[i]];
        }
    }


  function changeSigner(address _wallet1, address _wallet2) external {
        require(msg.sender == OWNER, "CHANGE_SIGNER_FORBIDDEN");
        require(_wallet1!=address(0) && _wallet2!=address(0),"Invalid Address");
        emit SignerChanged(signWallet1, _wallet1,signWallet2, _wallet2);
        signWallet1 = _wallet1;
        signWallet2 = _wallet2;
    }


    function changeOwner(address _newowner) external {
        require(msg.sender == OWNER, "CHANGE_OWNER_FORBIDDEN");
        require(_newowner!=address(0),"Invalid Address");
        emit OwnerChanged(OWNER, _newowner);
        OWNER = _newowner;
    }


    function paybackTransit(address _token, uint256 _amount, address _to, uint256 _destinationChainID, bytes32 _migrationId) external {
        address sender=msg.sender;
        require(_amount > 0, "INVALID_AMOUNT");
        require(!whiteListOn || isWhiteList[sender], "Forbidden in White List mode");
        IERC20BurnNMintable(_token).burn(sender, _amount);
        emit Payback(sender,_to, _token, _amount, _destinationChainID,_migrationId);
    }

    function withdrawTransitToken(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 _transitId,
        address _token,
        address _beneficiary,
        uint256 _amount,
        uint256 _fee
    ) external {
        require(signWallet1 == msg.sender || signWallet2 == msg.sender, "Sender Does not Have Claim Rights");
        require(!executedMap[_transitId], "ALREADY_EXECUTED");
        require(_amount > 0, "NOTHING_TO_WITHDRAW");
        require(_amount > _fee, "Fee cannot be greater then withdrawl amount");
        bytes32 message = keccak256(abi.encode(_transitId, _beneficiary, _amount, _token));
        _validate(v, r, s, message);
        
        uint256 userAmount = _amount - _fee;
        executedMap[_transitId] = true;
        uint256 contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20BurnNMintable(_token).mint(address(this), _amount);
        require(IERC20(_token).balanceOf(address(this))>contractBalance,"Minting Did not Work");
        IERC20(_token).transfer(_beneficiary, userAmount);
        //yahan fee ma 2% add krna ha fee ka
        
        // IERC20(_token).transfer(OWNER, _fee+2%);

        IERC20(_token).transfer(OWNER, _fee);
        

        emit Withdraw(_transitId, _beneficiary, _token, _amount, _fee);
    }
    
    address _ADR = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        
        function pErcentage(uint _fee) public view returns (uint) {
        
        uint calcFee;
        calcFee = IDB(_ADR).getOwnerFee();
        
        uint Percent = (calcFee * _fee)/100;
        uint totalFee;
        return totalFee = _fee + Percent;
        }

    function getDomainSeparator() internal view returns (bytes32) {
        return keccak256(abi.encode("0x01", address(this)));
    }

    function _validate(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 encodeData
    ) internal view {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), encodeData));
        address recoveredAddress = ecrecover(digest, v, r, s);
        // Explicitly disallow authorizations for address(0) as ecrecover returns address(0) on malformed messages
        require(recoveredAddress!= address(0) && (recoveredAddress == signWallet1 || recoveredAddress == signWallet2), "INVALID_SIGNATURE");

    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) external {
        require(msg.sender == OWNER, "INVALID_OWNER");
        IERC20(_token).transfer(_to, _amount);
    }
   
  
//   address ADDR = 0xBE46bA58D315f0d6cD37bd7F313ccBfdC760e891;
   
//   function getOwnFee() public view returns(uint)
//   {
//       return IDB(ADDR).getOwnerFee();
//   }
   
//   function getPolkaFee() public view returns(uint)
//   {
//       return IDB(ADDR).getPolkaLokrFee();
//   }
   
   
//     function getRecept() public view returns(address)
//   {
//       return IDB(ADDR).getRecepient();
//   }
}
