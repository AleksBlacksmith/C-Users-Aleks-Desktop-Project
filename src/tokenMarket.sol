pragma ton-solidity >= 0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "libraries/date.sol";
import "interfaces/IData.sol";
// import "interfaces/IIndex.sol";
import "interfaces/iGetInfo.sol";

 struct Time {
                uint16 year;
                uint8 month;
                uint8 day;
        }

contract tokenMarket {

    constructor () public {
    }

    struct tokenPriceAndDate {
        uint tokenId;
        address addrData;
        uint price;
        uint16 year;
        uint8 month;
        uint day;
    }

    mapping (address => tokenPriceAndDate) tokenPriceAndDateList;
    uint tokenId = 1;

    function getTokenInfo(IData addrData) public returns (address) {
        // addrOwner = addrData.getOwner();
        // secondOwner = addrData.getSecondOwner();
        // (, address addrOwner, ) = addrData.getInfo();
    }

    function sellToken(IData addrData, uint128 price, uint16 year, uint8 month, uint8 day) public {
        // (address secondOwner) = addrData.getSecondOwner();
        (address addrToken, , , address addrApproveOwner) = addrData.getInfo();
        require(addrApproveOwner == address(this));
        require(addrData == addrToken);
        tvm.accept();
        date.deltaDate(year, month, day);
        tokenPriceAndDateList[addrData] = tokenPriceAndDate(tokenId, addrData, price, 
        date.deltaDate(year, month, day).year, 
        date.deltaDate(year, month, day).month, 
        date.deltaDate(year, month, day).day);

        tokenId++;
    }

    

    function buyToken(address addrData) public returns (string) {
        tvm.accept();
        uint timestamp = now;
        uint16 nowYear = date.getYear(timestamp);
        uint8 nowMonth = date.getMonth(timestamp);
        uint8 nowDay = date.getDay(timestamp);
        if (tokenPriceAndDateList[addrData].year <= nowYear) {
            if (tokenPriceAndDateList[addrData].month <= nowMonth) {
                if (tokenPriceAndDateList[addrData].day <= nowDay) {
                    // addrData.getOwner().transfer(tokenPriceAndDateList[tokenId].price, true, 1);
                    // addrData.transferOwnership(msg.sender);
                    delete tokenPriceAndDateList[addrData];
                    // delete allowed[addrData.getOwner()][]
                }
                else {
                    return ("Sale expired");
                }
            }
            else {
                return ("Sale expired");
            }
        }
        else {
            return ("Sale expired");
        }
    }

    // function removeSale() public returns (string) {
    //     tvm.accept();
    //     if (msg.sender == tokenPriceAndDateList[tokenId].tokenOwnerAddress) {
    //         delete tokenPriceAndDateList[tokenId];
    //     }
    //     else {
    //         return ("You are not the owner of the token");
    //     }
    // }

    // function getInfo() public returns (address TokenOwner, uint128 Price, string DeadlineTime) {
    //     tvm.accept();
    //     TokenOwner = tokenPriceAndDateList[tokenId].tokenOwnerAddress;
    //     Price = tokenPriceAndDateList[tokenId].price;
    //     DeadlineTime = format("{}.{}.{}", 
    //     tokenPriceAndDateList[tokenId].day,
    //     tokenPriceAndDateList[tokenId].month,
    //     tokenPriceAndDateList[tokenId].year);
    // }
}
