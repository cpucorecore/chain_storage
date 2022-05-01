const common = require('./common');

const UserStorage = artifacts.require("UserStorage");

contract('UserStorage_totalUserNumber', accounts => {
    let userStorageInstance;

    before(async () => {
        userStorageInstance = await UserStorage.deployed();
    })

    it('totalUserNumber', async () => {
        const user1 = accounts[0];
        const user2 = accounts[1];
        const user3 = accounts[2];

        let totalUserNumber;

        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 0);

        await userStorageInstance.newUser(user1, common.initSpace, common.userExt);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 1);

        await userStorageInstance.newUser(user2, common.initSpace, common.userExt);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 2);

        await userStorageInstance.deleteUser(user1);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 1);

        await userStorageInstance.newUser(user3, common.initSpace, common.userExt);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 2);

        await userStorageInstance.newUser(user1, common.initSpace, common.userExt);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 3);

        await userStorageInstance.deleteUser(user1);
        await userStorageInstance.deleteUser(user2);
        await userStorageInstance.deleteUser(user3);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 0);

        await userStorageInstance.newUser(user3, common.initSpace, common.userExt);
        totalUserNumber = await userStorageInstance.getTotalUserNumber.call();
        assert.equal(totalUserNumber, 1);
    });
});