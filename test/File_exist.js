const common = require('./common');

contract('File_exist', accounts => {
    let ctx;
    let chainStorage;
    let fileStorage;

    let node1;
    let node2;

    let tom;
    let bob;

    let dumpState = common.dumpState;

    before(async () => {
        ctx = await common.prepareTestContext(accounts);

        chainStorage = ctx.chainStorage;
        fileStorage = ctx.fileStorage;

        tom = ctx.user1;
        bob = ctx.user2;

        node1 = ctx.node1;
        node2 = ctx.node2;
    })

    it('exist', async () => {
        const cid = common.cid;
        const duration = common.duration;
        const fileExt = common.fileExt;

        let exist;

        await chainStorage.userAddFile(cid, duration, fileExt, {from: tom});
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});

        await chainStorage.userAddFile(cid, duration, fileExt, {from: bob});
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await chainStorage.userDeleteFile(cid, {from: tom});
        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, true);

        await dumpState(ctx, "tom.deleteFile");

        await chainStorage.userDeleteFile(cid, {from: bob});

        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node1});

        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, false);

        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeFinishTask(2, common.fileSize, {from: node2});

        exist = await fileStorage.exist.call(cid);
        assert.equal(exist, false);

        await dumpState(ctx, "last");
    })
});