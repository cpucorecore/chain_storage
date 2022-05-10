const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");
const User = artifacts.require("User");

contract('User_storage_space', accounts => {
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
        await settingInstance.setMaxCidLength(common.maxCidLength);
        await settingInstance.setInitSpace(common.initSpace);

        await nodeInstance.register(node1, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node2, common.nodeTotalSpace, common.nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
    })

    it('space test', async () => {
        const user = accounts[1];
        const cid1 = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
        const cid1size = 10001;
        const cid2 = 'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H';
        const cid2size = 10002;
        const duration = 3600;
        const ext = "fileExt";

        let storageUsed;
        let storageTotal;

        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, 0);

        await userInstance.register(user, common.userExt);
        storageUsed = await userInstance.getStorageUsed.call(user);
        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, 0);

        await userInstance.addFile(user, cid1, cid1size, duration, ext);
        storageUsed = await userInstance.getStorageUsed.call(user);
        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, cid1size);

        await userInstance.addFile(user, cid2, cid2size, duration, ext);
        storageUsed = await userInstance.getStorageUsed.call(user);
        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, cid1size+cid2size);

        await userInstance.deleteFile(user, cid1);
        storageUsed = await userInstance.getStorageUsed.call(user);
        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, cid2size);

        await userInstance.deleteFile(user, cid2);
        storageUsed = await userInstance.getStorageUsed.call(user);
        storageTotal = await userInstance.getStorageTotal.call(user);
        assert.equal(storageTotal, common.initSpace);
        assert.equal(storageUsed, 0);
    })
});
