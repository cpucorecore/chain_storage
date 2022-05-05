const common = require('./common');

const NodeStorage = artifacts.require("NodeStorage");

contract('NodeStorage', accounts => {
    it('newNode', async () => {
        const node1 = accounts[0];
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
        assert.equal(spaceInfo[1], common.nodeTotalSpace);
        assert.equal(spaceInfo[0], 0);

        ext = await nodeStorageInstance.getExt.call(node1);
        console.log(ext);

        // (maintainCount, offlineCount, taskAddFileFinishCount, taskAddFileFailCount, taskDeleteFileFinishCount, taskAcceptTimeoutCount, taskTimeoutCount)
        serviceInfo = await nodeStorageInstance.getServiceInfo.call(node1);
        assert.equal(serviceInfo[0], 0);
        assert.equal(serviceInfo[1], 0);
        assert.equal(serviceInfo[2], 0);
        assert.equal(serviceInfo[3], 0);
        assert.equal(serviceInfo[4], 0);
        assert.equal(serviceInfo[5], 0);
        assert.equal(serviceInfo[6], 0);

        freeSpace = await nodeStorageInstance.getStorageFree.call(node1);
        assert.equal(freeSpace, common.nodeTotalSpace);

        totalNodeNumber = await nodeStorageInstance.getTotalNodeNumber.call();
        assert.equal(totalNodeNumber, 1);

        totalOnlineNodeNumber = await nodeStorageInstance.getTotalOnlineNodeNumber.call();
        assert.equal(totalOnlineNodeNumber, 0);
    });

    it('cid tests', async () => {
        const node2 = accounts[1];
        const cids = [
            'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir',
            'QmWAJk3wmp8jqTWp2dQ3NRdoBjnmvupdL2GiBqt69FFk2H',
            'QmUgU1m8wtsiyfXnKJn6yMP66zph5X716GZqjqYrZWsLjf'
        ];
        let cidExist;
        let cidsNumber;
        let nodeCids;

        const nodeStorageInstance = await NodeStorage.deployed();
        await nodeStorageInstance.newNode(node2, common.nodeTotalSpace, common.nodeExt);

        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[0]);
        assert.equal(cidExist, false);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 0);

        await nodeStorageInstance.addNodeCid(node2, cids[0]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[0]);
        assert.equal(cidExist, true);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 1);
        await nodeStorageInstance.addNodeCid(node2, cids[1]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[1]);
        assert.equal(cidExist, true);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 2);
        await nodeStorageInstance.addNodeCid(node2, cids[2]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[0]);
        assert.equal(cidExist, true);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 3);
        nodeCids = await nodeStorageInstance.getNodeCids.call(node2);
        console.log(nodeCids);
        assert.lengthOf(nodeCids, 3);

        let page1Cids = await nodeStorageInstance.getNodeCids.call(node2, 2, 1);
        console.log(page1Cids);
        assert.lengthOf(page1Cids[0], 2);

        let page2Cids = await nodeStorageInstance.getNodeCids.call(node2, 2, 2);
        console.log(page2Cids);
        assert.lengthOf(page2Cids[0], 1);

        page1Cids = await nodeStorageInstance.getNodeCids.call(node2, 50, 1);
        console.log(page1Cids);
        assert.lengthOf(page1Cids[0], 3);

        await nodeStorageInstance.removeNodeCid(node2, cids[1]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[1]);
        assert.equal(cidExist, false);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 2);

        await nodeStorageInstance.removeNodeCid(node2, cids[0]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[0]);
        assert.equal(cidExist, false);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 1);

        await nodeStorageInstance.removeNodeCid(node2, cids[2]);
        cidExist = await nodeStorageInstance.cidExist.call(node2, cids[2]);
        assert.equal(cidExist, false);
        cidsNumber = await nodeStorageInstance.getNodeCidsNumber.call(node2);
        assert.equal(cidsNumber, 0);
    });

    it('node online tests', async () => {
        const node3 = accounts[2];
        const node4 = accounts[3];
        const node5 = accounts[4];
        const nodeStorageInstance = await NodeStorage.deployed();
        let isOnline;
        let onlineNodeAddresses;

        await nodeStorageInstance.newNode(node3, common.nodeTotalSpace, common.nodeExt);

        await nodeStorageInstance.addOnlineNode(node3);
        isOnline = await nodeStorageInstance.isNodeOnline.call(node3);
        assert.equal(isOnline, true);

        onlineNodeAddresses = await nodeStorageInstance.getAllOnlineNodeAddresses.call();
        console.log(onlineNodeAddresses);
        assert.lengthOf(onlineNodeAddresses, 1);

        await nodeStorageInstance.deleteOnlineNode(node3);
        onlineNodeAddresses = await nodeStorageInstance.getAllOnlineNodeAddresses.call();
        console.log(onlineNodeAddresses);
        assert.lengthOf(onlineNodeAddresses, 0);

        isOnline = await nodeStorageInstance.isNodeOnline.call(node3);
        assert.equal(isOnline, false);

        await nodeStorageInstance.addOnlineNode(node4);
        await nodeStorageInstance.addOnlineNode(node3);
        await nodeStorageInstance.deleteOnlineNode(node4);
        await nodeStorageInstance.addOnlineNode(node5);
        await nodeStorageInstance.deleteOnlineNode(node3);

        isOnline = await nodeStorageInstance.isNodeOnline.call(node3);
        assert.equal(isOnline, false);
        isOnline = await nodeStorageInstance.isNodeOnline.call(node4);
        assert.equal(isOnline, false);
        isOnline = await nodeStorageInstance.isNodeOnline.call(node5);
        assert.equal(isOnline, true);
        onlineNodeAddresses = await nodeStorageInstance.getAllOnlineNodeAddresses.call();
        console.log(onlineNodeAddresses);
        assert.lengthOf(onlineNodeAddresses, 1);
    });

    it('node status tests', async () => {
        const node6 = accounts[5];
        const nodeStorageInstance = await NodeStorage.deployed();
        let status;

        await nodeStorageInstance.newNode(node6, common.nodeTotalSpace, common.nodeExt);
        status = await nodeStorageInstance.getStatus.call(node6);
        assert.equal(status, 1);

        await nodeStorageInstance.setStatus(node6, 3);
        status = await nodeStorageInstance.getStatus.call(node6);
        assert.equal(status, 3);

        await nodeStorageInstance.deleteNode(node6);
        status = await nodeStorageInstance.getStatus.call(node6);
        assert.equal(status, 0);
    });

    it('node storage tests', async () => {
        const node7 = accounts[6];
        const nodeStorageInstance = await NodeStorage.deployed();
        const newTotalSpace = common.nodeTotalSpace*2;
        const usedSpace = 1024*1024;

        let totalSpace;
        let freeSpace;
        let used;

        await nodeStorageInstance.newNode(node7, common.nodeTotalSpace, common.nodeExt);

        totalSpace = await nodeStorageInstance.getStorageTotal.call(node7);
        freeSpace = await nodeStorageInstance.getStorageFree.call(node7);
        used = await nodeStorageInstance.getStorageUsed.call(node7);
        assert.equal(totalSpace, common.nodeTotalSpace);
        assert.equal(freeSpace, common.nodeTotalSpace);
        assert.equal(used, 0);

        await nodeStorageInstance.setStorageTotal(node7, newTotalSpace);
        totalSpace = await nodeStorageInstance.getStorageTotal.call(node7);
        freeSpace = await nodeStorageInstance.getStorageFree.call(node7);
        used = await nodeStorageInstance.getStorageUsed.call(node7);
        assert.equal(totalSpace, newTotalSpace);
        assert.equal(freeSpace, newTotalSpace);
        assert.equal(used, 0);

        await nodeStorageInstance.useStorage(node7, usedSpace);
        totalSpace = await nodeStorageInstance.getStorageTotal.call(node7);
        freeSpace = await nodeStorageInstance.getStorageFree.call(node7);
        used = await nodeStorageInstance.getStorageUsed.call(node7);
        assert.equal(totalSpace, newTotalSpace);
        assert.equal(freeSpace, newTotalSpace - usedSpace);
        assert.equal(used, usedSpace);
    });
});
