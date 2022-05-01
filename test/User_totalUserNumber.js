const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");
const User = artifacts.require("User");

contract.skip('User_totalUserNumber', accounts => {
    let settingInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;
    let userInstance;

    before(async () => {
        const node1 = accounts[5];
        const node2 = accounts[6];

        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();
        userInstance = await User.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setMaxUserExtLength(common.maxUserExtLength);
        await settingInstance.setInitSpace(common.initSpace);

        await nodeInstance.register(node1, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node2, common.nodeTotalSpace, common.nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
    })

    it('getTotalUserNumber', async () => {
        const user1 = accounts[0];
        const user2 = accounts[1];
        const user3 = accounts[2];
        const user4 = accounts[3];

        let userNumber;

        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 0);

        await userInstance.register(user1, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await userInstance.deRegister(user1);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 0);

        await userInstance.register(user1, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await userInstance.register(user2, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await userInstance.register(user3, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await userInstance.deRegister(user1);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await userInstance.deRegister(user2);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 1);

        await userInstance.register(user2, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);

        await userInstance.register(user1, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await userInstance.register(user4, common.userExt);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 4);

        await userInstance.deRegister(user2);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 3);

        await userInstance.deRegister(user3);
        userNumber = await userInstance.getTotalUserNumber.call();
        assert.equal(userNumber, 2);
    })
});
