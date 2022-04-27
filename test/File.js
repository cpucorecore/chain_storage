const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");

contract('FileStorage', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
    let nodeSpace = 1024*1024*1024*1024;
    let nodeExt = '{"key":"value"}';

    it('exist', async () => {
        const settingInstance = await Setting.deployed();
        await settingInstance.setReplica(2);
        await settingInstance.setMaxNodeExtLength(1024);

        const nodeInstance = await Node.deployed();
        await nodeInstance.register(accounts[0], nodeSpace, nodeExt);
        await nodeInstance.register(accounts[1], nodeSpace, nodeExt);

        const fileInstance = await File.deployed();

        let exist = await fileInstance.exist.call(cid);
        assert.equal(exist, false);

        await fileInstance.addFile(cid, size, accounts[0]);

        exist = await fileInstance.exist.call(cid);
        assert.equal(exist, true);
    });
});