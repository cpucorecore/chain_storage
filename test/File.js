const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");

contract('FileStorage', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
    let nodeSpace = 1024*1024*1024*1024;
    let nodeExt = '{"key":"value"}';

    let settingInstance;
    let nodeInstance;
    let fileInstance;

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();

        await settingInstance.setReplica(2);
        await settingInstance.setMaxNodeExtLength(1024);

        await nodeInstance.register(accounts[0], nodeSpace, nodeExt);
        await nodeInstance.register(accounts[1], nodeSpace, nodeExt);
    })

    it('exist', async () => {
        let exist = await fileInstance.exist.call(cid);
        assert.equal(exist, false);

        await fileInstance.addFile(cid, size, accounts[0]);

        exist = await fileInstance.exist.call(cid);
        assert.equal(exist, true);
    });
});