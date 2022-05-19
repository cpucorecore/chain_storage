const common = require('./common');

contract('User', accounts => {
    let ctx;

    let chainStorage;
    let userStorage;
    let fileStorage;

    let node1;
    let node2;

    let user1;
    let user2;

    let dumpState;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 2, 2, 2);

        chainStorage = ctx.chainStorage;
        userStorage = ctx.userStorage;
        fileStorage = ctx.fileStorage;

        node1 = ctx.nodes[0];
        node2 = ctx.nodes[1];

        user1 = ctx.users[0];
        user2 = ctx.users[1];

        dumpState = common.dumpState;
    })

    it('exist', async () => {
        const user = accounts[3];
        let exist;

        exist = await userStorage.exist.call(user);
        assert.equal(exist, false);

        await chainStorage.userRegister(common.userExt, {from: user});
        exist = await userStorage.exist.call(user);
        assert.equal(exist, true);

        await chainStorage.userDeRegister({from: user});
        exist = await userStorage.exist.call(user);
        assert.equal(exist, false);
    })

    it('ext tests', async () => {
        const user = accounts[4];
        const newExt = 'newExt';

        let ext;

        ext = await userStorage.getExt.call(user);
        assert.equal(ext, '');

        await chainStorage.userRegister(common.userExt, {from: user});
        ext = await userStorage.getExt.call(user);
        assert.equal(ext, common.userExt);

        await chainStorage.userSetExt(newExt, {from: user});
        ext = await userStorage.getExt.call(user);
        assert.equal(ext, newExt);
    })

    it('storage tests', async () => {
        const user = accounts[5];
        const newSpace = common.initSpace*2;

        let storageUsed;
        let storageTotal;

        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageTotal, 0);

        await chainStorage.userRegister(common.userExt, {from: user});
        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, 0);

        await chainStorage.userSetStorageTotal(user, newSpace, {from: accounts[0]});
        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageTotal, newSpace);
        assert.equal(storageUsed, 0);

        await chainStorage.userDeRegister({from: user});
        storageUsed = await userStorage.getStorageUsed.call(user);
        storageTotal = await userStorage.getStorageTotal.call(user);
        assert.equal(storageTotal, 0);
        assert.equal(storageUsed, 0);

        await dumpState(ctx, "last");
    })
});
