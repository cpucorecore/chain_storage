const common = require('./common');

contract('User_totalUserNumber', accounts => {
    let ctx;
    let chainStorage;
    let userStorage;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 0, 0, 2);
        chainStorage = ctx.chainStorage;
        userStorage = ctx.userStorage;
    })

    it('getTotalUserNumber', async () => {
        const user1 = accounts[0];
        const user2 = accounts[1];
        const user3 = accounts[2];
        const user4 = accounts[3];

        let userNumber;

        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 0);

        await chainStorage.userRegister(common.userExt, {from: user1});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await chainStorage.userDeRegister({from: user1});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 0);

        await chainStorage.userRegister(common.userExt, {from: user1});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await chainStorage.userRegister(common.userExt, {from: user2});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await chainStorage.userRegister(common.userExt, {from: user3});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await chainStorage.userDeRegister({from: user1});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await chainStorage.userDeRegister({from: user2});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await chainStorage.userRegister(common.userExt, {from: user2});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await chainStorage.userRegister(common.userExt, {from: user1});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await chainStorage.userRegister(common.userExt, {from: user4});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 4);

        await chainStorage.userDeRegister({from: user2});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await chainStorage.userDeRegister({from: user3});
        userNumber = await userStorage.getTotalUserNumber.call();
        assert.equal(userNumber, 2);
    })
});
