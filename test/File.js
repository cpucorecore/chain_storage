const File = artifacts.require("File");

contract('FileStorage', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    it('exist', async () => {
        const fileInstance = await File.deployed();

        let exist = await fileInstance.exist.call(cid);
        assert.equal(exist, false);

        await fileInstance.addFile(cid, 1000, accounts[0]);

        exist = await fileInstance.exist.call(cid);
        assert.equal(exist, true);
    });
});