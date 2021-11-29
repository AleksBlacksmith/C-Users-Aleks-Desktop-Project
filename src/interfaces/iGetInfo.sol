pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct _owners {
    address Owner;
    address secondOwner;
}

interface iGetInfo {
    // function getOwner() external returns (address);
    function getFirstAndSecondOwner() external view returns (_owners owners);
}
