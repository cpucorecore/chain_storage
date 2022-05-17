const common = require('./common');

contract('File_addFile-deleteFile', accounts => {
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    let context;

    before(async () => {
        context = await common.prepareTestContext(accounts);
    })

    it('fileAdded', async () => {
        let nodeExist;
        let taskCount;
        let nodes;

        await context.chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: context.tom});
        await context.chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: context.bob});

        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node1);
        assert.equal(nodeExist, false);
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node2);
        assert.equal(nodeExist, false);
        nodes = await context.fileStorage.getNodes.call(cid);
        assert.lengthOf(nodes, 0);

        taskCount = await context.taskStorage.getCurrentTid.call();
        assert.equal(taskCount, 2);

        await context.chainStorage.nodeAcceptTask(1, {from: context.node1});
        await context.chainStorage.nodeAcceptTask(2, {from: context.node2});

        await context.chainStorage.nodeFinishTask(1, common.fileSize, {from: context.node1});
        nodes = await context.fileStorage.getNodes.call(cid);
        assert.lengthOf(nodes, 1);
        console.log(nodes);

        await context.chainStorage.nodeFinishTask(2, common.fileSize, {from: context.node2});
        nodes = await context.fileStorage.getNodes.call(cid);
        assert.lengthOf(nodes, 2);
        console.log(nodes);

        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node1);
        assert.equal(nodeExist, true);
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node2);
        assert.equal(nodeExist, true);

        await context.chainStorage.userDeleteFile(cid, {from: context.tom});
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node1);
        assert.equal(nodeExist, true);
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node2);
        assert.equal(nodeExist, true);

        await context.chainStorage.userDeleteFile(cid, {from: context.bob});
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node1);
        assert.equal(nodeExist, true);
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node2);
        assert.equal(nodeExist, true);

        await context.chainStorage.nodeAcceptTask(3, {from: context.node1});
        await context.chainStorage.nodeAcceptTask(4, {from: context.node2});

        let storageInfo = await context.nodeStorage.getStorageInfo.call(context.node1);
        console.log(storageInfo[0].toString());
        storageInfo = await context.nodeStorage.getStorageInfo.call(context.node2);
        console.log(storageInfo[0].toString());

        await context.chainStorage.nodeFinishTask(4, common.fileSize, {from: context.node2});
        let fileExist = await context.fileStorage.exist(cid);
        assert.equal(fileExist, true);

        storageInfo = await context.nodeStorage.getStorageInfo.call(context.node1);
        console.log(storageInfo[0].toString());
        storageInfo = await context.nodeStorage.getStorageInfo.call(context.node2);
        console.log(storageInfo[0].toString());

        let task = await context.taskStorage.getTask.call(3);
        console.log(task);
        task = await context.taskStorage.getTask.call(4);
        console.log(task);
        await context.chainStorage.nodeFinishTask(3, common.fileSize, {from: context.node1});

        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node1);
        assert.equal(nodeExist, false);
        nodeExist = await context.fileStorage.nodeExist.call(cid, context.node2);
        assert.equal(nodeExist, false);

        fileExist = await context.fileStorage.exist(cid);
        assert.equal(fileExist, false);
    })
});