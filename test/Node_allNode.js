const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");

contract('Node', accounts => {
    let settingInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setInitSpace(common.initSpace);
    })

    it('allnode/allonline tests', async () => {
        const node1 = accounts[0];
        const node2 = accounts[1];
        const node3 = accounts[2];

        let totalNodeNumber;
        let totalOnlineNodeNumber;
        let allNodeAddresses;
        let allOnlineNodeAddresses;

        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 0);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 0);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.register(node1, common.nodeTotalSpace, common.nodeExt);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 1);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 1);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.register(node2, common.nodeTotalSpace, common.nodeExt);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 2);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 2);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.register(node3, common.nodeTotalSpace, common.nodeExt);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.online(node1);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await nodeInstance.online(node2);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 2);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 2);

        await nodeInstance.online(node3);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 3);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 3);
        console.log(allNodeAddresses);
        console.log(allOnlineNodeAddresses);

        await nodeInstance.maintain(node1);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 2);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 2);

        await nodeInstance.maintain(node2);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await nodeInstance.maintain(node3);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.online(node2);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 3);
        assert.equal(totalOnlineNodeNumber, 1);
        assert.lengthOf(allNodeAddresses, 3);
        assert.lengthOf(allOnlineNodeAddresses, 1);

        await nodeInstance.maintain(node2);
        await nodeInstance.deRegister(node2);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 2);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 2);
        assert.lengthOf(allOnlineNodeAddresses, 0);

        await nodeInstance.deRegister(node3);
        await nodeInstance.deRegister(node1);
        totalNodeNumber = await nodeInstance.getTotalNodeNumber.call();
        totalOnlineNodeNumber = await nodeInstance.getTotalOnlineNodeNumber.call();
        allNodeAddresses = await nodeInstance.getAllNodeAddresses.call();
        allOnlineNodeAddresses = await nodeInstance.getAllOnlineNodeAddresses.call();
        assert.equal(totalNodeNumber, 0);
        assert.equal(totalOnlineNodeNumber, 0);
        assert.lengthOf(allNodeAddresses, 0);
        assert.lengthOf(allOnlineNodeAddresses, 0);
    });
});
