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
        'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H', // hash: 0xdda4e1efafe56f53f4025cd0708f6bdff673e1aa3995eea9f023c6eec2a7eb4a
        'QmUgU1m8wtsiyfXnKJn6yMP66zph5X716GZqjqYrZWsLjf', // hash: 0xf8af37dd2f20cebb5f9720a4c63a7ceaa036a5042a30b87a19832e0fa530c84c
        'QmRnCyTbu47hdg173ja4j8xUoEZ5MjRHT6yqDMSqtqXHhF', // hash: 0xd4a832f0884972948d6eee2c2daa0e91def2d4bd5f4f899c9eda1d78a28a9b44
        'QmbZU93HjXLn5wseFjCLyw1tM5BDoitSiZfR5o3Jo6C6tN', // hash: 0x68fc51c0de0c0e6be1067b90862da21f2e796b933851e5aaecf9d1d6f6ff332b
        'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir' // hash: 0x5ef8d464eb9a1baaf9c52ccfef2262fda94bd65cc559526f90e9ea37e73b2068
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
    node4.finishAddFile-->
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
        /*
        user1.addFile(cid1)-->
        node1.finishAddFile-->
        node2.finishAddFile-->
        node3.finishAddFile-->
        node4.finishAddFile-->
         */
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

        /*
        user1.deleteFile(cid1)-->
        node1.finishDeleteFile-->
        node2.finishDeleteFile-->
        node3.finishDeleteFile-->
        node4.finishDeleteFile-->
         */
        await userInstance.deleteFile(tom, cids[0]);
        await taskInstance.acceptTask(node1, 5);
        await taskInstance.acceptTask(node2, 6);
        await taskInstance.acceptTask(node3, 7);
        await taskInstance.acceptTask(node4, 8);
        await nodeInstance.finishTask(node1, 5);
        await nodeInstance.finishTask(node2, 6);
        await nodeInstance.finishTask(node3, 7);
        await nodeInstance.finishTask(node4, 8);

        // check Task
        currentTid = await taskInstance.getCurrentTid.call();
        assert.equal(currentTid, 8);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 5);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 6);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 7);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 8);
        createTime = await taskInstance.getCreateTime.call(5);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(6);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(7);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(8);
        console.log(createTime.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(5);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(6);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(7);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(8);
        console.log(createBlock.toString());

        // check File
        fileExist = await fileInstance.exist.call(cids[0]);
        assert.equal(fileExist, false);
        _fileSize = await fileInstance.getSize.call(cids[0]);
        assert.equal(_fileSize, 0);
        ownerExist = await fileInstance.ownerExist.call(cids[0], tom);
        assert.equal(ownerExist, false);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node2);
        assert.equal(nodeExist, false);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node3);
        assert.equal(nodeExist, false);
        nodeExist = await fileInstance.nodeExist.call(cids[0], node4);
        assert.equal(nodeExist, false);
        owners = await fileInstance.getOwners.call(cids[0]);
        assert.lengthOf(owners, 0);
        nodes = await fileInstance.getNodes.call(cids[0]);
        assert.lengthOf(nodes, 0);
        totalFileNumber = await fileInstance.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 0);
        totalSize = await fileInstance.getTotalSize.call();
        assert.equal(totalSize, 0);

        // check User
        _fileExt = await userInstance.getFileExt.call(tom, cids[0]);
        assert.equal(_fileExt, '');
        _fileDuration = await userInstance.getFileDuration.call(tom, cids[0]);
        assert.equal(_fileDuration, 0);
        _cids = await userInstance.getCids.call(tom, 50, 1);
        console.log(_cids);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node1);
        assert.equal(nodeCidsNumber, 0);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node2);
        assert.equal(nodeCidsNumber, 0);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node3);
        assert.equal(nodeCidsNumber, 0);
        nodeCidsNumber = await nodeInstance.getNodeCidsNumber.call(node4);
        assert.equal(nodeCidsNumber, 0);

        nodeCids = await nodeInstance.getNodeCids.call(node1);
        console.log(nodeCids);
        assert.lengthOf(nodeCids, 0);
        nodeCids = await nodeInstance.getNodeCids.call(node1, 50, 1);
        console.log(nodeCids);

        nodeNumber = await nodeInstance.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);

        /*
        user2.addFile(cid1)-->
        node1.finishAddFile-->
        node2.finishAddFile-->
        node3.finishAddFile-->
        node4.finishAddFile
         */
        await userInstance.addFile(bob, cids[0], fileSize, fileDuration, fileExt);
        await taskInstance.acceptTask(node1, 9);
        await taskInstance.acceptTask(node2, 10);
        await taskInstance.acceptTask(node3, 11);
        await taskInstance.acceptTask(node4, 12);
        await nodeInstance.finishTask(node1, 9);
        await nodeInstance.finishTask(node2, 10);
        await nodeInstance.finishTask(node3, 11);
        await nodeInstance.finishTask(node4, 12);

        // check Task
        currentTid = await taskInstance.getCurrentTid.call();
        assert.equal(currentTid, 12);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 9);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 10);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 11);
        nodeMaxTid = await taskInstance.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 12);
        createTime = await taskInstance.getCreateTime.call(9);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(10);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(11);
        console.log(createTime.toString());
        createTime = await taskInstance.getCreateTime.call(12);
        console.log(createTime.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(9);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(10);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(11);
        console.log(createBlock.toString());
        createBlock = await taskInstance.getCreateBlockNumber.call(12);
        console.log(createBlock.toString());

        // check File
        fileExist = await fileInstance.exist.call(cids[0]);
        assert.equal(fileExist, true);
        _fileSize = await fileInstance.getSize.call(cids[0]);
        assert.equal(_fileSize, fileSize);
        ownerExist = await fileInstance.ownerExist.call(cids[0], tom);
        assert.equal(ownerExist, false);
        ownerExist = await fileInstance.ownerExist.call(cids[0], bob);
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
        assert.lengthOf(owners, 1);
        nodes = await fileInstance.getNodes.call(cids[0]);
        assert.lengthOf(nodes, 4);
        totalFileNumber = await fileInstance.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 1);
        totalSize = await fileInstance.getTotalSize.call();
        assert.equal(totalSize, fileSize);

        // check User
        _fileExt = await userInstance.getFileExt.call(tom, cids[0]);
        assert.equal(_fileExt, '');
        _fileExt = await userInstance.getFileExt.call(bob, cids[0]);
        assert.equal(_fileExt, fileExt);
        _fileDuration = await userInstance.getFileDuration.call(tom, cids[0]);
        assert.equal(_fileDuration, 0);
        _fileDuration = await userInstance.getFileDuration.call(bob, cids[0]);
        assert.equal(_fileDuration, fileDuration);
        _cids = await userInstance.getCids.call(tom, 50, 1);
        console.log(_cids);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node
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
        assert.lengthOf(nodeCids, 1);
        nodeCids = await nodeInstance.getNodeCids.call(node1, 50, 1);
        console.log(nodeCids);

        nodeNumber = await nodeInstance.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);

        // check History
        let userHistoryNumber = await historyInstance.getUserHistoryNumber.call();
        assert.equal(userHistoryNumber, 3);
        let userHistory = await historyInstance.getUserHistoryIndexesByUser.call(tom, 20, 1);
        assert.lengthOf(userHistory[0], 2);
        userHistory = await historyInstance.getUserHistoryIndexesByUser.call(bob, 20, 1);
        assert.lengthOf(userHistory[0], 1);

        let nodeHistoryNumber = await historyInstance.getNodeHistoryNumber.call();
        assert.equal(nodeHistoryNumber, 12);
        let nodeHistory = await historyInstance.getNodeHistoryIndexesByNode.call(node1, 20, 1);
        assert.lengthOf(nodeHistory[0], 3);
        nodeHistory = await historyInstance.getNodeHistoryIndexesByNode.call(node2, 20, 1);
        assert.lengthOf(nodeHistory[0], 3);
        nodeHistory = await historyInstance.getNodeHistoryIndexesByNode.call(node3, 20, 1);
        assert.lengthOf(nodeHistory[0], 3);
        nodeHistory = await historyInstance.getNodeHistoryIndexesByNode.call(node4, 20, 1);
        assert.lengthOf(nodeHistory[0], 3);
    })
})
