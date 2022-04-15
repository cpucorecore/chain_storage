pragma solidity ^0.5.17;

import "./base/Importable.sol";
import "./base/Pausable.sol";
import "./base/Proxyable.sol";
import "./interfaces/IChainStorage.sol";

contract ChainStorage is Proxyable, Pausable, Importable, IChainStorage {

}
