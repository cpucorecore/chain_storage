const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");

contract('File exist', accounts => {
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

        await settingInstance.setReplica(2);
        await settingInstance.setMaxNodeExtLength(1024);
        await settingInstance.setInitSpace(initSpace);

        await nodeInstance.register(node1, nodeSpace, nodeExt);
        await nodeInstance.register(node2, nodeSpace, nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
    })

    it('exist/status', async () => {
        let exist;
        let status;

        exist = await fileInstance.exist.call(cid);
        status = await fileInstance.getStatus.call(cid);
        assert.equal(exist, false);
        assert.equal(status, 0); // status=Default

        await fileInstance.addFile(cid, size, tom);
        exist = await fileInstance.exist.call(cid);
        status = await fileInstance.getStatus.call(cid);
        assert.equal(exist, true);
        assert.equal(status, 1); // status=Adding

        await fileInstance.addFile(cid, size, bob);
        exist = await fileInstance.exist.call(cid);
        status = await fileInstance.getStatus.call(cid);
        assert.equal(exist, true);
        assert.equal(status, 1); // status=Adding

        await fileInstance.deleteFile(cid, tom);
        exist = await fileInstance.exist.call(cid);
        status = await fileInstance.getStatus.call(cid);
        assert.equal(exist, true);
        assert.equal(status, 1); // status=Adding

        await fileInstance.deleteFile(cid, bob);
        exist = await fileInstance.exist.call(cid);
        status = await fileInstance.getStatus.call(cid);
        assert.equal(exist, true);
        assert.equal(status, 3); // status=Deleting
    })
});