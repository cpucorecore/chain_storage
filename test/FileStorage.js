const FileStorage = artifacts.require("FileStorage");

contract('FileStorage', accounts => {
    let size = 10000;

    it('exist', async () => {
        let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';
        const fileStorageInstance = await FileStorage.deployed();

        let exist = await fileStorageInstance.exist.call(cid);
        assert.equal(exist, false, "should not exist");

        await fileStorageInstance.newFile(cid, size);
        exist = await fileStorageInstance.exist.call(cid);
        assert.equal(exist, true, "should exist");

        await fileStorageInstance.deleteFile(cid);
        exist = await fileStorageInstance.exist.call(cid);
        assert.equal(exist, false, "should not exist");
    });

    it('getSize', async () => {
        let cid = 'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H';
        const fileStorageInstance = await FileStorage.deployed();

        let actualSize = await fileStorageInstance.getSize.call(cid);
        assert.equal(actualSize, 0, "size should be 0");

        await fileStorageInstance.newFile(cid, size);
        actualSize = await fileStorageInstance.getSize.call(cid);
        assert.equal(actualSize, size, "wrong size");

        await fileStorageInstance.deleteFile(cid);
        actualSize = await fileStorageInstance.getSize.call(cid);
        assert.equal(actualSize, 0, "size should be 0");
    });

    it('owner test', async () => {
        let cid = 'QmUgU1m8wtsiyfXnKJn6yMP66zph5X716GZqjqYrZWsLjf';
        const fileStorageInstance = await FileStorage.deployed();

        await fileStorageInstance.newFile(cid, size);
        let ownerEmpty = await fileStorageInstance.ownerEmpty.call(cid);
        assert.equal(ownerEmpty, true);

        let owners = await fileStorageInstance.getOwners.call(cid);
        assert.lengthOf(owners, 0);

        let ownerExist = await fileStorageInstance.ownerExist.call(cid, accounts[0]);
        assert.equal(ownerExist, false);

        await fileStorageInstance.addOwner(cid, accounts[0]);
        ownerEmpty = await fileStorageInstance.ownerEmpty.call(cid);
        assert.equal(ownerEmpty, false);

        ownerExist = await fileStorageInstance.ownerExist.call(cid, accounts[0]);
        assert.equal(ownerExist, true);

        owners = await fileStorageInstance.getOwners.call(cid);
        assert.lengthOf(owners, 1);

        await fileStorageInstance.addOwner(cid, accounts[1]);
        ownerEmpty = await fileStorageInstance.ownerEmpty.call(cid);
        assert.equal(ownerEmpty, false);

        owners = await fileStorageInstance.getOwners.call(cid);
        assert.lengthOf(owners, 2);

        await fileStorageInstance.deleteOwner(cid, accounts[0]);
        ownerEmpty = await fileStorageInstance.ownerEmpty.call(cid);
        assert.equal(ownerEmpty, false);

        ownerExist = await fileStorageInstance.ownerExist.call(cid, accounts[0]);
        assert.equal(ownerExist, false);

        owners = await fileStorageInstance.getOwners.call(cid);
        assert.lengthOf(owners, 1);

        await fileStorageInstance.deleteOwner(cid, accounts[1]);
        ownerEmpty = await fileStorageInstance.ownerEmpty.call(cid);
        assert.equal(ownerEmpty, true);

        owners = await fileStorageInstance.getOwners.call(cid);
        assert.lengthOf(owners, 0);
    });

    it('node test', async () => {
        let cid = 'QmRnCyTbu47hdg173ja4j8xUoEZ5MjRHT6yqDMSqtqXHhF';
        const fileStorageInstance = await FileStorage.deployed();

        await fileStorageInstance.newFile(cid, size);
        let nodeEmpty = await fileStorageInstance.nodeEmpty.call(cid);
        assert.equal(nodeEmpty, true);

        let nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 0);

        let nodeExist = await fileStorageInstance.nodeExist.call(cid, accounts[0]);
        assert.equal(nodeExist, false);

        await fileStorageInstance.addNode(cid, accounts[0]);
        nodeEmpty = await fileStorageInstance.nodeEmpty.call(cid);
        assert.equal(nodeEmpty, false);

        nodeExist = await fileStorageInstance.nodeExist.call(cid, accounts[0]);
        assert.equal(nodeExist, true);

        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 1);

        await fileStorageInstance.addNode(cid, accounts[1]);
        nodeEmpty = await fileStorageInstance.nodeEmpty.call(cid);
        assert.equal(nodeEmpty, false);

        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 2);

        await fileStorageInstance.deleteNode(cid, accounts[0]);
        nodeEmpty = await fileStorageInstance.nodeEmpty.call(cid);
        assert.equal(nodeEmpty, false);

        nodeExist = await fileStorageInstance.nodeExist.call(cid, accounts[0]);
        assert.equal(nodeExist, false);

        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 1);

        await fileStorageInstance.deleteNode(cid, accounts[1]);
        nodeEmpty = await fileStorageInstance.nodeEmpty.call(cid);
        assert.equal(nodeEmpty, true);

        nodes = await fileStorageInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 0);
    });
});
