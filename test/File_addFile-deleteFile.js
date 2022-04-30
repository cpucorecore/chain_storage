const common = require('./common');

const Setting = artifacts.require("Setting");
const Node = artifacts.require("Node");
const File = artifacts.require("File");
const Task = artifacts.require("Task");

contract.skip('File_addFile-deleteFile', accounts => {
    let size = 10000;
    let cid = 'QmeN6JUjRSZJgdQFjFMX9PHwAFueWbRecLKBZgcqYLboir';

    let settingInstance;
    let nodeInstance;
    let fileInstance;
    let taskInstance;

    let node1 = accounts[5];
    let node2 = accounts[6];

    let tom = accounts[0];
    let bob = accounts[1];

    before(async () => {
        settingInstance = await Setting.deployed();
        nodeInstance = await Node.deployed();
        fileInstance = await File.deployed();
        taskInstance = await Task.deployed();

        await settingInstance.setReplica(common.replica);
        await settingInstance.setMaxNodeExtLength(common.maxNodeExtLength);
        await settingInstance.setInitSpace(common.initSpace);

        await nodeInstance.register(node1, common.nodeTotalSpace, common.nodeExt);
        await nodeInstance.register(node2, common.nodeTotalSpace, common.nodeExt);

        await nodeInstance.online(node1);
        await nodeInstance.online(node2);
    })

    it('fileAdded', async () => {
        let nodeExist;
        let nodeCids;
        let taskCount;
        let nodes;

        await fileInstance.addFile(cid, size, tom);
        await fileInstance.addFile(cid, size, bob);

        nodeExist = await fileInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);
        nodeCids = await nodeInstance.getNodeCids.call(node1);
        assert.lengthOf(nodeCids, 0);
        nodeCids = await nodeInstance.getNodeCids.call(node2);
        assert.lengthOf(nodeCids, 0);
        nodes = await fileInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 0);

        taskCount = await taskInstance.getCurrentTid.call();
        assert.equal(taskCount, 2);

        await taskInstance.acceptTask(node1, 1);
        await taskInstance.acceptTask(node2, 2);

        await nodeInstance.finishTask(node1, 1);
        nodes = await fileInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 1);
        console.log(nodes);
        await nodeInstance.finishTask(node2, 2);
        nodes = await fileInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 2);
        console.log(nodes);

        nodeExist = await fileInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        nodeCids = await nodeInstance.getNodeCids.call(node1);
        assert.lengthOf(nodeCids, 1);
        console.log(nodeCids);
        nodeCids = await nodeInstance.getNodeCids.call(node2);
        assert.lengthOf(nodeCids, 1);
        console.log(nodeCids);

        await fileInstance.deleteFile(cid, tom);

        nodeExist = await fileInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        nodeCids = await nodeInstance.getNodeCids.call(node1);
        assert.lengthOf(nodeCids, 1);
        nodeCids = await nodeInstance.getNodeCids.call(node2);
        assert.lengthOf(nodeCids, 1);

        await fileInstance.deleteFile(cid, bob);

        nodeExist = await fileInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, true);
        nodeExist = await fileInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, true);
        nodeCids = await nodeInstance.getNodeCids.call(node1);
        assert.lengthOf(nodeCids, 1);
        nodeCids = await nodeInstance.getNodeCids.call(node2);
        assert.lengthOf(nodeCids, 1);

        await taskInstance.acceptTask(node1, 3);
        await taskInstance.acceptTask(node2, 4);

        await nodeInstance.finishTask(node1, 3);
        let fileExist = await fileInstance.exist(cid);
        assert.equal(fileExist, true);
        nodes = await fileInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 1);
        console.log(nodes);
        await nodeInstance.finishTask(node2, 4);

        nodeExist = await fileInstance.nodeExist.call(cid, node1);
        assert.equal(nodeExist, false);
        nodeExist = await fileInstance.nodeExist.call(cid, node2);
        assert.equal(nodeExist, false);
        nodeCids = await nodeInstance.getNodeCids.call(node1);
        assert.lengthOf(nodeCids, 0);

        nodeCids = await nodeInstance.getNodeCids.call(node2);
        assert.lengthOf(nodeCids, 0);

        nodes = await fileInstance.getNodes.call(cid);
        assert.lengthOf(nodes, 0);

        fileExist = await fileInstance.exist(cid);
        assert.equal(fileExist, false);
    })
});