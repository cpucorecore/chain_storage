const common = require('./common');

contract('File_exist', accounts => {
    let ctx;
    let chainStorage;
    let fileStorage;

    let node1;
    let node2;

    let user1;
    let user2;

    let dumpState = common.dumpState;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 2, 2, 2);

        chainStorage = ctx.chainStorage;
        fileStorage = ctx.fileStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];

        user1 = ctx.users[0];
        user2 = ctx.users[1];
    })

    it('exist', async () => {
        const cid = common.cid;
        const duration = common.duration;
        const fileExt = common.fileExt;

        await chainStorage.userAddFile(cid, duration, fileExt, {from: user1});

        let exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});

        await chainStorage.userAddFile(cid, duration, fileExt, {from: user2});
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await chainStorage.userDeleteFile(cid, {from: user1});
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await dumpState(ctx, "user1.deleteFile");

        await chainStorage.userDeleteFile(cid, {from: user2});

        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node1});

        await dumpState(ctx, "node1.finishTask(3)");
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, false);

        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeFinishTask(2, common.fileSize, {from: node2});

        await dumpState(ctx, "node2.finishTask(2)");
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, false);

        await chainStorage.nodeAcceptTask(4, {from: node2});
        await chainStorage.nodeFinishTask(4, common.fileSize, {from: node2});

        await dumpState(ctx, "node2.finishTask(2)");
    })
});