const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");

contract.skip('Node', accounts => {
    let settingInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setInitSpace(common.initSpace);
    })

    it('exist', async () => {
        const node = accounts[0];
        let exist;

        exist = await nodeInstance.exist.call(node);
        assert.equal(exist, false);

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        exist = await nodeInstance.exist.call(node);
        assert.equal(exist, true);

        await nodeInstance.deRegister(node);
        exist = await nodeInstance.exist.call(node);
        assert.equal(exist, false);
    })

    it('status', async () => {
        const node = accounts[0];
        let status;

        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 0);

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 1);

        await nodeInstance.online(node);
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 2);

        await nodeInstance.maintain(node);
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 3);

        await nodeInstance.deRegister(node);
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 0);
    })

    it('status2', async () => {
        const node = accounts[1];
        let status;

        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 0);

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 1);

        // await nodeInstance.maintain(node);
        assert.throws(async () => {
            await nodeInstance.maintain(node);
        }); //TODO fix
        status = await nodeInstance.getStatus.call(node);
        assert.equal(status, 1);
    })

    it.skip('ext tests', async () => {
        const node = accounts[2];
        const newExt = 'newExt';
        let ext;

        ext = await nodeInstance.getExt.call(node);
        assert.equal(ext, '');

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        ext = await nodeInstance.getExt.call(node);
        assert.equal(ext, common.nodeExt);

        await nodeInstance.setExt(node, newExt);
        ext = await nodeInstance.getExt.call(node);
        assert.equal(ext, newExt);

        await nodeInstance.deRegister(node);
        ext = await nodeInstance.getExt.call(node);
        assert.equal(ext, '');

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        ext = await nodeInstance.getExt.call(node);
        assert.equal(ext, common.nodeExt);
    });

    it('storage tests', async () => {
        const node = accounts[3];
        let storageSpaceInfo;

        storageSpaceInfo = await nodeInstance.getStorageSpaceInfo.call(node);
        assert.equal(storageSpaceInfo.total, 0);
        assert.equal(storageSpaceInfo.used, 0);

        await nodeInstance.register(node, common.nodeTotalSpace, common.nodeExt);
        storageSpaceInfo = await nodeInstance.getStorageSpaceInfo.call(node);
        assert.equal(storageSpaceInfo.total, common.nodeTotalSpace);
        assert.equal(storageSpaceInfo.used, 0);

        await nodeInstance.deRegister(node);
        storageSpaceInfo = await nodeInstance.getStorageSpaceInfo.call(node);
        assert.equal(storageSpaceInfo.total, 0);
        assert.equal(storageSpaceInfo.used, 0);
    });
});
