const common = require('./common');

contract('File owners', accounts => {
    let ctx;

    let chainStorage;
    let fileStorage;

    let node1;
    let node2;

    let user1;
    let user2;

    let dumpState;

    before(async () => {
        ctx = await common.prepareTestContext(accounts);

        chainStorage = ctx.chainStorage;
        fileStorage = ctx.fileStorage;

        node1 = ctx.node1;
        node2 = ctx.node2;

        user1 = ctx.user1;
        user2 = ctx.user2;

        dumpState = common.dumpState;
    })

    it('owners', async () => {
        const cid = common.cid;
        const duration = common.duration;
        const fileExt = common.fileExt;

        await chainStorage.userAddFile(cid, duration, fileExt, {from: user1});
        await dumpState(ctx, "user1 addFile");

        let userExist = await fileStorage.userExist.call(cid, user1);
        assert.equal(userExist, true);
        userExist = await fileStorage.userExist.call(cid, user2);
        assert.equal(userExist, false);

        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeFinishTask(1, common.fileSize, {from: node1});
        await dumpState(ctx, "node1 finish task");
        await chainStorage.userAddFile(cid, duration, fileExt, {from: user2});
        await dumpState(ctx, "user2 addFile");

        userExist = await fileStorage.userExist.call(cid, user1);
        assert.equal(userExist, true);
        userExist = await fileStorage.userExist.call(cid, user2);
        assert.equal(userExist, true);

        await chainStorage.userDeleteFile(cid, {from: user1});

        userExist = await fileStorage.userExist.call(cid, user1);
        assert.equal(userExist, false);
        userExist = await fileStorage.userExist.call(cid, user2);
        assert.equal(userExist, true);

        await chainStorage.userDeleteFile(cid, {from: user2});
        await dumpState(ctx, "user2 deleteFile");

        userExist = await fileStorage.userExist.call(cid, user1);
        assert.equal(userExist, false);
        userExist = await fileStorage.userExist.call(cid, user2);
        assert.equal(userExist, true);

        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeFinishTask(3, common.fileSize, {from: node1});

        userExist = await fileStorage.userExist.call(cid, user1);
        assert.equal(userExist, false);
        userExist = await fileStorage.userExist.call(cid, user2);
        assert.equal(userExist, false);
    })
});
