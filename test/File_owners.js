const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");

contract.skip('File owners', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
    let nodeSpace = 1024*1024*1024*1024;
    let initSpace = 1024*1024*1024*5;
    let nodeExt = '{"key":"value"}';

    let settingInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;

    let node1 = accounts[5];
    let node2 = accounts[6];

    let tom = accounts[0];
    let bob = accounts[1];

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setInitSpace(initSpace);

        await nodeInstance.register(node1, nodeSpace, nodeExt);
        await nodeInstance.register(node2, nodeSpace, nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
    })

    it('owners', async () => {
        let owners;
        let ownerExist;

        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 0);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, false);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, false);

        await fileInstance.addFile(cid, size, tom);
        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 1);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, true);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, false);

        await fileInstance.addFile(cid, size, bob);
        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 2);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, true);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, true);

        await fileInstance.addFile(cid, size, tom); // tom add duplicate file
        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 2);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, true);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, true);

        await fileInstance.deleteFile(cid, tom);
        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 1);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, false);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, true);

        await fileInstance.deleteFile(cid, bob);
        owners = await fileInstance.getOwners.call(cid);
        assert.lengthOf(owners, 0);
        ownerExist = await fileInstance.ownerExist.call(cid, tom);
        assert.equal(ownerExist, false);
        ownerExist = await fileInstance.ownerExist.call(cid, bob);
        assert.equal(ownerExist, false);
    })
});