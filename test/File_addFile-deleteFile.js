const common = require('./common');

contract('File_addFile-deleteFile', accounts => {
    let ctx;
    let chainStorage;
    let userStorage;
    let nodeStorage;
    let fileStorage;
    let taskStorage;
    
    let tom;
    let bob;
    let node1;
    let node2;

    let dumpState;
    
    before(async () => {
        ctx = await common.prepareTestContext(accounts);
        chainStorage = ctx.chainStorage;
        userStorage = ctx.userStorage;
        nodeStorage = ctx.nodeStorage;
        fileStorage = ctx.fileStorage;
        taskStorage = ctx.taskStorage;
        tom = ctx.user1;
        bob = ctx.user2;
        node1 = ctx.node1;
        node2 = ctx.node2;
        dumpState = common.dumpState;
    })

    it('fileAdded', async() => {
        const cid = common.cid;
        
        let nodeExist;
        let taskCount;
        let nodes;

        await chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: tom});

        taskCount = await taskStorage.getCurrentTid.call();
        assert.equal(taskCount, 2);

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});
        await dumpState(ctx, "node1.finishTask(1)");
        await chainStorage.nodeFinishTask(2, common.fileSize, {from: node2});
        await dumpState(ctx, "node2.finishTask(2)");

        await chainStorage.userAddFile(cid, common.duration, common.fileExt, {from: bob});
        await dumpState(ctx, "bob.addFile()");
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
        await dumpState(ctx, "tom.deleteFile()");

        await chainStorage.userDeleteFile(cid, {from: bob});
        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        await dumpState(ctx, "bob.deleteFile()");

        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeAcceptTask(4, {from: node2});

        await chainStorage.nodeFinishTask(4, common.fileSize, {from: node2});
        let fileExist = await fileStorage.exist(cid);
        assert.equal(fileExist, true);
        await dumpState(ctx, "node2.finishTask(4)");

        let task = await taskStorage.getTask.call(3);
        console.log(task);
        task = await taskStorage.getTask.call(4);
        console.log(task);
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node1});
        await dumpState(ctx, "node1.finishTask(3)");

        nodeExist = await fileStorage.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileStorage.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);

        fileExist = await fileStorage.exist(cid);
        assert.equal(fileExist, false);
    })
});