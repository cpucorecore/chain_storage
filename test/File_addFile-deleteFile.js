const common = require('./common');

contract('File_addFile-deleteFile', accounts => {
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    let chainStorage;
    let userStorage;
    let nodeStorage;
    let fileStorage;
    let taskStorage;
    
    let tom;
    let bob;
    let node1;
    let node2;
    
    before(async () => {
        let context = await common.prepareTestContext(accounts);
        chainStorage = context.chainStorage;
        userStorage = context.userStorage;
        nodeStorage = context.nodeStorage;
        fileStorage = context.fileStorage;
        taskStorage = context.taskStorage;
        tom = context.tom;
        bob = context.bob;
        node1 = context.node1;
        node2 = context.node2;
    })

    async function debug(what) {
        console.log("================after: " + what + "================");

        // user
        let userStorageUsed = await userStorage.getStorageUsed.call(tom);
        console.log("tom.storageUsed=" + userStorageUsed.toString());

        userStorageUsed = await userStorage.getStorageUsed.call(bob);
        console.log("bob.storageUsed=" + userStorageUsed.toString());

        // node
        let nodeStorageUsed = await nodeStorage.getStorageUsed.call(node1);
        console.log("node1.storageUsed=" + nodeStorageUsed.toString());

        nodeStorageUsed = await nodeStorage.getStorageUsed.call(node2);
        console.log("node2.storageUsed=" + nodeStorageUsed.toString());

        // file
        let fileTotal = await fileStorage.getTotalSize.call();
        console.log("file.totalSize=" + fileTotal.toString());

        let totalFileNumber = await fileStorage.getTotalFileNumber.call();
        console.log("file.totalFileNumber=" + totalFileNumber.toString());

        console.log("--------------------------------\n");
    }

    it('fileAdded', async() => {
        let nodeExist;
        let taskCount;
        let nodes;

        await chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: tom});

        taskCount = await taskStorage.getCurrentTid.call();
        assert.equal(taskCount, 2);

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});
        await debug("node1.finishTask(1)");
        await chainStorage.nodeFinishTask(2, common.fileSize, {from: node2});
        await debug("node2.finishTask(2)");

        await chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: bob});
        await debug("bob.addFile()");
        nodes = await fileStorage.getNodes.call(cid);
        assert.lengthOf(nodes, 2);
        console.log(nodes);

        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);

        await chainStorage.userDeleteFile(cid, {from: tom});
        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        await debug("tom.deleteFile()");

        await chainStorage.userDeleteFile(cid, {from: bob});
        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        await debug("bob.deleteFile()");

        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeAcceptTask(4, {from: node2});

        await chainStorage.nodeFinishTask(4, common.fileSize, {from: node2});
        let fileExist = await fileStorage.exist(cid);
        assert.equal(fileExist, true);
        await debug("node2.finishTask(4)");

        let task = await taskStorage.getTask.call(3);
        console.log(task);
        task = await taskStorage.getTask.call(4);
        console.log(task);
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node1});
        await debug("node1.finishTask(3)");

        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);

        fileExist = await fileStorage.exist(cid);
        assert.equal(fileExist, false);
    })
});