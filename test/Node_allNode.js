const common = require('./common');

contract('Node', accounts => {
    let ctx;

    let chainStorage;
    let nodeStorage;

    before(async () => {
        ctx = await common.prepareTestContextWithoutNode(accounts);

        chainStorage = ctx.chainStorage;
        nodeStorage = ctx.nodeStorage;
    })

    it('allnode/allonline tests', async () => {
        const node1 = accounts[0];
        const node2 = accounts[1];
        const node3 = accounts[2];

        let totalNodeNumber;
        let totalOnlineNodeNumber;
        let allNodeAddresses;
        let allOnlineNodeAddresses;

        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 0);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 0);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node1});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 1);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 1);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node2});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 2);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 2);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeRegister(common.nodeStorageTotal, common.nodeExt, {from: node3});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeOnline({from: node1});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await chainStorage.nodeOnline({from: node2});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 2);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 2);

        await chainStorage.nodeOnline({from: node3});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 3);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 3);
        console.log(allNodeAddresses);
        console.log(allOnlineNodeAddresses);

        await chainStorage.nodeMaintain({from: node1});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 2);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 2);

        await chainStorage.nodeMaintain({from: node2});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await chainStorage.nodeMaintain({from: node3});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeOnline({from: node2});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await chainStorage.nodeMaintain({from: node2});
        await chainStorage.nodeDeRegister({from: node2});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 2);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 2);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await chainStorage.nodeDeRegister({from: node3});
        await chainStorage.nodeDeRegister({from: node1});
        totalNodeNumber = await nodeStorage.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeStorage.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeStorage.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeStorage.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 0);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 0);
        assert.lengthOf(allOnlineNodeAddresses, 0);
    });
});
