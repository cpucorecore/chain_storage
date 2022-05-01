const common = require("./common");
const History = artifacts.require("History");

contract('History', accounts => {
    let historyInstance;

    const cidHashes = [
        "0xdda4e1efafe56f53f4025cd0708f6bdff673e1aa3995eea9f023c6eec2a7eb4a",
        "0xf8af37dd2f20cebb5f9720a4c63a7ceaa036a5042a30b87a19832e0fa530c84c",
        "0xd4a832f0884972948d6eee2c2daa0e91def2d4bd5f4f899c9eda1d78a28a9b44",
        "0x68fc51c0de0c0e6be1067b90862da21f2e796b933851e5aaecf9d1d6f6ff332b",
        "0x5ef8d464eb9a1baaf9c52ccfef2262fda94bd65cc559526f90e9ea37e73b2068"
    ];

    before(async () => {
        historyInstance = await History.deployed();
    })

    it('User History', async () => {
        const tom = accounts[0];
        const bob = accounts[1];
        let userHistoryNumber;

        await historyInstance.addUserAction(tom, 0, cidHashes[0]);
        userHistoryNumber = await historyInstance.getUserHistoryNumber.call();
        assert.equal(userHistoryNumber, 1);
        await historyInstance.addUserAction(bob, 0, cidHashes[0]);
        userHistoryNumber = await historyInstance.getUserHistoryNumber.call();
        assert.equal(userHistoryNumber, 2);
        await historyInstance.addUserAction(tom, 1, cidHashes[0]);
        userHistoryNumber = await historyInstance.getUserHistoryNumber.call();
        assert.equal(userHistoryNumber, 3);

        let historyIndexesByUser = await historyInstance.getUserHistoryIndexesByUser.call(tom, 20, 1);
        assert.lengthOf(historyIndexesByUser[0], 2);

        let historyIndexesByCidHash = await historyInstance.getUserHistoryIndexesByCidHash.call(cidHashes[0], 20, 1);
        assert.lengthOf(historyIndexesByCidHash[0], 3);
        for(var index in historyIndexesByCidHash[0]) {
            console.log(index.toString());
        }
        console.log("\n");

        let historyIndexesByUserAndCidHash = await historyInstance.getUserHistoryIndexesByUserAndCidHash.call(tom, cidHashes[0], 20, 1);
        assert.lengthOf(historyIndexesByUserAndCidHash[0], 2);
        for(var index in historyIndexesByUserAndCidHash[0]) {
            console.log(index.toString());
        }
        console.log("\n");

        historyIndexesByUserAndCidHash = await historyInstance.getUserHistoryIndexesByUserAndCidHash.call(bob, cidHashes[0], 20, 1);
        assert.lengthOf(historyIndexesByUserAndCidHash[0], 1);
        for(var index in historyIndexesByUserAndCidHash[0]) {
            console.log(index.toString());
        }
        console.log("\n");

        let history = await historyInstance.getUserHistoryNumber.call();
        console.log(history);
    });

    it('Node History', async () => {
        const node1 = accounts[4];
        const node2 = accounts[5];
        const node3 = accounts[6];
        const mockTid = 1;
        const mockNodeActionTypeAdd = 0;

        await historyInstance.addNodeAction(node1, mockTid, mockNodeActionTypeAdd, cidHashes[0]);
        await historyInstance.addNodeAction(node2, mockTid, mockNodeActionTypeAdd, cidHashes[0]);
        await historyInstance.addNodeAction(node3, mockTid, mockNodeActionTypeAdd, cidHashes[0]);
        await historyInstance.addNodeAction(node1, mockTid, mockNodeActionTypeAdd, cidHashes[1]);
        await historyInstance.addNodeAction(node2, mockTid, mockNodeActionTypeAdd, cidHashes[1]);
        await historyInstance.addNodeAction(node1, mockTid, mockNodeActionTypeAdd, cidHashes[2]);

        let nodeHistoryNumber = await historyInstance.getNodeHistoryNumber.call();
        assert.equal(nodeHistoryNumber, 6);

        let nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNode.call(node1, 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 3);
        assert.equal(nodeHistoryIndexes[0][0], 1);
        assert.equal(nodeHistoryIndexes[0][1], 4);
        assert.equal(nodeHistoryIndexes[0][2], 6);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNode.call(node2, 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 2);
        assert.equal(nodeHistoryIndexes[0][0], 2);
        assert.equal(nodeHistoryIndexes[0][1], 5);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNode.call(node3, 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByCidHash.call(cidHashes[0], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 3);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByCidHash.call(cidHashes[1], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 2);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByCidHash.call(cidHashes[2], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node1, cidHashes[0], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node1, cidHashes[1], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node1, cidHashes[2], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node2, cidHashes[0], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node2, cidHashes[1], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node2, cidHashes[2], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 0);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node3, cidHashes[0], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 1);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node3, cidHashes[1], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 0);

        nodeHistoryIndexes = await historyInstance.getNodeHistoryIndexesByNodeAndCidHash.call(node3, cidHashes[2], 20, 1);
        assert.lengthOf(nodeHistoryIndexes[0], 0);
    });
});
