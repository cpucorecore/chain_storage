const NodeStorage = artifacts.require("NodeStorage");
const common = require('./common');

contract('NodeStorage', accounts => {
    const node1 = accounts[0];
    const node2 = accounts[1];
    const cids = [
        'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir',
        'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H',
        'QmUgU1m8wtsiyfXnKJn6yMP66zph5X716GZqjqYrZWsLjf'
    ];

    it('exist', async () => {
        let exist;
        let status;
        let isOnline;
        let spaceInfo;
        let ext;
        let serviceInfo;
        let freeSpace;
        let totalNodeNumber;
        let totalOnlineNodeNumber;

        const nodeStorageInstance = await NodeStorage.deployed();

        exist = await nodeStorageInstance.exist.call(node1);
        assert.equal(exist, false);

        // do add
        await nodeStorageInstance.newNode(node1, common.nodeTotalSpace, common.nodeExt);

        // tests
        exist = await nodeStorageInstance.exist.call(node1);
        assert.equal(exist, true);

        status = await nodeStorageInstance.getStatus.call(node1);
        assert.equal(status, 1);

        isOnline = await nodeStorageInstance.isNodeOnline.call(node1);
        assert.equal(isOnline, false);

        spaceInfo = await nodeStorageInstance.getStorageSpaceInfo.call(node1);
        assert.equal(spaceInfo.total, common.nodeTotalSpace);
        assert.equal(spaceInfo.used, 0);

        ext = await nodeStorageInstance.getExt.call(node1);
        console.log(ext);

        serviceInfo = await nodeStorageInstance.getServiceInfo.call(node1);
        assert.equal(serviceInfo.maintainCount, 0);
        assert.equal(serviceInfo.offlineCount, 0);
        assert.equal(serviceInfo.taskAddFileFinishCount, 0);
        assert.equal(serviceInfo.taskAddFileFailCount, 0);
        assert.equal(serviceInfo.taskDeleteFileFinishCount, 0);
        assert.equal(serviceInfo.taskAcceptTimeoutCount, 0);
        assert.equal(serviceInfo.taskTimeoutCount, 0);

        freeSpace = await nodeStorageInstance.getStorageFree.call(node1);
        assert.equal(freeSpace, common.nodeTotalSpace);

        totalNodeNumber = await nodeStorageInstance.getTotalNodeNumber.call();
        assert.equal(totalNodeNumber, 1);

        totalOnlineNodeNumber = await nodeStorageInstance.getTotalOnlineNodeNumber.call();
        assert.equal(totalOnlineNodeNumber, 0);
    });
});
