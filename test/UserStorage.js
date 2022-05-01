const common = require('./common');

const UserStorage = artifacts.require("UserStorage");

contract('UserStorage', accounts => {
    let userStorageInstance;

    before(async() => {
        userStorageInstance = await UserStorage.deployed();
    })

    it('exist', async () => {
        const user = accounts[0];

        let exist = await userStorageInstance.exist.call(user);
        assert.equal(exist, false);

        await userStorageInstance.newUser(user, common.initSpace, common.userExt);
        exist = await userStorageInstance.exist.call(user);
        assert.equal(exist, true);

        await userStorageInstance.deleteUser(user);
        exist = await userStorageInstance.exist.call(user);
        assert.equal(exist, false);
    });

    it('ext tests', async () => {
        const user = accounts[1];
        const newExt = "newExt";

        let ext;

        await userStorageInstance.newUser(user, common.initSpace, common.userExt);
        ext = await userStorageInstance.getExt.call(user);
        assert.equal(ext, common.userExt);

        await userStorageInstance.setExt(user, newExt);
        ext = await userStorageInstance.getExt.call(user);
        assert.equal(ext, newExt);

        await userStorageInstance.deleteUser(user);
        ext = await userStorageInstance.getExt.call(user);
        assert.equal(ext, '');
    });

    it('ext tests', async () => {
        const user = accounts[2];
        const newExt = "newExt";

        let total;
        let free;
        let used;
        const actualUsed = 1024*1024;
        const newTotalSpace = common.initSpace*4;

        await userStorageInstance.newUser(user, common.initSpace, common.userExt);
        total = await userStorageInstance.getStorageTotal.call(user);
        free = await userStorageInstance.getStorageFree.call(user);
        used = await userStorageInstance.getStorageUsed.call(user);
        assert.equal(total, common.initSpace);
        assert.equal(free, common.initSpace);
        assert.equal(used, 0);

        await userStorageInstance.setStorageUsed(user, actualUsed);
        total = await userStorageInstance.getStorageTotal.call(user);
        free = await userStorageInstance.getStorageFree.call(user);
        used = await userStorageInstance.getStorageUsed.call(user);
        assert.equal(total, common.initSpace);
        assert.equal(free, common.initSpace - actualUsed);
        assert.equal(used, actualUsed);

        await userStorageInstance.setStorageTotal(user, newTotalSpace);
        total = await userStorageInstance.getStorageTotal.call(user);
        free = await userStorageInstance.getStorageFree.call(user);
        used = await userStorageInstance.getStorageUsed.call(user);
        assert.equal(total, newTotalSpace);
        assert.equal(free, newTotalSpace - actualUsed);
        assert.equal(used, actualUsed);
    });
});
