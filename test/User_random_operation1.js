const common = require('./common');
const {dumpTask} = require("./common");

contract('User_random_operation1', accounts => {
    let ctx;

    let chainStorage;
    let taskStorage;
    let fileStorage;
    let userStorage;
    let nodeStorage;

    let user1;
    let user2;

    let node1;
    let node2;
    let node3;
    let node4;

    let dumpState;
    let dumpTask;

    const cids = common.cids;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 4, 2, 4);

        chainStorage = ctx.chainStorage;
        taskStorage = ctx.taskStorage;
        fileStorage = ctx.fileStorage;
        userStorage = ctx.userStorage;
        nodeStorage = ctx.nodeStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];
        node3 = ctx.nodes[2];
        node4 = ctx.nodes[3];

        user1 = ctx.users[0];
        user2 = ctx.users[1];

        dumpState = common.dumpState;
        dumpTask = common.dumpTask;
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
        const fileSize = common.fileSize;
        /*
        user1.addFile(cid1)-->
        node1.finishAddFile-->
        node2.finishAddFile-->
        node3.finishAddFile-->
        node4.finishAddFile-->
         */
        const fileDuration = common.duration;
        const fileExt = common.fileExt;

        await chainStorage.userAddFile(cids[0], common.duration, common.fileExt, {from: user1});

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeAcceptTask(3, {from: node3});
        await chainStorage.nodeAcceptTask(4, {from: node4});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});
        await chainStorage.nodeFinishTask(2, common.fileSize, {from: node2});
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node3});
        await chainStorage.nodeFinishTask(4, common.fileSize, {from: node4});

        // check Task
        let currentTid;
        let nodeMaxTid;

        currentTid = await taskStorage.getCurrentTid.call();
        assert.equal(currentTid, 4);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 1);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 2);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 3);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 4);

        await dumpTask(ctx, 1, 4);

        // check File
        let fileExist;
        let _fileSize;
        let userExist;
        let nodeExist;
        let owners;
        let nodes
        let totalFileNumber;
        let totalSize;

        fileExist = await fileStorage.exist.call(cids[0]);
        assert.equal(fileExist, true);
        _fileSize = await fileStorage.getSize.call(cids[0]);
        assert.equal(_fileSize, fileSize);
        userExist = await fileStorage.userExist.call(cids[0], user1);
        assert.equal(userExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node2);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node3);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node4);
        assert.equal(nodeExist, true);
        owners = await fileStorage.getUsers.call(cids[0]);
        console.log(owners);
        assert.lengthOf(owners, 1);
        nodes = await fileStorage.getNodes.call(cids[0]);
        console.log(nodes);
        assert.lengthOf(nodes, 4);
        totalFileNumber = await fileStorage.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 1);
        totalSize = await fileStorage.getTotalSize.call();
        assert.equal(totalSize, fileSize);

        // check User
        let _fileExt;
        let _fileDuration;
        let _cids;
        let userNumber;

        _fileExt = await userStorage.getFileExt.call(user1, cids[0]);
        assert.equal(_fileExt, fileExt);
        _fileDuration = await userStorage.getFileDuration.call(user1, cids[0]);
        assert.equal(_fileDuration, fileDuration);
        _cids = await userStorage.getCids.call(user1, 50, 1);
        console.log(_cids);
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node
        let nodeCidsNumber;
        let nodeCids;
        let nodeNumber;
        let onlineNodeNumber;

        // TODO check node cidNumbers

        nodeNumber = await nodeStorage.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);

        /*
        user1.deleteFile(cid1)-->
        node1.finishDeleteFile-->
        node2.finishDeleteFile-->
        node3.finishDeleteFile-->
        node4.finishDeleteFile-->
         */
        await chainStorage.userDeleteFile(cids[0], {from: user1});
        await chainStorage.nodeAcceptTask(5, {from: node1});
        await chainStorage.nodeAcceptTask(6, {from: node2});
        await chainStorage.nodeAcceptTask(7, {from: node3});
        await chainStorage.nodeAcceptTask(8, {from: node4});
        await chainStorage.nodeFinishTask(5, common.fileSize, {from: node1});
        await chainStorage.nodeFinishTask(6, common.fileSize, {from: node2});
        await chainStorage.nodeFinishTask(7, common.fileSize, {from: node3});
        await chainStorage.nodeFinishTask(8, common.fileSize, {from: node4});

        // check Task
        currentTid = await taskStorage.getCurrentTid.call();
        assert.equal(currentTid, 8);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 5);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 6);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 7);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 8);

        await dumpTask(ctx, 5, 8);

        // check File
        fileExist = await fileStorage.exist.call(cids[0]);
        assert.equal(fileExist, false);
        userExist = await fileStorage.userExist.call(cids[0], user1);
        assert.equal(userExist, false);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node2);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node3);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node4);
        assert.equal(nodeExist, false);
        owners = await fileStorage.getUsers.call(cids[0]);
        assert.lengthOf(owners, 0);
        nodes = await fileStorage.getNodes.call(cids[0]);
        assert.lengthOf(nodes, 0);
        totalFileNumber = await fileStorage.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 0);
        totalSize = await fileStorage.getTotalSize.call();
        assert.equal(totalSize, 0);

        // check User
        _fileExt = await userStorage.getFileExt.call(user1, cids[0]);
        assert.equal(_fileExt, '');
        _fileDuration = await userStorage.getFileDuration.call(user1, cids[0]);
        assert.equal(_fileDuration, 0);
        _cids = await userStorage.getCids.call(user1, 50, 1);
        console.log(_cids);
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node

        nodeNumber = await nodeStorage.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);

        /*
        user2.addFile(cid1)-->
        node1.finishAddFile-->
        node2.finishAddFile-->
        node3.finishAddFile-->
        node4.finishAddFile
         */
        await chainStorage.userAddFile(cids[0], fileDuration, fileExt, {from: user2});
        await chainStorage.nodeAcceptTask(9, {from: node1});
        await chainStorage.nodeAcceptTask(10, {from: node2});
        await chainStorage.nodeAcceptTask(11, {from: node3});
        await chainStorage.nodeAcceptTask(12, {from: node4});
        await chainStorage.nodeFinishTask(9, common.fileSize, {from: node1});
        await chainStorage.nodeFinishTask(10, common.fileSize, {from: node2});
        await chainStorage.nodeFinishTask(11, common.fileSize, {from: node3});
        await chainStorage.nodeFinishTask(12, common.fileSize, {from: node4});

        // check Task
        currentTid = await taskStorage.getCurrentTid.call();
        assert.equal(currentTid, 12);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node1);
        assert.equal(nodeMaxTid, 9);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node2);
        assert.equal(nodeMaxTid, 10);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node3);
        assert.equal(nodeMaxTid, 11);
        nodeMaxTid = await taskStorage.getNodeMaxTid.call(node4);
        assert.equal(nodeMaxTid, 12);
        
        dumpTask(ctx, 9, 12);

        // check File
        fileExist = await fileStorage.exist.call(cids[0]);
        assert.equal(fileExist, true);
        _fileSize = await fileStorage.getSize.call(cids[0]);
        assert.equal(_fileSize, fileSize);
        userExist = await fileStorage.userExist.call(cids[0], user1);
        assert.equal(userExist, false);
        userExist = await fileStorage.userExist.call(cids[0], user2);
        assert.equal(userExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node2);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node3);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cids[0], node4);
        assert.equal(nodeExist, true);
        owners = await fileStorage.getUsers.call(cids[0]);
        assert.lengthOf(owners, 1);
        nodes = await fileStorage.getNodes.call(cids[0]);
        assert.lengthOf(nodes, 4);
        totalFileNumber = await fileStorage.getTotalFileNumber.call();
        assert.equal(totalFileNumber, 1);
        totalSize = await fileStorage.getTotalSize.call();
        assert.equal(totalSize, fileSize);

        // check User
        _fileExt = await userStorage.getFileExt.call(user1, cids[0]);
        assert.equal(_fileExt, '');
        _fileExt = await userStorage.getFileExt.call(user2, cids[0]);
        assert.equal(_fileExt, fileExt);
        _fileDuration = await userStorage.getFileDuration.call(user1, cids[0]);
        assert.equal(_fileDuration, 0);
        _fileDuration = await userStorage.getFileDuration.call(user2, cids[0]);
        assert.equal(_fileDuration, fileDuration);
        _cids = await userStorage.getCids.call(user1, 50, 1);
        console.log(_cids);
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        // check Node

        nodeNumber = await nodeStorage.getTotalNodeNumber.call();
        assert.equal(nodeNumber, 4);

        onlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        assert.equal(onlineNodeNumber, 4);
    })
})
