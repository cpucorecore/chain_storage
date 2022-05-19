const common = require('./common');

contract('User_storage_space', accounts => {
    let ctx;
    let chainStorage;
    let fileStorage;
    let userStorage;

    let node1;
    let node2;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 2, 0, 2);

        chainStorage = ctx.chainStorage;
        fileStorage = ctx.fileStorage;
        userStorage = ctx.userStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];
    })

    it('space test', async () => {
        const cid1 = common.cids[0];
        const cid1size = 10001;
        const cid2 = common.cids[1];
        const cid2size = 10002;
        const duration = common.duration;
        const ext = common.fileExt;
        const user = accounts[0];

        let storageUsed;
        let storageTotal;

        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageTotal, 0);

        await chainStorage.userRegister(common.userExt, {from: user});
        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageUsed, 0);
        assert.equal(storageTotal, common.initSpace);

        await chainStorage.userAddFile(cid1, duration, ext, {from: user});
        await chainStorage.nodeAcceptTask(1, {from: node1});
        await chainStorage.nodeAcceptTask(2, {from: node2});
        await chainStorage.nodeFinishTask(1, cid1size, {from: node1});
        await chainStorage.nodeFinishTask(2, cid1size, {from: node2});

        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageUsed, cid1size);
        assert.equal(storageTotal, common.initSpace);

        await chainStorage.userAddFile(cid2, duration, ext, {from: user});
        await chainStorage.nodeAcceptTask(3, {from: node1});
        await chainStorage.nodeAcceptTask(4, {from: node2});
        await chainStorage.nodeFinishTask(3, cid2size, {from: node1});
        await chainStorage.nodeFinishTask(4, cid2size, {from: node2});

        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageUsed, cid1size+cid2size);
        assert.equal(storageTotal, common.initSpace);

        await chainStorage.userDeleteFile(cid1, {from: user});
        await chainStorage.nodeAcceptTask(5, {from: node1});
        await chainStorage.nodeAcceptTask(6, {from: node2});
        await chainStorage.nodeFinishTask(5, cid1size, {from: node1});
        await chainStorage.nodeFinishTask(6, cid1size, {from: node2});

        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageUsed.toNumber(), cid2size);
        assert.equal(storageTotal, common.initSpace);

        await chainStorage.userDeleteFile(cid2, {from: user});
        await chainStorage.nodeAcceptTask(7, {from: node1});
        await chainStorage.nodeAcceptTask(8, {from: node2});
        await chainStorage.nodeFinishTask(7, cid2size, {from: node1});
        await chainStorage.nodeFinishTask(8, cid2size, {from: node2});

        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageUsed.toNumber(), 0);
        assert.equal(storageTotal, common.initSpace);
    })
});
