const common = require('./common');

const Setting = artifacts.require("Setting");
const History = artifacts.require("History");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");
const User = artifacts.require("User");

contract('User_random_operation1', accounts => {
    let settingInstance;
    let historyInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;
    let userInstance;

    const fileSize = 1000;
    const fileDuration = 3600;
    const fileExt = 'test';
    const replica = 4;

    const cids = [
        'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H',
        'QmUgU1m8wtsiyfXnKJn6yMP66zph5X716GZqjqYrZWsLjf',
        'QmRnCyTbu47hdg173ja4j8xUoEZ5MjRHT6yqDMSqtqXHhF',
        'QmbZU93HjXLn5wseFjCLyw1tM5BDoitSiZfR5o3Jo6C6tN',
        'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir'
    ];

    const tom = accounts[0];
    const bob = accounts[1];

    const node1 = accounts[5];
    const node2 = accounts[6];
    const node3 = accounts[7];
    const node4 = accounts[8];

    before(async () => {
        settingInstance = await Setting.deployed();
        historyInstance = await History.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();
        userInstance = await User.deployed();

        await settingInstance.setReplica(replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setMaxUserExtLength(common.maxUserExtLength);
        await settingInstance.setMaxFileExtLength(common.maxFileExtLength);
        await settingInstance.setMaxCidLength(common.maxCidLength);
        await settingInstance.setInitSpace(common.initSpace);

        await userInstance.register(tom, common.userExt);
        await userInstance.register(bob, common.userExt);

        await nodeInstance.register(node1, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node2, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node3, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node4, common.nodeTotalSpace, common.nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
        await nodeInstance.online(node3);
        await nodeInstance.online(node4);
    })

    /* random operations:
    user1.addFile(cid1)-->
    node1.finishAddFile-->
    node2.finishAddFile-->
    node3.finishAddFile-->
    node4.finishAddFile--
    user1.deleteFile(cid1)-->
    node1.finishDeleteFile-->
    node2.finishDeleteFile-->
    node3.finishDeleteFile-->
    node4.finishDeleteFile-->
    user2.addFile(cid1)-->
    node1.finishAddFile-->
    node2.finishAddFile-->
    node3.finishAddFile-->
    node4.finishAddFile
     */

    it('random operations1', async () => {
        await userInstance.addFile(tom, cids[0], fileSize, fileDuration, fileExt);

        await taskInstance.acceptTask(node1, 1);
        await taskInstance.acceptTask(node2, 2);
        await taskInstance.acceptTask(node3, 3);
        await taskInstance.acceptTask(node4, 4);
        await nodeInstance.finishTask(node1, 1);
        await nodeInstance.finishTask(node2, 2);
        await nodeInstance.finishTask(node3, 3);
        await nodeInstance.finishTask(node4, 4);

        // check Task
        let currentTid;
        let nodeMaxTid;
        let task;
        let createTime;
        let createBlock;
        let taskStatus;

        currentTid = await taskInstance.getCurrentTid.call();
        assert.equal(currentTid, 4);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 1);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 2);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 3);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 4);
        task = await taskInstance.getTaskItem.call(1);
        console.log(task);
        task = await taskInstance.getTaskItem.call(2);
        console.log(task);
        task = await taskInstance.getTaskItem.call(3);
        console.log(task);
        task = await taskInstance.getTaskItem.call(4);
        console.log(task);
        createTime = await taskInstance.getCreateTime.call(1);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(2);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(3);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(4);
        console.log(createTime.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(1);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(2);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(3);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(4);
        console.log(createBlock.toString());
        taskStatus = await taskInstance.getStatusInfo.call(1);
        console.log(taskStatus);
        taskStatus = await taskInstance.getStatusInfo.call(2);
        console.log(taskStatus);
        taskStatus = await taskInstance.getStatusInfo.call(3);
        console.log(taskStatus);
        taskStatus = await taskInstance.getStatusInfo.call(4);
        console.log(taskStatus);

        // check File
        let fileExist;
        let _fileSize;
        let ownerExist;
        let nodeExist;
        let owners;
        let nodes
        let totalFileNumber;
        let totalSize;

        fileExist = await fileInstance.exist.call(cids[0]);
        assert.equal(fileExist, true);
        _fileSize = await fileInstance.getSize.call(cids[0]);
        assert.equal(_fileSize, fileSize);
        ownerExist = await fileInstance.ownerExist.call(cids[0], tom);
        assert.equal(ownerExist, true);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node2);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node3);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node4);
        assert.equal(nodeExist, true);
        owners = await fileInstance.getOwners.call(cids[0]);
        console.log(owners);
        assert.lengthOf(owners, 1);
        nodes = await fileInstance.getNodes.call(cids[0]);
        console.log(nodes);
        assert.lengthOf(nodes, 4);
        totalFileNumber = await fileInstance.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 1);
        totalSize = await fileInstance.getTotalSize.call();
        assert.equal(totalSize, fileSize);

        // check User
        let _fileExt;
        let _fileDuration;
        let _cids;
        let userNumber;

        _fileExt = await userInstance.getFileExt.call(tom, cids[0]);
        assert.equal(_fileExt, fileExt);
        _fileDuration = await userInstance.getFileDuration.call(tom, cids[0]);
        assert.equal(_fileDuration, fileDuration);
        _cids = await userInstance.getCids.call(tom, 50, 1);
        console.log(_cids);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node
        let nodeCidsNumber;
        let nodeCids;
        let nodeNumber;
        let onlineNodeNumber;

        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node1);
        assert.equal(nodeCidsNumber, 1);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node2);
        assert.equal(nodeCidsNumber, 1);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node3);
        assert.equal(nodeCidsNumber, 1);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node4);
        assert.equal(nodeCidsNumber, 1);

        nodeCids = await nodeInstance.getNodeCids.call(node1);
        console.log(nodeCids);
        nodeCids = await nodeInstance.getNodeCids.call(node1, 50, 1);
        console.log(nodeCids);

        nodeNumber = await nodeInstance.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);
    })
})
