// SPDX-License-Identifier: MIT LICENSE

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

pragma solidity ^0.8.7;

contract UserDb is ReentrancyGuard, Ownable, AccessControl {

    uint256 public currentEntry; // This variable counts the amount of users registered.
    // currentEntry++ , this increments the integer by 1.

    struct userAccount {
        string accountCid;
        address userId;
        address payWallet;
        uint256 userNum;
    }

    mapping(address => userAccount) public _account;

    struct userNumber {
        address entryWallet;
    }

    mapping(uint256 => userNumber) public _entry;

    struct userPicture {
        string pictureCid;
    }

    mapping(address => userPicture) public _picture;

    struct erc20Pay {
        uint256 lastPaid;
    }

    mapping(address => erc20Pay) public _ercPay;

    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(UPDATER_ROLE, _msgSender());
    }

    function createProfile(string memory newCid, address wallet, address payErcWallet)
    external
    nonReentrant
    {
     require(hasRole(UPDATER_ROLE, _msgSender()), "You must have updater role to run");
     currentEntry++;
     _account[wallet] = userAccount({
        accountCid: newCid,
        userId: wallet,
        userNum: currentEntry,
        payWallet: payErcWallet
        });
   _entry[currentEntry] = userNumber({
         entryWallet: wallet
        });

    }

    function updateProfile(string memory newCid, address wallet)
    external
    nonReentrant
    {
      require(hasRole(UPDATER_ROLE, _msgSender()), "You must have updater role to run");
      address ercWallet = _account[msg.sender].payWallet;
      uint256 usernumber = _account[msg.sender].userNum;
      _account[wallet] = userAccount({
        accountCid: newCid,
        userId: wallet,
        payWallet: ercWallet,
        userNum: usernumber
        });
    }

    function updatePicture(string memory newCid, address wallet)
    external
    nonReentrant
    {
      require(hasRole(UPDATER_ROLE, _msgSender()), "You must have updater role to run");
      _picture[wallet] = userPicture({
        pictureCid: newCid
       });
    }

    function recordPay(uint256 lastPay, address wallet)
    external
    nonReentrant
    {
      require(hasRole(UPDATER_ROLE, _msgSender()), "You must have updater role to run");
      _ercPay[wallet] = erc20Pay({
        lastPaid: lastPay
         });
    }

    function migrateProfile(address newwallet)
    external
    nonReentrant
    {
      require(_account[msg.sender].userId == msg.sender, "Account not found");
      require(_account[msg.sender].userId != newwallet, "Wallet already exists");
      uint256 previousId = _account[msg.sender].userNum;
      _entry[previousId] = userNumber({
        entryWallet: newwallet
        });
      string memory migrateUserCid = _account[msg.sender].accountCid;
      address ercWallet = _account[msg.sender].payWallet;
      _account[newwallet] = userAccount({
        accountCid: migrateUserCid,
        userId: newwallet,
        payWallet: ercWallet,
        userNum: previousId
        });
        delete _account[msg.sender];
        string memory migratePicCid = _picture[msg.sender].pictureCid;
        _picture[newwallet] = userPicture({
            pictureCid: migratePicCid
       });
       delete _picture[msg.sender];
       uint256 lastPaidTime = _ercPay[msg.sender].lastPaid;
       _ercPay[newwallet] = erc20Pay({
            lastPaid: lastPaidTime
       });
       delete _ercPay[msg.sender];
    }

    function deleteProfile()
    external
    nonReentrant
    {
      require(_account[msg.sender].userId == msg.sender, "Account not found");
      uint256 previousId = _account[msg.sender].userNum;
      delete _entry[previousId];
      delete _account[msg.sender];
      delete _picture[msg.sender];
      delete _ercPay[msg.sender];
    }

    function confirmUser() external view returns (address){
        address userWallet = _account[msg.sender].userId;
        return userWallet;
    }

}