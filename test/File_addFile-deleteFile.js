const common = require('./common');

const ChainStorage = artifacts.require("ChainStorage");
const Setting = artifacts.require("Setting");
const NodeStorage = artifacts.require("NodeStorage");
const FileStorage = artifacts.require("FileStorage");
const TaskStorage = artifacts.require("TaskStorage");

contract('File_addFile-deleteFile', accounts => {
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    let chainStorageInstance;
    let settingInstance;
    let nodeStorageInstance;
    let fileStorageInstance;
    let taskStorageInstance;

    let node1 = accounts[5];
    let node2 = accounts[6];

    let tom = accounts[0];
    let bob = accounts[1];

    before(async () => {
        chainStorageInstance = await ChainStorage.deployed();
        settingInstance = await Setting.deployed();
        nodeStorageInstance = await NodeStorage.deployed();
        fileStorageInstance = await FileStorage.deployed();
        taskStorageInstance = await TaskStorage.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxUserExtLength(common.maxUserExtLength);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setMaxFileExtLength(common.maxFileExtLength);
        await settingInstance.setInitSpace(common.initSpace);
        await settingInstance.setMaxCidLength(common.maxCidLength);

        await chainStorageInstance.userRegister(common.userExt, {from: tom});
        await chainStorageInstance.userRegister(common.userExt, {from: bob});

        await chainStorageInstance.nodeRegister(common.nodeTotalSpace, common.nodeExt, {from: node1});
        await chainStorageInstance.nodeRegister(common.nodeTotalSpace, common.nodeExt, {from: node2});

        await chainStorageInstance.nodeOnline({from: node1});
        await chainStorageInstance.nodeOnline({from: node2});
    })

    it('fileAdded', async () => {
        let nodeExist;
        let taskCount;
        let nodes;

        await chainStorageInstance.userAddFile(cid, common.duration, common.fileExt, {from: tom});
        await chainStorageInstance.userAddFile(cid, common.duration, common.fileExt, {from: bob});

        nodeExist = await fileStorageInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);
        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 0);

        taskCount = await taskStorageInstance.getCurrentTid.call();
        assert.equal(taskCount, 2);

        await chainStorageInstance.nodeAcceptTask(1, {from: node1});
        await chainStorageInstance.nodeAcceptTask(2, {from :node2});

        await chainStorageInstance.nodeFinishTask(1, common.fileSize, {from: node1});
        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 1);
        console.log(nodes);

        await chainStorageInstance.nodeFinishTask(2, common.fileSize, {from: node2});
        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 2);
        console.log(nodes);

        nodeExist = await fileStorageInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);

        await chainStorageInstance.userDeleteFile(cid, {from: tom});
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);

        await chainStorageInstance.userDeleteFile(cid, {from: bob});
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);

        await chainStorageInstance.nodeAcceptTask(3, {from: node1});
        await chainStorageInstance.nodeAcceptTask(4, {from: node2});

        let storageInfo = await nodeStorageInstance.getStorageInfo.call(node1);
        console.log(storageInfo[0].toString());
        storageInfo = await nodeStorageInstance.getStorageInfo.call(node2);
        console.log(storageInfo[0].toString());

        await chainStorageInstance.nodeFinishTask(4, common.fileSize, {from: node2});
        let fileExist = await fileStorageInstance.exist(cid);
        assert.equal(fileExist, true);

        storageInfo = await nodeStorageInstance.getStorageInfo.call(node1);
        console.log(storageInfo[0].toString());
        storageInfo = await nodeStorageInstance.getStorageInfo.call(node2);
        console.log(storageInfo[0].toString());

        let task = await taskStorageInstance.getTask(3);
        console.log(task);
        task = await taskStorageInstance.getTask(4);
        console.log(task);
        await chainStorageInstance.nodeFinishTask(3, common.fileSize, {from: node1});

        nodeExist = await fileStorageInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorageInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);

        fileExist = await fileStorageInstance.exist(cid);
        assert.equal(fileExist, false);
    })
});