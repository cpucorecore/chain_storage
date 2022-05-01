const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");
const User = artifacts.require("User");

contract('User', accounts => {
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

    it('exist', async () => {
        const user = accounts[0];
        let exist;

        exist = await userInstance.exist.call(user);
        assert.equal(exist, false);

        await userInstance.register(user, common.userExt);
        exist = await userInstance.exist.call(user);
        assert.equal(exist, true);

        await userInstance.deRegister(user);
        exist = await userInstance.exist.call(user);
        assert.equal(exist, false);
    })

    it('ext tests', async () => {
        const user = accounts[0];
        const newExt = 'newExt';

        let ext;

        ext = await userInstance.getExt.call(user);
        assert.equal(ext, '');

        await userInstance.register(user, common.userExt);
        ext = await userInstance.getExt.call(user);
        assert.equal(ext, common.userExt);

        await userInstance.setExt(user, newExt);
        ext = await userInstance.getExt.call(user);
        assert.equal(ext, newExt);
    })

    it('storage tests', async () => {
        const user = accounts[1];
        const newSpace = common.initSpace*2;

        let storageInfo;

        storageInfo = await userInstance.getStorageInfo.call(user);
        assert.equal(storageInfo.total, 0);

        await userInstance.register(user, common.userExt);
        storageInfo = await userInstance.getStorageInfo.call(user);
        assert.equal(storageInfo.total, common.initSpace);
        assert.equal(storageInfo.used, 0);

        await userInstance.changeSpace(user, newSpace);
        storageInfo = await userInstance.getStorageInfo.call(user);
        assert.equal(storageInfo.total, newSpace);
        assert.equal(storageInfo.used, 0);

        await userInstance.deRegister(user);
        storageInfo = await userInstance.getStorageInfo.call(user);
        assert.equal(storageInfo.total, 0);
        assert.equal(storageInfo.used, 0);
    })
});