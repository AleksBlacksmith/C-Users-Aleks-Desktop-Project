pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/IData.sol';

import './libraries/Constants.sol';

// import './interfaces/iGetInfo.sol';


contract Data is IData, IndexResolver {
    address _addrRoot;
    address _addrOwner;
    address _addrAuthor;
    address _addrApproveOwner;

    string _rarity;

    uint256 static _id;

    constructor(address addrOwner, TvmCell codeIndex, string rarity) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _addrAuthor = addrOwner;
        _codeIndex = codeIndex;

        _rarity = rarity;

        deployIndex(addrOwner);
    }

    function transferOwnership(address addrTo) public override {
        require(_addrApproveOwner == address(0));
        require(msg.sender == _addrOwner);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);

        address oldIndexOwner = resolveIndex(_addrRoot, address(this), _addrOwner);
        IIndex(oldIndexOwner).destruct();
        address oldIndexOwnerRoot = resolveIndex(address(0), address(this), _addrOwner);
        IIndex(oldIndexOwnerRoot).destruct();

        _addrOwner = addrTo;

        deployIndex(addrTo);
    }

    function deployIndex(address owner) private {
        TvmCell codeIndexOwner = _buildIndexCode(_addrRoot, owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: 0.4 ton}(_addrRoot);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(address(0), owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: 0.4 ton}(_addrRoot);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrData,
        address addrApproveOwner
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrData = address(this);
        addrApproveOwner = _addrApproveOwner;
    }

    function getOwner() public view override returns(address addrOwner) {
        addrOwner = _addrOwner;
    }

    // function getFirstAndSecondOwner() public view override returns (_owners owners){
    //     owners.Owner = _addrOwner;
    //     owners.secondOwner = _secondOwner;
    // }

    // struct _owners {
    //     address Owner;
    //     address secondOwner;
    // }

    mapping (address => mapping (address => address)) public allowed;
    function approve(address toOwner) public {
        require(msg.sender == _addrOwner);
        require(msg.sender != toOwner);
        _addrApproveOwner = toOwner;
        allowed[_addrOwner][toOwner] = address(this);
    }
}