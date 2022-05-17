pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/INode.sol";
import "./interfaces/ITask.sol";

contract File is Importable, ExternalStorable, IFile {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
            CONTRACT_USER,
            CONTRACT_NODE,
            CONTRACT_TASK
        ];
    }

    function _Storage() private view returns (IFileStorage) {
        return IFileStorage(getStorage());
    }

    function _User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function _Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function _Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function addFile(string calldata cid, address owner) external returns (bool finish) {
        mustAddress(CONTRACT_USER);

        if(!_Storage().exist(cid)) {
            _Storage().newFile(cid);
            _Node().addFile(owner, cid);
        }

        if(!_Storage().ownerExist(cid, owner)) {
            _Storage().addOwner(cid, owner);
            finish = true;
        }
    }

    function onNodeAddFileFinish(address node, address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_NODE);

        if(_Storage().exist(cid)) {
            if(_Storage().nodeEmpty(cid)) {
                _User().onAddFileFinish(owner, cid, size);
                _Storage().setSize(cid, size);
                _Storage().upTotalSize(size);
            }

            if(!_Storage().nodeExist(cid, node)) {
                _Storage().addNode(cid, node);
            }
        } else {
            _Task().issueTask(Delete, owner, cid, node);
        }
    }

    function onAddFileFail(address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);
        _User().onAddFileFail(owner, cid);
    }

    function deleteFile(string calldata cid, address owner) external returns (bool finish) {
        mustAddress(CONTRACT_USER);

        require(_Storage().exist(cid), "F:file not exist");

        if(_Storage().ownerExist(cid, owner)) {
            _Storage().deleteOwner(cid, owner);
            finish = true;
        }

        if(_Storage().ownerEmpty(cid)) {
            if(_Storage().nodeEmpty(cid)) {
                _Storage().deleteFile(cid);
                _Storage().downTotalSize(_Storage().getSize(cid));
                finish = true;
            } else {
                address[] memory nodes = _Storage().getNodes(cid);
                for(uint i=0; i<nodes.length; i++) {
                    _Task().issueTask(Delete, owner, cid, nodes[i]);
                }
            }
        }
    }

    function onNodeDeleteFileFinish(address node, address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);

        if(_Storage().nodeExist(cid, node)) {
            _Storage().deleteNode(cid, node);
        }

        if(_Storage().nodeEmpty(cid)) {
            _User().onDeleteFileFinish(owner, cid, _Storage().getSize(cid));
            if(_Storage().ownerEmpty(cid)) {
                _Storage().deleteFile(cid);
            }
        }
    }

    function getSize(string calldata cid) external view returns (uint256) {
        return _Storage().getSize(cid);
    }
}
