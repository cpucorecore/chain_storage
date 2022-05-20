const common = require('./common');
const chai = require("chai");

contract('Node', accounts => {
    let ctx;

    let chainStorage;
    let nodeStorage;

    before(async () => {
        ctx = await common.prepareTestContext(accounts, 0, 2, 2);

        chainStorage = ctx.chainStorage;
        nodeStorage = ctx.nodeStorage;
    })

    it('exist', async () => {
        const node = accounts[0];
        
        let exist = await nodeStorage.exist.call(node);
        assert.equal(exist, false);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        exist = await nodeStorage.exist.call(node);
        assert.equal(exist, true);

        await chainStorage.nodeDeRegister({from: node});
        exist = await nodeStorage.exist.call(node);
        assert.equal(exist, false);
    })

    it('status', async () => {
        const node = accounts[1];
        
        let status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 1);

        await chainStorage.nodeOnline({from: node});
        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 2);

        await chainStorage.nodeMaintain({from: node});
        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 3);

        await chainStorage.nodeDeRegister({from: node});
        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 0);
    })

    it.skip('status2', async () => {
        const node = accounts[2];
        
        let status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 1);

        await chai.expect(
            chainStorage.nodeMaintain({from: node})
        ).to.be.revertedWith("N:wrong status must[O]");

        status = await nodeStorage.getStatus.call(node);
        assert.equal(status, 1);
    })

    it('ext tests', async () => {
        const node = accounts[3];
        const newExt = 'newExt';

        let ext = await nodeStorage.getExt.call(node);
        assert.equal(ext, '');

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        ext = await nodeStorage.getExt.call(node);
        assert.equal(ext, common.nodeExt);

        await chainStorage.nodeSetExt(newExt, {from: node});
        ext = await nodeStorage.getExt.call(node);
        assert.equal(ext, newExt);

        await chainStorage.nodeDeRegister({from: node});
        ext = await nodeStorage.getExt.call(node);
        assert.equal(ext, '');

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        ext = await nodeStorage.getExt.call(node);
        assert.equal(ext, common.nodeExt);
    });

    it('storage tests', async () => {
        const node = accounts[4];
        
        let storageSpaceInfo = await nodeStorage.getStorageSpace.call(node);
        assert.equal(storageSpaceInfo[0], 0);
        assert.equal(storageSpaceInfo[1], 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node});
        storageSpaceInfo = await nodeStorage.getStorageSpace.call(node);
        assert.equal(storageSpaceInfo[0], 0);
        assert.equal(storageSpaceInfo[1], common.nodeStorageTotal);

        await chainStorage.nodeDeRegister({from: node});
        storageSpaceInfo = await nodeStorage.getStorageSpace.call(node);
        assert.equal(storageSpaceInfo[0], 0);
        assert.equal(storageSpaceInfo[1], 0);
    });
});
