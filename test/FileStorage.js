const FileStorage = artifacts.require("FileStorage");

contract('FileStorage', (accounts) => {
    it('test', async () => {
        const fileStorageInstance = await FileStorage.deployed(accounts[0]);
        let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
        const size = await fileStorageInstance.getSize.call(cid);

        assert.equal(size, 0, "size is not 0");
    });
});
