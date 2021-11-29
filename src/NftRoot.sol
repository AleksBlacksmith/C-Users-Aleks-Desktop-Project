pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';
import './libraries/Common.sol';


contract NftRoot is DataResolver, IndexResolver {
    

    uint8 constant RARITY_DOES_NOT_EXIST = 110; 
    uint8 constant LIMIT_EXCEEDED = 111; 
    uint8 constant NOT_CREATOR = 112; 
    
    uint256 _totalMinted;
    address _addrBasis;

    address _addrCreator;

    mapping (string => uint) _rarityToLimit;
    mapping (string => uint) _rarityToMintedCount;

    uint _limit;

    bytes _icon;
    string _title;

    modifier creatorOnly() {
        require(msg.sender == _addrCreator, NOT_CREATOR);
        _;
    }
    modifier accept() {
        tvm.accept();
        _;
    }

    constructor(
        TvmCell codeIndex,
        TvmCell codeData,
        Rarity[] rarityTypeList,
        uint limit,
        bytes icon,
        string title
    ) public accept {
        _codeIndex = codeIndex;
        _codeData = codeData;
        for(uint i; i < rarityTypeList.length; i++) {
            Rarity rarity = rarityTypeList[i];
            _rarityToLimit[rarity.name] = rarity.limit;
        }
        _limit = limit;

        _addrCreator = msg.sender;
        _icon = icon;
    }

    function mintNft(string rarityName) public {
        require(_rarityToLimit.exists(rarityName), RARITY_DOES_NOT_EXIST);
        if(!_rarityToMintedCount.exists(rarityName)) {
            _rarityToMintedCount[rarityName] = 0;
        }
        require(
            _rarityToLimit[rarityName] > _rarityToMintedCount[rarityName] &&
            _limit > _rarityToMintedCount[rarityName],
            LIMIT_EXCEEDED
        );
        
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted);
        new Data{stateInit: stateData, value: 1.1 ton}(msg.sender, _codeIndex, rarityName);

        _totalMinted++;
    }

    function setIcon(bytes icon) public creatorOnly accept {
        _icon = icon;
    }

    function getIcon() public view accept returns(string icon) {
        icon = _icon;
    }

    function setTitle(string title) public creatorOnly accept {
        _title = title;
    }
    function getTitle() public view accept returns(string title) {
        title = _title;
    }

    function deployBasis(TvmCell codeIndexBasis) public {
        require(msg.value > 0.5 ton, 104);
        uint256 codeHasData = resolveCodeHashData();
        TvmCell state = tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {
                _codeHashData: codeHasData,
                _addrRoot: address(this)
            },
            code: codeIndexBasis
        });
        _addrBasis = new IndexBasis{stateInit: state, value: 0.4 ton}();
    }

    function destructBasis() public view {
        IIndexBasis(_addrBasis).destruct();
    }
}